/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe PaymentManagerInterface
* NAME: PaymentManagerInterfaceTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 25/09/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 16/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/

@isTest(SeeAllData = true)
private class PaymentManagerInterfaceTest {

  static testMethod void myUnitTest() 
  {
      Utils.setMigrationDoneTest(false); 
        //Recupera os IDS de tipo de registro.
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        

        
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        //insert regional;
        insert regional;
                      //Recupera um Perfil no ambiente
      User gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        
        
      //Database.insert(gerente);
      try{Database.insert(gerente);}catch(Exception e){} 
        
      //Cria novo usuario.
      User usuario = new User();
      usuario.FirstName       = 'nome2';
      usuario.LastName      = 'Sobrenome2';
      usuario.Alias       = 'NSobres2';
      usuario.Email         = 'usuario@sobrenome2.com';
      usuario.Username      = 'devtestusercloud2b2@cloud2b.com.br';
      usuario.CommunityNickname   = '1234jjuuuU';
      usuario.EmailEncodingKey  = 'ISO-8859-1';
      usuario.TimeZoneSidKey    = 'GMT';
      usuario.LocaleSidKey    = 'en_Us';
      usuario.LanguageLocaleKey = 'en_Us';
      usuario.C_digo_JDE__c   = '235';
      usuario.ProfileId       = gerente.profileId;
      usuario.ManagerId  = gerente.Id;
      usuario.Gerente_regional__c = gerente.Id;
      usuario.Country = 'BR';
      
      // Database.insert(usuario);
       try{Database.insert(usuario);}catch(Exception e){}
        
        Account acc = new Account();
        acc.Name = 'Conta teste Trigger';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        //acc.Regional__c = regional.id;
        acc.RecordTypeId = idRecTypeAcc;
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        //insert acc;
        insert acc;

        Test.startTest();
        Utils.setMigrationDoneTest(false); 
          
        LAT_Contract__c lContract = new LAT_Contract__c();
        lContract.Account__c = acc.Id;
        lContract.Status__c = 'Em elaboração';
        lContract.StartDate__c = System.today();
        lContract.ContractTerm__c = 12;
        lContract.RecordTypeId = idrecTypeLatCon;
        lContract.ROI_Comentarios_Negativo__c = 'teste';
        insert lContract;
        //try{insert lContract;}catch(Exception e){}
          
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        ibp.Data_de_Previsao_do_Pagamento__c = system.today();
        ibp.Finalidade__c = 'Contrato';
        ibp.LAT_Contract__c = lContract.id;
        ibp.Valor_R__c = 100;
        ibp.Status_da_Verba__c = 'Reservado';
        ibp.Conta_IBP__c = acc.id;
        //insert ibp;
        insert ibp;
        
        Id idRecTypeAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
        Agrupamento_Fiscal_Year__c lAgrp = new Agrupamento_Fiscal_Year__c( 
        RecordTypeId = idRecTypeAgr,
        LAT_Contract__c = lContract.Id,
        Ano_Fiscal__c = FiscalYearFormat( Date.today() )
        );
        Database.insert( lAgrp );
        
        Pagamento__c lPagto = new Pagamento__c();
        lPagto.Cliente__c = acc.Id;
        lPagto.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento__c', 'Dinheiro' );
        lPagto.OwnerId = usuario.id;
        //insert lPagto;
        insert lPagto;
      
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c();
        lPagtoVerba.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' );
        lPagtoVerba.Pagamento__c = lPagto.id;
        lPagtoVerba.Investimento_Bonifica_o_e_Pagamento__c = ibp.id;
        lPagtoVerba.valor_a_pagar__c = 1.45;
        lPagtoVerba.Conta__c = acc.id;
        lPagtoVerba.Sistema__c = 'ME';
        //insert lPagtoVerba;
        insert lPagtoVerba;
        
        /*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments( 'Submitting request for approval.' );
        req1.setObjectId( lPagto.id );
        req1.setNextApproverIds( new Id[] { UserInfo.getUserId() } );
        Approval.ProcessResult result = Approval.process( req1 );*/
        
        Agrupamento_Fiscal_Year__c lAgrupamento = new Agrupamento_Fiscal_Year__c(
          LAT_Contract__c=ibp.LAT_Contract__c,
          Ano_Fiscal__c=ibp.Ano_Fiscal__c,
          RecordTypeId=RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard')
        );
        //insert lAgrupamento;
        insert lAgrupamento;
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Approve.');
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req.setObjectId(lPagto.Id);

        //Submit the approval request
        Approval.ProcessResult result = Approval.process(req);
        try{
          PaymentManagerInterface.PaymentManagerInvoke( lPagto.id );
          //PaymentManagerInterface.calloutMock();
        }catch(Exception e){
          System.debug(e.getMessage());
        }
        Test.stopTest();

  }

