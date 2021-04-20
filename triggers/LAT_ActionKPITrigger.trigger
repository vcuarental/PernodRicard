trigger LAT_ActionKPITrigger on LAT_ActionKPI__c (after insert) {
  if (trigger.isInsert){
    if (trigger.isAfter){
      LAT_PromotionalActionHandler.CreateAKKPIs(trigger.new);
    }
  }
}