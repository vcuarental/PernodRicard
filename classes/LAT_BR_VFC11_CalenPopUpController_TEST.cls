/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:31/03/2014    *
*******************************************************************************/

@istest
public with sharing class LAT_BR_VFC11_CalenPopUpController_TEST {

    static testMethod void unitTest1(){
    
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
            
        Planejamento__c plan = new Planejamento__c(
            Name = 'Test', 
            M_s_de_Ref_rencia__c = 'Janeiro', 
            Ano_de_Referencia__c = '2013', 
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard')
        );
        insert plan;
        
        List<Visitas__c> listVisitas = new List<Visitas__c>();
        
        Visitas__c vis1 = new Visitas__c(
            Name = 'TEST', 
            Planejamento__c = plan.id, 
            Hora_da_Visita__c = '02:00', 
            Descrever_Motivo__c = 'Test', 
            Resumo_da_Visita__c = 'Test', 
            Data_da_Visita__c = Date.today().addDays(2),
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard') 
        );
        insert vis1;
        
        test.startTest();
        
        ApexPages.StandardController testController = new ApexPages.StandardController(vis1);
        ApexPages.currentPage().getparameters().put('idVisita', vis1.Id);
        LAT_BR_VFC11_CalenderPopUpController pagina = new LAT_BR_VFC11_CalenderPopUpController(testController);
              
        pagina.doSave();
        
        test.stopTest();
    
    }
    
    static testMethod void unitTest2(){
    
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
            
        Planejamento__c plan = new Planejamento__c(
            Name = 'Test', 
            M_s_de_Ref_rencia__c = 'Janeiro', 
            Ano_de_Referencia__c = '2013', 
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard')
        );
        insert plan;
        
        List<Visitas__c> listVisitas = new List<Visitas__c>();
        
        Visitas__c vis1 = new Visitas__c(
            Name = 'TEST', 
            Planejamento__c = plan.id, 
            Hora_da_Visita__c = '02:00', 
            Descrever_Motivo__c = 'Test', 
            Resumo_da_Visita__c = 'Test', 
            Data_da_Visita__c = Date.today().addDays(2),
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard') 
        );
        insert vis1;
        
        test.startTest();
        
        ApexPages.StandardController testController = new ApexPages.StandardController(vis1);
        Apexpages.currentPage().getParameters().put('date', 'Mon Mar 31 2014 09:00:00 GMT-0300 (ART)');
        Apexpages.currentPage().getParameters().put('idPlan', plan.Id);
        LAT_BR_VFC11_CalenderPopUpController pagina = new LAT_BR_VFC11_CalenderPopUpController(testController);
              
        pagina.doSave();
        
        test.stopTest();
    
    }
}