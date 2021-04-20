@isTest
private class ASI_TnE_CreateCashAdvTnE_Test {

    private static TestMethod void testExecuteTriggerAction() {
        
        // Create Running Numbers
        ASI_TnE_TW_TestClassHelper.createRunningNumbers();
        User managerUser = ASI_TnE_TestClassHelper.createUser();
        User normalUser = ASI_TnE_TestClassHelper.newUser('NormalUser');
        normalUser.managerid = managerUser.id;
        insert normalUser;
        // Create Cash Advance Pre-Approval Data
        ASI_TnE_Cash_Advance_Pre_Approval__c cashAdvanceInstance =
            new ASI_TnE_Cash_Advance_Pre_Approval__c(
                RecordTypeId = 
                    Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_TH_Cash_Advance_Pre_approval'),
                ASI_TnE_Status__c = 'Draft',
                ASI_TnE_Requested_Employee__c = normalUser.Id,
                ASI_TnE_Sys_Allow_Submit_Approval__c = true
            );
        insert cashAdvanceInstance;

        cashAdvanceInstance.ASI_TnE_Status__c = 'Approved';
        update cashAdvanceInstance;
    }  
}