/*********************************************************************************
* Name: ASI_CRM_JP_SalesOrderPDFTest
* Description: Test class for all sales order PDF
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 11/07/2017       Hugo Cheung             Created       
* 18/08/2017       Kevin Choi              Added Test Class for ASI_CRM_JP_SOSalesContract_Ctrl 
* 26/09/2019       Wilken Lee              [WL 1.0] Test Class fix
*/
@isTest
public class ASI_CRM_JP_SalesOrderPDFTest {
    
    private final static String PDF_TYPE = 'pdfType';
    private final static String SOID     = 'id';
    private final static String LANGUAGE = 'language';
    
    @TestSetup
    public static void setupData() {
        ASI_CRM_JP_TestHelper.createRunningNumber();
        ASI_CRM_JP_TestHelper.createApprovalRoute();
        
        Map<String, Object> postalCodeFieldValueMap = ASI_CRM_JP_TestHelper.POSTAL_CODE_DEFAULT_VALUE_MAP;
        ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestHelper.createPostalCode(postalCodeFieldValueMap);
        insert postalCode;
        
        Map<String, Object> directSalesCustomerFieldValueMap = ASI_CRM_JP_TestHelper.DIRECT_SALES_CUSTOMER_DEFAULT_VALUE_MAP;
        directSalesCustomerFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.CUSTOMER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales_Customer'));
        ASI_CRM_AccountsAdditionalField__c directSalesCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesCustomerFieldValueMap);
        insert directSalesCustomer;
        