  static testMethod void myUnitTestB() 
  {
      Utils.setMigrationDoneTest(true); 
        //Recupera os IDS de tipo de registro.
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        
              //Recupera um Perfil no ambiente
     
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
      User gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        
        
      //Database.insert(gerente);
      try{Database.insert(gerente);}catch(Exception e){} 
        
      //Cria novo usuario.
      User usuario = new User();
      usuario.FirstName       = 'nome2';
      usuario.LastName      = 'Sobrenome2';
      usuario.Alias       = 'NSobres2';
      usuario.Email         = 'usuario@sobrenome2.com';
      usuario.Username      = 'devtestusercloud2b2@cloud2b.com.br';
      usuario.CommunityNickname   = '1234jjuuuU';
      usuario.EmailEncodingKey  = 'ISO-8859-1';
      usuario.TimeZoneSidKey    = 'GMT';
      usuario.LocaleSidKey    = 'en_Us';
      usuario.LanguageLocaleKey = 'en_Us';
      usuario.C_digo_JDE__c   = '235';
      usuario.ProfileId       = gerente.profileId;
      usuario.ManagerId  = gerente.Id;
      usuario.Gerente_regional__c = gerente.Id;
      usuario.Country = 'BR';
      
      // Database.insert(usuario);
       try{Database.insert(usuario);}catch(Exception e){}
        

        Account acc = new Account();
        acc.Name = 'Conta teste Trigger';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        //acc.Regional__c = regional.id;
        acc.RecordTypeId = idRecTypeAcc;
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        //insert acc;
        insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true); 

        LAT_Contract__c lContract = new LAT_Contract__c();
        lContract.Account__c = acc.Id;
        lContract.Status__c = 'Em elaboração';
        lContract.StartDate__c = System.today();
        lContract.ContractTerm__c = 12;
        lContract.RecordTypeId = idrecTypeLatCon;
        lContract.ROI_Comentarios_Negativo__c = 'teste';
        insert lContract;
        //try{insert lContract;}catch(Exception e){}
          
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        ibp.Data_de_Previsao_do_Pagamento__c = system.today();
        ibp.Finalidade__c = 'Contrato';
        ibp.LAT_Contract__c = lContract.id;
        ibp.Valor_R__c = 100;
        ibp.Status_da_Verba__c = 'Reservado';
        ibp.Conta_IBP__c = acc.id;
        //insert ibp;
        insert ibp;
        
        Id idRecTypeAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
        Agrupamento_Fiscal_Year__c lAgrp = new Agrupamento_Fiscal_Year__c( 
        RecordTypeId = idRecTypeAgr,
        LAT_Contract__c = lContract.Id,
        Ano_Fiscal__c = FiscalYearFormat( Date.today() )
        );
        Database.insert( lAgrp );
        
