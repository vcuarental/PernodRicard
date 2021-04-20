@isTest
/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Teste da classe CasoTratamento
* NAME: CasoTratamentoTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 29/06/2012
* MODIFIED BY JEF WITH USER ID HARD-CODED WITH ONE ORG USER Jean-francois.bernard@pernod-ricard.com
*
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/

private class CasoTratamentoTest { 
    //type - reason - status

   static testMethod void myUnitTest() {
      createTest('Customer service', 'Cadastro de clientes','Análise/complementação de dados','Aprovado', 'Off Trade', false);
   }

   static testMethod void myUnitTest1() {
      createTest('Controladoria', 'Cadastro de clientes','Análise/complementação de dados','Aprovado', 'Off Trade', false);
   }

   static testMethod void myUnitTest2() {
      createTest('Customer service', 'Assinatura de contrato','Aprovação do cliente','Aprovado' , 'Off Trade', false);
   }
   
   static testMethod void myUnitTest3() {
      createTest('Customer service', 'Assinatura de contrato','Aprovação do cliente','Aprovado' , 'On Trade', false);
   }
   static testMethod void myUnitTest4() {
      createTest('Customer service', 'Assinatura de contrato','Coleta de assinatura do cliente','Aprovado' , 'On Trade', false);
   }


   static testMethod void myUnitTest5() {
      createTest('Customer service', 'Assinatura de contrato','Aprovação do cliente','Não aprovado' , 'On Trade', false);
   }
   static testMethod void myUnitTest6() {
      createTest('Customer service', 'Assinatura de contrato','Coleta de assinatura do cliente','Não aprovado' , 'On Trade', false);
   }

   static testMethod void myUnitTest7() {
      createTest('Customer service', 'Assinatura de contrato','Aprovação do cliente','Solicitação de ajuste na proposta' , 'On Trade', false);
   }


   static testMethod void myUnitTest8() {
      createTest('Customer service', 'Assinatura de contrato','Conferência de contrato','Fechado e resolvido' , 'On Trade', false);
   }
   static testMethod void myUnitTest9() {
      createTest('Customer service', 'Assinatura de contrato','Assinatura do procurador','Fechado e resolvido' , 'On Trade', false);
   }
   static testMethod void myUnitTest10() {
      createTest('Customer service', 'Assinatura de contrato','Assinatura da diretoria','Fechado e resolvido' , 'On Trade', false);
   }
   static testMethod void myUnitTest11() {
      createTest('Customer service', 'Assinatura de contrato','Encaminhar via assinada para o Consultor','Fechado e resolvido' , 'On Trade', false);
   }
   static testMethod void myUnitTest12() {
      createTest('Customer service', 'Assinatura de contrato','Providenciar correções de documentação','Fechado e resolvido' , 'On Trade', false);
   }
   static testMethod void myUnitTest13() {
      createTest('Customer service', 'Assinatura de contrato','Entregar contrato assinado ao cliente','Fechado e resolvido' , 'On Trade', false);
   }


   static testMethod void myUnitTest14() {
      createTest('Customer service', 'Alteração de contrato','Impressão do aditamento','Aprovado' , 'On Trade', false);
   }
   static testMethod void myUnitTest15() {
      createTest('Customer service', 'Alteração de contrato','Assinatura de aditamento','Aprovado' , 'Off Trade', false);
   }


   static testMethod void myUnitTest16() {
      createTest('Customer service', 'Alteração de contrato','Impressão do aditamento','Não aprovado' , 'On Trade', false);
   }

   static testMethod void myUnitTest17() {
      createTest('Customer service', 'Alteração de contrato','Assinatura de aditamento','Não aprovado' , 'Off Trade', false);
   }

   static testMethod void myUnitTest18() {
      createTest('Customer service', 'Assinatura de contrato','Conferência de contrato','Encaminhado para correções' , 'Off Trade', true);
   }


