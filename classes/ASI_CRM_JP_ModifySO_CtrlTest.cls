/*********************************************************************************
 * Name: ASI_CRM_JP_ModifySO_CtrlTest
 * Description: Test class for ASI_CRM_JP_ModifySO_Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/07/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_JP_ModifySO_CtrlTest {
    
    private final static String RECORD_TYPE      = 'recordType';
	private final static String SALES_ORDER_JSON = 'salesOrderJson';
    private final static String CUSTOMER_ID      = 'customerId';
    
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
    }
    
    public static testMethod void testCtrl() {
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_AccountsAdditionalField__c customer : [SELECT Id, RecordType.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c]) {
        	customerMap.put(customer.RecordType.DeveloperName, customer);
        }
        
        PageReference pageRef = Page.ASI_CRM_JP_ModifySO_Page;
        pageRef.getParameters().put(RECORD_TYPE, 'ASI_CRM_JP_Normal_SO');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new ASI_CRM_JP_Sales_Order__c());
        ASI_CRM_JP_ModifySO_Controller modifySOCtrl = new ASI_CRM_JP_ModifySO_Controller(sc);
        pageRef.getParameters().put(SALES_ORDER_JSON, modifySOCtrl.salesOrderWrapperJson);
        pageRef.getParameters().put(CUSTOMER_ID, customerMap.get('ASI_CRM_JP_Direct_Sales_Ship_To').Id);
        modifySOCtrl.assignShipToDefaultValue();
        pageRef.getParameters().put(SALES_ORDER_JSON, modifySOCtrl.salesOrderWrapperJson);
        pageRef.getParameters().put(CUSTOMER_ID, customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
        modifySOCtrl.assignSoldToDefaultValue();
        modifySOCtrl.save();
        modifySOCtrl.cancel();
    }
}