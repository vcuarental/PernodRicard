public with sharing class PJ_ByFor_Clients {
	
	// defaults get and set methods
	public String showParam{get;set;}
	public Integer thePageParam{get;set;}
	public String accountNameParam{get;set;}
	public String accountNamePrefixParam{get;set;}
	public String companyName{get; set;}
	
	// Defaults sortOrder by CreatedDate and descendant 
    private String sortOrder = 'CreatedDate'; 
    private String sortOrderbis = ''; 
    private Boolean isAsc = false;
    public ObjectPermissions userPermission{get;set;}
	// test  
	String[] countries = new String[]{};
	
 	
	// The default init method
	public void init()
	{
		showParam = '';
		accountNameParam = '';
		accountNamePrefixParam = '';
		
		/*
		userPermission = [SELECT Id, SObjectType, PermissionsRead, PermissionsCreate
		FROM ObjectPermissions
		WHERE parentid in (select id from permissionset where
		PermissionSet.ProfileId =:Userinfo.getProfileId()) and sobjectType = 'PJ_ByFor_Client__c'];*/
		/*userPermission = [SELECT Id, SObjectType, PermissionsRead, permissionsCreate, Parent.label, Parent.IsOwnedByProfile
							FROM ObjectPermissions
							WHERE (ParentId
							IN (SELECT PermissionSetId
							FROM PermissionSetAssignment
							WHERE Assignee.Id =:UserInfo.getUserId()))
							AND
							(SobjectType = 'PJ_ByFor_Client__c')];*/
							
							
							
							
					
		userPermission = new ObjectPermissions(PermissionsRead=false,permissionsCreate=false,permissionsEdit=false);
	for(ObjectPermissions p:[SELECT Id, SObjectType, PermissionsRead, permissionsCreate, permissionsEdit,Parent.label, Parent.IsOwnedByProfile
				  FROM ObjectPermissions
				  WHERE (ParentId
				  IN (SELECT PermissionSetId
				  FROM PermissionSetAssignment
				  WHERE Assignee.Id =:UserInfo.getUserId()))
				  AND
				  (SobjectType = 'PJ_ByFor_Client__c')])
	{
		if(p.PermissionsRead)
		
			userPermission.PermissionsRead = true;
		if(p.permissionsCreate)
		
			userPermission.permissionsCreate = true;
			
		if(p.permissionsEdit)
			userPermission.permissionsEdit = true;
	}
						
	}
	

	
	// Do search action from the account name entered
	public pageReference doSearchName()
	{
		System.Debug('##### DoSearch #####');
		system.debug('Input Parameter: ' + accountNameParam);// this will show the value of mysearchtext
		clientsSet = null;
		accountNamePrefixParam = '';
		return null;
	}
	
	public pageReference doSearch()
	{
		System.Debug('##### DoSearch #####'); 
		system.debug('Input Parameter: ' + accountNamePrefixParam);// this will show the value of mysearchtext
		accountNameParam = '';
		clientsSet = null;
		return null;
	}
	
	
	
	// Clients set methods (load all the clients and the related  fields)  
	public ApexPages.StandardSetController clientsSet {
        get {
            if(clientsSet == null || accountNameParam != '' || accountNamePrefixParam != '') {
            	System.Debug('##### clientset');
            	system.debug('Input accountNameParam: ' + accountNameParam);// this will show the value of mysearchtext
            	system.debug('Input accountNamePrefixParam: ' + accountNamePrefixParam);// this will show the value of mysearchtext
                String queryString = 'select Id, Name, PJ_ByFor_Status__c, PJ_ByFor_City_of_residence__c, PJ_ByFor_Phone_del__c, PJ_ByFor_Email__c, CreatedDate, PJ_ByFor_Subsidiary__c, PJ_ByFor_First_Contact_Date__c, tolabel(PJ_ByFor_Country_residence__c),PJ_ByFor_Latest_Situation_Update__c, PJ_ByFor_Salutation__c,PJ_ByFor_First_name__c,PJ_ByFor_Latest_Situation_Update_Date__c from PJ_ByFor_Client__c';
                
                // Search set database request
                if(accountNameParam != '')
                {
                	System.Debug('##### accountNameParam');
                	system.debug('Input Parameter: ' + accountNameParam);// this will show the value of mysearchtext
                	//queryString += ' where Name like \'%' + accountNameParam + '%\'';
                	queryString += ' where Name like \'%' + accountNameParam + '%\'';
            	}
            	 if(accountNamePrefixParam != '')
                {
                	System.Debug('##### accountNameParam');
                	system.debug('Input Parameter: ' + accountNamePrefixParam);// this will show the value of mysearchtext
                	//queryString += ' where Name like \'%' + accountNameParam + '%\'';
                	queryString += ' where Name like \'' + accountNamePrefixParam + '%\'';
            	}
            	
            	
            	if (isAsc) {
            		queryString += ' order by ' + sortOrder + ' asc ';
            	
            	}
            	
            	else {
            		queryString += ' order by ' + sortOrder + ' desc ';
            	}
            	
            	
            	

            	System.Debug('##### clientset blabla ' + queryString);
                clientsSet = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                // sets the number of records in each page set
                if(showParam != '')
                	clientsSet.setPageSize(Integer.valueOf(showParam));
            }
            System.Debug('##### clientSet 2');
            clearSearchParam();
            
            
            return clientsSet;
            
        }
        set;
    }
    
    public pageReference sortByName() {
    	this.sortOrder = 'PJ_ByFor_First_name__c,Name';
    	this.isAsc = !this.isAsc;
    	
    	clientsSet = null;
		return null;
    }
    
    public pageReference sortByContactDate() {
        this.sortOrder = 'PJ_ByFor_First_Contact_Date__c';
        this.isAsc = !this.isAsc;
        
        clientsSet = null;
		return null;
    }
    
    
    public pageReference sortByCountryOfresidence() {
        this.sortOrder = 'PJ_ByFor_City_of_residence__c, PJ_ByFor_Country_residence__c';
        this.isAsc = !this.isAsc;
        
        clientsSet = null;
		return null;
    }
    
    
    public pageReference sortByLastSituationUpdate() {
        this.sortOrder = 'PJ_ByFor_Latest_Situation_Update__c, PJ_ByFor_Latest_Situation_Update_Date__c';
        this.isAsc = !this.isAsc;
        
        clientsSet = null;
		return null;
    }
    
    
    public void clearSearchParam(){
    
    	accountNameParam = '';
    	accountNamePrefixParam = '';
    }

	// default call to get clients lists
    public List<PJ_ByFor_Client__c> getclients()
    {
    	System.Debug('##### getclients');
        return (List<PJ_ByFor_Client__c>)clientsSet.getRecords();
    }
}