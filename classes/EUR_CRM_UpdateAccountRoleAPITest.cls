@isTest
public class EUR_CRM_UpdateAccountRoleAPITest {
    
    @testSetUp static void setupData(){
        
        User user1 = EUR_CRM_RU_TestClassHelper.createUser('EUR RU ON Trade User', 'EUR_RU_SR_ON_South_Krasnodar','user@laputaTest.com','user@laputaTest.com','Test');
        User user2 = EUR_CRM_RU_TestClassHelper.createUser('EUR RU ON Trade User', 'EUR_RU_SR_ON_South_Krasnodar','manager@laputaTest.com','manager@laputaTest.com','Test');
        //User user3 = EUR_CRM_RU_TestClassHelper.createUser('EUR RU Affiliate Admin', 'EUR_RU_SR_ON_South_Krasnodar','director@laputaTest.com','director@laputaTest.com','Test');
        EUR_CRM_Account__c acct = EUR_CRM_RU_TestClassHelper.createEUAccount('Test Update 502','EUR RU On Trade');
        
        acct.OwnerId = user1.Id;
        //acct.EUR_CRM_Manager_of_Account_Owner__c = user2.Id;
        
        user1.ManagerId = user2.Id;
        update user1;
        
        system.runAs(user1){
            EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
            apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
            insert apexConfig;
            insert acct;
        }
        
        
    }
    
    static testmethod void test1(){
        user originUser = [select id ,isActive, UserRoleId FROM user where Email = 'user@laputaTest.com' limit 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = 'EUR RU SR OFF Volga N Novgorod']; 
        
        originUser.UserRoleId = role.Id;
        
        update originUser;
        
        
    }
    
}