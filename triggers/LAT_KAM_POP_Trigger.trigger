trigger LAT_KAM_POP_Trigger on LAT_KAMPOP__c (before insert ,before update, after insert,after update) {


	if(trigger.isAfter){
		if(trigger.isInsert){
			LAT_KAMPOP.kamNotification(trigger.newMap);
			LAT_KAMPOP.shareRecords(trigger.newMap);
		}else if(trigger.isUpdate){
			LAT_KAMPOP.checkNegativeAmount(trigger.newMap,trigger.oldMap);
		}

	}
 
	if(trigger.isBefore){

		if(trigger.isInsert ){
			LAT_KAMPOP.checkKAMPOP(trigger.new);
		 }
		 
	}   
}