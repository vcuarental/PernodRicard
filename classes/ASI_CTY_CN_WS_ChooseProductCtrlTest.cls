@isTest
private class ASI_CTY_CN_WS_ChooseProductCtrlTest {
    @testSetup
    private static void createTestData() {
    	User admin = ASI_CTY_CN_WS_TestDataFactory.generateAdminUser('testAdmin@wholesaler.com');
        System.runAs(admin) {
            Test.startTest();
	    	ASI_CRM_AccountsAdditionalField__c customer = ASI_CTY_CN_WS_TestDataFactory.generateWSUser('testWS@wholesaler.com');
	    	ASI_MFM_Item_Group__c itemGroup = ASI_CTY_CN_WS_TestDataFactory.generateItemGroup(true, 'TestItemGroup');
            ASI_MFM_Item_Group__c itemGroup2 = ASI_CTY_CN_WS_TestDataFactory.generateItemGroup(true, 'TestItemGroup2');
	    	ASI_KOR_Sales_Order_Request__c salesOrder = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrder(true, customer.Id);
            ASI_KOR_Sales_Order_Transaction__c salesOrderItem = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrderItem(true, itemGroup.Id, salesOrder.Id);
	    	ASI_CTY_CN_WS_Custom_Category_Brand__c customCategoryBrand = ASI_CTY_CN_WS_TestDataFactory.generateCustomCategoryBrand(true);
	    	ASI_MFM_Brand__c brand = ASI_CTY_CN_WS_TestDataFactory.generatebrand(true);
            Test.stopTest();
            ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c customCategoryBrandRel = ASI_CTY_CN_WS_TestDataFactory.generateCustomCategoryBrandRel(true, customCategoryBrand.Id, brand.Id);
            ASI_CRM_Order_Form__c orderForm = ASI_CTY_CN_WS_TestDataFactory.generateOrderForm(true);
            ASI_CRM_Order_Form_Customer_Relationship__c orderFormRel = ASI_CTY_CN_WS_TestDataFactory.generateOrderFormRel(true, orderForm.Id, customer.Id);
            ASI_CRM_Order_Form_Detail__c orderFormDetail = ASI_CTY_CN_WS_TestDataFactory.generateOrderFormDetail(true, orderForm.Id, itemGroup.Id);
            ASI_CRM_Order_Form_Detail__c orderFormDetail2 = ASI_CTY_CN_WS_TestDataFactory.generateOrderFormDetail(true, orderForm.Id, itemGroup2.Id);
            ASI_CRM_Promotion_Master__c promotionMaster = ASI_CTY_CN_WS_TestDataFactory.generatePromotionMaster(true);
            ASI_CRM_Item_Group_Customer_Price__c customerPrice = ASI_CTY_CN_WS_TestDataFactory.generateCustomerPrice(true, customer.Id, itemGroup.Id, promotionMaster.Id);
            ASI_CRM_Item_Group_Customer_Price__c customerPrice2 = ASI_CTY_CN_WS_TestDataFactory.generateCustomerPrice(true, customer.Id, itemGroup2.Id, promotionMaster.Id);
	    }
    }
    static testMethod void testGetFilterItems() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        User admin = [SELECT Id FROM User WHERE UserName = 'testAdmin@wholesaler.com'];
        System.runAs(admin) {
            ASI_CTY_CN_WS_Custom_Category_Brand__c customBrand = [SELECT Id, RecordTypeId FROM ASI_CTY_CN_WS_Custom_Category_Brand__c LIMIT 1];
            customBrand.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CTY_CN_WS_Custom_Category_Brand__cASI_CTY_CN_WS_Bottle_Size_Filter');
            update customBrand;
        }
        insert new PermissionSetAssignment(PermissionSetId = ASI_CTY_CN_WS_TestDataFactory.SetupPermissionSet().Id,AssigneeId = user.Id);
        System.runAs(user) {
            ASI_CTY_CN_WS_ChooseProductController.getFilterItems();
        }

        Test.stopTest();
    }
    static testMethod void testGetFilterItems2() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        System.runAs(user) {
            ASI_CTY_CN_WS_ChooseProductController.getFilterItems();
        }

        Test.stopTest();
    }
    static testMethod void testGetBrandRels() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        System.runAs(user) {
            ASI_CTY_CN_WS_ChooseProductController.getBrandRels();
        }

        Test.stopTest();
    }
    static testMethod void testFetchProducts() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        User admin = [SELECT Id FROM User WHERE UserName = 'testAdmin@wholesaler.com'];
        System.runAs(admin) {
            ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id, ASI_CRM_CN_Commercial_Team__c FROM ASI_CRM_AccountsAdditionalField__c LIMIT 1];
            customer.ASI_CRM_CN_Commercial_Team__c = 'Prestige';
            update customer;
        }
        System.runAs(user) {
            ASI_CTY_CN_WS_ChooseProductController.fetchProducts();
        }

        Test.stopTest();
    }
    static testMethod void testFetchProducts2() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        System.runAs(user) {
            ASI_CTY_CN_WS_ChooseProductController.fetchProducts();
        }

        Test.stopTest();
    }
    static testMethod void testGenerateSORItem() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        insert new PermissionSetAssignment(PermissionSetId = ASI_CTY_CN_WS_TestDataFactory.SetupPermissionSet().Id,AssigneeId = user.Id);
        System.runAs(user) {
            ASI_MFM_Item_Group__c itemGroup = [SELECT Id FROM ASI_MFM_Item_Group__c WHERE Name = 'TestItemGroup' LIMIT 1];
            ASI_KOR_Sales_Order_Request__c salesOrder = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c LIMIT 1];
            ASI_CTY_CN_WS_ChooseProductController.generateSORItem(salesOrder.Id, itemGroup.Id, 5);
        }

        Test.stopTest();
    }
    static testMethod void testGenerateSORItem2() {
        Test.startTest();
        
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        insert new PermissionSetAssignment(PermissionSetId = ASI_CTY_CN_WS_TestDataFactory.SetupPermissionSet().Id,AssigneeId = user.Id);
        System.runAs(user) {
            ASI_MFM_Item_Group__c itemGroup = [SELECT Id FROM ASI_MFM_Item_Group__c WHERE Name = 'TestItemGroup2' LIMIT 1];
            ASI_KOR_Sales_Order_Request__c salesOrder = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c LIMIT 1];
            ASI_CTY_CN_WS_ChooseProductController.generateSORItem(salesOrder.Id, itemGroup.Id, 5);
        }
        Test.stopTest();
    }
}