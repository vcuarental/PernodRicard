/*********************************************************************************
 * Name:ASI_TnE_ExpenseRptController_Test2
 * Description: Test Class for ASI_TnE_ExpenseRptController
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 11/05/2015       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_TnE_ExpenseRptController_Test2 {
    //Expense Report PDF test
    static testMethod void ASI_TnE_ExpenseRptController_Test() {
        User u = ASI_TnE_TestClassHelper.newUser('testApprover');
        u.CompanyName = 'test';
        u.Department = 'test';
        insert u;
        
        system.runAs(u){
            ASI_TnE_TestClassHelper.createRouteType(u,1);
            ASI_TnE_TestClassHelper.createRunningNumbers();
            ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
            ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
            ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
            ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
            ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail', cls);
            test.startTest();
            PageReference pageRef = Page.ASI_TnE_ExpenseRptPage;
            pageRef.getParameters().put('Id', header.Id);
            Test.setCurrentPage(pageRef);
            ASI_TnE_ExpenseRptController controller = new ASI_TnE_ExpenseRptController();
            controller.setcurrentHeaderId(header.Id);
            controller.getHeader();
            controller.getcurrentHeaderId();
            controller.getCurrencyStr();
            controller.getAccMapDetails();
            controller.getapprovalDetails();
            controller.getIsOverThreeMth();
            controller.getClaimDetails();
            controller.getBudget();
            controller.getNumOfDetails();
            test.stopTest();
        }
    }
    
    //Expense Report PDF test2
    static testMethod void ASI_TnE_ExpenseRptController_Test2() {
        User u = ASI_TnE_TestClassHelper.newUser('testApprover');
        insert u;
        
        system.runAs(u){
            ASI_TnE_TestClassHelper.createRouteType(u,2);
            ASI_TnE_TestClassHelper.createRunningNumbers();
            ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_MY_Claim_Header');
            ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_MY_Account_Mapping');
            ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_MY_Expense_Category');
            ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_MY_Expense_Classification', category, accMap);
            ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_MY_Claim_Detail', cls);
            test.startTest();
            PageReference pageRef = Page.ASI_TnE_ExpenseRptPage;
            pageRef.getParameters().put('Id', header.Id);
            Test.setCurrentPage(pageRef);
            ASI_TnE_ExpenseRptController controller = new ASI_TnE_ExpenseRptController();
            controller.setcurrentHeaderId(header.Id);
            controller.getHeader();
            controller.getcurrentHeaderId();
            controller.getCurrencyStr();
            controller.getAccMapDetails();
            controller.getapprovalDetails();
            controller.getIsOverThreeMth();
            controller.getClaimDetails();
            controller.getBudget();
            controller.getNumOfDetails();
            test.stopTest();
        }
    }
}