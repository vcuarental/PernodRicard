/*********************************************************************************
 * Name: ASI_CRM_JP_CustomerTriggerTest
 * Description: Test class for all customer trigger
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/07/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_JP_CustomerTriggerTest {
    
    @TestSetup
    public static void setupData() {
        ASI_CRM_JP_TestHelper.createRunningNumber();
   		ASI_CRM_JP_TestHelper.createApprovalRoute();
        
        Map<String, Object> postalCodeFieldValueMap = ASI_CRM_JP_TestHelper.POSTAL_CODE_DEFAULT_VALUE_MAP;
        ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestHelper.createPostalCode(postalCodeFieldValueMap);
        insert postalCode;
    }
    
    public static testMethod void testTrigger() {
        Map<String, Object> directSalesCustomerFieldValueMap = ASI_CRM_JP_TestHelper.DIRECT_SALES_CUSTOMER_DEFAULT_VALUE_MAP;
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
    }
}