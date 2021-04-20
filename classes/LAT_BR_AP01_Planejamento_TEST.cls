/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/

@isTest
public with sharing class LAT_BR_AP01_Planejamento_TEST {
	
	static testMethod void UnitTest2(){
		User usuario;
	    try{usuario = [SELECT Id, Name, ProfileId FROM User WHERE IsActive = true LIMIT 1];}catch(Exception e){}
			
		Planejamento__c plan0 = new Planejamento__c(Name = 'Test0', Ano_de_Referencia__c = '2012', M_s_de_Ref_rencia__c = 'Dezembro', Solicitar_aprova_o_para__c = 'Planejamento semana 2', Aprovado_semana_1__c = true, OwnerId = usuario.id );
		insert plan0;
			
		Visitas__c vis = new Visitas__c(Name = 'testVis', Planejamento__c = plan0.id, Hora_da_Visita__c = '01:00', Data_da_Visita__c = date.today().addDays(-3), Resumo_da_Visita__c = '123', Status__c = 'Planejada' );
		insert vis;
		
		plan0.Status_do_Planejamento__c = 'Aguardando Aprovação';
		
		//a fail message should appear
		try{update plan0;}catch(Exception e){}
	}
	
	static testMethod void UnitTest4(){
		
		User usuario;
	    try{usuario = [SELECT Id, Name, ProfileId FROM User WHERE IsActive = true LIMIT 1];}catch(Exception e){}
			
		Planejamento__c plan0 = new Planejamento__c(Name = 'Test0', Ano_de_Referencia__c = '2012', M_s_de_Ref_rencia__c = 'Dezembro', OwnerId = usuario.id );
		insert plan0;
		
		Planejamento__c plan = new Planejamento__c(Name = 'Test', Ano_de_Referencia__c = '2013', M_s_de_Ref_rencia__c = 'Janeiro', OwnerId = usuario.id );
		insert plan;
			
		Visitas__c vis = new Visitas__c(Name = 'testVis', Planejamento__c = plan0.id, Hora_da_Visita__c = '01:00', Data_da_Visita__c = date.today().addDays(-3), Resumo_da_Visita__c = '123', Status__c = 'Planejada' );
		insert vis;
		
		plan0.Status_do_Planejamento__c = 'Aguardando Aprovação';
		//a fail message should appear
		try{update plan0;}catch(Exception e){}
		
		plan.Status_do_Planejamento__c = 'Aguardando Aprovação';
		//a fail message should appear
		try{update plan;}catch(Exception e){}
	}

	static testMethod void testMonthlyPlanGenerator(){
		LAT_BR_Planejamento_Scheduler scheduler = new LAT_BR_Planejamento_Scheduler();
		scheduler.execute(null);

		

		Account braOnTrade               = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
		braOnTrade.OwnerId               = UserInfo.getUserId();
		insert braOnTrade;

		LAT_BR_Planejamento_Batch batch = new LAT_BR_Planejamento_Batch();
		Database.QueryLocator qLocator = batch.start(null);

		batch.execute(null, Database.Query(qLocator.getQuery()));

	}
	
}