/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:01/11/2013    *
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/


@istest
public with sharing class LAT_MX_AP01_ChecklistDeVisitaARG_TEST {

   static testMethod void unitTest() {
		
		Id profileId = LAT_GlobalProfileCache.getProfileIdByName('PR BRAZIL System Administrator');		
		User usuario = new User(FirstName = 'Nome', LastName = 'Sobrenome', Alias = 'NSobre', Email = 'gerente@sobrenome.com', Username = 'devtestusercloud2b@cloud2b.com.br', CommunityNickname = '123jjjuuuG', EmailEncodingKey = 'ISO-8859-1', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_Us', LanguageLocaleKey = 'en_Us', C_digo_JDE__c = '234', ProfileId = ProfileId, Country = 'BR' );
		insert usuario;

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        Account acc = new Account(Name = 'TEST', AccountNumber = '1000', Type = 'Payer', Phone = '1-11-1111-1111', Fax = '11-1111-1111', Notes__c = 'TEST', AddressLine1_AR__c = 'TEST', CNPJ__c = 'LOZM701213E52', Corporate_Name__c = 'TEST', Channel__c = 'WS', Segmentation_Type_on_trade__c = 'MOP', RecordTypeId = rtOffMX);
        insert acc;
        
        String rtpla = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning');
        Planejamento__c pla = new Planejamento__c(RecordTypeId = rtpla, Name = 'test', Ano_de_Referencia__c = String.valueOf(date.today().year()), M_s_de_Ref_rencia__c = 'Dezembro', Status_do_Planejamento__c = 'Approved');
        insert pla;
        
        String rtvis = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit');
        Visitas__c visit = new Visitas__c(Conta__c = acc.Id, Name = 'test', Data_da_Visita__c = date.newInstance(date.today().year(),12,31), Hora_da_Visita__c = '08:00', LAT_MX_Type__c = 'Activity Negotiation - On Trade', Planejamento__c = pla.Id, Resumo_da_Visita__c = 'test', LAT_MX_ClienteChannel__c = 'Off Trade', RecordTypeId = rtvis );
        insert visit;
        
        String rtcheck = Global_RecordTypeCache.getRtId('CLV_ChecklistVisita_ARG__c' + 'LAT_MX_CLV_ActivityNegotiationOn');
        CLV_ChecklistVisita_ARG__c check = new CLV_ChecklistVisita_ARG__c(RecordTypeId = rtcheck, Visit_AR__c = visit.Id);
        insert check;
        
        test.startTest();
        check.LAT_MX_Feedback__c = 'feedback'; 
        update check;
        system.debug('check' + check);
        
        system.runAs(usuario){
        	try{delete check;}catch(exception e){}
        }
        test.stopTest();
   }

      static testMethod void unitTestB() {
        
        Id profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator');     
        User usuario = new User(FirstName = 'Nome', LastName = 'Sobrenome', Alias = 'NSobre', Email = 'gerente@sobrenome.com', Username = 'devtestusercloud2b@cloud2b.com.br', CommunityNickname = '123jjjuuuG', EmailEncodingKey = 'ISO-8859-1', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_Us', LanguageLocaleKey = 'en_Us', C_digo_JDE__c = '234', ProfileId = ProfileId, Country = 'BR' );
        insert usuario;

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        Account acc = new Account(Name = 'TEST', AccountNumber = '1000', Type = 'Payer', Phone = '1-11-1111-1111', Fax = '11-1111-1111', Notes__c = 'TEST', AddressLine1_AR__c = 'TEST', CNPJ__c = 'LOZM701213E52', Corporate_Name__c = 'TEST', Channel__c = 'WS', Segmentation_Type_on_trade__c = 'MOP', RecordTypeId = rtOffMX);
        insert acc;
        
        String rtpla = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning');
        Planejamento__c pla = new Planejamento__c(RecordTypeId = rtpla, Name = 'test', Ano_de_Referencia__c = String.valueOf(date.today().year()), M_s_de_Ref_rencia__c = 'Dezembro', Status_do_Planejamento__c = 'Approved');
        insert pla;
        
        String rtvis = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit');
        Visitas__c visit = new Visitas__c(Conta__c = acc.Id, Name = 'test', Data_da_Visita__c = date.newInstance(date.today().year(),12,31), Hora_da_Visita__c = '08:00', LAT_MX_Type__c = 'Activity Negotiation - On Trade', Planejamento__c = pla.Id, Resumo_da_Visita__c = 'test', LAT_MX_ClienteChannel__c = 'Off Trade', RecordTypeId = rtvis );
        insert visit;
        
        String rtcheck = Global_RecordTypeCache.getRtId('CLV_ChecklistVisita_ARG__c' + 'LAT_MX_CLV_ActivityNegotiationOn');
        CLV_ChecklistVisita_ARG__c check = new CLV_ChecklistVisita_ARG__c(RecordTypeId = rtcheck, Visit_AR__c = visit.Id);
        insert check;
        
        test.startTest();
        check.LAT_MX_Feedback__c = 'feedback'; 
        update check;
        system.debug('check' + check);
        
        system.runAs(usuario){
            try{delete check;}catch(exception e){}
        }
        test.stopTest();
   }
}