@isTest
private class ASI_CTY_CN_WS_ProductDetailCtrlTest {
	@testSetup
    private static void createTestData() {
    	User admin = ASI_CTY_CN_WS_TestDataFactory.generateAdminUser('testAdmin@wholesaler.com');
        System.runAs(admin) {
            Test.startTest();
            ASI_CRM_AccountsAdditionalField__c customer = ASI_CTY_CN_WS_TestDataFactory.generateWSUser('testWS@wholesaler.com');
        	ASI_MFM_Item_Group__c itemGroup = ASI_CTY_CN_WS_TestDataFactory.generateItemGroup(true, 'TestItemGroup');
        	ASI_KOR_Sales_Order_Request__c salesOrder = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrder(true, customer.Id);
            ASI_KOR_Sales_Order_Request__c salesOrder2 = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrder(true, customer.Id);
            salesOrder2.ASI_KOR_Order_Status__c = 'Submitted';
            update salesOrder2;
            Test.stopTest();
        	ASI_KOR_Sales_Order_Transaction__c salesOrderItem = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrderItem(true, itemGroup.Id, salesOrder.Id);
        }
    }
    static testMethod void testGetProduct() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        ASI_MFM_Item_Group__c itemGroup = [SELECT Id FROM ASI_MFM_Item_Group__c WHERE Name = 'TestItemGroup'];
        System.runAs(user) {
            ASI_CTY_CN_WS_ProductDetailController.getProduct(itemGroup.Id);
        }

        Test.stopTest();
    }
    static testMethod void testGetProduct2() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        System.runAs(user) {
            ASI_CTY_CN_WS_ProductDetailController.getProduct('');
        }

        Test.stopTest();
    }
    static testMethod void testGenerateSORItem() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        ASI_MFM_Item_Group__c itemGroup = [SELECT Id FROM ASI_MFM_Item_Group__c WHERE Name = 'TestItemGroup'];
        ASI_KOR_Sales_Order_Request__c salesOrder = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c WHERE ASI_KOR_Order_Status__c = 'Submitted' LIMIT 1];
        System.runAs(user) {
            ASI_CTY_CN_WS_ProductDetailController.generateSORItem(salesOrder.Id, itemGroup.Id, 5);
        }

        Test.stopTest();
    }
    static testMethod void testGenerateSORItem2() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        insert new PermissionSetAssignment(PermissionSetId = ASI_CTY_CN_WS_TestDataFactory.SetupPermissionSet().Id,AssigneeId = user.Id);
        ASI_MFM_Item_Group__c itemGroup = [SELECT Id FROM ASI_MFM_Item_Group__c WHERE Name = 'TestItemGroup'];
        ASI_KOR_Sales_Order_Request__c salesOrder = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c WHERE ASI_KOR_Order_Status__c = 'Open' LIMIT 1];
        System.debug(LoggingLevel.INFO, '*** salesOrder: ' + salesOrder);
        ASI_KOR_Sales_Order_Transaction__c salesOrderItem = [SELECT Id, ASI_KOR_Sales_Order_Request__c FROM ASI_KOR_Sales_Order_Transaction__c LIMIT 1];
        System.debug(LoggingLevel.INFO, '*** salesOrderItem: ' + salesOrderItem);
        System.runAs(user) {
            ASI_CTY_CN_WS_ProductDetailController.generateSORItem(salesOrder.Id, itemGroup.Id, 5);
        }

        Test.stopTest();
    }
}