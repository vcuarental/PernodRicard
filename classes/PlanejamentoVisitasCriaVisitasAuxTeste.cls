@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Responsável pelo teste de cobertura do seguinte código: 
* PlanejamentoVisitasCriaVisitasAux.cls
*
* NAME: PlanejamentoVisitasCriaVisitasAuxTeste.cls
* AUTHOR: ROGÉRIO ALVARENGA                         DATE: 
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
private class PlanejamentoVisitasCriaVisitasAuxTeste {

    static testMethod void PlanejamentoVisitasCriaVisitasAuxTeste() 
    {
      
        //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
        Set< Id > setRecTypeLatCon = new Set< Id >();
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
        Id idRecTypeAcc = RecordTypeForTest.getRecType( 'Account', 'Off_Trade' );
        
        UDC__c regional = new UDC__c( 
            CodDefUsuario__c = '2',
            CodProd__c     = '01',
            CodUs__c     = '01',
            Internal_Id__c   = '01-01',
            RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' )
        );
        insert regional;
        
        UDC__c customerOrg = new UDC__c( 
            CodDefUsuario__c = '2',
            CodProd__c     = '01',
            CodUs__c     = '10',
            Internal_Id__c   = '548271',
            RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' )
        );
        insert customerOrg;
        
        Account lConta = new Account( 
            Name = 'Conta teste Trigger',
            CNPJ__c = '48843971000120',
            Type = 'Outros',
            Status__c = 'Cliente cadastrado no JDE',
            Agency__c = '000',
            Checking_account__c = '000',
            Current_account__c = '0',
            Corporate_Name__c = 'Teste',
            Regional__c = regional.Id,
            Customer_Organization__c = customerOrg.Id,
            RecordTypeId = idRecTypeAcc,
            Segmentation_Type_on_trade__c = 'Bar',
            Channel__c = 'Off Trade',
            Channel_Type__c = 'Indireto',
            Rating = 'Cliente'
        );
        insert lConta;
        
        LAT_Contract__c lContrato = new LAT_Contract__c( 
            Account__c = lConta.Id,
            Status__c = 'Ativo',
            Status_do_processo__c='Estudo em elaboração',
            StartDate__c = System.today(),
            ContractTerm__c = 12,
            RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'),
            ROI_Comentarios_Negativo__c = 'teste'
        );
        insert lContrato;
      
      Par_metro_Produto_Concorr_ncia__c lProdConc = new Par_metro_Produto_Concorr_ncia__c();
      lProdConc.RecordTypeId = ChecklistVisitaCria.REC_TYPE_PARAM_PROD_CONCORRENCIA;
      lProdConc.Canal__c = 'Off Trade';
      insert lProdConc;
      
      Integer mes = PlanejamentoVisitasCriaVisitasAux.getMonth( 'Junho' );
      Integer ano = 2012;
      Integer aBusinessDay  = 0;
      Integer numVisita   = 0;
      String aPeriodicidade = null;
      
      PlanejamentoVisitasCriaVisitasAux plan = new PlanejamentoVisitasCriaVisitasAux();
      
      //Testa método de periodicidade.
      PlanejamentoVisitasCriaVisitasAux.getPeriodicity('', 0, 0);
      
      aPeriodicidade = 'Diária';
      try
      {
        numVisita = PlanejamentoVisitasCriaVisitasAux.getPeriodicity(aPeriodicidade,ano , mes);
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
      PlanejamentoVisitasCriaVisitasAux.getParamProdConcorrencia();
      
      if( lConta.Client_code_AN8__c == null ) lConta.Client_code_AN8__c = '22468'; 
        
      Map<String, List<String>> mapIdAccount = new Map<String, List<String>>();
      
      PlanejamentoVisitasCriaVisitasAux.getParamProdContrato( new List< Id >{ lConta.Id }, mapIdAccount );
      
      Map< String, CustomerRSPProfiles__c > lAN8Map = new Map< String, CustomerRSPProfiles__c >();
      Map< String, CustomerRSPProfiles__c > lOrgBandMap = new Map< String, CustomerRSPProfiles__c >();
      Map< String, CustomerRSPProfiles__c > lCanalUFAN8Map = new Map< String, CustomerRSPProfiles__c >();
      PlanejamentoVisitasCriaVisitasAux.getRSPProfile( lAN8Map, lOrgBandMap, lCanalUFAN8Map );
      
      List< String > lAllContracts = new List< String >();
      List< decimal > lProfilesID = new List< Decimal >();
        
        CustomerRSPProfiles__c lProfile = null;
        if ( lConta.Client_code_AN8__c != null )
            lProfile = lAN8Map.get( lConta.Client_code_AN8__c );
        else
            if ( lConta.Customer_Organization__r.CodDefUsuario__c != null 
                && lConta.Customer_Flag__r.CodDefUsuario__c != null )
            lProfile = lOrgBandMap.get( lConta.Customer_Organization__r.CodDefUsuario__c 
                                       + '|' + lConta.Customer_Flag__r.CodDefUsuario__c );
        else
            if ( lConta.Sub_Channel_Rating__r.CodDefUsuario__c != null
                && lConta.Revenue_UF__c != null )
            lProfile = lCanalUFAN8Map.get( lConta.Sub_Channel_Rating__r.CodDefUsuario__c 
                                          + '|' + lConta.Revenue_UF__c );
        
        if ( lProfile != null  ) lProfilesID.add( lProfile.profile_id__c );
        
        List< String > lContracts = mapIdAccount.get( lConta.id );
        if ( lContracts != null ) lAllContracts.addAll( lContracts );
      if ( lProfilesID.size() > 0 ) PlanejamentoVisitasCriaVisitasAux.getCustomerRSPProdMap( lProfilesID[ 0 ] );
      PlanejamentoVisitasCriaVisitasAux.getContrapartidaContratoVisita( lAllContracts );
    }
    
    private static void customerRSP( Account aAcc )
    {
      CustomerRSPProfiles__c lProf = new CustomerRSPProfiles__c();
      lProf.profile_id__c= 324;
      lProf.AN8__c= aAcc.Client_code_AN8__c;
      lProf.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProfiles__c', 'BRA_Standard' );
      insert lProf;
      
      CustomerRSPProducts__c lProd = new CustomerRSPProducts__c();
      lProd.Profile2_Id__c = lProf.profile_id__c;
      lProd.price_rsp_min__c = 1; 
      lProd.price_rsp_max__c = 5;
      lProd.Internal_id_pk__c = 'r'+aAcc.id;
      lProd.sku__c = 1406;
      lProd.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProducts__c', 'BRA_Standard' );
      insert lProd;
    }
}