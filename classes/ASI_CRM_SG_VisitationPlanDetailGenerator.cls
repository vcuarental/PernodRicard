public with sharing class ASI_CRM_SG_VisitationPlanDetailGenerator {
  public static final Date DEF_VALUE_VISIT_DATE = System.today().addDays(1);
  public static final String ASI_SG_CRM_VISITATIONPLAN_DETAIL_RECORDTYPE = 'ASI_CRM_SG_Visitation_Plan_Detail';
  private Id SG_RecordtypeId{
    get
    { return [Select Id from Recordtype where Developername=:ASI_SG_CRM_VISITATIONPLAN_DETAIL_RECORDTYPE].Id;
    }
    private set; 
  }

  public ASI_HK_CRM_Visitation_Plan_Detail__c generateBasicVisitationPlanDetail(ASI_HK_CRM_Visitation_Plan__c visitPlan, ASI_CRM_AccountsAdditionalField__c acct, Date visitDate) {
    return new ASI_HK_CRM_Visitation_Plan_Detail__c(
      ASI_HK_CRM_Visitation_Plan__c = visitPlan.Id
      , ASI_CRM_MY_Customer__c = acct.Id
      , ASI_HK_CRM_Visit_Date__c = visitDate
      , recordtypeId = SG_RecordtypeId
    );
  }

  public ASI_HK_CRM_Visitation_Plan_Detail__c generateVisitationPlanDetail(ASI_HK_CRM_Visitation_Plan__c visitPlan, ASI_CRM_AccountsAdditionalField__c acct, Date visitDate) {
    return generateBasicVisitationPlanDetail(visitPlan, acct, visitDate);
  }

}