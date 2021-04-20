trigger ESN_BP_Vote_Trigger on ESN_BP_Vote__c (after insert) {

	ESN_BP_Vote_Tools.AddVotedOnCurrentUserWall(Trigger.new);
	
}