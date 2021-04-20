trigger LAT_Debit on DBT_Debit_ARG__c (before insert, before update, before delete, after insert, after update, after delete) {

		if (Trigger.isBefore) {
	    	if (trigger.isUpdate){
				LAT_AR_Debit.DebitCheckPrintStatus(trigger.newMap);
			}

			if (trigger.isDelete){
				LAT_AR_Debit.DebitCheckPrintStatus(trigger.oldMap);
			}
	    
		} else if (Trigger.isAfter) {
	    	if (trigger.isUpdate){
	    		LAT_AR_Debit.replicateJDE_ID(trigger.newMap);
	    	}
	    
		}
}