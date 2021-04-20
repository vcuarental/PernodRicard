public with sharing class PJ_ByFor_ClientDetail {
    private final PJ_ByFor_Client__c client;
    public String companyName{get; set;}
    public ObjectPermissions userPermissionClient{get;set;}
    public ObjectPermissions userPermissionXp{get;set;}
    
    public PJ_ByFor_ClientDetail(ApexPages.StandardController stdController)
    {
    	//stdController.addFields(new List<String>{'Owner.CompanyName'});
        this.client = (PJ_ByFor_Client__c)stdController.getRecord();
        List<User> userList = [Select Id, CompanyName from User where Id =:client.owner.Id];
        
        try{
        	User u = userList.get(0);
        	companyName = u.CompanyName;
        }catch(Exception e){}
        
        			
		userPermissionClient = new ObjectPermissions(PermissionsRead=false,permissionsCreate=false,permissionsEdit=false);
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
			
				userPermissionClient.PermissionsRead = true;
			if(p.permissionsCreate)
			
				userPermissionClient.permissionsCreate = true;
				
			if(p.permissionsEdit)
				userPermissionClient.permissionsEdit = true;
		}
	
		userPermissionXp = new ObjectPermissions(PermissionsRead=false,permissionsCreate=false,permissionsEdit=false);
		for(ObjectPermissions p:[SELECT Id, SObjectType, PermissionsRead, permissionsCreate, permissionsEdit,Parent.label, Parent.IsOwnedByProfile
					  FROM ObjectPermissions
					  WHERE (ParentId
					  IN (SELECT PermissionSetId
					  FROM PermissionSetAssignment
					  WHERE Assignee.Id =:UserInfo.getUserId()))
					  AND
					  (SobjectType = 'PJ_ByFor_Experience__c')])
		{
			if(p.PermissionsRead)
			
				userPermissionXp.PermissionsRead = true;
			if(p.permissionsCreate)
			
				userPermissionXp.permissionsCreate = true;
				
			if(p.permissionsEdit)
				userPermissionXp.permissionsEdit = true;
		}


	/*userPermissionClient = [SELECT Id, SObjectType, PermissionsRead, permissionsCreate, permissionsEdit,Parent.label, Parent.IsOwnedByProfile
              FROM ObjectPermissions
              WHERE (ParentId
              IN (SELECT PermissionSetId
              FROM PermissionSetAssignment
              WHERE Assignee.Id =:UserInfo.getUserId()))
              AND
              (SobjectType = 'PJ_ByFor_Client__c')];
			  
	userPermissionXp = [SELECT Id, SObjectType, PermissionsRead, permissionsCreate, permissionsEdit,Parent.label, Parent.IsOwnedByProfile
              FROM ObjectPermissions
              WHERE (ParentId
              IN (SELECT PermissionSetId
              FROM PermissionSetAssignment
              WHERE Assignee.Id =:UserInfo.getUserId()))
              AND
              (SobjectType = 'PJ_ByFor_Experience__c')];*/
    					
    }
    
    

	public List<PJ_ByFor_Experience__c> getExperiences()
    {
        return [select Id, Name, PJ_ByFor_Countries__c, PJ_ByFor_Status__c, CreatedDate, PJ_ByFor_Wishedexperiencedate__c from PJ_ByFor_Experience__c where PJ_ByFor_Client__c=:client.Id order by CreatedDate desc];
    }
}