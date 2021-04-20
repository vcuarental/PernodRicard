/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_BudgetUtil Class.
  @Author:      IPC
  @History:     July 2014 - Created
*/
@isTest

private with sharing class EUR_CRM_TestBudgetUtil{
    static testMethod void testMethod1(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.salesRepUser){
            test.StartTest();
            
            Organization  org = EUR_CRM_BudgetUtil.retrieveFiscalYearOrg();
            system.assertNotEquals(org, null);
            
            Date rDate = EUR_CRM_BudgetUtil.retrieveFiscalYearStart();
            system.assertNotEquals(rDate, null);
            
            Boolean rBoolean = EUR_CRM_BudgetUtil.isFYCurrentYear();
            system.assertNotEquals(rBoolean, null);
            
            test.StopTest();
        }
    }
}