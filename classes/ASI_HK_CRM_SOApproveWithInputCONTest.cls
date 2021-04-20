@isTest
private class ASI_HK_CRM_SOApproveWithInputCONTest {
    static {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
    }
  

    static testMethod void test_main() {
        Test.startTest();
        
        //Prepare Acct and SO
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        
        
        List<Approval.ProcessSubmitRequest> approvalReqList = new List<Approval.ProcessSubmitRequest>();
        

        ApexPages.StandardController stdSetConroller = new ApexPages.StandardController(cmData.so);
        
        // Try to click button before record submitted
        PageReference testPage = Page.ASI_HK_CRM_SOApproveWithSSMCommentPage;
        testPage.getParameters().put('id',cmData.SO.id);
        //Map<String, String> pageParams = testPage.getParameters();
        //pageParams.put('id', cmData.SO.id);
        
        Test.setCurrentPageReference(testPage);
        ASI_HK_CRM_SOApproveWithInputCON testController = new ASI_HK_CRM_SOApproveWithInputCON(stdSetConroller);
        testController.comment='12345';
        testController.hasError = false;
        PageReference initRedirectPage = testController.doApprove();
        
        
         
        /*
        
        //update SO to Test H4/H7
        cmData.so.ASI_HK_CRM_Order_Status_Name__c='Hold Code Received';
        cmData.so.ASI_HK_CRM_Credit_Hold_Reason__c='H4';
        cmData.so.ASI_HK_CRM_SYS_Greater_Than_Min_Amount__c = true;
        
        
        cmData.so.ASI_HK_CRM_SYS_Approver_3__c= UserInfo.getUserId();
        cmData.so.ASI_HK_CRM_SYS_Approver_6__c= UserInfo.getUserId();
        
        update cmData.so;
        
        
        //submit for approval - SSC
        Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
        approvalReq.setObjectId(cmData.so.Id);
        approvalReq.setComments('Submitting request for approval.');
        Approval.ProcessResult result1 = Approval.process(approvalReq);
        List<Id> newWorkItemIds = result1.getNewWorkitemIds();
        
        
        //SSC approve
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        
        
        //retest after correct stage
        testPage = Page.ASI_HK_CRM_SalesOrderNewButtonPage;
        pageParams = testPage.getParameters();
        pageParams.put('id', cmData.SO.id);

        Test.setCurrentPageReference(testPage);
        testController = new ASI_HK_CRM_SOApproveWithInputCON(stdSetConroller);
        testController.comment='12345';
        initRedirectPage = testController.doApprove();

        */
        

        Test.stopTest();

        
        
    }
    
    static testMethod void test_SSC() {
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 1, 1);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 1, 1);
        
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_SYS_Approver_3__c = UserInfo.getUserId();
        so.ASI_HK_CRM_Order_Status_Name__c = 'Hold Code Received';
        so.ASI_HK_CRM_Credit_Hold_Reason__c = 'H1';
        update so;
        try{
            Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
            approvalReq.setObjectId(so.Id);
            Approval.process(approvalReq);
        }catch(exception e){
        }
        ApexPages.StandardController stdCon = new ApexPages.StandardController(so);
        
        Test.startTest();
        
        PageReference testPage = Page.ASI_HK_CRM_SOApproveWithSSCInputPage;
        Test.setCurrentPageReference(testPage);
        ASI_HK_CRM_SOApproveWithInputCON testCon = new ASI_HK_CRM_SOApproveWithInputCON(stdCon);
        testCon.comment='Test Comment';
        testCon.soHeader.ASI_HK_CRM_Payment_Amt_1__c = 1000;
        testCon.doApprove();
        
        Test.stopTest();
    }
    
    static testMethod void test_SSC1() {
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 1, 1);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 1, 1);
        
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_SYS_Approver_3__c = UserInfo.getUserId();
        so.ASI_HK_CRM_Order_Status_Name__c = 'SA Approved';
        so.ASI_HK_CRM_Credit_Hold_Reason__c = 'H1';
        update so;
        try{
            Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
            approvalReq.setObjectId(so.Id);
            Approval.process(approvalReq);
        }catch(exception e){
        }
        ApexPages.StandardController stdCon = new ApexPages.StandardController(so);
        
        Test.startTest();
        
        PageReference testPage = Page.ASI_HK_CRM_SOApproveWithSSCInputPage;
        Test.setCurrentPageReference(testPage);
        ASI_HK_CRM_SOApproveWithInputCON testCon = new ASI_HK_CRM_SOApproveWithInputCON(stdCon);
        testCon.comment='Test Comment';
        testCon.soHeader.ASI_HK_CRM_Payment_Amt_1__c = 1000;
        testCon.doApprove();
        
        Test.stopTest();
    }
    
    static testMethod void test_SSC2() {
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 1, 1);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 1, 1);
        
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_SYS_Approver_3__c = UserInfo.getUserId();
        so.ASI_HK_CRM_Order_Status_Name__c = 'Approved';
        so.ASI_HK_CRM_Credit_Hold_Reason__c = 'H1';
        update so;
        try{
            Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
            approvalReq.setObjectId(so.Id);
            Approval.process(approvalReq);
        }catch(exception e){
        }
        ApexPages.StandardController stdCon = new ApexPages.StandardController(so);
        
        Test.startTest();
        
        PageReference testPage = Page.ASI_HK_CRM_SOApproveWithSSCInputPage;
        Test.setCurrentPageReference(testPage);
        ASI_HK_CRM_SOApproveWithInputCON testCon = new ASI_HK_CRM_SOApproveWithInputCON(stdCon);
        testCon.comment='Test Comment';
        testCon.soHeader.ASI_HK_CRM_Payment_Amt_1__c = 1000;
        testCon.doApprove();
        
        Test.stopTest();
    }
}