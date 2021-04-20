public with sharing class LAT_ProcessesNotifications {
	public LAT_ProcessesNotifications() {
		
	}

	public static ConnectApi.BatchInput generateChatterPost(String UserGroupId, List<String> mentions, String postText, String refObj){
		ConnectApi.BatchInput batchInput = null;
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();

        if(UserGroupId != ''){
	        input.subjectId = UserGroupId;
	          
	        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
	        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
	          
	        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
	       	textSegment.text = postText + '\n\n';

	       	if(refObj != ''){
	       		textSegment.text +=  URL.getSalesforceBaseUrl().toExternalForm() + '/' + refObj + '\n\n';
	       	}
	       	messageInput.messageSegments.add(textSegment );


	        for(String mentionId : mentions){
	        	ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
	      		mentionSegment.id = mentionId;
	      		messageInput.messageSegments.add(mentionSegment);
	      		
		      	textSegment = new ConnectApi.TextSegmentInput();
	       		textSegment.text = '\n';
	      		messageInput.messageSegments.add(textSegment);
	      	}

	      	
	       	input.body = messageInput;
	              
	       	batchInput = new ConnectApi.BatchInput(input);
	       	
       
       	}
       	return batchInput;
	}

	public static void post(List<ConnectApi.BatchInput> posts){
		try{
			if(posts != null && posts.size()>0){
				ConnectApi.ChatterFeeds.postFeedElementBatch(null, posts);
			}
		}catch(Exception ex){
			LAT_DebugUtil debugUtil = new LAT_DebugUtil();
            debugUtil.addData('Exception:' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
            debugUtil.setOrigin('MATERIAL POP');
            debugUtil.insertDebug();
		}
	}

}