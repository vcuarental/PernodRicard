public class ASI_TnE_KR_ClaimHeaderController implements ASI_TnE_KR_MassCreateAndUpdateAbstract {
    ApexPages.StandardController controller;
    
    //public Boolean isEditable {get; set;}
    private static String roleName = [Select Id,UserRole.Name from User where Id=:userinfo.getUserId()].UserRole.Name;
    private static String accounting = 'KR Accounting Team';
    private static Id profileId = userinfo.getProfileId();
    private static String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
    private static String admin = 'System Administrator';
    private Id payee,ap1,ap2,ap3,ap4,ap5;
    private List<ASI_TnE_ClaimHeader__c> listHeader;
    public Integer isEditable {get; set;}
    public Boolean isFAUser {get; set;}
    public Boolean isFAVerifyStep {get; set;}
    public ASI_TnE_KR_ClaimHeaderController thisController { get {return this;} set; }
    
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

    public ASI_TnE_KR_ClaimHeaderController (ApexPages.StandardController stdcontroller){
        controller = stdcontroller;
        claim = (ASI_TnE_ClaimHeader__c)stdcontroller.getRecord();
        payee = [SELECT id,ASI_TnE_KR_Payee_Approver__c FROM ASI_TnE_ClaimHeader__c WHERE id =: claim.Id].ASI_TnE_KR_Payee_Approver__c;
        ap1 = [SELECT id,ASI_TnE_KR_Additional_Approver_1__c FROM ASI_TnE_ClaimHeader__c WHERE id =: claim.Id].ASI_TnE_KR_Additional_Approver_1__c;
        ap2 = [SELECT id,ASI_TnE_KR_Additional_Approver_2__c FROM ASI_TnE_ClaimHeader__c WHERE id =: claim.Id].ASI_TnE_KR_Additional_Approver_2__c;
        ap3 = [SELECT id,ASI_TnE_KR_Additional_Approver_3__c FROM ASI_TnE_ClaimHeader__c WHERE id =: claim.Id].ASI_TnE_KR_Additional_Approver_3__c;
        ap4 = [SELECT id,ASI_TnE_KR_Additional_Approver_4__c FROM ASI_TnE_ClaimHeader__c WHERE id =: claim.Id].ASI_TnE_KR_Additional_Approver_4__c;
        ap5 = [SELECT id,ASI_TnE_KR_Additional_Approver_5__c FROM ASI_TnE_ClaimHeader__c WHERE id =: claim.Id].ASI_TnE_KR_Additional_Approver_5__c;
        //Check if current user is in FA public user group to display JDE interface fields and VAT fields
       // isFAUser = checkIsInFAUserGroup(UserInfo.getUserId());
        
        //Check if current step is FA Verification, to allow FA edit
        isFAVerifyStep = (claim.ASI_TnE_Status__c == 'Approved');
        
        //Check if current step is Open to allow everyone to edit
        //isEditable = (claim.ASI_TnE_Status__c == 'Draft' || claim.ASI_TnE_Status__c == 'Rejected');
        if((claim.ASI_TnE_Status__c == 'Draft'
           || claim.ASI_TnE_Status__c == 'Rejected'
           || profileName == admin)
           &&!Test.isRunningTest())
            isEditable = 1;
        //for TnE card&cash
        else if((claim.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_Cash_Finance_View')
                 ||claim.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_TnE_Finance_View'))
                &&claim.ASI_TnE_Status__c == 'Approved'
                && roleName == accounting)
            isEditable = 2;
        //for Tne card&cash
        else if((claim.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_TnE')
                 ||claim.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_Cash')
                 ||claim.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_Cash_Finance_View')
                 ||claim.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_TnE_Finance_View'))
                &&(claim.ASI_TnE_Status__c == 'Submitted'
                   ||claim.ASI_TnE_Status__c == 'Final'
                   ||claim.ASI_TnE_Status__c == 'Complete'
                   ||claim.ASI_TnE_Status__c == 'Approved'))
            isEditable = 3;
        //for AnP
        else if(claim.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_AnP')
                &&claim.ASI_TnE_Status__c == 'Submitted'
                &&(userInfo.getUserId() == payee
                   ||userInfo.getUserId() == ap1
                   ||userInfo.getUserId() == ap2
                   ||userInfo.getUserId() == ap3
                   ||userInfo.getUserId() == ap4
                   ||userInfo.getUserId() == ap5))
            isEditable = 4;
        //for AnP
        else if((claim.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_AnP_Finance_View')
                 ||claim.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_AnP'))
                &&(claim.ASI_TnE_Status__c == 'Approved'
                   ||claim.ASI_TnE_Status__c == 'Final'
                   ||claim.ASI_TnE_Status__c == 'Complete'
                   ||claim.ASI_TnE_Status__c == 'Submitted'))
            isEditable = 5;
        	
        System.debug('isEditable: ' + isEditable + ' isFA: ' + isFAUser + ' isFAVerifyStep: ' + isFAVerifyStep);
    }
    
    /*private static Boolean checkIsInFAUserGroup(Id userId){        
        Group userGroup = [Select Id, type, RelatedId From Group Where DeveloperName = 'ASI_TnE_KR_Accounting_Review_User'];
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
    }*/
        
        /*public static Set<id> getgroupRoles (Set<ID> groupID)
        {
                Set<ID> groupRoles = new Set<ID>();
                List<Group> groupRoleType = [SELECT ID, Type, developerName, relatedID 
                                                                        FROM Group 
                                                                        WHERE ID IN : groupID 
                                                                        AND (Type = : 'Role' OR Type = : 'RoleAndSubordinates')];
                                                                        
                for (Group i : groupRoleType)
                        groupRoles.add(i.relatedID);
                return groupRoles;
        }*/

//Methods to implement the ASI_MFM_MassCreateAndUpdateAbstract    
    public List<ASI_TnE_KR_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
        return null;
    }
    
     public PageReference mcau_triggerPageBlockAction(ASI_TnE_KR_MassCreateAndUpdateController controller, String actionKey) {
        return null;
    }
    
    public void mcau_triggerActionForSObject(ASI_TnE_KR_MassCreateAndUpdateController controller, String actionKey, sObject sObj) {
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