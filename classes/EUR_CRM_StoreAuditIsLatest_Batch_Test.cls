/**
 * Created by larsz on 8/12/2020.
 */

@IsTest
private class EUR_CRM_StoreAuditIsLatest_Batch_Test {
    @IsTest
    static void testBatch() {
        EUR_CRM_Account__c account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        insert account;
        EUR_CRM_Store_Audit__c audit1 = EUR_CRM_TestClassUtilityHelper.createStoreAudit(1, 'EUR_GB_Store_Audit', account.Id)[0];
        audit1.EUR_CRM_Audit_Datetime__c = Datetime.now();
        insert audit1;

        Test.startTest();
        Database.executeBatch(new EUR_CRM_StoreAuditIsLatest_Batch());
        Test.stopTest();

        audit1 = [SELECT Id, EUR_CRM_Status__c FROM EUR_CRM_Store_Audit__c];
        System.assertEquals(audit1.EUR_CRM_Status__c, EUR_CRM_StoreAuditIsLatest_Batch.FINISH_STATUS);
    }
}