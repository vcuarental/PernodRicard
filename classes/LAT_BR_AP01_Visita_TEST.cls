/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/
@isTest
public with sharing class LAT_BR_AP01_Visita_TEST {
	
	static testmethod void unitTest(){
		
        String rtOffBRCWH = Global_RecordTypeCache.getRtId('LAT_CWH_ClientWorkHour__c' + 'LAT_BR_CWH_Standard');
        String rtOffBRPla = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard');
        String rtOffBRVis = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard');
        
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
		Test.startTest();
		Planejamento__c plan = new Planejamento__c(Name = 'Test', M_s_de_Ref_rencia__c = 'Janeiro', Ano_de_Referencia__c = '2013', RecordTypeId = rtOffBRPla);
		insert plan;
		
		Visitas__c vis = new Visitas__c(Name = 'TEST', Planejamento__c = plan.id, Hora_da_Visita__c = '02:00', Descrever_Motivo__c = 'Test', Resumo_da_Visita__c = 'Test', RecordTypeId = rtOffBRVis );
		insert vis;
		Map<Id,Visitas__c> oldMap = new Map<Id,Visitas__c>();
		oldMap.put(vis.Id, vis);

		try{LAT_BR_AP01_Visita.updateEvent(new List<Visitas__c> {vis}, oldMap);}catch(Exception e){}
		try{LAT_BR_AP01_Visita.sendTAAIfClosed(new List<Visitas__c> {vis}, oldMap);}catch(Exception e){}
		try{LAT_BR_AP01_Visita.updatesPPCKey(new List<Visitas__c> {vis}, oldMap);}catch(Exception e){}
		
		Test.stopTest();
	}	
}