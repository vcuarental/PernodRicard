/*
* LAT_ProductCostAfterInsert
* Trigger to expire old product costs
* Author: Martin Prado (martin@zimmic.com)
* Date: 11/07/2016
*/
trigger LAT_ProductCostAfterInsert on LAT_ProductCost__c (after insert) {

  Set<Id> extIds = new Set<Id>();
  Set<Id> extIdsToUpdate = new Set<Id>();
  Map<String, Set<Id>> pcMap = new Map<String, Set<Id>>();
  LAT_ProductCost__c pcParam;

  List<LAT_ProductCost__c> allCurrentProductCost = [Select ExternalId__c, Id, EndDate__c FROM LAT_ProductCost__c WHERE EndDate__c >= :System.NOW() ];
  Set<String> extName = new Set<String>();
  // we have the external id like: "BA-98835-104-CHIVAS 12-201607022144" but we need only "BA-98835-104-CHIVAS 12"
  for(LAT_ProductCost__c pc : allCurrentProductCost ){
    String specialExt = pc.ExternalId__c.substringBeforeLast('-');
    extName.add(specialExt);

    Set<Id> lstIds = new Set<id>();
    if(pcMap.containsKey(specialExt)){
          lstIds = pcMap.get(specialExt);
    }
    lstIds.add(pc.Id);
    pcMap.put(specialExt,lstIds);
  }

  for ( LAT_ProductCost__c pc : trigger.new ) {
    pcParam = pc;
    String specialExt = pc.ExternalId__c.substringBeforeLast('-');
    if(extName.contains(specialExt)){
      extIds.add(pc.Id);
      Set<Id> lstIds = pcMap.get(specialExt);
      if(lstIds.contains(pc.Id)){
        lstIds.remove(pc.Id);
      }
      extIdsToUpdate.addAll(lstIds);
    }
  }



  // Product Cost that need to expire now . All new productCost must begin the same month-year
  List<LAT_ProductCost__c> productToChangeEndDate = [Select Id, EndDate__c FROM LAT_ProductCost__c WHERE Id  NOT IN :extIds AND ID IN:extIdsToUpdate  ];
  for ( LAT_ProductCost__c pc : productToChangeEndDate ) {
    pc.EndDate__c = pcParam.StartDate__c.addMinutes(-10);
  }
  update productToChangeEndDate;



}