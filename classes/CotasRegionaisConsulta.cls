/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Verifica se existe alguma cota relacionada a um SKU.
* NAME: CotasRegionaisConsulta.cls
* AUTHOR: ROGÉRIO ALVARENGA                 DATE: 
*
* MAINTENANCE
* AUTHOR:                                           DATE: 
********************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/
public with sharing class CotasRegionaisConsulta {
  
  private Map< String, Criterio_de_cota_regional__c > fMapCriterioRegional = new Map< String, Criterio_de_cota_regional__c >();
  private Map< String, List< Criterio_de_cota_regional__c > > fMapListaCritNac = new Map< String, List< Criterio_de_cota_regional__c > >();
  private Map<String, Cota_regional__c> fMapCotaRegional = new Map<String, Cota_regional__c>();
  
  public CotasRegionaisConsulta( List< String > aSKUList )
  {
    List< Criterio_de_cota_regional__c > lListCriterioCotaRegional = CriterioCotaRegionalDAO.getInstance().getListCriterioByIdSKU( aSKUList );
      for( Criterio_de_cota_regional__c lCritR : lListCriterioCotaRegional )
      {
          fMapCriterioRegional.put( lCritR.id, lCritR );
          List< Criterio_de_cota_regional__c > lList = fMapListaCritNac.get( lCritR.SKU__c );
          if ( lList == null )
          {
            lList = new List< Criterio_de_cota_regional__c >();
            fMapListaCritNac.put( lCritR.SKU__c, lList );
          }
          lList.add( lCritR );
      }
      List< Cota_regional__c > lListCotasRegionais = CotasRegionaisDAO.getInstance().getListCotasRegionais( aSKUList );
      for ( Cota_regional__c lCotaR : lListCotasRegionais )
      {
        Criterio_de_cota_regional__c lCritR = fMapCriterioRegional.get( lCotaR.Criterio_regional_de_cota__c );
        if ( lCritR == null ) continue;
          String sb = lCotaR.SKU__c + '|';
          if ( lCritR.Regional__c != null ) sb += lCotaR.Regional__c + '|';
          if ( lCritR.Canal__c != null ) sb += lCotaR.Canal__c + '|';
          if ( lCritR.Sub_canal__c != null ) sb += lCotaR.Sub_canal__c + '|';
          if ( lCritR.Bandeira__c != null || lCotaR.Bandeira_regional__c != null ) sb += lCotaR.Bandeira_referencia__c + '|';
          if ( lCritR.Executivo__c ) sb += lCotaR.Executivo__c + '|';
          if ( lCotaR.Cliente__c != null ) sb += lCotaR.Cliente__c;
          fMapCotaRegional.put( sb, lCotaR );
      }
  }
  
  public Cota_regional__c getCota( String aSKU, Opportunity aOpp )
  {
    List< Criterio_de_cota_regional__c > lList = fMapListaCritNac.get( aSKU );
    if ( lList == null ) return null;
    
    String lBandeira = aOpp.Account.Customer_Flag__r.Id;
    if ( lBandeira != null && lBandeira.length() > 3 )
      lBandeira = lBandeira.substring( 0, lBandeira.length() - 3 );
    
    
    for ( Criterio_de_cota_regional__c critR : lList )
    {
      // Usando bandeira do criterio
      Cota_regional__c lCotaR = getCota( critR, aOpp, aSKU, critR.Bandeira__c != null ? lBandeira:'' );
      if ( lCotaR == null ) lCotaR = getCota( critR, aOpp, aSKU, lBandeira ); // Usando bandeira 
      if ( lCotaR != null ) return lCotaR;
    }
    return null;
  }

  //MIGRATED 02/11/2016 
  public Cota_regional__c getCota( String aSKU, LAT_Opportunity__c aOpp )
  {
    List< Criterio_de_cota_regional__c > lList = fMapListaCritNac.get( aSKU );
    if ( lList == null ) return null;
    
    String lBandeira = aOpp.LAT_Account__r.Customer_Flag__r.Id;
    if ( lBandeira != null && lBandeira.length() > 3 )
      lBandeira = lBandeira.substring( 0, lBandeira.length() - 3 );
    
    
    for ( Criterio_de_cota_regional__c critR : lList )
    {
      // Usando bandeira do criterio
      Cota_regional__c lCotaR = getCota( critR, aOpp, aSKU, critR.Bandeira__c != null ? lBandeira:'' );
      if ( lCotaR == null ) lCotaR = getCota( critR, aOpp, aSKU, lBandeira ); // Usando bandeira 
      if ( lCotaR != null ) return lCotaR;
    }
    return null;
  }
  
  private Cota_regional__c getCota( Criterio_de_cota_regional__c critR, Opportunity aOpp, String aSKU, String aBandeira )
  { 
    String sb = aSKU + '|';
    String subString = aOpp.Account.Regional__r.Id;
    if ( critR.Regional__c != null && subString != null ){
        sb += subString.substring( 0, subString.length() - 3 ) + '|';
    }
    if ( critR.Canal__c != null ) sb += aOpp.Account.Channel__c + '|';
    if ( critR.Sub_canal__c != null ) sb += aOpp.Account.Sub_Channel__c + '|';
    if ( aBandeira != '' ) sb += aBandeira + '|';
    if ( critR.Executivo__c ) sb += aOpp.OwnerId + '|';
    Cota_regional__c lCotaR = fMapCotaRegional.get( sb );
    if ( lCotaR != null ) return lCotaR;
    return fMapCotaRegional.get( sb + aOpp.AccountId );
  }

  //MIGRATED 02/11/2016 
  private Cota_regional__c getCota( Criterio_de_cota_regional__c critR, LAT_Opportunity__c aOpp, String aSKU, String aBandeira )
  { 
    String sb = aSKU + '|';
    String subString = aOpp.LAT_Account__r.Regional__r.Id;
    if ( critR.Regional__c != null && subString != null ){
        sb += subString.substring( 0, subString.length() - 3 ) + '|';
    }
    if ( critR.Canal__c != null ) sb += aOpp.LAT_Account__r.Channel__c + '|';
    if ( critR.Sub_canal__c != null ) sb += aOpp.LAT_Account__r.Sub_Channel__c + '|';
    if ( aBandeira != '' ) sb += aBandeira + '|';
    if ( critR.Executivo__c ) sb += aOpp.OwnerId + '|';
    Cota_regional__c lCotaR = fMapCotaRegional.get( sb );
    if ( lCotaR != null ) return lCotaR;
    return fMapCotaRegional.get( sb + aOpp.LAT_Account__c );
  }
  
  public static Map<String, String> getPriceEntryXSKU( List< OpportunityLineItem > aItems )
  {
    List< String > lListIdsPricebookEntry = new List<String>();
    for( OpportunityLineItem oli : aItems ){
      lListIdsPricebookEntry.add( oli.PricebookEntryId );
    }
    Map<String, String>fMapSKUs = new Map<String, String>();
    List< PricebookEntry > lListPricebookEntry = PricebookEntryDAO.getInstance().getListPricebookEntry( lListIdsPricebookEntry );
    List<String> lListIdsSKU = new List<String>();
    for( PricebookEntry pbe: lListPricebookEntry )
    {
      lListIdsSKU.add( pbe.Product2.Sku__c );
      fMapSKUs.put( pbe.Id, pbe.Product2.Sku__c );
    }
    return fMapSKUs;
  }

  //MIGRATED 02/11/2016 
  public static Map<String, String> getPriceEntryXSKU( List< LAT_OpportunityLineItem__c > aItems )
  {
    List< String > lListIdsOpptyLineItem = new List<String>();
    for( LAT_OpportunityLineItem__c oli : aItems ){
      lListIdsOpptyLineItem.add( oli.Id );
    }
    List<LAT_OpportunityLineItem__c> aItmms2 = [SELECT Id, LAT_Product__r.LAT_Sku__c FROM LAT_OpportunityLineItem__c WHERE Id in:lListIdsOpptyLineItem ];
    Map<String, String>fMapSKUs = new Map<String, String>();
    List<String> lListIdsSKU = new List<String>();
    for( LAT_OpportunityLineItem__c pbe: aItmms2 )
    {
      lListIdsSKU.add( pbe.LAT_Product__r.LAT_Sku__c );
      fMapSKUs.put( pbe.Id, pbe.LAT_Product__r.LAT_Sku__c );
    }
    return fMapSKUs;
  }
}