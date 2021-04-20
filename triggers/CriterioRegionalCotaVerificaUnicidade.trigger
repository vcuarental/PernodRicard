/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Verifica se já existe um criterio regional de cota para 
*              SKU - REGIONAL - CANAL - SUBCANAL - BANDEIRA
* NAME: CriterioRegionalCotaVerificaUnicidade.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 27/06/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
trigger CriterioRegionalCotaVerificaUnicidade on Criterio_de_cota_regional__c (before insert) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
  
  //Declaração de variáveis  
  Id idRecTypeCritR = RecordTypeForTest.getRecType('Criterio_de_cota_regional__c', 'BRA_Standard');
  List< String > lListSku = new List< String >();
  
  for ( Criterio_de_cota_regional__c crit: trigger.new ){
    if( crit.RecordTypeId == idRecTypeCritR ){
        lListSku.add( crit.SKU__c );
    }
  }
  List< Criterio_de_cota_regional__c > lCriterios = 
    [ SELECT SKU__c, Regional_Vendas__c, Canal__c, Sub_canal__c,Bandeira__c 
      FROM Criterio_de_cota_regional__c WHERE SKU__c =:lListSku AND RecordtypeId =: idRecTypeCritR];
      
  Map< String, Criterio_de_cota_regional__c > lSetCrit = new Map< String, Criterio_de_cota_regional__c >();
  for ( Criterio_de_cota_regional__c lCrit : lCriterios )
  {
    String lKey = lCrit.SKU__c + '|' + lCrit.Regional_Vendas__c + '|' + lCrit.Canal__c + '|' + lCrit.Sub_canal__c + '|' + lCrit.Bandeira__c;
    lSetCrit.put( lKey, lCrit );
  }
  
  boolean hasError = false;
  for(Criterio_de_cota_regional__c crit: trigger.new)
  {
    if( crit.RecordTypeId == idRecTypeCritR ){
        String lKey = crit.SKU__c + '|' + crit.Regional_Vendas__c + '|' + crit.Canal__c + '|' + crit.Sub_canal__c + '|' + crit.Bandeira__c;
        Criterio_de_cota_regional__c lExist = lSetCrit.get( lKey );
        if ( lExist != null && lExist.id != crit.id ) 
        {
          hasError = true;
          break;
        }
    }
  }
  
  if ( hasError )
  {
    for(Criterio_de_cota_regional__c crit: trigger.new)
      if( crit.RecordTypeId == idRecTypeCritR )
        crit.addError( 'Já existe um critério cadastrado para essa cota nacional' );
  }
 }
}