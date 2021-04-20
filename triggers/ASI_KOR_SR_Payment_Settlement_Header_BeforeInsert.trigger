trigger ASI_KOR_SR_Payment_Settlement_Header_BeforeInsert on ASI_KOR_SR_Payment_Settlement_Header__c (before insert) {

 List<ASI_KOR_TriggerAbstract> triggerClasses = new List<ASI_KOR_TriggerAbstract> {
    new ASI_KOR_SRPaymentSettlementValidation()
  };
  
  for (ASI_KOR_TriggerAbstract triggerClass : triggerClasses) {
    triggerClass.executeTriggerAction(ASI_KOR_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, null);
  }
    
}