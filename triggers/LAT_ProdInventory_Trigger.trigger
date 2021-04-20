trigger LAT_ProdInventory_Trigger on LAT_ProdInventory__c (after update) {

	LAT_ProdInventory.updateInventoryAmount(trigger.newMap, trigger.oldMap);

}