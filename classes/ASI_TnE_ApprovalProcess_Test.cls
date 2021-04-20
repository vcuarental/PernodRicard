/*********************************************************************************
 * Name:ASI_TnE_ApprovalProcess_Test
 * Description: Test Class for Approval Process
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 11/05/2015       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_TnE_ApprovalProcess_Test{
    //For Approval Process
    static testMethod void ASI_TnE_ApprovalProcess_Test() {
        User u = ASI_TnE_TestClassHelper.newUser('testApprover');
        u.CompanyName = 'test';
        u.Department = 'test';
        insert u;
        
        system.runAs(u){
            ASI_TnE_TestClassHelper.createRunningNumbers();
            ASI_TnE_TestClassHelper.createRouteType(u,1);
            ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
            ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail');
            detail.ASI_TnE_Tax_Inclusive__c = false;
            update detail;
        }
    }
    
    static testMethod void ASI_TnE_ApprovalProcess_Test2() {
        User u = ASI_TnE_TestClassHelper.newUser('testApprover');
        insert u;
        
        system.runAs(u){
            ASI_TnE_TestClassHelper.createRunningNumbers();
            ASI_TnE_TestClassHelper.createRouteType(u,2);
            ASI_TnE_Account_Mapping__c accMap = ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping');
            ASI_JP_TnE_Expense_Category__c category = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category');
            ASI_JP_TnE_Expense_Classification__c cls = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification', category, accMap);
            
          cls.ASI_TnE_Approver__c = cls.ASI_TnE_Notification_Email__c;
          cls.ASI_TnE_Approver_2__c = cls.ASI_TnE_Notification_Email_2__c;
          cls.ASI_TnE_Approver_3__c = cls.ASI_TnE_Notification_Email_3__c;
          cls.ASI_TnE_Approver_4__c = cls.ASI_TnE_Notification_Email_4__c;
            update cls;
        
            ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
            ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail', cls);
            header.ASI_TnE_Payee_Employee__c = u.Id;
            update header;
        }
    }
    
    static testMethod void ASI_TnE_ApprovalProcess_Test3() {
        User u = ASI_TnE_TestClassHelper.newUser('testApprover');
        insert u;
        
        system.runAs(u){
          ASI_TnE_TestClassHelper.createTaxDateMapping();
            ASI_TnE_TestClassHelper.createRunningNumbers();
            ASI_TnE_TestClassHelper.createRouteType(u,2);
            ASI_TnE_ClaimHeader__c header = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header');
            ASI_TnE_ClaimDetail__c detail = ASI_TnE_TestClassHelper.createClaimDetail(header.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail');
            test.startTest();
            header.ASI_TnE_Payee_Employee__c = u.Id;
            detail.ASI_TnE_Receipt_Amount__c = 200;
            update header;
            update detail;
            test.stopTest();
        }
    }
}