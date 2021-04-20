global class ESN_BP_Test_Tools {

	webservice static void deleteMyVotes(){
		
		Id userId = UserInfo.getUserId();

		List<ESN_BP_Vote__c> myVotes = [SELECT Id FROM ESN_BP_Vote__c WHERE CreatedByID =:userId];

		if(myVotes.size()>0){
			delete myVotes;
		}
	}

}