/*********************************************************************************
 * Name:ASI_CRM_SG_SalesOrder_Test
 * Description: Test all related code to the object Sales Order
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 19/03/2015         Laputa: Conrad        Created
 * 04/08/2016         Laputa: Hugo Cheung   Updated. Add test setup function. 
 * 02/03/2018         Wilken Lee			[WL 1.0] Add Re-export markets test data to increase coverage of SO Header BeforeUpdate trigger
*********************************************************************************/
@isTest
public class ASI_CRM_SG_SalesOrder_Test {

    @TestSetup
    public static void setupTestData() {
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User testUser = new User(Alias  = 'standt', 
                          email = 'newUser@newUser.com',
                          EmailEncodingKey = 'UTF-8', 
                          LastName = 'Testing', 
                          LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_US', 
                          ASI_Company_Name__c = 'Testcompany',
                          ProfileId  = testProfile.Id, 
                          ManagerId = UserInfo.getUserId(),
                          TimeZoneSidKey = 'America/Los_Angeles',
                          username = 'newUser1@reexportTestUser.com',
						  ASI_Default_Order_Customer__c = 'Sample Customer',
						  ASI_Default_Order_Ship_To__c = 'Sample Customer');
        insert testUser;
		
		System.runAs(testUser) {
			/*[WL 1.0] BEGIN*/
			List<ASI_CRM_AccountsAdditionalField__c> custList = new List<ASI_CRM_AccountsAdditionalField__c>();
			ASI_CRM_AccountsAdditionalField__c cust1 = new ASI_CRM_AccountsAdditionalField__c(Name='Sample Customer', recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Re_Export_SO_Customer'), ASI_CRM_VN_Channel__c ='CA');
			ASI_CRM_AccountsAdditionalField__c cust2 = new ASI_CRM_AccountsAdditionalField__c(Name='Sample Customer IN', recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Re_Export_SO_Customer'), ASI_CRM_VN_Channel__c ='ID');
			ASI_CRM_AccountsAdditionalField__c cust3 = new ASI_CRM_AccountsAdditionalField__c(Name='Sample Customer LA', recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Re_Export_SO_Customer'), ASI_CRM_VN_Channel__c ='LA');
			ASI_CRM_AccountsAdditionalField__c cust4 = new ASI_CRM_AccountsAdditionalField__c(Name='Sample Customer MM', recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Re_Export_SO_Customer'), ASI_CRM_VN_Channel__c ='MM');
			ASI_CRM_AccountsAdditionalField__c cust5 = new ASI_CRM_AccountsAdditionalField__c(Name='Sample Customer MY', recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Re_Export_SO_Customer'), ASI_CRM_VN_Channel__c ='MY');
			ASI_CRM_AccountsAdditionalField__c cust6 = new ASI_CRM_AccountsAdditionalField__c(Name='Sample Customer VI', recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Re_Export_SO_Customer'), ASI_CRM_VN_Channel__c ='IT');
			ASI_CRM_AccountsAdditionalField__c cust7 = new ASI_CRM_AccountsAdditionalField__c(Name='Sample Customer VIDF', recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Re_Export_SO_Customer'), ASI_CRM_VN_Channel__c ='IC');
			custList.add(cust1);
			custList.add(cust2);
			custList.add(cust3);
			custList.add(cust4);
			custList.add(cust5);
			custList.add(cust6);
			custList.add(cust7);
			insert custList;
			/*[WL 1.0] END*/
			
			ASI_CRM_SG_TestClassHelper.createDataSettings();

			List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
			
			ASI_CRM_SG_TestClassHelper.salesOrderData salesOrderD = new ASI_CRM_SG_TestClassHelper.salesOrderData(true, 'ASI_CRM_SG_CA', cust1);
			
			/*[WL 1.0] BEGIN*/
			ASI_CRM_SG_TestClassHelper.salesOrderData salesOrderD2 = new ASI_CRM_SG_TestClassHelper.salesOrderData(true, 'ASI_CRM_SG_IN', cust2);
			ASI_CRM_SG_TestClassHelper.salesOrderData salesOrderD3 = new ASI_CRM_SG_TestClassHelper.salesOrderData(true, 'ASI_CRM_SG_LA', cust3);
			ASI_CRM_SG_TestClassHelper.salesOrderData salesOrderD4 = new ASI_CRM_SG_TestClassHelper.salesOrderData(true, 'ASI_CRM_SG_MM', cust4);
			ASI_CRM_SG_TestClassHelper.salesOrderData salesOrderD5 = new ASI_CRM_SG_TestClassHelper.salesOrderData(true, 'ASI_CRM_SG_MY', cust5);
			ASI_CRM_SG_TestClassHelper.salesOrderData salesOrderD6 = new ASI_CRM_SG_TestClassHelper.salesOrderData(true, 'ASI_CRM_SG_VI', cust6);
			ASI_CRM_SG_TestClassHelper.salesOrderData salesOrderD7 = new ASI_CRM_SG_TestClassHelper.salesOrderData(true, 'ASI_CRM_SG_VIDF', cust7);
			/*[WL 1.0] END*/
			
			ASI_CRM_SG_TestClassHelper.salesOrderItemData salesOrderItemD = new ASI_CRM_SG_TestClassHelper.salesOrderItemData(true, 'ASI_CRM_SG_CA', salesOrderD.salesOrder);
        }
    }

    public static testmethod void testSalesOrderManage_Controller () {
		
			ASI_KOR_Sales_Order_Request__c salesOrder = [SELECT Id, ASI_KOR_Order_Status__c FROM ASI_KOR_Sales_Order_Request__c LIMIT 1];
			ASI_MFM_SKU_Code__c sku = [SELECT Id FROM ASI_MFM_SKU_Code__c WHERE Name = 'Test Sku 3' LIMIT 1];

			test.starttest();
			PageReference pageRef = Page.ASI_CRM_SG_ManageSalesOrder_Page;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getParameters().put('id', salesOrder.id);
			
			ApexPages.StandardController sc = new ApexPages.StandardController(salesOrder);
			ASI_CRM_SG_ManageSalesOrder_Controller salesOrderController = new ASI_CRM_SG_ManageSalesOrder_Controller(sc);
			
			ASI_CRM_SG_ComponentControllerBase soTestbase = salesOrderController.getComponentController();
			salesOrderController.setComponentController(soTestbase);
			Map<String, ASI_CRM_SG_ComponentControllerBase> testMap = salesOrderController.getComponentControllerMap();
			salesOrderController.setComponentControllerMap('keyTest', null);
			ASI_CRM_SG_PageControllerBase testTemp2 = salesOrderController.getThis();
			if(soTestbase == null) {
				soTestbase = new ASI_CRM_SG_ComponentControllerBase();
			}
			
			soTestbase.pageController = new ASI_CRM_SG_PageControllerBase();
			soTestbase.key = 'testkey';
			ASI_CRM_SG_PageControllerBase testPageControllerBase2 = soTestbase.pageController;
			
			String counter = salesOrderController.newCounterCreatorLine();
			salesOrderController.retrieveSKUbySubBrand();
			System.currentPageReference().getParameters().put('PARAM_SALESORDER_SOURCE_ITEM_ID', sku.id);
			salesOrderController.addSalesOrderItem();
			salesOrderController.cancel();
			salesOrderController.setSubBrandSelectOptions();
			salesOrderController.saveSalesOrderItems();
			System.currentPageReference().getParameters().put('PARAM_SALESORDER_SKU_ID', sku.id);
			salesOrderController.removeSalesOrderSKU();
			salesOrderController.saveSalesOrderItems();
			test.stoptest();
			salesOrder.ASI_KOR_Order_Status__c = 'Rejected';
			update salesOrder;
			salesOrder.ASI_KOR_Order_Status__c = 'Submitted';
			update salesOrder;
    }
    
    public static testmethod void testSalesOrderPDF_Controller() {
        ASI_KOR_Sales_Order_Request__c salesOrder = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c LIMIT 1];

        test.starttest();

        ASI_CRM_SG_SalesOrderPDFController salesOrderController = new ASI_CRM_SG_SalesOrderPDFController();
        salesOrderController.currentHeaderId = salesOrder.id;
        salesOrderController.getHeader();
        salesOrderController.getDetails();
		
		/*[WL 1.0] BEGIN*/
		List<ASI_KOR_Sales_Order_Request__c> salesOrderList = [SELECT Id, ASI_CRM_Delivery_Note__c FROM ASI_KOR_Sales_Order_Request__c];
		for (ASI_KOR_Sales_Order_Request__c so:salesOrderList){
			so.ASI_CRM_Delivery_Note__c = 'test';
			update so;	//Intentionally to update each of them separately because trigger only check first record's record type in the list
		}
		/*[WL 1.0] END*/
        test.stoptest();
 
    }

}