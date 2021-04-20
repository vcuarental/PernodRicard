/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@isTest
private class CasoTratamentoTestExtension {

	static testMethod void myUnitTestB() {
      createLatCase('Customer service', 'Cadastro de clientes','Análise/complementação de dados','Aprovado', 'Off Trade', false);
   }

   static testMethod void myUnitTestB1() {
      createLatCase('Controladoria', 'Cadastro de clientes','Análise/complementação de dados','Aprovado', 'Off Trade', false);
   }

   static testMethod void myUnitTestB2() {  
      createLatCase('Customer service', 'Assinatura de contrato','Aprovação do cliente','Aprovado' , 'Off Trade', false);
   }
   
   static testMethod void myUnitTestB3() {
      createLatCase('Customer service', 'Assinatura de contrato','Aprovação do cliente','Aprovado' , 'On Trade', false);
   }
   static testMethod void myUnitTestB4() {
      createLatCase('Customer service', 'Assinatura de contrato','Coleta de assinatura do cliente','Aprovado' , 'On Trade', false);
   }


   static testMethod void myUnitTestB5() {
      createLatCase('Customer service', 'Assinatura de contrato','Aprovação do cliente','Não aprovado' , 'On Trade', false);
   }
   static testMethod void myUnitTestB6() {
      createLatCase('Customer service', 'Assinatura de contrato','Coleta de assinatura do cliente','Não aprovado' , 'On Trade', false);
   }

   static testMethod void myUnitTestB7() {
      createLatCase('Customer service', 'Assinatura de contrato','Aprovação do cliente','Solicitação de ajuste na proposta' , 'On Trade', false);
   }


   static testMethod void myUnitTestB8() {
      createLatCase('Customer service', 'Assinatura de contrato','Conferência de contrato','Fechado e resolvido' , 'On Trade', false);
   }
   static testMethod void myUnitTestB9() {
      createLatCase('Customer service', 'Assinatura de contrato','Assinatura do procurador','Fechado e resolvido' , 'On Trade', false);
   }
   static testMethod void myUnitTestB10() {
      createLatCase('Customer service', 'Assinatura de contrato','Assinatura da diretoria','Fechado e resolvido' , 'On Trade', false);
   }
   static testMethod void myUnitTestB11() {
      createLatCase('Customer service', 'Assinatura de contrato','Encaminhar via assinada para o Consultor','Fechado e resolvido' , 'On Trade', false);
   }
   static testMethod void myUnitTestB12() {
      createLatCase('Customer service', 'Assinatura de contrato','Providenciar correções de documentação','Fechado e resolvido' , 'On Trade', false);
   }
   static testMethod void myUnitTestB13() {
      createLatCase('Customer service', 'Assinatura de contrato','Entregar contrato assinado ao cliente','Fechado e resolvido' , 'On Trade', false);
   }


   static testMethod void myUnitTestB14() {
      createLatCase('Customer service', 'Alteração de contrato','Impressão do aditamento','Aprovado' , 'On Trade', false);
   }
   static testMethod void myUnitTestB15() {
      createLatCase('Customer service', 'Alteração de contrato','Assinatura de aditamento','Aprovado' , 'Off Trade', false);
   }


   static testMethod void myUnitTestB16() {
      createLatCase('Customer service', 'Alteração de contrato','Impressão do aditamento','Não aprovado' , 'On Trade', false);
   }

   static testMethod void myUnitTestB17() {
      createLatCase('Customer service', 'Alteração de contrato','Assinatura de aditamento','Não aprovado' , 'Off Trade', false);
   }

   static testMethod void myUnitTestB18() {
      createLatCase('Customer service', 'Assinatura de contrato','Conferência de contrato','Encaminhado para correções' , 'Off Trade', true);
   }


   static testMethod void myUnitTestB19() {
      createLatCase('Customer service', 'Cancelamento de Contrato','Negociação de cancelamento/pagamento','Aprovado' , 'Off Trade',false);
   }


   static testMethod void myUnitTestB20() {
      createLatCase('Customer service', 'Cancelamento de Contrato','Negociação de cancelamento/pagamento','Não aprovado' , 'On Trade',false);
   }

 
   static testMethod void myUnitTestB21() {
      createLatCase('Customer service', 'Cancelamento de Contrato','Providenciar assinatura do distrato','Não aprovado' , 'On Trade',false);
   }

   static testMethod void myUnitTestB22() {
      createLatCase('Customer service', 'Cancelamento de Contrato','Conferência de distrato','Fechado e resolvido' , 'On Trade',false);
   }
   
