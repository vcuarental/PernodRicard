/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Verifica se já existe uma cota nacional para
*              SKU - REGIONAL - CANAL - SUBCANAL - BANDEIRA 
* NAME: CotaNacionaVerificaUnicidade.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 27/06/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
trigger CotaNacionaVerificaUnicidade on Cota_nacional__c (before insert, before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
  
  Id idRecTypeCN = RecordTypeForTest.getRecType('Cota_nacional__c', 'BRA_Standard');
  
  List< String > lListSku = new List< String >();
  for ( Cota_nacional__c lCota: trigger.new )
    lListSku.add( lCota.SKU__c );
    
  List< Cota_nacional__c > lListCota = [ SELECT SKU__c, Regional__c, Canal__c,
      Sub_canal__c, Bandeira__c, id FROM Cota_nacional__c WHERE SKU__c =:lListSku 
      AND RecordTypeId =: idRecTypeCN];
      
  Map< String, Cota_nacional__c > lSetCrit = new Map< String, Cota_nacional__c >();
  for ( Cota_nacional__c lCota : lListCota )
  {
    String lKey = lCota.SKU__c + '|' + lCota.Regional__c + '|' + lCota.Canal__c + '|' + lCota.Sub_canal__c + '|' + lCota.Bandeira__c;
    lSetCrit.put( lKey, lCota );
  }
  
  boolean hasError = false;
  for ( Cota_nacional__c lCota: trigger.new )
  {
    String lKey = lCota.SKU__c + '|' + lCota.Regional__c + '|' + lCota.Canal__c + '|' + lCota.Sub_canal__c + '|' + lCota.Bandeira__c;
    Cota_nacional__c lExist = lSetCrit.get( lKey );
    if ( lExist != null && lExist.id != lCota.id )
    {
      hasError = true;
      break;
    }
  }
  
  if ( hasError )
  {
    for ( Cota_nacional__c lCota: trigger.new ){
        if( lCota.RecordTypeId == idRecTypeCN ){
            lCota.addError( 'Já existe uma cota nacional cadastrada para essas informações' );
        }
    }
  }
 }
}