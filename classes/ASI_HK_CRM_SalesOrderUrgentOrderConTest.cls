@isTest
private class ASI_HK_CRM_SalesOrderUrgentOrderConTest {
    
    private static ASI_HK_CRM_TestUtils.CommonData cmData;

    static {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
    }
    
    static testMethod void test_SalesOrderUrgentOrderCon() {
        
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        //so.ASI_HK_CRM_Next_SO_Approver__c = UserInfo.getUserId(); //added by Leo@Elufa 20160129 //edited by Leo, 20160303
        //update so; //added by Leo@Elufa 20160129 //edited by Leo, 20160303
        ApexPages.StandardController stdConroller = new ApexPages.StandardController(so);
        Test.startTest();
        PageReference testPage = Page.ASI_HK_CRM_SalesOrderConfirmUrgentPage;
        Map<String, String> pageParams = testPage.getParameters();        
        ASI_HK_CRM_SalesOrderConfirmUrgentCon testController = new ASI_HK_CRM_SalesOrderConfirmUrgentCon(stdConroller);
        testController.save();
        
        Test.stopTest();
    }
}