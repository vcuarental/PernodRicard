/******************************************************************************
*    Company:Valuenet    Developer:Elena Schwarzböck       Date:17/03/2013    *
*******************************************************************************/

@isTest 

public with sharing class LAT_MX_VFC07_ChecklistDeleteValExt_TEST {

    static testMethod void unitTest1() {
                    
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
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        insert acc;
        
        Planejamento__c pla = new Planejamento__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning'),
            Name = 'test',
            Ano_de_Referencia__c = string.ValueOf(date.today().year()), 
            M_s_de_Ref_rencia__c = 'Dezembro'
        );
        insert pla;
        
        Visitas__c visit = new Visitas__c(
            Conta__c = acc.Id,
            Name = 'test',
            Data_da_Visita__c = date.newInstance(date.today().year(),12,31),
            Hora_da_Visita__c = '08:00',
            LAT_MX_Type__c = 'Activity Negotiation - On Trade',
            Planejamento__c = pla.Id,
            Resumo_da_Visita__c = 'test',
            LAT_MX_ClienteChannel__c = 'Off Trade',
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit')
        
        );
        insert visit;
        
        test.startTest();    
        
        CLV_ChecklistVisita_ARG__c check = new CLV_ChecklistVisita_ARG__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('CLV_ChecklistVisita_ARG__c' + 'LAT_MX_CLV_ActivityNegotiationOn'),
            Visit_AR__c = visit.Id            

        );
        insert check;
        
        
        ApexPages.StandardController controller = new ApexPages.StandardController(check);
        LAT_MX_VFC07_ChecklistDeleteValExt pagina = new LAT_MX_VFC07_ChecklistDeleteValExt(controller);
        
        Apexpages.currentPage().getParameters().put('id', check.Id); 
        Apexpages.currentPage().getParameters().put('retURL', visit.Id);
                
        pagina.doValidationDelete();
        
        test.stopTest();
        

    }
    
    static testMethod void unitTest2() {
                    
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
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        insert acc;
        
        Planejamento__c pla = new Planejamento__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning'),
            Name = 'test',
            Ano_de_Referencia__c = string.ValueOf(date.today().year()), 
            M_s_de_Ref_rencia__c = 'Dezembro'
        );
        insert pla;
        
        Visitas__c visit = new Visitas__c(
            Conta__c = acc.Id,
            Name = 'test',
            Data_da_Visita__c = date.newInstance(date.today().year(),12,31),
            Hora_da_Visita__c = '08:00',
            LAT_MX_Type__c = 'Activity Negotiation - On Trade',
            Planejamento__c = pla.Id,
            Resumo_da_Visita__c = 'test',
            LAT_MX_ClienteChannel__c = 'Off Trade',
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_ClosedVisit')
        
        );
        insert visit;
        
        test.startTest();    
        
        CLV_ChecklistVisita_ARG__c check = new CLV_ChecklistVisita_ARG__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('CLV_ChecklistVisita_ARG__c' + 'LAT_MX_CLV_ActivityNegotiationOn'),
            Visit_AR__c = visit.Id            

        );
        insert check;
        
        
        ApexPages.StandardController controller = new ApexPages.StandardController(check);
        LAT_MX_VFC07_ChecklistDeleteValExt pagina = new LAT_MX_VFC07_ChecklistDeleteValExt(controller);
        
        Apexpages.currentPage().getParameters().put('id', check.Id); 
        Apexpages.currentPage().getParameters().put('retURL', visit.Id);
                
        pagina.doValidationDelete();
        
        test.stopTest();
        

    }
 
}