trigger ESN_BP_News_Trigger on ESN_BP_News__c (after insert,after update) {
	if(Trigger.isInsert){
		ESN_BP_News_Services.getActivatedInsertedNews(Trigger.new);
	}
	if(Trigger.isUpdate){
		ESN_BP_News_Services.getActivatedUpdatedNews(Trigger.oldMap, Trigger.newMap);
	}

}