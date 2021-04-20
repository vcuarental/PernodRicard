public with sharing class ESN_chatterDAM_ShareAsset {
    
    public static String DAM_URL = Label.ESN_chatterDAM_DamUrl;
    public static String SSO_URL = Label.ESN_chatterDAM_SsoUrl;
    public static List<CollaborationGroup> group_List = [SELECT Id, Name FROM CollaborationGroup WHERE Id IN (SELECT CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId=:UserInfo.getUserId()) LIMIT 990];
    
    public String asset_Url {get; set;}
    public String asset_Id {get; set;}
    public String asset_Name {get; set;}
    public String asset_Thumbnail_Url {get; set;}
    public String asset_MidRes_Url {get; set;}
    public blob asset_MidRes_Encoded {get; set;}
    public String message{get; set;}
    public List<String> session {get; set;}
    public String user_Id {get; set;}
    public String user_Photo {get; set;}
    public String selectedTo{get;set;}
    public String selectedGroup{get;set;}
    
    
    public ESN_chatterDAM_ShareAsset() {
    	session = ESN_chatterDAM_DamApiCallout.authentication();
    	user_Id = UserInfo.getUserId();
        user_Photo = getUserPhoto();
        asset_Url = System.currentPageReference().getParameters().get('AssetId');
        if (!asset_Url_IsEmpty(asset_Url))
        {
            asset_Id = getAssetId(asset_Url);
            try {
            	List<String> assetData = ESN_chatterDAM_DamApiCallout.getAssetData(asset_Id, session);
            	asset_Name = getAssetName(assetData[0]);
            	asset_Thumbnail_Url = DAM_URL + assetData[1];
            	asset_MidRes_Url = DAM_URL + assetData[2];
            } catch (Exception e) {
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ESN_chatterDAM_ErrorDataNotFound));
        	}
            system.debug('asset_Name: ' + asset_Name);
            system.debug('asset_Thumbnail_Url: ' + asset_Thumbnail_Url);
            system.debug('asset_MidRes_Url: ' + asset_MidRes_Url);
        }
    }
    
    public PageReference postAssetOnChatter() {
        if(!asset_Url_IsEmpty(asset_Url)) {
        	PageReference pageRef = new PageReference('/' + getSubjectId(selectedTo));
        	asset_MidRes_Encoded = ESN_chatterDAM_DamApiCallout.encodeAsset_MidRes(asset_MidRes_Url, session);	
        	
        	String link = SSO_URL + asset_Url;
        	String textFixed = '\n\n' + Label.ESN_chatterDAM_Text + '\n';
        
        	String text = getFinalText(message) + textFixed + link;
        	String asset_Filename = asset_Name + '.jpg';
        
        	ESN_chatterDAM_ConnectApiHelper.postFeedItemWithMentions(null, getSubjectId(selectedTo), text, asset_Name, asset_Filename, asset_MidRes_Encoded);
        
        	return pageRef;
        } else {
        	return null;
        }
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
    
    public static String getAssetId(String url) {
        String assetId;
        Pattern p = Pattern.compile('item' + '([0-9]+)') ;
        Matcher m = p.matcher(url) ;  
        if (m.find()) {  
            assetId = m.group(1);  
        }
        return assetId; 
    }
     
    public static String getAssetName(String name) {
        String assetName = name;
        if (name.contains('.')) {
            Integer index= name.lastIndexOf('.');
            assetName = name.substring(0, index);
        }
        return assetName;   
    }
    
    public Boolean asset_Url_IsEmpty(String url) {
         Boolean url_IsEmpty= false;
         if (url == null || url == '' || url.trim().length() == 0) {
             url_IsEmpty = true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ESN_chatterDAM_ErrorUrlNotFound));
         }
         return url_IsEmpty;
    }
    
}