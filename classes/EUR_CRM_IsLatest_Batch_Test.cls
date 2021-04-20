/**
 * Created by Ilarion Tokarskyi on 10/21/2020.
 */

@IsTest
private class EUR_CRM_IsLatest_Batch_Test {
    @TestSetup
    static void setup() {
        List<EUR_CRM_Account__c> accounts = EUR_CRM_TestClassUtilityHelper.createAccountsEU(2, 'GB FS Indirect');
        insert accounts;
        accounts = [SELECT Id FROM EUR_CRM_Account__c];
        List<EUR_CRM_Store_Audit__c> storeAuditsForFirstAccount = EUR_CRM_TestClassUtilityHelper.createStoreAudit(2,
                'EUR_GB_Store_Audit', accounts[0].Id);
        storeAuditsForFirstAccount[0].EUR_CRM_Audit_Datetime__c = Date.today();
        storeAuditsForFirstAccount[1].EUR_CRM_Audit_Datetime__c = Date.today().addDays(2);
        storeAuditsForFirstAccount[1].EUR_CRM_External_ID__c = 'External_Store_Audit_1';
        List<EUR_CRM_Store_Audit__c> storeAuditsForSecondAccount = EUR_CRM_TestClassUtilityHelper.createStoreAudit(2,
                'EUR_GB_Store_Audit', accounts[1].Id);
        storeAuditsForSecondAccount[0].EUR_CRM_Audit_Datetime__c = Date.today();
        storeAuditsForSecondAccount[1].EUR_CRM_Audit_Datetime__c = Date.today().addDays(2);
        storeAuditsForSecondAccount[1].EUR_CRM_External_ID__c = 'External_Store_Audit_2';
        insert storeAuditsForFirstAccount;
        insert storeAuditsForSecondAccount;
        EUR_CRM_Contract__c contractForFirstAccount1 = EUR_CRM_TestClassUtilityHelper.createContract(accounts[0].Id,
                EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract__c', 'EUR_GB_Contract'), Date.today(), Date.today().addDays(90));
        EUR_CRM_Contract__c contractForFirstAccount2 = EUR_CRM_TestClassUtilityHelper.createContract(accounts[0].Id,
                EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract__c', 'EUR_GB_Contract'), Date.today(), Date.today().addDays(90));
        insert new List<EUR_CRM_Contract__c>{
                contractForFirstAccount1, contractForFirstAccount2
        };
        List<EUR_CRM_Contract__c> contracts = [SELECT Id FROM EUR_CRM_Contract__c];
        List<EUR_CRM_Contract_Audit__c> contractAudits1 = createContractAudits(contracts[0].Id,
                'EUR_GB_Contract_Audit', 2);
        List<EUR_CRM_Contract_Audit__c> contractAudits2 = createContractAudits(contracts[1].Id,
                'EUR_GB_Contract_Audit', 2);
        insert contractAudits1;
        insert contractAudits2;
    }
    
    @IsTest
    static void testStoreAuditsBatch() {
        Test.startTest();
        Database.executeBatch(new EUR_CRM_IsLatest_Batch('EUR_CRM_Store_Audit__c'));
        Test.stopTest();
        List<EUR_CRM_Store_Audit__c> storeAudits = [
                SELECT EUR_CRM_Is_Latest__c, EUR_CRM_Status__c
                FROM
                        EUR_CRM_Store_Audit__c
                WHERE EUR_CRM_Is_Latest__c = TRUE AND EUR_CRM_Status__c = 'Finished'
        ];
        System.assertEquals(2, storeAudits.size());
    }

    @IsTest
    static void testContractAuditsBatch() {
        Test.startTest();
        Database.executeBatch(new EUR_CRM_IsLatest_Batch('EUR_CRM_Contract_Audit__c'));
        Test.stopTest();
        List<EUR_CRM_Contract_Audit__c> contractAudits = [
                SELECT EUR_CRM_Is_Latest__c, EUR_CRM_Status__c
                FROM
                        EUR_CRM_Contract_Audit__c
                WHERE EUR_CRM_Is_Latest__c = TRUE AND EUR_CRM_Status__c = 'Finished'
        ];
        update contractAudits;
        System.assertEquals(2, contractAudits.size());
    }

    private static List<EUR_CRM_Contract_Audit__c> createContractAudits(Id contrId, String recordTypeName, Integer
            numberOfRecords) {
        List<EUR_CRM_Contract_Audit__c> result = new List<EUR_CRM_Contract_Audit__c>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            result.add(new EUR_CRM_Contract_Audit__c(EUR_CRM_Contract__c = contrId, RecordTypeId =
                    EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract_Audit__c', recordTypeName)));
        }
        return result;
    }
}