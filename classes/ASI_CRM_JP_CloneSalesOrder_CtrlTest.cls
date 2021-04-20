/*********************************************************************************
 * Name: ASI_CRM_JP_CloneSalesOrder_CtrlTest
 * Description: Test class for cloning sales order
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/07/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_JP_CloneSalesOrder_CtrlTest {
    
    private final static String SALES_ORDER_ID = 'id';
    private final static String IS_CLONE_CHILD = 'cloneChild';
    
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
        
        ASI_CRM_Bill_To__c billTo = [SELECT Id FROM ASI_CRM_Bill_To__c LIMIT 1];
        
        Map<String, Object> userRoleFieldValueMap = ASI_CRM_JP_TestHelper.USER_ROLE_DEFAULT_VALUE_MAP;
        UserRole uRole = ASI_CRM_JP_TestHelper.createUserRole(userRoleFieldValueMap);
        insert uRole;
        
        Map<String, Object> userFieldValueMap = ASI_CRM_JP_TestHelper.USER_DEFAULT_VALUE_MAP;
        userFieldValueMap.put('UserRoleId', uRole.Id);
        User u = ASI_CRM_JP_TestHelper.createUser(userFieldValueMap);
        insert u;
        
        System.runAs(u) {
            Map<String, Object> directSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
//            directSOFieldValueMap.put('ASI_CRM_Ship_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Ship_To').Id);
            directSOFieldValueMap.put('ASI_CRM_Sold_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
            directSOFieldValueMap.put('ASI_CRM_JP_Bill_To__c', billTo.Id);
            directSOFieldValueMap.put('ASI_CRM_Salesman__c', u.Id);
            directSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales'));

            directSOFieldValueMap.put('ASI_CRM_Payment_Option__c', 'COD');
            directSOFieldValueMap.put('ASI_CRM_JP_Taxable_Service_Charge__c', '1000');
            directSOFieldValueMap.put('ASI_CRM_Invoice_Date__c', Date.today());
            directSOFieldValueMap.put('ASI_CRM_Payment_Request_Date__c', Date.today().addMonths(2));

            ASI_CRM_JP_Sales_Order__c directSO = ASI_CRM_JP_TestHelper.createSalesOrder(directSOFieldValueMap);
            insert directSO;

            /*
            ASI_CRM_JP_Sales_Order__c directSO = new ASI_CRM_JP_Sales_Order__c();
            insert directSO;
            */
            
            PageReference pageRef = Page.ASI_CRM_JP_CloneSalesOrder_Page;
            pageRef.getParameters().put(SALES_ORDER_ID, directSO.Id);
            pageRef.getParameters().put(IS_CLONE_CHILD, 'true');
            Test.setCurrentPage(pageRef);
            
            ASI_CRM_JP_CloneSalesOrder_Ctrl cloneSalesOrderCtrl = new ASI_CRM_JP_CloneSalesOrder_Ctrl();
            Test.startTest();
            cloneSalesOrderCtrl.cloneRecord();
            Test.stopTest();
        }
    }
}