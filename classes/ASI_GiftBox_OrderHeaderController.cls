public class ASI_GiftBox_OrderHeaderController implements ASI_GiftBox_MassUpsertAbstract  {
    ApexPages.StandardController controller;
    
    public Boolean isEditable {get; set;}
    //public Boolean isFAUser {get; set;}
    //public Boolean isFAVerifyStep {get; set;}
    public ASI_GiftBox_OrderHeaderController thisController { get {return this;} set; }
    
    ASI_GiftBox_Order_Header__c order = new ASI_GiftBox_Order_Header__c();

    public ASI_GiftBox_OrderHeaderController (ApexPages.StandardController stdcontroller){
        controller = stdcontroller;
        order = (ASI_GiftBox_Order_Header__c)stdcontroller.getRecord();
        
        isEditable = true;//(order.ASI_TnE_Status__c == 'Open');

    }
/*    
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
    */
    
    public List<ASI_GiftBox_MassUpsertController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
        return null;
    }
    
     public PageReference mcau_triggerPageBlockAction(Object controller, String actionKey) {
        return null;
    }
    
    public void mcau_triggerActionForSObject(ASI_GiftBox_MassUpsertController controller, String actionKey, sObject sObj) {
    }
    
    public void setComponentController(ASI_GiftBox_ComponentInterface cController) {
        this.componentControllerMap.put(DEF_CC_KEY, cController);
    }
    public void setComponentController(String key, ASI_GiftBox_ComponentInterface cController) {
        System.debug('ASI_TnE_ClaimHeaderController setComponentController(String key, ASI_TnE_ComponentInterface cController): ' + key + ' ' + cController);
        this.componentControllerMap.put(key, cController);
    }
    
    private static String DEF_CC_KEY = 'DEFAULT';
    private Map<String, ASI_GiftBox_ComponentInterface> componentControllerMap = new Map<String, ASI_GiftBox_ComponentInterface>();
    
    public ASI_GiftBox_ComponentInterface getComponentController() {
        return this.componentControllerMap.get(DEF_CC_KEY);
    }
    
    public ASI_GiftBox_ComponentInterface getComponentController(String key) {
        return this.componentControllerMap.get(key);
    }
}