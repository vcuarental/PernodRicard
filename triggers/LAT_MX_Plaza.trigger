trigger LAT_MX_Plaza on LAT_MX_Plaza__c (before insert, after update) {

		if (Trigger.isBefore) {
	    	if (Trigger.isInsert){
	    		LAT_MX_Plaza.validateUniquePlaza(trigger.new);
	    	}
	    
		} else if (Trigger.isAfter) {
	    	if (Trigger.isUpdate){

	    		Set <Id> plazasIds = new Set <Id>();
	    		Map <Id, LAT_MX_Plaza__c> plazasNewEjecutivoIds = new Map <Id, LAT_MX_Plaza__c>();

	    		for (LAT_MX_Plaza__c plaza :trigger.newMap.values()){
	    			if (trigger.oldMap.get(plaza.id).name != plaza.name){
	    				plazasIds.add(plaza.id);
	    			}
	    		}

	    		if (!plazasIds.isEmpty()){

	    			LAT_MX_Plaza.getAssociatedAccountsAndNotify(plazasIds);
	    		}


	    		for (LAT_MX_Plaza__c plaza :trigger.newMap.values()){
	    			if (trigger.oldMap.get(plaza.id).LAT_MX_Ejecutivo__c != plaza.LAT_MX_Ejecutivo__c){
	    				plazasNewEjecutivoIds.put(plaza.id, plaza);
	    			}
	    		}

	    		if (!plazasNewEjecutivoIds.isEmpty()){

	    			LAT_MX_Plaza.getOwnerAccountsAndSetNewPlaza(plazasNewEjecutivoIds);
	    		}
	    		
	    	}
	    
		}
}