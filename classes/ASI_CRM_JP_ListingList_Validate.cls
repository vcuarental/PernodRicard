/*********************************************************************************
 * Name:ASI_CRM_JP_ListingList_Validate
 * Description: Validate Listing List values to avoid duplicate Item Group
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 16/12/2014       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_ListingList_Validate extends ASI_CRM_JP_TriggerAbstract {


    public ASI_CRM_JP_ListingList_Validate() {
        super('ASI_CRM_JP_ListingList_Validate');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Listing_List__c> listingList = (List<ASI_CRM_Listing_List__c>)sObjList;
        List<ASI_CRM_Listing_List__c> validListingList = new List<ASI_CRM_Listing_List__c>();
        
        Set<String> uniqueKeySet = new Set<String>();
        
        // Check if there is a duplicate within the batch
        for(ASI_CRM_Listing_List__c listing : listingList) {
            
            String key = (String)listing.ASI_CRM_Customer__c + (String)listing.ASI_CRM_Item_Group__c;
            if(!uniqueKeySet.contains(key)) {
                uniqueKeySet.add(key);
            } else {
                listing.adderror(' ' + Label.ASI_CRM_JP_Duplicate_Error);
            }
        }
        
        if(oldMap != null) {
            Map<ID, ASI_CRM_Listing_List__c> listingListOldMap = (Map<ID, ASI_CRM_Listing_List__c>)oldMap;
            
            for(ASI_CRM_Listing_List__c listing : listingList) {
            
                if(listingListOldMap.get(listing.id).ASI_CRM_Item_Group__c != listing.ASI_CRM_Item_Group__c 
                    || listing.ASI_CRM_Customer__c != listingListOldMap.get(listing.id).ASI_CRM_Customer__c) {
                    validListingList.add(listing);
                }
            }
        } else {
            validListingList = listingList;
        }
        
        // Core Code
        if(validListingList.size() > 0) {
            Set<ID> customerIDSet = new Set<ID>();
            
            for(ASI_CRM_Listing_List__c listing : validListingList) {
                customerIDSet.add(listing.ASI_CRM_Customer__c);
            }
            
            List<ASI_CRM_Listing_List__c> existingListingList = [SELECT ID, name, ASI_CRM_Customer__c, ASI_CRM_Item_Group__c
                                                                    FROM ASI_CRM_Listing_List__c
                                                                    WHERE ASI_CRM_Customer__c IN : customerIDSet];
            
            for(ASI_CRM_Listing_List__c listing : validListingList) {
                
                for(ASI_CRM_Listing_List__c listing2 : existingListingList) {
                    String key = (String)listing2.ASI_CRM_Customer__c + (String)listing2.ASI_CRM_Item_Group__c;
                    
                    if(!uniqueKeySet.contains(key)) {
                        uniqueKeySet.add(key);
                    } else {
                        listing.adderror(' ' + Label.ASI_CRM_JP_Duplicate_Error);
                        break;
                    }
                }
            }
        }
        
    }

}