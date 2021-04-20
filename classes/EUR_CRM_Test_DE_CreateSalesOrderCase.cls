/*
    Test-class for EUR_CRM_DE_CreateSalesOrderCase functionality
    
    @author avi
    @copyright PARX
*/

@isTest
public class EUR_CRM_Test_DE_CreateSalesOrderCase 
{
    @isTest 
    static void test_EUR_CRM_DE_CreateSalesOrderCase()
    {
        List<RecordType> orderRecordTypeList = [SELECT Id FROM RecordType 
            WHERE DeveloperName = 'EUR_Direct' AND sObjectType = 'EUR_CRM_Sales_Order__c'];

        List<User> adminUserList = [SELECT Id FROM User WHERE Profile.Name = 'EUR System Admin' AND IsActive = true];

        if (adminUserList.isEmpty()) return;

        EUR_CRM_Sales_Order__c newSalesOrder = new EUR_CRM_Sales_Order__c(
            RecordTypeId = orderRecordTypeList[0].Id,
            EUR_CRM_Order_Status__c = 'Send To ERP',
            EUR_CRM_IsMobile__c = true
        );

        //run as admin user
        System.runAs(adminUserList[0]) 
        {
            EUR_CRM_Account__c testAccount = EUR_COMMON_TestUtils.createAccount('EUR DE On Trade New Business', 'Test DE Acc');
            newSalesOrder.EUR_CRM_Account__c = testAccount.Id;
        }
        insert newSalesOrder;

        List<Case> caseList = [SELECT Id FROM Case WHERE Status = 'Closed' AND Type = 'New Sales Order'];
        System.assert(!caseList.isEmpty(), 'Case was not created.');
    }
}