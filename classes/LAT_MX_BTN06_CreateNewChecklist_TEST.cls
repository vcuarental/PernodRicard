/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:31/10/2013    *
*******************************************************************************/

@isTest 

public with sharing class LAT_MX_BTN06_CreateNewChecklist_TEST {

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
            RecordTypeId = rtOffMX
        );
        insert acc;
        
        String rtpla = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning');
        
        Planejamento__c pla = new Planejamento__c(
            RecordTypeId = rtpla,
            Name = 'test',
            Ano_de_Referencia__c = string.ValueOf(date.today().year()), 
            M_s_de_Ref_rencia__c = 'Dezembro'
        );
        insert pla;
        
        String rtvis = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit');
        
        Visitas__c visit = new Visitas__c(
            Conta__c = acc.Id,
            Name = 'test',
            Data_da_Visita__c = date.newInstance(date.today().year(),12,31),
            Hora_da_Visita__c = '08:00',
            Planejamento__c = pla.Id,
            Resumo_da_Visita__c = 'test',
            LAT_MX_ClienteChannel__c = 'Off Trade'
        
        );
        insert visit;
        
        try{LAT_MX_BTN06_CreateNewChecklist.CreateNewChecklist(visit.Id);} catch(exception e){}
        
        visit.LAT_MX_Type__c = 'Activity Negotiation - On Trade; Sales Negotiation';
        
        update visit;
        
        LAT_MX_CS002_VisitTypesAndChecklists__c cs1 = new LAT_MX_CS002_VisitTypesAndChecklists__c(
            Name = '01',
            LAT_MX_RecordTypeNameChecklist__c = 'LAT_MX_CLV_ActivityNegotiationOn',
            LAT_MX_Type__c = 'Activity Negotiation - On Trade' 
        );
        
        insert cs1;
        
        LAT_MX_CS002_VisitTypesAndChecklists__c cs2 = new LAT_MX_CS002_VisitTypesAndChecklists__c(
            Name = '02',
            LAT_MX_RecordTypeNameChecklist__c = 'LAT_MX_CLV_SalesNegotiation',
            LAT_MX_Type__c = 'Sales Negotiation' 
        );
        
        insert cs2;
        
        String rtcheck = Global_RecordTypeCache.getRtId('CLV_ChecklistVisita_ARG__c' + 'LAT_MX_CLV_SalesNegotiation');
        
        CLV_ChecklistVisita_ARG__c check = new CLV_ChecklistVisita_ARG__c(
            RecordTypeId = rtcheck,
            Visit_AR__c = visit.Id            
        );
        
        insert check;
        
        LAT_MX_BTN06_CreateNewChecklist.CreateNewChecklist(visit.Id);
        
        
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
            RecordTypeId = rtOffMX
        );
        insert acc;
        
        String rtpla = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning');
        
        Planejamento__c pla = new Planejamento__c(
            RecordTypeId = rtpla,
            Name = 'test',
            Ano_de_Referencia__c = string.ValueOf(date.today().year()), 
            M_s_de_Ref_rencia__c = 'Dezembro'
        );
        insert pla;
        
        String rtvis = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit');
        
        Visitas__c visit = new Visitas__c(
            Conta__c = acc.Id,
            Name = 'test',
            Data_da_Visita__c = date.newInstance(date.today().year(),12,31),
            Hora_da_Visita__c = '08:00',
            LAT_MX_Type__c = 'Activity Negotiation - On Trade; Sales Negotiation',
            Planejamento__c = pla.Id,
            Resumo_da_Visita__c = 'test',
            LAT_MX_ClienteChannel__c = 'Off Trade'
        
        );
        insert visit;
        
        LAT_MX_CS002_VisitTypesAndChecklists__c cs1 = new LAT_MX_CS002_VisitTypesAndChecklists__c(
            Name = '01',
            LAT_MX_RecordTypeNameChecklist__c = 'LAT_MX_CLV_ActivityNegotiationOn',
            LAT_MX_Type__c = 'Activity Negotiation - On Trade' 
        );
        
        insert cs1;
                
        String rtcheck = Global_RecordTypeCache.getRtId('CLV_ChecklistVisita_ARG__c' + 'LAT_MX_CLV_SalesNegotiation');
        
        CLV_ChecklistVisita_ARG__c check = new CLV_ChecklistVisita_ARG__c(
            RecordTypeId = rtcheck,
            Visit_AR__c = visit.Id            
        );
        
        insert check;
        
        LAT_MX_BTN06_CreateNewChecklist.CreateNewChecklist(visit.Id);
              
    }
    
    static testMethod void unitTest3() {
                
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
            RecordTypeId = rtOffMX
        );
        insert acc;
        
        String rtpla = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning');
        
        Planejamento__c pla = new Planejamento__c(
            RecordTypeId = rtpla,
            Name = 'test',
            Ano_de_Referencia__c = string.ValueOf(date.today().year()), 
            M_s_de_Ref_rencia__c = 'Dezembro'
        );
        insert pla;
        
        String rtvis = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit');
        
        Visitas__c visit = new Visitas__c(
            Conta__c = acc.Id,
            Name = 'test',
            Data_da_Visita__c = date.newInstance(date.today().year(),12,31),
            Hora_da_Visita__c = '08:00',
            Planejamento__c = pla.Id,
            Resumo_da_Visita__c = 'test',
            LAT_MX_ClienteChannel__c = 'Off Trade'
        
        );
        insert visit;
        
        try{LAT_MX_BTN06_CreateNewChecklist.CreateNewChecklist(visit.Id);} catch(exception e){}
        
        visit.LAT_MX_Type__c = 'Activity Negotiation - On Trade; Sales Negotiation';
        
        update visit;
        
        LAT_MX_CS002_VisitTypesAndChecklists__c cs1 = new LAT_MX_CS002_VisitTypesAndChecklists__c(
            Name = '01',
            LAT_MX_RecordTypeNameChecklist__c = 'LAT_MX_CLV_ActivityNegotiationOn',
            LAT_MX_Type__c = 'Activity Negotiation - On Trade' 
        );
        
        insert cs1;
        
        LAT_MX_CS002_VisitTypesAndChecklists__c cs2 = new LAT_MX_CS002_VisitTypesAndChecklists__c(
            Name = '02',
            LAT_MX_RecordTypeNameChecklist__c = 'LAT_MX_CLV_SalesNegotiation',
            LAT_MX_Type__c = 'Sales Negotiation' 
        );
        
        insert cs2;
        
        String rtcheck = Global_RecordTypeCache.getRtId('CLV_ChecklistVisita_ARG__c' + 'LAT_MX_CLV_SalesNegotiation');
        
        CLV_ChecklistVisita_ARG__c check = new CLV_ChecklistVisita_ARG__c(
            RecordTypeId = rtcheck,
            Visit_AR__c = visit.Id            
        );
        
        insert check;
        
        String rtcheck2 = Global_RecordTypeCache.getRtId('CLV_ChecklistVisita_ARG__c' + 'LAT_MX_CLV_ActivityNegotiationOn');
        
        CLV_ChecklistVisita_ARG__c check2 = new CLV_ChecklistVisita_ARG__c(
            RecordTypeId = rtcheck2,
            Visit_AR__c = visit.Id            
        );
        
        insert check2;
        
        LAT_MX_BTN06_CreateNewChecklist.CreateNewChecklist(visit.Id);
            
    }
}