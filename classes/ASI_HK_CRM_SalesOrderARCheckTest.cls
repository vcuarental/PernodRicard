@isTest
public with sharing class ASI_HK_CRM_SalesOrderARCheckTest {

    private static ASI_HK_CRM_TestUtils.CommonData cmData;
    
    static {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.initARWSSettings();  
        cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
    }


    static testMethod void testAR(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new ASI_HK_CRM_ARMock());
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(cmData.so);
        
        PageReference testPage = Page.ASI_HK_CRM_SalesOrderARCheckPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', so.id);
        Test.setCurrentPageReference(testPage);
        ASI_HK_CRM_SalesOrderARCheckController testController = new ASI_HK_CRM_SalesOrderARCheckController(stdController);
        
        PageReference initRedirectPage = testController.requestARInfo();
        
        Test.stopTest();
    } 

}