   static testMethod void myUnitTestB23() {
      createLatCase('Customer service', 'Cancelamento de Contrato','Providenciar assinatura do procurador','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTestB24() {
      createLatCase('Customer service', 'Cancelamento de Contrato','Providenciar assinatura da Diretoria','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTestB25() {
      createLatCase('Customer service', 'Cancelamento de Contrato','Encaminhar distrato para o consultor','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTestB26() {
      createLatCase('Customer service', 'Cancelamento de Contrato','Entregar via do distrato ao cliente','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTestB27() {
      createLatCase('Customer service', 'Cancelamento de Contrato','Entregar distrato assinado ao cliente','Fechado e resolvido' , 'On Trade',false);
   }
   
   static testMethod void myUnitTestB28() {
      createLatCase('Customer service', 'Alteração de contrato','Assinatura de aditamento','Não aprovado' , 'Off Trade',false);
   }
   static testMethod void myUnitTestB29() {
      createLatCase('Customer service', 'Alteração de contrato','Conferência de aditamento','Encaminhado para correções' , 'Off Trade',false);
   }
   static testMethod void myUnitTestB30() {
      createLatCase('Customer service', 'Alteração de contrato','Conferência de aditamento','Encaminhado para correções' , 'On Trade',false);
   }
   static testMethod void myUnitTestB31() {
      createLatCase('Customer service', 'Alteração de contrato','Impressão do aditamento','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTestB32() {
      createLatCase('Customer service', 'Alteração de contrato','Assinatura do procurador','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTestB33() {
      createLatCase('Customer service', 'Alteração de contrato','Assinatura da diretoria','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTestB34() {
      createLatCase('Customer service', 'Alteração de contrato','Conferência de aditamento','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTestB35() {
      createLatCase('Customer service', 'Alteração de contrato','Encaminhar aditamento para o consultor','Fechado e resolvido' , 'On Trade',false);
   }
   static testMethod void myUnitTestB36() {
      createLatCase('Customer service', 'Alteração de contrato','Entregar aditamento assinado ao cliente','Fechado e resolvido' , 'On Trade',false);
   }

   static testMethod void myUnitTestB37() {
      createLatCase('Customer service', 'Prorrogação de Contrato','Prorrogação de contrato não aprovada','Não aprovado pelo cliente' , 'On Trade',true);
   }
   static testMethod void myUnitTestB38() {
      createLatCase('Customer service', 'Renovação de Contrato','Solicitar aprovação do cliente','Não aprovado' , 'On Trade',true);
   }
   static testMethod void myUnitTestB39() {
      createLatCase('Customer service', 'Não Renovação de Contrato','Carta de não renovação de contrato','Fechado e resolvido' , 'On Trade',true);
   }
	
	//MIGRATED 21/11/2016
   public static void createLatCase(String nombreGrupo, String caseType, String caseReason, String caseStatus, String channel, Boolean needMoreFields){
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

         Group g = createGroupB(nombreGrupo);

         LAT_Case__c lCaso = createLATCase(caseType,caseReason,caseStatus, lContract, g, needMoreFields);

         insert lCaso;
         update lCaso;

      }
      test.stopTest();
   }

   public static Group createGroupB(String queueName) {

         Group g = new Group(Type='Queue', Name=queueName);
       
         insert g;
        
         QueueSobject lQueue = new QueueSobject();
         lQueue.SobjectType = 'LAT_Case__c';
         lQueue.QueueId = g.id;
        
         insert lQueue;
         return g;
        
   }
   //MIGRATED 21/11/2016
   public static LAT_Case__c createLATCase(String caseType, String caseReason,  String caseStatus ,LAT_Contract__c  lContract, Group g, Boolean needMoreFields) {

      LAT_Case__c lCaso = new LAT_Case__c();
      lCaso.LAT_Type__c = caseType;
      lCaso.LAT_Status__c = caseStatus;
      lCaso.LAT_Reason__c = caseReason;
      lCaso.OwnerId = g.Id;
      lCaso.LAT_Account__c = lContract.account__c;
      lCaso.LAT_Contract__c = lContract.id;
      lCaso.RecordTypeId = RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato');
      lCaso.LAT_CompanySignatory2__c = 'test'; 
      lCaso.LAT_CompanySignatory__c = 'test';

      if(needMoreFields){
         lCaso.LAT_ActionProposal__c = 'Prorrogação do contrato';
         lCaso.LAT_ContractDeadlinemonths__c = 1;
      }   

      return lCaso;   
   }
}