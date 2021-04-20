/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

@IsTest
public with sharing class BTN01_RCPRedeemedBtnController_AR_TEST {
    
    static testMethod void UnitTest(){
         Id profId = LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator');
        
        User u1 = new User(Alias = 'newUser1', Email='newuser1@testorg.com', 
         EmailEncodingKey='UTF-8', FirstName='FERNANDO1',LastName='VALDUJO1', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = profId, 
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR1@mail.com');
         insert u1;
        
       
        System.runAs(u1){
			Account acco = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
            acco.Name='TEST';
            acco.Corporate_Name__c = 'Target Corp';
            insert acco;
            
            test.startTest();
            
            list<id> idsRegister = new list<id>();
            
            CS003_ReceiptRedemptionNo_ARG__c csRnum = new CS003_ReceiptRedemptionNo_ARG__c(RedemptionNo__c = 0.00);
            insert csRnum;
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, Status_AR__c = 'Receipt printed Deposit done' );
            insert recibo;
            idsRegister.add(recibo.id);
            RCP_Receipt_ARG__c recibo1 = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, Status_AR__c = 'Receipt printed Deposit done');
            insert recibo1;
            idsRegister.add(recibo1.id);
            
            BTN01_RCPRedeemedBtnController_AR.rcpButton(idsRegister);
            test.stopTest();
    	}
    }
    static testMethod void UnitTest1(){
                 Id profId = LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator');
        
        User u1 = new User(Alias = 'newUser1', Email='newuser1@testorg.com', 
         EmailEncodingKey='UTF-8', FirstName='FERNANDO1',LastName='VALDUJO1', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = profId, 
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR1@mail.com');
         insert u1;
        
       
        System.runAs(u1){
			Account acco = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
            acco.Name='TEST';
            acco.Corporate_Name__c = 'Target Corp';
            insert acco;
            
            test.startTest();
            
            list<id> idsRegister = new list<id>();
            
            CS003_ReceiptRedemptionNo_ARG__c csRnum = new CS003_ReceiptRedemptionNo_ARG__c(RedemptionNo__c = 0.00);
            insert csRnum;
            
            BTN01_RCPRedeemedBtnController_AR.rcpButton(idsRegister);
            test.stopTest();
        }
    }
    static testMethod void UnitTest2(){
                 Id profId = LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator');
        
        User u1 = new User(Alias = 'newUser1', Email='newuser1@testorg.com', 
         EmailEncodingKey='UTF-8', FirstName='FERNANDO1',LastName='VALDUJO1', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = profId, 
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR1@mail.com');
         insert u1;
        
       
        System.runAs(u1){     
			Account acco = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
            acco.Name='TEST';
            acco.Corporate_Name__c = 'Target Corp';
            insert acco;
            
            test.startTest();
            
            list<id> idsRegister = new list<id>();
            
            CS003_ReceiptRedemptionNo_ARG__c csRnum = new CS003_ReceiptRedemptionNo_ARG__c(RedemptionNo__c = 0.00);
            insert csRnum;
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, Status_AR__c = '123' );
            insert recibo;
            idsRegister.add(recibo.id);
            RCP_Receipt_ARG__c recibo1 = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, Status_AR__c = 'Receipt printed Deposit done');
            insert recibo1;
            idsRegister.add(recibo1.id);
            
            BTN01_RCPRedeemedBtnController_AR.rcpButton(idsRegister);
            test.stopTest();
        }
    }
    static testMethod void UnitTest3(){
       
        Account acco = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
        acco.Name='TEST';
        acco.Corporate_Name__c = 'Target Corp';
        insert acco;
        
        test.startTest();
        
        list<id> idsRegister = new list<id>();
        
        CS003_ReceiptRedemptionNo_ARG__c csRnum = new CS003_ReceiptRedemptionNo_ARG__c(RedemptionNo__c = 0.00);
        insert csRnum;
        
        RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, Status_AR__c = 'Receipt printed Deposit done' );
        insert recibo;
        idsRegister.add(recibo.id);
        RCP_Receipt_ARG__c recibo1 = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, Status_AR__c = 'Receipt printed Deposit done');
        insert recibo1;
        idsRegister.add(recibo1.id);
        
        list<Profile> perfiles = [SELECT id, Name FROM Profile WHERE Name != 'AR_Vendedor' AND Name != 'System Administrator' AND Name != 'LAT_AR2_Vendedor' AND Name != 'LAT_SystemAdministrator']; 
        User usuario;
        try{usuario = [SELECT Id, Name, ProfileId FROM User WHERE ProfileId IN: perfiles AND IsActive = true LIMIT 1];}catch(Exception e){}
        if(usuario!=null){
            system.runAs(usuario){
                BTN01_RCPRedeemedBtnController_AR.rcpButton(idsRegister);
            }
        }
        test.stopTest();
    }
    static testMethod void UnitTest4(){
         Id profId = LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator');
        
        User u1 = new User(Alias = 'newUser1', Email='newuser1@testorg.com', 
         EmailEncodingKey='UTF-8', FirstName='FERNANDO1',LastName='VALDUJO1', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = profId, 
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR1@mail.com');
         insert u1;
        
       
        System.runAs(u1){       
			Account acco = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
            acco.Name='TEST';
            acco.Corporate_Name__c = 'Target Corp';
            insert acco;
            
            test.startTest();
            
            list<id> idsRegister = new list<id>();
            
            CS003_ReceiptRedemptionNo_ARG__c csRnum = new CS003_ReceiptRedemptionNo_ARG__c(RedemptionNo__c = 0.00);
            insert csRnum;
            
            RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, Status_AR__c = 'Receipt of Applying Documents' );
            insert recibo;
            idsRegister.add(recibo.id);
            RCP_Receipt_ARG__c recibo1 = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id, Status_AR__c = 'Receipt of Applying Documents');
            insert recibo1;
            idsRegister.add(recibo1.id);
            //User u = createTesoreriaUser();
 
           		 BTN01_RCPRedeemedBtnController_AR.rcpButton(idsRegister);
            
            test.stopTest();
        }
    }
    
    public static User createTesoreriaUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'LAT_AR2_Tesoreria' LIMIT 1]; 
            
        User u = new User(
            Alias = 'testB', 
            Email='testAlias@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='TestUser1', 
            FirstName = 'TestUser1',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testAlias@testorg.com'
        );      
        insert u;
        
        return u;
    } 
}