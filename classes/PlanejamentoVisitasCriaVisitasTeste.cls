/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que realiza teste de cobertura da trigger PlanejamentoVisitasCriaVisitas
* NAME: PlanejamentoVisitasCriaVisitasTeste.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 04/05/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR: MARCOS DOBROWOLSKI                        DATE: 26/12/2012
*
* AUTHOR: CARLOS CARVALHO                           DATE: 16/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@isTest(seeAllData=true)
private class PlanejamentoVisitasCriaVisitasTeste 
{
  static testMethod void PlanejamentoVisitasCriaVisitasTeste() {
        Utils.setMigrationDoneTest(false); 
      
        //Declaração de variáveis.
        Account acc, acc2, acc3         = null;
        User usuario              = null;
        Planejamento__c plan,plan2,plan3,plan4,plan5,plan6,plan7,plan8,plan9,plan10,plan11,plan12 = null;
        Profile perfil              = null;
        UDC__c regional, org, bandeira,classSub = null;
        String idAccount            = null;
        Par_metro_Produto_Concorr_ncia__c param = null;
        Product2 produto            = null;
        CustomerRSPProducts__c customProd,customProd2,customProd3   = null;
        CustomerRSPProfiles__c customProfile,customProfile2,customProfile3  = null;
        Visitas__c visita           = null;
        Holiday feriado = null; 
        String aMes       = '05';
        Integer ano       = 2012;
        Integer mes       = PlanejamentoVisitasCriaVisitasAux.getMonth(aMes);
        Integer aBusinessDay  = 0;
        Integer numVisita   = 0;
        String aPeriodicidade = null;
        String aParam     = null;
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        
        //Atribui à variável o id da conta.
        idAccount = RecordTypeForTest.getRecType('Account', 'Off_Trade');
        
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '5';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '01-01';
        regional.RecordTypeId = idRecTypeUDC;
     //   insert regional;
        try{insert regional;}catch(Exception e){}
        
        //Cria novo usuario.
        usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
       // insert usuario;
        try{insert usuario;}catch(Exception e){}
        
    
        //Cria nova UDC.
        org = new UDC__c();
        org.CodDefUsuario__c  = '171';
        org.CodProd__c      = '01';
        org.CodUs__c      = '10';
        org.Internal_Id__c    = '1235';
        org.RecordTypeId = idRecTypeUDC;
       //insert org;
        try{insert org;}catch(Exception e){}
        
        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c     = '01';
        bandeira.CodUs__c     = '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        //insert bandeira;
        try{    insert bandeira;}catch(Exception e){}
        
        //Cria nova UDC.
        classSub = new UDC__c();
        classSub.CodDefUsuario__c = '1889';
        classSub.CodProd__c     = '01';
        classSub.CodUs__c     = '03';
        classSub.Internal_Id__c   = '1237';
        classSub.RecordTypeId = idRecTypeUDC;
       // insert classSub;
        try{ insert classSub;}catch(Exception e){}
    
       // Cria uma UDC_Tabela
       UDC__c UdcTest = new UDC__c();
       UdcTest.CodUs__c = '03';
       UdcTest.CodProd__c = '01';
       UdcTest.Name = 'KA';
       UdcTest.Internal_Id__c = '1238';
       UdcTest.RecordTypeId = idRecTypeUDC;
      // insert UdcTest;
       try{ insert UdcTest;}catch(Exception e){}
    
        //Cria novo Account.
        //acc = [ select id from Account where Channel__c = 'Off Trade' limit 1];
        acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'Conta PlanejamentoVisitasCriaVisitasTeste';
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
        acc.Client_code_AN8__c = '557798';
        acc.Channel_Type__c = 'Direto';
        acc.Sub_Channel_Rating__c = UdcTest.Id;
        //acc.Revenue_City__c = lCidade.id;
       // insert acc;
        try{insert acc;}catch(Exception e){}
        
        Produto_Concorrente__c lProdConcorrente = new Produto_Concorrente__c();
        lProdConcorrente.name = 'Red Label';
        lProdConcorrente.Classifica_o__c = 'Whisky';
        lProdConcorrente.Empresa_Fabricante__c = 'Johnnie Walker';
        lProdConcorrente.RecordTypeId = RecordTypeForTest.getRecType( 'Produto_Concorrente__c', 'BRA_Standard' );
        //insert lProdConcorrente;
        try{insert lProdConcorrente;}catch(Exception e){}
    
        //Recupera um produto no ambiente.
        //produto = [Select Id, Sku__c From Product2 limit 1];
        produto = new Product2();
        produto.Name = 'Cloud2b'; 
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        produto.Internal_id__c = '444';
        //produto.QT_lead_time__c = 5;
        produto.SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
        //insert produto;
        try{insert produto;}catch(Exception e){}
  
        //Cria novo parametro de produto concorrencia.
        param = new Par_metro_Produto_Concorr_ncia__c();
        param.Canal__c = 'Off Trade';
        param.Regional__c = regional.Id;
        param.Produto_Pernod__c = produto.Id;
        param.Produto_Concorrencia__c = lProdConcorrente.id;
        param.RecordTypeId = RecordTypeForTest.getRecType( 'Par_metro_Produto_Concorr_ncia__c', 'Produtos_Concorr_ncia' );
        
        //insert param;
        try{insert param;}catch(Exception e){}
        
        //Cria novo customRSPProfile.
        customProfile = new CustomerRSPProfiles__c();
        customProfile.AN8__c = '12345';
        customProfile.profile_id__c = 123456;
        customProfile.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProfiles__c', 'BRA_Standard' );
        //insert customProfile;
        try{insert customProfile;}catch(Exception e){}
        
        //Cria novo customRSPProfile.
        customProfile2 = new CustomerRSPProfiles__c();
        customProfile2.codigo_bandeira__c = '179';
        customProfile2.codigo_organizacao__c = '171';
        customProfile2.profile_id__c = 123457;
        customProfile2.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProfiles__c', 'BRA_Standard' );
        //insert customProfile2;
        try{insert customProfile2;}catch(Exception e){}
        
        //Cria novo customRSPProfile.
        customProfile3 = new CustomerRSPProfiles__c();
        customProfile3.canal__c = '189';
        customProfile3.uf_an8__c = 'SP';
        customProfile3.profile_id__c = 127756;
        customProfile3.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProfiles__c', 'BRA_Standard' );
        //insert customProfile3;
        try{insert customProfile3;}catch(Exception e){}
        
        //Cria novo custom RSP Product.
        customProd = new CustomerRSPProducts__c();
        customProd.Profile2_Id__c = 123456;
        customProd.sku__c = Decimal.valueOf(produto.SKU__c);
        customProd.price_rsp_max__c = 250;
        customProd.price_rsp_min__c = 200;
        customProd.Internal_id_pk__c = '1234567890';
        customProd.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProducts__c', 'BRA_Standard' );
       // insert customProd;
        try{ insert customProd;}catch(Exception e){}
        
        //Cria novo custom RSP Product.
        customProd2 = new CustomerRSPProducts__c();
        customProd2.Profile2_Id__c = customProfile2.profile_id__c;
        customProd2.sku__c = Decimal.valueOf(produto.SKU__c);
        customProd2.price_rsp_max__c = 250;
        customProd2.price_rsp_min__c = 200;
        customProd2.Internal_id_pk__c = '1234560';
        customProd2.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProducts__c', 'BRA_Standard' );
        //insert customProd2;
        try{insert customProd2;}catch(Exception e){}
        
        //Cria novo custom RSP Product.
        customProd3 = new CustomerRSPProducts__c();
        customProd3.Profile2_Id__c = customProfile3.profile_id__c;
        customProd3.sku__c = Decimal.valueOf(produto.SKU__c);
        customProd3.price_rsp_max__c = 250;
        customProd3.price_rsp_min__c = 200;
        customProd3.Internal_id_pk__c = '1277760';
        customProd3.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProducts__c', 'BRA_Standard' );
       // insert customProd3;
        try{ insert customProd3;}catch(Exception e){}
        
        plan = new Planejamento__c();
        plan.Ano_de_Referencia__c = '2012';
        plan.M_s_de_Ref_rencia__c = 'Janeiro';
        plan.Name = 'Teste';
        plan.OwnerId = usuario.Id;
        plan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
        //insert plan;
      // try{insert plan;}catch(Exception e){}
        
        plan2 = new Planejamento__c();
        plan2.Ano_de_Referencia__c = '2012';
        plan2.M_s_de_Ref_rencia__c = 'Fevereiro';
        plan2.Name = 'Teste';
        plan2.OwnerId = usuario.Id;
        plan2.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
       // insert plan2;
        //try{insert plan2;}catch(Exception e){}
        
        visita = new Visitas__c();
        visita.Name = 'Teste';
        visita.Data_da_Visita__c = System.today();
        visita.Hora_da_Visita__c = '08:00';
        visita.Planejamento__c = plan2.Id;
        visita.Tipo_de_Visita__c = 'Execução';
        visita.Conta__c = acc.Id;
        visita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
        visita.Resumo_da_Visita__c = 'teste';
        //insert visita;
      //  try{insert visita;}catch(Exception e){}
        
        //Atualiza planejamento.
        plan2.Aprovado_semana_1__c = true;
        try
        {
          update plan2;
        }
        catch(DMLException e)
        {
          System.debug(e.getMessage());
        }
            
        plan3 = new Planejamento__c();
        plan3.Ano_de_Referencia__c = '2012';
        plan3.M_s_de_Ref_rencia__c = 'Março';
        plan3.Name = 'Teste';
        plan3.OwnerId = usuario.Id;
        plan3.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard');
        
       // insert plan3;
       // try{  insert plan3;}catch(Exception e){}
            
        plan4 = new Planejamento__c();
        plan4.Ano_de_Referencia__c = '2012';
        plan4.M_s_de_Ref_rencia__c = 'Abril';
        plan4.Name = 'Teste';
        plan4.OwnerId = usuario.Id;
        plan4.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard');
        //insert plan4;
      //  try{ insert plan4;}catch(Exception e){}
        
        
        PlanejamentoVisitasCriaVisitasAux planVisita = new PlanejamentoVisitasCriaVisitasAux();
        
        //Testa método de periodicidade.
        aPeriodicidade = 'Diária';
        try
        {
          numVisita = PlanejamentoVisitasCriaVisitasAux.getPeriodicity(aPeriodicidade, ano, mes);
        }
        catch(Exception e)
        {
          System.debug(e.getMessage());
        }
        
        //Testa método de periodicidade.
        aPeriodicidade = '2 x Semana';
        try{
          numVisita = PlanejamentoVisitasCriaVisitasAux.getPeriodicity(aPeriodicidade, ano, mes);
        }
        catch(Exception e)
        {
          System.debug(e.getMessage());
        }
        //Testa método de periodicidade.
        aPeriodicidade = 'Semanal';
        try
        {
          numVisita = PlanejamentoVisitasCriaVisitasAux.getPeriodicity(aPeriodicidade, ano, mes);
        }
        catch(Exception e)
        {
          System.debug(e.getMessage());
        }
        //Testa método de periodicidade.
        aPeriodicidade = 'Quinzenal';
        try
        {
          numVisita = PlanejamentoVisitasCriaVisitasAux.getPeriodicity(aPeriodicidade, ano, mes);
        }
        catch(Exception e)
        {
          System.debug(e.getMessage());
        }
        //Testa método de periodicidade.
        aPeriodicidade = 'Mensal';
        try
        {
          numVisita = PlanejamentoVisitasCriaVisitasAux.getPeriodicity(aPeriodicidade, ano, mes);
        }
        catch(Exception e)
        {
          System.debug(e.getMessage());
        }
        Checklist_de_visita__c check = new Checklist_de_visita__c();
        check.Visita__c =visita.Id;
        check.RecordTypeId = RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'Off_Trade');
        //insert check;
        try{insert check;}catch(Exception e){}
        
