@IsTest
public with sharing class LAT_BR_VFC02_VisitasCalenController_TEST {

     static testMethod void unitTest1() {

        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'), 
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
        
        Planejamento__c planejamento = new Planejamento__c(
            Name = 'test planejamento',
            M_s_de_Ref_rencia__c = 'Janeiro'
        );
        insert planejamento;
        
        Visitas__c visita = new Visitas__c(
            Name = 'test visita',
            Tipo_de_Visita__c = 'Vendas',
            Hora_da_Visita__c = '10:00',
            Resumo_da_Visita__c = 'This is a test',
            Conta__c = acc.Id,
            Planejamento__c = planejamento.Id,
            Data_da_Visita__c = Date.today().addDays(2)
        );
        insert visita;
        
        test.startTest();
    
        ApexPages.currentPage().getparameters().put('idPlanejamento', planejamento.Id);
                
        LAT_BR_VFC02_VisitasCalenController testController = new LAT_BR_VFC02_VisitasCalenController();
        testcontroller.doVolver();
        
        test.stopTest();            
    }

        
     static testMethod void unitTest2() {
        
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
        listVisitas.add(vis1);
        
        Visitas__c vis2 = new Visitas__c(
            Name = 'TEST', 
            Planejamento__c = plan.id, 
            Hora_da_Visita__c = '02:00', 
            Descrever_Motivo__c = 'Test', 
            Resumo_da_Visita__c = 'Test', 
            Data_da_Visita__c = Date.today().addDays(2),
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard'),
            Visita_n_o_realizada__c = true,
            Poss_veis_motivos__c = 'Indisponibilidade do cliente' 
        );
        listVisitas.add(vis2);
        
        insert listVisitas;
        
        test.startTest();
    
        ApexPages.currentPage().getparameters().put('idPlanejamento', plan.Id);
        
        
        LAT_BR_VFC02_VisitasCalenController testController = new LAT_BR_VFC02_VisitasCalenController();
        testcontroller.doVolver();       
        testcontroller.listWrapper[0].isCheckbox = true;
        testcontroller.doRecuperar();
        test.stopTest();
                    
    }

}