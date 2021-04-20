public with sharing class PJ_ByFor_ProjectDetail {
    private final PJ_ByFor_Experience__c experience;
    public ObjectPermissions userPermissionXp{get;set;}
    
    
    public PJ_ByFor_ProjectDetail(ApexPages.StandardController stdController)
    {
       if(!Test.isRunningTest()){
    	stdController.addFields(new List<String>{'PJ_ByFor_Step_Number__c','Name'});
           }else{
            System.debug('Running test !');
                    
                }
        this.experience = (PJ_ByFor_Experience__c)stdController.getRecord();
		
		/*userPermissionXp = [SELECT Id, SObjectType, PermissionsRead, permissionsCreate, permissionsEdit,Parent.label, Parent.IsOwnedByProfile
							FROM ObjectPermissions
							WHERE (ParentId
							IN (SELECT PermissionSetId
							FROM PermissionSetAssignment
							WHERE Assignee.Id =:UserInfo.getUserId()))
							AND
							(SobjectType = 'PJ_ByFor_Experience__c')];*/
							
							
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
         
    }

    public List<PJ_ByFor_Experience__History> getExperienceHistory()
    {
        return [select Field, CreatedDate, CreatedBy.FirstName, CreatedBy.LastName, NewValue from PJ_ByFor_Experience__History where ParentId=:experience.Id and Field='PJ_ByFor_Status__c' order by CreatedDate desc];
    }
    

}