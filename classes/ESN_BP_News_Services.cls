public with sharing class ESN_BP_News_Services {
	/**
	*	Function that push notifications to users for News that are activated
	*/
	public static void pushNewsNotificationToUserIdSet(List<ESN_BP_News__c> news, Set<Id> userIds){
		// Instantiating variables
		List<String> newsTitle = new List<String>();
		List<String> deviceTokens = new List<String>();
		List<ESN_BP_Device_Token__c> listTokens = new List<ESN_BP_Device_Token__c>();

		// Getting list of device tokens
		if((userIds==null)||(userIds.isEmpty())){
			listTokens = [SELECT ESN_BP_Device_Token__c FROM ESN_BP_Device_Token__c];
		}
		else{
			listTokens = [SELECT ESN_BP_Device_Token__c FROM ESN_BP_Device_Token__c WHERE OwnerId IN :userIds];
		}
		if(listTokens.size()>0){
			
			// Pass true to the constructor for pretty print formatting.
			JSONGenerator gen = JSON.createGenerator(true);
			
			// Gathering news title
			for(ESN_BP_News__c currentNews : news){
				newsTitle.add(currentNews.ESN_BP_News_Title__c);
			}
				
			for(ESN_BP_Device_Token__c token: listTokens) {
			   deviceTokens.add(token.ESN_BP_Device_Token__c);
			}
			// Write data to the JSON string.
			gen.writeStartObject();
			gen.writeObjectField('news', newsTitle);
			gen.writeObjectField('devicetokens', deviceTokens);


			// Get the JSON string.
			String body = gen.getAsString();

			// Call the REST WS to push notifications
			//Set HTTPRequest header properties
			Map<String, String> header = new Map<String, String>();
			header.put('Content-Type', 'application/json');

			// Set HTTP Enpoint
			String endpoint = ESN_BP_Settings__c.getValues('APN_REMOTE_WS_ENDPOINT') != null ? ESN_BP_Settings__c.getValues('APN_REMOTE_WS_ENDPOINT').Value__c : '';
			System.debug('=========> JSON Body');
			System.debug(body);
			System.debug(endpoint);
			ESN_BP_Rest_Request_Tools.REST_Request('POST', endpoint, header, body);
		}
	}

	/**
	*	Function that checks if updated news have been activated and push notifications
	*/
	public static void getActivatedUpdatedNews(Map<Id,ESN_BP_News__c> oldNews,Map<Id,ESN_BP_News__c> updatedNews){
		List<Id> unactivatedNewsId = new List<Id>();
		List<ESN_BP_News__c> newsListToPush = new List<ESN_BP_News__c>();
		// Checking if old news was unactivated and starting date has passed
		for(ESN_BP_News__c currentNews : oldNews.values()){
			if(!(currentNews.ESN_BP_News_Active__c)&&(currentNews.ESN_BP_News_Starting_Date__c<Datetime.Now())){
				unactivatedNewsId.add(currentNews.Id);
			}
		}


		if (unactivatedNewsId.size()>0){
			ESN_BP_News__c updatedNewsItem = new ESN_BP_News__c();
			for(Id newsId : unactivatedNewsId){
				updatedNewsItem = updatedNews.get(newsId);
				if(updatedNewsItem.ESN_BP_News_Active__c){
					newsListToPush.add(updatedNewsItem);
				}
			}
		}

		if (newsListToPush.size()>0){
			pushNewsNotificationToUserIdSet(newsListToPush,null);
		}
	}

	/**
	*	Function that checks if inserted news are activated and push notifications
	*/
	public static void getActivatedInsertedNews(List<ESN_BP_News__c> insertedNews){
		List<ESN_BP_News__c> newsListToPush = new List<ESN_BP_News__c>();
		// Checking if old news was unactivated and starting date has passed
		for(ESN_BP_News__c currentNews : insertedNews){
			if((currentNews.ESN_BP_News_Active__c)&&(currentNews.ESN_BP_News_Starting_Date__c<Datetime.Now())){
				newsListToPush.add(currentNews);
			}
		}

		if (newsListToPush.size()>0){
			pushNewsNotificationToUserIdSet(newsListToPush,null);
		}
	}
}