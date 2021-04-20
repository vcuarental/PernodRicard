public with sharing class EUR_CRM_FilteredMassChatterController {
	
	private static final Integer PAGE_SIZE = 100;
	public Apexpages.StandardSetController standardSetCon { get; set; }
	public FeedItem myFeedItem { get; set; }
	public String NumOfRecords {
		get{
			return (standardSetCon == null ? '0' : (standardSetCon.getResultSize() > 2000 ? '2000+' :  String.valueof(standardSetCon.getResultSize())) );
		} private set;
	}
	
	public EUR_CRM_FilteredMassChatterController(Apexpages.StandardSetController stdSetCon){
		System.debug('Stdset controller' + stdSetCon);
		standardSetCon = stdSetCon;
		standardSetCon.setPageSize(PAGE_SIZE);
		myFeedItem = new FeedItem();
	}
	
	/*	get a list of EU account from the selected list view filter
	*	if the chatter post is 'content post', upload the first post to FeedItem;
	*	create all the other posts referencing the same version of file used by the first post;
	*	if the chatter post is non-content post (link or text), insert the same text/link content post to all EU accounts.
	*/
	public void massSendChatterPosts(){
		//get filtered acct list
		EUR_CRM_ListViewFilter filter = new EUR_CRM_ListViewFilter(standardSetCon);
		List<EUR_CRM_Account__c> filteredAcctList = Test.isRunningTest() ? EUR_CRM_FilteredMassChatterCtrllerTest.acctlist : filter.getEURAccountListByFilter();
		System.debug('filtered list: ' + filteredAcctList);
		List<FeedItem> fditemlist = new List<FeedItem>();
		FeedItem fstPost;
		for(EUR_CRM_Account__c a : filteredAcctList){
			FeedItem post = createFeedItem(myFeedItem, a, true);
			if(post.Type == 'ContentPost'){
				fstPost = post;
				break;	
			}else
				fditemlist.add(post);
		}
		
		try{
			if(fstPost != null){
				insert fstPost;
				if(filteredAcctList.size() > 1){
					List<FeedItem> fileitemlist = new List<FeedItem>();
					fstPost = [Select RelatedRecordId From FeedItem Where Id =: fstPost.Id];
					for(Integer i=1; i < filteredAcctList.size(); i++){
						FeedItem post = createFeedItem(myFeedItem, filteredAcctList[i], false);
						post.RelatedRecordId = fstPost.RelatedRecordId;
						post.Type = 'ContentPost';
						fileitemlist.add(post);
					}
					insert fileitemlist;
				}
			}
		
			if(!fditemlist.isEmpty())
				insert fdItemlist;
			
			//success message
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.INFO, 'Message has been posted successfully.'));
			myFeedItem = new FeedItem();
		}catch(Exception ex){
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.FATAL, ex.getMessage()));
		}

	}

	private FeedItem createFeedItem(FeedItem item, EUR_CRM_Account__c a, Boolean hasFile){
		FeedItem post = new FeedItem();
		post.ParentId = a.Id;
		post.Body = item.Body;
		if(String.IsNotBlank(item.LinkUrl)){
			post.LinkUrl = item.LinkUrl;
			post.Title = item.Title;
			post.Type = 'LinkPost';
		}
		if(item.ContentData != null && hasFile){
			post.ContentData = item.ContentData;
			post.ContentFileName = item.ContentFileName;
			post.Type = 'ContentPost';
		}
		return post;
	}

	
}