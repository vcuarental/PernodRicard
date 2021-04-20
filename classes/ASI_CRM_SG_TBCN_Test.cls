/*********************************************************************************
 * Name:ASI_CRM_SG_TBCN_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 14/06/2016       Laputa: Hugo            Created
 * 10/07/2017       Wilken Lee              [WL 1.0] Updated test data default Customer Name record type to Outlet SG
 * 25/10/2017       Wilken Lee              [WL 2.0] Fix test class error of incorrect default customer 
*********************************************************************************/
@isTest
public class ASI_CRM_SG_TBCN_Test {
	
    @testSetup
    public static void setupTestData() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        ASI_CRM_SG_TestClassHelper.wholesalesCustomerData customerD = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(true, 'TestCustomer');

		/*[WL 1.0 BEGIN]*/
		//Account testAccount = new Account(Name = 'TestWholesaler');
        Account testAccount = new Account(Name = 'TestWholesaler', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Outlet'));
		/*[WL 1.0 BEGIN]*/
        insert testAccount;

        Id soHistoryRecTypeId = Schema.SObjectType.ASI_HK_CRM_Sales_Order_History__c
                                      .getRecordTypeInfosByName()
                                      .get('SG CRM Sales Order History').getRecordTypeId();

        ASI_HK_CRM_Sales_Order_History__c history = new ASI_HK_CRM_Sales_Order_History__c(
                                                                RecordTypeId = soHistoryRecTypeId,
                                                                ASI_HK_CRM_Account_PA__c = testAccount.Id,
                                                                ASI_CRM_Sold_To__c = customerD.customer.Id,
                                                                ASI_HK_CRM_Order_Type__c = 'Singapore DF & DP Sales Order - SO',
                                                                ASI_HK_CRM_Order_No__c = '123456789',
                                                                ASI_HK_CRM_JDE_Invoice_No__c = '123456789'
                                                        );
        insert history;

        Id soHistoryDetailRecTypeId = Schema.SObjectType.ASI_HK_CRM_Sales_Order_History_Detail__c
                                      .getRecordTypeInfosByName()
                                      .get('SG CRM Sales Order History Detail').getRecordTypeId();
        
        List<ASI_HK_CRM_Sales_Order_History_Detail__c> historyDetailList = new List<ASI_HK_CRM_Sales_Order_History_Detail__c>();
        
        ASI_HK_CRM_Sales_Order_History_Detail__c historyDetail1 = new ASI_HK_CRM_Sales_Order_History_Detail__c(
                                                                             ASI_HK_CRM_Sales_Order_History__c = history.Id,
                                                                             ASI_HK_CRM_Product_SKU__c = skuList.get(0).Id,
																			 recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Sales_Order_History_Detail__cASI_CRM_SG_Sales_Order_History_Detail')
                                                                      );
        historyDetailList.add(historyDetail1);
        
        ASI_HK_CRM_Sales_Order_History_Detail__c historyDetail2 = new ASI_HK_CRM_Sales_Order_History_Detail__c(
                                                                             ASI_HK_CRM_Sales_Order_History__c = history.Id,
                                                                             ASI_HK_CRM_Product_SKU__c = skuList.get(1).Id,
																			 recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Sales_Order_History_Detail__cASI_CRM_SG_Sales_Order_History_Detail')
                                                                     );
        historyDetailList.add(historyDetail2);
        
        insert historyDetailList;
		
		/*[WL 2.0 BEGIN]*/
		historyDetail1.ASI_HK_CRM_Quantity_in_Bottles__c = 20;
		update historyDetail1;
		/*[WL 2.0 BEGIN]*/

		/*[WL 1.0 BEGIN]*/
        //ASI_CRM_SG_TestClassHelper.salesOrderData tbcnOrderD = new ASI_CRM_SG_TestClassHelper.salesOrderData(true, 'ASI_CRM_SG_TBCN');
		ASI_CRM_SG_TestClassHelper.salesOrderData tbcnOrderD = new ASI_CRM_SG_TestClassHelper.salesOrderData(false, 'ASI_CRM_SG_TBCN');
		/*[WL 1.0 END]*/
        
		/*[WL 2.0 BEGIN]*/
		//tbcnOrderD.salesOrder.ASI_CRM_SG_Customer__c = customerD.customer.Id;
		ASI_CRM_SG_TestClassHelper.customerData customerData = new ASI_CRM_SG_TestClassHelper.customerData(true, 'TestCustomerOutlet');
		tbcnOrderD.salesOrder.ASI_CRM_SG_Customer__c = customerData.customer.Id;
		tbcnOrderD.salesOrder.ASI_CRM_SG_Ship_To__c = customerData.customer.Id;
		/*[WL 2.0 END]*/
		
		/*[WL 1.0 BEGIN]*/
		insert tbcnOrderD.salesOrder;
		/*[WL 1.0 END]*/
		
        update tbcnOrderD.salesOrder;
        
        ASI_CRM_SG_TestClassHelper.salesOrderItemData tbcnOrderLineItemD1 = new ASI_CRM_SG_TestClassHelper.salesOrderItemData(false, 'ASI_CRM_SG_TBCN', tbcnOrderD.salesOrder);
        ASI_CRM_SG_TestClassHelper.salesOrderItemData tbcnOrderLineItemD2 = new ASI_CRM_SG_TestClassHelper.salesOrderItemData(false, 'ASI_CRM_SG_TBCN', tbcnOrderD.salesOrder);
        tbcnOrderLineItemD2.salesOrderItem.ASI_CRM_Sales_Order_History_Detail__c = historyDetail1.Id;

        List<ASI_KOR_Sales_Order_Transaction__c> tbcnOrderLineItemList = new List<ASI_KOR_Sales_Order_Transaction__c>();
        tbcnOrderLineItemList.add(tbcnOrderLineItemD1.salesOrderItem);
        tbcnOrderLineItemList.add(tbcnOrderLineItemD2.salesOrderItem);
        insert tbcnOrderLineItemList;
    }

