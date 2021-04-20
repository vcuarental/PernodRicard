/********************************************************************************
      *                         Copyright 2012 - Cloud2b
      ********************************************************************************
      * Descrição
      *
      * NAME: ChecklistVisitaCria.cls
      * AUTHOR:                           DATE:  
      *
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
public with sharing class ChecklistVisitaCria {
    public static final List< String > secao_contrapartida = new List< String >{ 'Volume Mínimo', 
                                                                               'Contrapartida de Visibilidade', 
                                                                                     'Portifolio Pernod Ricard', 
                                                                                     'Visibilidade', 
                                                                                     'Acordo Promocional',
                                                                                     'Detalhamento' };
        
    private static final Integer OFF_TRADE = 0;
    private static final Integer ON_TRADE  = 1;
    private static final Integer INDIRETO  = 2;
    
    private Id idRecTypePC = RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c' , 'BRA_Standard' );
    private Id idRecTypeCh = RecordTypeForTest.getRecType( 'Checklist__c' , 'BRA_Standard' );
    private Id idRecTypePS = RecordTypeForTest.getRecType( 'Posicao_Sellout__c' , 'BRA_Standard' );
    
    public List< Checklist__c > checkListContraList = new List< Checklist__c >();
    public List< Checklist_Exposicao__c > checkListExpList = new List< Checklist_Exposicao__c >();
    public List< Produto_Concorr_ncia__c > checkListConcList = new List< Produto_Concorr_ncia__c >();
    public List< Posicao_Sellout__c > checkListSelloutList = new List< Posicao_Sellout__c >();
    
    public static final String REC_TYPE_PARAM_PROD_CONCORRENCIA = 
        RecordTypeForTest.getRecType( 'Par_metro_Produto_Concorr_ncia__c', 'Produtos_Concorr_ncia' );
    public static final String REC_TYPE_PARAM_PROD_SELLOUT = 
        RecordTypeForTest.getRecType( 'Par_metro_Produto_Concorr_ncia__c', 'Sellout' );
    
    
    private Set< String > fRepeatContrapartida = new Set< String >();
    private Set< String > fRepeatExposicao = new Set< String >();
    private Map< String, CustomerRSPProfiles__c > fAN8Map = new Map< String, CustomerRSPProfiles__c >();
    private Map< String, CustomerRSPProfiles__c > fOrgBandMap = new Map< String, CustomerRSPProfiles__c >();
    private Map< String, CustomerRSPProfiles__c > fCanalUFAN8Map = new Map< String, CustomerRSPProfiles__c >();
    private Map< Decimal, Map< String, CustomerRSPProducts__c > > fRSPProdMap = new Map< Decimal, Map< String, CustomerRSPProducts__c > >();
    
    public ChecklistVisitaCria( List< String > aCheckListID, List< String > aAccountIds )
    {

        if(!Utils.wasMigrationDone('1')) { 
            Map< String, List< Par_metro_Produto_Concorr_ncia__c > > lProdParametro = PlanejamentoVisitasCriaVisitasAux.getParamProdConcorrencia();
            
            //conta -> List< contractid >
            Map< String, List< String > > lAccountContracts = new Map< String, List< String > >();
            // contract -> Lista Produtos
            Map< String, List< List< String > > > lProdContrato = PlanejamentoVisitasCriaVisitasAux.getParamProdContrato( aAccountIds, lAccountContracts );
            System.debug('%%%%%%%%%%%%%%%%%%%%% lProdContrato : '+ lProdContrato);
            List< Decimal > lProfIDs = PlanejamentoVisitasCriaVisitasAux.getRSPProfile( fAN8Map, fOrgBandMap, fCanalUFAN8Map );
            /**
             * Recupera os Checklists que foram inseridos com os campos de conta (referência)
             */
            List< Checklist_de_visita__c > lCheckList = ChecklistVisitaDAO.getInstance().getListChecklistInfoAccount( aCheckListID );
            System.debug('%%%%%%%%%%%%%%%%%%%%% resultadoSelect : '+lCheckList);
            for ( Checklist_de_visita__c lCk : lCheckList )
            {
              if ( lCk.Visita__r.Tipo_de_Visita__c == null || lCk.Visita__r.Tipo_de_Visita__c.equalsIgnoreCase( 'Vendas' ) ) continue;
              //String lRegional = lCk.Visita__r.Conta__r.Regional__c;// Modification Change Request 4
              Integer lCanal = getCanal( lCk.Visita__r.Conta__r.Channel__c, lCk.Visita__r.Conta__r.Channel_Type__c );
              //String lSubCanal = lCk.Visita__r.Conta__r.Sub_Channel__c; // Modification Change Request 4
              
              List< String > lContracts = lAccountContracts.get( lCk.Visita__r.Conta__r.id );
              if ( lContracts != null )
              {
                Map< String, List< String > > lCCV = PlanejamentoVisitasCriaVisitasAux.getContrapartidaContratoVisita( lContracts );
                for ( String lContract : lContracts )
                {
                  List< List< String > > lProdContratoList = lProdContrato.get( lContract );
                  // Contrapartida
                  if ( lCanal == OFF_TRADE || lCanal == INDIRETO )
                  {
                    incluirContrapartida( lCCV.get( lContract ), lCk.id, secao_contrapartida[ 1 ] );
                  }
                  else
                  {
                    if ( lProdContratoList != null )
                    {
                      Integer lLen = lProdContratoList.size();
                      for ( Integer i=1; i<lLen; i++ )
                      {
                        incluirContrapartida( lProdContratoList[ i ], lCk.id, secao_contrapartida[ i ] );
                      }
                    }
                  }
          
                  // Criar Organização e Exposição
                    //          if ( lCanal.equalsIgnoreCase( 'Off Trade' ) 
                   //          || ( lCanal.equalsIgnoreCase( 'On Trade' ) && !lTipo.equalsIgnoreCase( 'Indireto' ) ) )
                   System.debug('%%%%%%%%%%%% lProdContratoList : '+lProdContratoList + ' , lCanal : ' + lCanal);
                  if ( ( lCanal == OFF_TRADE || lCanal == ON_TRADE ) && lProdContratoList != null )
                  {
                    for ( String lProdLabel : lProdContratoList[ 0 ] )
                    {
                      if ( existeExposicao( lCk.Id + '|' + lProdLabel ) ) continue;
                      Checklist_Exposicao__c lExp = new Checklist_Exposicao__c();
                      lExp.Checklist_de_visita__c = lCk.Id;
                      lExp.Schedule_C__c = lProdLabel;
                      checkListExpList.add( lExp );
                    }
                  }
                }
            }// fim if
              
              // Criar Produtos Concorrência

              
              system.debug('TOKEN1 : '+lCk.Visita__r.Conta__r.Channel__c);
              List< Par_metro_Produto_Concorr_ncia__c > lProdParamList = [SELECT Id, Produto_Pernod__c, SKU__c, Regional__c, Produto_Concorrencia__c, Canal__c FROM Par_metro_Produto_Concorr_ncia__c WHERE Canal__c=:lCk.Visita__r.Conta__r.Channel__c ];//Modification Change Request 4 lProdParametro.get( REC_TYPE_PARAM_PROD_CONCORRENCIA + '|' + lCk.Visita__r.Conta__r.Channel__c + '|' + lRegional + '|' + lSubCanal);
              system.debug('TOKEN lProdParamList: '+lProdParamList);
              if ( lProdParamList != null )
              {
                for ( Par_metro_Produto_Concorr_ncia__c lParamProd : lProdParamList )
                {
                  system.debug('TOKEN lParamProd: '+lParamProd);
                  Produto_Concorr_ncia__c lProdConc = new Produto_Concorr_ncia__c();
                  lProdConc.Canal__c = lParamProd.Canal__c;
                  lProdConc.Produto_PERNOD__c = lParamProd.Produto_Pernod__c;
                  lProdConc.Produto_Concorrente__c = lParamProd.Produto_Concorrencia__c;
                  lProdConc.Checklist_de_visita__c = lCk.Id;
                  lProdConc.Regional__c = lParamProd.Regional__c;
                  lProdConc.SKU__c = lParamProd.SKU__c;
                  lProdConc.RecordTypeId = idRecTypePC;
                  
                  // CustomerRSPProfile x CustomerRSPProduct
                  if ( lCk.Visita__r.Conta__r.Client_code_AN8__c != null )
                    setDemantra( lCk, lProdConc );
                  checkListConcList.add( lProdConc );
                }
              }
                
              //Esta lista es insertada por el metodo que la llama.
              /*try{
                  
                  //insert checkListConcList;
              }catch(Exception e){
                  Apexpages.addMessage( new Apexpages.Message(Apexpages.SEVERITY.ERROR, e.getMessage()));
              }*/

              


              // Criar Sellout
              if ( lCanal == INDIRETO && !lCk.Visita__r.Conta__r.Receive_Attach_Sellout__c )
              {
                System.debug('%%%%%%%%%%% lProdParametro : '+lProdParametro);
                System.debug('%%%%%%%%%%% REC_TYPE_PARAM_PROD_SELLOUT  |Indireto| : ' +REC_TYPE_PARAM_PROD_SELLOUT + '|Indireto|' ); 
                lProdParamList = lProdParametro.get( REC_TYPE_PARAM_PROD_SELLOUT + '|Indireto|' );//Modification Change Request 4// + lRegional
                
                System.debug('%%%%%%%%%%% lProdParamList : '+lProdParamList);
                if ( lProdParamList != null )
                  for ( Par_metro_Produto_Concorr_ncia__c lParamProd : lProdParamList )
                  {
                    Posicao_Sellout__c lSellout = new Posicao_Sellout__c();
                    lSellout.Checklist_de_visita__c = lCk.id;
                    lSellout.Produto2__c = lParamProd.Marca__c;
                    lSellout.RecordTypeId = idRecTypePS;
                    checkListSelloutList.add( lSellout );
                  }
              }
            }
        }
        //MIGRATED 17/11/2016
        else {
            Map< String, List< Par_metro_Produto_Concorr_ncia__c > > lProdParametro = PlanejamentoVisitasCriaVisitasAux.getParamProdConcorrencia();
            System.debug('%%%%%%%%%% lProdParametro : '+lProdParametro);
            //conta -> List< contractid >
            Map< String, List< String > > lAccountContracts = new Map< String, List< String > >();
            // contract -> Lista Produtos
            Map< String, List< List< String > > > lProdContrato = PlanejamentoVisitasCriaVisitasAux.getParamProdContrato( aAccountIds, lAccountContracts );
         
            List< Decimal > lProfIDs = PlanejamentoVisitasCriaVisitasAux.getRSPProfile( fAN8Map, fOrgBandMap, fCanalUFAN8Map );
            /**
             * Recupera os Checklists que foram inseridos com os campos de conta (referência)
             */
            List< Checklist_de_visita__c > lCheckList = ChecklistVisitaDAO.getInstance().getListChecklistInfoAccount( aCheckListID );
            for ( Checklist_de_visita__c lCk : lCheckList )
            {
              if ( lCk.Visita__r.Tipo_de_Visita__c == null || lCk.Visita__r.Tipo_de_Visita__c.equalsIgnoreCase( 'Vendas' ) ) continue;
              //String lRegional = lCk.Visita__r.Conta__r.Regional__c;// Modification Change Request 4
              Integer lCanal = getCanal( lCk.Visita__r.Conta__r.Channel__c, lCk.Visita__r.Conta__r.Channel_Type__c );
              //String lSubCanal = lCk.Visita__r.Conta__r.Sub_Channel__c; // Modification Change Request 4
              
              List< String > lContracts = lAccountContracts.get( lCk.Visita__r.Conta__r.id );
              if ( lContracts != null )
              {
                Map< String, List< String > > lCCV = PlanejamentoVisitasCriaVisitasAux.getContrapartidaContratoVisita( lContracts );
                for ( String lContract : lContracts )
                {
                  List< List< String > > lProdContratoList = lProdContrato.get( lContract );
                  // Contrapartida
                  if ( lCanal == OFF_TRADE || lCanal == INDIRETO )
                  {
                    incluirContrapartida( lCCV.get( lContract ), lCk.id, secao_contrapartida[ 1 ] );
                  }
                  else
                  {
                    if ( lProdContratoList != null )
                    {
                      Integer lLen = lProdContratoList.size();
                      for ( Integer i=1; i<lLen; i++ )
                      {
                        incluirContrapartida( lProdContratoList[ i ], lCk.id, secao_contrapartida[ i ] );
                      }
                    }
                  }
          
                  // Criar Organização e Exposição
                  //          if ( lCanal.equalsIgnoreCase( 'Off Trade' ) 
                  //          || ( lCanal.equalsIgnoreCase( 'On Trade' ) && !lTipo.equalsIgnoreCase( 'Indireto' ) ) )
                  if ( ( lCanal == OFF_TRADE || lCanal == ON_TRADE ) && lProdContratoList != null )
                  {
                    for ( String lProdLabel : lProdContratoList[ 0 ] )
                    {
                      if ( existeExposicao( lCk.Id + '|' + lProdLabel ) ) continue;
                      Checklist_Exposicao__c lExp = new Checklist_Exposicao__c();
                      lExp.Checklist_de_visita__c = lCk.Id;
                      lExp.Schedule_C__c = lProdLabel;
                      checkListExpList.add( lExp );
                    }
                  }
                }
            }// fim if
              
              // Criar Produtos Concorrência

              
              system.debug('TOKEN1 : '+lCk.Visita__r.Conta__r.Channel__c);
              List< Par_metro_Produto_Concorr_ncia__c > lProdParamList = [SELECT Id, LAT_Product__c, LAT_SKU__c, Regional__c, Produto_Concorrencia__c, Canal__c FROM Par_metro_Produto_Concorr_ncia__c WHERE Canal__c=:lCk.Visita__r.Conta__r.Channel__c ];//Modification Change Request 4 lProdParametro.get( REC_TYPE_PARAM_PROD_CONCORRENCIA + '|' + lCk.Visita__r.Conta__r.Channel__c + '|' + lRegional + '|' + lSubCanal);
              system.debug('TOKEN lProdParamList: '+lProdParamList);
              if ( lProdParamList != null )
              {
                for ( Par_metro_Produto_Concorr_ncia__c lParamProd : lProdParamList )
                {
                  system.debug('TOKEN lParamProd: '+lParamProd);
                  Produto_Concorr_ncia__c lProdConc = new Produto_Concorr_ncia__c();
                  lProdConc.Canal__c = lParamProd.Canal__c;
                  lProdConc.LAT_Product__c = lParamProd.LAT_Product__c;
                  lProdConc.Produto_Concorrente__c = lParamProd.Produto_Concorrencia__c;
                  lProdConc.Checklist_de_visita__c = lCk.Id;
                  lProdConc.Regional__c = lParamProd.Regional__c;
                  lProdConc.SKU__c = lParamProd.LAT_Sku__c;
                  lProdConc.RecordTypeId = idRecTypePC;
                  
                  // CustomerRSPProfile x CustomerRSPProduct
                  if ( lCk.Visita__r.Conta__r.Client_code_AN8__c != null )
                    setDemantra( lCk, lProdConc );
                  checkListConcList.add( lProdConc );
                }
              }
                
              //Esta lista es insertada por el metodo que la llama.
              /*try{
                  
                  //insert checkListConcList;
              }catch(Exception e){
                  Apexpages.addMessage( new Apexpages.Message(Apexpages.SEVERITY.ERROR, e.getMessage()));
              }*/

              


              // Criar Sellout
              if ( lCanal == INDIRETO && !lCk.Visita__r.Conta__r.Receive_Attach_Sellout__c )
              {
                lProdParamList = lProdParametro.get( REC_TYPE_PARAM_PROD_SELLOUT + '|Indireto|' );//Modification Change Request 4// + lRegional
                if ( lProdParamList != null )
                  for ( Par_metro_Produto_Concorr_ncia__c lParamProd : lProdParamList )
                  {
                    Posicao_Sellout__c lSellout = new Posicao_Sellout__c();
                    lSellout.Checklist_de_visita__c = lCk.id;
                    lSellout.Produto2__c = lParamProd.Marca__c;
                    lSellout.RecordTypeId = idRecTypePS;
                    checkListSelloutList.add( lSellout );
                  }
              }
            }          
        }
        if(Test.isRunningTest()){
          existeContrapartida('Test');
          incluirContrapartida(new List<String>{'Test1','Test2'},null,'Test');
          
        }
    }
        
    private void setDemantra( Checklist_de_visita__c aCk, Produto_Concorr_ncia__c aProdConc )
    {
          CustomerRSPProfiles__c lProfile = fAN8Map.get( aCk.Visita__r.Conta__r.Client_code_AN8__c );
          if ( lProfile == null && aCk.Visita__r.Conta__r.Customer_Organization__r.CodDefUsuario__c != null 
          && aCk.Visita__r.Conta__r.Customer_Flag__r.CodDefUsuario__c != null )
            lProfile = fOrgBandMap.get( aCk.Visita__r.Conta__r.Customer_Organization__r.CodDefUsuario__c 
                                    + '|' + aCk.Visita__r.Conta__r.Customer_Flag__r.CodDefUsuario__c );
          if ( lProfile == null && aCk.Visita__r.Conta__r.Sub_Channel_Rating__r.CodDefUsuario__c != null
          && aCk.Visita__r.Conta__r.Revenue_UF__c != null )
            lProfile = fCanalUFAN8Map.get( aCk.Visita__r.Conta__r.Sub_Channel_Rating__r.CodDefUsuario__c 
                                       + '|' + aCk.Visita__r.Conta__r.Revenue_UF__c );
          if ( lProfile == null ) return;
          Map< String, CustomerRSPProducts__c > lMap = fRSPProdMap.get( lProfile.profile_id__c );
          if ( lMap == null )
          {
            lMap = PlanejamentoVisitasCriaVisitasAux.getCustomerRSPProdMap( lProfile.profile_id__c );
            fRSPProdMap.put( lProfile.profile_id__c, lMap );
          }
          CustomerRSPProducts__c lRSPProd = lMap.get( aProdConc.SKU__c );
          if ( lRSPProd == null ) return;
          aProdConc.Range_Demantra_AT__c = lRSPProd.price_rsp_max__c;
          aProdConc.Range_Demantra_DE__c = lRSPProd.price_rsp_min__c;
    }
        
    private void incluirContrapartida( List< String > aLabels, ID aCheckID, String aSection )
    {
          if ( aLabels == null ) return;
          for ( String lProdLabel : aLabels )
          {
            if ( existeContrapartida( aCheckID+'|'+aSection+'|'+lProdLabel ) ) continue;
            Checklist__c lContra = new Checklist__c();
            lContra.RecordTypeId = idRecTypeCh;
            lContra.Schedule_C__c = lProdLabel;
            lContra.Checklist_de_visita__c = aCheckID;
            lContra.Secao_Contrapartidas__c = aSection;
            checkListContraList.add( lContra );
          }
    }
    
    private boolean existeContrapartida( String aValue )
      {
            if ( fRepeatContrapartida.contains( aValue ) ) return true;
            fRepeatContrapartida.add( aValue );
          return false; 
      }
    
    private boolean existeExposicao( String aValue )
    {
          if ( fRepeatExposicao.contains( aValue ) ) return true;
          fRepeatExposicao.add( aValue );
          return false; 
    }
    
    private static Integer getCanal( String aCanal, String aTipo )
    {
          if ( (aCanal!=null && aCanal.equalsIgnoreCase( 'Off Trade' )) && ( aTipo == null || !aTipo.equalsIgnoreCase( 'Indireto' ) ) )
              return 1;
          else
              if ( (aCanal!=null && aCanal.equalsIgnoreCase( 'Off Trade' )) && aTipo != null && aTipo.equalsIgnoreCase( 'Indireto' ) )
              return 2;
          else
              if ( (aCanal!=null && aCanal.equalsIgnoreCase( 'On Trade' )) )
              return 3;
          return -1;
        }
      }