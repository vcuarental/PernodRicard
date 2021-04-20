/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_BudgetManagementPageController Class.
  @Author:      IPC
  @History:     AUG.05.2014 - Created
*/
@isTest
public class EUR_CRM_TestBudgetManagementPageCtrl{
   //
    private static EUR_CRM_Budget__c budget;
    private static EUR_CRM_Budget__c subBudget;
    private static User user;
    private static User user2;
    
    static void dataSetup(){
        user = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_Regional_Sales_Manager_On_Trade_West', 'testuser123902@test.com', 'testuser123902@test.com', 'test898441');
        system.assertNotEquals(user, null);
        
        user2 = EUR_CRM_DE_TestClassUtilityHelper.createUser('System Administrator','EUR_DE_GSL_West', 'testuser123902111@test.com', 'testuser123902111@test.com', 'test898441111');
        system.assertNotEquals(user, null);
        
        budget = EUR_CRM_ZA_TestClassHelper.createBudget(1)[0];
        budget.EUR_CRM_Allocated_Budget__c = 2000.00;
        budget.EUR_CRM_Carry_Forward__c = 0.00;
        budget.EUR_CRM_Fiscal_Year__c = 'FY15';
        budget.ownerId = user.Id;
        
        subBudget = EUR_CRM_ZA_TestClassHelper.createBudget(1)[0];
        subBudget.EUR_CRM_Allocated_Budget__c = 1000.00;
        subBudget.EUR_CRM_Carry_Forward__c = 0.00;
        subBudget.EUR_CRM_Fiscal_Year__c = 'FY15';
        subBudget.ownerId = user2.Id;
    }
    static testMethod void testBudgetCredit(){
        dataSetup();
        Test.startTest();
            system.runAs(user){
                insert budget;
                insert subBudget;
            system.assertEquals(budget.ownerId, user.Id);
            
            Id roleId = [select UserRoleId from User where Id = :user.Id].UserRoleId;
            system.assertEquals(roleId, user.UserRoleId);
            
            PageReference rf = new Pagereference('/apex/EUR_CRM_BudgetManagementPage');
            rf.getParameters().put('id', budget.Id);
            Test.setCurrentPage(rf);
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(budget);
            
            EUR_CRM_BudgetManagementPageController ctrl = new EUR_CRM_BudgetManagementPageController(standardController);
            EUR_CRM_RoleUtils roles = new EUR_CRM_RoleUtils();
            system.assert(ctrl.manageItemList.size() == 1);
            for(EUR_CRM_BudgetManagementPageController.ManageItem manageItem: ctrl.manageItemList){
                manageItem.budgetTransactions.put('Credit','1000');
            }
            
            system.assert(ctrl.save() !=null );
            ctrl.removeManageItem();
            system.assert(ctrl.manageItemList.size() == 0);
            EUR_CRM_Budget__c newBudget = [select EUR_CRM_Current_Balance__c, id from EUR_CRM_Budget__c where id =: budget.id];
            system.debug(newBudget.EUR_CRM_Current_Balance__c  );
            //system.assert(newBudget.EUR_CRM_Current_Balance__c == 3000);
            ctrl.goToPage();
            }
        Test.stopTest();
    }
     static testMethod void testBudgetDebit(){
        dataSetup();
        Test.startTest();
            system.runAs(user){
                insert budget;
                insert subBudget;
            system.assertEquals(budget.ownerId, user.Id);
            
            Id roleId = [select UserRoleId from User where Id = :user.Id].UserRoleId;
            system.assertEquals(roleId, user.UserRoleId);
            
            PageReference rf = new Pagereference('/apex/EUR_CRM_BudgetManagementPage');
            rf.getParameters().put('id', budget.Id);
            Test.setCurrentPage(rf);
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(budget);
            
            EUR_CRM_BudgetManagementPageController ctrl = new EUR_CRM_BudgetManagementPageController(standardController);
            EUR_CRM_RoleUtils roles = new EUR_CRM_RoleUtils();
            system.assert(ctrl.manageItemList.size() == 1);
            for(EUR_CRM_BudgetManagementPageController.ManageItem manageItem: ctrl.manageItemList){
                manageItem.budgetTransactions.put('Debit','1000');
            }
            system.assert(ctrl.save() !=null ); 
            
            }
        Test.stopTest();
    }
}