@isTest
private class ASI_CTY_CN_WS_SORItem_TriggerClassTest {
	@testSetup
    private static void createTestData() {
        User admin = ASI_CTY_CN_WS_TestDataFactory.generateAdminUser('testAdmin@wholesaler.com');
        System.debug(LoggingLevel.INFO, '*** admin.Id: ' + admin.Id);
        System.runAs(admin) {
            Test.startTest();
            System.debug(LoggingLevel.INFO, '*** current user: ' + UserInfo.getUserId());
            ASI_CRM_AccountsAdditionalField__c customer = ASI_CTY_CN_WS_TestDataFactory.generateWSUser('testWS@wholesaler.com');
            
            ASI_MFM_Item_Group__c itemGroup = ASI_CTY_CN_WS_TestDataFactory.generateItemGroup(true, 'TestItemGroup');
            ASI_MFM_Item_Group__c itemGroup2 = ASI_CTY_CN_WS_TestDataFactory.generateItemGroup(true, 'TestItemGroup2');
            itemGroup2.ASI_CTY_CN_WS_Is_Especial_For_WS__c = true;
            update itemGroup2;


            ASI_CRM_Order_Form__c orderForm = ASI_CTY_CN_WS_TestDataFactory.generateOrderForm(true);
            ASI_CRM_Order_Form_Customer_Relationship__c orderFormRel = ASI_CTY_CN_WS_TestDataFactory.generateOrderFormRel(true, orderForm.Id, customer.Id);
            ASI_CRM_Order_Form_Detail__c orderFormDetail = ASI_CTY_CN_WS_TestDataFactory.generateOrderFormDetail(true, orderForm.Id, itemGroup.Id);

            // ASI_KOR_Sales_Order_Request__c salesOrder = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrder(true, customer.Id);
            // salesOrder.ASI_KOR_Order_Status__c = 'Submitted';
            // update salesOrder;
            
            Test.stopTest();

            ASI_CRM_CN_CustomSetting__c csetting = new ASI_CRM_CN_CustomSetting__c();
            csetting.ASI_CTY_CN_WS_Dev_EndPoint__c = 'http://prcdhdev.pernod-ricard-china.com:8089/PRCApi/transport/wechattransportationoutbound';
            csetting.ASI_CTY_CN_WS_Dev_JWT_Key__c = 'bTe5354ihj84AMwV6AtJ7oefZzw3qZNL';
            csetting.ASI_CTY_CN_WS_Pro_EndPoint__c = 'http://prapi.pernod-ricard-china.com:8089/prcapi/transport/wechattransportationoutbound';
            csetting.ASI_CTY_CN_WS_Pro_JWT_Key__c = '1gfi5g6unMVJaeT4WtXLGENSYaJjuELA';
            csetting.ASI_CTY_CN_WS_Download_SOR_Item_Header__c = '订单编号,订单状态,姓名,电话,订单日期,其他需求,地址,TOV,产品名称,包装规格,下单量（箱）,释放量（箱）,原价（瓶）,促销,折扣率,实际单价（瓶）,释放量金额';
            csetting.ASI_CTY_CN_WS_Upload_SOR_Item_Header__c = '产品英文名, 产品中文名, 每箱瓶数, 容量(cl), 数量(批发商输入), 单位,每瓶单价, Item Group ID(下载自动生成)';
            csetting.ASI_CTY_CN_WS_Upload_SOR_Item_Header_Err__c = '产品英文名,产品中文名, 每箱瓶数,容量(cl), 数量(批发商输入),单位,每瓶单价, Item Group ID(下载自动生成),错误信息';
            insert csetting;

        }
    }

    static testMethod void testMethod1() {
        Test.startTest();
        try {
            ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c LIMIT 1];
            User comUser = [SELECT Id FROM User WHERE Username = 'testWS@wholesaler.com' LIMIT 1];
            System.runAs(comUser) {
                 ASI_KOR_Sales_Order_Request__c salesOrder = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrder(true, customer.Id);
                salesOrder.ASI_KOR_Order_Status__c = 'Submitted';
                update salesOrder;
            }
            
            List<ASI_MFM_Item_Group__c> itemList = [SELECT Id FROM ASI_MFM_Item_Group__c];
	        List<ASI_KOR_Sales_Order_Request__c> sorList = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c];
	        ASI_KOR_Sales_Order_Transaction__c salesOrderItem = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrderItem(true, itemList[0].Id, sorList[0].Id);
	            ASI_KOR_Sales_Order_Transaction__c salesOrderItem2 = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrderItem(true, itemList[1].Id, sorList[0].Id);
	        List<ASI_KOR_Sales_Order_Transaction__c> sorItemList = new List<ASI_KOR_Sales_Order_Transaction__c>{salesOrderItem, salesOrderItem2};
	        insert sorItemList;
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e: ' + e);
        }
        Test.stopTest();
    }
}