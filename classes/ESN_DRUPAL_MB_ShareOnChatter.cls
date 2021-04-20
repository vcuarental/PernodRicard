public class ESN_DRUPAL_MB_ShareOnChatter {
	private static String FILE_EXTENSION = '.jpg';
	private static String CONTENT_TYPE = 'image/jpg';

	public static List<CollaborationGroup> group_List = [SELECT Id, Name FROM CollaborationGroup WHERE Id IN (SELECT CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId=:UserInfo.getUserId()) LIMIT 990];

	public String user_Id {get; set;}
	public String user_Photo {get; set;}
	
	public String title {get; set;}
	public String link {get; set;}
	public String thumbnail {get; set;}
	
	public String message{get; set;}
	public String selectedTo{get;set;}
    public String selectedGroup{get;set;}


	public ESN_DRUPAL_MB_ShareOnChatter() {
		user_Id = UserInfo.getUserId();
        user_Photo = getUserPhoto();

		title = ApexPages.currentPage().getParameters().get('Title');
		link = ApexPages.currentPage().getParameters().get('Link');
		thumbnail = ApexPages.currentPage().getParameters().get('Thumbnail');
	
		if (String.isEmpty(title) || String.isEmpty(link) || String.isEmpty(thumbnail)) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ESN_DRUPAL_MB_ErrorMissingParameters));
		}
	}

	public PageReference shareOnChatter() {
       	PageReference pageRef = new PageReference('/' + getSubjectId(selectedTo));
       	String textFixed = '\n\n' + Label.ESN_DRUPAL_MB_DefaultText + '\n';
       	String text = getFinalText(message) + textFixed + link;
		
		HttpRequest req = new HttpRequest();
        req.setEndpoint(thumbnail);
        req.setMethod('GET');
		req.setHeader('Content-Type', CONTENT_TYPE);
		req.setCompressed(true);
        req.setTimeout(120000);
		Http http = new Http();
		HTTPResponse res = http.send(req);

       	ESN_DRUPAL_MB_ConnectApiHelper.postFeedItemWithMentions(null, getSubjectId(selectedTo), text, title, title + FILE_EXTENSION, res.getBodyAsBlob());
       	return pageRef;
    }
	
	public String getFinalText (String text) {
		Pattern p = Pattern.compile('@' + Pattern.quote('[') + '(.*?)' + Pattern.quote(']'));
		Matcher m = p.matcher(text);
		List<String> mentionNameList = new List<string>();
		while (m.find()) {
  			mentionNameList.add(m.group(1));
		}

		if(mentionNameList.size() > 0) {
			Map<String, Id> mentionMap = new Map<String, Id>();
			for (User u : [SELECT Id, Name FROM User WHERE Name IN :mentionNameList]) {
	  			mentionMap.put(u.Name, u.Id);
			}
			for (CollaborationGroup cg : [SELECT Id, Name FROM CollaborationGroup WHERE Name IN :mentionNameList]) {
	  			mentionMap.put(cg.Name, cg.Id);
			}
	
			p = Pattern.compile('@' + Pattern.quote('[') + '(.*?)' + Pattern.quote(']'));
			m = p.matcher(text);
			while (m.find()) {
	  			text = text.replace(m.group(), '{' + mentionMap.get(m.group(1)) + '}');
			}
		}
    	return text;
    }
    
    public String getSubjectId(String value) {
        String subject_Id;
        if (value == 'My Followers') {
            subject_Id = UserInfo.getUserId();
        }
        else if (value == 'A Group') {
            subject_Id = selectedGroup;
        }
        return subject_Id;
    }
    
    public String getUserPhoto() {
    	ConnectApi.Photo photo = ConnectApi.ChatterUsers.getPhoto(null, UserInfo.getUserId()); 
    	return photo.largePhotoUrl;
    }

    public List<SelectOption> getShareTo() {
        List<SelectOption> optns = new List<Selectoption>();
        optns.add(new selectOption('My Followers', 'My Followers'));
        optns.add(new selectOption('A Group', 'A Group'));
        return optns;
	}
    
    public List<SelectOption> getGroups() {
        List<SelectOption> optns = new List<Selectoption>();
        optns.add(new selectOption('', ''));
        for(CollaborationGroup obj : group_List){
           optns.add(new selectOption(obj.Id, obj.Name));
        }            
	    return optns;
	}
}