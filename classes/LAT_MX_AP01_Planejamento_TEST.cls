/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:01/11/2013    *
*******************************************************************************/

@isTest 

public with sharing class LAT_MX_AP01_Planejamento_TEST {

    static testMethod void unitTest() {
                
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            Frequency_of_Visits__c = 'Mensal',
            RecordTypeId = rtOffMX
        );
        try{insert acc;} catch(exception e){}  
        User u = new User();
        u = LAT_TestUserAdmin.userWithAdminPorf ('Nome4','Sobrenome4','NSobre4','nome4@sobrenome.com','PriceCalculationInterface4@mail.com','123jjjuuu4','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        u.profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_OnPremise');
        insert u;
        test.startTest();
        
        String rtpla = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning');
        
        Planejamento__c pla = new Planejamento__c(
            RecordTypeId = rtpla,
            Name = 'test',
            Ano_de_Referencia__c = string.ValueOf(date.today().year()), 
            M_s_de_Ref_rencia__c = 'Dezembro',
            OwnerId = u.Id
        );
        try{insert pla;} catch(exception e){}  
        
        LAT_MX_AP01_Planejamento.getBusinessDay(2017,07);
        LAT_MX_AP01_Planejamento.getPeriodicity('Diária',2017,10);
        LAT_MX_AP01_Planejamento.getPeriodicity('2 x Semana',2017,10);
        LAT_MX_AP01_Planejamento.getPeriodicity('Semanal',2017,10);
        LAT_MX_AP01_Planejamento.getPeriodicity('Quinzenal',2017,10);
        LAT_MX_AP01_Planejamento.getPeriodicity('Mensal',2017,10);
        test.stopTest();  
        
    }
    
    static testMethod void unitTest2() {
                
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            Frequency_of_Visits__c = 'Diária',
            RecordTypeId = rtOffMX
        );
        try{insert acc;} catch(exception e){}  
        
        test.startTest();
        
        String rtpla = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning');
        
        Planejamento__c pla = new Planejamento__c(
            RecordTypeId = rtpla,
            Name = 'test',
            Ano_de_Referencia__c = string.ValueOf(date.today().year()), 
            M_s_de_Ref_rencia__c = 'Dezembro'
        );
        try{insert pla;} catch(exception e){}  
        Integer mes = LAT_MX_AP01_Planejamento.getMonth('Junho');
        test.stopTest();
        
    }
}