@isTest
public class EUR_CRM_TestPostalCodeTerrMapChangdHndlr{
    static User eurSysUser;
    static User user1;
    static User user2;
    
    static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;
         p = [SELECT Id FROM Profile WHERE Name ='EUR DE ON Trade User']; 
         r = [select id from UserRole where Developername ='EMEA'];
        user1 = new User(Alias = 'standt', Email='user1Email1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='user1Email1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='user1Email1234aoke@test.com');
        insert user1;
        user2 = new User(Alias = 'standt', Email='user2Email1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='user2Email1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='user2Email1234aoke@test.com');
        insert user2;

    }
    @isTest(seeAllData=false)
    static  void testTerritoryHandler(){
        setUser();
        System.runAs(eurSysUser){
            Id dePostalMapping = [select id from RecordType where sobjecttype='EUR_CRM_Postal_Code_Territory_Mapping__c' and developername ='EUR_DE_On_Trade_Postal_Code_Territory_Mapping'].id;
            Id deAccountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_DE_ON_Consumers'].id;
            Id deTerritoryRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_Territory__c' and developername ='EUR_DE_Territory'].id;
            Id deRegionRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_Region__c' and developername ='EUR_DE_Region'].id;
            
            EUR_CRM_Region__c region = new EUR_CRM_Region__c(recordtypeid=deRegionRecordTypeId,name = 'testregion',EUR_CRM_Region_Owner__c = eurSysUser.id, ownerid = eurSysUser.id);
            insert region;
            
            EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(EUR_CRM_Region__c = region.id, recordtypeid=deTerritoryRecordTypeId,name = 'testterritory',
            EUR_CRM_Territory_Owner__c = user1.id, EUR_CRM_Default__c = true);
            insert territory;
            EUR_CRM_Territory__c territory2 = new EUR_CRM_Territory__c(EUR_CRM_Region__c = region.id, recordtypeid=deTerritoryRecordTypeId,name = 'testterritory2',
            EUR_CRM_Territory_Owner__c = user2.id, EUR_CRM_Default__c = true);
            insert territory2;
            
            
            EUR_CRM_Postal_Code_Territory_Mapping__c m = new EUR_CRM_Postal_Code_Territory_Mapping__c(name='test', recordtypeid = dePostalMapping, eur_crm_territory__c = territory.id, eur_Crm_postal_code__c = '99999');
            insert m;
            
            eur_crm_account__C account = new eur_crm_account__C(name='test account',  recordtypeid=deAccountRecordTypeId , eur_Crm_postal_code__c = '99999');
            insert account;
            account = [select eur_crm_territory__c  from eur_crm_account__C  where id =: account.id]; 
            //system.assert(account.eur_crm_territory__c == territory.id, '' + account.eur_crm_territory__c +' ' +territory.id);
            m.eur_crm_territory__c = territory2.id;
            update m;   
            account = [select eur_crm_territory__c  from eur_crm_account__C  where id =: account.id]; 
          
            //system.assert(account.eur_crm_territory__c == territory2.id);
            territory2 = [select EUR_CRM_IsOwnerChanged__c from eur_crm_territory__c where id=:territory2.id];
            //system.assert(territory2.EUR_CRM_IsOwnerChanged__c);
        }
        
    }

}