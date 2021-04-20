@isTest
private class LAT_BR_LATCase_Tratamento_Test {
	
static testMethod void myUnitTest() {
   
      createUpdateTest('Customer service', 'Cadastro de clientes','Análise/complementação de dados','Novo','Aprovado', 'Off Trade', false);
   }

   static testMethod void myUnitTest1() {
      createUpdateTest('Controladoria', 'Cadastro de clientes','Análise/complementação de dados','Novo','Aprovado', 'Off Trade', false);
   }

   static testMethod void myUnitTest3() {
      createUpdateTest('Customer service', 'Assinatura de contrato','Aprovação do cliente','Novo' ,'Aprovado', 'On Trade', false);
   }
   static testMethod void myUnitTest4() {
      createUpdateTest('Customer service', 'Assinatura de contrato','Coleta de assinatura do cliente','Novo','Aprovado' , 'On Trade', false);
   }

      static testMethod void myUnitTest103() {
      createUpdateTest('Customer service', 'Assinatura de contrato','Aprovação do cliente','Novo' ,'Aprovado', 'Off Trade', false);
   }
   static testMethod void myUnitTest104() {
      createUpdateTest('Customer service', 'Assinatura de contrato','Coleta de assinatura do cliente','Novo','Aprovado' , 'Off Trade', false);
   }
   static testMethod void myUnitTest105() {
      createUpdateTest('Customer service', 'Assinatura de contrato','Coleta de assinatura do cliente','Novo','Não aprovado' , 'On Trade', false);
   }

      static testMethod void myUnitTest106() {
      createUpdateTest('Customer service', 'Assinatura de contrato','Aprovação do cliente','Novo' ,'Não aprovado', 'Off Trade', false);
   }

    static testMethod void myUnitTest2() {
      createUpdateTest('Crédito e cobrança', 'Assinatura de contrato','Aprovação do cliente','Novo','Solicitação de ajuste na proposta',  'Off Trade', false);
   }

   static testMethod void myUnitTest102() {
      createUpdateTest('Planejamento comercial', 'Assinatura de contrato','Conferência de contrato','Novo' ,'Fechado e resolvido',  'Off Trade', false);
   }
   static testMethod void myUnitTest107() {
      createUpdateTest('Planejamento comercial', 'Assinatura de contrato','Assinatura do procurador','Novo' ,'Fechado e resolvido',  'Off Trade', false);
   }
   static testMethod void myUnitTest108() {
      createUpdateTest('Planejamento comercial', 'Assinatura de contrato','Assinatura da diretoria','Novo' ,'Fechado e resolvido',  'Off Trade', false);
   }
   static testMethod void myUnitTest109() {
      createUpdateTest('Planejamento comercial', 'Assinatura de contrato','Encaminhar via assinada para o Consultor','Novo' ,'Fechado e resolvido',  'Off Trade', false);
   }
   static testMethod void myUnitTest110() {
      createUpdateTest('Planejamento comercial', 'Assinatura de contrato','Providenciar correções de documentação','Novo' ,'Fechado e resolvido',  'Off Trade', false);
   }
   static testMethod void myUnitTest111() {
      createUpdateTest('Planejamento comercial', 'Assinatura de contrato','Entregar contrato assinado ao cliente','Novo' ,'Fechado e resolvido',  'Off Trade', false);
   }
   static testMethod void myUnitTest112() {
      createUpdateTest('Customer service', 'Alteração de contrato','Impressão do aditamento','Novo' ,'Aprovado', 'On Trade', false);
   }
   static testMethod void myUnitTest113() {
      createUpdateTest('Customer service', 'Alteração de contrato','Assinatura de aditamento','Novo','Aprovado' , 'Off Trade', false);
   }

      static testMethod void myUnitTest114() {
      createUpdateTest('Customer service', 'Alteração de contrato','Impressão do aditamento','Novo' ,'Não aprovado', 'On Trade', false);
   }
   static testMethod void myUnitTest115() {
      createUpdateTest('Customer service', 'Alteração de contrato','Assinatura de aditamento','Novo','Não aprovado' , 'Off Trade', false);
   }
   
