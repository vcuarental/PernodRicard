/*********************************************************************************
 * Name: ASI_CRM_SG_SalesOrderTransactionDT_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/05/2016       Laputa:Hugo             Created
 *              
*/
@isTest
private class ASI_CRM_SG_SalesOrderTransactionDT_Test {

    public static testmethod void testSalesOrderTransactionDTCls() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ASI SG Standard User'];
        
        User newUser = new User(
          profileId = p.Id,
            username = 'newUser1234@newUser1234.com',
            email = 'newUser@newUser.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias = 'nuser',
            lastname = 'user',
            ASI_Company_Name__c = 'TestCustomer',
            ASI_Outlet_Name__c = 'TestCustomerOutlet'
        );
        insert newUser;
        ASI_CRM_SG_TestClassHelper.wholesalesCustomerData customerD;
        ASI_CRM_SG_TestClassHelper.customerData customerOutletD;
        ASI_CRM_SG_TestClassHelper.salesOrderData salesOrderD;
        ASI_CRM_SG_TestClassHelper.salesOrderItemData salesOrderItemD;

        System.runAs(newUser){
            customerD = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(true, 'TestCustomer');
            customerOutletD = new ASI_CRM_SG_TestClassHelper.customerData(true, 'TestCustomerOutlet');
            salesOrderD = new ASI_CRM_SG_TestClassHelper.salesOrderData(true, 'ASI_CRM_SG_Wholesaler');
            salesOrderItemD = new ASI_CRM_SG_TestClassHelper.salesOrderItemData(true, 'ASI_CRM_SG_Wholesaler', salesOrderD.salesOrder);
        

            test.starttest();
            try {
                delete salesOrderItemD.salesOrderItem;
            } catch (Exception e) {
                
            }
            test.stoptest();
        
        }
    }

}