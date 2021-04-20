@isTest
private class ASI_CTY_CN_WS_MyOrdersControllerTest {
    @testSetup
    private static void createTestData() {
        User admin = ASI_CTY_CN_WS_TestDataFactory.generateAdminUser('testAdmin@wholesaler.com');
        System.debug(LoggingLevel.INFO, '*** admin.Id: ' + admin.Id);
        System.runAs(admin) {
            Test.startTest();
            System.debug(LoggingLevel.INFO, '*** current user: ' + UserInfo.getUserId());
            ASI_CRM_AccountsAdditionalField__c customer = ASI_CTY_CN_WS_TestDataFactory.generateWSUser('testWS@wholesaler.com');
            
            ASI_MFM_Item_Group__c itemGroup = ASI_CTY_CN_WS_TestDataFactory.generateItemGroup(true, 'TestItemGroup');

            ASI_CRM_Order_Form__c orderForm = ASI_CTY_CN_WS_TestDataFactory.generateOrderForm(true);
            ASI_CRM_Order_Form_Customer_Relationship__c orderFormRel = ASI_CTY_CN_WS_TestDataFactory.generateOrderFormRel(true, orderForm.Id, customer.Id);
            ASI_CRM_Order_Form_Detail__c orderFormDetail = ASI_CTY_CN_WS_TestDataFactory.generateOrderFormDetail(true, orderForm.Id, itemGroup.Id);

            ASI_KOR_Sales_Order_Request__c salesOrder = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrder(true, customer.Id);
            salesOrder.ASI_KOR_Order_Status__c = 'Submitted';
            update salesOrder;
            
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

            ASI_KOR_Sales_Order_Transaction__c salesOrderItem = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrderItem(true, itemGroup.Id, salesOrder.Id);

            List<ASI_CRM_TOV__c> tovList = new List<ASI_CRM_TOV__c>();
            ASI_CRM_TOV__c tov = new ASI_CRM_TOV__c(
                ASI_CRM_Status__c = 'Held', ASI_CRM_SO_Number__c = '123456',
                ASI_CRM_Order_Date__c = Date.today().addDays(-15),
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV__cASI_CRM_CN_TOV'),
                ASI_CRM_SF_SO_Request_Number__c = salesOrder.Id);
            tovList.add(tov);
            ASI_CRM_TOV__c refundTOV = new ASI_CRM_TOV__c(
                ASI_CRM_SO_Number__c = 'RefundTOVTest', 
                ASI_CRM_SO_Type__c = 'V2', ASI_CRM_Order_Date__c = Date.today().addDays(-15),
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV__cASI_CRM_CN_TOV_Final'),
                ASI_CRM_SF_SO_Request_Number__c = salesOrder.Id);
            tovList.add(refundTOV);
            insert tovList;

            List<ASI_CRM_TOV_Detail__c> tovLineList = new List<ASI_CRM_TOV_Detail__c>();
            ASI_CRM_TOV_Detail__c tovLine = new ASI_CRM_TOV_Detail__c(
                ASI_CRM_TOV__c = tov.Id, ASI_CRM_SF_SO_Request_Line_Number__c = salesOrderItem.Id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV_Detail__cASI_CRM_CN_CN_TOV_Detail'),
                ASI_CRM_UOM__c = 'CA', ASI_CRM_PriceWVAT_BT__c = 100, ASI_CRM_Price_BT__c = 88,
                ASI_CRM_Order_QTY__c = 10);
            tovLineList.add(tovLine);
            ASI_CRM_TOV_Detail__c refundTOVLine = new ASI_CRM_TOV_Detail__c(
                ASI_CRM_TOV__c = refundTOV.Id, ASI_CRM_SF_SO_Request_Line_Number__c = salesOrderItem.Id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV_Detail__cASI_CRM_CN_CN_TOV_Detail'),
                ASI_CRM_UOM__c = 'CA', ASI_CRM_PriceWVAT_BT__c = 100, ASI_CRM_Price_BT__c = 88,
                ASI_CRM_Order_QTY__c = 10);
            tovLineList.add(refundTOVLine);
            insert tovLineList;
        }
    }
    
    static testMethod void testGetOpenSOR() {
        Test.startTest();

        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        System.runAs(user) {
        	ASI_CTY_CN_WS_MyOrdersController.getOpenSOR();
        }

        Test.stopTest();
    }
    static testMethod void testFetchSORs() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        System.runAs(user) {
            ASI_CTY_CN_WS_MyOrdersController.fetchSORs('','');
            ASI_CTY_CN_WS_MyOrdersController.fetchSORs('2020-01-01','2020-01-31');
        }

        Test.stopTest();
    }
    static testMethod void testdeleteOpenSOR() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        ASI_KOR_Sales_Order_Request__c sor = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c LIMIT 1];
        System.runAs(user) {
            ASI_CTY_CN_WS_MyOrdersController.deleteOpenSOR(sor.Id);
        }

        Test.stopTest();
    }
    static testMethod void testFetchRefundTOVs() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        insert new PermissionSetAssignment(PermissionSetId = ASI_CTY_CN_WS_TestDataFactory.SetupPermissionSet().Id,AssigneeId = user.Id);
        System.runAs(user) {
            ASI_CTY_CN_WS_MyOrdersController.fetchRefundTOVs();
        }
        
        Test.stopTest();
    }
    static testMethod void testFetchHeldTOVs() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        System.runAs(user) {
            ASI_CTY_CN_WS_MyOrdersController.fetchHeldTOVs();
        }

        Test.stopTest();
    }
    static testMethod void testCopySalesOrder() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        ASI_KOR_Sales_Order_Request__c sor = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c LIMIT 1];
        System.runAs(user) {
            ASI_CTY_CN_WS_MyOrdersController.copySalesOrder(sor.Id);
        }

        Test.stopTest();
    }
    static testMethod void testGetSORDetails() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        insert new PermissionSetAssignment(PermissionSetId = ASI_CTY_CN_WS_TestDataFactory.SetupPermissionSet().Id,AssigneeId = user.Id);
        System.runAs(user) {
            ASI_CTY_CN_WS_MyOrdersController.getSORDetails('','');
            ASI_CTY_CN_WS_MyOrdersController.getSORDetails('2020-01-01','2020-01-31');
        }

        Test.stopTest();
    }
    static testMethod void testNegative() {
        Test.startTest();

        ASI_CTY_CN_WS_MyOrdersController.getOpenSOR();
        ASI_CTY_CN_WS_MyOrdersController.fetchSORs('','');
        ASI_CTY_CN_WS_MyOrdersController.fetchRefundTOVs();
        ASI_CTY_CN_WS_MyOrdersController.fetchHeldTOVs();

        Test.stopTest();
    }
}