   static testMethod void myUnitTest117() {
      createUpdateTest('Customer service', 'Alteração de contrato','Conferência de aditamento','Novo' ,'Encaminhado para correções', 'Off Trade', false);
   }
   static testMethod void myUnitTest118() {
      createUpdateTest('Customer service', 'Alteração de contrato','Conferência de aditamento','Novo' ,'Encaminhado para correções', 'On Trade', false);
  }

      static testMethod void myUnitTest119() {
      createUpdateTest('Customer service', 'Alteração de contrato','Impressão do aditamento','Novo' ,'Fechado e resolvido', 'On Trade', false);
   }
   static testMethod void myUnitTest120() {
      createUpdateTest('Customer service', 'Alteração de contrato','Assinatura do procurador','Novo','Não aprovado' , 'Off Trade', false);
   }
   static testMethod void myUnitTest121() {
      createUpdateTest('Customer service', 'Alteração de contrato','Assinatura da diretoria','Novo','Não aprovado' , 'Off Trade', false);
   }
   static testMethod void myUnitTest122() {
      createUpdateTest('Customer service', 'Alteração de contrato','Conferência de aditamento','Novo','Não aprovado' , 'Off Trade', false);
   }
   static testMethod void myUnitTest123() {
      createUpdateTest('Customer service', 'Alteração de contrato','Encaminhar aditamento para o consultor','Novo','Não aprovado' , 'Off Trade', false);
   }
   static testMethod void myUnitTest124() {
      createUpdateTest('Customer service', 'Alteração de contrato','Entregar aditamento assinado ao cliente','Novo','Não aprovado' , 'Off Trade', false);
   }
  static testMethod void myUnitTest125() {
      createUpdateTest('Customer service', 'Cancelamento de Contrato','Negociação de cancelamento/pagamento','Novo','Aprovado' , 'Off Trade', false);
   }
   /*static testMethod void myUnitTest126() {
      createUpdateTest('Customer service', 'Cancelamento de Contrato','Providenciar assinatura do distrato','Novo','Aprovado' , 'Off Trade', true);
   }*/
   
   static testMethod void myUnitTest127() {
      createUpdateTest('Customer service', 'Cancelamento de Contrato','Negociação de cancelamento/pagamento','Novo','Não aprovado' , 'Off Trade', false);
   }
   static testMethod void myUnitTest128() {
      createUpdateTest('Customer service', 'Cancelamento de Contrato','Providenciar assinatura do distrato','Novo','Não aprovado' , 'Off Trade', false);
   }
   static testMethod void myUnitTest129() {
      createUpdateTest('Customer service', 'Cancelamento de Contrato','Conferência de distrato','Novo','Fechado e resolvido' , 'Off Trade', false);
   }
   static testMethod void myUnitTest130() {
      createUpdateTest('Customer service', 'Cancelamento de Contrato','Providenciar assinatura do procurador','Novo','Fechado e resolvido' , 'Off Trade', false);
   }   
   static testMethod void myUnitTest131() {
      createUpdateTest('Customer service', 'Cancelamento de Contrato','Providenciar assinatura da Diretoria','Novo','Fechado e resolvido' , 'Off Trade', false);
   }   
   static testMethod void myUnitTest132() {
      createUpdateTest('Customer service', 'Cancelamento de Contrato','Encaminhar distrato para o consultor','Novo','Fechado e resolvido' , 'Off Trade', false);
   }   
   static testMethod void myUnitTest133() {
      createUpdateTest('Customer service', 'Cancelamento de Contrato','Entregar via do distrato ao cliente','Novo','Fechado e resolvido' , 'Off Trade', false);
   }
   static testMethod void myUnitTest134() {
      createUpdateTest('Customer service', 'Cancelamento de Contrato','Entregar distrato assinado ao cliente','Novo','Fechado e resolvido' , 'Off Trade', false);
   }/*
   static testMethod void myUnitTest135() {
      createUpdateTest('Customer service', 'Prorrogação de Contrato','Negociar prorrogação de contrato','Novo','Aprovado' , 'Off Trade', true);
   }  */ 
   static testMethod void myUnitTest136() {
      createUpdateTest('Customer service', 'Prorrogação de Contrato','Negociar prorrogação de contrato','Novo','Fechado e cancelado' , 'Off Trade', true);
   }   
   
