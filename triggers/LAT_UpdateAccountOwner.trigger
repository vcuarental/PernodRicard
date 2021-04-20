trigger LAT_UpdateAccountOwner on LAT_MasiveOwnerHeader__c (after update) {
	String[] sizes = LAT_GeneralConfigDao.getValueAsStringArray('ACCOUNT_OWNER_UPDATE_Batch', ' ');
    Integer batchSize = sizes != null ?  Integer.valueOf(sizes[0]) : 1;
    System.debug('aaaaaaaaaaaaaaa  entró al trigger');
	if(trigger.isAfter){
		if(trigger.isUpdate){
			for(integer i =0; i < trigger.new.size(); i++){
				if(trigger.new[0].LAT_Status__c == 'Execution' && trigger.old[0].LAT_Status__c == 'Approval' ){
					Database.executeBatch(new LAT_UpdateAccountOwner_Batch(trigger.new[0].Id), batchSize);
					Database.executeBatch(new LAT_UpdateLAT_OpportunityOwner_Batch(trigger.new[0].Id), batchSize);
					Database.executeBatch(new LAT_UpdateLAT_CaseOwner_Batch(trigger.new[0].Id), batchSize);
					Database.executeBatch(new LAT_UpdateContactOwner_Batch(trigger.new[0].Id), batchSize);
					Database.executeBatch(new LAT_UpdateVisitasOwner_Batch(trigger.new[0].Id), batchSize);
					Database.executeBatch(new LAT_UpdateLATContract2Owner_Batch(trigger.new[0].Id), batchSize);
					Database.executeBatch(new LAT_UpdateFiscalNoteOwner_Batch(trigger.new[0].Id), batchSize);
					Database.executeBatch(new LAT_UpdateSellOutColletOwner_Batch(trigger.new[0].Id), batchSize);
					Database.executeBatch(new LAT_UpdateInventarioPOPOwner_Batch(trigger.new[0].Id), batchSize);
					Database.executeBatch(new LAT_ClientChannelSegmOwner_Batch(trigger.new[0].Id), batchSize);
					Database.executeBatch(new LAT_ClientChannelSegmResultOwner_Batch(trigger.new[0].Id), batchSize);

				}
			}

		}
	}
}