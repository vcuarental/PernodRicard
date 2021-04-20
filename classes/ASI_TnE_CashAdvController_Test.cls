/**********************************************************************************
 * Name : ASI_TnE_CashAdvController_Test
 * Created : DC @01/04/2016 3:17 PM
 * Revision History:
 * 1. 01/04/2016 - [DC 1.0] Created (Test class for ASI_TnE_CashAdvController)
 **********************************************************************************/
@isTest
public class ASI_TnE_CashAdvController_Test {
    private static testMethod void testSubmitForApproval() {
        // Create Running Numbers for Claim Header
        ASI_TnE_TW_TestClassHelper.createRunningNumbers();
        
        // Create Claim Header Instance
        ASI_TnE_ClaimHeader__c headerInstance =
            ASI_TnE_TW_TestClassHelper.createTestClaimHeader('123456', 'ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
        
        // Create Cash Advance Pre-Approval
        ASI_TnE_Cash_Advance_Pre_Approval__c cashAdvanceInstance =
            new ASI_TnE_Cash_Advance_Pre_Approval__c(
                RecordTypeId = 
                    Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_SG_Cash_Advance_Pre_approval'),
                ASI_TnE_Status__c = 'Draft',
                ASI_TnE_Sys_Allow_Submit_Approval__c = true
            );
        insert cashAdvanceInstance;
        
        // Submit process for approval
        Test.startTest();
            PageReference currentPage = Page.ASI_SubmitApprovalPage;
            currentPage.getParameters().put('id',cashAdvanceInstance.Id);
            Test.setCurrentPage(currentPage);
            ASI_SubmitApprovalController submitController = new ASI_SubmitApprovalController();
            submitController.submit();
        Test.stopTest();
    }
    
    private static testMethod void testSubmitForApproval1() {
        // Create Running Numbers for Claim Header
        ASI_TnE_TW_TestClassHelper.createRunningNumbers();
        User managerUser = ASI_TnE_TestClassHelper.createUser();
        User normalUser = ASI_TnE_TestClassHelper.newUser('NormalUser');
        normalUser.managerid = managerUser.id;
        insert normalUser;
        // Create Claim Header Instance
        ASI_TnE_ClaimHeader__c headerInstance =
            ASI_TnE_TW_TestClassHelper.createTestClaimHeader('123456', 'ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header');
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'user', Email='standarduser123@foo.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@foo.com');
        Id userId;
        System.runAs(u) {
            userId = UserInfo.getUserId();
            System.debug('------ userId ------ : ' + userId);
        }

        // Create Cash Advance Pre-Approval
        ASI_TnE_Cash_Advance_Pre_Approval__c cashAdvanceInstance =
            new ASI_TnE_Cash_Advance_Pre_Approval__c(
                RecordTypeId = 
                    Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__cASI_TnE_SG_Cash_Advance_Pre_approval'),
                ASI_TnE_Status__c = 'Draft',
                ASI_TnE_Sys_Allow_Submit_Approval__c = true,
                ASI_TnE_Requested_Employee__c = normalUser.Id,
                ASI_TnE_Sys_Approver_1__c = userId
            );
        insert cashAdvanceInstance;
        
        // Submit process for approval
        //Test.startTest();
            ASI_TnE_CashAdvController controllerInstance = new ASI_TnE_CashAdvController();
            controllerInstance.setCurrentHeaderId(cashAdvanceInstance.Id);
            controllerInstance.currentHeaderId = cashAdvanceInstance.Id;
            controllerInstance.header = cashAdvanceInstance;
            controllerInstance.getHeader();
            Approval.ProcessSubmitRequest req1 = 
                new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(controllerInstance.currentHeaderId);
            req1.setSubmitterId(UserInfo.getUserId());
        
            // Submit the approval request for the account 
    
            Approval.ProcessResult result = Approval.process(req1);
            System.debug('------ result ------ : ' + result);
       Test.startTest();
           controllerInstance.approvalDetails = new List<ASI_TnE_CashAdvController.ApprovalDetail>();
           List<ProcessInstanceHistory> lstHistory = [Select Id, (Select Id, StepStatus, Comments, CreatedDate From ProcessSteps) 
                                                      From ASI_TnE_Cash_Advance_Pre_Approval__c WHERE Id = :cashAdvanceInstance.Id][0].ProcessSteps;
           ASI_TnE_CashAdvController.ApprovalDetail detailInstance = new ASI_TnE_CashAdvController.ApprovalDetail();
           detailInstance.history = NULL;
           detailInstance.title  = 'Test Title!';
           controllerInstance.approvalDetails.add(detailInstance);
           controllerInstance.getNumOfApprovals();
           controllerInstance.numOfApprovals = 1;
            // Verify the result 
    
            // System.assert(result.isSuccess());
        Test.stopTest();
    }
}