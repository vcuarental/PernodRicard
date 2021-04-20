/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:23/12/2013    *
*******************************************************************************/

@isTest 

public with sharing class LAT_MX_VFP05_VisitEditDeleteValExt_TEST {

	public static Map<Integer, String> mapNumToMonth = new Map<Integer, String>{1 => 'Janeiro', 2 => 'Fevereiro', 3 => 'Março', 4 => 'Abril', 5 => 'Maio', 6 => 'Junho', 7 => 'Julho', 8 => 'Agosto', 9 => 'Setembro', 10 => 'Outubro', 11 => 'Novembro', 12 => 'Dezembro'};

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
            Frequency_of_Visits__c = 'Mensual',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        insert acc;
        
        test.startTest();
        Planejamento__c pla = new Planejamento__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning'),
            Name = 'test',
            Ano_de_Referencia__c = string.valueOf(date.today().year()),
            M_s_de_Ref_rencia__c = mapNumToMonth.get(date.today().month())
        );
        insert pla; 
            
        Visitas__c visit = new Visitas__c(
            Conta__c = acc.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit'),
            Name = 'test',
            Data_da_Visita__c = date.today(),
            Hora_da_Visita__c = '08:00',
            Planejamento__c = pla.Id,
            Resumo_da_Visita__c = 'test',
            LAT_MX_ClienteChannel__c = 'Off Trade',
            LAT_MX_Type__c = 'Collections;Follow Up - On Trade'        
        );        
        insert visit;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(visit);
        LAT_MX_VFP05_VisitEditDeleteValExt pagina = new LAT_MX_VFP05_VisitEditDeleteValExt(controller);
        
        Apexpages.currentPage().getParameters().put('id', visit.Id); 
        Apexpages.currentPage().getParameters().put('retURL', pla.Id);
        
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
            Frequency_of_Visits__c = 'Mensual',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        insert acc;
    test.startTest();
    
        Planejamento__c pla = new Planejamento__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning'),
            Name = 'test',
            Ano_de_Referencia__c = string.valueOf(date.today().year()),
            M_s_de_Ref_rencia__c = mapNumToMonth.get(date.today().month())
        );
        insert pla;

        Visitas__c visit = new Visitas__c(
            Conta__c = acc.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit'),
            Name = 'test',
            Data_da_Visita__c = date.today(),
            Hora_da_Visita__c = '08:00',
            Planejamento__c = pla.Id,
            Resumo_da_Visita__c = 'test',
            LAT_MX_ClienteChannel__c = 'Off Trade',
            LAT_MX_Type__c = 'Collections;Follow Up - On Trade'        
        );        
        insert visit;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(visit);
        LAT_MX_VFP05_VisitEditDeleteValExt pagina = new LAT_MX_VFP05_VisitEditDeleteValExt(controller);
        
        Apexpages.currentPage().getParameters().put('id', visit.Id); 
        Apexpages.currentPage().getParameters().put('retURL', pla.Id);
        
        pagina.doValidationEdit();
    test.stopTest();
    }
    
    static testMethod void unitTest3() {

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
            Frequency_of_Visits__c = 'Mensual',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        insert acc;
        test.startTest();
        
        Planejamento__c pla = new Planejamento__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning'),
            Name = 'test',
            Ano_de_Referencia__c = string.valueOf(date.today().year()),
            M_s_de_Ref_rencia__c = mapNumToMonth.get(date.today().month())
        );
        insert pla; 
            
        Visitas__c visit = new Visitas__c(
            Conta__c = acc.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_ClosedVisit'),
            Name = 'test',
            Data_da_Visita__c = date.today(),
            Hora_da_Visita__c = '08:00',
            Planejamento__c = pla.Id,
            Resumo_da_Visita__c = 'test',
            LAT_MX_ClienteChannel__c = 'Off Trade',
            LAT_MX_Type__c = 'Collections;Follow Up - On Trade'        
        );        
        insert visit;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(visit);
        LAT_MX_VFP05_VisitEditDeleteValExt pagina = new LAT_MX_VFP05_VisitEditDeleteValExt(controller);
        
        Apexpages.currentPage().getParameters().put('id', visit.Id); 
        Apexpages.currentPage().getParameters().put('retURL', pla.Id);
        
        try{pagina.doValidationDelete();}catch(exception e){}
    test.stopTest();
    }
    
    static testMethod void unitTest4() {

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
            Frequency_of_Visits__c = 'Mensual',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        insert acc;
        test.startTest();

        Planejamento__c pla = new Planejamento__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning'),
            Name = 'test',
            Ano_de_Referencia__c = string.valueOf(date.today().year()),
            M_s_de_Ref_rencia__c = mapNumToMonth.get(date.today().month())
        );
        insert pla;
  
        Visitas__c visit = new Visitas__c(
            Conta__c = acc.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_ClosedVisit'),
            Name = 'test',
            Data_da_Visita__c = date.today(),
            Hora_da_Visita__c = '08:00',
            Planejamento__c = pla.Id,
            Resumo_da_Visita__c = 'test',
            LAT_MX_ClienteChannel__c = 'Off Trade',
            LAT_MX_Type__c = 'Collections;Follow Up - On Trade'        
        );        
        insert visit;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(visit);
        LAT_MX_VFP05_VisitEditDeleteValExt pagina = new LAT_MX_VFP05_VisitEditDeleteValExt(controller);
        
        Apexpages.currentPage().getParameters().put('id', visit.Id); 
        Apexpages.currentPage().getParameters().put('retURL', pla.Id);
        
        try{pagina.doValidationEdit();}catch(exception e){}
    test.stopTest();
    }
}