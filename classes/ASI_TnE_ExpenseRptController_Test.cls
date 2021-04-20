/*********************************************************************************
 * Name:ASI_TnE_ExpenseRptController_Test
 * Description: Test Class for ASI_TnE_ExpenseRptController
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 11/05/2015       Laputa: Hank            Created
 * 26/07/2016       Laputa: Hugo Cheung    	Updated. Add test method for TW record type
*********************************************************************************/
@isTest
private class ASI_TnE_ExpenseRptController_Test {
    //Expense Report PDF test3
    static testMethod void ASI_TnE_ExpenseRptController_Test3() {
        ASI_TnE_TestClassHelper.createRunningNumbers();
        ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_ID_Claim_Header');
        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_ID_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_ID_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_ID_Expense_Classification', category, accMap);
        ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_ID_Claim_Detail', cls);
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
    
    //Expense Report PDF test4
    static testMethod void ASI_TnE_ExpenseRptController_Test4() {
        ASI_TnE_TestClassHelper.createRunningNumbers();
        ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_PH_Claim_Header');
        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_PH_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_PH_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_PH_Expense_Classification', category, accMap);
        ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_PH_Claim_Detail', cls);
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
        header.ASI_TnE_Status__c = 'Approved';
        update header;
    }
    
    static testMethod void ASI_TnE_ExpenseRptController_Test5() {
        ASI_TnE_TestClassHelper.createRunningNumbers();
        ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_TW_Claim_Header');
        ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_TW_Account_Mapping');
        ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_TW_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_TW_Expense_Classification', category, accMap);
        ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail', cls);
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
        header.ASI_TnE_Status__c = 'Approved';
        update header;
    }
}