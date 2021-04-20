/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_PromoReq_UpdatePromotionPlan
 * Description: Update Promotion Plan (Trade A&P Plan ) ASI_CRM_Committed_Amount__c and ASI_CRM_Committed_Outlet__c
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-03       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public with sharing class ASI_CRM_VN_PromoReq_UpdatePromotionPlan {
    private final static String RECORD_SUBMITTED = 'Submitted';
    private final static String RECORD_OPEN = 'Open';


    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_GiftBox_Request_Header__c> csRequestList = (List<ASI_GiftBox_Request_Header__c>) newList;
        Map<Id, ASI_GiftBox_Request_Header__c> csRequestOldMap = (Map<Id, ASI_GiftBox_Request_Header__c>) oldMap;
        List<Id> csRequestSubmitted = new List<Id>();

        //        A request needs to recompute plan if status changes
        for (ASI_GiftBox_Request_Header__c csRequest : csRequestList) {
            if ((csRequest.ASI_GiftBox_Status__c == RECORD_SUBMITTED && csRequestOldMap.get(csRequest.Id).ASI_GiftBox_Status__c != RECORD_SUBMITTED)
                    || (csRequest.ASI_GiftBox_Status__c == RECORD_OPEN && csRequestOldMap.get(csRequest.Id).ASI_GiftBox_Status__c != RECORD_OPEN))
                csRequestSubmitted.add(csRequest.Id);
        }

        //        Get plans
        List<ASI_CRM_Trade_A_P_Plan__c> plans = [
                SELECT Id, ASI_CRM_Committed_Amount__c, ASI_CRM_Committed_Outlet__c, (SELECT ASI_CRM_VN_Amount__c, ASI_GiftBox_Status__c FROM Gift_Box_POSM_Requests__r)
                FROM ASI_CRM_Trade_A_P_Plan__c
                where Id in (SELECT ASI_CRM_Trade_A_P_Plan__c FROM ASI_GiftBox_Request_Header__c WHERE Id in :csRequestSubmitted)
        ];

        //        count distinct outlet
        Map<Id, Integer> planIdToOutletCount = new Map<Id, Integer>();
        List<AggregateResult> result = [
                SELECT ASI_CRM_Trade_A_P_Plan__c, COUNT_DISTINCT(ASI_CRM_VN_Contract__r.ASI_CRM_Outlet_WS__c)
                FROM ASI_GiftBox_Request_Header__c
                WHERE Id in :csRequestSubmitted AND ASI_GiftBox_Status__c = :RECORD_SUBMITTED
                GROUP BY ASI_CRM_Trade_A_P_Plan__c
        ];
        for (AggregateResult r : result) {
            planIdToOutletCount.put((Id) r.get('ASI_CRM_Trade_A_P_Plan__c'), (Integer) r.get('expr0'));
        }


        //        update plan items committed quantity and committed outlet
        for (ASI_CRM_Trade_A_P_Plan__c plan : plans) {
            plan.ASI_CRM_Committed_Amount__c = 0;
            plan.ASI_CRM_Committed_Outlet__c = 0;
            for (ASI_GiftBox_Request_Header__c request : plan.Gift_Box_POSM_Requests__r) {
                if (request.ASI_GiftBox_Status__c != RECORD_OPEN) {
                    plan.ASI_CRM_Committed_Amount__c += request.ASI_CRM_VN_Amount__c != null ? request.ASI_CRM_VN_Amount__c : 0;
                }
            }
            plan.ASI_CRM_Committed_Outlet__c = planIdToOutletCount.get(plan.Id);
        }


        update plans;
    }

}