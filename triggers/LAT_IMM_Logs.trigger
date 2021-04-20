trigger LAT_IMM_Logs on LAT_IMM_Logs__c (before insert, before update, before delete, after insert, after update) {

		if (Trigger.isBefore) {
	    	
	    
		} else if (Trigger.isAfter) {
	    	if(Trigger.isUpdate) {
	    		Map<Id, String> toUpdateMap = new Map<Id, String>();
		    	for(LAT_IMM_Logs__c log : Trigger.new){
		    		if(log.LAT_OpportunityLineItem__c != null && Trigger.oldMap.get(log.Id).LAT_OpportunityLineItem__c == null) {
		    			toUpdateMap.put(log.LAT_OpportunityLineItem__c, log.LAT_uuid__c);
		    		}
		    	}	
		    	if(toUpdateMap.size() > 0) {
		    		List<LAT_OpportunityLineItem__c> toUpdate = [SELECT Id, LAT_IdIMM__c FROM LAT_OpportunityLineItem__c WHERE Id IN :toUpdateMap.keyset()];
		    		for(LAT_OpportunityLineItem__c oli : toUpdate) {
		    			oli.LAT_IdIMM__c = toUpdateMap.get(oli.Id);
		    		}
		    		update toUpdate;
		    	}	
	    	}
	    
		}
}