        Pagamento__c lPagto = new Pagamento__c();
        lPagto.Cliente__c = acc.Id;
        lPagto.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento__c', 'Dinheiro' );
        lPagto.OwnerId = usuario.id;
        //insert lPagto;
        insert lPagto;
      
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c();
        lPagtoVerba.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' );
        lPagtoVerba.Pagamento__c = lPagto.id;
        lPagtoVerba.Investimento_Bonifica_o_e_Pagamento__c = ibp.id;
        lPagtoVerba.valor_a_pagar__c = 1.45;
        lPagtoVerba.Conta__c = acc.id;
        lPagtoVerba.Sistema__c = 'ME';
        //insert lPagtoVerba;
        insert lPagtoVerba;
        
        /*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments( 'Submitting request for approval.' );
        req1.setObjectId( lPagto.id );
        req1.setNextApproverIds( new Id[] { UserInfo.getUserId() } );
        Approval.ProcessResult result = Approval.process( req1 );*/
        
        Agrupamento_Fiscal_Year__c lAgrupamento = new Agrupamento_Fiscal_Year__c(
          LAT_Contract__c=ibp.LAT_Contract__c,
          Ano_Fiscal__c=ibp.Ano_Fiscal__c,
          RecordTypeId=RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard')
        );
        //insert lAgrupamento;
        try{insert lAgrupamento;}catch(Exception e){}
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Approve.');
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req.setObjectId(lPagto.Id);

        //Submit the approval request
        Approval.ProcessResult result = Approval.process(req);

