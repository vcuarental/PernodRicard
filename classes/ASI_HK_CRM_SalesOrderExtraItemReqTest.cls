@isTest
private class ASI_HK_CRM_SalesOrderExtraItemReqTest {

    static testMethod void test_basic() {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        //ASI_HK_CRM_TestUtils.initSOWSSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new ASI_HK_CRM_SalesOrderMock());
        
        ASI_HK_CRM_SalesOrderHoldCodeSchedule.schedule();
        
        Test.stopTest();
    }
    
    static testMethod void test_main() {
        EmailTemplate emExist = [select id, folderId from emailTemplate limit 1];
        Integer num = [select count() from emailTemplate where developerName='ASI_HK_CRM_SO_Has_Unavailable_Item'];
        if(num == 0){
            EmailTemplate em = new EmailTemplate(developerName='ASI_HK_CRM_SO_Has_Unavailable_Item',subject='subject',      
            TemplateType='text', Encoding='UTF-8', Body='Body',Name='Name', FolderId=emExist.folderId);
            insert em;
        }
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.initSOWSSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Order_Status_Name__c = ASI_HK_CRM_SalesOrderExtraItemRequest.STATUS_CHECKING_EXTRA_ITEMS;
        so.ASI_HK_CRM_SYS_Approver_3__c = UserInfo.getUserId();
        so.ASI_HK_CRM_Actual_Approve_User__c = UserInfo.getUserId();
        so.ASI_HK_CRM_Code__c = '111111';
        so.ASI_HK_CRM_Credit_Hold_Reason__c = 'H1';
        Test.startTest();
        update so;

        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesOrder testShowSalesOrder = ASI_HK_CRM_SalesOrderMock.sampleShowSalesOrder();
        testShowSalesOrder.header[0].detail[0].product.item.itemId = cmData.skuList[0].ASI_HK_CRM_External_Short_ID__c.intValue();
        ASI_HK_CRM_SalesOrderMock.expectedShowSalesOrder = testShowSalesOrder;
        
        ASI_HK_CRM_SalesOrderExtraItemRequest extraItemReq = new ASI_HK_CRM_SalesOrderExtraItemRequest();
        Database.QueryLocator soQueryLocator = extraItemReq.start(null);
        Database.QueryLocatorIterator soIterator = soQueryLocator.iterator();
        if (soIterator.hasNext()){
            so = (ASI_HK_CRM_Sales_Order__c)soIterator.next();
        }
        Test.setMock(WebServiceMock.class, new ASI_HK_CRM_SalesOrderMock());    
        //extraItemReq.execute(null, new List<sObject>{so});
        
        Test.stopTest();
    }
}