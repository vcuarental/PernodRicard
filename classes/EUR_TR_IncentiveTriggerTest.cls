/**
 * Created by osman on 27.01.2021.
 */

@IsTest
private with sharing class EUR_TR_IncentiveTriggerTest {

    @TestSetup
    static void setup() {

        EUR_TR_Account__c account = new EUR_TR_Account__c();
        account.Name = 'test acc';
        account.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        account.EUR_TR_Status__c = 'Aktif';
        account.EUR_TR_AccountCode__c = '4455661';
        insert account;

        EUR_TR_Incentive__c incentive = new EUR_TR_Incentive__c();
        incentive.EUR_TR_RelatedAccount__c = account.Id;
        incentive.EUR_TR_Brand__c = 'Ballantines';
        incentive.EUR_TR_StartDate__c = Date.today().addDays(2);
        incentive.EUR_TR_EndDate__c = Date.today().addYears(1);
        insert incentive;

        incentive.EUR_TR_DoNotShowMeAgain__c = true;
        update incentive;

    }

    @IsTest
    static void testAfterInsert() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_Incentive__c incentive = new EUR_TR_Incentive__c();
        incentive.EUR_TR_RelatedAccount__c = account.Id;
        incentive.EUR_TR_Brand__c = 'JAMESON';
        incentive.EUR_TR_StartDate__c = Date.today().addDays(2);
        incentive.EUR_TR_EndDate__c = Date.today().addYears(1);
        incentive.EUR_TR_DoNotShowMeAgain__c = true;

        Test.startTest();
        {
            insert incentive;
            EUR_TR_Incentive__c updatedIncentive = [SELECT Id,EUR_TR_DoNotShowMeAgain__c FROM EUR_TR_Incentive__c WHERE EUR_TR_Brand__c = 'Ballantines' LIMIT 1];
            System.assertEquals(false, updatedIncentive.EUR_TR_DoNotShowMeAgain__c);
        }
        Test.stopTest();
    }

    @IsTest
    static void testAfterUpdate() {

        EUR_TR_Incentive__c incentive = [SELECT Id FROM EUR_TR_Incentive__c WHERE EUR_TR_DoNotShowMeAgain__c = TRUE];
        Test.startTest();
        {
            incentive.EUR_TR_EndDate__c = Date.today().addYears(5);
            update incentive;
            incentive = [SELECT Id,EUR_TR_DoNotShowMeAgain__c FROM EUR_TR_Incentive__c WHERE Id = :incentive.Id];
            System.assertEquals(false, incentive.EUR_TR_DoNotShowMeAgain__c);
        }
        Test.stopTest();

    }

    private static EUR_TR_Account__c getAccount() {
        return [SELECT Id FROM EUR_TR_Account__c LIMIT 1];
    }

}