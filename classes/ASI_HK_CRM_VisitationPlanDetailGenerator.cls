public with sharing class ASI_HK_CRM_VisitationPlanDetailGenerator {
    public static final Date DEF_VALUE_VISIT_DATE = System.today().addDays(1);
    
    public ASI_HK_CRM_Visitation_Plan_Detail__c generateBasicVisitationPlanDetail(ASI_HK_CRM_Visitation_Plan__c visitPlan, Account acct, Date visitDate) {
        if(visitPlan.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_TW_Merchandiser_Visitation_Plan')){
            return new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_HK_CRM_Visitation_Plan__c = visitPlan.Id
                , ASI_HK_CRM_Account__c = acct.Id
                , ASI_HK_CRM_Visit_Date__c = visitDate
                , RecordTypeId=Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_TW_Merchandiser_Visitation_Plan_Detail')
            );
        }else if(visitPlan.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_TW_Visitation_Plan')){
            return new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_HK_CRM_Visitation_Plan__c = visitPlan.Id
                , ASI_HK_CRM_Account__c = acct.Id
                , ASI_HK_CRM_Visit_Date__c = visitDate
                , RecordTypeId=Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_TW_Visitation_Plan_Detail')
            );
        }
        else{
            return new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_HK_CRM_Visitation_Plan__c = visitPlan.Id
                , ASI_HK_CRM_Account__c = acct.Id
                , ASI_HK_CRM_Visit_Date__c = visitDate
            );
        }
    }

    public ASI_HK_CRM_Visitation_Plan_Detail__c generateVisitationPlanDetail(ASI_HK_CRM_Visitation_Plan__c visitPlan, Account acct, Date visitDate) {
        return generateBasicVisitationPlanDetail(visitPlan, acct, visitDate);
    }

}