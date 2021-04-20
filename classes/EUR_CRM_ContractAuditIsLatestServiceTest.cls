/**
 * Created by Ilarion Tokarskyi on 10/22/2020.
 */

@IsTest
private class EUR_CRM_ContractAuditIsLatestServiceTest {
    @IsTest
    static void testInsertContractAudit() {
        EUR_CRM_Account__c account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        insert account;
        account = [SELECT Id FROM EUR_CRM_Account__c];
        EUR_CRM_Contract__c contract = EUR_CRM_TestClassUtilityHelper.createContract(account.Id,
                EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract__c', 'EUR_GB_Contract'), Date.today(), Date.today().addDays(90));
        insert contract;
        contract = [SELECT Id FROM EUR_CRM_Contract__c LIMIT 1];
        EUR_CRM_Contract_Audit__c contractAudit1 = createContractAudit(contract.Id, 'EUR_GB_Contract_Audit');
        contractAudit1.EUR_CRM_Mobile_ID__c = 'External_ID_1';
        contractAudit1.EUR_CRM_Audit_Datetime__c = Date.today();
        contractAudit1.EUR_CRM_Status__c = EUR_CRM_ContractAuditIsLatestService.AUDIT_FINISHED_STATUS;
        insert contractAudit1;
        contractAudit1 = [SELECT Id, EUR_CRM_Is_Latest__c FROM EUR_CRM_Contract_Audit__c];

        System.assertEquals(true, contractAudit1.EUR_CRM_Is_Latest__c);

        Test.startTest();
        EUR_CRM_Contract_Audit__c contractAudit2 = createContractAudit(contract.Id, 'EUR_GB_Contract_Audit');
        contractAudit2.EUR_CRM_Mobile_ID__c = 'External_ID_2';
        contractAudit2.EUR_CRM_Audit_Datetime__c = Date.today().addDays(1);
        contractAudit2.EUR_CRM_Status__c = EUR_CRM_PriceAuditIsLatestService.AUDIT_FINISHED_STATUS;
        insert contractAudit2;
        Test.stopTest();

        contractAudit2 = [
                SELECT Id, EUR_CRM_Is_Latest__c
                FROM EUR_CRM_Contract_Audit__c
                WHERE EUR_CRM_Mobile_ID__c =
                        'External_ID_2'
        ];
        contractAudit1 = [
                SELECT Id, EUR_CRM_Is_Latest__c
                FROM EUR_CRM_Contract_Audit__c
                WHERE EUR_CRM_Mobile_ID__c = 'External_ID_1'
        ];

        System.assertEquals(true, contractAudit2.EUR_CRM_Is_Latest__c);
        System.assertEquals(false, contractAudit1.EUR_CRM_Is_Latest__c);
    }

    private static EUR_CRM_Contract_Audit__c createContractAudit(Id contrId, String recordTypeName) {
        return new EUR_CRM_Contract_Audit__c(EUR_CRM_Contract__c = contrId, RecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract_Audit__c', recordTypeName));
    }
}