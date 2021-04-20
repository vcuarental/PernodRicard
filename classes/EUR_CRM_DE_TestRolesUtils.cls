@isTest
private with sharing class EUR_CRM_DE_TestRolesUtils{

    static testMethod void roleUtils(){
        Test.startTest();
           set<Id> Ids = new set<Id>();
            UserRole r = new UserRole(name = 'TEST ROLE',Developername='TEST_ROLE');
            insert r;
    
            Profile prof1 = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = prof1.Id, userroleid = r.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='EUR_CRM_DE_TestRolesUtils@testorg.com');
    
            insert u1;
            Ids.add(u1.Id);
    
            Profile prof2 = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u2 = new User(Alias = 'standt', Email='standarduser2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = prof2.Id, userroleid = r.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='EUR_CRM_DE_TestRolesUtils2@testorg.com');
    
            insert u2;
            Ids.add(u2.Id);
    
            
            EUR_CRM_RoleUtils.getRoleSubordinateUsers(u1.Id);
            EUR_CRM_RoleUtils.getRoleSubordinateUsers(Ids);
            EUR_CRM_RoleUtils.getRoleSubordinateUsers('TEST_ROLE');
            EUR_CRM_RoleUtils.getUsers(Ids);
        Test.stopTest();
    }
}