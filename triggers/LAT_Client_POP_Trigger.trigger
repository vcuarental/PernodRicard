trigger LAT_Client_POP_Trigger on LAT_ClientPOP__c (after insert, before insert,after update) {
	if(trigger.isBefore){
		if(trigger.isInsert){
			LAT_CLIENTPOP.createEntrega(trigger.new);
			LAT_CLIENTPOP.updateDate(trigger.new);
		}
	}else if(trigger.isAfter){
		if(trigger.isUpdate){
			LAT_CLIENTPOP.executeEntrega(trigger.newMap,trigger.oldMap);
			
		}else if(trigger.isInsert){
			LAT_CLIENTPOP.createEntregaTask(trigger.newMap);
			LAT_CLIENTPOP.executeEntregaWPlan(trigger.newMap);
		}
	}

}