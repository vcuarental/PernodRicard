@RestResource(urlMapping='/Vote/*')
global with sharing class ESN_BP_Vote_WS {

	@HttpGet
	  global static WSCheckVote doGet() {
	    
	  	Boolean result = false;
	  	WSCheckVote checkVote = new WSCheckVote();
	  	checkVote.canVote = false;
	  	checkVote.displayWinner = ESN_BP_Vote_Tools.DisplayWinner();

	    String bpID = RestContext.request.params.get('bpId');

	    
    	List<ESN_Best_Practice__c> bps = [SELECT Id, ESN_BP_Category__c, ESN_BP_Finalist__c from ESN_Best_Practice__c WHERE Id =: bpId];

	    if(bps.size()>0){
	    	ESN_Best_Practice__c bp = bps[0];
	    	checkVote.canVote = ESN_BP_Vote_Tools.CheckCurrentUserCanVote(bp);
	    	checkVote.bpId = bp.Id;
	    }
	    return checkVote;
	  }

	  global class WSCheckVote{
	  	Id bpId;
	  	Boolean canVote;
	  	Boolean displayWinner;
	  }

}