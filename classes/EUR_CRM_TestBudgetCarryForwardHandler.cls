/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_BudgetCarryForwardHandler Class.
  @Author:      IPC
  @History:     July 2014 - Created
*/
@isTest

private class EUR_CRM_TestBudgetCarryForwardHandler{
    private static String PREV_FY_STR = 'FY14';
    private static String FY_STR = 'FY15';
    private static String EXTERNAL_ID_PREFIX = 'TEST_';
    private static Decimal ALLOCATED_BUDGET = 10000;
    private static Decimal CARRY_FWD = 0;
    
    private static EUR_CRM_Budget__c prevBudget;
    private static EUR_CRM_Budget_Transaction__c prevBudgetTransaction;
    private static EUR_CRM_Budget_Transaction__c currentBudgetTransaction;
    private static EUR_CRM_Budget__c currentBudget;
    
    public static void dataInsert1(){
        prevBudget = EUR_CRM_DE_TestClassUtilityHelper.createBudget(EUR_CRM_DE_TestClassUtilityHelper.DE_BUDGET_RECORD_TYPE,
                                                UserInfo.getUserId(), 
                                                PREV_FY_STR, EXTERNAL_ID_PREFIX+PREV_FY_STR,
                                                ALLOCATED_BUDGET, CARRY_FWD);
        insert prevBudget;
        EUR_CRM_Budget__c prevBudgetTransfertarget = EUR_CRM_DE_TestClassUtilityHelper.createBudget(EUR_CRM_DE_TestClassUtilityHelper.DE_BUDGET_RECORD_TYPE,
                                                UserInfo.getUserId(), 
                                                PREV_FY_STR, EXTERNAL_ID_PREFIX+PREV_FY_STR,
                                                ALLOCATED_BUDGET, CARRY_FWD);                                       
        insert prevBudgetTransfertarget;
        system.assertNotEquals(prevBudget, null);
        
        EUR_CRM_Budget_Transaction__c prevBudgetTransactionFirst = EUR_CRM_DE_TestClassUtilityHelper.createDebitTransactions(EUR_CRM_DE_TestClassUtilityHelper.DE_TRANSACTION_RECORD_TYPE, 
                                                                                prevBudget.Id,
                                                                                1, ALLOCATED_BUDGET+5000,
                                                                                'Transfer')[0];
        prevBudgetTransactionFirst.EUR_CRM_Transfer_From_Budget_Header__c =     prevBudget.Id;                                                                  
        insert prevBudgetTransactionFirst;
        
        prevBudgetTransaction = EUR_CRM_DE_TestClassUtilityHelper.createDebitTransactions(EUR_CRM_DE_TestClassUtilityHelper.DE_TRANSACTION_RECORD_TYPE, 
                                                                                prevBudgetTransfertarget.Id,
                                                                                1, ALLOCATED_BUDGET+5000,
                                                                                'Transfer')[0];
        prevBudgetTransaction.EUR_CRM_Transfer_From_Budget_Header__c =  prevBudgetTransfertarget.Id;                                                                    
        insert prevBudgetTransaction;
        system.assertNotEquals(prevBudgetTransaction, null);
    }
    
    public static void dataInsert2(){
        prevBudget = EUR_CRM_DE_TestClassUtilityHelper.createBudget(EUR_CRM_DE_TestClassUtilityHelper.DE_BUDGET_RECORD_TYPE,
                                                UserInfo.getUserId(), 
                                                '', EXTERNAL_ID_PREFIX+'',
                                                ALLOCATED_BUDGET, CARRY_FWD);
        insert prevBudget;
        
        prevBudgetTransaction = EUR_CRM_DE_TestClassUtilityHelper.createDebitTransactions(EUR_CRM_DE_TestClassUtilityHelper.DE_TRANSACTION_RECORD_TYPE, 
                                                                                prevBudget.Id,
                                                                                1, ALLOCATED_BUDGET+5000,
                                                                                'Transfer')[0];
        prevBudgetTransaction.EUR_CRM_Transfer_From_Budget_Header__c =  prevBudget.Id;                                                                  
        insert prevBudgetTransaction;
        system.assertNotEquals(prevBudgetTransaction, null);
    }
    
    
    static testMethod void testMethod1(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            test.StartTest();
                
            dataInsert1();
            dataInsert2();
            //Create Budget
            currentBudget = EUR_CRM_DE_TestClassUtilityHelper.createBudget(EUR_CRM_DE_TestClassUtilityHelper.DE_BUDGET_RECORD_TYPE,
                                                UserInfo.getUserId(), 
                                                FY_STR, EXTERNAL_ID_PREFIX+FY_STR,
                                                ALLOCATED_BUDGET, CARRY_FWD);
            insert currentBudget;
            currentBudgetTransaction = EUR_CRM_DE_TestClassUtilityHelper.createCreditTransactions(EUR_CRM_DE_TestClassUtilityHelper.DE_TRANSACTION_RECORD_TYPE, 
                                                                                currentBudget.Id,
                                                                                1, ALLOCATED_BUDGET+5000,
                                                                                'Initial Load')[0];
            insert currentBudgetTransaction ;
            system.assertNotEquals(currentBudget, null);

            EUR_CRM_Budget_Transaction__c x = EUR_CRM_DE_TestClassUtilityHelper.createCreditTransactions(EUR_CRM_DE_TestClassUtilityHelper.DE_TRANSACTION_RECORD_TYPE, 
                                                                                currentBudget.Id,
                                                                                1, 1,
                                                                                'Initial Load')[0];
            x.EUR_CRM_Transfer_From_Budget_Header__c =  prevBudget.Id;
            insert x;

            test.stopTest();
        }
    }
    
    static testMethod void testMethod2(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            test.StartTest();
            
            //Create Budget
            currentBudget = EUR_CRM_DE_TestClassUtilityHelper.createBudget(EUR_CRM_DE_TestClassUtilityHelper.DE_BUDGET_RECORD_TYPE,
                                                UserInfo.getUserId(), 
                                                FY_STR, EXTERNAL_ID_PREFIX+FY_STR,
                                                ALLOCATED_BUDGET, CARRY_FWD);
            insert currentBudget;
            system.assertNotEquals(currentBudget, null);

            test.stopTest();
        }
    }

}