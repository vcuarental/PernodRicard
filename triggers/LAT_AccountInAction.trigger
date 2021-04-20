trigger LAT_AccountInAction on LAT_AccountInAction__c (before insert,before update, after insert, after update) {
    LAT_PromotionalActionHandler.runClientesTriggers();
	if (trigger.isBefore) {
		if(trigger.isInsert){
			LAT_PromotionalActionHandler.assingMechanic(trigger.new);
			LAT_PromotionalActionHandler.setApproveByClient(trigger.new);
		}
		LAT_PromotionalActionHandler.checkAdheringClients(trigger.new);
		LAT_PromotionalActionHandler.setSegmentation(trigger.new);
	}
}