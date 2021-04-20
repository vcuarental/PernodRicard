trigger LAT_MasiveAccountOwnerUpdate_Batch on LAT_MasiveOwnerHeader__c (after update) {
	String[] sizes = LAT_GeneralConfigDao.getValueAsStringArray('ACCOUNT_OWNER_UPDATE_Batch', ' ');
    Integer batchSize = sizes != null ?  Integer.valueOf(sizes[0]) : 1;

	if(trigger.isAfter){
		if(trigger.isUpdate){
			for(integer i =0; i < trigger.new.size(); i++){
				if(trigger.new[0].LAT_Status__c == 'Execution' && trigger.old[0].LAT_Status__c == 'Approval' ){
					 Database.executeBatch(new LAT_UpdateCreditLimit_Batch(trigger.new[0].Id), batchSize);
				}
			}

		}
	}
}