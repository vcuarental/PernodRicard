/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_PromoReq_UpdatePromoPlanItems
 * Description: Update Promotion Plan Items(Trade A&P Plan Item) Committed Quantity
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-02       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public with sharing class ASI_CRM_VN_PromoReq_UpdatePromoPlanItems {
    private final static String RECORD_SUBMITTED = 'Submitted';
    private final static String RECORD_OPEN = 'Open';


    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        system.debug('Trigger ASI_CRM_VN_PromoReq_UpdatePromoPlanItems Function');
        List<ASI_GiftBox_Request_Header__c> csRequestList = (List<ASI_GiftBox_Request_Header__c>) newList;
        Map<Id,ASI_GiftBox_Request_Header__c> csRequestOldMap = (Map<Id,ASI_GiftBox_Request_Header__c>) oldMap;
        List<Id> csRequestSubmitted = new List<Id> ();


//        A request needs to recompute plan if status changes
        for (ASI_GiftBox_Request_Header__c csRequest : csRequestList){
            if ((csRequest.ASI_GiftBox_Status__c == RECORD_SUBMITTED && csRequestOldMap.get(csRequest.Id).ASI_GiftBox_Status__c != RECORD_SUBMITTED)
                    || (csRequest.ASI_GiftBox_Status__c == RECORD_OPEN && csRequestOldMap.get(csRequest.Id).ASI_GiftBox_Status__c != RECORD_OPEN))
                csRequestSubmitted.add(csRequest.Id);
        }

//        Get requestItems and planItems
        List<Id> requestItemIds = new List<Id>();
        for (ASI_GiftBox_Request_Item__c requestItem : [SELECT ASI_CRM_Trade_A_P_Plan_Item__c FROM ASI_GiftBox_Request_Item__c WHERE ASI_GiftBox_Request_Id__c IN :csRequestSubmitted]) {
            requestItemIds.add(requestItem.ASI_CRM_Trade_A_P_Plan_Item__c);
        }
        List<ASI_CRM_Trade_A_P_Plan_Item__c> planItems = [SELECT Id, ASI_CRM_Committed_Quantity__c,
        (SELECT Id, ASI_GiftBox_Request_Quantity__c, ASI_GiftBox_Request_Id__r.ASI_GiftBox_Status__c FROM Gift_Box_POSM_Request_Items__r)
        FROM ASI_CRM_Trade_A_P_Plan_Item__c WHERE Id IN :requestItemIds];

        System.debug(requestItemIds);
        System.debug(planItems);

//        update plan items committed quantity
        for (ASI_CRM_Trade_A_P_Plan_Item__c planItem : planItems) {
            planItem.ASI_CRM_Committed_Quantity__c = 0;
            for (ASI_GiftBox_Request_Item__c requestItem : planItem.Gift_Box_POSM_Request_Items__r) {
                if (requestItem.ASI_GiftBox_Request_Id__r.ASI_GiftBox_Status__c != RECORD_OPEN) {
                    planItem.ASI_CRM_Committed_Quantity__c += requestItem.ASI_GiftBox_Request_Quantity__c;

                }
            }
        }


        update planItems;
    }
}