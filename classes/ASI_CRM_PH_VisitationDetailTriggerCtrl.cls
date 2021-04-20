/*********************************************************************************
 * Name: ASI_CRM_PH_VisitationDetailTriggerCtrl
 * Description: Class for handling the visitation plan detail trigger logic
 * Logic 1 : Before Insert : Copy menu listing & pouring from latest visitation 
 * Logic 2 : After Update  : Update customer master last visit date when visitation completed
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 02/01/2019       Hugo Cheung             Created          
*/
public with sharing class ASI_CRM_PH_VisitationDetailTriggerCtrl {

    public static void copyMenuListingAndPouringFromLatestVisitation(List<sObject> sObjectList) {
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = (List<ASI_HK_CRM_Visitation_Plan_Detail__c>) sObjectList;

        Set<Id> customerIdSet = new Set<Id>();
        for(ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail : visitationPlanDetailList) 
            customerIdSet.add(visitationPlanDetail.ASI_CRM_MY_Customer__c);

        List<ASI_HK_CRM_Visitation_Plan_Detail__c> existingVisitationPlanDetailList = [SELECT Id, 
                ASI_CRM_MY_Customer__c,
                ASI_CRM_Menu_Listing__c,
                ASI_CRM_Pouring__c
            FROM ASI_HK_CRM_Visitation_Plan_Detail__c
            WHERE ASI_CRM_MY_Customer__c in :customerIdSet
            AND ASI_HK_CRM_Visit_Date__c = LAST_90_DAYS
            AND ASI_HK_CRM_Status__c = 'Achieved'
            ORDER BY ASI_HK_CRM_Visit_Date__c DESC
            ];

        Map<Id, ASI_HK_CRM_Visitation_Plan_Detail__c> latestVisitationPlanDetailMap = new Map<Id, ASI_HK_CRM_Visitation_Plan_Detail__c>();
        for(ASI_HK_CRM_Visitation_Plan_Detail__c existingVisitationPlanDetail : existingVisitationPlanDetailList) {
            if(latestVisitationPlanDetailMap.containsKey(existingVisitationPlanDetail.ASI_CRM_MY_Customer__c)) 
                continue;
            else 
                latestVisitationPlanDetailMap.put(existingVisitationPlanDetail.ASI_CRM_MY_Customer__c, existingVisitationPlanDetail);
        }

        for(ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail : visitationPlanDetailList) {
            if(latestVisitationPlanDetailMap.containsKey(visitationPlanDetail.ASI_CRM_MY_Customer__c)) {
                visitationPlanDetail.ASI_CRM_Menu_Listing__c = latestVisitationPlanDetailMap.get(visitationPlanDetail.ASI_CRM_MY_Customer__c).ASI_CRM_Menu_Listing__c;
                visitationPlanDetail.ASI_CRM_Pouring__c = latestVisitationPlanDetailMap.get(visitationPlanDetail.ASI_CRM_MY_Customer__c).ASI_CRM_Pouring__c;
            }
        }

    }
    
}