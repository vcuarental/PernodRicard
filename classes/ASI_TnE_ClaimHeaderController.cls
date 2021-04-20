public class ASI_TnE_ClaimHeaderController implements ASI_TnE_MassCreateAndUpdateAbstract {
    ApexPages.StandardController controller;
    
    public Boolean isEditable {get; set;}
    public Boolean isFAUser {get; set;}
    public Boolean isFAVerifyStep {get; set;}
    public ASI_TnE_ClaimHeaderController thisController { get {return this;} set; }
    
    ASI_TnE_ClaimHeader__c claim = new ASI_TnE_ClaimHeader__c();

    public ASI_TnE_ClaimHeaderController (ApexPages.StandardController stdcontroller){
        controller = stdcontroller;
        claim = (ASI_TnE_ClaimHeader__c)stdcontroller.getRecord();
        
        //Check if current user is in FA public user group to display JDE interface fields and VAT fields
        isFAUser = checkIsInFAUserGroup(UserInfo.getUserId());
        
        //Check if current step is FA Verification, to allow FA edit
        isFAVerifyStep = (claim.ASI_TnE_Status__c == 'Waiting for Finance Verification');
        
        //Check if current step is Open to allow everyone to edit
        if (claim.ASI_TnE_Status__c == 'Open' || claim.ASI_TnE_Status__c == 'Release'){
            isEditable = true;
        }
        else {
            isEditable = false;
        }
        
        
        System.debug('isEditable: ' + isEditable + ' isFA: ' + isFAUser + ' isFAVerifyStep: ' + isFAVerifyStep);
    }
    
    private static Boolean checkIsInFAUserGroup(Id userId){        
        Group userGroup = [Select Id From Group Where DeveloperName = 'ASI_TnE_VN_Finance_Review_User'];
        List<GroupMember> faGroupMember = [Select UserOrGroupId From GroupMember Where GroupId = :userGroup.Id];
        Boolean result = false;
        
        System.debug('CurrentUID: ' + userId + ' FAGroupUIDs: ' + faGroupMember);
        
        for (GroupMember g:faGroupMember){
            if (userId == g.UserOrGroupId){
                result = true;
                System.debug('Found FA User');
                break;
            }
        }
        return result;
    }


//Methods to implement the ASI_MFM_MassCreateAndUpdateAbstract

    
    public List<ASI_TnE_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
        return null;
    }
    
     public PageReference mcau_triggerPageBlockAction(ASI_TnE_MassCreateAndUpdateController controller, String actionKey) {
        return null;
    }
    
    public void mcau_triggerActionForSObject(ASI_TnE_MassCreateAndUpdateController controller, String actionKey, sObject sObj) {
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