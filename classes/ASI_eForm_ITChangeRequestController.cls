public without sharing class ASI_eForm_ITChangeRequestController implements ASI_eForm_SFObjSelectTableAbstract, ASI_eForm_MassCreateAndUpdateExtAbstract {
    public Integer contextSize{get;set;}
    public ASI_eForm_IT_Change_Request__c itChangeRequest{get; private set;}
    private static string DEF_RT_IT_CHANGE_REQ_ITEM = 'ASI_eForm_IT_Change_Request_Item';
    public string po_filter {get; set;}
    public Boolean isITGroupUser {get;set;}
    public Boolean isBypassGroupUser {get;set;} //Issue #5: Detect the Bypass Group users
    
    public void mcau_triggerActionAfterCommitAll(ASI_eForm_MassCreateAndUpdateController controller)
    {
        
    }
    
    public Boolean mcau_triggerActionBeforeCommitAll(ASI_eForm_MassCreateAndUpdateController controller) 
    {
        Set<String> itChangeRequestItemSet = new Set<String>();                        
        for (ASI_eForm_MassCreateAndUpdateController.RecordTypeElement rtEle : 
          controller.theRecordTypeElementList) {
            for (ASI_eForm_MassCreateAndUpdateController.TableRow tr : rtEle.myRecordList) {                
                String key = ''+tr.mySObj.get('ASI_eForm_Context__c');                
                if (itChangeRequestItemSet.contains(key))
                {
                  ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_eForm_Duplicate_Context_Found);
                  ApexPages.addMessage(errorMessage);                 
                  return false;
                } else
                {
                   itChangeRequestItemSet.add(key); 
                } 
            }
        }        
        return true;        
    }
    
    public ASI_eForm_ITChangeRequestController(ApexPages.StandardSetController controller){
        id pid = apexpages.currentPage().getParameters().get('id');
        itChangeRequest = database.query(ASI_MFM_function.buildQuery('ASI_eForm_IT_Change_Request__c') + ' where id = :pid');
        init_search_with_header_info =' (RecordType.DeveloperName=null OR RecordType.DeveloperName = \'ASI_eForm_HK_Context\') AND ASI_eForm_Inactive__c = False ';
        this.componentControllerMap = new Map<String, ASI_MFM_ComponentInterface>();
        
        List<ASI_eForm_IT_Change_Request_Item__c> itChangeRequests = [select id,ASI_eForm_Context__c from ASI_eForm_IT_Change_Request_Item__c
        where id =: pid];        
 
        /*
        ASI_eForm_SFObjSelectTableController sobjstController = (ASI_eForm_SFObjSelectTableController)this.getComponentController('selectTable');
             
        if (sobjstController != null) {
            sobjstController.setDataFilter('and name = \'Hardware\'');
            sobjstController.reloadData();
        }*/
        
        List<ASI_eForm_Context__c> contexts = [select id from ASI_eForm_Context__c WHERE ASI_eForm_Inactive__c = False];
        contextSize = contexts.size();
        
        isITGroupUser =  isITGroupUser(UserInfo.getUserId());
        isBypassGroupUser = isHKBypassGroupUser(UserInfo.getUserId()); //Issue #5: Detect the Bypass Group users
        
    }
    
    //Issue #5: Detect the Bypass Group users
    private static Boolean isHKBypassGroupUser(Id userId) {         
        
        List<GroupMember> groupMember = [Select UserOrGroupId from GroupMember Where 
        Group.DeveloperName = 'ASI_eForm_HK_Bypass_Group' and UserOrGroupId = :userId];
      
        Boolean result = false;        
                          
        if (groupMember.size() > 0){
             result = true;   
        }
        
     return result;
    }
    
    private static Boolean isITGroupUser(Id userId){        
        
    List<GroupMember> groupMember = [Select UserOrGroupId from GroupMember Where 
    Group.DeveloperName = 'ASI_eForm_Regional_IT_Group' and UserOrGroupId = :userId];
  
    Boolean result = false;        
                      
    if (groupMember.size() > 0){
         result = true;   
    }
        
     return result;
    }
    
    public string init_search_with_header_info {get; private set;}
    private static String DEF_CC_KEY = 'DEFAULT';
    private Map<String, ASI_MFM_ComponentInterface> componentControllerMap; 
    public ASI_eForm_ITChangeRequestController thisController { get {return this;} set; }
    public void setComponentController(ASI_MFM_ComponentInterface cController) {
        this.componentControllerMap.put(DEF_CC_KEY, cController);
    }
    /**
     * Methods to implement the ASI_MFM_SFObjSelectTableAbstract
     */
    public void mcau_triggerActionForSObject(ASI_eForm_MassCreateAndUpdateController controller, String actionKey, sObject sObj) {
        ASI_eForm_IT_Change_Request_Item__c itChangeRequestItem = (ASI_eForm_IT_Change_Request_Item__c)sObj;
        
        if (itChangeRequestItem != null && itChangeRequestItem.ASI_eForm_Context__c != null 
        && actionKey == ASI_eForm_MassCreateAndUpdateController.ACTION_REMOVE_NEW) {
            ASI_eForm_SFObjSelectTableController selectTableC = (ASI_eForm_SFObjSelectTableController)this.getComponentController('selectTable');
            //Revert the "add" button to "0" (0 = Add, 1 = Added) by mould record id (detail.MouldLookup__c)
            if(selectTableC != null)
            {
             selectTableC.setBtnStageBySObjId(itChangeRequestItem.ASI_eForm_Context__c, 'add', 0);
            } 
        }        
        
    }
    
    public void sobjst_triggerActionForSObject(ASI_eForm_SFObjSelectTableController controller, String actionKey, sObject sObj) {
        ASI_eForm_MassCreateAndUpdateController mcauC = (ASI_eForm_MassCreateAndUpdateController)this.getComponentController('massCreateAndUpdate');
        ASI_eForm_Context__c selected_pol = (ASI_eForm_Context__c)sObj;
        
        ASI_eForm_IT_Change_Request_Item__c itChangeRequestItem = new ASI_eForm_IT_Change_Request_Item__c();
        itChangeRequestItem.ASI_eForm_Context__c = selected_pol.id;                      
        mcauC.addNewRowByInfo(DEF_RT_IT_CHANGE_REQ_ITEM, itChangeRequestItem);    
    }
    public List<ASI_eForm_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList() {
        return null;
    }
    
    public Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap() {
        return null;
    }
    
    public List<ASI_eForm_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
        return null;
    }
    
    public PageReference mcau_triggerPageBlockAction(ASI_eForm_MassCreateAndUpdateController controller, String actionKey) {
        return null;
    }
    
    public void setComponentController(String key, ASI_MFM_ComponentInterface cController) {
        this.componentControllerMap.put(key, cController);
    }
    public ASI_MFM_ComponentInterface getComponentController() {
        return this.componentControllerMap.get(DEF_CC_KEY);
    }
    public ASI_MFM_ComponentInterface getComponentController(String key) {
        return this.componentControllerMap.get(key);
    }
}