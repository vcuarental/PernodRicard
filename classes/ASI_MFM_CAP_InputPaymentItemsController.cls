public with sharing class ASI_MFM_CAP_InputPaymentItemsController implements ASI_MFM_SFObjSelectTableAbstract, ASI_MFM_CAP_MassCreateAndUpdateAbstract {
    
    private static final String DEF_RT_PAYMENT_LI_CAP;
    
    static {
        if(ApexPages.CurrentPage().getParameters().containsKey('crtName'))
            DEF_RT_PAYMENT_LI_CAP = ApexPages.CurrentPage().getParameters().get('crtName');
        else
            DEF_RT_PAYMENT_LI_CAP = 'ASI_MFM_CAP_Payment_Line_Item';
    }
    
    public string paymentId {get; set;}
    public string initSupplierNum {get; set;}
    public string po_filter {get; set;} 
    public boolean dummy_po {get; set;}
    public string supplier_filter {get; set;}
    public string plan_filter {get; set;}               
    public ASI_MFM_PO__c po_obj_filter {get; set;}
    public ASI_MFM_PO_Line_Item__c pol_obj_filter {get; set;}
    public string raised_by_filter {get; set;}
    public string init_search {get; private set;}   
    public string init_search_with_header_info {get; private set;}
    public ASI_MFM_Payment__c payment {get; private set;}   
    private RecordType defPaymentLIRT;
    public ASI_MFM_objectPickListHelper subBrandPickList { get; set;}
    public boolean isFinal {get;set;}
    public boolean isSubmitted {get;set;}
    public boolean isSSCFinance {get;set;}
    public boolean isOCRORDPayment {get;set;}
    public boolean isDraft {
        get {
            if(isDraft == NULL) {
                return false;
            } 
            return isDraft;
        }
        set;
    }
    
    public final Set<String> groupExceptionList = new Set<String>{'ASI_MFM_CAP_SSC_Finance_Team'};

    public ASI_MFM_CAP_InputPaymentItemsController(ApexPages.StandardSetController stdSetController) {
    
        subBrandPickList = new ASI_MFM_ObjectPickListHelper('ASI_MFM_PO_Line_Item__c','ASI_MFM_Sub_brand_Code__c');                 
        
        this.componentControllerMap = new Map<String, ASI_MFM_ComponentInterface>();
        paymentId = apexpages.currentPage().getParameters().get('id');  
        payment = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_Payment__c', 'ASI_MFM_CAP_PO__r.Name,ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c, recordType.developerName') + ' where id = :paymentId');
        
        // DC - 03/02/2016 - Added following code while reverting changes in CAP Payment Manage All page.
        this.isFinal = false;
        this.isSubmitted = false;
        this.isOCRORDPayment = false;
        if(payment.ASI_MFM_OCR__c || payment.ASI_MFM_Is_Direct_Payment__c)
            this.isOCRORDPayment = true;
        if (payment.ASI_MFM_CAP_PO__c != null)
            this.po_filter = payment.ASI_MFM_CAP_PO__r.Name;
        this.dummy_po = false;
        if(ApexPages.CurrentPage().getParameters().containsKey('crtName')) {
            if(!String.isBlank(payment.ASI_MFM_Status__c) && payment.ASI_MFM_Status__c.equalsIgnoreCase('Draft')) {
                isDraft = true;
            } else {
                isDraft = false;
            }
        }
        else {
            if (payment.recordtypeid == Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment_Read_Only') && payment.ASI_MFM_Status__c != 'Submitted')
                this.isFinal = true;
            else if (payment.ASI_MFM_Status__c == 'Submitted')
                this.isSubmitted = true;
        }
        this.isSSCFinance = false;
        List<Group> relatedGroup = getGroupsForUser(userinfo.getuserid());
        for (Group i : relatedGroup)
        {
            if (groupExceptionList.contains(i.DeveloperName))
                this.isSSCFinance = true;
        }

        this.initSupplierNum = payment.ASI_MFM_Supplier_Name__r != null ? payment.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c : null;
        String IDFinalCapAccrual;
        if(ApexPages.CurrentPage().getParameters().containsKey('crtName') && !String.isBlank(ApexPages.CurrentPage().getParameters().get('crtName'))) {
            IDFinalCapAccrual = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_TW_PO_Line_Item');
        } else {
            IDFinalCapAccrual = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_PO_Line_Item');
        }
        init_search = '(ASI_MFM_Remaining_Balance__c != 0 and ASI_MFM_Remaining_Balance__c != null and ASI_MFM_Pay_Acc__c = \'A\' and recordtypeID = \'' + IDFinalCapAccrual + '\' and ASI_MFM_PO__r.ASI_MFM_Status__c = \'Final\' and ASI_MFM_PO__r.ASI_MFM_PO_Type__c = \''+ payment.ASI_MFM_Payment_Type__c +'\') ';
        
        //20181109 Hector: Remove the Plan restriction to cater Dummy PO logic
        //20160608 Wilken: Filter Accrual PO which the Plan matches Payment Header's Plan only
        
        if (IDFinalCapAccrual ==  Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_PO_Line_Item') && payment.ASI_MFM_Plan__c != null)
            init_search += 'and ASI_MFM_PO__r.ASI_MFM_Plan__c = \'' + payment.ASI_MFM_Plan__c + '\' ';
        
        FilterPOItems();
        
        /*
        string user_name = userInfo.getFirstName();
        if (user_name == null) {
            user_name = userInfo.getLastName();
        }
        else {    
            user_name += ' ' + userInfo.getLastName();
        }
        init_search_with_header_info = init_search + ' and ASI_MFM_PO_Raised_By__c = \'' + user_name + '\'';
        */
        init_search_with_header_info = init_search;
        List<String> queryFilter = new List<String>();
        if (payment.ASI_MFM_CAP_PO__c != null){
            queryFilter.add('ASI_MFM_PO__c = \'' + String.escapeSingleQuotes(payment.ASI_MFM_CAP_PO__c) + '\' ');
        }
        if (initSupplierNum != null) {
            //init_search_with_header_info += ' and ASI_MFM_PO_Supplier_Number__c = \'' + String.escapeSingleQuotes(initSupplierNum) + '\'';
            queryFilter.add('ASI_MFM_PO_Supplier_Number__c = \'' + String.escapeSingleQuotes(initSupplierNum) + '\' ');
        }
        if (payment.ASI_MFM_Currency__c != null) {
            //init_search_with_header_info += ' and ASI_MFM_Currency__c = \'' + payment.ASI_MFM_Currency__c + '\'';
            queryFilter.add('ASI_MFM_Currency__c = \'' + payment.ASI_MFM_Currency__c + '\'');
        }
         if (queryFilter.size() > 0){
            //queryFilter.add('ASI_MFM_PO__r.ASI_MFM_Plan__c = \'' + payment.ASI_MFM_Plan__c + '\' ');
            if (dummy_po){
                init_search_with_header_info += ' AND ((' + String.join(queryFilter, ' AND ') + ') OR ASI_MFM_PO__r.ASI_MFM_Dummy_PO__c = true) ';
            } else {
                init_search_with_header_info += ' AND (' + String.join(queryFilter, ' AND ') + ') ';
            }
        } else {
            if (dummy_po){
                init_search_with_header_info += ' AND ASI_MFM_PO__r.ASI_MFM_Dummy_PO__c = true';
            }
        }
        system.debug('Search string:' + init_search_with_header_info);
        raised_by_filter = '';        
// 2013.07.17 change ends       
        supplier_filter = initSupplierNum;
        this.po_obj_filter = new ASI_MFM_PO__c(ASI_MFM_Currency__c = payment.ASI_MFM_Currency__c == null ? '' : payment.ASI_MFM_Currency__c);
        this.pol_obj_filter = new ASI_MFM_PO_Line_Item__c();
        List<RecordType> paymentLIRTs = [SELECT Id FROM RecordType WHERE SobjectType = 'ASI_MFM_Payment_Line_Item__c' AND DeveloperName = :DEF_RT_PAYMENT_LI_CAP];
        this.defPaymentLIRT = paymentLIRTs.size() > 0 ? paymentLIRTs[0] : null;
        
    }
    
    public void FilterPOItems() {
        string whereStatm = init_search;
        system.debug('PO Filter: ' + po_filter);
// 2018.10.26 Laputa(Hector) Rewrite Where Clause and Add Dummy PO
        List<String> queryFilter = new List<String>();
        if (!String.isBlank(po_filter)){
            queryFilter.add('ASI_MFM_PO__r.name like \'' + String.escapeSingleQuotes(po_filter.trim()) + '%\'');
        }
        if (!String.isBlank(supplier_filter)){
            queryFilter.add('ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c = \'' + String.escapeSingleQuotes(supplier_filter.trim()) + '\'');
        }
        if (!String.isBlank(plan_filter)){
            queryFilter.add('ASI_MFM_PO__r.ASI_MFM_Plan__r.name like \'' + String.escapeSingleQuotes(plan_filter.trim()) + '%\'');
        }
        if (po_obj_filter != null){
        	if (!String.isBlank(po_obj_filter.ASI_MFM_Currency__c)){
                queryFilter.add('ASI_MFM_Currency__c = \'' + String.escapeSingleQuotes(po_obj_filter.ASI_MFM_Currency__c) + '\'');
            }    
        }
        
        if (!String.isBlank(raised_by_filter)){
            queryFilter.add('ASI_MFM_PO_Raised_By__c like \'%' + String.escapeSingleQuotes(raised_by_filter.trim()) + '%\'');
        }
        if (queryFilter.size() > 0){
            //queryFilter.add('ASI_MFM_PO__r.ASI_MFM_Plan__c = \'' + payment.ASI_MFM_Plan__c + '\' ');
            if (dummy_po){
                whereStatm += ' AND ((' + String.join(queryFilter, ' AND ') + ') OR ASI_MFM_PO__r.ASI_MFM_Dummy_PO__c = true) ';
            } else {
                whereStatm += ' AND (' + String.join(queryFilter, ' AND ') + ') ';
            }
        } else {
            if (dummy_po){
                whereStatm += ' AND ASI_MFM_PO__r.ASI_MFM_Dummy_PO__c = true';
            }
        }
// 2018.10.26 Laputa(Hector) Rewrite Where Clause and Add Dummy PO END           
        system.debug('whereStatm:' + whereStatm);        
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
            ASI_MFM_CAP_MassCreateUpdateController mcauC = (ASI_MFM_CAP_MassCreateUpdateController)this.getComponentController('massCreateAndUpdate');
            ASI_MFM_PO_Line_Item__c selected_pol = (ASI_MFM_PO_Line_Item__c)sObj;
            decimal exchange_rate;
            if (selected_pol.ASI_MFM_Currency__c == payment.ASI_MFM_Currency__c) {
                exchange_rate = 1;
            }
            else {
                string country = payment.recordType.developerName.substring(8, 10);
                list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c 
                    where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Base_Currency__c = :selected_pol.ASI_MFM_Currency__c and
                    ASI_MFM_Counter_Currency__c = :payment.ASI_MFM_Currency__c and ASI_MFM_Country__c = :country and
                    ASI_MFM_Effective_Date__c <= :date.today() order by ASI_MFM_Effective_Date__c desc limit 1];
                if (xr_list.size() > 0) {
                    exchange_rate = xr_list[0].ASI_MFM_Exchange_Rate__c;
                }
            }
            ASI_MFM_Payment_Line_Item__c payment_item = new ASI_MFM_Payment_Line_Item__c(
                ASI_MFM_PO_Line_Item__c = selected_pol.id, 
                ASI_MFM_Payment__c = paymentId,
                ASI_MFM_PO_Line_Currency__c = selected_pol.ASI_MFM_Currency__c,
                ASI_MFM_PO_Line_Remaining_Amount__c = selected_pol.ASI_MFM_Remaining_Balance__c,
                ASI_MFM_PO_Line_Description__c = selected_pol.ASI_MFM_List_Item_Description__c, 
                //ASI_MFM_A_C_Code__c = selected_pol.ASI_MFM_A_C_Code__c,         
                ASI_MFM_AP_Code__c = selected_pol.ASI_MFM_AP_Code__c,
                //ASI_MFM_BU__c  = selected_pol.ASI_MFM_BU_Code__c,
                ASI_MFM_Payment_Amount__c = exchange_rate == null || exchange_rate == 0? null : (selected_pol.ASI_MFM_Remaining_Balance__c / exchange_rate).setScale(2, roundingMode.half_up));
                
            if (this.defPaymentLIRT != null) payment_item.RecordTypeId = this.defPaymentLIRT.Id;
            // Use ASI_MFM_CAP_MassCreateUpdateController.RTDEVNAME_MASTER if you have only one record type
            // Use Record Type developer name if you have more than 1 record type
            mcauC.addNewRowByInfo(DEF_RT_PAYMENT_LI_CAP, payment_item);
        }
    }
    
    /**
     * Methods to implement the ASI_MFM_MassCreateAndUpdateAbstract
     */
    
    public  List<ASI_MFM_CAP_MassCreateUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
        return null;
    }
    
    public PageReference mcau_triggerPageBlockAction(ASI_MFM_CAP_MassCreateUpdateController controller, String actionKey) {
        return null;
    }
    
    public void mcau_triggerActionForSObject(ASI_MFM_CAP_MassCreateUpdateController controller, String actionKey, sObject sObj) {
        ASI_MFM_Payment_Line_Item__c payment_item = (ASI_MFM_Payment_Line_Item__c)sObj;
        if (payment_item != null && payment_item.ASI_MFM_PO_Line_Item__c != null && actionKey == ASI_MFM_CAP_MassCreateUpdateController.ACTION_REMOVE_NEW) {
            ASI_MFM_SFObjSelectTableController selectTableC = (ASI_MFM_SFObjSelectTableController)this.getComponentController('selectTable');
            // Revert the "add" button to "0" (0 = Add, 1 = Added) by mould record id (detail.MouldLookup__c)
            if(!isFinal && !isSubmitted && !isOCRORDPayment)
                selectTableC.setBtnStageBySObjId(payment_item.ASI_MFM_PO_Line_Item__c, 'add', 0);
        }
    }
    
    /*
     * Methods and variables that extend the ASI_MFM_PageInterface
     */
    
    private static String DEF_CC_KEY = 'DEFAULT';
    private Map<String, ASI_MFM_ComponentInterface> componentControllerMap;
    public ASI_MFM_CAP_InputPaymentItemsController thisController { get {return this;} set; }
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
    
    // return list of all groups the user belongs to via direct or indirect membership
    public Group[] getGroupsForUser(Id userId){

        Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
     return [
           select Id
            , Name ,
            DeveloperName 
         from Group
        where Id IN: groupIds];

    }

    // return all ids the user belongs to via direct or indirect membership
    public Set<Id> getGroupsForIds(Set<Id> userOrGroupIds){

        Set<Id> output = new Set<Id>();

        Set<Id> nestedGroupIds = new Set<Id>();

        // only query actual groups and not roles and queues
        list<GroupMember> records = [
            select id
                 , GroupId
                 , UserOrGroupId
              from GroupMember
         where UserOrGroupId =: userOrGroupIds
            and UserOrGroupId != null];

        for (GroupMember record:records)
        {
            // found a group, remember for traversal
            if (!(record.UserOrGroupId + '').startsWith('005'))
            {
                nestedGroupIds.add(record.UserOrGroupId);   
            }
            else
            {
                output.add(record.GroupId);
            }
        }

        // call self to get nested groups we found
        if (nestedGroupIds.size() > 0)
        {
            output.addAll(getGroupsForIds(nestedGroupIds));
        }

        return output;
    }
}