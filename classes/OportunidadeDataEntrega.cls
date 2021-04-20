/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* NAME: OportunidadeDataEntrega.cls
* AUTHOR:                                               DATE: 
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/
public with sharing class OportunidadeDataEntrega {
  
  private Set< String > fFeriados = new Set< String >();
  private Map< String, Opportunity > fAccInfos = new Map< String, Opportunity >();
  private Map< String, List< OpportunityLineItem > > fListItems = new Map< String, List< OpportunityLineItem > >();
  private Set< Id > setRecTypeOpp = getIds();

  //VARIABLES MIGRACION LICENCIAS 
  private Map< String, LAT_Opportunity__C > LAT_fAccInfos = new Map< String, LAT_Opportunity__C >();
  private Map< String, List< LAT_OpportunityLineItem__c > > LAT_fListItems = new Map< String, List< LAT_OpportunityLineItem__c > >();
  
  //Mario Praca - 21/06/2013 - inicio
  public string ipais;
  //Mario Praca - 21/06/2013 - fim

  private Set< Id > getIds(){
    if(!Utils.wasMigrationDone('1')) {
      Set< Id > lSet = new Set< Id >();
      //Recupera os ids de tipo de registro de ooportunidade
      lSet.add( RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao'));
      lSet.add( RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao_do_cabecalho'));
      lSet.add( RecordTypeForTest.getRecType('Opportunity', 'Nova_oportunidade'));
      
      lSet.add( RecordTypeForTest.getRecType('Opportunity', 'OPP_1_NewOrder_ARG'));
      lSet.add( RecordTypeForTest.getRecType('Opportunity', 'OPP_2_NewOrder_URU'));
      lSet.add( RecordTypeForTest.getRecType('Opportunity', 'OPP_3_HeaderBlocked_ARG'));
      lSet.add( RecordTypeForTest.getRecType('Opportunity', 'OPP_4_HeaderBlocked_URU'));
      lSet.add( RecordTypeForTest.getRecType('Opportunity', 'OPP_5_OrderBlocked_ARG'));
      lSet.add( RecordTypeForTest.getRecType('Opportunity', 'OPP_6_OrderBlocked_URU'));
      
      return lSet;
    }
    //MIGRATED 07/11/2016
    else {
      Set< Id > lSet = new Set< Id >();
      //Recupera os ids de tipo de registro de ooportunidade
      lSet.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Bloqueia_alteracao'));
      lSet.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Bloqueia_alteracao_do_cabecalho'));
      lSet.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'Nova_oportunidade'));
      
      lSet.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'OPP_1_NewOrder_ARG'));
      lSet.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'OPP_2_NewOrder_URU'));
      lSet.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'OPP_3_HeaderBlocked_ARG'));
      lSet.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'OPP_4_HeaderBlocked_URU'));
      lSet.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'OPP_5_OrderBlocked_ARG'));
      lSet.add( RecordTypeForTest.getRecType('LAT_Opportunity__c', 'OPP_6_OrderBlocked_URU'));
      
      return lSet;
      
    }
  }
  public OportunidadeDataEntrega( List< String > aOppIDs )
  {
    if(!Utils.wasMigrationDoneByRecords(aOppIDs)) {
      // Recupera todos os dias não úteis
      Date dHoy = date.today();
  	  List< Calendario_de_Entrega__c > lListCalend = [ SELECT date_full__c, cd_local__c, calendar_key__c, pais__c FROM Calendario_de_Entrega__c WHERE ind_util__c <> 'W' AND date_full__c >: dHoy AND date_full__c <: dHoy.addMonths(6) ];
  	
      if ( lListCalend != null )
      {
        for ( Calendario_de_Entrega__c lCalend : lListCalend )
        {
          fFeriados.add(lCalend.pais__c+'|'+ lCalend.cd_local__c + '|' + lCalend.calendar_key__c + '|' + lCalend.date_full__c );
        }
      }
      
      // Recupera todos as oportunidades que serão alteradas, com dados do cliente
      List< Opportunity > lListOpps = [ SELECT id, name, Data_Entrega_Recalculada__c, StageName , DT_delivery__c, 
          Data_Entrega_Calculada__c, Account.Business_Unit__r.CodDefUsuario__c, Account.Business_Unit_AR__r.CodDefUsuario__c , Account.Carriers_Numbers__c, pais__c
          FROM Opportunity WHERE id =: aOppIDs AND Cancelar_pedido__c = false
          AND (Account.Business_Unit__c != null OR Account.Business_Unit_AR__c != null) 
          AND RecordTypeId =: setRecTypeOpp ];
      if ( lListOpps == null ) return;
     
      for ( Opportunity lItem : lListOpps )
        fAccInfos.put( lItem.Id, lItem );
      
      List< OpportunityLineItem > lListItems = [ select PriceBookEntry.Product2Id, PriceBookEntry.Product2.QT_lead_time__c, OpportunityId
                                         from OpportunityLineItem where OpportunityId =: aOppIDs and CD_Action__c <> 'C' ];
      if ( lListItems != null )
      {
        for ( OpportunityLineItem lItem : lListItems )
        {
          List< OpportunityLineItem > lList = fListItems.get( lItem.OpportunityId );
          if ( lList == null )
          {
            lList = new List< OpportunityLineItem >();
            fListItems.put( lItem.OpportunityId, lList );
          }
          lList.add( lItem );
        }
      }
    } 
    //MIGRATED 07/11/2016
    else {
      // Recupera todos os dias não úteis
      Date dHoy = date.today();
      List< Calendario_de_Entrega__c > lListCalend = [ SELECT date_full__c, cd_local__c, calendar_key__c, pais__c FROM Calendario_de_Entrega__c WHERE ind_util__c <> 'W' AND date_full__c >: dHoy AND date_full__c <: dHoy.addMonths(6) ];
    
      if ( lListCalend != null )
      {
        for ( Calendario_de_Entrega__c lCalend : lListCalend )
        {
          fFeriados.add(lCalend.pais__c+'|'+ lCalend.cd_local__c + '|' + lCalend.calendar_key__c + '|' + lCalend.date_full__c );
        }
      }
      
      // Recupera todos as oportunidades que serão alteradas, com dados do cliente
      List< LAT_Opportunity__c > lListOpps = [ SELECT Id, Name, LAT_ReEstimatedDeliveryDate__c, LAT_StageName__c, LAT_DTDelivery__c, 
          LAT_EstimatedDeliveryDate__c, LAT_Account__r.Business_Unit__r.CodDefUsuario__c, LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c , LAT_Account__r.Carriers_Numbers__c, LAT_Country__c
          FROM LAT_Opportunity__c WHERE id =: aOppIDs AND LAT_CancelOrder__c = false
          AND (LAT_Account__r.Business_Unit__c != null OR LAT_Account__r.Business_Unit_AR__c != null) 
          AND RecordTypeId =: setRecTypeOpp ];
      if ( lListOpps == null ) return;
     
      for ( LAT_Opportunity__c lItem : lListOpps )
        LAT_fAccInfos.put( lItem.Id, lItem );
      
      List< LAT_OpportunityLineItem__c > lListItems = [ select LAT_Product__c, LAT_Product__r.LAT_QTLeadTime__c, LAT_Opportunity__c
                                         from LAT_OpportunityLineItem__c where LAT_Opportunity__c =: aOppIDs and LAT_CDAction__c <> 'C' ];
      if ( lListItems != null )
      {
        for ( LAT_OpportunityLineItem__c lItem : lListItems )
        {
          List< LAT_OpportunityLineItem__c > lList = LAT_fListItems.get( lItem.LAT_Opportunity__c );
          if ( lList == null )
          {
            lList = new List< LAT_OpportunityLineItem__c >();
            LAT_fListItems.put( lItem.LAT_Opportunity__c, lList );
          }
          lList.add( lItem );
        }
      }      
    }
  }
  
  public Opportunity atualizaPedido( String aId )
  {
    return atualizaPedido( fAccInfos.get( aId ) );
  }
  //MIGRATED 07/11/2016
  public LAT_Opportunity__c LAT_atualizaPedido( String aId )
  {
    return atualizaPedido( LAT_fAccInfos.get( aId ) );
  }
  
  public Opportunity atualizaPedido( Opportunity aOpp )
  {
    if ( aOpp == null ) return null;
    // Recupera a oportunidade com os dados do cliente
    Opportunity lOppAcc = fAccInfos.get( aOpp.Id );
    if ( lOppAcc == null ) return null;
    // Recupera todos os items do pedido
    List< OpportunityLineItem > lListItems = fListItems.get( aOpp.Id );
    if ( lListItems != null )
    {
      for ( OpportunityLineItem lItem : lListItems )
      {
        string CodDefUsuario = '';
        //Business_Unit_AR__r.CodDefUsuario__c
        if (lOppAcc.Account.Business_Unit_AR__c != null) {
            CodDefUsuario = lOppAcc.Account.Business_Unit_AR__r.CodDefUsuario__c;
        } else {
            CodDefUsuario = lOppAcc.Account.Business_Unit__r.CodDefUsuario__c;
        }
       
        
         //Mario Praca - 21/06/2013 - recupera codigo do pais - inicio
        ipais = string.valueof(lOppAcc.pais__c);
        //Mario Praca - 21/06/2013 - recupera codigo do pais - fim

        Date lItemDate = calculaDataItem( CodDefUsuario,
                                          lOppAcc.Account.Carriers_Numbers__c, 
                                          Integer.valueOf( lItem.PriceBookEntry.Product2.QT_lead_time__c ) );
        if ( aOpp.Data_Entrega_Recalculada__c == null || lItemDate > aOpp.Data_Entrega_Recalculada__c )
          aOpp.Data_Entrega_Recalculada__c = lItemDate;
        if ( aOpp.StageName == 'Novo pedido' && ( aOpp.Data_Entrega_Calculada__c == null || lItemDate > aOpp.Data_Entrega_Calculada__c ) )
          aOpp.Data_Entrega_Calculada__c = lItemDate;
        if (aOpp.StageName == 'Novo pedido' && (aOpp.DT_delivery__c < aOpp.Data_Entrega_Calculada__c ))
          aOpp.DT_delivery__c = aOpp.Data_Entrega_Calculada__c;
      }
    }
    return aOpp;
  }

  //MIGRATED 07/11/2016
  public LAT_Opportunity__c atualizaPedido( LAT_Opportunity__c aOpp )
  {
    if ( aOpp == null ) return null;
    // Recupera a oportunidade com os dados do cliente
    LAT_Opportunity__c lOppAcc = LAT_fAccInfos.get( aOpp.Id );
    if ( lOppAcc == null ) return null;
    // Recupera todos os items do pedido
    List< LAT_OpportunityLineItem__c > lListItems = LAT_fListItems.get( aOpp.Id );
    if ( lListItems != null )
    {
      for ( LAT_OpportunityLineItem__c lItem : lListItems )
      {
        string CodDefUsuario = '';
        //Business_Unit_AR__r.CodDefUsuario__c
        if (lOppAcc.LAT_Account__r.Business_Unit_AR__c != null) {
            CodDefUsuario = lOppAcc.LAT_Account__r.Business_Unit_AR__r.CodDefUsuario__c;
        } else {
            CodDefUsuario = lOppAcc.LAT_Account__r.Business_Unit__r.CodDefUsuario__c;
        }
       
        
         //Mario Praca - 21/06/2013 - recupera codigo do pais - inicio
        ipais = string.valueof(lOppAcc.LAT_Country__c);
        //Mario Praca - 21/06/2013 - recupera codigo do pais - fim

        Date lItemDate = calculaDataItem( CodDefUsuario,
                                          lOppAcc.LAT_Account__r.Carriers_Numbers__c, 
                                          Integer.valueOf( lItem.LAT_Product__r.LAT_QTLeadTime__c ) );
        if ( aOpp.LAT_ReEstimatedDeliveryDate__c == null || lItemDate > aOpp.LAT_ReEstimatedDeliveryDate__c )
          aOpp.LAT_ReEstimatedDeliveryDate__c = lItemDate;
        if ( aOpp.LAT_StageName__c == 'Novo pedido' && ( aOpp.LAT_EstimatedDeliveryDate__c == null || lItemDate > aOpp.LAT_EstimatedDeliveryDate__c ) )
          aOpp.LAT_EstimatedDeliveryDate__c = lItemDate;
        if (aOpp.LAT_StageName__c == 'Novo pedido' && (aOpp.LAT_DTDelivery__c < aOpp.LAT_EstimatedDeliveryDate__c ))
          aOpp.LAT_DTDelivery__c = aOpp.LAT_EstimatedDeliveryDate__c;
      }
    }
    return aOpp;
  }
  
  private Date calculaDataItem( String aUnidFat, String aTransp, Integer aLeadTime )
  {
  	//Consulta al custom settings
  	LAT_BR_CS003_OppLimitTime__c timeLimit = LAT_BR_CS003_OppLimitTime__c.getOrgDefaults();
  	Datetime dateLimit = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(), Integer.ValueOf(timeLimit.LAT_BR_HH__c), Integer.ValueOf(timeLimit.LAT_BR_MM__c), 0);
  	
    Date lResult = Date.today();
    if ( Datetime.now() >= dateLimit )
   		if (ipais == '1')
   			lResult = lResult.addDays( 1 );
	
	if (aLeadTime != null)
       lResult = lResult.addDays( aLeadTime );
	
    Integer counter = 1;
    while ( true )
    {
      if ( !fFeriados.contains(ipais+'|'+ aUnidFat + '|' + aTransp + '|' + lResult ) )
        break;
      if ( counter == 10 )return null;
      else counter++;
      if (ipais == '1')
         lResult = lResult.addDays( 1 );
    }
    return lResult;
  }

}