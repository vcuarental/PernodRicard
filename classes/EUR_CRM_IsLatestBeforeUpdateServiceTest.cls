/**
 * Created by Ilarion Tokarskyi on 04.11.2020.
 */

@IsTest
private class EUR_CRM_IsLatestBeforeUpdateServiceTest {
    @TestSetup
    static void setup() {
        EUR_CRM_Account__c account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1,'EUR_DE_On_Trade_Wholesaler')[0];
        insert account;
        account = [SELECT EUR_CRM_Country_Code__c FROM EUR_CRM_Account__c LIMIT 1];
        System.debug('COUNRY CODE ' + account.EUR_CRM_Country_Code__c);
        List<EUR_CRM_Store_Audit__c> storeAudits = EUR_CRM_TestClassUtilityHelper.createStoreAudit(2,
                'EUR_DE_Wholesaler_Store_Audit', account.Id);
        storeAudits[0].EUR_CRM_Status__c = 'In progress';
        storeAudits[0].EUR_CRM_Audit_Datetime__c = Date.today().addDays(2);
        storeAudits[1].EUR_CRM_Status__c = 'Finished';
        storeAudits[1].EUR_CRM_Audit_Datetime__c = Date.today();
        insert storeAudits;

        EUR_CRM_Visit__c visit = EUR_CRM_TestClassUtilityHelper.createVisit('EUR_DE_Off_Trade_Visit',account.Id);
        insert visit;
        update visit;

        EUR_CRM_Price_Audit__c priceAudit = makePA('EUR_DE_Off_Trade_Price_Audit', account.Id);
        insert priceAudit;
        update priceAudit;

        EUR_CRM_POSM_Audit__c posmAudit = makePOSM_Audit('EUR_DB_POSM_Audit', account.Id);
        insert posmAudit;
        update posmAudit;
    }

    @IsTest
    static void testUpdateStatusOnStoreAudit() {
        EUR_CRM_Store_Audit__c storeAudit = [SELECT EUR_CRM_Is_Latest__c, EUR_CRM_Status__c FROM
                EUR_CRM_Store_Audit__c WHERE EUR_CRM_Is_Latest__c = TRUE LIMIT 1];
        System.assertEquals('Finished', storeAudit.EUR_CRM_Status__c);

        Test.startTest();
        storeAudit = [SELECT Id FROM EUR_CRM_Store_Audit__c WHERE EUR_CRM_Status__c = 'In progress' LIMIT 1];
        storeAudit.EUR_CRM_Status__c = 'Finished';
        update storeAudit;
        Test.stopTest();

        storeAudit = [SELECT EUR_CRM_Is_Latest__c FROM EUR_CRM_Store_Audit__c WHERE Id =: storeAudit.Id];
        System.assertEquals(true, storeAudit.EUR_CRM_Is_Latest__c);
    }

    private static EUR_CRM_Price_Audit__c makePA(String rt, Id accId) {
        Id rtId = SObjectType.EUR_CRM_Price_Audit__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Price_Audit__c(
                RecordTypeId = rtId
                ,   EUR_CRM_Account__c = accId
        );
    }

    private static EUR_CRM_POSM_Audit__c makePOSM_Audit(String rt, Id accId) {
        Id rtId = SObjectType.EUR_CRM_POSM_Audit__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_POSM_Audit__c(
                RecordTypeId = rtId
                , EUR_CRM_Account__c = accId
        );
    }
}