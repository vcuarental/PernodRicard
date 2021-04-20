/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Resposável por cria uma cota regional automaticamente. Somente se a regional 
* do Critério Regional estiver vazio.
*
* NAME: CriaCotaRegional.trigger
* AUTHOR: CARLOS CARVALHO                          DATE: 25/05/2012 
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
********************************************************************************/
trigger CriaCotaRegional on Criterio_de_cota_regional__c (after insert) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

   //Declaração de variáveis
   Id idRecTypeCR = RecordTypeForTest.getRecType('Cota_regional__c', 'BRA_Standard');
  List<Cota_regional__c> listCotaRegional = new List<Cota_regional__c>();
  
  for(Criterio_de_cota_regional__c crit: trigger.new)
  {
    //Verifica se a regional do critério esta vazio
    if(crit.Regional__c == null)
    {
      Cota_regional__c cotaR = new Cota_regional__c();
      cotaR.Criterio_regional_de_cota__c = crit.Id;
      cotaR.Cota__c = crit.Cota__c;
      cotaR.RecordTypeId = idRecTypeCR;
      listCotaRegional.add(cotaR);
    }
  }
  
  //Verifica se existem Criterio para serem autalizados.
  if(listCotaRegional != null && listCotaRegional.size()>0)
  {
    try
    {
      //Insere as cotas regionais
      insert listCotaRegional;
    }
    catch(DMLException e)
    {
      System.debug(e.getMessage());
    }
  }
 }
}