/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_Contract Triggers.
  @Author:      IPC
  @History:     July 2014 - Created
*/
@isTest

private with sharing class EUR_CRM_DE_TestContract_Triggers{
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    
    private static String EXTERNAL_ID_PREFIX = 'TEST_';
    private static Decimal ALLOCATED_BUDGET = 10000;
    private static Decimal CARRY_FWD = 0;

    private static EUR_CRM_Budget__c currentBudget;

    private static String getCurrentFY(){
        Date fy = EUR_CRM_BudgetUtil.retrieveFiscalYearStart();
        return 'FY' + String.valueOf(fy.year()).substring(2);
    }
    
    public static void dataInsert1(){
        //Create account
        EUR_CRM_DE_TestClassUtilityHelper.initData();
        accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;
        system.assertNotEquals(accountEU, null);

    }
    
    
    static testMethod void testMethod1(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        
        system.runAs(new User(Id = EUR_CRM_DE_TestClassUtilityHelper.regionalUser.Id)){
            
            test.StartTest();
            dataInsert1();
            contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
            insert contract;
            
            String currentFY = getCurrentFY();
            currentBudget = EUR_CRM_DE_TestClassUtilityHelper.createBudget(EUR_CRM_DE_TestClassUtilityHelper.DE_BUDGET_RECORD_TYPE,
                                                UserInfo.getUserId(), 
                                                currentFY, EXTERNAL_ID_PREFIX+currentFY,
                                                ALLOCATED_BUDGET, CARRY_FWD);
            insert currentBudget;
            system.assertNotEquals(currentBudget, null);
            test.StopTest();

            contract.EUR_CRM_Start_Date__c = contract.EUR_CRM_Start_Date__c.addDays(1);
            update contract;
        }
    }
}