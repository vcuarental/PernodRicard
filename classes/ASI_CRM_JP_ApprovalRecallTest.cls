/**********************************************************************************
 * Name : ASI_CRM_JP_ApprovalRecallTest
 * Created : DC @04/14/2016 8:44 AM
 * Revision History:
 * 1. 04/14/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_JP_ApprovalRecallTest {
    
    private static ASI_CRM_Purchase_Contract__c contractInstance;
    
    @TestSetup
    static void createTestData() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ManagerId=UserInfo.getUserId(),
            TimeZoneSidKey='America/Los_Angeles', UserName='test0@laputa.com');
        insert u;
        
        ASI_HK_CRM_Running_Number__c runningNumber = new ASI_HK_CRM_Running_Number__c(
            ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No',
            ASI_HK_CRM_Running_Number__c = 1,
            ASI_HK_CRM_Format__c = 'Event-{YY}{000000}',
            ASI_HK_CRM_Fiscal_Year__c = 2016,
            ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7
        );
        insert runningNumber;

        Id contractRecTypeId = Schema.SObjectType.ASI_CRM_Purchase_Contract__c
                                     .getRecordTypeInfosByName()
                                     .get('JP SPTD Contract').getRecordTypeId();
        
        contractInstance = new ASI_CRM_Purchase_Contract__c(
            RecordTypeId = contractRecTypeId,
            Name = 'TestContract123',
            ASI_CRM_Status__c = 'Draft',
            ASI_CRM_Sys_Allow_Submit_Approval__c = true,
            OwnerId = u.Id,
            ASI_CRM_Start_Date__c = ASI_CRM_JP_TestClassHelper.createTestDate(),
            ASI_CRM_End_Date__c = ASI_CRM_JP_TestClassHelper.createTestDate().addMonths(1),
            ASI_CRM_Request_Type__c = 'New Customer Development'
        );
        insert contractInstance;

        System.debug('------ contractInstance ------ : ' + contractInstance);
    }

    static testMethod void testApprovalRecallPositive() {

        contractInstance = [SELECT Id FROM ASI_CRM_Purchase_Contract__c LIMIT 1];
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ManagerId=UserInfo.getUserId(),
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        insert u;
        
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(contractInstance.id);
        req1.setSubmitterId(u.Id);

        Approval.ProcessResult result = Approval.process(req1);

        ASI_CRM_JP_ApprovalRecall.recallApproval(contractInstance.Id);
    }

    static testMethod void testApprovalRecallNegative() {
        
        contractInstance = [SELECT Id FROM ASI_CRM_Purchase_Contract__c LIMIT 1];

        ASI_CRM_JP_ApprovalRecall.recallApproval(contractInstance.Id);

    }

    static testMethod void testApprovalRecallWithNullId() {
        
        contractInstance = new ASI_CRM_Purchase_Contract__c();

        ASI_CRM_JP_ApprovalRecall.recallApproval(contractInstance.Id);

    }
}