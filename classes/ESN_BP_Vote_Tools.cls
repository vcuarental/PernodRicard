public class ESN_BP_Vote_Tools {
	
	/**
	*	Function that adds 'VOTED FOR BP' chatter feed on current user wall'
	*/
	public static void AddVotedOnCurrentUserWall(List<ESN_BP_Vote__c> votes){
		List<FeedItem> posts = new List<FeedItem>();
		String article = 'a';
		for(ESN_BP_Vote__c vote : votes){
			FeedItem post = new FeedItem();
			post.ParentId = UserInfo.getUserId();
			if((vote.ESN_BP_Vote_Function__c.equalsIgnoreCase('IT'))||(vote.ESN_BP_Vote_Function__c.equalsIgnoreCase('Operations'))){
				article = 'an';
			}
			post.Body = 'Voted for '+ article + ' '+ vote.ESN_BP_Vote_Function__c+' Best Practice.';
			posts.add(post);
		}

		if(posts.size()>0){
			insert posts;
		}
	}

	/**
	*	Function that chexks if the current user already voted for a bp of the same function
	*/
	public static Boolean CheckCurrentUserCanVote(ESN_Best_Practice__c bp){

		Boolean result = false;

		if((CheckAuthorizedVote())&&(bp.ESN_BP_Finalist__c)){
			Id userId = UserInfo.getUserId();

			List<User> userList = [SELECT ESN_BP_User_can_vote__c, ESN_BP_Functions__c, Id FROM User WHERE Id=:userId];

			if(userList.size()>0){

				User currentUser = userList[0];
				if((currentUser.ESN_BP_User_can_vote__c)&&
					((currentUser.ESN_BP_Functions__c.containsIgnoreCase(bp.ESN_BP_Category__c))
						||(bp.ESN_BP_Category__c.equalsIgnoreCase(ESN_BP_Statics.MARKETING_FUNCTION)))) {
					List<ESN_BP_Vote__c> lVote = [SELECT Id FROM ESN_BP_Vote__c WHERE CreatedById=:UserInfo.getUserId() AND ESN_BP_Vote_Best_Practice__r.ESN_BP_Category__c =:bp.ESN_BP_Category__c ];

					if(lVote.size()==0){
						result = true;
					}
				}	
			}
		}		
		return result;

	}

	/**
	*
	*	Function that checks if vote for BP is currently authorized.
	*/
	public static Boolean CheckAuthorizedVote(){
		Boolean result = FALSE;
		
		ESN_BP_Settings__c voteSetting = ESN_BP_Settings__c.getValues('AUTHORIZE_VOTE');
		String authorizeVote = voteSetting.Value__c; 

		if((String.isNotEmpty(authorizeVote))&&(authorizeVote.equalsIgnoreCase('TRUE'))){
			result= TRUE;
		}

		return result;
	}

	/**
	*	Function that checks if "winner" button should be displayed
	*/
	public static Boolean DisplayWinner(){
		Boolean result = FALSE;
		ESN_BP_Settings__c voteSettings = ESN_BP_Settings__c.getValues('DISPLAY_WINNER');
		String displayWinner = voteSettings.Value__c;

		if((String.isNotEmpty(displayWinner))&&(displayWinner.equalsIgnoreCase('TRUE'))){
			result = TRUE;
		}
		return result;
	}
}