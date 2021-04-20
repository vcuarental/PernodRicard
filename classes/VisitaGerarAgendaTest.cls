@isTest
/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* NAME: VisitaGerarAgendaTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE:
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
private class VisitaGerarAgendaTest {
    
    static testMethod void myUnitTest() {
        
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
        
        /* 
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
        try{insert usuario;}catch(Exception e){}*/
        
        //Cria nova UDC
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '01-01';
        regional.RecordTypeId = idRecTypeUDC;
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
        Account acc = new Account();
        acc.OwnerId = UserInfo.getUserId();//usuario.Id;
        acc.Name = 'Conta PlanejamentoVisitasCriaVisitasTeste';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade' );
        acc.Status__c = 'XXXX';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Channel__c = 'Off Trade';
        acc.Regional__c = regional.Id;
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '557799';
        acc.Channel_Type__c = 'Direto';
        //insert acc;
        try{insert acc;}catch(Exception e){system.debug('Exception ----->' + e.getMessage() + ' ' + e.getStackTraceString());}
            
        Planejamento__c plan = new Planejamento__c();
        plan.Ano_de_Referencia__c = '2012';
        plan.M_s_de_Ref_rencia__c = 'Janeiro';
        plan.Name = 'Teste';
        plan.OwnerId = UserInfo.getUserId();//usuario.Id;
        plan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
        //insert plan;
        try{insert plan;}catch(Exception e){}
        
        //VisitaGerarAgenda.processaBotao( plan.id );
        /*plan = new Planejamento__c();
        plan.Ano_de_Referencia__c = '2012';
        plan.M_s_de_Ref_rencia__c = 'Janeiro';
        plan.Name = 'Teste';
        plan.OwnerId = UserInfo.getUserId();//usuario.Id;
        plan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
        //insert plan;
        try{insert plan;}catch(Exception e){}*/
        
        Id idRecTypeVis = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard' );
        //Cria nova visita
        Visitas__c visita = new Visitas__c(
          Name = 'Teste',
          Data_da_Visita__c = System.today(),
          Hora_da_Visita__c = '08:00',
          Planejamento__c = plan.Id,
          Tipo_de_Visita__c = 'Execução',
          Conta__c = acc.Id,
          Status__c = 'Planejada',
          RecordTypeId = idRecTypeVis,
          Resumo_da_Visita__c = 'Teste'
        );
        //insert visita;
        try{insert visita;}catch(Exception e){}

        Id idRecTypeComp = RecordTypeForTest.getRecType( 'Event' , 'Planejamentovisitas' );
        List<Event> compromissos = [ SELECT AccountId, ActivityDateTime, Subject, WhatId 
                FROM Event WHERE WhatId =: visita.Id AND RecordTypeId =: idRecTypeComp limit 1];
        delete compromissos;

        Test.startTest();
            try{VisitaGerarAgenda.processaBotao( plan.id );}catch(Exception e){system.debug('Exception ----->' + e.getMessage() + ' ' + e.getStackTraceString());}
        Test.stopTest();
        /*visita.Data_da_Visita__c = system.today();
        visita.Hora_da_Visita__c =  '8:00';
        visita.Resumo_da_Visita__c = 'teste';
        //update visita;
        try{update visita;}catch(Exception e){}*/
        
        /*Id idRecTypeComp = RecordTypeForTest.getRecType( 'Event' , 'Planejamentovisitas' );
        Event lCompromisso = new Event();
        lCompromisso.ActivityDateTime = system.now();
        lCompromisso.Subject = 'Visita de teste';
        lCompromisso.WhatId = visita.id;
        lCompromisso.DurationInMinutes = 60;
        lCompromisso.RecordTypeId = idRecTypeComp;
        //insert lCompromisso;
        try{insert lCompromisso;}catch(Exception e){}*/
        
        //VisitaGerarAgenda.processaBotao( plan.id );
        //try{VisitaGerarAgenda.processaBotao( plan.id );}catch(Exception e){system.debug('Exception ----->' + e.getMessage() + ' ' + e.getStackTraceString());}
        
      
    }
}