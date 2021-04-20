/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:12/12/2013    *
*******************************************************************************/

@istest
public with sharing class LAT_MX_FullCalendarController_TEST {

    static testMethod void unitTest() {

        datetime hoy = date.newInstance(date.today().year(),12,31);
        datetime hoyMasDos = date.newInstance(date.today().year(),12,31);
        string title = 'Themap';
        string title2 = 'true';
        
        string digits = string.valueOfGmt(hoy);
        digits = digits.replace(' ', '');
        digits =+ digits.replace('-', '');
        digits =+ digits.replace(':', '');
        
        string digits2 = string.valueOfGmt(hoyMasDos);
        digits2 = digits2.replace(' ', '');
        digits2 =+ digits2.replace('-', '');
        digits2 =+ digits2.replace(':', '');
        
        LAT_MX_FullCalendarController.CreateEvent(title, digits,digits2, title2);
        
        User usuario;
        try{usuario = [SELECT Id, Name, ProfileId FROM User WHERE IsActive = true LIMIT 1];}catch(Exception e){}
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade'),
            OwnerId = usuario.id
        );     
        insert acc;
        
        Planejamento__c plan0 = new Planejamento__c(
            Name = 'Test0', 
            Ano_de_Referencia__c = string.ValueOf(date.today().year()), 
            M_s_de_Ref_rencia__c = 'Dezembro',
            Solicitar_aprova_o_para__c = 'Planejamento semana 2', 
            Aprovado_semana_1__c = true, 
            OwnerId = usuario.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning')
        );
        insert plan0;
                            
        Visitas__c vis = new Visitas__c(
            Conta__c = acc.Id,
            Name = 'test',
            Data_da_Visita__c = date.newInstance(date.today().year(),12,31),
            Hora_da_Visita__c = '08:00',
            Planejamento__c = plan0.Id,
            Resumo_da_Visita__c = 'test',
            LAT_MX_ClienteChannel__c = 'Off Trade',
            LAT_MX_Type__c = 'Collections;Follow Up - On Trade',
            RecordTypeId =  Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit')      
        );        
        insert vis;
        
        LAT_MX_FullCalendarController.getEvents(digits,digits2, plan0.Id);
        
        LAT_MX_FullCalendarController.updateEvent(vis.Id, title, digits, digits2, false, 'true');
        LAT_MX_FullCalendarController.deleteEvent(vis.Id);
    
    }
}