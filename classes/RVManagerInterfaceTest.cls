/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe RVManagerInterface
* NAME: RVManagerInterfaceTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 25/09/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 19/11/2016
*
********************************************************************************/


@isTest(SeeAllData=true)
private class RVManagerInterfaceTest {

    static testMethod void myUnitTest() 
    {
      Utils.setMigrationDoneTest(false); 
      //Recupera ids de tipo de registro
      Set< Id > setRecTypePV = new Set< Id >();
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos' ) );
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' ) );
      
            
      //Cria novo usuario.
      User gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      Database.Saveresult sResult = Database.insert( gerente, false );
      system.assert( sResult.isSuccess() );
      
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
      usuario.ManagerId           = gerente.Id;
      usuario.Country = 'BR';
      sResult = Database.insert( usuario, false );
      system.assert( sResult.isSuccess() );

      System.runAs(usuario){
        //Cria um novo pagamento
        Pagamento__c payment = new Pagamento__c();
        payment.OwnerId               = usuario.Id;
        payment.Recebedor__c          = 'Cliente Abertura da RV';
        payment.Forma_de_Pagamento__c ='Deposito em Conta';
        sResult = Database.insert( payment, false );
        system.debug('%%%%%%%%%%  Database.insert result : '+ sResult.getErrors());
        system.assert( sResult.isSuccess() );
        
        //Cria um novo IBP
        Investimento_Bonificacao_e_Pagamento__c IBP =
          new Investimento_Bonificacao_e_Pagamento__c(
            Status_da_Verba__c='Reservado',
            RecordTypeId=RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ),
            Data_de_previsao_do_pagamento__c=System.today().addDays( 10 ),
            Sistema__c='ME',
            OwnerId=usuario.Id
          );
        sResult = Database.insert( IBP, false );
        system.assert( sResult.isSuccess() );
        
        //Cria um novo pagamento de verba
        Pagamento_da_Verba__c pagVerba = 
          new Pagamento_da_Verba__c( 
            Pagamento__c=payment.Id, 
            Investimento_Bonifica_o_e_Pagamento__c=IBP.Id 
          );
        sResult = Database.insert( pagVerba, false );
        system.assert( sResult.isSuccess() );
        
        payment = [Select Id, OwnerId, Recebedor__c, Forma_de_Pagamento__c,Conta_itens_de_verba__c 
          FROM Pagamento__c WHERE Id =: payment.Id limit 1 ];
        
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setNextApproverIds( new List< Id >{ payment.OwnerId});
        req.setObjectId( payment.Id );
        try{
          // submit the approval request for processing
          Approval.ProcessResult result = Approval.process( req );
        }catch(Exception e){
          system.debug(e.getMessage());
        }
        RVManagerInterface.RVManagerInvoke(IBP.Id, payment.Id);
      }
    }
    
    static testMethod void myUnitTestB() 
    {
      Utils.setMigrationDoneTest(true); 
      //Recupera ids de tipo de registro
      Set< Id > setRecTypePV = new Set< Id >();
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos' ) );
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' ) );
      
            
      //Cria novo usuario.
      User gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      Database.Saveresult sResult = Database.insert( gerente, false );
      system.assert( sResult.isSuccess() );
      
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
      usuario.ManagerId           = gerente.Id;
      usuario.Country = 'BR';
      sResult = Database.insert( usuario, false );
      system.assert( sResult.isSuccess() );
      
      System.runAs(usuario){
        //Cria um novo pagamento
        Pagamento__c payment = new Pagamento__c();
        payment.OwnerId               = usuario.Id;
        payment.Recebedor__c          = 'Cliente Abertura da RV';
        payment.Forma_de_Pagamento__c ='Deposito em Conta';
        sResult = Database.insert( payment, false );
        system.debug('%%%%%%%%%%  Database.insert result : '+ sResult.getErrors());
        system.assert( sResult.isSuccess() );
        
        //Cria um novo IBP
        Investimento_Bonificacao_e_Pagamento__c IBP =
          new Investimento_Bonificacao_e_Pagamento__c(
            Status_da_Verba__c='Reservado',
            RecordTypeId=RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ),
            Data_de_previsao_do_pagamento__c=System.today().addDays( 10 ),
            Sistema__c='ME',
            OwnerId=usuario.Id
          );
        sResult = Database.insert( IBP, false );
        system.assert( sResult.isSuccess() );
        
        //Cria um novo pagamento de verba
        Pagamento_da_Verba__c pagVerba = 
          new Pagamento_da_Verba__c( 
            Pagamento__c=payment.Id, 
            Investimento_Bonifica_o_e_Pagamento__c=IBP.Id 
          );
        sResult = Database.insert( pagVerba, false );
        system.assert( sResult.isSuccess() );
        
        payment = [Select Id, OwnerId, Recebedor__c, Forma_de_Pagamento__c,Conta_itens_de_verba__c 
          FROM Pagamento__c WHERE Id =: payment.Id limit 1 ];
        
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setNextApproverIds( new List< Id >{ payment.OwnerId});
        req.setObjectId( payment.Id );
        try{
          // submit the approval request for processing
          Approval.ProcessResult result = Approval.process( req );
        }catch(Exception e){
          system.debug(e.getMessage());
        }
        RVManagerInterface.RVManagerInvoke(IBP.Id, payment.Id);
      }
    }

    static testMethod void myUnitTest2() 
    {
      Utils.setMigrationDoneTest(false); 
      //Recupera ids de tipo de registro
      Set< Id > setRecTypePV = new Set< Id >();
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos' ) );
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' ) );
      
      //Cria um novo pagamento
      Pagamento__c payment = new Pagamento__c();
      payment.Forma_de_Pagamento__c = 'Deposito em Conta';
      payment.Recebedor__c = 'Cliente Abertura da RV';
      Database.Saveresult sResult = Database.insert( payment, false );
      system.assert( sResult.isSuccess() );
      
      //Cria um novo IBP
      Investimento_Bonificacao_e_Pagamento__c IBP =
        new Investimento_Bonificacao_e_Pagamento__c(
          Status_da_Verba__c='Reservado',
          RecordTypeId=RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ),
          Data_de_previsao_do_pagamento__c=System.today().addDays( 10 ),
          Sistema__c='SCV'
        );
      sResult = Database.insert( IBP, false );
      system.assert( sResult.isSuccess() );
      
      //Cria um novo pagamento de verba
      Pagamento_da_Verba__c pagVerba = 
        new Pagamento_da_Verba__c( 
          Pagamento__c=payment.Id, 
          Investimento_Bonifica_o_e_Pagamento__c=IBP.Id 
        );
      sResult = Database.insert( pagVerba, false );
      system.assert( sResult.isSuccess() );
      
      RVManagerInterface.RVManagerInvoke(IBP.Id, payment.Id);
    }
    static testMethod void myUnitTest2B() 
    {
      Utils.setMigrationDoneTest(true); 
      //Recupera ids de tipo de registro
      Set< Id > setRecTypePV = new Set< Id >();
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos' ) );
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' ) );
      
      //Cria um novo pagamento
      Pagamento__c payment = new Pagamento__c();
      payment.Forma_de_Pagamento__c = 'Deposito em Conta';
      payment.Recebedor__c = 'Cliente Abertura da RV';
      Database.Saveresult sResult = Database.insert( payment, false );
      system.assert( sResult.isSuccess() );
      
      //Cria um novo IBP
      Investimento_Bonificacao_e_Pagamento__c IBP =
        new Investimento_Bonificacao_e_Pagamento__c(
          Status_da_Verba__c='Reservado',
          RecordTypeId=RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' ),
          Data_de_previsao_do_pagamento__c=System.today().addDays( 10 ),
          Sistema__c='SCV'
        );
      sResult = Database.insert( IBP, false );
      system.assert( sResult.isSuccess() );
      
      //Cria um novo pagamento de verba
      Pagamento_da_Verba__c pagVerba = 
        new Pagamento_da_Verba__c( 
          Pagamento__c=payment.Id, 
          Investimento_Bonifica_o_e_Pagamento__c=IBP.Id 
        );
      sResult = Database.insert( pagVerba, false );
      system.assert( sResult.isSuccess() );
      
      RVManagerInterface.RVManagerInvoke(IBP.Id, payment.Id);
    }
    
    static testMethod void myUnitTest3()
    {
      Utils.setMigrationDoneTest(false); 
      RVManager.SDTRVS_PGTPRDITM lp = new RVManager.SDTRVS_PGTPRDITM();
      lp.KrqPgtDat = system.today();
      lp.KrqQtdCai = 0;
      lp.KrqSkuCod = 0;
      lp.KrqVal = 0;
      
      RVManager.ArrayOfSDTRVS_SHCITM ls = new RVManager.ArrayOfSDTRVS_SHCITM();
      ls.SDTRVS_SHCITM = new List< RVManager.SDTRVS_SHCITM >();
      
      RVManager.ArrayOfSDTRVS_PGTDINITM lg = new RVManager.ArrayOfSDTRVS_PGTDINITM();
      lg.SDTRVS_PGTDINITM = new List< RVManager.SDTRVS_PGTDINITM >();
      
      RVManager.WBSRVS_Execute_element le = new RVManager.WBSRVS_Execute_element();
      le.Acao = '';
      le.Cavapvrpv = system.today();
      le.Cavhieobr = '';
      le.Cavmotrpv = '';
      le.Cavusrapv = '';
      le.Empcod = 0;
      le.Fincod = '';
      le.Idcrm = '';
      le.Paicod = 0;
      le.Rqvan8cod = 0;
      le.Rqvanofis = 0;
      le.Rqvemiusr = '';
      le.Rqvencprv = system.today();
      le.Rqvnrovad = 0;
      le.Rqvobs = '';
      le.Rqvpgttip = '';
      le.Rqvsoldat = system.today();
      le.Rqvsolusr = '';
      le.Rqvtvepar = '';
       
      RVManager.ArrayOfSDTRVS_PGTPRDITM lt = new RVManager.ArrayOfSDTRVS_PGTPRDITM();
      lt.SDTRVS_PGTPRDITM = new list< RVManager.SDTRVS_PGTPRDITM >();
    } 
    
    static testMethod void myUnitTest3B()
    {
      Utils.setMigrationDoneTest(true); 
      RVManager.SDTRVS_PGTPRDITM lp = new RVManager.SDTRVS_PGTPRDITM();
      lp.KrqPgtDat = system.today();
      lp.KrqQtdCai = 0;
      lp.KrqSkuCod = 0;
      lp.KrqVal = 0;
      
      RVManager.ArrayOfSDTRVS_SHCITM ls = new RVManager.ArrayOfSDTRVS_SHCITM();
      ls.SDTRVS_SHCITM = new List< RVManager.SDTRVS_SHCITM >();
      
      RVManager.ArrayOfSDTRVS_PGTDINITM lg = new RVManager.ArrayOfSDTRVS_PGTDINITM();
      lg.SDTRVS_PGTDINITM = new List< RVManager.SDTRVS_PGTDINITM >();
      
      RVManager.WBSRVS_Execute_element le = new RVManager.WBSRVS_Execute_element();
      le.Acao = '';
      le.Cavapvrpv = system.today();
      le.Cavhieobr = '';
      le.Cavmotrpv = '';
      le.Cavusrapv = '';
      le.Empcod = 0;
      le.Fincod = '';
      le.Idcrm = '';
      le.Paicod = 0;
      le.Rqvan8cod = 0;
      le.Rqvanofis = 0;
      le.Rqvemiusr = '';
      le.Rqvencprv = system.today();
      le.Rqvnrovad = 0;
      le.Rqvobs = '';
      le.Rqvpgttip = '';
      le.Rqvsoldat = system.today();
      le.Rqvsolusr = '';
      le.Rqvtvepar = '';
       
      RVManager.ArrayOfSDTRVS_PGTPRDITM lt = new RVManager.ArrayOfSDTRVS_PGTPRDITM();
      lt.SDTRVS_PGTPRDITM = new list< RVManager.SDTRVS_PGTPRDITM >();
    } 

    static testMethod void myUnitTest4() 
    {
      Utils.setMigrationDoneTest(false); 
      //Recupera ids de tipo de registro
      Set< Id > setRecTypePV = new Set< Id >();
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos' ) );
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' ) );
      
            
      //Cria novo usuario.
      
      ID idAccount = RecordTypeForTest.getRecType('Account','On_Trade');
     
       Account Acc = new Account();  
        Acc.OwnerId = UserInfo.getUserId();    
        //Acc.OwnerId = usuario.Id;      
        Acc.Name = 'ProdutoOppVerificaCotaExistenteTeste';      
        Acc.CNPJ__c = '48843971000120';      
        Acc.Type = 'Outros';      
        Acc.RecordTypeId = idAccount;      
        Acc.Status__c = 'Cliente cadastrado no JDE';      
        Acc.Agency__c = '000';      
        Acc.Current_account__c = '0';      
        Acc.Corporate_Name__c = 'Teste';      
        Acc.Channel__c = 'On Trade';  
        Acc.Rating = 'Cliente';    
        Acc.Segmentation_Type_on_trade__c = 'Bar';      
        Acc.Frequency_of_Visits__c = 'Semanal';      
        Acc.Client_code_AN8__c = '557799';      
        Acc.Price_Group__c = '1';      
        //Acc.Customer_Flag__c = bandeira.Id;      
        insert Acc;
      //Cria novo usuario.

      User gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      Database.Saveresult sResult = Database.insert( gerente, false );
      system.assert( sResult.isSuccess() );

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
      usuario.ManagerId           = gerente.Id;
      usuario.Country = 'BR';
      sResult = Database.insert( usuario, false );
      system.assert( sResult.isSuccess() );

      




     
        //Cria um novo pagamento
        Pagamento__c payment = new Pagamento__c();
        payment.OwnerId               = usuario.Id;
        payment.Recebedor__c          = 'Cliente Abertura da RV';
        payment.Forma_de_Pagamento__c ='Deposito em Conta';
        payment.Cliente__c = Acc.Id;


        insert payment;


        
        //sResult = Database.insert( payment, false );
        system.debug('%%%%%%%%%%  Database.insert result : '+ sResult.getErrors());
        //system.assert( sResult.isSuccess() );
        
        Product2 lProd = new Product2();
        lProd.Name = 'Cachaca';
        lProd.Internal_ID__c = 'qeweqewq';
        insert lProd;








        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );

    Test.startTest();
        Utils.setMigrationDoneTest(false); 
          
        LAT_Contract__c Lc = new LAT_Contract__c();
        Lc.Account__c = Acc.Id;
        Lc.Status__c = 'Em elaboração';
        Lc.StartDate__c = System.today();
        Lc.ContractTerm__c = 12;
        Lc.RecordTypeId = idrecTypeLatCon;
        Lc.ROI_Comentarios_Negativo__c = 'teste';
        //insert lContract;
        insert Lc;
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
        ibp.Finalidade__c = 'Contrato';
        ibp.LAT_Contract__c = Lc.id;
        ibp.Valor_R__c = 100;
        ibp.Produto_Bonificado__c = lProd.id;
        ibp.Status_da_Verba__c = 'Reservado';
        ibp.Numero_da_DA__c = '120';
        //ibp.Numero_da_RV_criada__c = 'teste'; 
        //insert ibp;
        insert ibp;


        Pagamento__c lPagto = new Pagamento__c();
        lPagto.Cliente__c = acc.Id;
        lPagto.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento__c', 'Dinheiro' );
        //insert lPagto;
        insert lPagto;


      
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c();
        lPagtoVerba.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' );
        lPagtoVerba.Pagamento__c = lPagto.id;
        lPagtoVerba.Investimento_Bonifica_o_e_Pagamento__c = ibp.id;
        lPagtoVerba.valor_a_pagar__c = 1.45;
        //insert lPagtoVerba;
       insert lPagtoVerba;













       

        //Cria nova Clausula de contrato.     
        Cl_usulas_do_Contrato__c Cc = new  Cl_usulas_do_Contrato__c();
        Cc.Contrato__c = Lc.Id;
        insert Cc;

        //Cria nova type de doc.      
        Tipo_de_Documento__c Td = new Tipo_de_Documento__c(); 
        td.LAT_Contract__c = lc.id;
        insert Td;

        Lc.Cl_usulas_do_Contrato__c = Cc.Id;
        Lc.Status__c = 'Em elaboração';
        Lc.ContractTerm__c = 12; 
        update Lc; 
          
        Rateio_do_Contrato__c lRateio = new Rateio_do_Contrato__c();
        lRateio.Perc_de_Rateio__c = 100;
        lRateio.RecordTypeId = RecordTypeForTest.getRecType( 'Rateio_do_Contrato__c', 'BRA_Standard' );
        lRateio.LAT_Contract__c = Lc.Id;
        insert lRateio;  

        User admin = [SELECT Id FROM user WHERE Profile.Name = 'LAT_SystemAdministrator' AND isActive = true limit 1];                  
        //System.runAs(admin){
        //Cria um novo pagamento de verba
        Pagamento_da_Verba__c pagVerba = 
          new Pagamento_da_Verba__c( 
            Pagamento__c=payment.Id, 
            Investimento_Bonifica_o_e_Pagamento__c=ibp.Id,
            RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c' , 'Dinheiro' ),
            LAT_Product__c = ibp.LAT_Product__c,
            Conta__c = Acc.Id
            //valor_a_pagar__c = 1.45
        );

        insert pagVerba;  

      //}
        //sResult = Database.insert( pagVerba, false );
       // system.assert( sResult.isSuccess() );
       System.debug('%%%%%%% select de Pagamento_da_Verba__c :' +[Select id, name, Pagamento__c from Pagamento_da_Verba__c limit 10]);
        payment = [Select Id, OwnerId, Recebedor__c, Forma_de_Pagamento__c,Conta_itens_de_verba__c 
          FROM Pagamento__c WHERE Id =: payment.Id limit 1 ];
        
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setNextApproverIds( new List< Id >{ payment.OwnerId});
        req.setObjectId( payment.Id );
        try{
          // submit the approval request for processing
          Approval.ProcessResult result = Approval.process( req );
        }catch(Exception e){
          system.debug(e.getMessage());
        }
        RVManagerInterface.RVManagerInvoke(IBP.Id, payment.Id);
      
      Test.stopTest();
    }
    
    static testMethod void myUnitTest4B() 
    {
      Utils.setMigrationDoneTest(true); 
      //Recupera ids de tipo de registro
      Set< Id > setRecTypePV = new Set< Id >();
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos' ) );
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' ) );
      
            
      //Cria novo usuario.
      
      ID idAccount = RecordTypeForTest.getRecType('Account','On_Trade');
     
       Account Acc = new Account();  
        Acc.OwnerId = UserInfo.getUserId();    
        //Acc.OwnerId = usuario.Id;      
        Acc.Name = 'ProdutoOppVerificaCotaExistenteTeste';      
        Acc.CNPJ__c = '48843971000120';      
        Acc.Type = 'Outros';      
        Acc.RecordTypeId = idAccount;      
        Acc.Status__c = 'Cliente cadastrado no JDE';      
        Acc.Agency__c = '000';      
        Acc.Current_account__c = '0';      
        Acc.Corporate_Name__c = 'Teste';      
        Acc.Channel__c = 'On Trade';  
        Acc.Rating = 'Cliente';    
        Acc.Segmentation_Type_on_trade__c = 'Bar';      
        Acc.Frequency_of_Visits__c = 'Semanal';      
        Acc.Client_code_AN8__c = '557799';      
        Acc.Price_Group__c = '1';      
        //Acc.Customer_Flag__c = bandeira.Id;      
        insert Acc;
      //Cria novo usuario.

      User gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      Database.Saveresult sResult = Database.insert( gerente, false );
      system.assert( sResult.isSuccess() );

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
      usuario.ManagerId           = gerente.Id;
      usuario.Country = 'BR';
      sResult = Database.insert( usuario, false );
      system.assert( sResult.isSuccess() );

      



        Test.startTest();
        Utils.setMigrationDoneTest(true); 

     
        //Cria um novo pagamento
        Pagamento__c payment = new Pagamento__c();
        payment.OwnerId               = usuario.Id;
        payment.Recebedor__c          = 'Cliente Abertura da RV';
        payment.Forma_de_Pagamento__c ='Deposito em Conta';
        payment.Cliente__c = Acc.Id;


        insert payment;


        //sResult = Database.insert( payment, false );
        system.debug('%%%%%%%%%%  Database.insert result : '+ sResult.getErrors());
        //system.assert( sResult.isSuccess() );
        
        LAT_Product__c lProd = new LAT_Product__c();
        lProd.Name = 'Cachaca';
        lProd.LAT_ExternalId__c = 'qeweqewq';
        insert lProd;








        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );

        LAT_Contract__c Lc = new LAT_Contract__c();
        Lc.Account__c = Acc.Id;
        Lc.Status__c = 'Em elaboração';
        Lc.StartDate__c = System.today();
        Lc.ContractTerm__c = 12;
        Lc.RecordTypeId = idrecTypeLatCon;
        Lc.ROI_Comentarios_Negativo__c = 'teste';
        //insert lContract;
        insert Lc;
          
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
        ibp.Finalidade__c = 'Contrato';
        ibp.LAT_Contract__c = Lc.id;
        ibp.Valor_R__c = 100;
        ibp.LAT_Product__c = lProd.id;
        ibp.Status_da_Verba__c = 'Reservado';
        ibp.Numero_da_DA__c = '120';
        //ibp.Numero_da_RV_criada__c = 'teste'; 
        //insert ibp;
        insert ibp;

        Pagamento__c lPagto = new Pagamento__c();
        lPagto.Cliente__c = acc.Id;
        lPagto.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento__c', 'Dinheiro' );
        //insert lPagto;
        insert lPagto;


      
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c();
        lPagtoVerba.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' );
        lPagtoVerba.Pagamento__c = lPagto.id;
        lPagtoVerba.Investimento_Bonifica_o_e_Pagamento__c = ibp.id;
        lPagtoVerba.valor_a_pagar__c = 1.45;
        //insert lPagtoVerba;
       insert lPagtoVerba;













       

        //Cria nova Clausula de contrato.     
        Cl_usulas_do_Contrato__c Cc = new  Cl_usulas_do_Contrato__c();
        Cc.Contrato__c = Lc.Id;
        insert Cc;

        //Cria nova type de doc.      
        Tipo_de_Documento__c Td = new Tipo_de_Documento__c(); 
        td.LAT_Contract__c = lc.id;
        insert Td;

        Lc.Cl_usulas_do_Contrato__c = Cc.Id;
        Lc.Status__c = 'Em elaboração';
        Lc.ContractTerm__c = 12; 
        update Lc; 
          
        Rateio_do_Contrato__c lRateio = new Rateio_do_Contrato__c();
        lRateio.Perc_de_Rateio__c = 100;
        lRateio.RecordTypeId = RecordTypeForTest.getRecType( 'Rateio_do_Contrato__c', 'BRA_Standard' );
        lRateio.LAT_Contract__c = Lc.Id;
        insert lRateio;  

        User admin = [SELECT Id FROM user WHERE Profile.Name = 'LAT_SystemAdministrator' AND isActive = true limit 1];                  
        
        //Cria um novo pagamento de verba
        Pagamento_da_Verba__c pagVerba = 
          new Pagamento_da_Verba__c( 
            Pagamento__c=payment.Id, 
            Investimento_Bonifica_o_e_Pagamento__c=ibp.Id,
            RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c' , 'Dinheiro' ),
            LAT_Product__c = ibp.LAT_Product__c,
            Conta__c = Acc.Id
            //valor_a_pagar__c = 1.45
        );

        insert pagVerba;  

        
        //sResult = Database.insert( pagVerba, false );
       // system.assert( sResult.isSuccess() );
       System.debug('%%%%%%% select de Pagamento_da_Verba__c :' +[Select id, name, Pagamento__c from Pagamento_da_Verba__c limit 10]);
        payment = [Select Id, OwnerId, Recebedor__c, Forma_de_Pagamento__c,Conta_itens_de_verba__c 
          FROM Pagamento__c WHERE Id =: payment.Id limit 1 ];
        
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setNextApproverIds( new List< Id >{ payment.OwnerId});
        req.setObjectId( payment.Id );
        try{
          // submit the approval request for processing
          Approval.ProcessResult result = Approval.process( req );
        }catch(Exception e){
          system.debug(e.getMessage());
        }
        RVManagerInterface.RVManagerInvoke(IBP.Id, payment.Id);
      
      Test.stopTest();
    }


    static testMethod void myUnitTest5() 
    {
      Utils.setMigrationDoneTest(false); 
      //Recupera ids de tipo de registro
      Set< Id > setRecTypePV = new Set< Id >();
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos' ) );
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' ) );
      
            
      //Cria novo usuario.
      
      ID idAccount = RecordTypeForTest.getRecType('Account','On_Trade');
     
       Account Acc = new Account();  
        Acc.OwnerId = UserInfo.getUserId();    
        //Acc.OwnerId = usuario.Id;      
        Acc.Name = 'ProdutoOppVerificaCotaExistenteTeste';      
        Acc.CNPJ__c = '48843971000120';      
        Acc.Type = 'Outros';      
        Acc.RecordTypeId = idAccount;      
        Acc.Status__c = 'Cliente cadastrado no JDE';      
        Acc.Agency__c = '000';      
        Acc.Current_account__c = '0';      
        Acc.Corporate_Name__c = 'Teste';      
        Acc.Channel__c = 'On Trade';  
        Acc.Rating = 'Cliente';    
        Acc.Segmentation_Type_on_trade__c = 'Bar';      
        Acc.Frequency_of_Visits__c = 'Semanal';      
        Acc.Client_code_AN8__c = '557799';      
        Acc.Price_Group__c = '1';      
        //Acc.Customer_Flag__c = bandeira.Id;      
        insert Acc;
      //Cria novo usuario.

      User gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      Database.Saveresult sResult = Database.insert( gerente, false );
      system.assert( sResult.isSuccess() );

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
      usuario.ManagerId           = gerente.Id;
      usuario.Country = 'BR';
      sResult = Database.insert( usuario, false );
      system.assert( sResult.isSuccess() );

      




     
        //Cria um novo pagamento
        Pagamento__c payment = new Pagamento__c();
        payment.OwnerId               = usuario.Id;
        payment.Recebedor__c          = 'Cliente Abertura da RV';
        payment.Forma_de_Pagamento__c ='Deposito em Conta';
        payment.Cliente__c = Acc.Id;


        insert payment;


        //sResult = Database.insert( payment, false );
        system.debug('%%%%%%%%%%  Database.insert result : '+ sResult.getErrors());
        //system.assert( sResult.isSuccess() );
        
        Product2 lProd = new Product2();
        lProd.Name = 'Cachaca';
        lProd.Internal_ID__c = 'qeweqewq';
        lProd.SKU__c = '1234';
        insert lProd;








        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        
        Test.startTest();
        Utils.setMigrationDoneTest(false); 

        LAT_Contract__c Lc = new LAT_Contract__c();
        Lc.Account__c = Acc.Id;
        Lc.Status__c = 'Em elaboração';
        Lc.StartDate__c = System.today();
        Lc.ContractTerm__c = 12;
        Lc.RecordTypeId = idrecTypeLatCon;
        Lc.ROI_Comentarios_Negativo__c = 'teste';
        //insert lContract;
        insert Lc;
          


        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' );
        ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
        ibp.Finalidade__c = 'Contrato';
        ibp.LAT_Contract__c = Lc.id;
        ibp.Valor_R__c = 0;
        ibp.Produto_Bonificado__c = lProd.id;
        ibp.Status_da_Verba__c = 'Reservado';
        ibp.Numero_da_DA__c = '120';
        
        //ibp.Numero_da_RV_criada__c = 'teste'; 
        //insert ibp;
        insert ibp;


        Pagamento__c lPagto = new Pagamento__c();
        lPagto.Cliente__c = acc.Id;
        lPagto.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento__c', 'Bonificacao_Produtos' );
        //insert lPagto;
        insert lPagto;


      
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c();
        lPagtoVerba.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos' );
        lPagtoVerba.Pagamento__c = lPagto.id;
        lPagtoVerba.Investimento_Bonifica_o_e_Pagamento__c = ibp.id;
        lPagtoVerba.valor_a_pagar__c = 1.45;
        //insert lPagtoVerba;
       insert lPagtoVerba;













       

        //Cria nova Clausula de contrato.     
        Cl_usulas_do_Contrato__c Cc = new  Cl_usulas_do_Contrato__c();
        Cc.Contrato__c = Lc.Id;
        insert Cc;

        //Cria nova type de doc.      
        Tipo_de_Documento__c Td = new Tipo_de_Documento__c(); 
        td.LAT_Contract__c = lc.id;
        insert Td;

        Lc.Cl_usulas_do_Contrato__c = Cc.Id;
        Lc.Status__c = 'Em elaboração';
        Lc.ContractTerm__c = 12; 
        update Lc; 
          
        Rateio_do_Contrato__c lRateio = new Rateio_do_Contrato__c();
        lRateio.Perc_de_Rateio__c = 100;
        lRateio.RecordTypeId = RecordTypeForTest.getRecType( 'Rateio_do_Contrato__c', 'BRA_Standard' );
        lRateio.LAT_Contract__c = Lc.Id;
        insert lRateio;  

        User admin = [SELECT Id FROM user WHERE Profile.Name = 'LAT_SystemAdministrator' AND isActive = true limit 1];                  
        //System.runAs(admin){
        //Cria um novo pagamento de verba
        Pagamento_da_Verba__c pagVerba = 
          new Pagamento_da_Verba__c( 
            Pagamento__c=payment.Id, 
            Investimento_Bonifica_o_e_Pagamento__c=ibp.Id,
            RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c' , 'Bonificacao_Produtos' ),
            LAT_Product__c = ibp.LAT_Product__c,
            Conta__c = Acc.Id
            //valor_a_pagar__c = 1.45
        );

        insert pagVerba;  

      //}
        //sResult = Database.insert( pagVerba, false );
       // system.assert( sResult.isSuccess() );
       System.debug('%%%%%%% select de Pagamento_da_Verba__c :' +[Select id, name, Pagamento__c from Pagamento_da_Verba__c limit 10]);
        payment = [Select Id, OwnerId, Recebedor__c, Forma_de_Pagamento__c,Conta_itens_de_verba__c 
          FROM Pagamento__c WHERE Id =: payment.Id limit 1 ];
        
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setNextApproverIds( new List< Id >{ payment.OwnerId});
        req.setObjectId( payment.Id );
        try{
          // submit the approval request for processing
          Approval.ProcessResult result = Approval.process( req );
        }catch(Exception e){
          system.debug(e.getMessage());
        }
        RVManagerInterface.RVManagerInvoke(IBP.Id, payment.Id);
      
      Test.stopTest();
    }
    
    static testMethod void myUnitTest5B() 
    {
      Utils.setMigrationDoneTest(true); 
      //Recupera ids de tipo de registro
      Set< Id > setRecTypePV = new Set< Id >();
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos' ) );
      setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro' ) );
      
            
      //Cria novo usuario.
      
      ID idAccount = RecordTypeForTest.getRecType('Account','On_Trade');
     
       Account Acc = new Account();  
        Acc.OwnerId = UserInfo.getUserId();    
        //Acc.OwnerId = usuario.Id;      
        Acc.Name = 'ProdutoOppVerificaCotaExistenteTeste';      
        Acc.CNPJ__c = '48843971000120';      
        Acc.Type = 'Outros';      
        Acc.RecordTypeId = idAccount;      
        Acc.Status__c = 'Cliente cadastrado no JDE';      
        Acc.Agency__c = '000';      
        Acc.Current_account__c = '0';      
        Acc.Corporate_Name__c = 'Teste';      
        Acc.Channel__c = 'On Trade';  
        Acc.Rating = 'Cliente';    
        Acc.Segmentation_Type_on_trade__c = 'Bar';      
        Acc.Frequency_of_Visits__c = 'Semanal';      
        Acc.Client_code_AN8__c = '557799';      
        Acc.Price_Group__c = '1';      
        //Acc.Customer_Flag__c = bandeira.Id;      
        insert Acc;
      //Cria novo usuario.

      User gerente = new User();
      gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      Database.Saveresult sResult = Database.insert( gerente, false );
      system.assert( sResult.isSuccess() );

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
      usuario.ManagerId           = gerente.Id;
      usuario.Country = 'BR';
      sResult = Database.insert( usuario, false );
      system.assert( sResult.isSuccess() );

      




     
        //Cria um novo pagamento
        Pagamento__c payment = new Pagamento__c();
        payment.OwnerId               = usuario.Id;
        payment.Recebedor__c          = 'Cliente Abertura da RV';
        payment.Forma_de_Pagamento__c ='Deposito em Conta';
        payment.Cliente__c = Acc.Id;


        insert payment;


        //sResult = Database.insert( payment, false );
        system.debug('%%%%%%%%%%  Database.insert result : '+ sResult.getErrors());
        //system.assert( sResult.isSuccess() );
        
        LAT_Product__c lProd = new LAT_Product__c();
        lProd.Name = 'Cachaca';
        lProd.LAT_ExternalId__c = 'qeweqewq';
        lProd.LAT_SKU__c = '1234';
        insert lProd;






        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );


        Test.startTest();
        Utils.setMigrationDoneTest(true); 

        LAT_Contract__c Lc = new LAT_Contract__c();
        Lc.Account__c = Acc.Id;
        Lc.Status__c = 'Em elaboração';
        Lc.StartDate__c = System.today();
        Lc.ContractTerm__c = 12;
        Lc.RecordTypeId = idrecTypeLatCon;
        Lc.ROI_Comentarios_Negativo__c = 'teste';
        //insert lContract;
        insert Lc;
          
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' );
        ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
        ibp.Finalidade__c = 'Contrato';
        ibp.LAT_Contract__c = Lc.id;
        ibp.Valor_R__c = 0;
        ibp.LAT_Product__c = lProd.id;
        ibp.Status_da_Verba__c = 'Reservado';
        ibp.Numero_da_DA__c = '120';
        //ibp.Numero_da_RV_criada__c = 'teste'; 
        //insert ibp;
        insert ibp;

        Pagamento__c lPagto = new Pagamento__c();
        lPagto.Cliente__c = acc.Id;
        lPagto.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento__c', 'Bonificacao_Produtos' );
        //insert lPagto;
        insert lPagto;


      
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c();
        lPagtoVerba.RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos' );
        lPagtoVerba.Pagamento__c = lPagto.id;
        lPagtoVerba.Investimento_Bonifica_o_e_Pagamento__c = ibp.id;
        lPagtoVerba.valor_a_pagar__c = 1.45;
        //insert lPagtoVerba;
       insert lPagtoVerba;













       

        //Cria nova Clausula de contrato.     
        Cl_usulas_do_Contrato__c Cc = new  Cl_usulas_do_Contrato__c();
        Cc.Contrato__c = Lc.Id;
        insert Cc;

        //Cria nova type de doc.      
        Tipo_de_Documento__c Td = new Tipo_de_Documento__c(); 
        td.LAT_Contract__c = lc.id;
        insert Td;

        Lc.Cl_usulas_do_Contrato__c = Cc.Id;
        Lc.Status__c = 'Em elaboração';
        Lc.ContractTerm__c = 12; 
        update Lc; 
          
        Rateio_do_Contrato__c lRateio = new Rateio_do_Contrato__c();
        lRateio.Perc_de_Rateio__c = 100;
        lRateio.RecordTypeId = RecordTypeForTest.getRecType( 'Rateio_do_Contrato__c', 'BRA_Standard' );
        lRateio.LAT_Contract__c = Lc.Id;
        insert lRateio;  

        User admin = [SELECT Id FROM user WHERE Profile.Name = 'LAT_SystemAdministrator' AND isActive = true limit 1];                  
        //System.runAs(admin){
        //Cria um novo pagamento de verba
        Pagamento_da_Verba__c pagVerba = 
          new Pagamento_da_Verba__c( 
            Pagamento__c=payment.Id, 
            Investimento_Bonifica_o_e_Pagamento__c=ibp.Id,
            RecordTypeId = RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c' , 'Bonificacao_Produtos' ),
            LAT_Product__c = ibp.LAT_Product__c,
            Conta__c = Acc.Id
            //valor_a_pagar__c = 1.45
        );

        insert pagVerba;  

      //}
        //sResult = Database.insert( pagVerba, false );
       // system.assert( sResult.isSuccess() );
       System.debug('%%%%%%% select de Pagamento_da_Verba__c :' +[Select id, name, Pagamento__c from Pagamento_da_Verba__c limit 10]);
        payment = [Select Id, OwnerId, Recebedor__c, Forma_de_Pagamento__c,Conta_itens_de_verba__c 
          FROM Pagamento__c WHERE Id =: payment.Id limit 1 ];
        
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setNextApproverIds( new List< Id >{ payment.OwnerId});
        req.setObjectId( payment.Id );
        try{
          // submit the approval request for processing
          Approval.ProcessResult result = Approval.process( req );
        }catch(Exception e){
          system.debug(e.getMessage());
        }
        RVManagerInterface.RVManagerInvoke(IBP.Id, payment.Id);
      
      Test.stopTest();
    }

}