@isTest
private class ASI_HK_CRM_SO_ExecuteTest {
	
	static testMethod void test_SO_Execute_button() {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.initSOWSSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        /*ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Order_Status_Name__c = ASI_HK_CRM_SalesOrderHoldCodeRequest.STATUS_WAIT_CREDIT_HOLD;
        update so;*/
        
		Test.startTest();
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Order_Status_Name__c = ASI_HK_CRM_SalesOrderHoldCodeRequest.STATUS_WAIT_CREDIT_HOLD;
        update so;
        Test.setMock(WebServiceMock.class, new ASI_HK_CRM_SalesOrderMock());
        
        ApexPages.StandardController stdConroller = new ApexPages.StandardController(so);
        PageReference testPage = Page.ASI_HK_CRM_Execute;
        ASI_HK_CRM_SO_ExecuteGetHoldCode ase = new ASI_HK_CRM_SO_ExecuteGetHoldCode(stdConroller);
        PageReference testPage2 = ase.executeBatchHoldCode();
        Test.stopTest();
	}

}