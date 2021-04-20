/**
 * Created by osman on 4.02.2021.
 */

@IsTest
private with sharing class EUR_TR_BulkProfitabilityDeleteContTest {

    @TestSetup
    static void setup() {

        EUR_TR_Account__c account = new EUR_TR_Account__c();
        account.Name = 'profit account';
        account.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        account.EUR_TR_Status__c = 'Aktif';
        account.EUR_TR_AccountCode__c = '8700';
        insert account;

        EUR_TR_AccountProfitability__c accountProfitability = new EUR_TR_AccountProfitability__c();
        accountProfitability.EUR_TR_RelatedAccount__c = account.Id;
        accountProfitability.EUR_TR_Year__c = '19';
        accountProfitability.EUR_TR_Quarter__c = 'Q1';
        accountProfitability.EUR_TR_ProfitAmount__c = 100;
        accountProfitability.EUR_TR_TotalAmount__c = 120;
        accountProfitability.RecordTypeId = Schema.SObjectType.EUR_TR_AccountProfitability__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_AccountProfitability').getRecordTypeId();
        insert accountProfitability;

    }

    @IsTest
    static void testDeleteRecords() {
        EUR_TR_BulkProfitabilityDeleteController.deleteRecords(1);
    }

    @IsTest
    static void testDeleteRecords_error() {
        try {
            EUR_TR_BulkProfitabilityDeleteController.deleteRecords(100001);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }

    @IsTest
    static void testDeleteRecords_error_more_than_one_batch() {
        try {
            EUR_TR_BulkProfitabilityDeleteController.deleteRecords(1);
            EUR_TR_BulkProfitabilityDeleteController.deleteRecords(1);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }

    @IsTest
    static void testCheckDeleteStatus() {
        Test.startTest();
        {
            EUR_TR_BulkProfitabilityDeleteController.checkDeleteStatus();
        }
        Test.stopTest();
    }


}