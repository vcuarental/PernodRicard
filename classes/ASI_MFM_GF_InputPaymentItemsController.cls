public with sharing class ASI_MFM_GF_InputPaymentItemsController implements ASI_MFM_SFObjSelectTableAbstract, ASI_MFM_MassCreateAndUpdateAbstract {
    
    private static final String DEF_RT_PAYMENT_LI_TW = 'ASI_MFM_GF_Payment_Line_Item';
    
    public string paymentId {get; set;}
    public string initSupplierNum {get; set;}
    public string initSupplierName {get; set;}
    public string po_filter {get; set;} 
    public string supplier_filter {get; set;}
    public string supplierName_filter {get; set;}
    public string plan_filter {get; set;}               
    public ASI_MFM_PO__c po_obj_filter {get; set;}
    public ASI_MFM_PO_Line_Item__c pol_obj_filter {get; set;}
    public string raised_by_filter {get; set;}
    public string init_search {get; private set;}   
    public string init_search_with_header_info {get; private set;}
    public ASI_MFM_Payment__c payment {get; private set;}   
    private RecordType defPaymentLIRT;
    public ASI_MFM_objectPickListHelper subBrandPickList { get; set;}
        
    public ASI_MFM_GF_InputPaymentItemsController(ApexPages.StandardSetController stdSetController) {
        subBrandPickList = new ASI_MFM_ObjectPickListHelper('ASI_MFM_PO_Line_Item__c','ASI_MFM_Sub_brand_Code__c');                 
        
        this.componentControllerMap = new Map<String, ASI_MFM_ComponentInterface>();
        paymentId = apexpages.currentPage().getParameters().get('id');  
        payment = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_Payment__c', 'ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c,ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Name__c, recordType.developerName') + ' where id = :paymentId');
        this.initSupplierNum = payment.ASI_MFM_Supplier_Name__r != null ? payment.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c : null;
        this.initSupplierName = payment.ASI_MFM_Supplier_Name__r != null ? payment.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Name__c : null;

        init_search = 'ASI_MFM_Complete__c = false and ASI_MFM_Remaining_Balance__c != 0 and ASI_MFM_Remaining_Balance__c != null and ASI_MFM_PO_Status__c = \'Final\' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Reference_1_List__c != \'Management Accrual\'';
        
        //Gulf: If pre-payment, only allow select PO Line that haven't perform PO Receipt
        if (payment.ASI_MFM_Pre_payment__c) {
            init_search += ' and ASI_MFM_Has_Final_Receipt__c = 0';
        }
        else {
            //Gulf: If NOT pre-payment, only allow select PO Line that have PO Receipt and PO Receipt status if Final
            init_search += ' and ASI_MFM_Has_Final_Receipt__c > 0';
        }
        
        string user_name = userInfo.getFirstName();
        if (user_name == null) {
            user_name = userInfo.getLastName();
        }
        else {
            user_name += ' ' + userInfo.getLastName();
        }
        init_search_with_header_info = init_search + ' and ASI_MFM_PO_Raised_By__c = \'' + user_name + '\'';
        if (initSupplierNum != null) {
            init_search_with_header_info += ' and ASI_MFM_PO_Supplier_Number__c = \'' + String.escapeSingleQuotes(initSupplierNum) + '\'';
        }
        
        if (payment.ASI_MFM_PO_Type__c != null) {
            init_search_with_header_info += ' and ASI_MFM_PO_Type__c = \'' + payment.ASI_MFM_PO_Type__c + '\'';
        }
        
        if (payment.ASI_MFM_Currency__c != null) {
            init_search_with_header_info += ' and ASI_MFM_Currency__c = \'' + payment.ASI_MFM_Currency__c + '\'';
        }
        
        system.debug('Search string:' + init_search_with_header_info);
        raised_by_filter = user_name;        
        supplier_filter = initSupplierNum;
        supplierName_filter = initSupplierName;
        
        //GF Logic: Default empty for currency field
        //this.po_obj_filter = new ASI_MFM_PO__c(ASI_MFM_Currency__c = payment.ASI_MFM_Currency__c == null ? '' : payment.ASI_MFM_Currency__c);
        this.po_obj_filter = new ASI_MFM_PO__c(ASI_MFM_Currency__c = '');
        
        this.pol_obj_filter = new ASI_MFM_PO_Line_Item__c();
        List<RecordType> paymentLIRTs = [SELECT Id FROM RecordType WHERE SobjectType = 'ASI_MFM_Payment_Line_Item__c' AND DeveloperName = :DEF_RT_PAYMENT_LI_TW];
        this.defPaymentLIRT = paymentLIRTs.size() > 0 ? paymentLIRTs[0] : null;
    }
    
    public void FilterPOItems() {
        string whereStatm = init_search;
        system.debug('PO Filter: ' + po_filter);
// 2013.07.17 change starts
        if (po_filter != null && po_filter.trim() != '') {
            whereStatm += ' and ASI_MFM_PO__r.name like \'' + String.escapeSingleQuotes(po_filter.trim()) + '%\'';
        }
        if (supplier_filter != null && supplier_filter.trim() != '') {
            whereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c = \'' + String.escapeSingleQuotes(supplier_filter.trim()) + '\'';
        }       
        if (supplierName_filter != null && supplierName_filter.trim() != '') {
            whereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Name__c like \'' + String.escapeSingleQuotes(supplierName_filter.trim()) + '%\'';
        }
        if (plan_filter != null && plan_filter.trim() != '') {
            whereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.name like \'' + String.escapeSingleQuotes(plan_filter.trim()) + '%\'';
        }
        if (po_obj_filter.ASI_MFM_Currency__c != null && po_obj_filter.ASI_MFM_Currency__c.trim() != '') {
            whereStatm += ' AND ASI_MFM_Currency__c = \'' + String.escapeSingleQuotes(po_obj_filter.ASI_MFM_Currency__c) + '\'';
        }
        if (pol_obj_filter.ASI_MFM_Sub_brand_Code__c != null) {
            whereStatm += ' AND ASI_MFM_Sub_brand_Code__c = \'' + pol_obj_filter.ASI_MFM_Sub_brand_Code__c + '\'';
        }
        if (raised_by_filter != null && raised_by_filter.trim() != '') {
            whereStatm += ' and ASI_MFM_PO_Raised_By__c like \'%' + String.escapeSingleQuotes(raised_by_filter.trim()) + '%\'';
        }   
// 2013,07.17 change ends           
                
        ASI_MFM_SFObjSelectTableController sobjstController = (ASI_MFM_SFObjSelectTableController)this.getComponentController('selectTable');
        if (sobjstController != null) {
            sobjstController.setDataFilter(whereStatm);
            sobjstController.reloadData();
        }           
    }
    
    public void addAll(){
        ASI_MFM_SFObjSelectTableController sobjstController = (ASI_MFM_SFObjSelectTableController)this.getComponentController('selectTable');
        if (sobjstController != null) {
            system.debug(sobjstController.actionBtnList);
            system.debug(sobjstController.tableEleList);
            for(ASI_MFM_SFObjSelectTableController.SFObjSelectTableElement tEle : sobjstController.tableEleList){
                //System.debug(!sobjstController.actionBtnList[0].isDisableList);
                if(!sobjstController.actionBtnList[0].isDisableList[tEle.btnStage.get('add')]){
                    system.debug(tEle.sObj);
                    sobjstController.triggerRowAction('add', (String)tEle.sObj.get('id'));
                }
            }
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
                ASI_MFM_Payment_Amount__c = exchange_rate == null || exchange_rate == 0 ? null : (selected_pol.ASI_MFM_Remaining_Balance__c / exchange_rate).setScale(2, roundingMode.half_up),
                ASI_MFM_Payment_Amount_Distributor__c = exchange_rate == null || exchange_rate == 0 || selected_pol.ASI_MFM_Distributor_Amount__c == null ? null : (selected_pol.ASI_MFM_Distributor_Amount__c - (selected_pol.ASI_MFM_Paid_Amount_in_PO_Currency__c - selected_pol.ASI_MFM_Paid_Amount_in_PO_Currency_PRG__c)/ exchange_rate).setScale(2, roundingMode.half_up)
                );
                
            if (this.defPaymentLIRT != null) payment_item.RecordTypeId = this.defPaymentLIRT.Id;
            // Use ASI_MFM_MassCreateAndUpdateController.RTDEVNAME_MASTER if you have only one record type
            // Use Record Type developer name if you have more than 1 record type
            mcauC.addNewRowByInfo(DEF_RT_PAYMENT_LI_TW, payment_item);
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
        ASI_MFM_Payment_Line_Item__c payment_item = (ASI_MFM_Payment_Line_Item__c)sObj;
        if (payment_item != null && payment_item.ASI_MFM_PO_Line_Item__c != null && actionKey == ASI_MFM_MassCreateAndUpdateController.ACTION_REMOVE_NEW) {
            ASI_MFM_SFObjSelectTableController selectTableC = (ASI_MFM_SFObjSelectTableController)this.getComponentController('selectTable');
            // Revert the "add" button to "0" (0 = Add, 1 = Added) by mould record id (detail.MouldLookup__c)
            selectTableC.setBtnStageBySObjId(payment_item.ASI_MFM_PO_Line_Item__c, 'add', 0);
        }
    }
    
    /*
     * Methods and variables that extend the ASI_MFM_PageInterface
     */
    
    private static String DEF_CC_KEY = 'DEFAULT';
    private Map<String, ASI_MFM_ComponentInterface> componentControllerMap;
    public ASI_MFM_GF_InputPaymentItemsController thisController { get {return this;} set; }
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