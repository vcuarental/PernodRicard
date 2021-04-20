trigger Lat_StockLevelTriggerUpdate on Lat_Stock__c (before insert,before update) {

	if(Trigger.isUpdate && trigger.isBefore){
		Lat_StockLevelTriggerHandler.updateLatStockLevel(trigger.oldMap,trigger.new,trigger.isUpdate);
	}
	if(Trigger.isInsert && trigger.isBefore){
		Lat_StockLevelTriggerHandler.updateLatStockLevel(trigger.oldMap,trigger.new,trigger.isUpdate);
	}
}