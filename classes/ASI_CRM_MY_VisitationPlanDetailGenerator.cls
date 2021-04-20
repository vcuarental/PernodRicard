/*********************************************************************************
 * Name: ASI_CRM_MY_VisitationPlanEditController
 * Description: Controller class for ASI_CRM_MY_VisitationPlanEditPage
 *
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-01-01       Daniel WONG             Copy FROM ASI_HK_CRM_VisitationPlanDetailGenerator
 */
 
public with sharing class ASI_CRM_MY_VisitationPlanDetailGenerator {
  public static final Date DEF_VALUE_VISIT_DATE = System.today().addDays(1);
  
  public ASI_HK_CRM_Visitation_Plan_Detail__c generateBasicVisitationPlanDetail(ASI_HK_CRM_Visitation_Plan__c visitPlan, ASI_CRM_AccountsAdditionalField__c acct, Date visitDate) {
    return new ASI_HK_CRM_Visitation_Plan_Detail__c(
      ASI_HK_CRM_Visitation_Plan__c = visitPlan.Id
      , ASI_CRM_MY_Customer__c = acct.Id
      , ASI_HK_CRM_Visit_Date__c = visitDate
      , RecordTypeID = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan_Detail__c.RecordTypeInfosByName.get('MY Visitation Plan Detail').RecordTypeId
    );
  }

  public ASI_HK_CRM_Visitation_Plan_Detail__c generateVisitationPlanDetail(ASI_HK_CRM_Visitation_Plan__c visitPlan, ASI_CRM_AccountsAdditionalField__c acct, Date visitDate) {
    return generateBasicVisitationPlanDetail(visitPlan, acct, visitDate);
  }

}