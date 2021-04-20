trigger LAT_ProductTrigger on LAT_Product__c (before insert, before update, before delete, after insert, after update, after delete) {
	if (trigger.isAfter && trigger.isUpdate) {
		LAT_CTR_Product2.runTriggers();
    } else if(trigger.isAfter && trigger.isInsert) {    
    	LAT_CTR_Product2.runTriggers();
    } else if(trigger.isBefore && trigger.isUpdate) {
        LAT_CTR_Product2.runTriggers(); 
    } else if(trigger.isBefore && trigger.isInsert) {       
        LAT_CTR_Product2.runTriggers();
    } else if(trigger.isBefore && trigger.isDelete) {
       
    } else if(trigger.isAfter && trigger.isDelete) {

    }
}