public class ASI_eForm_UserIDRequestItemController implements  ASI_eForm_MassCreateAndUpdateExtAbstract  {

    private static String DEF_CC_KEY = 'DEFAULT';
    private Map<String, ASI_MFM_ComponentInterface> componentControllerMap;
    public Section3Controller section3Controller {get; set;}
    public Section4Controller section4Controller {get; set;}
    public ASI_eForm_User_ID_Request__c userIDRequest {get; set;}
    public ASI_eForm_UserIDRequestItemController thisController { get {return this;} set; }
    private static string DEF_RT_IT_CHANGE_REQ_ITEM = 'ASI_eForm_User_ID_Request_Item';
    public Boolean isITGroupUser {get;set;}
    public Boolean isBypassGroupUser {get;set;} //Issue #5: Detect the Bypass Group users
    
    public Boolean isNewEmployeeRecordType {get;set;}
    
    // For filtering
    public ASI_eForm_PR_System__c prSystemFilter {get; set;}
    public string init_search {get; private set;}
    public string init_search_default {get; private set;}
    public List<SelectOption> categoryPicklist{get;set;}
    Public string categoryFilter {get; set;}
    
    public ASI_eForm_UserIDRequestItemController(ApexPages.StandardSetController controller){
        this.prSystemFilter = new ASI_eForm_PR_System__c();
        categoryPicklist = new List<SelectOption>();
        categoryPicklist.add(new SelectOption('All','All'));
        List<SelectOption> tempcategoryPicklist = getPicklistValues(prSystemFilter, 'ASI_eForm_Category__c');
        for(SelectOption i : tempcategoryPicklist)
            categoryPicklist.add(i);

        categoryFilter = 'General';
        init_search = ' Name != \'Active Directory User Profile\' AND ASI_eForm_Inactive__c = False ';
        init_search_default = init_search + ' and ASI_eForm_Category__c = \'' + categoryFilter + '\' ';
        this.componentControllerMap = new Map<String, ASI_MFM_ComponentInterface>();
        id pid = apexpages.currentPage().getParameters().get('id');
        userIDRequest = database.query(ASI_MFM_function.buildQuery('ASI_eForm_User_ID_Request__c') + ' where id = :pid');
      
        section3Controller = new Section3Controller(this);
        section4Controller = new Section4Controller(this);
        isITGroupUser =  isITGroupUser(UserInfo.getUserId());
        isBypassGroupUser = isHKBypassGroupUser(UserInfo.getUserId()); //Issue #5: Detect the Bypass Group users
        isNewEmployeeRecordType = isNewEmployeeRecordType(userIDRequest.RecordTypeId);
        
        
    } 

