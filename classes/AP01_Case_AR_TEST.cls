/*************************************************************************************************************
*   Company:Valuenet    Developers:   Tomás Etchegaray y Elena Schwarzböck               Date:21/03/2013     *
**************************************************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@isTest
public with sharing class AP01_Case_AR_TEST {
@isTest
    static void unitTest() {
        Utils.setMigrationDoneTest(false); 
       list<RecordType> record = [select id, DeveloperName from RecordType WHERE SobjectType='Case' order by Name ASC];
        RecordType recordOffTradeArg = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'ACC_1_OffTrade_ARG' AND SobjectType='Account'];
        list<Case> listCases = new list<Case>();
    
        system.Test.startTest();
        Utils.setMigrationDoneTest(false); 
        Account acc = new Account(
        RecordTypeId = recordOffTradeArg.Id, 
        CNPJ__c = '33700964049',
        Name = 'testAccount',
        Type = 'Prospect_ARG',
        Corporate_Name__c = 'test',
        Channel_Type__c = 'Direto',
        Sub_Channel__c = 'Delicatessen',
        AddressLine1_AR__c= 'test',
        Shipping_Neighbourhood__c = 'test',
        Revenue_Neighbourhood__c = 'test',
        Billing_Neighbourhood__c ='test',
        Shipping_Country__c ='test',
        Revenue_Country__c ='test',
        Billing_Country__c ='test'
        );
        
        insert acc;

         Profile p = [SELECT Id FROM Profile WHERE Name='AR_System Administrator']; 
         User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR@mail.com');
         insert u2;


        system.Test.stopTest();
       
        
        Case caso = new Case(
            RecordTypeId = record[0].id  , 
            status= 'Without customer proposal-Sent to Credit',
            Reason = 'Alt. cliente pai',
            Description = 'TEST',
            OwnerId = u2.id,
            Type = 'Account Alteration ARG',
            AccountId= acc.id
        );

         listCases.add(caso);

         insert  listCases;
         update listCases;


    }
    /*
//MIGRATED 21/11/2016 
@isTest
    static void unitTestLATCase() {
        Utils.setMigrationDoneTest(true); 
       list<RecordType> record = [select id, DeveloperName from RecordType WHERE SobjectType='LAT_Case__c' order by Name ASC];
        RecordType recordOffTradeArg = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'ACC_1_OffTrade_ARG' AND SobjectType='Account'];
        list<LAT_Case__c> listCases = new list<LAT_Case__c>();
    
        system.Test.startTest();
        Utils.setMigrationDoneTest(true);
        Account acc = new Account(
        RecordTypeId = recordOffTradeArg.Id, 
        CNPJ__c = '33700964049',
        Name = 'testAccount',
        Type = 'Prospect_ARG',
        Corporate_Name__c = 'test',
        Channel_Type__c = 'Direto',
        Sub_Channel__c = 'Delicatessen',
        AddressLine1_AR__c= 'test',
        Shipping_Neighbourhood__c = 'test',
        Revenue_Neighbourhood__c = 'test',
        Billing_Neighbourhood__c ='test',
        Shipping_Country__c ='test',
        Revenue_Country__c ='test',
        Billing_Country__c ='test'
        );
        
        insert acc;

         Profile p = [SELECT Id FROM Profile WHERE Name='LAT_SystemAdministrator']; 
         User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR@mail.com');
         insert u2;


      
       
        
        LAT_Case__c caso = new LAT_Case__c(
            RecordTypeId = record[0].id  , 
            LAT_status__c = 'Without customer proposal-Sent to Credit',
            LAT_Reason__c = 'Alt. cliente pai',
            LAT_Description__c = 'TEST',
            OwnerId = u2.id,
            LAT_Type__c = 'Account Alteration ARG',
            LAT_Account__c = acc.id
        );
        

         LAT_Case__c caso7 = new LAT_Case__c(
            RecordTypeId = record[26].id  , 
            LAT_status__c= 'Without customer proposal-Sent to Credit',
            LAT_Reason__c = 'Alt. cliente pai',
            LAT_Description__c = 'TEST',
            OwnerId = u2.id,
            LAT_Type__c = 'Proposta não realizada',
            LAT_Account__c= acc.id
        );
        
  

    
        
        LAT_Case__c caso1 = new LAT_Case__c(
            RecordTypeId = record[29].id  , 
            LAT_status__c= 'Without customer proposal-Sent to Credit',
            LAT_Reason__c = 'Alt. cliente pai',
            LAT_Description__c = 'TEST',
            OwnerId = u2.id,
            LAT_Type__c = 'Proposta de pagamento',
            LAT_Account__c= acc.id
        );
        
        LAT_Case__c caso2 = new LAT_Case__c(
            RecordTypeId = record[31].id  , 
            LAT_status__c= 'Without customer proposal-Sent to Credit',
            LAT_Reason__c = 'Alt. cliente pai',
            LAT_Description__c = 'TEST',
            LAT_Type__c = 'Justificativa de inadimplência',
            LAT_Account__c= acc.id
        );
        
        LAT_Case__c caso3 = new LAT_Case__c(
            RecordTypeId = record[33].id  , 
            LAT_status__c= 'Without customer proposal-Sent to Credit',
            LAT_Reason__c = 'Alt. cliente pai',
            LAT_Description__c = 'TEST',
            LAT_Type__c = 'Prouesta no realizada',
            LAT_Account__c= acc.id
        );

        LAT_Case__c caso4 = new LAT_Case__c(
            RecordTypeId = record[0].id  , 
            LAT_status__c= 'Without customer proposal-Sent to Credit',
            LAT_Reason__c = 'Alt. cliente pai',
            LAT_Description__c = 'TEST',
            OwnerId = u2.id,
            LAT_Type__c = 'Justificativa de inadimplência',
            LAT_Account__c= acc.id
        );

        LAT_Case__c caso5 = new LAT_Case__c(
            RecordTypeId = record[0].id  , 
            LAT_status__c= 'Without customer proposal-Sent to Credit',
            LAT_Reason__c = 'Alt. cliente pai',
            LAT_Description__c = 'TEST',
            OwnerId = u2.id,
            LAT_Type__c = 'Proposta de pagamento',
            LAT_Account__c= acc.id
        );

         listCases.add(caso3);
         listCases.add(caso2);
         listCases.add(caso1);
         listCases.add(caso7);
         listCases.add(caso4);
         listCases.add(caso5);
         listCases.add(caso);

         insert  listCases;
       system.Test.stopTest();


    }
@isTest
    static void unitTest2() {
        Utils.setMigrationDoneTest(false); 
       list<RecordType> record = [select id, DeveloperName from RecordType WHERE SobjectType='Case' order by Name ASC];
        RecordType recordOffTradeArg = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'ACC_1_OffTrade_ARG' AND SobjectType='Account'];
        list<Case> listCases = new list<Case>();
            Profile p = [SELECT Id FROM Profile WHERE Name='AR_System Administrator']; 

       
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
                  Name = 'AR_PROFILE_CLOSING_CASES',
                LAT_Value__c = p.Id);
        insert cfg;

         User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR@mail.com');
         insert u2;

      

         

        system.Test.startTest();
        Utils.setMigrationDoneTest(false); 
        Account acc = new Account(
        RecordTypeId = recordOffTradeArg.Id, 
        CNPJ__c = '33700964049',
        Name = 'testAccount',
        Type = 'Prospect_ARG',
        Corporate_Name__c = 'test',
        Channel_Type__c = 'Direto',
        Sub_Channel__c = 'Delicatessen',
        AddressLine1_AR__c= 'test',
        Shipping_Neighbourhood__c = 'test',
        Revenue_Neighbourhood__c = 'test',
        Billing_Neighbourhood__c ='test',
        Shipping_Country__c ='test',
        Revenue_Country__c ='test',
        Billing_Country__c ='test',
        OwnerId = userinfo.getUserId()
        );
        
        insert acc;
        

        System.runAs(u2){
       
           LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(
                  Name = 'AR_USERS_CLOSING_CASES',
                LAT_Value__c = u2.Id);
            insert cfg2;
            Case caso = new Case(
                RecordTypeId = RecordTypeForTest.getRecType('Case', 'CSE_1_AccountAlteration_ARG')   , 
                status= 'Without customer proposal-Sent to Credit',
                Reason = 'Alt. cliente pai',
                Description = 'TEST',
                OwnerId = u2.id,
                Type = 'Account Alteration ARG',
                AccountId= acc.id
            );
             insert caso;

             caso.status = 'Fechado e cancelado';
             update caso;
         }
         system.Test.stopTest();
    }
//MIGRATED 21/11/2016 
@isTest
    static void unitTestLATCase2() {
        Utils.setMigrationDoneTest(true);
        User admin = [SELECT Id FROM user WHERE Profile.Name = 'System Administrator' AND isActive = true limit 1];                  
        Account acc;
       list<RecordType> record = [select id, DeveloperName from RecordType WHERE SobjectType='LAT_Case__c' order by Name ASC];
        RecordType recordOffTradeArg = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'ACC_1_OffTrade_ARG' AND SobjectType='Account'];
        list<LAT_Case__c> listCases = new list<LAT_Case__c>();
        Profile p = [SELECT Id FROM Profile WHERE Name='LAT_SystemAdministrator']; 



        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
                  Name = 'AR_PROFILE_CLOSING_CASES',
                LAT_Value__c = p.Id);
        insert cfg;



         User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR@mail.com');
         insert u2;
        
        acc = new Account(
        RecordTypeId = recordOffTradeArg.Id, 
        CNPJ__c = '33700964049',
        Name = 'testAccount',
        Type = 'Prospect_ARG',
        Corporate_Name__c = 'test',
        Channel_Type__c = 'Direto',
        Sub_Channel__c = 'Delicatessen',
        AddressLine1_AR__c= 'test',
        Shipping_Neighbourhood__c = 'test',
        Revenue_Neighbourhood__c = 'test',
        Billing_Neighbourhood__c ='test',
        Shipping_Country__c ='test',
        Revenue_Country__c ='test',
        Billing_Country__c ='test', 
        OwnerId = u2.Id
        );
        
        insert acc;
        

        
        system.Test.startTest();
        Utils.setMigrationDoneTest(true);
        
        System.runAs(u2){
       
            LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(
                      Name = 'AR_USERS_CLOSING_CASES',
                    LAT_Value__c = u2.Id);
            insert cfg2;
       
            LAT_Case__c caso = new LAT_Case__c(
                RecordTypeId = RecordTypeForTest.getRecType('LAT_Case__c', 'CSE_1_AccountAlteration_ARG')  , 
                LAT_status__c = 'Without customer proposal-Sent to Credit',
                LAT_Reason__c = 'Alt. cliente pai',
                LAT_Description__c = 'TEST',
                OwnerId = u2.id,
                LAT_Type__c = 'Account Alteration ARG',
                LAT_Account__c = acc.id
            );
            

             insert caso;
             //insert caso4;
             //insert caso5;

             caso.LAT_status__c = 'Fechado e cancelado';
             update caso;
        }
        system.Test.stopTest();
    }
 */
}