/* History                          Desc                          Log #                Status        Deployment State
 * -------------------------------------------------------------------------------------------------------------------
 * 2013-11-11 Michael Yip           Create
 * 2015-05-12 Alan Wong (Elufa)     Remove Sub-brand filter       cn-sfdc-event-001    Developed
*/
public with sharing class ASI_MFM_EventPPInputPageController implements ASI_MFM_SFObjSelectTableAbstract, ASI_MFM_MassCreateAndUpdateAbstract{
    
    private static final String DEF_RT = 'ASI_MFM_CN_Event_PP';
    
    public string eventId {get; set;}
    public string initSupplierNum {get; set;}
    public string pp_filter {get; set;} 
    public ASI_MFM_Plan__c pp_obj_filter {get; set;}
    //Edited by Introv 20131223
   
    public ASI_MFM_objectPickListHelper budgetOwnerPickList { get; set;}
    public ASI_MFM_objectPickListHelper ppCategoryPickList{ get; set;}
    //End Edit
    public ASI_MFM_PO_Line_Item__c pol_obj_filter {get; set;}
    public User user_obj_filter {set;get;}
    public string init_search {get; private set;}   
    public string init_search_with_header_info {get; private set;}
    public ASI_MFM_Event__c event {get; private set;}   
    public string raised_by_filter {get; set;}
    public ASI_MFM_objectPickListHelper subBrandPickList { get; set;}
    private RecordType defPaymentLIRT;
        
    // added by KF Leung (Introv) 20140507
    public List<selectOption> subBrandOptions {get;set;}
    //
    
    public ASI_MFM_EventPPInputPageController(ApexPages.StandardSetController stdSetController) {
        
        //subBrandPickList = new ASI_MFM_ObjectPickListHelper('ASI_MFM_Plan_Line_Item__c','ASI_MFM_Sub_brand_Code__c');             
        budgetOwnerPickList = new ASI_MFM_ObjectPickListHelper('ASI_MFM_PLAN__c','ASI_MFM_Budget_Owner__c','1000',' isActive = true and ASI_MFM_Country__c =\'CN\' ');               
        ppCategoryPickList = new ASI_MFM_ObjectPickListHelper('ASI_MFM_PLAN__c','ASI_MFM_PP_Category__c'); 
        this.componentControllerMap = new Map<String, ASI_MFM_ComponentInterface>();
        eventId = apexpages.currentPage().getParameters().get('id');  
        event = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_Event__c', 'recordType.developerName, owner.name') + ' where id = :eventId');

        //// START: added by KF Leung (Introv) 20140507
        
        // 1. prepared valid sub-brand Ids
        // 2. prepared valid sub-brand options for filtering
        set<Id> eventSubBrandIds = new set<Id>();
        subBrandOptions = new list<selectOption>();
        subBrandOptions.add(new SelectOption('',''));
        for(ASI_MFM_Event_Sub_Brand__c eventSB :[SELECT Id, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.Name FROM ASI_MFM_Event_Sub_Brand__c WHERE ASI_MFM_Event__c =:event.Id ORDER BY ASI_MFM_Sub_brand__r.Name]) {
           	//added by Daniel 20150129 NULL checking
            if(eventSB.ASI_MFM_Sub_brand__c != NULL && eventSB.ASI_MFM_Sub_brand__r.Name != NULL){
            	subBrandOptions.add(new SelectOption(eventSB.ASI_MFM_Sub_brand__c, eventSB.ASI_MFM_Sub_brand__r.Name));
            	eventSubBrandIds.add(eventSB.ASI_MFM_Sub_brand__c);
            }
        }
        //// END: added by KF Leung (Introv) 20140507

        //// START: changed by KF Leung (Introv) 20140507
        //init_search = ' ASI_MFM_Status__c = \'Final\' ';
        init_search = ' ASI_MFM_Status__c = \'Final\' AND RecordType.developerName LIKE \'ASI_MFM_CN%\' ';
        /* #cn-sfdc-event-001 Remove sub-brand filter by Alan Wong (Elufa) 20150512     
        //if(eventSubBrandIds.size()>0) {
        //    init_search += ' AND Id IN (SELECT ASI_MFM_Plan__c FROM ASI_MFM_Plan_Line_Item__c WHERE';
        //    boolean isFirst = true;
        //    for(Id sbid :eventSubBrandIds) {
        //    	init_search += (isFirst?'':' OR') + ' ASI_MFM_Sub_brand_Code__c=\'' + sbid + '\'';
        //        isFirst=false;
        //    }
        //    init_search += ')';
        //}
        */
        //// END: changed by KF Leung (Introv) 20140507
        init_search_with_header_info = init_search;
        
        system.debug('Search string:' + init_search_with_header_info);

        
        this.pp_obj_filter = new ASI_MFM_Plan__c(ASI_MFM_Budget_Owner__c = userInfo.getUserId());
        this.pol_obj_filter = new ASI_MFM_PO_Line_Item__c();
        this.user_obj_filter = new user();
        List<RecordType> paymentLIRTs = [SELECT Id FROM RecordType WHERE SobjectType = 'ASI_MFM_Event_PP__c' AND DeveloperName = :DEF_RT];
        this.defPaymentLIRT = paymentLIRTs.size() > 0 ? paymentLIRTs[0] : null;
        
    }
    
    public void FilterPP() {
        string whereStatm = init_search;
        system.debug('PP Filter: ' + pp_filter);

        if (pp_filter != null && pp_filter.trim() != '') {
            whereStatm += ' and ASI_MFM_Plan_Name__c like \'' + String.escapeSingleQuotes(pp_filter.trim()) + '%\'';
               
        }
        if((pp_obj_filter.ASI_MFM_Budget_Owner__c != null)){
              system.debug('pp_filter : ' + pp_obj_filter.ASI_MFM_Budget_Owner__c);
              whereStatm += ' and ASI_MFM_Budget_Owner__c = \'' + pp_obj_filter.ASI_MFM_Budget_Owner__c + '\'';
        }  
         if((pp_obj_filter.ASI_MFM_PP_Category__c!= null)){
              system.debug('pp_filter : ' + pp_obj_filter.ASI_MFM_PP_Category__c);
              whereStatm += ' and ASI_MFM_PP_Category__c = \'' + pp_obj_filter.ASI_MFM_PP_Category__c+ '\'';
        }   
        /* #cn-sfdc-event-001 Remove sub-brand filter by Alan Wong (Elufa) 20150512
        if (pol_obj_filter.ASI_MFM_Sub_brand_Code__c != null) {
            system.debug('pol_obj_filter: ' + pol_obj_filter.ASI_MFM_Sub_brand_Code__c );
            whereStatm += ' AND Id IN (SELECT ASI_MFM_Plan__c FROM ASI_MFM_Plan_Line_Item__c WHERE ASI_MFM_Sub_brand_Code__c = \'' + pol_obj_filter.ASI_MFM_Sub_brand_Code__c + '\')';
        }
        */
        if(user_obj_filter.ASI_MFM_Team__c != null) {
        	system.debug('user_obj_filter.ASI_MFM_Team__c: ' + user_obj_filter.ASI_MFM_Team__c );
            whereStatm += ' AND ASI_MFM_Budget_Owner__r.ASI_MFM_Team__c = \'' + user_obj_filter.ASI_MFM_Team__c + '\'';
        }
                
        ASI_MFM_SFObjSelectTableController sobjstController = (ASI_MFM_SFObjSelectTableController)this.getComponentController('selectTable');
        if (sobjstController != null) {
            sobjstController.setDataFilter(whereStatm);
            sobjstController.reloadData();
        }           
    }
    
    /**
     * Methods to implement the ASI_MFM_SFObjSelectTableAbstract
     */
    
    public List<ASI_MFM_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList() {
        return null;
    }
    
    public Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap() {
        return null;
    }
    
    public void sobjst_triggerActionForSObject(ASI_MFM_SFObjSelectTableController controller, String actionKey, sObject sObj) {
        if (actionKey == 'add') {
            ASI_MFM_MassCreateAndUpdateController mcauC = (ASI_MFM_MassCreateAndUpdateController)this.getComponentController('massCreateAndUpdate');
            
            ASI_MFM_Event_PP__c eventPP = new ASI_MFM_Event_PP__c(
                ASI_MFM_Plan__c = sObj.id, 
                ASI_MFM_Event__c = eventId);
                
            if (this.defPaymentLIRT != null) eventPP.RecordTypeId = this.defPaymentLIRT.Id;
            // Use ASI_MFM_MassCreateAndUpdateController.RTDEVNAME_MASTER if you have only one record type
            // Use Record Type developer name if you have more than 1 record type
            mcauC.addNewRowByInfo(DEF_RT, eventPP);
        }
    }
    
    /**
     * Methods to implement the ASI_MFM_MassCreateAndUpdateAbstract
     */
    
    public List<ASI_MFM_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
        return null;
    }
    
    public PageReference mcau_triggerPageBlockAction(ASI_MFM_MassCreateAndUpdateController controller, String actionKey) {
        return null;
    }
    
    public void mcau_triggerActionForSObject(ASI_MFM_MassCreateAndUpdateController controller, String actionKey, sObject sObj) {
        ASI_MFM_Event_PP__c eventPP = (ASI_MFM_Event_PP__c)sObj;
        if (eventPP != null && eventPP.ASI_MFM_Plan__c != null && actionKey == ASI_MFM_MassCreateAndUpdateController.ACTION_REMOVE_NEW) {
            ASI_MFM_SFObjSelectTableController selectTableC = (ASI_MFM_SFObjSelectTableController)this.getComponentController('selectTable');
            // Revert the "add" button to "0" (0 = Add, 1 = Added) by mould record id (detail.MouldLookup__c)
            selectTableC.setBtnStageBySObjId(eventPP.ASI_MFM_Plan__c, 'add', 0);
        }
    }
    
    /*
     * Methods and variables that extend the ASI_MFM_PageInterface
     */
    
    private static String DEF_CC_KEY = 'DEFAULT';
    private Map<String, ASI_MFM_ComponentInterface> componentControllerMap;
    public ASI_MFM_EventPPInputPageController thisController { get {return this;} set; }
    public void setComponentController(ASI_MFM_ComponentInterface cController) {
        this.componentControllerMap.put(DEF_CC_KEY, cController);
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