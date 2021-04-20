/*********************************************************************************
 * Name: ASI_CRM_JP_AdvancedSearchCtrlTest
 * Description: Test class for ASI_CRM_JP_AdvancedSearchController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/07/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_JP_AdvancedSearchCtrlTest {
    
    private final static String DEFAULT_CUSTOMER_NAME  = 'defaultCustomerName';
    private final static String CUSTOMER_NAME          = 'customerName';
    private final static String TEMPLATE_ID            = 'templateId';
    
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
    
    public static testMethod void testCtrl() {
        PageReference pageRef = Page.ASI_CRM_JP_AdvancedSearchPage;
        pageRef.getParameters().put(DEFAULT_CUSTOMER_NAME, 'Testing');
        Test.setCurrentPage(pageRef);
        
        ASI_CRM_JP_AdvancedSearchController advanceSearchCtrl = new ASI_CRM_JP_AdvancedSearchController();
        pageRef.getParameters().put(CUSTOMER_NAME, 'Testing');
        advanceSearchCtrl.search();
        advanceSearchCtrl.createNewSalesOrder();
        
    	ASI_CRM_JP_Advanced_Search__c advancedSearch = [SELECT Id FROM ASI_CRM_JP_Advanced_Search__c LIMIT 1];
        pageRef.getParameters().put(TEMPLATE_ID, advancedSearch.Id);
        advanceSearchCtrl.selectSalesOrderTemplate();
    }
}