/*
 *    Description : Apex Helper class which would be invoked from Apex Trigger Helper
 *    'ASI_GiftBox_RequestItemTriggerClass'
 * 
 *     Version         Author                Date            Description
 *     1.0             Neha Sonawane         11/09/2015      Initial Draft
 */
public class ASI_GiftBox_RequestItemHelper {
    //Method to populate ItemDelivered on before update/insert of Request Item
    public static void populateItemDelivered(list<ASI_GiftBox_Request_Item__c> itemList){
        Set<Id> headerIdSet = new Set<Id>();
        Set<Id> ownerIdSet = new Set<Id>();
        Set<Id> cusIdSet = new Set<Id>();
        Set<Id> itemIdSet = new Set<Id>();
        Set<String> fiscalYearSet = new Set<String>();
        Map<Id, ASI_GiftBox_Request_Header__c> headerMap = new Map<Id, ASI_GiftBox_Request_Header__c>();
        for(ASI_GiftBox_Request_Item__c item:itemList){
            headerIdSet.add(item.ASI_GiftBox_Request_Id__c);  
            itemIdSet.add(item.ASI_GiftBox_Request_Item__c);     
        }
        for(ASI_GiftBox_Request_Header__c header:[Select Id, ownerID, ASI_CRM_Customer__c,ASI_CRM_VN_Fiscal_Year__c From ASI_GiftBox_Request_Header__c Where Id In :headerIdSet]){
            fiscalYearSet.add(header.ASI_CRM_VN_Fiscal_Year__c);
            ownerIdSet.add(header.ownerID);
            cusIdSet.add(header.ASI_CRM_Customer__c);
            headerMap.put(header.Id, header);
        }
        List<ASI_GiftBox_Request_Header__c> exsitRequest = [Select ID,
                                                                   ASI_CRM_Customer__c,
                                                                   ASI_CRM_VN_Fiscal_Year__c,
                                                                   ownerID,
                                                                   (
                                                                        Select ASI_GiftBox_Request_Quantity__c,
                                                                        ASI_CRM_Quantity_Adjusted__c,
                                                                        ASI_GiftBox_Request_Item__r.ASI_CRM_Category__c
                                                                        From Gift_Box_Request_Items__r
                                                                        Where recordtype.developerName = 'ASI_CRM_VN_POSM_Request_Item'
                                                                   )
                                                            From ASI_GiftBox_Request_Header__c
                                                            Where ownerId in :ownerIdSet
                                                            AND ASI_CRM_Customer__c in :cusIdSet
                                                            AND ASI_CRM_VN_Fiscal_Year__c in :fiscalYearSet
                                                            And ASI_GiftBox_Status__c = 'Complete'];
        Map<Id, ASI_GiftBox_Inventory_Master__c> categoryMap = new Map<Id, ASI_GiftBox_Inventory_Master__c>([Select Id, 
                                                                                                            ASI_CRM_Category__c 
                                                                                                            From ASI_GiftBox_Inventory_Master__c
                                                                                                            Where Id In :itemIdSet]);
        for(ASI_GiftBox_Request_Item__c item:itemList){
            item.ASI_CRM_Item_Delivered__c = 0;
            for(ASI_GiftBox_Request_Header__c existHeader:exsitRequest){
                if(existHeader.ASI_CRM_Customer__c == headerMap.get(item.ASI_GiftBox_Request_Id__c).ASI_CRM_Customer__c &&
                        existHeader.ASI_CRM_VN_Fiscal_Year__c == headerMap.get(item.ASI_GiftBox_Request_Id__c).ASI_CRM_VN_Fiscal_Year__c &&
                        existHeader.ownerId == headerMap.get(item.ASI_GiftBox_Request_Id__c).ownerId){
                    for(ASI_GiftBox_Request_Item__c existItem:existHeader.Gift_Box_Request_Items__r){
                        system.debug('Check Category: ' + existItem.ASI_GiftBox_Request_Item__r.ASI_CRM_Category__c + ' ' +categoryMap.get(item.Id));
                        if(existItem.ASI_GiftBox_Request_Item__r.ASI_CRM_Category__c == categoryMap.get(item.ASI_GiftBox_Request_Item__c).ASI_CRM_Category__c){
                            item.ASI_CRM_Item_Delivered__c += existItem.ASI_CRM_Quantity_Adjusted__c; 
                        }    
                    }
                }
            } 
        }                    
    }
}