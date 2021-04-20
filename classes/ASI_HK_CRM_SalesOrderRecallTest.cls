@isTest
public with sharing class ASI_HK_CRM_SalesOrderRecallTest {
    
    private static ASI_HK_CRM_TestUtils.CommonData cmData;
    
    static {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        
    }
    
    static testMethod void testSalesOrderRecall() {
        
        Test.startTest();

        
        cmData.so.ASI_HK_CRM_Order_Status_Name__c = 'Hold Code Received'; //changed by Leo@Elufa on 20160129, from status 'Draft'->'Received'
        cmData.so.ASI_HK_CRM_Order_Date__c = Date.today(); //added by Leo@Elufa on 20160129
        cmData.so.ASI_HK_CRM_SYS_Greater_Than_Min_Amount__c = true;
        cmData.so.ASI_HK_CRM_SYS_Approver_2__c = UserInfo.getUserId();
        update cmData.so;
        cmData.so.ASI_HK_CRM_Order_Status_Name__c = 'Submitted';
        update cmData.so;

        /*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(cmData.so.Id);
        Approval.ProcessResult result1 = Approval.process(req1); 
        List<Id> newWorkItemIds = result1.getNewWorkitemIds();*/
        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        //req2.setWorkitemId(newWorkItemIds.get(0));
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req2.setWorkitemId(cmData.so.Id);
        
        PageReference testPage = Page.ASI_HK_CRM_SalesOrderApprovalRecallPage;
        Map<String, String> pageParams = testPage.getParameters();
        Test.setCurrentPageReference(testPage);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(cmData.so);    
        ASI_HK_CRM_SalesOrderRecallController testController = new ASI_HK_CRM_SalesOrderRecallController(stdController);
        

        
        PageReference initRedirectPage = testController.doRecall();
    
        Test.stopTest();
    }
    
    
    
}