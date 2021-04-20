public class ASI_TnE_KR_PD_ClaimHeaderController implements ASI_TnE_KR_MassCreateAndUpdateAbstract{
    ApexPages.StandardController controller;
    
    public Boolean isEditable {get; set;}
    public Boolean isSalesman {get; set;}
    public ASI_TnE_KR_PD_ClaimHeaderController thisController { get {return this;} set; }
    public string dynamicAttributeFieldsPixels {get; set;}
     
    ASI_TnE_Proxy_Driving_Request__c claim = new ASI_TnE_Proxy_Driving_Request__c();
    
    public String getUserLanguage()
    {
        return UserInfo.getLanguage();
    }

    public ASI_TnE_KR_PD_ClaimHeaderController (ApexPages.StandardController stdcontroller){
        controller = stdcontroller;
        claim = (ASI_TnE_Proxy_Driving_Request__c)stdcontroller.getRecord();
               
       //Check if current step is Open to allow everyone to edit
        isEditable = (claim.ASI_TnE_KR_PD_Status__c == 'Draft' || claim.ASI_TnE_KR_PD_Status__c == 'Rejected');
        isSalesman = [SELECT ASI_eForm_Employee_Is_Salesman__c FROM ASI_eForm_HR_MDM__c WHERE Name =: claim.ASI_TnE_Requester_ID__c].ASI_eForm_Employee_Is_Salesman__c;
        System.debug('isEditable: ' + isEditable);
    }
        
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