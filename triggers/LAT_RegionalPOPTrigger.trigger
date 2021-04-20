trigger LAT_RegionalPOPTrigger on LAT_RegionalPOP__c (before insert, after insert, after update) {
	if (Trigger.isAfter){
		LAT_RegionalPOP.notificationTask(trigger.newMap, trigger.oldMap);
	}else if(Trigger.isBefore){ 
		LAT_RegionalPOP.updateOwner(trigger.new);
	}
}