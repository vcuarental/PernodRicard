/****************************************************
 Dev: Bruno Vuono  Version: 1  Consulting: Zimmic
****************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
@isTest
public with sharing class LAT_AR_Case_Update_Owner_Test {

    static testMethod void unitTestAR(){
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='ARG_Int Comercial']; 
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR@mail.com');
         
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','AR'); 
        insert usuario;  
        
        System.runAs(u2) {
            Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
            CNPJ__c = '33700964049',
            Name = 'testAccount',
            Type = 'Sale_ARG',
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
            ownerId = UserInfo.getUserId(),
            Reason_for_Inactivation__c = 'test'
            );
            
            insert acc;     
            
        
         
            Case caso = new Case(
                RecordTypeId = Global_RecordTypeCache.getRtId('Case' + 'CSE_1_AccountAlteration_ARG'),
                status= 'Without customer proposal-Sent to Credit',
                Reason = 'Solicitação de inativação de cliente',
                Description = 'TEST',
                Type = 'Account Alteration ARG',
                AccountId= acc.id,
                ownerId = usuario.id
            );
            insert caso;
        }
        
        Test.stopTest();
    }
    //MIGRATED 21/11/2016
    static testMethod void unitTestARLATCase(){
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='ARG_Int Comercial' OR Name='ARG_Int Comercial' Limit 1]; 
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR@mail.com');
         
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','AR'); 
        insert usuario;  
        
        System.runAs(u2) {
            Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
            CNPJ__c = '33700964049',
            Name = 'testAccount',
            Type = 'Sale_ARG',
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
            ownerId = UserInfo.getUserId(),
            Reason_for_Inactivation__c = 'test'
            );
            
            insert acc;     
            
        
         
            LAT_Case__c caso = new LAT_Case__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'CSE_1_AccountAlteration_ARG'),
                LAT_status__c = 'Without customer proposal-Sent to Credit',
                LAT_Reason__c = 'Solicitação de inativação de cliente',
                LAT_Description__c = 'TEST',
                LAT_Type__c = 'Account Alteration ARG',
                LAT_Account__c = acc.id,
                ownerId = usuario.id
            );
            insert caso;
        }
        
        Test.stopTest();
    }
    
}