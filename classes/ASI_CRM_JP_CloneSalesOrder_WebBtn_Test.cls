/*********************************************************************************
 * Name: ASI_CRM_JP_CloneSalesOrder_Ctrl
 * Description: Controller class for cloning the Sales Order and Sales Order Item
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/06/2019       Wilson Chow             Created.  Remarks: Cannot test case 1: Sold To != Bill To, case 2: JDE not synced
*/

@isTest
public with sharing class ASI_CRM_JP_CloneSalesOrder_WebBtn_Test {

    @TestSetup
    public static void setupData() {
        ASI_CRM_JP_TestHelper.createRunningNumber();
    }

    @isTest
    static void testValidateBillTo1() {
        Map<String, Object> directSalesCustomerFieldValueMap = ASI_CRM_JP_TestHelper.DIRECT_SALES_CUSTOMER_DEFAULT_VALUE_MAP;
        directSalesCustomerFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.CUSTOMER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales_Customer'));
        ASI_CRM_AccountsAdditionalField__c directSalesCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesCustomerFieldValueMap);
        insert directSalesCustomer;

        Map<String, Object> directSalesBillToCustomerFieldValueMap = ASI_CRM_JP_TestHelper.BILL_TO_CUSTOMER_DEFAULT_VALUE_MAP;
        ASI_CRM_AccountsAdditionalField__c directSalesBillToCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesBillToCustomerFieldValueMap);
        insert directSalesBillToCustomer;

        ASI_CRM_Bill_To__c billTo = ASI_CRM_JP_TestHelper.createBillTo(directSalesCustomer.Id, directSalesBillToCustomer.Id);
        insert billTo;

        Map<String, Object> directSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
        directSOFieldValueMap.put('ASI_CRM_Sold_To__c', directSalesCustomer.Id);
        directSOFieldValueMap.put('ASI_CRM_JP_Bill_To__c', billTo.Id);
        directSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales'));

        directSOFieldValueMap.put('ASI_CRM_Payment_Option__c', 'COD');
        directSOFieldValueMap.put('ASI_CRM_JP_Taxable_Service_Charge__c', '1000');
        directSOFieldValueMap.put('ASI_CRM_Invoice_Date__c', Date.today());
        directSOFieldValueMap.put('ASI_CRM_Payment_Request_Date__c', Date.today().addMonths(2));

        ASI_CRM_JP_Sales_Order__c salesOrder1 = ASI_CRM_JP_TestHelper.createSalesOrder(directSOFieldValueMap);
        insert salesOrder1;

        billTo.ASI_CRM_JP_Active__c = false;
        update billTo;

        Test.startTest();
        ASI_CRM_JP_CloneSalesOrder_WebBtnCtrl.validateBillTo(salesOrder1.Id);
        Test.stopTest();
    }

    @isTest
    static void testValidateBillTo2() {
        Map<String, Object> directSalesCustomerFieldValueMap = ASI_CRM_JP_TestHelper.DIRECT_SALES_CUSTOMER_DEFAULT_VALUE_MAP;
        directSalesCustomerFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.CUSTOMER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales_Customer'));
        ASI_CRM_AccountsAdditionalField__c directSalesCustomer1 = ASI_CRM_JP_TestHelper.createCustomer(directSalesCustomerFieldValueMap);
        insert directSalesCustomer1;

        Map<String, Object> directSalesBillToCustomerFieldValueMap = ASI_CRM_JP_TestHelper.BILL_TO_CUSTOMER_DEFAULT_VALUE_MAP;
        ASI_CRM_AccountsAdditionalField__c directSalesBillToCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesBillToCustomerFieldValueMap);
        insert directSalesBillToCustomer;

        Map<String, Object> directSalesCustomerFieldValueMap2 = ASI_CRM_JP_TestHelper.DIRECT_SALES_CUSTOMER_DEFAULT_VALUE_MAP;
        directSalesCustomerFieldValueMap2.put('RecordTypeId', ASI_CRM_JP_TestHelper.CUSTOMER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales_Customer'));
        ASI_CRM_AccountsAdditionalField__c directSalesCustomer2 = ASI_CRM_JP_TestHelper.createCustomer(directSalesCustomerFieldValueMap2);
        insert directSalesCustomer2;

        ASI_CRM_Bill_To__c billTo = ASI_CRM_JP_TestHelper.createBillTo(directSalesCustomer2.Id, directSalesBillToCustomer.Id);
        insert billTo;

        Map<String, Object> directSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
        directSOFieldValueMap.put('ASI_CRM_Sold_To__c', directSalesCustomer2.Id);
        directSOFieldValueMap.put('ASI_CRM_JP_Bill_To__c', billTo.Id);
        directSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales'));

        directSOFieldValueMap.put('ASI_CRM_Payment_Option__c', 'COD');
        directSOFieldValueMap.put('ASI_CRM_JP_Taxable_Service_Charge__c', '1000');
        directSOFieldValueMap.put('ASI_CRM_Invoice_Date__c', Date.today());
        directSOFieldValueMap.put('ASI_CRM_Payment_Request_Date__c', Date.today().addMonths(2));

        ASI_CRM_JP_Sales_Order__c salesOrder2 = ASI_CRM_JP_TestHelper.createSalesOrder(directSOFieldValueMap);
        insert salesOrder2;

        Test.startTest();
        ASI_CRM_JP_CloneSalesOrder_WebBtnCtrl.validateBillTo(salesOrder2.Id);
        Test.stopTest();
    }

    @isTest
    static void testValidateBillTo3() {
        Test.startTest();
        ASI_CRM_JP_CloneSalesOrder_WebBtnCtrl.validateBillTo('');
        Test.stopTest();
    }
}