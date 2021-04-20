/*********************************************************************************
 * Name: ASI_CRM_SG_SalesOrder_WS_Test
 * Description: Test all related code to the object Wholesaler Sales Order
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-13      Laputa: Vincent          Created
 * 04/08/2016      Laputa: Hugo Cheung      Updated. Add test setup function. 
 * 04/01/2018      Wilken Lee      			[WL 1.0] Move Customer creation test code to be run by admin instead of test user
*********************************************************************************/
@isTest
public class ASI_CRM_SG_SalesOrder_WS_Test {

    @TestSetup
    public static void setupTestData() {
    }

    public static testmethod void testSalesOrderManage_Controller () {        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_SKU_Code__c> skuList;
        ASI_CRM_SG_TestClassHelper.wholesalesCustomerData customerD;
        ASI_CRM_SG_TestClassHelper.customerData customerOutletD;
        ASI_CRM_SG_TestClassHelper.salesOrderData salesOrderD;
        ASI_CRM_SG_TestClassHelper.salesOrderItemData salesOrderItemD;

		/*[WL 1.0] BEGIN*/
		User u = [select ASI_Default_Order_Customer__c, ASI_Default_Order_Ship_To__c from User where Id = :UserInfo.getUserId()];
		
		u.ASI_Default_Order_Customer__c = 'TestCustomerOutlet';
		u.ASI_Default_Order_Ship_To__c = 'TestCustomerOutlet';
		update u;
		
		skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        customerOutletD = new ASI_CRM_SG_TestClassHelper.customerData(true, 'TestCustomerOutlet');
		List<ASI_CRM_SG_SO_FOC_Rules__c> focRuleList = ASI_CRM_SG_TestClassHelper.createFOCRule(skuList, customerOutletD.customer.Id);		
		/*[WL 1.0] END*/		
		
		salesOrderD = new ASI_CRM_SG_TestClassHelper.salesOrderData(true, 'ASI_CRM_SG_Wholesaler', customerOutletD.customer);
		salesOrderItemD = new ASI_CRM_SG_TestClassHelper.salesOrderItemData(true, 'ASI_CRM_SG_Wholesaler', salesOrderD.salesOrder, skuList.get(1).Id);
        
        test.starttest();
        PageReference pageRef = Page.ASI_CRM_SG_ManageSalesOrder_Page_WS;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', salesOrderD.salesOrder.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(salesOrderD.salesOrder);
        ASI_CRM_SG_ManageSalesOrder_Ctrl_WS salesOrderController = new ASI_CRM_SG_ManageSalesOrder_Ctrl_WS(sc);
        
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
        
        salesOrderController.retrieveSKUbySubBrand();
        System.currentPageReference().getParameters().put('PARAM_SALESORDER_SOURCE_ITEM_ID', skuList.get(0).id);
        salesOrderController.addSalesOrderItem();
        salesOrderController.cancel();
        salesOrderController.setSubBrandSelectOptions();
        salesOrderController.saveSalesOrderItems();
        System.currentPageReference().getParameters().put('PARAM_SALESORDER_SKU_ID', 'zzzzzITEMLINEZ0');
        salesOrderController.removeSalesOrderSKU();
        salesOrderController.saveSalesOrderItems();
		
		salesOrderController.newCounterCreatorLine();
		
        test.stoptest();
        salesOrderD.salesOrder.ASI_KOR_Order_Status__c = 'Rejected';
        update salesOrderD.salesOrder;
        salesOrderD.salesOrder.ASI_KOR_Order_Status__c = 'Submitted';
        update salesOrderD.salesOrder;
    }

}