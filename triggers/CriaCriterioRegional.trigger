/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Resposável por cria um critério regional automaticamente.
*
* NAME: CriaCriterioRegional.trigger
* AUTHOR: CARLOS CARVALHO                          DATE: 25/05/2012 
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
********************************************************************************/
trigger CriaCriterioRegional on Cota_nacional__c (after insert) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

   //Declaração de variáveis
   Id idRecTypeCritR = RecordTypeForTest.getRecType('Criterio_de_cota_regional__c', 'BRA_Standard');
   List<Criterio_de_cota_regional__c> listCriterioR = new List<Criterio_de_cota_regional__c>();
   
    for(Cota_nacional__c cota: trigger.new)
    {
      Criterio_de_cota_regional__c crit = new Criterio_de_cota_regional__c();
      crit.Cota_nacional__c = cota.Id;
      crit.Cota__c = cota.Cota__c;
      crit.RecordTypeId = idRecTypeCritR;
      listCriterioR.add(crit);
    }
    
    //Verifica se existem Criterio para serem autalizados.
    if(listCriterioR != null && listCriterioR.size()>0)
    {
      try { insert listCriterioR; } catch(DMLException e) { System.debug(e.getMessage()); }
    }
 }
}