        try{
          PaymentManagerInterface.PaymentManagerInvoke( lPagto.id );
          //PaymentManagerInterface.calloutMock();
        }catch(Exception e){
          System.debug(e.getMessage());
        }
        Test.stopTest();
  }

    static testMethod void myUnitTestC() 
  {
      Utils.setMigrationDoneTest(false); 
        //Recupera os IDS de tipo de registro.
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        

        
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        //insert regional;
        insert regional;
                      //Recupera um Perfil no ambiente
      User gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        
        
      //Database.insert(gerente);
      try{Database.insert(gerente);}catch(Exception e){} 
        
      //Cria novo usuario.
      User usuario = new User();
      usuario.FirstName       = 'nome2';
      usuario.LastName      = 'Sobrenome2';
      usuario.Alias       = 'NSobres2';
      usuario.Email         = 'usuario@sobrenome2.com';
      usuario.Username      = 'devtestusercloud2b2@cloud2b.com.br';
      usuario.CommunityNickname   = '1234jjuuuU';
      usuario.EmailEncodingKey  = 'ISO-8859-1';
      usuario.TimeZoneSidKey    = 'GMT';
      usuario.LocaleSidKey    = 'en_Us';
      usuario.LanguageLocaleKey = 'en_Us';
      usuario.C_digo_JDE__c   = '235';
      usuario.ProfileId       = gerente.profileId;
      usuario.ManagerId  = gerente.Id;
      usuario.Gerente_regional__c = gerente.Id;
      usuario.Country = 'BR';
      
      // Database.insert(usuario);
       try{Database.insert(usuario);}catch(Exception e){}
        
        Account acc = new Account();
        acc.Name = 'Conta teste Trigger';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        //acc.Regional__c = regional.id;
        acc.RecordTypeId = idRecTypeAcc;
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        //insert acc;
        insert acc;

        Test.startTest();
        Utils.setMigrationDoneTest(false); 
          
        LAT_Contract__c lContract = new LAT_Contract__c();
        lContract.Account__c = acc.Id;
        lContract.Status__c = 'Em elaboração';
        lContract.StartDate__c = System.today();
        lContract.ContractTerm__c = 12;
        lContract.RecordTypeId = idrecTypeLatCon;
        lContract.ROI_Comentarios_Negativo__c = 'teste';
        insert lContract;
        //try{insert lContract;}catch(Exception e){}

        Id idRecTypeProd = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
        Product2 produto = new Product2();
        produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        produto.Internal_id__c = '123';
        produto.Sku__c = '32342';
        //produto.QT_lead_time__c = 5;
        produto.RecordTypeId = idRecTypeProd;
        insert produto;
          
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' );
        ibp.Data_de_Previsao_do_Pagamento__c = system.today();
        ibp.Finalidade__c = 'Contrato';
        ibp.LAT_Contract__c = lContract.id;
        ibp.Valor_R__c = 100;
        ibp.Status_da_Verba__c = 'Reservado';
        ibp.Conta_IBP__c = acc.id;
        ibp.Produto_Bonificado__c = produto.Id;
        //insert ibp;
        insert ibp;
        
        Id idRecTypeAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
        Agrupamento_Fiscal_Year__c lAgrp = new Agrupamento_Fiscal_Year__c( 
        RecordTypeId = idRecTypeAgr,
        LAT_Contract__c = lContract.Id,
        Ano_Fiscal__c = FiscalYearFormat( Date.today() )
        );
        Database.insert( lAgrp );
        
        Pagamento__c lPagto = new Pagamento__c();
        lPagto.Cliente__c = acc.Id;
        lPagto.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento__c', 'Dinheiro' );
        lPagto.OwnerId = usuario.id;
        lPagto.Forma_de_Pagamento__c = 'Deposito em Conta';
        lPagto.Recebedor__c = 'Cliente Pai';
        //insert lPagto;
        insert lPagto;
      
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c();
        lPagtoVerba.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' );
        lPagtoVerba.Pagamento__c = lPagto.id;
        lPagtoVerba.Investimento_Bonifica_o_e_Pagamento__c = ibp.id;
        lPagtoVerba.valor_a_pagar__c = 1.45;
        lPagtoVerba.Conta__c = acc.id;
        lPagtoVerba.Sistema__c = 'SCV';
        lPagtoVerba.pagar_com_produto__c = produto.Id;
        //insert lPagtoVerba;
        insert lPagtoVerba;
        
        /*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments( 'Submitting request for approval.' );
        req1.setObjectId( lPagto.id );
        req1.setNextApproverIds( new Id[] { UserInfo.getUserId() } );
        Approval.ProcessResult result = Approval.process( req1 );*/
        
        Agrupamento_Fiscal_Year__c lAgrupamento = new Agrupamento_Fiscal_Year__c(
          LAT_Contract__c=ibp.LAT_Contract__c,
          Ano_Fiscal__c=ibp.Ano_Fiscal__c,
          RecordTypeId=RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard')
        );
        //insert lAgrupamento;
        insert lAgrupamento;
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Approve.');
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req.setObjectId(lPagto.Id);

        //Submit the approval request
        Approval.ProcessResult result = Approval.process(req);
        try{
          PaymentManagerInterface.PaymentManagerInvoke( lPagto.id );
          //PaymentManagerInterface.calloutMock();
        }catch(Exception e){
          System.debug(e.getMessage());
        }
        Test.stopTest();

  }

  static testMethod void myUnitTestBC() 
  {
      Utils.setMigrationDoneTest(true); 
        //Recupera os IDS de tipo de registro.
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        
              //Recupera um Perfil no ambiente
     
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
      User gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        
        
      //Database.insert(gerente);
      try{Database.insert(gerente);}catch(Exception e){} 
        
      //Cria novo usuario.
      User usuario = new User();
      usuario.FirstName       = 'nome2';
      usuario.LastName      = 'Sobrenome2';
      usuario.Alias       = 'NSobres2';
      usuario.Email         = 'usuario@sobrenome2.com';
      usuario.Username      = 'devtestusercloud2b2@cloud2b.com.br';
      usuario.CommunityNickname   = '1234jjuuuU';
      usuario.EmailEncodingKey  = 'ISO-8859-1';
      usuario.TimeZoneSidKey    = 'GMT';
      usuario.LocaleSidKey    = 'en_Us';
      usuario.LanguageLocaleKey = 'en_Us';
      usuario.C_digo_JDE__c   = '235';
      usuario.ProfileId       = gerente.profileId;
      usuario.ManagerId  = gerente.Id;
      usuario.Gerente_regional__c = gerente.Id;
      usuario.Country = 'BR';
      
      // Database.insert(usuario);
       try{Database.insert(usuario);}catch(Exception e){}
        

        Account acc = new Account();
        acc.Name = 'Conta teste Trigger';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        //acc.Regional__c = regional.id;
        acc.RecordTypeId = idRecTypeAcc;
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        //insert acc;
        insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true); 

        LAT_Contract__c lContract = new LAT_Contract__c();
        lContract.Account__c = acc.Id;
        lContract.Status__c = 'Em elaboração';
        lContract.StartDate__c = System.today();
        lContract.ContractTerm__c = 12;
        lContract.RecordTypeId = idrecTypeLatCon;
        lContract.ROI_Comentarios_Negativo__c = 'teste';
        insert lContract;
        //try{insert lContract;}catch(Exception e){}
        LAT_Product__c lProd = new LAT_Product__c();
        lProd.Name = 'Cachaca';
        lProd.LAT_ExternalId__c = 'qeweqewq';
        lProd.LAT_SKU__c = '22321';
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
        ibp.Status_da_Verba__c = 'Reservado';
        ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
        insert ibp;  
        
        
        Id idRecTypeAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
        Agrupamento_Fiscal_Year__c lAgrp = new Agrupamento_Fiscal_Year__c( 
        RecordTypeId = idRecTypeAgr,
        LAT_Contract__c = lContract.Id,
        Ano_Fiscal__c = FiscalYearFormat( Date.today() )
        );
        Database.insert( lAgrp );
        
        Pagamento__c lPagto = new Pagamento__c();
        lPagto.Cliente__c = acc.Id;
        lPagto.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento__c', 'Dinheiro' );
        lPagto.OwnerId = usuario.id;
        lPagto.Forma_de_Pagamento__c = 'Deposito em Conta';
        lPagto.Recebedor__c = 'Cliente Pai';
        //insert lPagto;
        insert lPagto;
      
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c();
        lPagtoVerba.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' );
        lPagtoVerba.Pagamento__c = lPagto.id;
        lPagtoVerba.Investimento_Bonifica_o_e_Pagamento__c = ibp.id;
        lPagtoVerba.valor_a_pagar__c = 1.45;
        lPagtoVerba.Conta__c = acc.id;
        lPagtoVerba.Sistema__c = 'SCV';
        lPagtoVerba.LAT_Product__c = lProd.Id;
        //insert lPagtoVerba;
        insert lPagtoVerba;
        
        /*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments( 'Submitting request for approval.' );
        req1.setObjectId( lPagto.id );
        req1.setNextApproverIds( new Id[] { UserInfo.getUserId() } );
        Approval.ProcessResult result = Approval.process( req1 );*/
        
        Agrupamento_Fiscal_Year__c lAgrupamento = new Agrupamento_Fiscal_Year__c(
          LAT_Contract__c=ibp.LAT_Contract__c,
          Ano_Fiscal__c=ibp.Ano_Fiscal__c,
          RecordTypeId=RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard')
        );
        //insert lAgrupamento;
        try{insert lAgrupamento;}catch(Exception e){}
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Approve.');
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req.setObjectId(lPagto.Id);

        //Submit the approval request
        Approval.ProcessResult result = Approval.process(req);

        try{
          PaymentManagerInterface.PaymentManagerInvoke( lPagto.id );
          //PaymentManagerInterface.calloutMock();
        }catch(Exception e){
          System.debug(e.getMessage());
        }
        Test.stopTest();
  }

  static testMethod void myUnitTest2()
  {
    PaymentManager.PGTPRD_element lx = new PaymentManager.PGTPRD_element();
    lx.PGTPRDItem = new list< PaymentManager.SDTPGT_RVSItem_PGTPRDItem >();
    
    PaymentManager.SDTPGT_RVSItem_PGTPRDItem ly = new PaymentManager.SDTPGT_RVSItem_PGTPRDItem();
    ly.KspSkuCod = 0;
    ly.KspDatPgt = system.today();
    ly.KspQtdCai = 0;
    ly.KspVal = 0;
    ly.UndCod = '';
    
    PaymentManager.RVS_element lw = new PaymentManager.RVS_element();
    lw.RVSItem = new list< PaymentManager.SDTPGT_RVSItem >();
    
    PaymentManager.WBSPGT_ExecuteResponse_element lq = new PaymentManager.WBSPGT_ExecuteResponse_element();
    lq.Codret = '';
    lq.Errordesc = '';
    lq.Nrospgscv = 0;
    lq.Sdtpgt = new PaymentManager.SDTPGT();
    
    PaymentManager.ArrayOfSDTPGT_RVSItem_PGTDINItem lr = new PaymentManager.ArrayOfSDTPGT_RVSItem_PGTDINItem();
    lr.SDTPGT_RVSItem_PGTDINItem = new List< PaymentManager.SDTPGT_RVSItem_PGTDINItem >();
    
    PaymentManager.SDTPGT ls = new PaymentManager.SDTPGT();
    ls.RVS = new PaymentManager.RVS_element();
    
    PaymentManager.PGTDIN_element lg = new PaymentManager.PGTDIN_element();
    lg.PGTDINItem = new List< PaymentManager.SDTPGT_RVSItem_PGTDINItem >();
    
    PaymentManager.SDTPGT_RVSItem li = new PaymentManager.SDTPGT_RVSItem();
    li.PrqFinDes = '';
    li.RqvNroRqv = 0;
    li.TdoCod = '';
    
    PaymentManager.ArrayOfSDTPGT_RVSItem lk = new PaymentManager.ArrayOfSDTPGT_RVSItem();
    lk.SDTPGT_RVSItem = new list< PaymentManager.SDTPGT_RVSItem >();
    
    PaymentManager.WBSPGT_Execute_element lj = new PaymentManager.WBSPGT_Execute_element();
    lj.Cavapvrpv = System.today();
    lj.Cavhieobr = '';
    lj.Cavmotrpv = '';
    lj.Cavusrapv = '';
    lj.Codcliente = 0;
    lj.Codsistema = '';
    lj.Empcod = 0;
    lj.Idcrm = '';
    lj.Krqpgtdat = System.today();
    lj.Mcu = '';
    lj.Paicod = 0;
    lj.Spgclirec = '';
    lj.Spgemiusr = '';
    lj.Spgobs = '';
    lj.Spgsoltip = '';
    lj.Spgsolusr = '';
    lj.User_x = '';
    
    PaymentManager.SDTPGT_RVSItem_PGTDINItem lf = new PaymentManager.SDTPGT_RVSItem_PGTDINItem();
    lf.DspDatPgt = system.today();
    lf.DspVal = 0;
    
    PaymentManager.ArrayOfSDTPGT_RVSItem_PGTPRDItem ld = new PaymentManager.ArrayOfSDTPGT_RVSItem_PGTPRDItem();
    ld.SDTPGT_RVSItem_PGTPRDItem = new List< PaymentManager.SDTPGT_RVSItem_PGTPRDItem >();
  }
  
  public static string FiscalYearFormat ( Date inputDate ) {
    Integer anoYY = Integer.valueOf( String.valueOf ( inputDate.year() ).right(2) );
    String dataFinal = 'FY';
    
    if ( inputDate.month() >= 7 && inputDate.month() <= 12 ){
      dataFinal += String.valueOf( anoYY +1 );
      dataFinal += ': jul/';
      dataFinal += String.valueOf( anoYY );
      dataFinal += ' - jun/';
      dataFinal += String.valueOf( anoYY + 1 );
    } else {
      dataFinal += String.valueOf( anoYY );
      dataFinal += ': jul/';
      dataFinal += String.valueOf( anoYY -1 );
      dataFinal += ' - jun/';
      dataFinal += String.valueOf( anoYY );
    } 
    
    return dataFinal;
  }
}