/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Verifica se já existe um criterio nacional de cota para o SKU
* NAME: CriterioNacionalCotaVerificaSKU.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 27/06/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/

trigger CriterioNacionalCotaVerificaSKU on Criterio_nacional_de_cota__c (before insert) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

    Id idRecTypeCritN = RecordTypeForTest.getRecType('Criterio_nacional_de_cota__c', 'BRA_Standard');
  List< String > lListSku = new List< String >();
  for ( Criterio_nacional_de_cota__c lCritN : Trigger.new ){
    if( lCritN.RecordTypeId == idRecTypeCritN ) lListSku.add( lCritN.SKU__c );
  }
    
  List< Criterio_nacional_de_cota__c > lCriterios = 
    [ SELECT id FROM Criterio_nacional_de_cota__c WHERE SKU__c =:lListSku 
      AND RecordTypeId =: idRecTypeCritN];
      
  if ( lCriterios.size() > 0 )
    for ( Criterio_nacional_de_cota__c lCritN : Trigger.new )
      lCritN.addError( 'Já existe um critério nacional de cota para esse SKU' );
  }
}