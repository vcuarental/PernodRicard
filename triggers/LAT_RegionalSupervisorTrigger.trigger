trigger LAT_RegionalSupervisorTrigger on LAT_RegionalSupervisor__c (before insert, before update) {
  LAT_RegionalSupervisorHandler.updateNames();
}