/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe de cobertura de teste para a classe ContractROI_OnTrade
* NAME: ContractROI_OnTradeTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 03/09/2012
*
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013 
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/

@isTest
private class ContractROI_OnTradeTest {
      //MIGRATED 21/11/2016
    static testMethod void myUnitTest() {
      Utils.setMigrationDoneTest(false);
      //Recupera um Perfil no ambiente
      User gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert gerente;
      
      //Cria novo usuario.
      User usuario = new User();
      usuario.FirstName           = 'nome';
      usuario.LastName            = 'Sobrenome';
      usuario.Alias               = 'NSobres';
      usuario.Email               = 'nome@sobrenome.com';
      usuario.Username            = 'devtestusercloud2b2@cloud2b.com.br';
      usuario.CommunityNickname   = '1234jjuuu';
      usuario.EmailEncodingKey    = 'ISO-8859-1';
      usuario.TimeZoneSidKey      = 'GMT';
      usuario.LocaleSidKey        = 'en_Us';
      usuario.LanguageLocaleKey   = 'en_Us';
      usuario.C_digo_JDE__c       = '235';
      usuario.ProfileId           = gerente.ProfileId;
      usuario.Gerente_de_area__c  = gerente.Id;
      usuario.Gerente_regional__c = gerente.Id;
      usuario.Country = 'BR';
      insert usuario;
      
      //Cria nova UDC.
      UDC__c regional = new UDC__c();
      regional.CodDefUsuario__c = '2';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '01-01';
      regional.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
      insert regional;
            
      //Cria novo Account.
      Account acc = new Account();
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
      acc.RecordTypeId = RecordTypeForTest.getRecType( 'Account', 'Off_Trade' );
      insert acc;
      
      LAT_Contract__c lContract = new LAT_Contract__c();
      lContract.OwnerId = usuario.Id;
      lContract.Account__c = acc.Id;
      lContract.Status__c = 'Em elaboração';
      lContract.StartDate__c = System.today();
      lContract.ContractTerm__c = 12;
      lContract.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade' );
      insert lContract;
    
      Product2 lProd = new Product2();
      lProd.Name = 'Cachaca';
      lProd.Internal_id__c = 'qeweqewq';
      lProd.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
      insert lProd;
    
      Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
      ibp.LAT_Contract__c = lContract.id;
      ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' );
      ibp.Valor_R__c = 100;
      ibp.Perc_de_Rateio__c = 30;
      ibp.Valor_Percebido__c = 120.32;
      ibp.Custo_Bonificado__c = 89;
      ibp.Produto_Bonificado__c = lProd.id;
      ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
      insert ibp;
      
      //Excuta o standard controller
      ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller( lContract );
      
      ContractROI_OnTrade lPDF = new ContractROI_OnTrade( sc );
      List< Investimento_Bonificacao_e_Pagamento__c > lC = lPDF.contratos;
      List< Investimento_Bonificacao_e_Pagamento__c > lF = lPDF.festas;
      List< Investimento_Bonificacao_e_Pagamento__c > lT = lPDF.tailorMade;
      ContractROI_OnTrade.BonificacaoProdutos lBP = new ContractROI_OnTrade.BonificacaoProdutos();
      lBP.periodo = '1';
      lBP.anoCalendario = '2012';
      lBP.mes = '12';
      lBP.produto = 'asd';
      lBP.volume = 1;
      
      //List< BonificacaoProdutos > lBo = lPDF.bonificacao;
      boolean lD = lPDF.temDetalhamento;
 
    }
    //MIGRATED 21/11/2016
    static testMethod void myUnitTest2() { 
      Utils.setMigrationDoneTest(true);
      //Recupera um Perfil no ambiente
      User gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert gerente;
      
      //Cria novo usuario.
      User usuario = new User();
      usuario.FirstName           = 'nome';
      usuario.LastName            = 'Sobrenome';
      usuario.Alias               = 'NSobres';
      usuario.Email               = 'nome@sobrenome.com';
      usuario.Username            = 'devtestusercloud2b2@cloud2b.com.br';
      usuario.CommunityNickname   = '1234jjuuu';
      usuario.EmailEncodingKey    = 'ISO-8859-1';
      usuario.TimeZoneSidKey      = 'GMT';
      usuario.LocaleSidKey        = 'en_Us';
      usuario.LanguageLocaleKey   = 'en_Us';
      usuario.C_digo_JDE__c       = '235';
      usuario.ProfileId           = gerente.ProfileId;
      usuario.Gerente_de_area__c  = gerente.Id;
      usuario.Gerente_regional__c = gerente.Id;
      usuario.Country = 'BR';
      insert usuario;
      
      //Cria nova UDC.
      UDC__c regional = new UDC__c();
      regional.CodDefUsuario__c = '2';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '01-01';
      regional.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
      insert regional;
            
      //Cria novo Account.
      Account acc = new Account();
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
      acc.RecordTypeId = RecordTypeForTest.getRecType( 'Account', 'Off_Trade' );
      insert acc;
      
      LAT_Contract__c lContract = new LAT_Contract__c();
      lContract.OwnerId = usuario.Id;
      lContract.Account__c = acc.Id;
      lContract.Status__c = 'Em elaboração';
      lContract.StartDate__c = System.today();
      lContract.ContractTerm__c = 12;
      lContract.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade' );
      insert lContract;
    
      LAT_Product__c lProd = new LAT_Product__c();
      lProd.Name = 'Cachaca';
      lProd.LAT_ExternalID__c = 'qeweqewq';
      lProd.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
      insert lProd;
    
      Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
      ibp.LAT_Contract__c = lContract.id;
      ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' );
      ibp.Valor_R__c = 100;
      ibp.Perc_de_Rateio__c = 30;
      ibp.Valor_Percebido__c = 120.32;
      ibp.Custo_Bonificado__c = 89;
      ibp.LAT_Product__c = lProd.id;
      ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
      insert ibp;
      
      //Excuta o standard controller
      ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller( lContract );
      
      ContractROI_OnTrade lPDF = new ContractROI_OnTrade( sc );
      List< Investimento_Bonificacao_e_Pagamento__c > lC = lPDF.contratos;
      List< Investimento_Bonificacao_e_Pagamento__c > lF = lPDF.festas;
      List< Investimento_Bonificacao_e_Pagamento__c > lT = lPDF.tailorMade;
      ContractROI_OnTrade.BonificacaoProdutos lBP = new ContractROI_OnTrade.BonificacaoProdutos();
      lBP.periodo = '1';
      lBP.anoCalendario = '2012';
      lBP.mes = '12';
      lBP.produto = 'asd';
      lBP.volume = 1;
      
      //List< BonificacaoProdutos > lBo = lPDF.bonificacao;
      boolean lD = lPDF.temDetalhamento;
 
    }
}