    public static list<SelectOption> getPicklistValues(SObject obj, String fld){
      list<SelectOption> options = new list<SelectOption>();
      // Get the object type of the SObject.
      Schema.sObjectType objType = obj.getSObjectType(); 
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
      // Get a map of fields for the SObject
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
      // Get the list of picklist values for this field.
      list<Schema.PicklistEntry> values =
         fieldMap.get(fld).getDescribe().getPickListValues();
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a : values)
      { 
         options.add(new SelectOption(a.getLabel(), a.getValue())); 
      }
      return options;
     }

    public void FilterPRSystems() {
        string whereStatm = init_search;

        if ((categoryFilter != null || categoryFilter.trim() != '') && categoryFilter != 'All' ) {
            whereStatm += ' and ASI_eForm_Category__c = \'' + categoryFilter + '\' ';
        }
        if (categoryFilter == 'All' ) {
            whereStatm = '';
        }       
                
        ASI_eForm_SFObjSelectTableController sobjstController = (ASI_eForm_SFObjSelectTableController)this.Section3Controller.getComponentController('selectTable');
        if (sobjstController != null) {
            sobjstController.setDataFilter(whereStatm);
            sobjstController.reloadData();
        }           
    }

    private static Boolean isNewEmployeeRecordType(Id recordTypeId)
    {
        Boolean result = false;
        Map<Id,RecordType> newEmployeeRecordType =
          new Map<Id,RecordType>([SELECT Id from RecordType 
          WHERE SobjectType='ASI_eForm_User_ID_Request__c' and DeveloperName like '%New_Employee%']);
        
        if (newEmployeeRecordType.containsKey(recordTypeId))
        {
            result = true;
        }       
       return result;
    }
    
    private static Boolean isITGroupUser(Id userId) {         
        
        List<GroupMember> groupMember = [Select UserOrGroupId from GroupMember Where 
        Group.DeveloperName = 'ASI_eForm_Regional_IT_Group' and UserOrGroupId = :userId];
      
        Boolean result = false;        
                          
        if (groupMember.size() > 0){
             result = true;   
        }
        
     return result;
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
    
    public boolean mcau_triggerActionBeforeCommitAll(ASI_eForm_MassCreateAndUpdateController controller) 
    {
        Set<String> userIDRequestItemSet= new Set<String>(); 
        Set<ID> permissionTypeIds = new Set<ID>();
        Map<ID, ASI_eForm_Permission_Type__c> permissionTypeMap = new Map<ID, ASI_eForm_Permission_Type__c>();
        
        for (ASI_eForm_MassCreateAndUpdateController.RecordTypeElement rtEle : controller.theRecordTypeElementList) 
        {
            for (ASI_eForm_MassCreateAndUpdateController.TableRow tr : rtEle.myRecordList) 
            { 
                if (tr.mySObj.get('ASI_eForm_Permission_TypeN__c') != null)
                {
                    permissionTypeIds.add((ID)tr.mySObj.get('ASI_eForm_Permission_TypeN__c'));
                }
            }
        }
        
        if (permissionTypeIds.size() > 0)
        {
            permissionTypeMap = new Map<ID, ASI_eForm_Permission_Type__c>([SELECT ID, Name, ASI_eForm_Additional_Info_Required__c 
                                                                        FROM ASI_eForm_Permission_Type__c
                                                                        WHERE ID IN : permissionTypeIds AND ASI_eForm_Additional_Info_Required__c = true]);
        }
                
        for (ASI_eForm_MassCreateAndUpdateController.RecordTypeElement rtEle : controller.theRecordTypeElementList) {
            for (ASI_eForm_MassCreateAndUpdateController.TableRow tr : rtEle.myRecordList) {                
                String key = ''+tr.mySObj.get('ASI_eForm_PR_System__c')
                //+tr.mySObj.get('ASI_eForm_System_Privilege__c')
                +tr.mySObj.get('ASI_eForm_Permission_TypeN__c')
                +tr.mySObj.get('ASI_eForm_Permission_Action__c')
                +tr.mySObj.get('ASI_eForm_BO_Additional_Remarks__c') ;
               // (permissionTypeMap.containsKey((ID)tr.mySObj.get('ASI_eForm_Permission_TypeN__c')) ? tr.mySObj.get('ASI_eForm_BO_Additional_Remarks__c') : '');
                
                /*if (permissionTypeMap.containsKey((ID)tr.mySObj.get('ASI_eForm_Permission_TypeN__c')) && (tr.mySObj.get('ASI_eForm_BO_Additional_Remarks__c') == '' || tr.mySObj.get('ASI_eForm_BO_Additional_Remarks__c') == null))
                {
                    ASI_eForm_User_ID_Request_Item__c userIdRequestItemTemp = (ASI_eForm_User_ID_Request_Item__c)tr.mySObj;
                    userIdRequestItemTemp.adderror();
                }*/
                
                if (userIDRequestItemSet.contains(key))
                {
                  ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,Label.ASI_eForm_Duplicate_Permission_Set);
                  /*
                  String.format(,new String[]{String.valueOf(tr.mySObj.get('ASI_eForm_PR_System__c')),
                  String.valueOf(tr.mySObj.get('ASI_eForm_System_Privilege__c')),
                  String.valueOf(tr.mySObj.get('ASI_eForm_Permission_Type__c')) 
                  }));
                  */
                  ApexPages.addMessage(errorMessage);                 
                  return false;
                } else
                {
                   userIDRequestItemSet.add(key); 
                }
            }
        }        
        return true;
    }
    
    public void mcau_triggerActionAfterCommitAll(ASI_eForm_MassCreateAndUpdateController controller) 
    {
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
    
    public void mcau_triggerActionForSObject(ASI_eForm_MassCreateAndUpdateController controller, String actionKey, sObject sObj) {
    
        ASI_eForm_User_ID_Request_Item__c userRequestItem = (ASI_eForm_User_ID_Request_Item__c)sObj;
        //if (userRequestItem != null && userRequestItem.ASI_eForm_Context__c != null && actionKey == ASI_MFM_MassCreateAndUpdateController.ACTION_REMOVE_NEW) {
        //    ASI_MFM_SFObjSelectTableController selectTableC = (ASI_MFM_SFObjSelectTableController)this.getComponentController('selectTable');
        // Revert the "add" button to "0" (0 = Add, 1 = Added) by mould record id (detail.MouldLookup__c)
        //    selectTableC.setBtnStageBySObjId(itChangeRequestItem.ASI_eForm_Context__c, 'add', 0);
        //}
    
    
    }
    
    public void setComponentController(ASI_MFM_ComponentInterface cController) {
        this.componentControllerMap.put(DEF_CC_KEY, cController);
    }
    
    public class Section4Controller implements ASI_eForm_SFObjSelectTableAbstract{
    
        private Map<String, ASI_MFM_ComponentInterface> componentControllerMap;
        ASI_eForm_UserIDRequestItemController outerController;
        
        public Section4Controller (ASI_eForm_UserIDRequestItemController outerController){
            this.outerController = outerController;
            this.componentControllerMap = new Map<String, ASI_MFM_ComponentInterface>();
            
        }
        
        public List<ASI_eForm_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList() {
            List<ASI_eForm_SFObjSelectTableController.SFObjSelectTableActionBtn> buttons =  new List<ASI_eForm_SFObjSelectTableController.SFObjSelectTableActionBtn>(); 
            buttons.add(new ASI_eForm_SFObjSelectTableController.SFObjSelectTableActionBtn('add', new String[] {'Delete', 'Deleted'}, new Boolean[] {false, true}));
            return  buttons; 
        }
        
        public Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap() {
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
            
        public void sobjst_triggerActionForSObject(ASI_eForm_SFObjSelectTableController controller, String actionKey, sObject sObj) {
                    ASI_eForm_MassCreateAndUpdateController mcauC = (ASI_eForm_MassCreateAndUpdateController) outerController.getComponentController('massCreateAndUpdate');
                    ASI_eForm_User_System_Permission__c selectedPermission = (ASI_eForm_User_System_Permission__c) sObj;        
                    ASI_eForm_User_ID_Request_Item__c userIDRequestItem = new ASI_eForm_User_ID_Request_Item__c();
                    userIDRequestItem.ASI_eForm_PR_System__c = selectedPermission.ASI_eForm_PR_System__c;
                    userIDRequestItem.ASI_eForm_BO_Additional_Remarks__c = selectedPermission.ASI_eForm_BO_Additional_Remarks__c;
                    userIDRequestItem.ASI_eForm_Permission_Action__c = 'Delete Permission';
                    userIDRequestItem.ASI_eForm_Permission_TypeN__c = selectedPermission.ASI_eForm_Permission_TypeN__c;
                    
                    ASI_eForm_MassCreateAndUpdateController.TableRow  tableRow =
                    mcauC.addNewRowByInfo(DEF_RT_IT_CHANGE_REQ_ITEM, userIDRequestItem, true );
                    
        }
        
        public void setComponentController(ASI_MFM_ComponentInterface cController) {
            this.componentControllerMap.put(DEF_CC_KEY, cController);
        }
        
    }

    
    public class Section3Controller implements ASI_eForm_SFObjSelectTableAbstract{
    
        private Map<String, ASI_MFM_ComponentInterface> componentControllerMap;
        ASI_eForm_UserIDRequestItemController outerController;
        
        public Section3Controller(ASI_eForm_UserIDRequestItemController outerController){
            this.outerController = outerController;
            this.componentControllerMap = new Map<String, ASI_MFM_ComponentInterface>();
            
        }
        
        public List<ASI_eForm_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList() {
            return null;
        }
        
        public Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap() {
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
                
        public void sobjst_triggerActionForSObject(ASI_eForm_SFObjSelectTableController controller, String actionKey, sObject sObj) {
                    ASI_eForm_MassCreateAndUpdateController mcauC = (ASI_eForm_MassCreateAndUpdateController) outerController.getComponentController('massCreateAndUpdate');
                    ASI_eForm_PR_System__c selectedSystem= (ASI_eForm_PR_System__c)sObj;        
                    ASI_eForm_User_ID_Request_Item__c userIDRequestItem = new ASI_eForm_User_ID_Request_Item__c();
                    userIDRequestItem.ASI_eForm_PR_System__c = selectedSystem.id;
                    //userIDRequestItem.ASI_eForm_System_Privilege__c = selectedSystem.ASI_eForm_System_Privilege__c;
                    userIDRequestItem.ASI_eForm_Permission_Action__c = 'Add Permission';           
                    mcauC.addNewRowByInfo(DEF_RT_IT_CHANGE_REQ_ITEM, userIDRequestItem);
                    // Revert the "add" button to "0" (0 = Add, 1 = Added) by mould record id (detail.MouldLookup__c)
                    controller.setBtnStageBySObjId(selectedSystem.Id, actionKey, 0);
                    
                    
        }
        
        public void setComponentController(ASI_MFM_ComponentInterface cController) {
            this.componentControllerMap.put(DEF_CC_KEY, cController);
        }
        
    }
}