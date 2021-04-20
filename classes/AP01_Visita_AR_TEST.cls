/******************************************************************************************
*   Company:Valuenet    Developers:   Tomás Etchegaray                Date:21/03/2013     *
*******************************************************************************************/
@isTest

public with sharing class AP01_Visita_AR_TEST {
    
    static testmethod void unitTest() {

        Planejamento__c planejamiento = new Planejamento__c(
            Ano_de_Referencia__c='2013',
            M_s_de_Ref_rencia__c= 'Julho',
            Name='Test 1',
            RecordTypeId =  Global_RecordTypeCache.getRtId('Planejamento__c' + 'PLV_Standard_AR')
        );
        insert planejamiento;
        
        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
            CNPJ__c = '20354266645',
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
        
      /*  Profile p = [SELECT Id FROM Profile WHERE Name='AR_System Administrator']; 
         User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='VisitaAR@mail.com');*/
        
        Visitas__c visit = new Visitas__c(
            Conta__c = acc.id,
            Planejamento__c = planejamiento.id,
            Hora_da_Visita__c = '05:00',
            Resumo_da_Visita__c = 'asd',
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'VTS_Standard_AR')
        );
        insert visit;
    }
    
    static testmethod void unitTest1() {

        Planejamento__c planejamiento = new Planejamento__c(
            Ano_de_Referencia__c='2013',
            M_s_de_Ref_rencia__c= 'Julho',
            Name='Test 1',
            RecordTypeId =  Global_RecordTypeCache.getRtId('Planejamento__c' + 'PLV_Standard_AR')
        );
        insert planejamiento;
        
        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
            CNPJ__c = '20354266645',
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
        
        Visitas__c visit = new Visitas__c(
            Conta__c = acc.id,
            Planejamento__c = planejamiento.id,
            Hora_da_Visita__c = '05:00',
            Resumo_da_Visita__c = 'asd',
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'VTS_Standard_AR')
        );
        insert visit;
    }
        
}