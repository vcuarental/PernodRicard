/*********************************************************************************
 * Name: ASI_CRM_VN_VisitDetailTimeCtrlTest
 * Description: Test class for ASI_CRM_VN_VisitDetailTimeCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 13/07/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_VN_VisitDetailTimeCtrlTest {
    
    @TestSetup
    public static void setupData() {
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        
        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;
        
        ASI_CRM_AccountsAdditionalField__c offTradeCustomer = ASI_CRM_VN_TestClassHelper.createOffTradeCustomer();
    	insert offTradeCustomer;
       
        insert ASI_CRM_VN_TestClassHelper.createKeyCustomerSubBrand(offTradeCustomer.Id, subBrand.Id);
        insert ASI_CRM_VN_TestClassHelper.createCompetitorCustomerSubBrand(offTradeCustomer.Id, subBrand.Id);
        
        ASI_HK_CRM_Visitation_Plan__c visitationPlan = ASI_CRM_VN_TestClassHelper.createVisitationPlan();
        visitationPlan.ASI_HK_CRM_Confirmed__c = true;
        insert visitationPlan;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail = ASI_CRM_VN_TestClassHelper.createVisitationPlanDetail(visitationPlan.Id, offTradeCustomer.Id);
		insert visitationPlanDetail;
    }
    
    public static testMethod void testCtrl() {
        ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail = [SELECT Id FROM ASI_HK_CRM_Visitation_Plan_Detail__c LIMIT 1];


        ApexPages.StandardController sc = new ApexPages.StandardController(visitationPlanDetail);
        ASI_CRM_VN_VisitDetailTimeCtrl visitDetailTimeCtrl = new ASI_CRM_VN_VisitDetailTimeCtrl(sc);
        visitDetailTimeCtrl.setTimeIn();
        visitDetailTimeCtrl.setTimeOut();
  	}
}