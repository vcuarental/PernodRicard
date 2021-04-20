@isTest
private class ASI_HK_CRM_SalesOrderHoldCodeRequestTest {

	static testMethod void test_basic() {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.initSOWSSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Order_Status_Name__c = ASI_HK_CRM_SalesOrderHoldCodeRequest.STATUS_WAIT_CREDIT_HOLD;
        update so;
        
		Test.startTest();
        Test.setMock(WebServiceMock.class, new ASI_HK_CRM_SalesOrderMock());
        
        ASI_HK_CRM_SalesOrderHoldCodeSchedule.schedule();
        
        Test.stopTest();
	}
	
	static testMethod void test_main() {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.initSOWSSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        update so;
        
		Test.startTest();
        Test.setMock(WebServiceMock.class, new ASI_HK_CRM_SalesOrderMock());
        
        ASI_HK_CRM_SalesOrderHoldCodeRequest holdCodeReq = new ASI_HK_CRM_SalesOrderHoldCodeRequest();
        holdCodeReq.execute(null, new List<sObject>{so});
        
        Test.stopTest();
	}
}