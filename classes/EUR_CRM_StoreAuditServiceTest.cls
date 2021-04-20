/**
 * Created by Ilarion Tokarskyi on 03.06.2020.
 */

@IsTest
private class EUR_CRM_StoreAuditServiceTest {
    @IsTest
    static void testInsertStoreAuditsWithoutItems() {
        EUR_CRM_Account__c account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        insert account;
        account = [SELECT Id FROM EUR_CRM_Account__c];
        EUR_CRM_Store_Audit__c audit1 = EUR_CRM_TestClassUtilityHelper.createStoreAudit(1, 'EUR_GB_Store_Audit', account.Id)[0];
        audit1.EUR_CRM_External_ID__c = 'External_ID_1';
        audit1.EUR_CRM_Audit_Datetime__c = Date.today();
        audit1.EUR_CRM_Status__c = EUR_CRM_StoreAuditService.AUDIT_FINISHED_STATUS;
        insert audit1;
        audit1 = [SELECT Id, EUR_CRM_Is_Latest__c FROM EUR_CRM_Store_Audit__c];

        System.assertEquals(true, audit1.EUR_CRM_Is_Latest__c);

        Test.startTest();
        EUR_CRM_Store_Audit__c audit2 = EUR_CRM_TestClassUtilityHelper.createStoreAudit(1, 'EUR_GB_Store_Audit', account.Id)[0];
        audit2.EUR_CRM_External_ID__c = 'External_ID_2';
        audit2.EUR_CRM_Audit_Datetime__c = Date.today().addDays(1);
        audit2.EUR_CRM_Status__c = EUR_CRM_StoreAuditService.AUDIT_FINISHED_STATUS;
        insert audit2;
        Test.stopTest();

        audit2 = [
                SELECT Id, EUR_CRM_Is_Latest__c
                FROM EUR_CRM_Store_Audit__c
                WHERE EUR_CRM_External_ID__c =
                        'External_ID_2'
        ];
        audit1 = [
                SELECT Id, EUR_CRM_Is_Latest__c
                FROM EUR_CRM_Store_Audit__c
                WHERE EUR_CRM_External_ID__c = 'External_ID_1'
        ];

        System.assertEquals(true, audit2.EUR_CRM_Is_Latest__c);
        System.assertEquals(false, audit1.EUR_CRM_Is_Latest__c);
    }
}