   static testMethod void myUnitTest137() {
      createUpdateTest('Customer service', 'Prorrogação de Contrato','Prorrogação de contrato não aprovada','Novo','Não aprovado pelo cliente' , 'Off Trade', true);
   }   
   static testMethod void myUnitTest138() {
      createUpdateTest('Customer service', 'Prorrogação de Contrato','Entregar via do distrato ao cliente','Novo','Fechado e resolvido' , 'Off Trade', false);
   }
   static testMethod void myUnitTest139() {
      createUpdateTest('Customer service', 'Prorrogação de Contrato','Entregar distrato assinado ao cliente','Novo','Fechado e resolvido' , 'Off Trade', false);
   }
  static testMethod void myUnitTest140() {
      createUpdateTest('Customer service', 'Renovação de Contrato','Solicitar aprovação do cliente','Novo','Aprovado' , 'Off Trade', false);
   }   
   static testMethod void myUnitTest141() {
      createUpdateTest('Customer service', 'Renovação de Contrato','Solicitar aprovação do cliente','Novo','Não aprovado' , 'Off Trade', false);
   }
   static testMethod void myUnitTest142() {
      createUpdateTest('Customer service', 'Não Renovação de Contrato','Carta de não renovação de contrato','Novo','Fechado e resolvido' , 'Off Trade', false);
   }

   
   

   public static void createTest(String nombreGrupo, String caseType, String caseReason, String caseStatus, String channel, 
   								Boolean needMoreFields){
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

	         LAT_Case__C lCaso = createCase(caseType,caseReason,caseStatus, lContract, g, needMoreFields);

	         insert lCaso;
	         update lCaso;

	      }
	      test.stopTest();
    }

   public static void createUpdateTest(String nombreGrupo, String caseType, String caseReason, String caseStatusInit, String caseStatusUpdate, 
   	String channel, Boolean needMoreFields){
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
	      String accChannel = (channel=='On Trade')?'On_Trade':'Off_Trade';

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
	      acc.RecordTypeId = RecordTypeForTest.getRecType('Account', accChannel);
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


		   

	         LAT_Case__C lCaso = createCase(caseType,caseReason,caseStatusInit, lContract, g, needMoreFields);

	         insert lCaso;
	         lCaso.LAT_Status__c = caseStatusUpdate;
	         update lCaso;

	      }
	      test.stopTest();
    }

   public static Group createGroup(String queueName) {

         Group g = new Group(Type='Queue', Name=queueName);
       
         insert g;
        
         QueueSobject lQueue = new QueueSobject();
         lQueue.SobjectType = 'LAT_Case__c';
         lQueue.QueueId = g.id;
        
         insert lQueue;
         return g;
        
   }

   

   public static LAT_Case__c createCase(String caseType, String caseReason,  String caseStatus ,LAT_Contract__c  lContract, Group g, Boolean needMoreFields) {

      LAT_Case__c lCaso = new LAT_Case__c();
      lCaso.LAT_Type__c = caseType;
      lCaso.LAT_Status__c = caseStatus;
      lCaso.LAT_Reason__c = caseReason;
      lCaso.OwnerId = g.Id;
      lCaso.LAT_Account__c = lContract.account__c;
      lCaso.LAT_Contract__c = lContract.id;
      if(needMoreFields && caseReason =='Negociar prorrogação de contrato'){
         lCaso.RecordTypeId = RecordTypeForTest.getRecType('LAT_Case__c', 'Inserir_o_Tipo_de_Verba');

      } else {
         lCaso.RecordTypeId = RecordTypeForTest.getRecType('LAT_Case__c', 'Contrato');
      }
      
      lCaso.LAT_CompanySignatory2__c = 'test'; 
      lCaso.LAT_CompanySignatory__c = 'test';

      if(needMoreFields){
         lCaso.LAT_ActionProposal__c = 'Prorrogação do contrato';
         lCaso.LAT_ContractDeadlineMonths__c = 1;
      }   

      return lCaso;   
   }
	
}