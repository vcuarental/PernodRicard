trigger ASI_KOR_SR_Proposal_Detail_BeforeInsert on ASI_KOR_SR_Proposal_Detail__c (before insert) {
    
	List<ASI_KOR_TriggerAbstract> triggerClasses = new List<ASI_KOR_TriggerAbstract> {
		//new ASI_KOR_createSRpropByBrand(),
    	new ASI_KOR_CreateSRpropByBrand_V2(),
        new ASI_KOR_SRUpdatePrepayment()
	};
  
  	for (ASI_KOR_TriggerAbstract triggerClass : triggerClasses) {
    triggerClass.executeTriggerAction(ASI_KOR_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, null);
  }

}