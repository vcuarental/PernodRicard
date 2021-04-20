/**
 * Created by osman on 21.01.2021.
 */

@IsTest
private with sharing class EUR_TR_CrossComplianceTriggerTest {

    @TestSetup
    static void setup() {

        EUR_TR_Account__c account = new EUR_TR_Account__c();
        account.Name = 'test acc 1';
        account.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        account.EUR_TR_Status__c = 'Aktif';
        account.EUR_TR_AccountCode__c = '52199';
        insert account;

    }

    @IsTest
    static void testBeforeInsert() {

        EUR_TR_Account__c account = getAccount();
        Test.startTest();
        {
            EUR_TR_CrossCompliance__c crossCompliance = new EUR_TR_CrossCompliance__c();
            crossCompliance.EUR_TR_RelatedAccount__c = account.Id;
            crossCompliance.EUR_TR_AbsCross__c = true;
            crossCompliance.EUR_TR_BFWJWRL__c = true;
            crossCompliance.EUR_TR_CR12JD__c = true;
            crossCompliance.EUR_TR_PassBells__c = true;
            crossCompliance.EUR_TR_WyboCross__c = true;
            insert crossCompliance;
        }
        Test.stopTest();

    }

    @IsTest
    static void testBeforeUpdate() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_CrossCompliance__c crossCompliance = new EUR_TR_CrossCompliance__c();
        crossCompliance.EUR_TR_RelatedAccount__c = account.Id;
        crossCompliance.EUR_TR_AbsCross__c = true;
        crossCompliance.EUR_TR_BFWJWRL__c = true;
        crossCompliance.EUR_TR_CR12JD__c = true;
        crossCompliance.EUR_TR_PassBells__c = true;
        crossCompliance.EUR_TR_WyboCross__c = true;
        insert crossCompliance;

        Test.startTest();
        {
            crossCompliance.EUR_TR_AbsCross__c = false;
            update crossCompliance;
        }
        Test.stopTest();

    }

    private static EUR_TR_Account__c getAccount() {
        return [SELECT Id,EUR_TR_AccountCode__c FROM EUR_TR_Account__c LIMIT 1];
    }

}