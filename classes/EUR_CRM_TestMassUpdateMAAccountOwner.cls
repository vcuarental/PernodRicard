@isTest
public with sharing class EUR_CRM_TestMassUpdateMAAccountOwner {

    public static User testUser;
    public static EUR_CRM_Account__c account;
    public static EUR_CRM_Territory__c territory;
    
    public static void setUser(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName];
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMEA'];
        testUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        
        insert testUser;
    }
    
    static testMethod void dataInsert() {
        
        Id userId = UserInfo.getUserId();
        Id territoryRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='EUR_CRM_Territory__c' AND Developername = 'EUR_MA_Territory'].Id;
        Id accountRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Account__c' AND Developername = 'EUR_MA_On_Trade'].Id;
        
        EUR_CRM_Region__c region = EUR_CRM_TestClassUtilityHelper.createRegion(1, '', userId)[0];
        region.EUR_CRM_Channel__c = 'ON Trade & OFF Trade';
        insert region;
        
        territory = EUR_CRM_TestClassUtilityHelper.createTerritory(1, '', userId, region.Id)[0];
        territory.recordtypeid = territoryrecordtypeid;
        territory.EUR_CRM_isOwnerChanged__c = true;
        territory.EUR_CRM_On_Trade_Owner__c = userId;
        insert territory;
        System.assertEquals(territoryrecordtypeid, territory.recordTypeId);
        
        account = EUR_CRM_TestClassUtilityHelper.createAccountEU('Test Account', accountRecordTypeId);
        account.EUR_CRM_Territory__c = territory.Id;
        account.EUR_CRM_Channel__c = 'ON TRADE';
        insert account;
    }
    
    static testMethod void testBatch() {
        setUser('EUR System Admin');
        
        System.runAs(testUser) {
            dataInsert();
            
            Test.startTest();
            
            PageReference pageRef = Page.EUR_CRM_MassUpdateAccountTerritoryPage;
            pageRef.getParameters().put('id', territory.Id);
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(territory);
            EUR_CRM_TerritoryUpdateController con = new EUR_CRM_TerritoryUpdateController(sc);
            
            System.debug('@@@ accs'+[SELECT Id, Eur_crm_country_code__c, EUR_CRM_Territory__r.EUR_CRM_IsOwnerChanged__c, RecordTypeId, RecordType.DeveloperName, OwnerId, EUR_CRM_Territory__c, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c, EUR_CRM_Territory__r.EUR_CRM_Off_Trade_Owner__c, EUR_CRM_Territory__r.EUR_CRM_On_Trade_Owner__c, EUR_CRM_Image_Level__c FROM EUR_CRM_Account__c]);

            con.massUpdateAccounts();
            
            Test.stopTest();
            
            //territory = [SELECT EUR_CRM_On_Trade_Owner__c FROM EUR_CRM_Territory__c WHERE Id = :territory.Id];
            account = [SELECT OwnerId FROM EUR_CRM_Account__c WHERE Id = :account.Id];
            
            System.assertEquals(territory.EUR_CRM_On_Trade_Owner__c, account.ownerId);
        }
    }

}