   static testMethod void myUnitTest19() {
      createTest('Customer service', 'Cancelamento de Contrato','Negociação de cancelamento/pagamento','Aprovado' , 'Off Trade',false);
   }


   //Ok Hasta aca

   static testMethod void myUnitTest20() {
      createTest('Customer service', 'Cancelamento de Contrato','Negociação de cancelamento/pagamento','Não aprovado' , 'On Trade',false);
   }

 
   static testMethod void myUnitTest21() {
      createTest('Customer service', 'Cancelamento de Contrato','Providenciar assinatura do distrato','Não aprovado' , 'On Trade',false);
   }

   static testMethod void myUnitTest22() {
      createTest('Customer service', 'Cancelamento de Contrato','Conferência de distrato','Fechado e resolvido' , 'On Trade',false);
   }
   
   static testMethod void myUnitTest23() {
      createTest('Customer service', 'Cancelamento de Contrato','Providenciar assinatura do procurador','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTest24() {
      createTest('Customer service', 'Cancelamento de Contrato','Providenciar assinatura da Diretoria','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTest25() {
      createTest('Customer service', 'Cancelamento de Contrato','Encaminhar distrato para o consultor','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTest26() {
      createTest('Customer service', 'Cancelamento de Contrato','Entregar via do distrato ao cliente','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTest27() {
      createTest('Customer service', 'Cancelamento de Contrato','Entregar distrato assinado ao cliente','Fechado e resolvido' , 'On Trade',false);
   }
   
   static testMethod void myUnitTest28() {
      createTest('Customer service', 'Alteração de contrato','Assinatura de aditamento','Não aprovado' , 'Off Trade',false);
   }
   static testMethod void myUnitTest29() {
      createTest('Customer service', 'Alteração de contrato','Conferência de aditamento','Encaminhado para correções' , 'Off Trade',false);
   }
   static testMethod void myUnitTest30() {
      createTest('Customer service', 'Alteração de contrato','Conferência de aditamento','Encaminhado para correções' , 'On Trade',false);
   }
   static testMethod void myUnitTest31() {
      createTest('Customer service', 'Alteração de contrato','Impressão do aditamento','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTest32() {
      createTest('Customer service', 'Alteração de contrato','Assinatura do procurador','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTest33() {
      createTest('Customer service', 'Alteração de contrato','Assinatura da diretoria','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTest34() {
      createTest('Customer service', 'Alteração de contrato','Conferência de aditamento','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTest35() {
      createTest('Customer service', 'Alteração de contrato','Encaminhar aditamento para o consultor','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTest36() {
      createTest('Customer service', 'Alteração de contrato','Entregar aditamento assinado ao cliente','Fechado e resolvido' , 'On Trade',false);
   }

   static testMethod void myUnitTest37() {
      createTest('Customer service', 'Prorrogação de Contrato','Prorrogação de contrato não aprovada','Não aprovado pelo cliente' , 'On Trade',true);
   }
   static testMethod void myUnitTest38() {
      createTest('Customer service', 'Renovação de Contrato','Solicitar aprovação do cliente','Não aprovado' , 'On Trade',true);
   }
   static testMethod void myUnitTest39() {
      createTest('Customer service', 'Não Renovação de Contrato','Carta de não renovação de contrato','Fechado e resolvido' , 'On Trade',true);
   }

   
   

   public static void createTest(String nombreGrupo, String caseType, String caseReason, String caseStatus, String channel, Boolean needMoreFields){
      Id idRecTypeUdc =  [SELECT id,Name FROM RecordType WHERE SobjectType='UDC__c' AND DeveloperName = 'BRA_Standard' Limit 1].id;
      Profile perfil =  [SELECT Id, Name, Description FROM Profile WHERE UserType = 'Standard' AND PermissionsAuthorApex = true AND name != 'System Administrator SESAME'  LIMIT 1];     
     

      User gerente = new User();
      gerente.FirstName           = 'Nome';
      gerente.LastName            = 'SobrenomeC';
      gerente.Alias               = 'NSobreC';
      gerente.Email               = 'gerenteC@sobrenome.com';
      gerente.Username            = 'devtestusercloud2b@cloud2b.com.br';
      gerente.CommunityNickname   = '123jjjuuu';
      gerente.EmailEncodingKey    = 'ISO-8859-1';
      gerente.TimeZoneSidKey      = 'GMT';
      gerente.LocaleSidKey        = 'en_Us';
      gerente.LanguageLocaleKey   = 'en_Us';
      gerente.C_digo_JDE__c       = '234';
      gerente.ProfileId           = perfil.Id;
      gerente.Country = 'BR';
        
      insert gerente;
      User usuario = new User();
      usuario.FirstName = 'nome';
      usuario.LastName = 'Sobrenome';
      usuario.Alias = 'NSobreU';
      usuario.Email = 'usuarioC@sobrenome.com';
      usuario.Username = 'devtestusercloud2b2@cloud2b.com.br';
      usuario.CommunityNickname = '1234jjuuu';
      usuario.EmailEncodingKey = 'ISO-8859-1';
      usuario.TimeZoneSidKey = 'GMT';
      usuario.LocaleSidKey = 'en_Us';
      usuario.LanguageLocaleKey = 'en_Us';
      usuario.C_digo_JDE__c = '235';
      usuario.ProfileId = perfil.Id;
      usuario.Country = 'BR';
      usuario.Gerente_de_area__c  = gerente.Id;
      usuario.Gerente_regional__c = gerente.Id;

    
      insert usuario;

      Account acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'Conta teste Trigger';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.Status__c = 'Cliente cadastrado no CRM';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade');
      acc.Channel__c = channel;
      acc.Segmentation_Type_on_trade__c  = 'Bar';
      acc.Area_Manager__c = gerente.Id;
      acc.Regional_Manager__c = gerente.Id;   
      
      insert acc;       
  
      test.startTest();
      System.runAs(usuario){     

         LAT_Contract__c lContract = new LAT_Contract__c();
         lContract.OwnerId = usuario.Id;
         lContract.Account__c = acc.Id;
         lContract.Status__c = 'Em elaboração';
         lContract.StartDate__c = System.today();
         lContract.ContractTerm__c = 12;
         lContract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade');
         lContract.Motivo_de_cancelamento_do_contrato__c = 'Fechamento da casa';
         lContract.Status_do_processo__c = 'Solicitação de cancelamento de contrato';
         if(needMoreFields)
            lContract.Status_do_processo__c = 'Prorrogação de contrato não aprovada';
         insert lContract;

         Group g = createGroup(nombreGrupo);

         Case lCaso = createCase(caseType,caseReason,caseStatus, lContract, g, needMoreFields);

         insert lCaso;
         update lCaso;

      }
      test.stopTest();
   }

   public static Group createGroup(String queueName) {

         Group g = new Group(Type='Queue', Name=queueName);
       
         insert g;
        
         QueueSobject lQueue = new QueueSobject();
         lQueue.SobjectType = 'Case';
         lQueue.QueueId = g.id;
        
         insert lQueue;
         return g;
        
   }

   

   public static Case createCase(String caseType, String caseReason,  String caseStatus ,LAT_Contract__c  lContract, Group g, Boolean needMoreFields) {

      Case lCaso = new Case();
      lCaso.Type = caseType;
      lCaso.Status = caseStatus;
      lCaso.Reason = caseReason;
      lCaso.OwnerId = g.Id;
      lCaso.AccountId = lContract.account__c;
      lCaso.LAT_Contract__c = lContract.id;
      lCaso.RecordTypeId = RecordTypeForTest.getRecType('Case', 'Contrato');
      lCaso.Company_Signatory_2__c = 'test'; 
      lCaso.Company_Signatory__c = 'test';

      if(needMoreFields){
         lCaso.Action_Proposal__c = 'Prorrogação do contrato';
         lCaso.Contract_Deadline_months__c = 1;
      }   

      return lCaso;   
   }


}