        List<Checklist_de_visita__c> listcheckList = new List<Checklist_de_visita__c>();
        List<String> listIdCheck = new List<String>();
        listIdCheck.add(check.Id);
        
        listcheckList = ChecklistVisitaDAO.getInstance().getListChecklistInfoAccount(listIdCheck);
        
        Produto_Concorr_ncia__c prodConc = new Produto_Concorr_ncia__c();
        prodConc.Produto_PERNOD__c =   param.Produto_Pernod__c;
        prodConc.Produto_Concorrente__c = param.Produto_Concorrencia__c;
        prodConc.Checklist_de_visita__c =check.Id;
        prodConc.RecordTypeId = RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'BRA_Standard' );
    }
    
    //MIGRATED 21/11/2016
    static testMethod void PlanejamentoVisitasCriaVisitasTesteB() {
        Utils.setMigrationDoneTest(true); 
      
        //Declaração de variáveis.
        Account acc, acc2, acc3         = null;
        User usuario              = null;
        Planejamento__c plan,plan2,plan3,plan4,plan5,plan6,plan7,plan8,plan9,plan10,plan11,plan12 = null;
        Profile perfil              = null;
        UDC__c regional, org, bandeira,classSub = null;
        String idAccount            = null;
        Par_metro_Produto_Concorr_ncia__c param = null;
        LAT_Product__c produto            = null;
        CustomerRSPProducts__c customProd,customProd2,customProd3   = null;
        CustomerRSPProfiles__c customProfile,customProfile2,customProfile3  = null;
        Visitas__c visita           = null;
        Holiday feriado = null; 
        String aMes       = '05';
        Integer ano       = 2012;
        Integer mes       = PlanejamentoVisitasCriaVisitasAux.getMonth(aMes);
        Integer aBusinessDay  = 0;
        Integer numVisita   = 0;
        String aPeriodicidade = null;
        String aParam     = null;
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        
        //Atribui à variável o id da conta.
        idAccount = RecordTypeForTest.getRecType('Account', 'Off_Trade');
        
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '5';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '01-01';
        regional.RecordTypeId = idRecTypeUDC;
     //   insert regional;
        try{insert regional;}catch(Exception e){}
        
        //Cria novo usuario.
        usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
       // insert usuario;
        try{insert usuario;}catch(Exception e){}
        
    
        //Cria nova UDC.
        org = new UDC__c();
        org.CodDefUsuario__c  = '171';
        org.CodProd__c      = '01';
        org.CodUs__c      = '10';
        org.Internal_Id__c    = '1235';
        org.RecordTypeId = idRecTypeUDC;
       //insert org;
        try{insert org;}catch(Exception e){}
        
        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c     = '01';
        bandeira.CodUs__c     = '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        //insert bandeira;
        try{    insert bandeira;}catch(Exception e){}
        
        //Cria nova UDC.
        classSub = new UDC__c();
        classSub.CodDefUsuario__c = '1889';
        classSub.CodProd__c     = '01';
        classSub.CodUs__c     = '03';
        classSub.Internal_Id__c   = '1237';
        classSub.RecordTypeId = idRecTypeUDC;
       // insert classSub;
        try{ insert classSub;}catch(Exception e){}
    
       // Cria uma UDC_Tabela
       UDC__c UdcTest = new UDC__c();
       UdcTest.CodUs__c = '03';
       UdcTest.CodProd__c = '01';
       UdcTest.Name = 'KA';
       UdcTest.Internal_Id__c = '1238';
       UdcTest.RecordTypeId = idRecTypeUDC;
      // insert UdcTest;
       try{ insert UdcTest;}catch(Exception e){}
    
        //Cria novo Account.
        //acc = [ select id from Account where Channel__c = 'Off Trade' limit 1];
        acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'Conta PlanejamentoVisitasCriaVisitasTeste';
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
        acc.Client_code_AN8__c = '557798';
        acc.Channel_Type__c = 'Direto';
        acc.Sub_Channel_Rating__c = UdcTest.Id;
        //acc.Revenue_City__c = lCidade.id;
       // insert acc;
        try{insert acc;}catch(Exception e){}
        
        Produto_Concorrente__c lProdConcorrente = new Produto_Concorrente__c();
        lProdConcorrente.name = 'Red Label';
        lProdConcorrente.Classifica_o__c = 'Whisky';
        lProdConcorrente.Empresa_Fabricante__c = 'Johnnie Walker';
        lProdConcorrente.RecordTypeId = RecordTypeForTest.getRecType( 'Produto_Concorrente__c', 'BRA_Standard' );
        //insert lProdConcorrente;
        try{insert lProdConcorrente;}catch(Exception e){}
    
        //Recupera um produto no ambiente.
        //produto = [Select Id, Sku__c From Product2 limit 1];
        produto = new LAT_Product__c();
        produto.Name = 'Cloud2b'; 
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalID__c = '444';
        //produto.QT_lead_time__c = 5;
        produto.LAT_SKU__c = '5666';
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
        //insert produto;
        try{insert produto;}catch(Exception e){}
  
        //Cria novo parametro de produto concorrencia.
        param = new Par_metro_Produto_Concorr_ncia__c();
        param.Canal__c = 'Off Trade';
        param.Regional__c = regional.Id;
        param.LAT_Product__c = produto.Id;
        param.Produto_Concorrencia__c = lProdConcorrente.id;
        param.RecordTypeId = RecordTypeForTest.getRecType( 'Par_metro_Produto_Concorr_ncia__c', 'Produtos_Concorr_ncia' );
        
        //insert param;
        try{insert param;}catch(Exception e){}
        
        //Cria novo customRSPProfile.
        customProfile = new CustomerRSPProfiles__c();
        customProfile.AN8__c = '12345';
        customProfile.profile_id__c = 123456;
        customProfile.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProfiles__c', 'BRA_Standard' );
        //insert customProfile;
        try{insert customProfile;}catch(Exception e){}
        
        //Cria novo customRSPProfile.
        customProfile2 = new CustomerRSPProfiles__c();
        customProfile2.codigo_bandeira__c = '179';
        customProfile2.codigo_organizacao__c = '171';
        customProfile2.profile_id__c = 123457;
        customProfile2.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProfiles__c', 'BRA_Standard' );
        //insert customProfile2;
        try{insert customProfile2;}catch(Exception e){}
        
        //Cria novo customRSPProfile.
        customProfile3 = new CustomerRSPProfiles__c();
        customProfile3.canal__c = '189';
        customProfile3.uf_an8__c = 'SP';
        customProfile3.profile_id__c = 127756;
        customProfile3.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProfiles__c', 'BRA_Standard' );
        //insert customProfile3;
        try{insert customProfile3;}catch(Exception e){}
        
        //Cria novo custom RSP Product.
        customProd = new CustomerRSPProducts__c();
        customProd.Profile2_Id__c = 123456;
        customProd.sku__c = Decimal.valueOf(produto.LAT_SKU__c);
        customProd.price_rsp_max__c = 250;
        customProd.price_rsp_min__c = 200;
        customProd.Internal_id_pk__c = '1234567890';
        customProd.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProducts__c', 'BRA_Standard' );
       // insert customProd;
        try{ insert customProd;}catch(Exception e){}
        
        //Cria novo custom RSP Product.
        customProd2 = new CustomerRSPProducts__c();
        customProd2.Profile2_Id__c = customProfile2.profile_id__c;
        customProd2.sku__c = Decimal.valueOf(produto.LAT_SKU__c);
        customProd2.price_rsp_max__c = 250;
        customProd2.price_rsp_min__c = 200;
        customProd2.Internal_id_pk__c = '1234560';
        customProd2.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProducts__c', 'BRA_Standard' );
        //insert customProd2;
        try{insert customProd2;}catch(Exception e){}
        
        //Cria novo custom RSP Product.
        customProd3 = new CustomerRSPProducts__c();
        customProd3.Profile2_Id__c = customProfile3.profile_id__c;
        customProd3.sku__c = Decimal.valueOf(produto.LAT_SKU__c);
        customProd3.price_rsp_max__c = 250;
        customProd3.price_rsp_min__c = 200;
        customProd3.Internal_id_pk__c = '1277760';
        customProd3.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProducts__c', 'BRA_Standard' );
       // insert customProd3;
        try{ insert customProd3;}catch(Exception e){}
        
        plan = new Planejamento__c();
        plan.Ano_de_Referencia__c = '2012';
        plan.M_s_de_Ref_rencia__c = 'Janeiro';
        plan.Name = 'Teste';
        plan.OwnerId = usuario.Id;
        plan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
        //insert plan;
      // try{insert plan;}catch(Exception e){}
        
        plan2 = new Planejamento__c();
        plan2.Ano_de_Referencia__c = '2012';
        plan2.M_s_de_Ref_rencia__c = 'Fevereiro';
        plan2.Name = 'Teste';
        plan2.OwnerId = usuario.Id;
        plan2.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
       // insert plan2;
        //try{insert plan2;}catch(Exception e){}
        
        visita = new Visitas__c();
        visita.Name = 'Teste';
        visita.Data_da_Visita__c = System.today();
        visita.Hora_da_Visita__c = '08:00';
        visita.Planejamento__c = plan2.Id;
        visita.Tipo_de_Visita__c = 'Execução';
        visita.Conta__c = acc.Id;
        visita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
        visita.Resumo_da_Visita__c = 'teste';
        //insert visita;
      //  try{insert visita;}catch(Exception e){}
        
        //Atualiza planejamento.
        plan2.Aprovado_semana_1__c = true;
        try
        {
          update plan2;
        }
        catch(DMLException e)
        {
          System.debug(e.getMessage());
        }
            
        plan3 = new Planejamento__c();
        plan3.Ano_de_Referencia__c = '2012';
        plan3.M_s_de_Ref_rencia__c = 'Março';
        plan3.Name = 'Teste';
        plan3.OwnerId = usuario.Id;
        plan3.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard');
        
       // insert plan3;
       // try{  insert plan3;}catch(Exception e){}
            
        plan4 = new Planejamento__c();
        plan4.Ano_de_Referencia__c = '2012';
        plan4.M_s_de_Ref_rencia__c = 'Abril';
        plan4.Name = 'Teste';
        plan4.OwnerId = usuario.Id;
        plan4.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard');
        //insert plan4;
      //  try{ insert plan4;}catch(Exception e){}
        
        
        PlanejamentoVisitasCriaVisitasAux planVisita = new PlanejamentoVisitasCriaVisitasAux();
        
        //Testa método de periodicidade.
        aPeriodicidade = 'Diária';
        try
        {
          numVisita = PlanejamentoVisitasCriaVisitasAux.getPeriodicity(aPeriodicidade, ano, mes);
        }
        catch(Exception e)
        {
          System.debug(e.getMessage());
        }
        
        //Testa método de periodicidade.
        aPeriodicidade = '2 x Semana';
        try{
          numVisita = PlanejamentoVisitasCriaVisitasAux.getPeriodicity(aPeriodicidade, ano, mes);
        }
        catch(Exception e)
        {
          System.debug(e.getMessage());
        }
        //Testa método de periodicidade.
        aPeriodicidade = 'Semanal';
        try
        {
          numVisita = PlanejamentoVisitasCriaVisitasAux.getPeriodicity(aPeriodicidade, ano, mes);
        }
        catch(Exception e)
        {
          System.debug(e.getMessage());
        }
        //Testa método de periodicidade.
        aPeriodicidade = 'Quinzenal';
        try
        {
          numVisita = PlanejamentoVisitasCriaVisitasAux.getPeriodicity(aPeriodicidade, ano, mes);
        }
        catch(Exception e)
        {
          System.debug(e.getMessage());
        }
        //Testa método de periodicidade.
        aPeriodicidade = 'Mensal';
        try
        {
          numVisita = PlanejamentoVisitasCriaVisitasAux.getPeriodicity(aPeriodicidade, ano, mes);
        }
        catch(Exception e)
        {
          System.debug(e.getMessage());
        }
        Checklist_de_visita__c check = new Checklist_de_visita__c();
        check.Visita__c =visita.Id;
        check.RecordTypeId = RecordTypeForTest.getRecType( 'Checklist_de_visita__c', 'Off_Trade');
        //insert check;
        try{insert check;}catch(Exception e){}
        
        List<Checklist_de_visita__c> listcheckList = new List<Checklist_de_visita__c>();
        List<String> listIdCheck = new List<String>();
        listIdCheck.add(check.Id);
        
        listcheckList = ChecklistVisitaDAO.getInstance().getListChecklistInfoAccount(listIdCheck);
        
        Produto_Concorr_ncia__c prodConc = new Produto_Concorr_ncia__c();
        prodConc.LAT_Product__c =   param.LAT_Product__c;
        prodConc.Produto_Concorrente__c = param.Produto_Concorrencia__c;
        prodConc.Checklist_de_visita__c =check.Id;
        prodConc.RecordTypeId = RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'BRA_Standard' );
    }
}