/*********************************************************************************
* Name: ASI_CRM_JP_SORedirect_CtrlTest
* Description: Test class for ASI_CRM_JP_SORedirect_Controller
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 11/07/2017       Hugo Cheung             Created          
* 18/03/2020       Wilken Lee              [WL 1.0] Increase test class coverage
*/
@isTest
public class ASI_CRM_JP_SORedirect_CtrlTest {
    
    private final static String SALES_ORDER_ID  = 'salesOrderId';
    private final static String RECORD_TYPE_KEY = 'RecordType';
    private final static String SHIP_TO_KEY     = 'ASI_CRM_Ship_To__c';
    private final static String SOLD_TO_KEY     = 'ASI_CRM_Sold_To__c';
    private final static String TEMPLATE_ID     = 'templateId';
    
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
		directSalesShipToCustomer.ASI_CRM_CN_Inactive_Flag__c = false; //WL 1.0. There is Workflow Rule which set inactive when customer is created. So need to use Update
		update directSalesShipToCustomer;
		       
        Map<String, Object> directSalesBillToCustomerFieldValueMap = ASI_CRM_JP_TestHelper.BILL_TO_CUSTOMER_DEFAULT_VALUE_MAP;
        ASI_CRM_AccountsAdditionalField__c directSalesBillToCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesBillToCustomerFieldValueMap);
        insert directSalesBillToCustomer;
        
        insert ASI_CRM_JP_TestHelper.createBillTo(directSalesCustomer.Id, directSalesBillToCustomer.Id);
        
        Map<String, Object> advancedSearchFieldValueMap = ASI_CRM_JP_TestHelper.ADVANCED_SEARCH_DEFAULT_VALUE_MAP;
        advancedSearchFieldValueMap.put('ASI_Ship_To_Customer__c', directSalesShipToCustomer.Id);
        advancedSearchFieldValueMap.put('ASI_Sold_To_Customer__c', directSalesCustomer.Id);
        ASI_CRM_JP_Advanced_Search__c advancedSearch = ASI_CRM_JP_TestHelper.createAdvancedSearch(advancedSearchFieldValueMap);
        insert advancedSearch;
    }
    
    public static testMethod void createNormalSalesOrder() {
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c customer : [SELECT Id, RecordType.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c]) {
            customerMap.put(customer.RecordType.DeveloperName, customer);
        }
        
        PageReference pageRef = Page.ASI_CRM_JP_SORedirect_Page;
        pageRef.getParameters().put(RECORD_TYPE_KEY, 'ASI_CRM_JP_Normal_SO');
        pageRef.getParameters().put(SOLD_TO_KEY, customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
        Test.setCurrentPage(pageRef);
        
        ASI_CRM_JP_SORedirect_Controller soRedirectController = new ASI_CRM_JP_SORedirect_Controller();
        soRedirectController.redirectPage();
    }
    
    public static testMethod void createDirectSalesOrder() {
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c customer : [SELECT Id, RecordType.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c]) {
            customerMap.put(customer.RecordType.DeveloperName, customer);
        }
        
        PageReference pageRef = Page.ASI_CRM_JP_SORedirect_Page;
        pageRef.getParameters().put(RECORD_TYPE_KEY, 'ASI_CRM_JP_Direct_Sales');
        pageRef.getParameters().put(SHIP_TO_KEY, customerMap.get('ASI_CRM_JP_Direct_Sales_Ship_To').Id);
        pageRef.getParameters().put(SOLD_TO_KEY, customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
        Test.setCurrentPage(pageRef);

        /*
        ASI_CRM_JP_Sales_Order__c salesOrder = new ASI_CRM_JP_Sales_Order__c();
        insert salesOrder;
        */

        ASI_CRM_Bill_To__c billTo = [SELECT Id FROM ASI_CRM_Bill_To__c LIMIT 1];

        Map<String, Object> directSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
        directSOFieldValueMap.put('ASI_CRM_Sold_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
		directSOFieldValueMap.put('ASI_CRM_Ship_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Ship_To').Id); //WL 1.0
        directSOFieldValueMap.put('ASI_CRM_JP_Bill_To__c', billTo.Id);
        directSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales'));

        directSOFieldValueMap.put('ASI_CRM_Payment_Option__c', 'COD');
        directSOFieldValueMap.put('ASI_CRM_JP_Taxable_Service_Charge__c', '1000');
        directSOFieldValueMap.put('ASI_CRM_Invoice_Date__c', Date.today());
        directSOFieldValueMap.put('ASI_CRM_Payment_Request_Date__c', Date.today().addMonths(2));

        ASI_CRM_JP_Sales_Order__c salesOrder = ASI_CRM_JP_TestHelper.createSalesOrder(directSOFieldValueMap);
        insert salesOrder;
        
        Map<String, String> params = new Map<String, String>();        
        ASI_CRM_JP_SORedirect_Controller soRedirectController = new ASI_CRM_JP_SORedirect_Controller();
        soRedirectController.createSalesOrder(params);
        soRedirectController.deleteSalesOrder(salesOrder.Id, 'Direct Sales');
    }
	
	/*[WL 1.0] BEGIN*/
	public static testMethod void createDirectSalesOrder_WithParam() {
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c customer : [SELECT Id, RecordType.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c]) {
            customerMap.put(customer.RecordType.DeveloperName, customer);
        }
       
        ASI_CRM_Bill_To__c billTo = [SELECT Id FROM ASI_CRM_Bill_To__c LIMIT 1];

        Map<String, Object> directSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
        directSOFieldValueMap.put('ASI_CRM_Sold_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
		directSOFieldValueMap.put('ASI_CRM_Ship_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Ship_To').Id); //WL 1.0
        directSOFieldValueMap.put('ASI_CRM_JP_Bill_To__c', billTo.Id);
        directSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales'));

        directSOFieldValueMap.put('ASI_CRM_Payment_Option__c', 'COD');
        directSOFieldValueMap.put('ASI_CRM_JP_Taxable_Service_Charge__c', '1000');
        directSOFieldValueMap.put('ASI_CRM_Invoice_Date__c', Date.today());
        directSOFieldValueMap.put('ASI_CRM_Payment_Request_Date__c', Date.today().addMonths(2));

        ASI_CRM_JP_Sales_Order__c salesOrder = ASI_CRM_JP_TestHelper.createSalesOrder(directSOFieldValueMap);
        insert salesOrder;
        
		        PageReference pageRef = Page.ASI_CRM_JP_SORedirect_Page;
        pageRef.getParameters().put(RECORD_TYPE_KEY, 'ASI_CRM_JP_Direct_Sales');
        pageRef.getParameters().put(SHIP_TO_KEY, customerMap.get('ASI_CRM_JP_Direct_Sales_Ship_To').Id);
        pageRef.getParameters().put(SOLD_TO_KEY, customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
		pageRef.getParameters().put('RecordType', 'Direct Sales SO');
        Test.setCurrentPage(pageRef);
		
        ASI_CRM_JP_SORedirect_Controller soRedirectController = new ASI_CRM_JP_SORedirect_Controller();
        soRedirectController.redirectPage();
                
    }
	/*[WL 1.0] END*/
    
    public static testMethod void testDeleteSalesOrder() {
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c customer : [SELECT Id, RecordType.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c]) {
            customerMap.put(customer.RecordType.DeveloperName, customer);
        }
        
        PageReference pageRef = Page.ASI_CRM_JP_SORedirect_Page;
        pageRef.getParameters().put(RECORD_TYPE_KEY, 'ASI_CRM_JP_Direct_Sales');
        pageRef.getParameters().put(SHIP_TO_KEY, customerMap.get('ASI_CRM_JP_Direct_Sales_Ship_To').Id);
        pageRef.getParameters().put(SOLD_TO_KEY, customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
        Test.setCurrentPage(pageRef);
        
        ASI_CRM_JP_SORedirect_Controller soRedirectController = new ASI_CRM_JP_SORedirect_Controller();
        
        
        
        
        Map<String, String> params = new Map<String, String>();

        ASI_CRM_Bill_To__c billTo = [SELECT Id FROM ASI_CRM_Bill_To__c LIMIT 1];

        Map<String, Object> directSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
        directSOFieldValueMap.put('ASI_CRM_Sold_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
        directSOFieldValueMap.put('ASI_CRM_JP_Bill_To__c', billTo.Id);
        directSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales'));

        directSOFieldValueMap.put('ASI_CRM_Payment_Option__c', 'COD');
        directSOFieldValueMap.put('ASI_CRM_JP_Taxable_Service_Charge__c', '1000');
        directSOFieldValueMap.put('ASI_CRM_Invoice_Date__c', Date.today());
        directSOFieldValueMap.put('ASI_CRM_Payment_Request_Date__c', Date.today().addMonths(2));

        ASI_CRM_JP_Sales_Order__c salesOrder = ASI_CRM_JP_TestHelper.createSalesOrder(directSOFieldValueMap);
        insert salesOrder;
        
        
        soRedirectController.createSalesOrder(params);
        soRedirectController.deleteSalesOrder(salesOrder.Id, 'Direct Sales');
    }
    
    public static testMethod void createWithTemplate() {
        ASI_CRM_JP_Advanced_Search__c advancedSearch = [SELECT Id FROM ASI_CRM_JP_Advanced_Search__c LIMIT 1];
        PageReference pageRef = Page.ASI_CRM_JP_SORedirect_Page;
        pageRef.getParameters().put(RECORD_TYPE_KEY, 'ASI_CRM_JP_Normal_SO');
        pageRef.getParameters().put(TEMPLATE_ID, advancedSearch.Id);
        Test.setCurrentPage(pageRef);
        Map<String, String> params = new Map<String, String>();
        
        ASI_CRM_JP_Advanced_Search__c Adv = new ASI_CRM_JP_Advanced_Search__c();
        insert Adv;

        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                .getRecordTypeInfosByName()
                .get('Wholesaler (SG)').getRecordTypeId();

        ASI_CRM_AccountsAdditionalField__c cust =
                new ASI_CRM_AccountsAdditionalField__c(Name = 'TestCustomer',
                        RecordTypeId = customerRecTypeId);
        insert cust;
        
        Id RecordTypeId1 = Schema.SObjectType.ASI_CRM_JP_Sales_Order__c.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId();
        ASI_CRM_JP_Sales_Order__c salesOrder = new ASI_CRM_JP_Sales_Order__c();
        salesOrder.RecordTypeId = RecordTypeId1;
        insert salesOrder;
        
        ASI_CRM_Pay_To__c Payto = new ASI_CRM_Pay_To__c();
        insert Payto;
        
        ASI_CRM_JP_SORedirect_Controller soRedirectController = new ASI_CRM_JP_SORedirect_Controller();
        soRedirectController.createSalesOrder(params);
        soRedirectController.deleteSalesOrder(salesOrder.Id, 'Direct Sales');
        soRedirectController.assignSalesGroup(salesOrder);
        soRedirectController.retrievePrimaryPayTo();
        soRedirectController.createSalesOrder(Adv.id);
        soRedirectController.retrievePrimaryBillTo(cust.id);
    }
    
}