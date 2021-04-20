/**
 * Created by Ilarion Tokarskyi on 10/22/2020.
 */

@IsTest
private class EUR_CRM_PosmAuditIsLatestServiceTest {
    @IsTest
    static void testInsertPosmAudit() {
        EUR_CRM_Account__c account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        insert account;
        account = [SELECT Id FROM EUR_CRM_Account__c];
        EUR_CRM_POSM_Audit__c priceAudit1 = createPosmAudit(account.Id, 'EUR_IDL_POSM_Audit');
        priceAudit1.EUR_CRM_Mobile_Id__c = 'External_ID_1';
        priceAudit1.EUR_CRM_Audit_Datetime__c = Date.today();
        priceAudit1.EUR_CRM_Status__c = EUR_CRM_Visit_IsLatest_Service.VISIT_FINISHED_STATUS;
        insert priceAudit1;
        priceAudit1 = [SELECT Id, EUR_CRM_Is_Latest__c FROM EUR_CRM_POSM_Audit__c];

        System.assertEquals(true, priceAudit1.EUR_CRM_Is_Latest__c);

        Test.startTest();
        EUR_CRM_POSM_Audit__c priceAudit2 = createPosmAudit(account.Id, 'EUR_IDL_POSM_Audit');
        priceAudit2.EUR_CRM_Mobile_Id__c = 'External_ID_2';
        priceAudit2.EUR_CRM_Audit_Datetime__c = Date.today().addDays(1);
        priceAudit2.EUR_CRM_Status__c = EUR_CRM_PosmAuditIsLatestService.AUDIT_FINISHED_STATUS;
        insert priceAudit2;
        Test.stopTest();

        priceAudit2 = [
                SELECT Id, EUR_CRM_Is_Latest__c
                FROM EUR_CRM_POSM_Audit__c
                WHERE EUR_CRM_Mobile_Id__c =
                        'External_ID_2'
        ];
        priceAudit1 = [
                SELECT Id, EUR_CRM_Is_Latest__c
                FROM EUR_CRM_POSM_Audit__c
                WHERE EUR_CRM_Mobile_Id__c = 'External_ID_1'
        ];

        System.assertEquals(true, priceAudit2.EUR_CRM_Is_Latest__c);
        System.assertEquals(false, priceAudit1.EUR_CRM_Is_Latest__c);
    }

    private static EUR_CRM_POSM_Audit__c createPosmAudit(Id accId, String recordTypeName) {
        return new EUR_CRM_POSM_Audit__c(EUR_CRM_Account__c = accId, RecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_POSM_Audit__c', recordTypeName));
    }
}