        Map<String, Object> directSalesShipToCustomerFieldValueMap = ASI_CRM_JP_TestHelper.DIRECT_SALES_SHIP_TO_DEFAULT_VALUE_MAP;
        directSalesShipToCustomerFieldValueMap.put('ASI_CRM_Customer__c', directSalesCustomer.Id);
        directSalesShipToCustomerFieldValueMap.remove('ASI_CRM_KR_Salesman__c');
        ASI_CRM_AccountsAdditionalField__c directSalesShipToCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesShipToCustomerFieldValueMap);
        insert directSalesShipToCustomer;
        
        /*[WL 1.0] BEGIN*/
        directSalesShipToCustomer.ASI_CRM_CN_Inactive_Flag__c = false;
        update directSalesShipToCustomer;
        /*[WL 1.0] END*/
        
        Map<String, Object> directSalesBillToCustomerFieldValueMap = ASI_CRM_JP_TestHelper.BILL_TO_CUSTOMER_DEFAULT_VALUE_MAP;
        ASI_CRM_AccountsAdditionalField__c directSalesBillToCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesBillToCustomerFieldValueMap);
        insert directSalesBillToCustomer;
        
        insert ASI_CRM_JP_TestHelper.createBillTo(directSalesCustomer.Id, directSalesBillToCustomer.Id);
        
        Map<String, Object> itemGroupFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_GROUP_DEFAUL_VALUE_MAP;
        ASI_MFM_Item_Group__c itemGroup = ASI_CRM_JP_TestHelper.createItemGroup(itemGroupFieldValueMap);
        insert itemGroup;
        
        List<ASI_MFM_SKU_Code__c> skuCodeList = new List<ASI_MFM_SKU_Code__c>();
        for(Integer index = 0 ; index < 2 ; index++) {
            Map<String, Object> skuCodeFieldValueMap = ASI_CRM_JP_TestHelper.SKU_DEFAULT_VALUE_MAP;
            skuCodeFieldValueMap.put('ASI_MFM_Item_Group__c', itemGroup.Id);
            ASI_MFM_SKU_Code__c skuCode = ASI_CRM_JP_TestHelper.createSKU(skuCodeFieldValueMap);
            
            skuCode.ASI_HK_CRM_Active__c = true; //WL 1.0
            skuCodeList.add(skuCode);
        }
        insert skuCodeList;
        
        List<ASI_CRM_JP_Item_Availability__c> itemAvailabilityList = new List<ASI_CRM_JP_Item_Availability__c>();
        for(ASI_MFM_SKU_Code__c skuCode : skuCodeList) {
            Map<String, Object> itemAvailabilityFieldValueMap1 = ASI_CRM_JP_TestHelper.ITEM_AVAILABILITY_DEFAULT_VALUE_MAP;
            itemAvailabilityFieldValueMap1.put('ASI_SKU__c', skuCode.Id);
            itemAvailabilityFieldValueMap1.put('ASI_Warehouse_Location__c', '111');
            ASI_CRM_JP_Item_Availability__c itemAvailability1 = ASI_CRM_JP_TestHelper.createItemAvailability(itemAvailabilityFieldValueMap1);
            itemAvailabilityList.add(itemAvailability1);
            
            Map<String, Object> itemAvailabilityFieldValueMap2 = ASI_CRM_JP_TestHelper.ITEM_AVAILABILITY_DEFAULT_VALUE_MAP;
            itemAvailabilityFieldValueMap2.put('ASI_SKU__c', skuCode.Id);
            itemAvailabilityFieldValueMap2.put('ASI_Warehouse_Location__c', '131');
            ASI_CRM_JP_Item_Availability__c itemAvailability2 = ASI_CRM_JP_TestHelper.createItemAvailability(itemAvailabilityFieldValueMap2);
            itemAvailabilityList.add(itemAvailability2);
        }
        insert itemAvailabilityList;
        
        Map<String, Object> priceListFieldValueMap = ASI_CRM_JP_TestHelper.PRICE_LIST_DEFAULT_VALUE_MAP;
        ASI_CRM_Price_List__c priceList = ASI_CRM_JP_TestHelper.createPriceList(priceListFieldValueMap);
        priceList.ASI_CRM_JP_Effective_Date__c  = System.Today(); //WL 1.0
        insert priceList;
        
        List<ASI_CRM_JP_Customer_Product_Price__c> itemBasePriceList = new List<ASI_CRM_JP_Customer_Product_Price__c>();
        for(String itemBasePriceRecordTypeId : ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_RECORD_TYPE.values()) {
            Map<String, Object> itemBasePriceFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_DEFAULT_VALUE_MAP;
            itemBasePriceFieldValueMap.put('ASI_MFM_Item_Group__c', itemGroup.Id);
            itemBasePriceFieldValueMap.put('RecordTypeId', itemBasePriceRecordTypeId);
            ASI_CRM_JP_Customer_Product_Price__c itemBasePrice = ASI_CRM_JP_TestHelper.createItemBasePrice(itemBasePriceFieldValueMap);
            itemBasePrice.ASI_Customer_Name__c = directSalesCustomer.Id;//WL 1.0
            itemBasePriceList.add(itemBasePrice);
        }
        insert itemBasePriceList;
    }
    
    public static testMethod void testDirectSalesPDF() {
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c customer : [SELECT Id, RecordType.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c]) {
            customerMap.put(customer.RecordType.DeveloperName, customer);
        }
        
        ASI_CRM_Bill_To__c billTo = [SELECT Id FROM ASI_CRM_Bill_To__c LIMIT 1];
        List<ASI_MFM_SKU_Code__c> skuCodeList = [SELECT Id FROM ASI_MFM_SKU_Code__c];
        
        Map<String, Object> userRoleFieldValueMap = ASI_CRM_JP_TestHelper.USER_ROLE_DEFAULT_VALUE_MAP;
        UserRole uRole = ASI_CRM_JP_TestHelper.createUserRole(userRoleFieldValueMap);
        insert uRole;
        
        Map<String, Object> userFieldValueMap = ASI_CRM_JP_TestHelper.USER_DEFAULT_VALUE_MAP;
        userFieldValueMap.put('UserRoleId', uRole.Id);
        userFieldValueMap.put('Street', 'Testing Address');
        userFieldValueMap.put('ASI_CRM_JP_Address_Local__c', 'Testing JP Address');
        User u = ASI_CRM_JP_TestHelper.createUser(userFieldValueMap);
        insert u;
        
        System.runAs(u) {
            Map<String, Object> directSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
            directSOFieldValueMap.put('ASI_CRM_Ship_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Ship_To').Id);
            directSOFieldValueMap.put('ASI_CRM_Sold_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
            directSOFieldValueMap.put('ASI_CRM_JP_Bill_To__c', billTo.Id);
            directSOFieldValueMap.put('ASI_CRM_Salesman__c', u.Id);
            directSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales'));
            
            directSOFieldValueMap.put('ASI_CRM_Payment_Option__c', 'COD');
            directSOFieldValueMap.put('ASI_CRM_JP_Taxable_Service_Charge__c', '1000');
            directSOFieldValueMap.put('ASI_CRM_Invoice_Date__c', Date.today());
            directSOFieldValueMap.put('ASI_CRM_Payment_Request_Date__c', Date.today().addMonths(2));
            directSOFieldValueMap.put('ASI_CRM_Remark__c', 'Testing Remark 1');
            directSOFieldValueMap.put('ASI_CRM_JP_Remark_2__c', 'Testing Remark 2');
            
            ASI_CRM_JP_Sales_Order__c directSO = ASI_CRM_JP_TestHelper.createSalesOrder(directSOFieldValueMap);
            insert directSO;
            
            test.startTest(); //WL 1.0
            
            Map<String, Object> salesOrderItemFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_ITEM_DEFAULT_VALUE_MAP;
            salesOrderItemFieldValueMap.put('ASI_CRM_Sales_Order__c', directSO.Id);
            salesOrderItemFieldValueMap.put('ASI_CRM_SKU__c', skuCodeList.get(0).Id);
            salesOrderItemFieldValueMap.put('ASI_CRM_Sys_Item_Availability_Filter__c', directSO.ASI_CRM_Branch_Plant__c);
            salesOrderItemFieldValueMap.put('ASI_CRM_JP_Sys_Lookup_Filter__c', 'ASI_CRM_JP_Manual_JDE_SO');
            ASI_CRM_JP_Sales_Order_Item__c salesOrderItem = ASI_CRM_JP_TestHelper.createSalesOrderLine(salesOrderItemFieldValueMap);
            insert salesOrderItem;
                        
            PageReference pageRef = Page.ASI_CRM_JP_SO_PDF_Page;
            pageRef.getParameters().put(PDF_TYPE, 'Testing');
            pageRef.getParameters().put(SOID, directSO.Id);
            pageRef.getParameters().put(LANGUAGE, 'ja');
            Test.setCurrentPage(pageRef);
            
            ASI_CRM_JP_SO_PDF_Controller pdfCtrl = new ASI_CRM_JP_SO_PDF_Controller();
            
            ASI_CRM_JP_SODeliveryNote_ComCtrl jpDeliveryNoteCtrl = new ASI_CRM_JP_SODeliveryNote_ComCtrl();
            jpDeliveryNoteCtrl.salesOrderId = directSO.Id;
            jpDeliveryNoteCtrl.pdfLanguage  = 'ja';
            Boolean jpDeliveryNoteInitPage = jpDeliveryNoteCtrl.isPageInit;
            
            ASI_CRM_JP_SODeliveryNote_ComCtrl enDeliveryNoteCtrl = new ASI_CRM_JP_SODeliveryNote_ComCtrl();
            enDeliveryNoteCtrl.salesOrderId = directSO.Id;
            enDeliveryNoteCtrl.pdfLanguage  = 'en';
            Boolean enDeliveryNoteInitPage = enDeliveryNoteCtrl.isPageInit;
            
            ASI_CRM_JP_SOQuotation_ComCtrl jpQuotationCtrl = new ASI_CRM_JP_SOQuotation_ComCtrl();
            jpQuotationCtrl.salesOrderId = directSO.Id;
            jpQuotationCtrl.pdfLanguage  = 'ja';
            Boolean jpQuotationInitPage = jpQuotationCtrl.isPageInit;
            
            ASI_CRM_JP_SOQuotation_ComCtrl enQuotationCtrl = new ASI_CRM_JP_SOQuotation_ComCtrl();
            enQuotationCtrl.salesOrderId = directSO.Id;
            enQuotationCtrl.pdfLanguage  = 'en';
            Boolean enQuotationInitPage = enQuotationCtrl.isPageInit;
            
            test.stopTest(); //WL 1.0
        }
    }
    
    public static testMethod void testDirectSalesInvoicePDF() {
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c customer : [SELECT Id, RecordType.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c]) {
            customerMap.put(customer.RecordType.DeveloperName, customer);
        }
        
        ASI_CRM_Bill_To__c billTo = [SELECT Id FROM ASI_CRM_Bill_To__c LIMIT 1];
        List<ASI_MFM_SKU_Code__c> skuCodeList = [SELECT Id FROM ASI_MFM_SKU_Code__c];
        
        Map<String, Object> userRoleFieldValueMap = ASI_CRM_JP_TestHelper.USER_ROLE_DEFAULT_VALUE_MAP;
        UserRole uRole = ASI_CRM_JP_TestHelper.createUserRole(userRoleFieldValueMap);
        insert uRole;
        
        Map<String, Object> userFieldValueMap = ASI_CRM_JP_TestHelper.USER_DEFAULT_VALUE_MAP;
        userFieldValueMap.put('UserRoleId', uRole.Id);
        userFieldValueMap.put('Street', 'Testing Address');
        userFieldValueMap.put('ASI_CRM_JP_Address_Local__c', 'Testing JP Address');
        User u = ASI_CRM_JP_TestHelper.createUser(userFieldValueMap);
        insert u;
        
        System.runAs(u) {
            Map<String, Object> directSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
            directSOFieldValueMap.put('ASI_CRM_Ship_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Ship_To').Id);
            directSOFieldValueMap.put('ASI_CRM_Sold_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
            directSOFieldValueMap.put('ASI_CRM_JP_Bill_To__c', billTo.Id);
            directSOFieldValueMap.put('ASI_CRM_Salesman__c', u.Id);
            directSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales'));
            
            directSOFieldValueMap.put('ASI_CRM_Payment_Option__c', 'COD');
            directSOFieldValueMap.put('ASI_CRM_JP_Taxable_Service_Charge__c', '1000');
            directSOFieldValueMap.put('ASI_CRM_Invoice_Date__c', Date.today());
            directSOFieldValueMap.put('ASI_CRM_Payment_Request_Date__c', Date.today().addMonths(2));
            directSOFieldValueMap.put('ASI_CRM_Remark__c', 'Testing Remark 1');
            directSOFieldValueMap.put('ASI_CRM_JP_Remark_2__c', 'Testing Remark 2');
            
            ASI_CRM_JP_Sales_Order__c directSO = ASI_CRM_JP_TestHelper.createSalesOrder(directSOFieldValueMap);
            insert directSO;
            
            test.startTest(); //WL 1.0
            
            Map<String, Object> salesOrderItemFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_ITEM_DEFAULT_VALUE_MAP;
            salesOrderItemFieldValueMap.put('ASI_CRM_Sales_Order__c', directSO.Id);
            salesOrderItemFieldValueMap.put('ASI_CRM_SKU__c', skuCodeList.get(0).Id);
            salesOrderItemFieldValueMap.put('ASI_CRM_Sys_Item_Availability_Filter__c', directSO.ASI_CRM_Branch_Plant__c);
            salesOrderItemFieldValueMap.put('ASI_CRM_JP_Sys_Lookup_Filter__c', 'ASI_CRM_JP_Manual_JDE_SO');
            ASI_CRM_JP_Sales_Order_Item__c salesOrderItem = ASI_CRM_JP_TestHelper.createSalesOrderLine(salesOrderItemFieldValueMap);
            insert salesOrderItem;
            
            PageReference pageRef = Page.ASI_CRM_JP_SO_PDF_Page;
            pageRef.getParameters().put(PDF_TYPE, 'Testing');
            pageRef.getParameters().put(SOID, directSO.Id);
            pageRef.getParameters().put(LANGUAGE, 'ja');
            Test.setCurrentPage(pageRef);
            
            ASI_CRM_JP_SO_PDF_Controller pdfCtrl = new ASI_CRM_JP_SO_PDF_Controller();
            
            ASI_CRM_JP_SOInvoice_ComCtrl jpInvoiceCtrl = new ASI_CRM_JP_SOInvoice_ComCtrl();
            jpInvoiceCtrl.salesOrderIdListStr = directSO.Id;
            jpInvoiceCtrl.pdfLanguage  = 'ja';
            Boolean jpInvoiceInitPage = jpInvoiceCtrl.isPageInit;
                        
            ASI_CRM_JP_SOInvoice_ComCtrl enInvoiceCtrl = new ASI_CRM_JP_SOInvoice_ComCtrl();
            enInvoiceCtrl.salesOrderIdListStr = directSO.Id;
            enInvoiceCtrl.pdfLanguage  = 'en';
            Boolean enInvoiceInitPage = enInvoiceCtrl.isPageInit;
            
            test.stopTest(); //WL 1.0
        }
    }
    
    public static testMethod void testOtherPDF() {
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c customer : [SELECT Id, RecordType.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c]) {
            customerMap.put(customer.RecordType.DeveloperName, customer);
        }
        
        ASI_CRM_Bill_To__c billTo = [SELECT Id FROM ASI_CRM_Bill_To__c LIMIT 1];
        
        Map<String, Object> userRoleFieldValueMap = ASI_CRM_JP_TestHelper.USER_ROLE_DEFAULT_VALUE_MAP;
        UserRole uRole = ASI_CRM_JP_TestHelper.createUserRole(userRoleFieldValueMap);
        insert uRole;
        
        Map<String, Object> userFieldValueMap = ASI_CRM_JP_TestHelper.USER_DEFAULT_VALUE_MAP;
        userFieldValueMap.put('UserRoleId', uRole.Id);
        userFieldValueMap.put('Street', 'Testing Address');
        userFieldValueMap.put('ASI_CRM_JP_Address_Local__c', 'Testing JP Address');
        User u = ASI_CRM_JP_TestHelper.createUser(userFieldValueMap);
        insert u;
        
        System.runAs(u) {
            Map<String, Object> dutyFreeSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
            dutyFreeSOFieldValueMap.put('ASI_CRM_Ship_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Ship_To').Id);
            dutyFreeSOFieldValueMap.put('ASI_CRM_Order_Type__c', 'Sample Sales');
            dutyFreeSOFieldValueMap.put('ASI_CRM_AP_Code__c', '3800');
            dutyFreeSOFieldValueMap.put('ASI_CRM_Branch_Plant__c', '421');
            dutyFreeSOFieldValueMap.put('ASI_CRM_Customer_PO_No__c', '1234');
            dutyFreeSOFieldValueMap.put('ASI_CRM_Mailing_Name__c', 'Testing');
            dutyFreeSOFieldValueMap.put('ASI_CRM_Postal_Code__c', '1234567');
            dutyFreeSOFieldValueMap.put('ASI_CRM_Address_Line_1__c', 'Testing');
            dutyFreeSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Duty_Free_SO'));
            ASI_CRM_JP_Sales_Order__c dutyFreeSO = ASI_CRM_JP_TestHelper.createSalesOrder(dutyFreeSOFieldValueMap);
            
            insert dutyFreeSO;
            
            ASI_CRM_JP_SOReceipt_ComCtrl jpReceiptCtrl = new ASI_CRM_JP_SOReceipt_ComCtrl();
            jpReceiptCtrl.salesOrderId = dutyFreeSO.Id;
            jpReceiptCtrl.pdfLanguage  = 'ja';
            Boolean jpReceiptInitPage = jpReceiptCtrl.isPageInit;
            
            ASI_CRM_JP_SOReceipt_ComCtrl enReceiptCtrl = new ASI_CRM_JP_SOReceipt_ComCtrl();
            enReceiptCtrl.salesOrderId = dutyFreeSO.Id;
            enReceiptCtrl.pdfLanguage  = 'en';
            Boolean enReceiptInitPage = enReceiptCtrl.isPageInit;
            
            ASI_CRM_JP_SODFDeliveryNote_ComCtrl jpOtherDeliveryNoteCtrl = new ASI_CRM_JP_SODFDeliveryNote_ComCtrl();
            jpOtherDeliveryNoteCtrl.salesOrderId = dutyFreeSO.Id;
            jpOtherDeliveryNoteCtrl.pdfLanguage  = 'ja';
            Boolean jpOtherDeliveryNoteInitPage = jpOtherDeliveryNoteCtrl.isPageInit;
            
            ASI_CRM_JP_SODFDeliveryNote_ComCtrl enOtherDeliveryNoteCtrl = new ASI_CRM_JP_SODFDeliveryNote_ComCtrl();
            enOtherDeliveryNoteCtrl.salesOrderId = dutyFreeSO.Id;
            enOtherDeliveryNoteCtrl.pdfLanguage  = 'en';
            Boolean enOtherDeliveryNoteInitPage = enOtherDeliveryNoteCtrl.isPageInit;
            
            ASI_CRM_JP_SOShippingRequest_ComCtrl jpShippingRequestCtrl = new ASI_CRM_JP_SOShippingRequest_ComCtrl();
            jpShippingRequestCtrl.salesOrderId = dutyFreeSO.Id;
            jpShippingRequestCtrl.pdfLanguage  = 'ja';
            Boolean jpShippingRequestInitPage = jpShippingRequestCtrl.isPageInit;
            
            ASI_CRM_JP_SOShippingRequest_ComCtrl enShippingRequestCtrl = new ASI_CRM_JP_SOShippingRequest_ComCtrl();
            enShippingRequestCtrl.salesOrderId = dutyFreeSO.Id;
            enShippingRequestCtrl.pdfLanguage  = 'en';
            Boolean enShippingRequestInitPage = enShippingRequestCtrl.isPageInit;
            
            /* [Kevin Choi] Added 2017-08-18; Test Class for ASI_CRM_JP_SOSalesContract_Ctrl*/
            ASI_CRM_JP_SOSalesContract_Ctrl jpSlaesContractCtrl = new ASI_CRM_JP_SOSalesContract_Ctrl();
            jpSlaesContractCtrl.salesOrderId = dutyFreeSO.Id;
            //jpSlaesContractCtrl
            Boolean jpSalesOrderInitPage = jpSlaesContractCtrl.isPageInit;
            
            /* [Kevin Choi] End Added 2017-08-18; Test Class for ASI_CRM_JP_SOSalesContract_Ctrl */
            
        }
    }
}