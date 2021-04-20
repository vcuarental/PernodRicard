/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/

@isTest
public with sharing class LAT_CTR_GabaritodeExecucao_TEST { 
    
    static testMethod void unitTest(){
        
        String rtOffBRCWH = Global_RecordTypeCache.getRtId('LAT_CWH_ClientWorkHour__c' + 'LAT_BR_CWH_Standard');
        String rtOffBRPla = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard');
        String rtOffBRVis = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard');
        String rtOffBRCdV = Global_RecordTypeCache.getRtId('Checklist_de_visita__c' + 'On_Trade');
        
        Account acc = new Account(
			RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'), 
			CNPJ__c = '54651716001150',
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
			Client_code_AN8__c = '123697',
			Billing_Country__c ='test'
		);
		insert acc;
        
        Planejamento__c plan = new Planejamento__c(Name = 'Test', M_s_de_Ref_rencia__c = 'Janeiro', Ano_de_Referencia__c = '2013', RecordTypeId = rtOffBRPla);
        insert plan;
        
        Visitas__c vis = new Visitas__c(Name = 'TEST', Data_da_Visita__c = date.today(), Planejamento__c = plan.id, Hora_da_Visita__c = '02:00', Descrever_Motivo__c = 'Test', Resumo_da_Visita__c = 'Test', RecordTypeId = rtOffBRVis );
        insert vis;
        
        Checklist_de_visita__c cdvTest = new Checklist_de_visita__c(Visita__c = vis.Id, Tempo_Gasto_no_Cliente_Minutos__c = 12, RecordTypeId = rtOffBRCdV);
        insert cdvTest;
        
        Gabarito_de_Execucao__c gab = new Gabarito_de_Execucao__c(Checklist_de_Visita__c = cdvTest.Id);
        insert gab;
        
        test.startTest();
        
        cdvTest.LAT_BR_ValidOnTradeChecklistGE__c = true;
        update cdvTest;
        
        gab.Comentarios_gerais__c = 'hi';
        update gab;
        
        delete gab;
        
        test.stopTest();

    }
}