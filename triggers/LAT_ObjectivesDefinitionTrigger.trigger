trigger LAT_ObjectivesDefinitionTrigger on LAT_ObjectivesDefinition__c (before insert, before update) {

  if(Trigger.isInsert || Trigger.isUpdate){
    if(Trigger.isBefore){
      LAT_SalesAcademy.setObjectivesDefinitionRecordType(Trigger.new);
    }


  }
}