@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura do código ChecklistVisitaCria.cls
*
* NAME: ChecklistVisitaCriaTest.cls
* AUTHOR:                           DATE:  
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 09/01/2013 
********************************************************************************/
       /********************************************************************************
      * 
      * MIGRACION LICENCIAS 
      * AUTHOR: ZIMMIC                     DATE: 17/11/2016
      *
      ********************************************************************************/
private class ChecklistVisitaCriaTest {

    static testMethod void ChecklistVisitaCriaTest() {
        System.debug('&&&&&&&&&&&&&&& ChecklistVisitaCriaTest');
        Utils.setMigrationDoneTest(false);     
        
        Set< Id > setRecTypeLatCon = new Set< Id >();
        
        //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
        
        /*LAT_Contract__c lContrato = [ SELECT id, Account__c FROM LAT_Contract__c 
            WHERE Status__c = 'Em elaboração' AND Status_do_processo__c='Estudo em elaboração' 
            AND Account__r.Channel_Type__c ='Indireto' AND RecordTypeId =: setRecTypeLatCon limit 1];*/
        
        UDC__c regional = new UDC__c();      
        regional.CodDefUsuario__c = '1';      
        regional.CodProd__c     = '01';      
        regional.CodUs__c     = '01';      
        regional.Internal_Id__c   = '1234Jef';      
        regional.RecordTypeId = idRecTypeUdc;      
        insert regional;   
        regional.CodDefUsuario__c = '2'; 
        update regional;
        

        User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        //insert usuario;
        try{insert usuario;}catch(Exception e){}
        

            //Cria novo Account.
        Account acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade');
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Channel__c = 'Off Trade';
        //acc.Regional__c = regional.Id;
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Channel_Type__c = 'Indireto';
        acc.Client_code_AN8__c = '557799';
        acc.Price_Group__c = '1';
        //acc.Customer_Flag__c = bandeira.Id;
        insert acc;
        Product2 produto = new Product2();
        produto.Name = 'Cloud2b'; 
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        produto.Internal_id__c = '444';
        //produto.QT_lead_time__c = 5;
        produto.SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
        //insert produto;
        insert produto;

        Produto_Concorrente__c lProdConcorrente = new Produto_Concorrente__c();
        lProdConcorrente.name = 'Red Label';
        lProdConcorrente.Classifica_o__c = 'Whisky';
        lProdConcorrente.Empresa_Fabricante__c = 'Johnnie Walker';
        lProdConcorrente.RecordTypeId = RecordTypeForTest.getRecType( 'Produto_Concorrente__c', 'BRA_Standard' );
        //insert lProdConcorrente;
        insert lProdConcorrente;

        Test.startTest();
        Utils.setMigrationDoneTest(false);     



        LAT_Contract__c contract = new LAT_Contract__c();
        contract.OwnerId = usuario.Id;
        contract.Account__c = acc.Id;
        contract.Status__c = 'Ativo';
        contract.StartDate__c = System.today();
        contract.ContractTerm__c = 12;
        contract.Volume_absolut_100__c = 12;

        contract.Uniforme__c = 'testete';
        //contract.Status_do_processo__c='Estudo em elaboração'; 
        contract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Ativacao_de_contrato');
        contract.ROI_Comentarios_Negativo__c = 'teste';
        //insert contract;
        insert contract;

       
        
        Agrupamento_Fiscal_Year__c agr = new Agrupamento_Fiscal_Year__c();
        agr.Ano_Fiscal__c = String.valueOf( System.today().year() );
        agr.LAT_Contract__c = contract.Id;
        //insert agr;
        insert agr;


        Planejamento__c lPlan = new Planejamento__c();
        lPlan.Ano_de_Referencia__c = '2012';
        lPlan.M_s_de_Ref_rencia__c = 'Dezembro';
        lPlan.Name = 'Teste';
        lPlan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard');
        //insert lPlan;
        insert lPlan;

        Par_metro_Produto_Concorr_ncia__c param = new Par_metro_Produto_Concorr_ncia__c();
        param.Canal__c = 'Off Trade';
        param.Regional__c = regional.Id;
        param.Produto_Pernod__c = produto.Id;
        param.Produto_Concorrencia__c = lProdConcorrente.id;
        param.sub__c = 'Distribuidor';
        param.RecordTypeId = RecordTypeForTest.getRecType( 'Par_metro_Produto_Concorr_ncia__c', 'Produtos_Concorr_ncia' );
        
        insert param;     
        
        Visitas__c lVisita = new Visitas__c();
        lVisita.Conta__c = contract.Account__c;
        lVisita.Name = 'Planejamento de visitas'; 
        lVisita.Planejamento__c = lPlan.id;
        lVisita.Data_da_Visita__c = Date.today();
        lVisita.Hora_da_Visita__c = '08:00';
        lVisita.Resumo_da_Visita__c = 'resumo';
        lVisita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
        //insert lVisita;
        insert lVisita;
        
        Checklist_de_visita__c lCheck = new Checklist_de_visita__c();
        lCheck.Visita__c = lVisita.id;
        lCheck.recordTypeId = RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'On_Trade' );
        //insert lCheck;
        insert lCheck;
        
