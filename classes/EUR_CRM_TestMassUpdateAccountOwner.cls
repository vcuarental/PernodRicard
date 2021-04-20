/*------------------------------------------------------------
Author/Company:   IP Converge Data Services,Inc.
Description:      test class for EUR_CRM_MassUpdateAccountOwner 
History
05/05/2014        IPC     Created
------------------------------------------------------------*/
@isTest
public with sharing class EUR_CRM_TestMassUpdateAccountOwner {

    
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
                FirstName = 'test',
                LastName = 'test',
                EUR_CRM_Account__c = euAccount.id
        );
        insert c;
    }

    static testmethod void testMassUpdating(){
        User u = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com' LIMIT 1];
        EUR_CRM_Territory__c terr = [SELECT Id FROM EUR_CRM_Territory__c WHERE Name = 'TestTerritoty' LIMIT 1];

        terr.EUR_CRM_Territory_Owner__c = u.Id;

        Test.startTest();
        update terr;
        EUR_CRM_MassUpdateAccountOwner massUpdateAccOwn1 = new EUR_CRM_MassUpdateAccountOwner(new Set<Id>());
        EUR_CRM_MassUpdateAccountOwner massUpdateAccOwn2 = new EUR_CRM_MassUpdateAccountOwner(new Set<Id>(), new Set<Id>());
        EUR_CRM_MassUpdateAccountOwner massUpdateAccOwn = new EUR_CRM_MassUpdateAccountOwner('SELECT Id, Name, RecordType.DeveloperName, OwnerId, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__r.ManagerId, EUR_CRM_RTDevName__c, EUR_CRM_Image_Level_Name__c, EUR_CRM_Territory_KD_Owner__c ' + 'FROM EUR_CRM_Account__c LIMIT 10');
        database.executeBatch(massUpdateAccOwn, 200);
        Test.stopTest();

        System.assertEquals(u.Id, [SELECT OwnerId FROM EUR_CRM_Account__c WHERE Name = 'TestAccount' LIMIT 1].OwnerId);
    }


}