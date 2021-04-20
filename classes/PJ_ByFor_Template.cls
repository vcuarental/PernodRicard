public with sharing class PJ_ByFor_Template {
	
	
	 // html language set 
	public string language {get;set;}

	
	/*private Cookie languageCookie;
	
	public pageReference changeFrench(){
		
		language = 'fr';
		languageCookie = new Cookie('lang','fr',null,-1,true);
		ApexPages.currentPage().setCookies(new Cookie[]{languageCookie});
		return null;
	}
	
	public  pageReference changeEnglish(){
		
		language = 'en';
		System.Debug('##### pageReference changeEnglish() #####' + language);
		languageCookie = new Cookie('lang','en',null,-1,true);
		ApexPages.currentPage().setCookies(new Cookie[]{languageCookie});
		return null; 
	}


		// The default init method
	public void initLanguage()
	{
		if(language != null && language != '')
			language = 'en';
		
	}
	
	public PJ_ByFor_Template() {
		languageCookie = ApexPages.currentPage().getCookies().get('lang');
		if (languageCookie == null)
		{
			languageCookie = new Cookie('lang','en',null,-1,true);
			language = 'en';
			ApexPages.currentPage().setCookies(new Cookie[]{languageCookie});
		} else {
			language = String.valueOf(languageCookie.getValue());
		}
	}
	
	// The extension constructor initializes the private member

    // variable acct by using the getRecord method from the standard

    // controller.
    
    
   // public ApexPages.StandardSetController PJ_ByFor_Template {get; set;}

/*
 	public PJ_ByFor_Template(ApexPages.StandardSetController controller) {
        stdCntrlr = controller;
    }
*/


    public Boolean getIsAdmin() 
    {
    	//List<GroupMember> AdminUsers = new List<GroupMember>();
    	String CurrentUserId = userInfo.getUserid();
    	
    	
    	Map<Id, Group> groupMap = new Map<Id, Group>([Select Id, Name From Group Where DeveloperName='PJ_ByFor_System_Administrator']);
    	
    	List<GroupMember> groupMembers = [ Select GroupId, UserOrGroupId From GroupMember Where GroupId In :groupMap.keySet()];
    	
    	Boolean isAdmin = false;
    	
    	//System.Debug('isAdmin value before search ' + isAdmin + ' CurrentUserId' + CurrentUserId );
    	
    	for (GroupMember m : groupMembers) {
    		if (CurrentUserId == m.UserOrGroupId) {
    			isAdmin = true;
    		}
    	}
    	
    	//System.Debug(' isAdmin value after search' + isAdmin);
    	
    	
	    return isAdmin;
	    
    }
	   
}