        List< String > lListCheck = new List< String >();
        lListCheck.add( lCheck.id );
        
        List< String > lListAcc = new List< String >();
        lListAcc.add( contract.Account__c );
            
        new ChecklistVisitaCria( lListCheck, lListAcc );
        Test.stopTest();
        
    }

    static testMethod void ChecklistVisitaCriaTestB() {
        System.debug('&&&&&&&&&&&&&&& ChecklistVisitaCriaTestB');
        Utils.setMigrationDoneTest(true);     
        
        Set< Id > setRecTypeLatCon = new Set< Id >();
        
        //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
        
        /*LAT_Contract__c lContrato = [ SELECT id, Account__c FROM LAT_Contract__c 
            WHERE Status__c = 'Em elaboração' AND Status_do_processo__c='Estudo em elaboração' 
            AND Account__r.Channel_Type__c ='Indireto' AND RecordTypeId =: setRecTypeLatCon limit 1];*/
        UDC__c regional = new UDC__c();      
        regional.CodDefUsuario__c = '1';      
        regional.CodProd__c     = '01';      
        regional.CodUs__c     = '01';      
        regional.Internal_Id__c   = '1234Jef';      
        regional.RecordTypeId = idRecTypeUdc;      
        insert regional;   
        regional.CodDefUsuario__c = '2'; 
        update regional;
        
        User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        //insert usuario;
        try{insert usuario;}catch(Exception e){}
        

            //Cria novo Account.
        Account acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade');
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Channel__c = 'Off Trade';
        //acc.Regional__c = regional.Id;
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Channel_Type__c = 'Indireto';
        acc.Client_code_AN8__c = '557799';
        acc.Price_Group__c = '1';
        //acc.Customer_Flag__c = bandeira.Id;
        insert acc;


        LAT_Product__c produto = new LAT_Product__c();
        produto.Name = 'Cloud2b'; 
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '444';
        //produto.QT_lead_time__c = 5;
        produto.LAT_SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
        //insert produto;
        insert produto;

        Produto_Concorrente__c lProdConcorrente = new Produto_Concorrente__c();
        lProdConcorrente.name = 'Red Label';
        lProdConcorrente.Classifica_o__c = 'Whisky';
        lProdConcorrente.Empresa_Fabricante__c = 'Johnnie Walker';
        lProdConcorrente.RecordTypeId = RecordTypeForTest.getRecType( 'Produto_Concorrente__c', 'BRA_Standard' );
        //insert lProdConcorrente;
        insert lProdConcorrente;


        Test.startTest();
        Utils.setMigrationDoneTest(true);   
  
        
        LAT_Contract__c contract = new LAT_Contract__c();
        contract.OwnerId = usuario.Id;
        contract.Account__c = acc.Id;
        contract.Status__c = 'Ativo';
        contract.StartDate__c = System.today();
        contract.ContractTerm__c = 12;
        contract.Volume_absolut_100__c = 12;

        contract.Uniforme__c = 'testete';
        //contract.Status_do_processo__c='Estudo em elaboração'; 
        contract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Ativacao_de_contrato');
        contract.ROI_Comentarios_Negativo__c = 'teste';
        //insert contract;
        insert contract;

        Agrupamento_Fiscal_Year__c agr = new Agrupamento_Fiscal_Year__c();
        agr.Ano_Fiscal__c = String.valueOf( System.today().year() );
        agr.LAT_Contract__c = contract.Id;
        //insert agr;
        insert agr;

        Planejamento__c lPlan = new Planejamento__c();
        lPlan.Ano_de_Referencia__c = '2012';
        lPlan.M_s_de_Ref_rencia__c = 'Dezembro';
        lPlan.Name = 'Teste';
        lPlan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard');
        //insert lPlan;
        insert lPlan;

        Par_metro_Produto_Concorr_ncia__c param = new Par_metro_Produto_Concorr_ncia__c();
        param.Canal__c = 'Off Trade';
        param.Regional__c = regional.Id;
        param.LAT_Product__c = produto.Id;
        param.sub__c = 'Distribuidor';
        param.Produto_Concorrencia__c = lProdConcorrente.id;
        param.RecordTypeId = RecordTypeForTest.getRecType( 'Par_metro_Produto_Concorr_ncia__c', 'Sellout' );
        
        insert param;
        
        Visitas__c lVisita = new Visitas__c();
        lVisita.Conta__c = contract.Account__c;
        lVisita.Name = 'Planejamento de visitas'; 
        lVisita.Planejamento__c = lPlan.id;
        lVisita.Hora_da_Visita__c = '18:00';
        lVisita.Data_da_Visita__c = Date.today();
        lVisita.Resumo_da_Visita__c = 'resumo';
        lVisita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
        //insert lVisita;
        insert lVisita;


        


        Checklist_de_visita__c lCheck = new Checklist_de_visita__c();
        lCheck.Visita__c = lVisita.id;
        lCheck.recordTypeId = RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'On_Trade' );
        //insert lCheck;
        insert lCheck;
        
        List< String > lListCheck = new List< String >();
        lListCheck.add( lCheck.id );

        System.debug('%%%%%%%%%%%%%%%%%%% lListCheck '+ lListCheck);
        List< String > lListAcc = new List< String >();
        lListAcc.add( contract.Account__c );
            
        new ChecklistVisitaCria( lListCheck, lListAcc );
        Test.stopTest();
    }

    static testMethod void ChecklistVisitaCriaTest2() {
        System.debug('&&&&&&&&&&&&&&& ChecklistVisitaCriaTest2');
        Utils.setMigrationDoneTest(false);     
        
        Set< Id > setRecTypeLatCon = new Set< Id >();
        
        //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
        
        /*LAT_Contract__c lContrato = [ SELECT id, Account__c FROM LAT_Contract__c 
            WHERE Status__c = 'Em elaboração' AND Status_do_processo__c='Estudo em elaboração' 
            AND Account__r.Channel_Type__c ='Indireto' AND RecordTypeId =: setRecTypeLatCon limit 1];*/
        
        UDC__c regional = new UDC__c();      
        regional.CodDefUsuario__c = '1';      
        regional.CodProd__c     = '01';      
        regional.CodUs__c     = '01';      
        regional.Internal_Id__c   = '1234Jef';      
        regional.RecordTypeId = idRecTypeUdc;      
        insert regional;   
        regional.CodDefUsuario__c = '2'; 
        update regional;
        

        User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        //insert usuario;
        try{insert usuario;}catch(Exception e){}
        

            /*/Cria novo Account.
        Account acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'On_Trade');
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Channel__c = 'Off Trade';
        //acc.Regional__c = regional.Id;
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Channel_Type__c = 'Indireto';
        acc.Client_code_AN8__c = '557799';
        acc.Price_Group__c = '1';
        //acc.Customer_Flag__c = bandeira.Id;
        insert acc;*/

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
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Channel__c = 'On Trade';
        acc.Channel_Type__c = 'Indireto';
        acc.Price_Group__c = '1';
        acc.Client_code_AN8__c = '557799';
        //acc.Regional__c = regional.id;
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account','On_Trade');
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        //insert acc;
        insert acc;




        Product2 produto = new Product2();
        produto.Name = 'Cloud2b'; 
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        produto.Internal_id__c = '444';
        //produto.QT_lead_time__c = 5;
        produto.SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
        //insert produto;
        insert produto;

        Produto_Concorrente__c lProdConcorrente = new Produto_Concorrente__c();
        lProdConcorrente.name = 'Red Label';
        lProdConcorrente.Classifica_o__c = 'Whisky';
        lProdConcorrente.Empresa_Fabricante__c = 'Johnnie Walker';
        lProdConcorrente.RecordTypeId = RecordTypeForTest.getRecType( 'Produto_Concorrente__c', 'BRA_Standard' );
        //insert lProdConcorrente;
        insert lProdConcorrente;



        Test.startTest();
        Utils.setMigrationDoneTest(false);     
        LAT_Contract__c contract = new LAT_Contract__c();
        contract.OwnerId = usuario.Id;
        contract.Account__c = acc.Id;
        contract.Status__c = 'Ativo';
        contract.StartDate__c = System.today();
        contract.ContractTerm__c = 12;

        contract.Uniforme__c = 'testete';
        contract.Volume_absolut_100__c = 2;
        //contract.Status_do_processo__c='Estudo em elaboração'; 
        contract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Ativacao_de_contrato');
        contract.ROI_Comentarios_Negativo__c = 'teste';
        //insert contract;
        insert contract;
        

       



        LAT_Contract__c contract2 = new LAT_Contract__c();
        contract2.OwnerId = usuario.Id;
        contract2.Account__c = acc.Id;
        contract2.Status__c = 'Em elaboração';
        contract2.StartDate__c = System.today();
        contract2.ContractTerm__c = 12;
        contract2.Status_do_processo__c='Estudo em elaboração'; 
        contract2.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Alteracao_de_contrato_on');
        contract2.ROI_Comentarios_Negativo__c = 'teste2';
        contract2.Volume_absolut_100__c = 1;
        contract2.Uniforme__c = 'testete';
        //insert contract;
        //insert contract2;
        
        Agrupamento_Fiscal_Year__c agr = new Agrupamento_Fiscal_Year__c();
        agr.Ano_Fiscal__c = String.valueOf( System.today().year() );
        agr.LAT_Contract__c = contract.Id;
        //insert agr;
        insert agr;


        Planejamento__c lPlan = new Planejamento__c();
        lPlan.Ano_de_Referencia__c = '2012';
        lPlan.M_s_de_Ref_rencia__c = 'Dezembro';
        lPlan.Name = 'Teste';
        lPlan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard');
        //insert lPlan;
        insert lPlan;

        Par_metro_Produto_Concorr_ncia__c param = new Par_metro_Produto_Concorr_ncia__c();
        param.Canal__c = 'On Trade';
        param.Regional__c = regional.Id;
        param.Produto_Pernod__c = produto.Id;
        param.Produto_Concorrencia__c = lProdConcorrente.id;
        param.sub__c = 'Distribuidor';
        param.RecordTypeId = RecordTypeForTest.getRecType( 'Par_metro_Produto_Concorr_ncia__c', 'Sellout' );
        
        insert param;

 
        
        Visitas__c lVisita = new Visitas__c();
        lVisita.Conta__c = contract.Account__c;
        lVisita.Name = 'Planejamento de visitas'; 
        lVisita.Planejamento__c = lPlan.id;
        lVisita.Data_da_Visita__c = Date.today();
        lVisita.Hora_da_Visita__c = '08:00';
        lVisita.Resumo_da_Visita__c = 'resumo';
        lVisita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
        //insert lVisita;
        insert lVisita;
        
        Checklist_de_visita__c lCheck = new Checklist_de_visita__c();
        lCheck.Visita__c = lVisita.id;
        lCheck.recordTypeId = RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'On_Trade' );
        //insert lCheck;
        insert lCheck;
        
        List< String > lListCheck = new List< String >();
        lListCheck.add( lCheck.id );
        
        List< String > lListAcc = new List< String >();
        lListAcc.add( contract.Account__c );
            
        new ChecklistVisitaCria( lListCheck, lListAcc );
        Test.stopTest();
        
    }

    static testMethod void ChecklistVisitaCriaTest2B() {
        System.debug('&&&&&&&&&&&&&&& ChecklistVisitaCriaTest2B');
        Utils.setMigrationDoneTest(true);     
        
        Set< Id > setRecTypeLatCon = new Set< Id >();
        
        //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
        
        /*LAT_Contract__c lContrato = [ SELECT id, Account__c FROM LAT_Contract__c 
            WHERE Status__c = 'Em elaboração' AND Status_do_processo__c='Estudo em elaboração' 
            AND Account__r.Channel_Type__c ='Indireto' AND RecordTypeId =: setRecTypeLatCon limit 1];*/
        UDC__c regional = new UDC__c();      
        regional.CodDefUsuario__c = '1';      
        regional.CodProd__c     = '01';      
        regional.CodUs__c     = '01';      
        regional.Internal_Id__c   = '1234Jef';      
        regional.RecordTypeId = idRecTypeUdc;      
        insert regional;   
        regional.CodDefUsuario__c = '2'; 
        update regional;
        
        User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        //insert usuario;
        try{insert usuario;}catch(Exception e){}
        

            /*/Cria novo Account.
        Account acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account','On_Trade');
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Channel__c = 'Off Trade';
        //acc.Regional__c = regional.Id;
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Channel_Type__c = 'Indireto';
        acc.Client_code_AN8__c = '557799';
        acc.Price_Group__c = '1';
        //acc.Customer_Flag__c = bandeira.Id;
        insert acc;*/

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
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Channel__c = 'On Trade';
        acc.Channel_Type__c = 'Indireto';
        acc.Price_Group__c = '1';
        acc.Client_code_AN8__c = '557799';
        //acc.Regional__c = regional.id;
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account','On_Trade');
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        //insert acc;
        insert acc;

        LAT_Product__c produto = new LAT_Product__c();
        produto.Name = 'Cloud2b'; 
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '444';
        //produto.QT_lead_time__c = 5;
        produto.LAT_SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
        //insert produto;
        insert produto;

        Produto_Concorrente__c lProdConcorrente = new Produto_Concorrente__c();
        lProdConcorrente.name = 'Red Label';
        lProdConcorrente.Classifica_o__c = 'Whisky';
        lProdConcorrente.Empresa_Fabricante__c = 'Johnnie Walker';
        lProdConcorrente.RecordTypeId = RecordTypeForTest.getRecType( 'Produto_Concorrente__c', 'BRA_Standard' );
        //insert lProdConcorrente;
        insert lProdConcorrente;




        Test.startTest();
        Utils.setMigrationDoneTest(true);   
  
        
        LAT_Contract__c contract = new LAT_Contract__c();
        contract.OwnerId = usuario.Id;
        contract.Account__c = acc.Id;
        contract.Status__c = 'Ativo';
        contract.StartDate__c = System.today();
        contract.ContractTerm__c = 12;
        //contract.Status_do_processo__c='Estudo em elaboração'; 
        contract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Ativacao_de_contrato');
        contract.ROI_Comentarios_Negativo__c = 'teste';
        //insert contract;
        insert contract;


        
        Agrupamento_Fiscal_Year__c agr = new Agrupamento_Fiscal_Year__c();
        agr.Ano_Fiscal__c = String.valueOf( System.today().year() );
        agr.LAT_Contract__c = contract.Id;
        //insert agr;
        insert agr;
        Par_metro_Produto_Concorr_ncia__c param = new Par_metro_Produto_Concorr_ncia__c();
        param.Canal__c = 'On Trade';
        param.Regional__c = regional.Id;
        param.LAT_Product__c = produto.Id;
        param.Produto_Concorrencia__c = lProdConcorrente.id;
        param.sub__c = 'Distribuidor';
        param.RecordTypeId = RecordTypeForTest.getRecType( 'Par_metro_Produto_Concorr_ncia__c', 'Sellout' );
        
        insert param;     

        Planejamento__c lPlan = new Planejamento__c();
        lPlan.Ano_de_Referencia__c = '2012';
        lPlan.M_s_de_Ref_rencia__c = 'Dezembro';
        lPlan.Name = 'Teste';
        lPlan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard');
        //insert lPlan;
        insert lPlan;
        
        Visitas__c lVisita = new Visitas__c();
        lVisita.Conta__c = contract.Account__c;
        lVisita.Name = 'Planejamento de visitas'; 
        lVisita.Planejamento__c = lPlan.id;
        lVisita.Hora_da_Visita__c = '18:00';
        lVisita.Data_da_Visita__c = Date.today();
        lVisita.Resumo_da_Visita__c = 'resumo';
        lVisita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
        //insert lVisita;
        insert lVisita;


        


        Checklist_de_visita__c lCheck = new Checklist_de_visita__c();
        lCheck.Visita__c = lVisita.id;
        lCheck.recordTypeId = RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'On_Trade' );
        //insert lCheck;
        insert lCheck;
        
        List< String > lListCheck = new List< String >();
        lListCheck.add( lCheck.id );

        System.debug('%%%%%%%%%%%%%%%%%%% lListCheck '+ lListCheck);
        List< String > lListAcc = new List< String >();
        lListAcc.add( contract.Account__c );
            
        new ChecklistVisitaCria( lListCheck, lListAcc );
        Test.stopTest();
    }

    static testMethod void ChecklistVisitaCriaTest3B() {
        System.debug('&&&&&&&&&&&&&&& ChecklistVisitaCriaTest3B');
        Utils.setMigrationDoneTest(true);     
        
        Set< Id > setRecTypeLatCon = new Set< Id >();
        
        //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
        
        /*LAT_Contract__c lContrato = [ SELECT id, Account__c FROM LAT_Contract__c 
            WHERE Status__c = 'Em elaboração' AND Status_do_processo__c='Estudo em elaboração' 
            AND Account__r.Channel_Type__c ='Indireto' AND RecordTypeId =: setRecTypeLatCon limit 1];*/
        UDC__c regional = new UDC__c();      
        regional.CodDefUsuario__c = '1';      
        regional.CodProd__c     = '01';      
        regional.CodUs__c     = '01';      
        regional.Internal_Id__c   = '1234Jef';      
        regional.RecordTypeId = idRecTypeUdc;      
        insert regional;   
        regional.CodDefUsuario__c = '2'; 
        update regional;
        
        User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        //insert usuario;
        try{insert usuario;}catch(Exception e){}
        

            /*/Cria novo Account.
        Account acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account','On_Trade');
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Channel__c = 'Off Trade';
        //acc.Regional__c = regional.Id;
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Channel_Type__c = 'Indireto';
        acc.Client_code_AN8__c = '557799';
        acc.Price_Group__c = '1';
        //acc.Customer_Flag__c = bandeira.Id;
        insert acc;*/

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
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Channel__c = 'On Trade';
        acc.Channel_Type__c = 'Indireto';
        acc.Price_Group__c = '1';
        acc.Client_code_AN8__c = '557799';
        //acc.Regional__c = regional.id;
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account','On_Trade');
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        //insert acc;
        insert acc;

        LAT_Product__c produto = new LAT_Product__c();
        produto.Name = 'Cloud2b'; 
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '444';
        //produto.QT_lead_time__c = 5;
        produto.LAT_SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
        //insert produto;
        insert produto;

        Produto_Concorrente__c lProdConcorrente = new Produto_Concorrente__c();
        lProdConcorrente.name = 'Red Label';
        lProdConcorrente.Classifica_o__c = 'Whisky';
        lProdConcorrente.Empresa_Fabricante__c = 'Johnnie Walker';
        lProdConcorrente.RecordTypeId = RecordTypeForTest.getRecType( 'Produto_Concorrente__c', 'BRA_Standard' );
        //insert lProdConcorrente;
        insert lProdConcorrente;




        Test.startTest();
        Utils.setMigrationDoneTest(true);   
  
        
        LAT_Contract__c contract = new LAT_Contract__c();
        contract.OwnerId = usuario.Id;
        contract.Account__c = acc.Id;
        contract.Status__c = 'Em elaboração';
        contract.StartDate__c = System.today();
        contract.ContractTerm__c = 12;
        contract.Status_do_processo__c='Estudo em elaboração'; 
        contract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Ativacao_de_contrato');
        contract.ROI_Comentarios_Negativo__c = 'teste';
        //insert contract;
        insert contract;

        Contrapartida_de_Contrato_visitas__c ccv2 = new Contrapartida_de_Contrato_visitas__c();
        ccv2.Nome_da_Contrapartida_do_Contrato__c = 'test2';
        ccv2.LAT_Contract__c = contract.Id;
        insert ccv2;

        Contrapartida_de_Contrato_visitas__c ccv = new Contrapartida_de_Contrato_visitas__c();
        ccv.Nome_da_Contrapartida_do_Contrato__c = 'test';
        ccv.LAT_Contract__c = contract.Id;
        insert ccv;
        
        Agrupamento_Fiscal_Year__c agr = new Agrupamento_Fiscal_Year__c();
        agr.Ano_Fiscal__c = String.valueOf( System.today().year() );
        agr.LAT_Contract__c = contract.Id;
        //insert agr;
        insert agr;
        Par_metro_Produto_Concorr_ncia__c param = new Par_metro_Produto_Concorr_ncia__c();
        param.Canal__c = 'On Trade';
        param.Regional__c = regional.Id;
        param.LAT_Product__c = produto.Id;
        param.Produto_Concorrencia__c = lProdConcorrente.id;
        param.sub__c = 'Distribuidor';
        param.RecordTypeId = RecordTypeForTest.getRecType( 'Par_metro_Produto_Concorr_ncia__c', 'Produtos_Concorr_ncia' );
        
        insert param;     

        Planejamento__c lPlan = new Planejamento__c();
        lPlan.Ano_de_Referencia__c = '2012';
        lPlan.M_s_de_Ref_rencia__c = 'Dezembro';
        lPlan.Name = 'Teste';
        lPlan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard');
        //insert lPlan;
        insert lPlan;
        
        Visitas__c lVisita = new Visitas__c();
        lVisita.Conta__c = contract.Account__c;
        lVisita.Name = 'Planejamento de visitas'; 
        lVisita.Planejamento__c = lPlan.id;
        lVisita.Hora_da_Visita__c = '18:00';
        lVisita.Data_da_Visita__c = Date.today();
        lVisita.Resumo_da_Visita__c = 'resumo';
        lVisita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
        //insert lVisita;
        insert lVisita;


        


        Checklist_de_visita__c lCheck = new Checklist_de_visita__c();
        lCheck.Visita__c = lVisita.id;
        lCheck.recordTypeId = RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'On_Trade' );
        //insert lCheck;
        insert lCheck;
        
        List< String > lListCheck = new List< String >();
        lListCheck.add( lCheck.id );

        System.debug('%%%%%%%%%%%%%%%%%%% lListCheck '+ lListCheck);
        List< String > lListAcc = new List< String >();
        lListAcc.add( contract.Account__c );
            
        new ChecklistVisitaCria( lListCheck, lListAcc );
        Test.stopTest();
    }

    static testMethod void ChecklistVisitaCriaTest7B() {
        System.debug('&&&&&&&&&&&&&&& ChecklistVisitaCriaTest7B');
        Utils.setMigrationDoneTest(true);     
        
        Set< Id > setRecTypeLatCon = new Set< Id >();
        
        //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
        
        /*LAT_Contract__c lContrato = [ SELECT id, Account__c FROM LAT_Contract__c 
            WHERE Status__c = 'Em elaboração' AND Status_do_processo__c='Estudo em elaboração' 
            AND Account__r.Channel_Type__c ='Indireto' AND RecordTypeId =: setRecTypeLatCon limit 1];*/
        UDC__c regional = new UDC__c();      
        regional.CodDefUsuario__c = '1';      
        regional.CodProd__c     = '01';      
        regional.CodUs__c     = '01';      
        regional.Internal_Id__c   = '1234Jef';      
        regional.RecordTypeId = idRecTypeUdc;      
        insert regional;   
        regional.CodDefUsuario__c = '2'; 
        update regional;

        
        User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        //insert usuario;
        try{insert usuario;}catch(Exception e){}
        

            /*/Cria novo Account.
        Account acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account','On_Trade');
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Channel__c = 'Off Trade';
        //acc.Regional__c = regional.Id;
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Channel_Type__c = 'Indireto';
        acc.Client_code_AN8__c = '557799';
        acc.Price_Group__c = '1';
        //acc.Customer_Flag__c = bandeira.Id;
        insert acc;*/

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
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Channel__c = 'Off Trade';
        acc.Channel_Type__c = 'Indireto';
        acc.Price_Group__c = '1';
        acc.Client_code_AN8__c = '557799';
        //acc.Regional__c = regional.id;
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account','Off_Trade');
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        //insert acc;
        insert acc;

        LAT_Product__c produto = new LAT_Product__c();
        produto.Name = 'Cloud2b'; 
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '444';
        //produto.QT_lead_time__c = 5;
        produto.LAT_SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
        //insert produto;
        insert produto;

        Produto_Concorrente__c lProdConcorrente = new Produto_Concorrente__c();
        lProdConcorrente.name = 'Red Label';
        lProdConcorrente.Classifica_o__c = 'Whisky';
        lProdConcorrente.Empresa_Fabricante__c = 'Johnnie Walker';
        lProdConcorrente.RecordTypeId = RecordTypeForTest.getRecType( 'Produto_Concorrente__c', 'BRA_Standard' );
        //insert lProdConcorrente;
        insert lProdConcorrente;




        Test.startTest();
        Utils.setMigrationDoneTest(true);   
  
        
        LAT_Contract__c contract = new LAT_Contract__c();
        contract.OwnerId = usuario.Id;
        contract.Account__c = acc.Id;
        contract.Status__c = 'Em elaboração';
        contract.StartDate__c = System.today();
        contract.ContractTerm__c = 12;
        contract.Status_do_processo__c='Estudo em elaboração'; 
        contract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Ativacao_de_contrato');
        contract.ROI_Comentarios_Negativo__c = 'teste';
        //insert contract;
        insert contract;

        Contrapartida_de_Contrato_visitas__c ccv2 = new Contrapartida_de_Contrato_visitas__c();
        ccv2.Nome_da_Contrapartida_do_Contrato__c = 'test2';
        ccv2.LAT_Contract__c = contract.Id;
        insert ccv2;

        Contrapartida_de_Contrato_visitas__c ccv = new Contrapartida_de_Contrato_visitas__c();
        ccv.Nome_da_Contrapartida_do_Contrato__c = 'test';
        ccv.LAT_Contract__c = contract.Id;
        insert ccv;
        
        Agrupamento_Fiscal_Year__c agr = new Agrupamento_Fiscal_Year__c();
        agr.Ano_Fiscal__c = String.valueOf( System.today().year() );
        agr.LAT_Contract__c = contract.Id;
        //insert agr;
        insert agr;
        Par_metro_Produto_Concorr_ncia__c param = new Par_metro_Produto_Concorr_ncia__c();
        param.Canal__c = 'Off Trade';
        param.Regional__c = regional.Id;
        param.LAT_Product__c = produto.Id;
        param.Produto_Concorrencia__c = lProdConcorrente.id;
        param.sub__c = 'Distribuidor';
        param.RecordTypeId = RecordTypeForTest.getRecType( 'Par_metro_Produto_Concorr_ncia__c', 'Sellout' );
        
        insert param;     

        Planejamento__c lPlan = new Planejamento__c();
        lPlan.Ano_de_Referencia__c = '2012';
        lPlan.M_s_de_Ref_rencia__c = 'Dezembro';
        lPlan.Name = 'Teste';
        lPlan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard');
        //insert lPlan;
        insert lPlan;
        
        Visitas__c lVisita = new Visitas__c();
        lVisita.Conta__c = contract.Account__c;
        lVisita.Name = 'Planejamento de visitas'; 
        lVisita.Planejamento__c = lPlan.id;
        lVisita.Hora_da_Visita__c = '18:00';
        lVisita.Data_da_Visita__c = Date.today();
        lVisita.Resumo_da_Visita__c = 'resumo';
        lVisita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
        //insert lVisita;
        insert lVisita;


        


        Checklist_de_visita__c lCheck = new Checklist_de_visita__c();
        lCheck.Visita__c = lVisita.id;
        lCheck.recordTypeId = RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'On_Trade' );
        //insert lCheck;
        insert lCheck;
        
        List< String > lListCheck = new List< String >();
        lListCheck.add( lCheck.id );

        System.debug('%%%%%%%%%%%%%%%%%%% lListCheck '+ lListCheck);
        List< String > lListAcc = new List< String >();
        lListAcc.add( contract.Account__c );
            
        new ChecklistVisitaCria( lListCheck, lListAcc );
        Test.stopTest();
    }

    static testMethod void ChecklistVisitaCriaTest8() {
        System.debug('&&&&&&&&&&&&&&& ChecklistVisitaCriaTest2');
        Utils.setMigrationDoneTest(false);     
        
        Set< Id > setRecTypeLatCon = new Set< Id >();
        
        //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
        
        /*LAT_Contract__c lContrato = [ SELECT id, Account__c FROM LAT_Contract__c 
            WHERE Status__c = 'Em elaboração' AND Status_do_processo__c='Estudo em elaboração' 
            AND Account__r.Channel_Type__c ='Indireto' AND RecordTypeId =: setRecTypeLatCon limit 1];*/
        
        UDC__c regional = new UDC__c();      
        regional.CodDefUsuario__c = '1';      
        regional.CodProd__c     = '01';      
        regional.CodUs__c     = '01';      
        regional.Internal_Id__c   = '1234Jef';      
        regional.RecordTypeId = idRecTypeUdc;      
        insert regional;   
        regional.CodDefUsuario__c = '2'; 
        update regional;
        

        User usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        //insert usuario;
        try{insert usuario;}catch(Exception e){}
        

            /*/Cria novo Account.
        Account acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'On_Trade');
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Channel__c = 'Off Trade';
        //acc.Regional__c = regional.Id;
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Channel_Type__c = 'Indireto';
        acc.Client_code_AN8__c = '557799';
        acc.Price_Group__c = '1';
        //acc.Customer_Flag__c = bandeira.Id;
        insert acc;*/

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
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Channel__c = 'Off Trade';
        acc.Channel_Type__c = 'Direto';
        acc.Price_Group__c = '1';
        acc.Client_code_AN8__c = '557799';
        //acc.Regional__c = regional.id;
        acc.RecordTypeId = RecordTypeForTest.getRecType('Account','Off_Trade');
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        //insert acc;
        insert acc;




        Product2 produto = new Product2();
        produto.Name = 'Cloud2b'; 
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        produto.Internal_id__c = '444';
        //produto.QT_lead_time__c = 5;
        produto.SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
        //insert produto;
        insert produto;

        Produto_Concorrente__c lProdConcorrente = new Produto_Concorrente__c();
        lProdConcorrente.name = 'Red Label';
        lProdConcorrente.Classifica_o__c = 'Whisky';
        lProdConcorrente.Empresa_Fabricante__c = 'Johnnie Walker';
        lProdConcorrente.RecordTypeId = RecordTypeForTest.getRecType( 'Produto_Concorrente__c', 'BRA_Standard' );
        //insert lProdConcorrente;
        insert lProdConcorrente;



        LAT_Contract__c contract = new LAT_Contract__c();
        contract.OwnerId = usuario.Id;
        contract.Account__c = acc.Id;
        contract.Status__c = 'Ativo';
        contract.StartDate__c = System.today();
        contract.Volume_absolut_100__c = 2;
        contract.ContractTerm__c = 12;
        //contract.Status_do_processo__c='Estudo em elaboração'; 
        contract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Ativacao_de_contrato');
        contract.ROI_Comentarios_Negativo__c = 'teste';
        //insert contract;
        insert contract;

       

        Test.startTest();
        Utils.setMigrationDoneTest(false);     


        LAT_Contract__c contract2 = new LAT_Contract__c();
        contract2.OwnerId = usuario.Id;
        contract2.Volume_absolut_100__c = 1;
        contract2.Account__c = acc.Id;
        contract2.Status__c = 'Em elaboração';
        contract2.StartDate__c = System.today();
        contract2.ContractTerm__c = 12;
        contract2.Status_do_processo__c='Estudo em elaboração'; 
        contract2.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Alteracao_de_contrato_on');
        contract2.ROI_Comentarios_Negativo__c = 'teste2';
        //insert contract;
        insert contract2;
        
        Agrupamento_Fiscal_Year__c agr = new Agrupamento_Fiscal_Year__c();
        agr.Ano_Fiscal__c = String.valueOf( System.today().year() );
        agr.LAT_Contract__c = contract.Id;
        //insert agr;
        insert agr;


        Planejamento__c lPlan = new Planejamento__c();
        lPlan.Ano_de_Referencia__c = '2012';
        lPlan.M_s_de_Ref_rencia__c = 'Dezembro';
        lPlan.Name = 'Teste';
        lPlan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard');
        //insert lPlan;
        insert lPlan;

        Par_metro_Produto_Concorr_ncia__c param = new Par_metro_Produto_Concorr_ncia__c();
        param.Canal__c = 'Off Trade';
        param.Regional__c = regional.Id;
        param.Produto_Pernod__c = produto.Id;
        param.Produto_Concorrencia__c = lProdConcorrente.id;
        param.sub__c = 'Distribuidor';
        param.RecordTypeId = RecordTypeForTest.getRecType( 'Par_metro_Produto_Concorr_ncia__c', 'Sellout' );
        
        insert param;

 
        
        Visitas__c lVisita = new Visitas__c();
        lVisita.Conta__c = contract.Account__c;
        lVisita.Name = 'Planejamento de visitas'; 
        lVisita.Planejamento__c = lPlan.id;
        lVisita.Data_da_Visita__c = Date.today();
        lVisita.Hora_da_Visita__c = '08:00';
        lVisita.Resumo_da_Visita__c = 'resumo';
        lVisita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
        //insert lVisita;
        insert lVisita;
        
        Checklist_de_visita__c lCheck = new Checklist_de_visita__c();
        lCheck.Visita__c = lVisita.id;
        lCheck.recordTypeId = RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'On_Trade' );
        //insert lCheck;
        insert lCheck;
        
        List< String > lListCheck = new List< String >();
        lListCheck.add( lCheck.id );
        
        List< String > lListAcc = new List< String >();
        lListAcc.add( contract.Account__c );
            
        new ChecklistVisitaCria( lListCheck, lListAcc );
        Test.stopTest();
        
    }
}