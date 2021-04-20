@isTest
private class ESN_BP_Test {
	
	@isTest static void testInsertBPAndVote() {
		// Initializing custom settings
		initializeCustomSettings();

		// Implement test code
		ESN_Best_Practice__c bp = createBP('Test','Commercial');
		insert bp;

		GetBenefits('all');
		GetBenefits('');
		GetBenefits('Commercial');

		bp.ESN_BP_Actions__c = 'test updated';
		update bp;

		EnrichCurrentUser('Commercial');

		ESN_BP_Vote_WS.WSCheckVote response = CheckGetVote(bp);

		ESN_BP_Vote__c vote = new ESN_BP_Vote__c();
		vote.ESN_BP_Vote_Best_Practice__c = bp.Id;
		insert vote;

		ESN_BP_Test_Tools.deleteMyVotes();
	}
	
	

	private static ESN_Best_Practice__c createBP(String name,
		String category){

		ESN_Best_Practice__c bp = new ESN_Best_Practice__c();
		bp.Name = name;
		bp.ESN_BP_Category__c = category;
		bp.ESN_BP_Actions__c = 'Test';
		bp.ESN_BP_Challenge__c= 'Test';
		bp.ESN_BP_Description__c = 'Test';
		bp.ESN_BP_Results__c = 'Test';
		bp.ESN_BP_Benefit1__c = 'Test benefit';
		bp.ESN_BP_Finalist__c = true;
		bp.ESN_BP_Year__c = 2014;
		bp.ESN_BP_Contributor1_Mail__c = 'ychevreux@chatter.com';
		bp.ESN_BP_Contributor2_Mail__c = 'ychevreux@chatter.com';
		bp.ESN_BP_Contributor3_Mail__c = 'ychevreux@chatter.com';
		bp.ESN_BP_Contributor4_Mail__c = 'ychevreux@chatter.com';
		bp.ESN_BP_Contributor5_Mail__c = 'ychevreux@chatter.com';
		bp.ESN_BP_Contributor6_Mail__c = 'ychevreux@chatter.com';
		bp.ESN_BP_Contributor7_Mail__c = 'ychevreux@chatter.com';
		bp.ESN_BP_Contributor8_Mail__c = 'ychevreux@chatter.com';

		return bp;
	}

	private static ESN_BP_Vote__c createVote(ESN_Best_Practice__c bp){
		ESN_BP_Vote__c vote = new ESN_BP_Vote__c();
		vote.ESN_BP_Vote_Best_Practice__c = bp.Id;

		return vote;
	}

	private static void EnrichCurrentUser(String categories){
		Id userId = UserInfo.getUserId();
		List<User> userList = [SELECT ESN_BP_User_can_vote__c, ESN_BP_Functions__c, Id FROM User WHERE Id=:userId];
		if(userList.size()>0){
			User currentUser = userList[0];
			currentUser.ESN_BP_User_can_vote__c = true;
			currentUser.ESN_BP_Functions__c = categories;
			update currentUser;
		}
	}
	

	private static ESN_BP_Vote_WS.WSCheckVote CheckGetVote(ESN_Best_Practice__c bp) {

		// Initializing custom settings
		ESN_BP_Vote_WS.WSCheckVote response = new ESN_BP_Vote_WS.WSCheckVote();

		//do request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Vote/';  
        req.addParameter('bpId', bp.Id);
       

        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
      
        response = ESN_BP_Vote_WS.doGet();

       	return response;
    }

    private static ESN_BP_Benefits_WS.WSBenefitsList GetBenefits(String function) {

		// Initializing custom settings
		ESN_BP_Benefits_WS.WSBenefitsList response = new ESN_BP_Benefits_WS.WSBenefitsList();

		//do request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ESN_BP_Benefits/';  
        req.addParameter('function', function);
       

        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
      
        response = ESN_BP_Benefits_WS.GetBenefits();

       	return response;
    }

    private static void initializeCustomSettings(){
    	try{
            List<ESN_BP_Settings__c> settings = new List<ESN_BP_Settings__c>();
            settings.add(new ESN_BP_Settings__c(Name='AUTHORIZE_VOTE',Value__c='TRUE'));  
            settings.add(new ESN_BP_Settings__c(Name='DISPLAY_WINNER',Value__c='TRUE'));  
            insert settings;
        }
        catch(Exception e){
        	// No data
        }
    }
}