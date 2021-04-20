@IsTest
public with sharing class LAT_BR_VFC01_HisChecklistController_TEST {

	@IsTest
	static void unitTest() {
		RecordType rec = new RecordType(
        DeveloperName = 'ACC_1_OffTrade_ARG',
        Name = 'ACC_1_OffTrade_ARG', 
        SobjectType='Account');

        RecordType record = [select id, DeveloperName from RecordType where DeveloperName = 'ACC_1_OffTrade_ARG'];
        
        Account acc = new Account(
        RecordTypeId = record.Id, 
        CNPJ__c = '20354266645',
        Name = 'testAccount',
        Overdue__c = false,
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
        Billing_Country__c ='test',
        Status__c = 'Em análise - Crédito e Cobrança'
        );
		insert acc;
		
		Planejamento__c planejamento = new Planejamento__c();
		planejamento.Name = 'test planejamento';
		planejamento.M_s_de_Ref_rencia__c = 'Janeiro';
		insert planejamento;
		
		Visitas__c visita = new Visitas__c();
		visita.Name = 'test visita';
		visita.Tipo_de_Visita__c = 'Vendas';
		visita.Hora_da_Visita__c = '10:00';
		visita.Resumo_da_Visita__c = 'This is a test';
		visita.Conta__c = acc.Id;
		visita.Planejamento__c = planejamento.Id;
		visita.Data_da_Visita__c = Date.today().addDays(2);
		insert visita;
		
		ApexPages.currentPage().getparameters().put('idVisita', visita.Id);
		
		LAT_BR_VFC01_HisChecklistController testController = new LAT_BR_VFC01_HisChecklistController();
		testController.doDelete();
		testController.doEdit();
		testController.doVolver();
		testController.doPrevious();
		testController.doNext();
		
		Checklist_de_visita__c cdvTest = new Checklist_de_visita__c();
		cdvTest.Visita__c = visita.Id;
		insert cdvTest;
		ApexPages.currentPage().getparameters().put('idABorrar', cdvTest.Id);
		testController.doDelete();
	}

}