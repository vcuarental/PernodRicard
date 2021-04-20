@isTest
public with sharing class EUR_CRM_ContactOwnerUpdatingBatchTest {

    @TestSetup
    private static void setupTest() {
        String uniqueUserName = 'standarduser' + Datetime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(
                Alias = 'standt'
                ,   Email = 'standarduser@testorg.com'
                ,   EmailEncodingKey = 'UTF-8'
                ,   LastName = 'Testing'
                ,   LanguageLocaleKey = 'en_US'
                ,   LocaleSidKey = 'en_US'
                ,   ProfileId = p.Id
                ,   TimeZoneSidKey = 'America/Los_Angeles'
                ,   Username = uniqueUserName
        );
        insert u;

        EUR_CRM_Region__c region = new EUR_CRM_Region__c(
                recordtypeid = Schema.SObjectType.EUR_CRM_Region__c.getRecordTypeInfosByName().get('EUR DE Region').getRecordTypeId(),
                Name = 'TetsRegion',
                EUR_CRM_Region_Owner__c = UserInfo.getUserId(),
                EUR_CRM_Channel__c = 'OFF TRADE'
        );
        insert region;

        EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(
                EUR_CRM_Region__c = region.Id,
                recordtypeid = Schema.SObjectType.EUR_CRM_Territory__c.getRecordTypeInfosByName().get('EUR DE Territory').getRecordTypeId(),
                Name = 'TestTerritoty',
                EUR_CRM_Territory_Owner__c =  UserInfo.getUserId()
        );
        insert territory;

        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping = new EUR_CRM_Postal_Code_Territory_Mapping__c(
                EUR_CRM_Postal_Code__c = '11111',
                recordtypeid = Schema.SObjectType.EUR_CRM_Postal_Code_Territory_Mapping__c.getRecordTypeInfosByName().get('DE Off Trade Postal Code - Territory Mapping').getRecordTypeId(),
                Name = 'TestMapping',
                EUR_CRM_Territory__c = territory.Id
        );
        insert postalCodeTerritoryMapping;

        EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
                EUR_CRM_Postal_Code__c = '11111',
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByName().get('DE OFF STD').getRecordTypeId(),
                Name = 'TestAccount',
                EUR_CRM_Channel__c = 'OFF TRADE'
        );
        insert euAccount;

        Contact c = new Contact(
                OwnerId = u.Id,
                FirstName = 'test',
                LastName = 'test',
                EUR_CRM_Account__c = euAccount.id
        );
        insert c;
    }

    static testmethod void testOwnerUpdating(){
        Contact c = [SELECT OwnerId, EUR_CRM_Account__r.OwnerId FROM Contact WHERE FirstName = 'test' LIMIT 1];
        System.assertNotEquals(c.OwnerId, c.EUR_CRM_Account__r.OwnerId);

        Test.startTest();
        Database.executeBatch(new EUR_CRM_ContactOwnerUpdatingBatch('DE'), 200);
        Test.stopTest();

        c = [SELECT OwnerId, EUR_CRM_Account__r.OwnerId FROM Contact WHERE FirstName = 'test' LIMIT 1];
        System.assertEquals(c.OwnerId, c.EUR_CRM_Account__r.OwnerId);
    }
}