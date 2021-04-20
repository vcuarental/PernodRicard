trigger LAT_MX_Region on LAT_MX_Region__c (after update) {

	if (Trigger.isAfter) {
	    	if (Trigger.isUpdate){

	    		Set <Id> regionIds = new Set <Id>();
	    		Map <Id, LAT_MX_Region__c> regionNewKamIds = new Map <Id, LAT_MX_Region__c>();

	    		for (LAT_MX_Region__c region :trigger.newMap.values()){
	    			if (trigger.oldMap.get(region.id).name != region.name){
	    				regionIds.add(region.id);
	    			}
	    		}

	    		if (!regionIds.isEmpty()){

	    			LAT_MX_Region.getAssociatedAccountsAndNotify(regionIds);
	    		}
	    		
	    		for (LAT_MX_Region__c region :trigger.newMap.values()){
	    			if (trigger.oldMap.get(region.id).LAT_MX_KAM__c != region.LAT_MX_KAM__c){
	    				regionNewKamIds.put(region.id, region);
	    			}
	    		}

	    		if (!regionNewKamIds.isEmpty()){

	    			LAT_MX_Region.getOwnerAccountsAndSetNewRegion(regionNewKamIds);
	    		}
	    		
	    	}
	    
		}

}