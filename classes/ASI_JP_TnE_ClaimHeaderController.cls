public class ASI_JP_TnE_ClaimHeaderController implements ASI_JP_TnE_MassCreateAndUpdateAbstract {
    ApexPages.StandardController controller;
    
    public Boolean isEditable {get; set;}
    public Boolean isFAUser {get; set;}
    public Boolean isFAVerifyStep {get; set;}
    public ASI_JP_TnE_ClaimHeaderController thisController { get {return this;} set; }
    
    public string dynamicAttributeFieldsPixels {get; set;}
     
    ASI_TnE_ClaimHeader__c claim = new ASI_TnE_ClaimHeader__c();
    
    // Method for testing a hidden field functionality 
    public PageReference dummyMethod(){
        System.debug('myString: ' + dynamicAttributeFieldsPixels);
        return null;
    }
    
    public String getUserLanguage()
    {
        return UserInfo.getLanguage();
    }

    public ASI_JP_TnE_ClaimHeaderController (ApexPages.StandardController stdcontroller){
        controller = stdcontroller;
        claim = (ASI_TnE_ClaimHeader__c)stdcontroller.getRecord();
        
        //Check if current user is in FA public user group to display JDE interface fields and VAT fields
        isFAUser = checkIsInFAUserGroup(UserInfo.getUserId());
        
        //Check if current step is FA Verification, to allow FA edit
        isFAVerifyStep = (claim.ASI_TnE_Status__c == 'Approved');
        
        //Check if current step is Open to allow everyone to edit
        isEditable = (claim.ASI_TnE_Status__c == 'Draft');
        
        System.debug('isEditable: ' + isEditable + ' isFA: ' + isFAUser + ' isFAVerifyStep: ' + isFAVerifyStep);
    }
    
    private static Boolean checkIsInFAUserGroup(Id userId){        
        Group userGroup = [Select Id, type, RelatedId From Group Where DeveloperName = 'ASI_JP_TnE_Accounting_Review_User'];
        List<GroupMember> faGroupMember = [Select UserOrGroupId From GroupMember Where GroupId = :userGroup.Id];
        
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String roleType = Schema.SObjectType.UserRole.getKeyPrefix();
    	String groupType = Schema.SObjectType.Group.getKeyPrefix();
    	
    	Set<ID> groupIds = new set<ID>();
    	Set<ID> roleORuserIDS = new Set<ID>();
    	
    	for (GroupMember i : faGroupMember)
    	{
    		if(((String)i.UserOrGroupId).startsWith(groupType))
    			groupIds.add(i.UserOrGroupId);
    		else
    			roleORuserIDS.add(i.UserOrGroupId);
    	}
        
        Set<ID> temporaryRolesID = getgroupRoles(groupIds);
        
        for (ID i : temporaryRolesID)
        	roleORuserIDS.add(i);
        
        Boolean result = false;
        
        
        System.debug('CurrentUID: ' + userId + ' FAGroupUIDs: ' + roleORuserIDS);
        
        for (id i : roleORuserIDS)
        {
            if (userId == i  || userInfo.getUserRoleId() == i){ 
                result = true;
                System.debug('Found FA User');  
                break;
            }   
        }
        return result;
    }
	
	public static Set<id> getgroupRoles (Set<ID> groupID)
	{
		Set<ID> groupRoles = new Set<ID>();
		List<Group> groupRoleType = [SELECT ID, Type, developerName, relatedID 
									FROM Group 
									WHERE ID IN : groupID 
									AND (Type = : 'Role' OR Type = : 'RoleAndSubordinates')];
									
		for (Group i : groupRoleType)
			groupRoles.add(i.relatedID);
		return groupRoles;
	}

//Methods to implement the ASI_MFM_MassCreateAndUpdateAbstract    
    public List<ASI_JP_TnE_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
        return null;
    }
    
     public PageReference mcau_triggerPageBlockAction(ASI_JP_TnE_MassCreateAndUpdateController controller, String actionKey) {
        return null;
    }
    
    public void mcau_triggerActionForSObject(ASI_JP_TnE_MassCreateAndUpdateController controller, String actionKey, sObject sObj) {
    }
    
    public void setComponentController(ASI_TnE_ComponentInterface cController) {
        this.componentControllerMap.put(DEF_CC_KEY, cController);
    }
    public void setComponentController(String key, ASI_TnE_ComponentInterface cController) {
        System.debug('ASI_TnE_ClaimHeaderController setComponentController(String key, ASI_TnE_ComponentInterface cController): ' + key + ' ' + cController);
        this.componentControllerMap.put(key, cController);
    }
    
    private static String DEF_CC_KEY = 'DEFAULT';
    private Map<String, ASI_TnE_ComponentInterface> componentControllerMap = new Map<String, ASI_TnE_ComponentInterface>();
    
    public ASI_TnE_ComponentInterface getComponentController() {
        return this.componentControllerMap.get(DEF_CC_KEY);
    }
    
    public ASI_TnE_ComponentInterface getComponentController(String key) {
        return this.componentControllerMap.get(key);
    }
}