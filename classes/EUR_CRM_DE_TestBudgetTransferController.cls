/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_BudgetTransferController Class.
  @Author:      IPC
  @History:     AUG.4.2014 - Created
*/
@isTest
private with sharing class EUR_CRM_DE_TestBudgetTransferController{
    private static EUR_CRM_Budget__c budget;
    private static EUR_CRM_Budget__c budgetSub;
    private static EUR_CRM_Budget__c budgetSub2;
    private static List<EUR_CRM_Budget_Transaction__c> transactCredit;
    private static List<EUR_CRM_Budget_Transaction__c> transactDebit;
    private static List<EUR_CRM_Budget_Transaction__c> transactCreditSub;
    
    private static User user;
    private static User user2;
    private static User user3;
    
    static void dataSetup(){
        user = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_Regional_Sales_Manager_On_Trade_West', 'testuser123902@test.com', 'testuser123902@test.com', 'test898441');
        system.assertNotEquals(user, null);
        
        user2 = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_GSL_West', 'testuser123902111@test.com', 'testuser123902111@test.com', 'test898441111');
        system.assertNotEquals(user2, null);
        
        user3 = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_GSL_West', 'testuser1239021113@test.com', 'testuser1239021113@test.com', 'test8984411113');
        system.assertNotEquals(user3, null);
        
        budget = EUR_CRM_DE_TestClassUtilityHelper.createBudget('DE On Trade WKZ', user.Id, 'FY15', 'FY15EXT111', 50.00, 0.00);
        budgetSub = EUR_CRM_DE_TestClassUtilityHelper.createBudget('DE On Trade WKZ', user2.Id, 'FY15', 'FY15EXT111',50.00, 0.00);
        budgetSub2 = EUR_CRM_DE_TestClassUtilityHelper.createBudget('DE On Trade WKZ', user3.Id, 'FY15', 'FY15EXT111',30.00, 0.00);
    }
    
    static testMethod void testBudget(){
        dataSetup();
        Test.startTest();
            system.runAs(user3){
                insert budgetSub2;
            }
            
            system.runAs(user2){
                insert budgetSub;
            }
            
            system.runAs(user){
                insert budget;
                
                transactCredit = EUR_CRM_DE_TestClassUtilityHelper.createCreditTransactions('DE On Trade WKZ', budget.Id, 3, 10.00,'Initial Load');
                insert transactCredit;
                transactDebit = EUR_CRM_DE_TestClassUtilityHelper.createDebitTransactions('DE On Trade WKZ', budget.Id, 1, 10.00,'Transfer');
                insert transactDebit;
                
                transactCreditSub = EUR_CRM_DE_TestClassUtilityHelper.createCreditTransactions('DE On Trade WKZ', budgetSub.Id, 1, 20.00,'Initial Load');
                transactCreditSub[0].EUR_CRM_Transfer_From__c = user2.Id;
                insert transactCreditSub;
            }
            system.assertEquals(budget.ownerId, user.Id);
            //system.assertEquals(transactCreditSub[0].EUR_CRM_Transfer_From__c, budgetSub.ownerId);
            
            Id roleId = [select UserRoleId from User where Id = :user.Id].UserRoleId;
            system.assertEquals(roleId, user.UserRoleId);
            
            PageReference rf = new Pagereference('/apex/EUR_CRM_DE_BudgetTransferPage');
            rf.getParameters().put('id', budget.Id);
            Test.setCurrentPage(rf);
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(budget);
            
            EUR_CRM_DE_BudgetTransferController ctrl = new EUR_CRM_DE_BudgetTransferController(standardController);
            EUR_CRM_RoleUtils roles = new EUR_CRM_RoleUtils();
            
            system.assertNotEquals(transactCreditSub[0], null);
            
            Double runningBalanceTo = ctrl.runningBalanceTo;
            
            ctrl.budgetTransactionFrom.EUR_CRM_Transfer_From__c = user2.Id;
            ctrl.budgetTransactionFrom.EUR_CRM_Transfer_To__c = user3.Id;
            ctrl.budgetTransactionFrom.EUR_CRM_Amount__c = 30.00;
            
            ctrl.budgetFromOnChange();
            ctrl.budgetToOnChange();
            
            List<SelectOption> transfereeOptions = ctrl.transfereeOptions;
            List<SelectOption> transferorOptions = ctrl.transferorOptions;
            
            ctrl.retrieveUserOptions();
            ctrl.quickSave();
            ctrl.save();
        Test.stopTest();
    }
    
    static testMethod void testBudget2(){
        dataSetup();
        Test.startTest();
            system.runAs(user){
                insert budget;
            }
            
            PageReference rf = new Pagereference('/apex/EUR_CRM_DE_BudgetTransferPage');
            rf.getParameters().put('id', budget.Id);
            Test.setCurrentPage(rf);
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(budget);
            
            EUR_CRM_DE_BudgetTransferController ctrl = new EUR_CRM_DE_BudgetTransferController(standardController);
            EUR_CRM_RoleUtils roles = new EUR_CRM_RoleUtils();
            
            ctrl.save();
        Test.stopTest();
    }
}