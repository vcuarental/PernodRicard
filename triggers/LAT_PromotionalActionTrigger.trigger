trigger LAT_PromotionalActionTrigger on LAT_PromotionalAction__c (after insert, after update) {


	if(trigger.isUpdate) {
		System.debug('is update');
		LAT_PromotionalActionHandler.generatePromotionalActionTasks(trigger.new, trigger.oldMap);
		LAT_PromotionalActionHandler.generateTaskPromotionalActionInit(trigger.new, trigger.oldMap);
	}

	LAT_PromotionalActionHandler.postToChatterGroup(trigger.new, trigger.oldMap);



}