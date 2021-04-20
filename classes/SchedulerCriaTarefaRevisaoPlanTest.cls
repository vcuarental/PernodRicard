@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura do scheduler SchedulerCriaTarefaRevisaoPlanejamento.cls
* NAME: SchedulerCriaTarefaRevisaoPlanTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 05/06/2012
*
* MAINTENANCE
* AUTHOR:                                           DATE: 
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 15/11/2016
*
********************************************************************************/
private class SchedulerCriaTarefaRevisaoPlanTest 
{
   static testMethod void SchedulerCriaTarefaRevisaoPlanTest() 
   {
    
      //Inicia o teste
      Test.startTest();
      Utils.setMigrationDoneTest(false);      
      //Declaração de variáveis.
      Account acc                           = null;
      UDC__c regional, bandeira, cidade     = null;
      Profile perfil                        = null;
      Opportunity opp                       = null;
      OpportunityLineItem oli               = null;
      User usuario                          = null;
      Product2 produto                      = null;
      Pricebook2 pricebook                  = null;
      Visitas__c visita                     = null;
      Planejamento__c plan                  = null;
      PricebookEntry pbe                    = null;
      List<RecordType> listRecType          = null;
      List<String> developerName            = null;
      Map<String, String> mapRecType        = null;
      String idAccount                      = null;
      String idOpportunity                  = null;
      Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
      Id idRecTypePlan = RecordTypeForTest.getRecType( 'Planejamento__c' , 'BRA_Standard' );
      
      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','On_Trade');
      
      //Cria novo usuario.
      usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
      insert usuario;
    
      //Cria nova UDC.
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '01-01';
      regional.RecordTypeId = idRecTypeUDC;
      insert regional;
      
      //Cria nova UDC.
      bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '01-06';
      bandeira.RecordTypeId = idRecTypeUDC;
      insert bandeira;
    
      //Cria novo Account.
      acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.RecordTypeId = idAccount;
      acc.Status__c = 'Cliente cadastrado no JDE';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.Channel__c = 'Off Trade';
      acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Channel_Type__c = 'Direto';
      acc.Client_code_AN8__c = '557798';
      acc.Price_Group__c = '1';
      acc.Customer_Flag__c = bandeira.Id;
      insert acc;
      
      //Cria novo planejamento.
      plan = new Planejamento__c();
      plan.Ano_de_Referencia__c = '2012';
      plan.M_s_de_Ref_rencia__c = 'Fevereiro';
      plan.Name = 'Teste';
      plan.OwnerId = usuario.Id;
      plan.RecordTypeId = idRecTypePlan;
      insert plan;
      
      //Agenda o SCHEDULER de teste.
      String jobId = System.schedule('SchedulerCriaTarefaRevisaoPlanejamentoTest', SchedulerCriaTarefaRevisaoPlanejamento.CRON_EXP, new SchedulerCriaTarefaRevisaoPlanejamento());
      
      //Recupera as informações da API do objeto CronTrigger.
      CronTrigger ct = [SELECT Id,
                   CronExpression, 
                   TimesTriggered, 
                   NextFireTime 
                   FROM CronTrigger 
                   WHERE id = :jobId
               ];
               
 
      Test.stopTest();
    
   }

   static testMethod void SchedulerCriaTarefaRevisaoPlanTest2() 
   {
    
      //Inicia o teste
      Test.startTest();
      Utils.setMigrationDoneTest(true);      
      //Declaração de variáveis.
      Account acc                           = null;
      UDC__c regional, bandeira, cidade     = null;
      Profile perfil                        = null;
      LAT_Opportunity__c opp                       = null;
      LAT_OpportunityLineItem__c oli               = null;
      User usuario                          = null;
      LAT_Product__C produto                      = null;

      Visitas__c visita                     = null;
      Planejamento__c plan                  = null;
      List<RecordType> listRecType          = null;
      List<String> developerName            = null;
      Map<String, String> mapRecType        = null;
      String idAccount                      = null;
      String idOpportunity                  = null;
      Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
      Id idRecTypePlan = RecordTypeForTest.getRecType( 'Planejamento__c' , 'BRA_Standard' );
      
      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','On_Trade');
      

    
      //Cria nova UDC.
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '01-01';
      regional.RecordTypeId = idRecTypeUDC;
      insert regional;
      
      //Cria nova UDC.
      bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '01-06';
      bandeira.RecordTypeId = idRecTypeUDC;
      insert bandeira;

      //Cria novo usuario.
      usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
      insert usuario;

      //Cria novo Account.
      acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.RecordTypeId = idAccount;
      acc.Status__c = 'Cliente cadastrado no JDE';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.Channel__c = 'Off Trade';
      acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Channel_Type__c = 'Direto';
      acc.Client_code_AN8__c = '557798';
      acc.Price_Group__c = '1';
      acc.Customer_Flag__c = bandeira.Id;
      insert acc;
      
      //Cria novo planejamento.
      plan = new Planejamento__c();
      plan.Ano_de_Referencia__c = '2012';
      plan.M_s_de_Ref_rencia__c = 'Fevereiro';
      plan.Name = 'Teste';
      plan.OwnerId = usuario.Id;
      plan.RecordTypeId = idRecTypePlan;
      insert plan;
      
      //Agenda o SCHEDULER de teste.
      String jobId = System.schedule('SchedulerCriaTarefaRevisaoPlanejamentoTest', SchedulerCriaTarefaRevisaoPlanejamento.CRON_EXP, new SchedulerCriaTarefaRevisaoPlanejamento());
      
      //Recupera as informações da API do objeto CronTrigger.
      CronTrigger ct = [SELECT Id,
                   CronExpression, 
                   TimesTriggered, 
                   NextFireTime 
                   FROM CronTrigger 
                   WHERE id = :jobId
               ];
               
 
      Test.stopTest();
    
   }

}