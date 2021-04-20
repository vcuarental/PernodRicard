/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_BudgetSummaryControllerExt Class.
  @Author:      IPC
  @History:     AUG.4.2014 - Created
*/
@isTest (SeeAllData=true)
private with sharing class EUR_CRM_DE_TestBudgetSummaryConExt{
    private static EUR_CRM_Budget__c budget;
    
    static void dataSetup(){
        budget = new EUR_CRM_Budget__c();
        budget.EUR_CRM_Allocated_Budget__c = 1000.00;
        budget.EUR_CRM_Carry_Forward__c = 200.00;
        budget.EUR_CRM_Fiscal_Year__c = 'FY15';
        budget.OwnerId = UserInfo.getUserId();
        insert budget;
    }
     
    static testMethod void testBudget(){
     
         EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
          system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
             dataSetup();
        Test.startTest();
            PageReference rf = new Pagereference('/apex/EUR_CRM_DE_BudgetSummaryPage');
            rf.getParameters().put('id', budget.Id);
            Test.setCurrentPage(rf);
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(budget);
            
            EUR_CRM_DE_BudgetSummaryControllerExt ctrl = new EUR_CRM_DE_BudgetSummaryControllerExt(standardController);
            
            String currentFY = ctrl.currentFY;
        Test.stopTest();
        }
    }
}