public with sharing class ESN_BP_Tools {
	
	/**
	*
	*	Function used to remove HTML Tags from a string.
	* 	Some tags can be replaced by \n. They should be defined
	*	in ESN_BP_Statics.SET_HTML_TAGS_TO_REPLACE_CRLF
	*
	*/

	private static String ReplaceHTMLTags(String html){
		String result = html;

		if(String.isNotEmpty(html)){
			result = result.replaceAll('<li>', '-');

			result = result.replaceAll('&amp;', '&');
			result = result.replaceAll('&gt;', '>');
			result = result.replaceAll('&lt;', '<');

			//first replace all <BR> tags with \n to support new lines
			for(String tagToReplace : ESN_BP_Statics.SET_HTML_TAGS_TO_REPLACE_CRLF){
				result = result.replaceAll(tagToReplace, '\r\n');
			}


			//regular expression to match all HTML/XML tags
			string HTML_TAG_PATTERN = '<.*?>';

			// compile the pattern     
			pattern myPattern = pattern.compile(HTML_TAG_PATTERN);

			// get your matcher instance
			matcher myMatcher = myPattern.matcher(result);

			//remove the tags     
			result = myMatcher.replaceAll('');
		}
		
		

		return result;

	}

	/**
	*	Method used to copy Rich text to another field and remove HTML tags
	*/
	public static void CopyRichTextFields(List<ESN_Best_Practice__c> listBP){
		for(ESN_Best_Practice__c bp : listBP){
			if(String.isNotEmpty(bp.ESN_BP_Actions__c)){
				bp.ESN_BP_Actions_Text__c = ReplaceHTMLTags(bp.ESN_BP_Actions__c);
			}
				
			if(String.isNotEmpty(bp.ESN_BP_Actions__c)){
				bp.ESN_BP_Challenge_Text__c = ReplaceHTMLTags(bp.ESN_BP_Challenge__c);
			}

			if(String.isNotEmpty(bp.ESN_BP_Actions__c)){
				bp.ESN_BP_Description_Text__c = ReplaceHTMLTags(bp.ESN_BP_Description__c);
			}

			if(String.isNotEmpty(bp.ESN_BP_Actions__c)){
				bp.ESN_BP_Results_Text__c = ReplaceHTMLTags(bp.ESN_BP_Results__c);
			}
		}
	}

	/**
	*	Function that returns distinct Benefits for a function
	*/
	public static String GetBenefitsFromFunction(String function){
		String resultString='';
		Set<String> resultSet = new Set<String>();
		String tempBenefits;
		List<ESN_Best_Practice__c> bps = new List<ESN_Best_Practice__c>();

		if(function.equalsIgnoreCase('all')){
			bps = [SELECT ESN_BP_Benefits__c FROM ESN_Best_Practice__c WHERE ESN_BP_current_year__c = TRUE];
		}else{
			bps = [SELECT ESN_BP_Benefits__c FROM ESN_Best_Practice__c WHERE ESN_BP_Category__c=:function AND ESN_BP_current_year__c = TRUE];
		}	 

		if(bps.size()>0){
			for(ESN_Best_Practice__c bp : bps){
				tempBenefits = bp.ESN_BP_Benefits__c;
				if(String.isNotEmpty(tempBenefits)){
					resultSet.addAll(tempBenefits.toUpperCase().split(';'));
				}
			}

			for(String s: resultSet){
				resultString=resultString+s+';';
			}
		}

		return resultString;
	}

	/**
	*
	*/
	public static void UpdateContributorMail(List<ESN_Best_Practice__c> bps){
		
		Set<String> emails = new Set<String>();
		List<User> users = new List<User>();
		Map<String, String> mapMailUserId = new Map<String, String>();

		// 1 Pour chaque BP, on récupère les mails des contributeurs
		for(ESN_Best_Practice__c bp : bps){
			if(String.isNotEmpty(bp.ESN_BP_Contributor1_Mail__c))
				emails.add(bp.ESN_BP_Contributor1_Mail__c);
			if(String.isNotEmpty(bp.ESN_BP_Contributor2_Mail__c))
				emails.add(bp.ESN_BP_Contributor2_Mail__c);
			if(String.isNotEmpty(bp.ESN_BP_Contributor3_Mail__c))
				emails.add(bp.ESN_BP_Contributor3_Mail__c);
			if(String.isNotEmpty(bp.ESN_BP_Contributor4_Mail__c))
				emails.add(bp.ESN_BP_Contributor4_Mail__c);
			if(String.isNotEmpty(bp.ESN_BP_Contributor5_Mail__c))
				emails.add(bp.ESN_BP_Contributor5_Mail__c);
			if(String.isNotEmpty(bp.ESN_BP_Contributor6_Mail__c))
				emails.add(bp.ESN_BP_Contributor6_Mail__c);
			if(String.isNotEmpty(bp.ESN_BP_Contributor7_Mail__c))
				emails.add(bp.ESN_BP_Contributor7_Mail__c);
			if(String.isNotEmpty(bp.ESN_BP_Contributor8_Mail__c))
				emails.add(bp.ESN_BP_Contributor8_Mail__c);
		}

		if(emails.size()>0){
			users = [SELECT Id, Username FROM User WHERE Username IN :emails];

			// 2 Faire une map sur le mail
			if(users.size()>0){
				for(User currentUser : users){
					mapMailUserId.put(currentUser.Username, currentUser.Id);
				}
			}

			// 3 Remplir le champ Actor
			for(ESN_Best_Practice__c bp : bps){
				if((String.isNotEmpty(bp.ESN_BP_Contributor1_Mail__c))&&(String.isNotEmpty(mapMailUserId.get(bp.ESN_BP_Contributor1_Mail__c))))
					bp.ESN_BP_Actor1__c = mapMailUserId.get(bp.ESN_BP_Contributor1_Mail__c);
				if((String.isNotEmpty(bp.ESN_BP_Contributor2_Mail__c))&&(String.isNotEmpty(mapMailUserId.get(bp.ESN_BP_Contributor2_Mail__c))))
					bp.ESN_BP_Actor2__c = mapMailUserId.get(bp.ESN_BP_Contributor2_Mail__c);
				if((String.isNotEmpty(bp.ESN_BP_Contributor3_Mail__c))&&(String.isNotEmpty(mapMailUserId.get(bp.ESN_BP_Contributor3_Mail__c))))
					bp.ESN_BP_Actor3__c = mapMailUserId.get(bp.ESN_BP_Contributor3_Mail__c);
				if((String.isNotEmpty(bp.ESN_BP_Contributor4_Mail__c))&&(String.isNotEmpty(mapMailUserId.get(bp.ESN_BP_Contributor4_Mail__c))))
					bp.ESN_BP_Actor4__c = mapMailUserId.get(bp.ESN_BP_Contributor4_Mail__c);
				if((String.isNotEmpty(bp.ESN_BP_Contributor5_Mail__c))&&(String.isNotEmpty(mapMailUserId.get(bp.ESN_BP_Contributor5_Mail__c))))
					bp.ESN_BP_Actor5__c = mapMailUserId.get(bp.ESN_BP_Contributor5_Mail__c);
				if((String.isNotEmpty(bp.ESN_BP_Contributor6_Mail__c))&&(String.isNotEmpty(mapMailUserId.get(bp.ESN_BP_Contributor6_Mail__c))))
					bp.ESN_BP_Actor6__c = mapMailUserId.get(bp.ESN_BP_Contributor6_Mail__c);
				if((String.isNotEmpty(bp.ESN_BP_Contributor7_Mail__c))&&(String.isNotEmpty(mapMailUserId.get(bp.ESN_BP_Contributor7_Mail__c))))
					bp.ESN_BP_Actor7__c = mapMailUserId.get(bp.ESN_BP_Contributor7_Mail__c);
				if((String.isNotEmpty(bp.ESN_BP_Contributor8_Mail__c))&&(String.isNotEmpty(mapMailUserId.get(bp.ESN_BP_Contributor8_Mail__c))))
					bp.ESN_BP_Actor8__c = mapMailUserId.get(bp.ESN_BP_Contributor8_Mail__c);
					
			}
		}
		
	}

}