/**
 * Created by Ilarion Tokarskyi on 03.06.2020.
 */

@IsTest
public with sharing class EUR_CRM_StoreAuditItemServiceTest {
    @IsTest
    static void testInsertAuditsWithItems() {
        EUR_CRM_Account__c account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        insert account;
        account = [SELECT Id FROM EUR_CRM_Account__c];

        EUR_CRM_Store_Audit__c audit1 = EUR_CRM_TestClassUtilityHelper.createStoreAudit(1, 'EUR_GB_Store_Audit', account.Id)[0];
        audit1.EUR_CRM_External_ID__c = 'External_ID_1';
        insert audit1;

        audit1 = [
                SELECT Id, EUR_CRM_Is_Latest__c
                FROM EUR_CRM_Store_Audit__c
        ];
        List<EUR_CRM_Store_Audit_Item__c> items1 = EUR_CRM_TestClassUtilityHelper.createStoreAuditItem(2, 'EUR_GB_FS_Store_Audit', audit1.Id);
        insert items1;

        Test.startTest();

        EUR_CRM_Store_Audit__c audit2 = EUR_CRM_TestClassUtilityHelper.createStoreAudit(1, 'EUR_GB_Store_Audit', account.Id)[0];
        audit2.EUR_CRM_External_ID__c = 'External_ID_2';
        insert audit2;
        audit2 = [
                SELECT Id, EUR_CRM_Is_Latest__c
                FROM EUR_CRM_Store_Audit__c
                WHERE EUR_CRM_External_ID__c = 'External_ID_2'
        ];

        List<EUR_CRM_Store_Audit_Item__c> items2 = EUR_CRM_TestClassUtilityHelper.createStoreAuditItem(2, 'EUR_GB_FS_Store_Audit', audit2.Id);
        insert items2;

        Test.stopTest();

        List<EUR_CRM_Store_Audit_Item__c> items = [
                SELECT EUR_CRM_Is_Latest__c, EUR_CRM_Store_Audit__c
                FROM EUR_CRM_Store_Audit_Item__c
        ];

        for (EUR_CRM_Store_Audit_Item__c item : items) {
            if (item.EUR_CRM_Store_Audit__c == audit1.Id) {
                System.assertEquals(false, item.EUR_CRM_Is_Latest__c);
            } else {
                System.assertEquals(true, item.EUR_CRM_Is_Latest__c);
            }
        }
    }
}