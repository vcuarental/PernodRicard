@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza teste de cobertura dos seguintes códigos:
*                             CasoCopiaIdGerenteRegionalArea - 87%
*                             ContaCopiaIdGerenteRegionalArea - 100%
*                             ContratoCopiaIdGerenteRegionalArea - 100%
*                             ContaAutomatizaEnvioAprovacao - 100%
*                             ContratoAutomatizaEnvioaprovacao - 88%
*                             TRCustomerInterface - 75%
*                             DemandaInterna - 96%
*                             CriaCriterioRegional - 100%
*                             UserDAO - 100%*
* NAME: ContratoAutomatizaEnvioAprovacaoTest.cls
* AUTHOR:                                               DATE: 
*
* MAINTENANCE: 
* AUTHOR: CARLOS CARVALHO                               DATE: 14/03/2012
*
* AUTHOR: CARLOS CARVALHO                               DATE: 14/05/2012
*
* AUTHOR: CARLOS CARVALHO                               DATE: 24/05/2012
*
* AUTHOR: CARLOS CARVALHO                               DATE: 14/01/2013 
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
*
* AUTHOR: CARLOS CARVALHO                               DATE: 28/01/2013 
* DESC: ALTERADO CRIAÇÃO DE OBJETOS E PREENCHOMENTO DE CAMPOS OBRIGATÓRIOS.
********************************************************************************/
private class ContratoAutomatizaEnvioAprovacaoTest {

    static testMethod void ContratoAutomatizaEnvioAprovacaoTest() {
      
      //Declaração de variáveis. 
      String idEventos = null;
      String idAssinaturaContrato = null;
      Profile perfil = null;
      User usuario = null;
      User gerente = null; 
      Account acc = null;
      
      //Recupera o id de Eventos/Contrato para a variavel idEventos/idContrato.
      idEventos = RecordTypeForTest.getRecType( 'Account', 'On_Trade');
      Id idRecTypeAcc = RecordTypeForTest.getRecType( 'Account', 'Off_Trade' );
      Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
      
      //Recupera um Perfil no ambiente
      gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert gerente;
      //Cria novo usuario.
      usuario = new User();
      usuario.FirstName       = 'nome';
      usuario.LastName      = 'Sobrenome';
      usuario.Alias       = 'NSobres';
      usuario.Email         = 'nome@sobrenome.com';
      usuario.Username      = 'devtestusercloud2b2@cloud2b.com.br';
      usuario.CommunityNickname   = '1234jjuuu';
      usuario.EmailEncodingKey  = 'ISO-8859-1';
      usuario.TimeZoneSidKey    = 'GMT';
      usuario.LocaleSidKey    = 'en_Us';
      usuario.LanguageLocaleKey = 'en_Us';
      usuario.C_digo_JDE__c   = '235';
      usuario.ProfileId       = gerente.ProfileId;
      usuario.Gerente_de_area__c  = gerente.Id;
      usuario.Gerente_regional__c = gerente.Id;
      usuario.Country = 'BR';
      insert usuario;
      
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '01-01';
        regional.RecordTypeId = idRecTypeUdc;
        insert regional;
      
      //Cria novo Account. 
        acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'Conta teste Trigger';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Regional__c = regional.id;
        acc.RecordTypeId = idRecTypeAcc;
        insert acc;
        
        test.startTest();
        
      idAssinaturaContrato = RecordTypeForTest.getRecType('LAT_Contract__c','Assinatura_de_contrato_com_aprovacao');
      
      LAT_Contract__c contract = new LAT_Contract__c();
      contract.OwnerId = usuario.Id;
      contract.Account__c = acc.Id;
      contract.Status__c = 'Em elaboração';
      contract.StartDate__c = System.today();
      contract.ContractTerm__c = 12;
      contract.Percentual_KPI_financeiro_ROI__c = 32;
      contract.Percentual_CAAP__c = 20;
      contract.Alteracao_de_clausulas_contratuais__c = 'Sim';
      contract.RecordTypeId = idAssinaturaContrato;
      contract.Aditamento_gerado__c = false;
      contract.trigger_on__c = true;
      contract.ROI_Comentarios_Negativo__c = 'teste';
      
      insert contract;
      
      //Atualzia contrato.
      contract.Aditamento_gerado__c = true;
      contract.trigger_on__c = true;
      contract.Status_do_processo__c = 'Cancelamento aprovado pelo cliente';
      //Atualiza contrato.
      try{
        contract.Status__c = 'Em aprovação';
        update contract;
      }
      catch(DMLException e)
      {
        System.debug(e.getMessage());
      }
      
      test.stopTest();   
    }
}