    public static testmethod void testTBCNController() {
        List<ASI_MFM_SKU_Code__c> skuList = [SELECT Id FROM ASI_MFM_SKU_Code__c];
        List<ASI_HK_CRM_Sales_Order_History_Detail__c> historyDetailList = [SELECT Id FROM ASI_HK_CRM_Sales_Order_History_Detail__c];

        ASI_KOR_Sales_Order_Request__c tbcnOrder = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c LIMIT 1];
        List<ASI_KOR_Sales_Order_Transaction__c> tbcnDetailList = [SELECT Id FROM ASI_KOR_Sales_Order_Transaction__c];

        test.starttest();
        
		PageReference pageRef = Page.ASI_CRM_SG_TBCN_ManageAll_Page;
		Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', tbcnOrder.id);        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(tbcnOrder);
        ASI_CRM_SG_TBCN_ManageAll_Controller tbcnController = new ASI_CRM_SG_TBCN_ManageAll_Controller(sc);
        
        tbcnController.retrieveSKU();
        tbcnController.retrieveSalesOrderHistoryDetail();
        
        System.currentPageReference().getParameters().put('PARAM_SKU_ID', skuList.get(2).id);
        System.currentPageReference().getParameters().put('PARAM_SALES_ORDER_HISTORY_DETAIL_ID', historyDetailList.get(0).id);
        tbcnController.addSalesOrderLineItem();
        
        System.currentPageReference().getParameters().put('PARAM_SALES_ORDER_LINE_ITEM_ID', tbcnDetailList.get(0).id);
        tbcnController.removeSalesOrderLineItem();
        
        System.currentPageReference().getParameters().put('PARAM_SALES_ORDER_LINE_ITEM_ID', 'zzzzzITEMLINEZ0');
        tbcnController.removeSalesOrderLineItem();
        
        tbcnController.cancel();
        tbcnController.saveSalesOrderLineItem();
        
        test.stoptest();
    }
    
    public static testmethod void testTBCN_PDFController() {
        ASI_KOR_Sales_Order_Request__c tbcnOrder = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c LIMIT 1];
        
        test.starttest();
        ASI_CRM_SG_TBCN_PDF_Controller tbcnController = new ASI_CRM_SG_TBCN_PDF_Controller();
        tbcnController.currentTBCNHeaderId = tbcnOrder.id;
        tbcnController.getHeader();
        tbcnController.getDetails();
        test.stoptest();
    }
    
}