/**
 * Created by osman on 21.01.2021.
 */

@IsTest
public with sharing class EUR_TR_AccountProfitabilityTriggerTest {

    @TestSetup
    static void setup() {

        EUR_TR_Account__c account = new EUR_TR_Account__c();
        account.Name = 'test acc 1';
        account.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        account.EUR_TR_Status__c = 'Aktif';
        account.EUR_TR_AccountCode__c = '87995';
        insert account;

    }

    @IsTest
    static void testBeforeInsert() {

        EUR_TR_Account__c account = getAccount();
        Test.startTest();
        {
            EUR_TR_AccountProfitability__c accountProfitability = new EUR_TR_AccountProfitability__c();
            accountProfitability.EUR_TR_RelatedAccount__c = account.Id;
            accountProfitability.EUR_TR_Year__c = '19';
            accountProfitability.EUR_TR_Quarter__c = 'Q1';
            accountProfitability.EUR_TR_ProfitAmount__c = 100;
            accountProfitability.EUR_TR_TotalAmount__c = 120;
            insert accountProfitability;
        }
        Test.stopTest();

    }

    @IsTest
    static void testBeforeUpdate() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_AccountProfitability__c accountProfitability = new EUR_TR_AccountProfitability__c();
        accountProfitability.EUR_TR_RelatedAccount__c = account.Id;
        accountProfitability.EUR_TR_Year__c = '19';
        accountProfitability.EUR_TR_Quarter__c = 'Q1';
        accountProfitability.EUR_TR_ProfitAmount__c = 100;
        accountProfitability.EUR_TR_TotalAmount__c = 120;
        insert accountProfitability;

        Test.startTest();
        {
            accountProfitability.EUR_TR_ProfitAmount__c = 80;
            update accountProfitability;
        }
        Test.stopTest();

    }

    private static EUR_TR_Account__c getAccount() {
        return [SELECT Id,EUR_TR_AccountCode__c FROM EUR_TR_Account__c LIMIT 1];
    }

}