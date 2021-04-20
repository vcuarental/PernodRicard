/*********************************************************************************
 * Name: ASI_CRM_VN_CapsuleCS_addHeaderAmount
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    ----------------------------------------
 * 23/11/2017       Kevin Choi             Created          
***********************************************************************************/
public class ASI_CRM_VN_CapsuleCS_addHeaderAmount{

    public ASI_CRM_VN_CapsuleCS_addHeaderAmount(){

    }

    public void executeTrigger(List<sObject> newList) {

        system.debug('Trigger addHeaderAmount function');
        Set<Id> requestHeaderIdSet = new  Set<Id>(); 
        list<ASI_GiftBox_Request_Item__c> requestItemList = (list<ASI_GiftBox_Request_Item__c>) newList;

        for (ASI_GiftBox_Request_Item__c requestItem : (list<ASI_GiftBox_Request_Item__c>) requestItemList){
            requestHeaderIdSet.add(requestItem.ASI_GiftBox_Request_Id__c);
        }
        system.debug('requestHeaderIdSet:'+requestHeaderIdSet);
        if (requestHeaderIdSet.size() > 0){

            Map<Id, ASI_GiftBox_Request_Header__c> requestHeaderMap = new Map<Id, ASI_GiftBox_Request_Header__c>([select Id, ASI_CRM_VN_Amount__c, ASI_CRM_VN_Contract__c  
                                                                                                                  from ASI_GiftBox_Request_Header__c 
                                                                                                                  where Id IN: requestHeaderIdSet]);
            system.debug('requestHeaderMap:' + requestHeaderMap);
            for (ASI_GiftBox_Request_Item__c requestItem : (list<ASI_GiftBox_Request_Item__c>) requestItemList){
                if (requestHeaderMap.get(requestItem.ASI_GiftBox_Request_Id__c) != null){
                    system.debug('requestHeaderMap.get(requestItem.ASI_GiftBox_Request_Id__c):' + requestHeaderMap.get(requestItem.ASI_GiftBox_Request_Id__c));
                    requestHeaderMap.get(requestItem.ASI_GiftBox_Request_Id__c).ASI_CRM_VN_Amount__c += requestItem.ASI_CRM_Amount__c;

                }
            }
            
            // Round Down Function
            if (requestHeaderMap.values().size() > 0){
                for (ASI_GiftBox_Request_Header__c header : requestHeaderMap.values()){
                    system.debug('Previous:'+header.ASI_CRM_VN_Amount__c);

                    Decimal totalAmt = header.ASI_CRM_VN_Amount__c/10000;
                    header.ASI_CRM_VN_Amount__c = (totalAmt.round(System.RoundingMode.DOWN))*10000;

                    system.debug('After:'+header.ASI_CRM_VN_Amount__c);
                }

                update requestHeaderMap.values();
            }
        }
    }
}