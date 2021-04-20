public with sharing class ASI_MFM_CN_InputPaymentItemsController implements ASI_MFM_SFObjSelectTableAbstract, ASI_MFM_MassCreateAndUpdateAbstract {
    
    private static final String DEF_RT_PAYMENT_LI_CN = 'ASI_MFM_CN_Payment_Line_Item';
    public string whereStatm{get; set;}
    public string paymentId {get; set;}
    public string initSupplierNum {get; set;}
    public string initbu {get; set;}
    public string initfiscalyear {get; set;}
    public string po_filter {get; set;} 
    public string supplier_filter {get; set;}
    public string plan_filter {get; set;}
    public string bu_filter {get; set;} //{bu_filter = '1234';}
    public string FiscalYear_filter {get; set;} 
    public ASI_MFM_PO__c po_obj_filter {get; set;}
    public ASI_MFM_PO_Line_Item__c pol_obj_filter {get; set;}
    public string raised_by_filter {get; set;}
    public string init_search {get; private set;}   
    public string init_search_with_header_info {get; private set;}
    public ASI_MFM_Payment__c payment {get; set;}   
    private RecordType defPaymentLIRT;
    public ASI_MFM_objectPickListHelper subBrandPickList { get; set;}
    public ASI_MFM_objectPickListHelper budgetOwnerPickList { get; set;}
        
    public ASI_MFM_CN_InputPaymentItemsController(ApexPages.StandardSetController stdSetController) {
    
        this.componentControllerMap = new Map<String, ASI_MFM_ComponentInterface>();
        paymentId = apexpages.currentPage().getParameters().get('id');
    }
    
    public void init()
    {
        init(null);
    }
        
    public void init(ASI_MFM_Payment__c parent)    
    {
        subBrandPickList = new ASI_MFM_ObjectPickListHelper('ASI_MFM_PO_Line_Item__c','ASI_MFM_Sub_brand_Code__c');                 
        budgetOwnerPickList = new ASI_MFM_ObjectPickListHelper('ASI_MFM_PO__c','ASI_MFM_Budget_Owner__c','1000',' isActive = true and ASI_MFM_Country__c =\'CN\' ');               
       	id pid;
        if(paymentId!=null){
        	payment = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_Payment__c', 'ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c,ASI_MFM_BU__r.name,ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c, recordType.developerName') + ' where id = :paymentId');
        	pid = paymentId;
        }else {
            payment = parent;
        	pid = parent.Id;
        }
        this.initSupplierNum = payment.ASI_MFM_Supplier_Name__r != null ? payment.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c : null;
        this.initbu = payment.ASI_MFM_BU__c != null ? payment.ASI_MFM_BU__r.name: null;
        this.initfiscalyear = payment.ASI_MFM_CN_Fiscal_Year__c!= null ? payment.ASI_MFM_CN_Fiscal_Year__c: null;
        
        //bu_filter = initbu;
        //FiscalYear_filter=initfiscalyear;
		
		this.po_obj_filter = new ASI_MFM_PO__c(ASI_MFM_Budget_Owner__c = userInfo.getUserId(),ASI_MFM_Currency__c = payment.ASI_MFM_Currency__c);
		this.pol_obj_filter = new ASI_MFM_PO_Line_Item__c();
		
        //Added by Alan Wong (Elufa) 20150716 Remove dulipate PO Line in search
        set<id> pol_set= new set<id>();
        List<id> pol_list = new List<id>(); 
        string polid = '';
        if(pid!= null){
            List<ASI_MFM_Payment_Line_Item__c> tempPLIList = [SELECT ASI_MFM_PO_Line_Item__c from ASI_MFM_Payment_Line_Item__c WHERE ASI_MFM_Payment__c =:pid];
            if (tempPLIList.size() > 0){
                for (ASI_MFM_Payment_Line_Item__c pyl: tempPLIList) {
                    pol_set.add(pyl.ASI_MFM_PO_Line_Item__c);
                }
                pol_list.addAll(pol_set);
            }
            if (pol_list.size()>0){
                polid =  '( \'' + pol_list[0] + '\' ';
                for (id pol_id: pol_list){
                    if (pol_id != pol_list[0]) {
                        polid += ', \'' + pol_id + '\' ';
                    }
                }
                polid += ')';
            }
        }
        //-- End --//
		// 2014-10-31	Axel.Leung@introv.com		#96, Allow negative payment on negative receipt
        init_search = 'ASI_MFM_Remaining_Balance__c <> 0 and (ASI_MFM_PO_Status__c = \'Final\' or ASI_MFM_PO_Status__c = \'Complete\')';
        if (polid != null && polid != ''){
             init_search += ' AND id NOT IN ' + polid;
        }
        raised_by_filter = userInfo.getUserId();
        if(raised_by_filter != null){
        	init_search_with_header_info = init_search + ' and ASI_MFM_PO__r.createdbyid = \'' + raised_by_filter + '\'';
        }
        if(po_filter != null){
        	init_search_with_header_info += ' and ASI_MFM_PO__r.name = \''  + String.escapeSingleQuotes(po_filter) + '\'';
        }
        supplier_filter = initSupplierNum;        
        if (initSupplierNum != null) {
            init_search_with_header_info += ' and ASI_MFM_PO_Supplier_Number__c = \'' + String.escapeSingleQuotes(initSupplierNum) + '\'';
        }
        
        FiscalYear_filter = initfiscalyear;
        if (initfiscalyear != null) {
        init_search_with_header_info += ' and ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c = \'' + String.escapeSingleQuotes(initfiscalyear) + '\'';
        }
        
        bu_filter = initbu;
        if (initbu != null) {
        init_search_with_header_info += ' and ASI_MFM_PO__r.ASI_MFM_BU_Code__r.name = \'' + String.escapeSingleQuotes(initbu) + '\'';
        }
        
        if((po_obj_filter.ASI_MFM_Budget_Owner__c != null)){
        	init_search_with_header_info = init_search + ' and ASI_MFM_PO__r.ASI_MFM_Budget_Owner__c = \'' + po_obj_filter.ASI_MFM_Budget_Owner__c + '\'';
        }
        if (payment.ASI_MFM_Currency__c != null) {
            init_search_with_header_info += ' and ASI_MFM_Currency__c = \'' + payment.ASI_MFM_Currency__c + '\'';
        }
        if (pol_obj_filter.ASI_MFM_Sub_brand_Code__c != null) {
            init_search_with_header_info += ' AND ASI_MFM_Sub_brand_Code__c = \'' + pol_obj_filter.ASI_MFM_Sub_brand_Code__c + '\'';
        }
        //remove default
        init_search_with_header_info += ' and ASI_MFM_PO__r.name = \'lllll' + '\'';
        
        po_obj_filter.ASI_MFM_Currency__c = payment.ASI_MFM_Currency__c;
        
        system.debug('Search string:' + init_search_with_header_info);
    
        
        this.po_obj_filter = new ASI_MFM_PO__c(ASI_MFM_Currency__c = payment.ASI_MFM_Currency__c == null ? '' : payment.ASI_MFM_Currency__c);
        this.pol_obj_filter = new ASI_MFM_PO_Line_Item__c();
        
        //List<RecordType> paymentLIRTs = [SELECT Id FROM RecordType WHERE SobjectType = 'ASI_MFM_Payment_Line_Item__c' AND DeveloperName = :DEF_RT_PAYMENT_LI_HK];
        //this.defPaymentLIRT = paymentLIRTs.size() > 0 ? paymentLIRTs[0] : null;
        this.defPaymentLIRT = Global_RecordTypeCache.getRtRec('ASI_MFM_Payment_Line_Item__c'+DEF_RT_PAYMENT_LI_CN);
    }
    
    public void FilterPOItems() {
         whereStatm = init_search;
        system.debug('PO Filter: ' + po_filter);
// 2013.07.17 change starts
        if (po_filter != null && po_filter.trim() != '') {
            whereStatm += ' and ASI_MFM_PO__r.name like \'' + String.escapeSingleQuotes(po_filter.trim()) + '%\'';
        }
        if (supplier_filter != null && supplier_filter.trim() != '') {
            whereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c = \'' + String.escapeSingleQuotes(supplier_filter.trim()) + '\'';
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
            whereStatm += ' and ASI_MFM_PO__r.createdbyid = \'' + String.escapeSingleQuotes(raised_by_filter.trim()) + '\'';
        }
        if((po_obj_filter.ASI_MFM_Budget_Owner__c != null)){
        	whereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Budget_Owner__c = \'' + po_obj_filter.ASI_MFM_Budget_Owner__c + '\'';
        }  
        if(bu_filter != null&& bu_filter.trim() != ''){
        	whereStatm += ' and ASI_MFM_PO__r.ASI_MFM_BU_Code__r.name = \'' + String.escapeSingleQuotes(bu_filter.trim()) + '\'';
        }
        if(FiscalYear_filter != null&& FiscalYear_filter.trim() != ''){
        	whereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c = \'' + String.escapeSingleQuotes(FiscalYear_filter.trim()) + '\'';
        }  
        
// 2013,07.17 change ends           
                
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
            ASI_MFM_Payment_Line_Item__c payment_item;
            if(!test.isRunningTest()){
            	payment_item = new ASI_MFM_Payment_Line_Item__c(
                ASI_MFM_PO_Line_Item__c = selected_pol.id, ASI_MFM_Payment__c = paymentId, ASI_MFM_PO_Line_Currency__c = selected_pol.ASI_MFM_Currency__c,
                // 2014-10-16		Axel@introv
                // Issue Log #44, modify layout
                //ASI_MFM_PO_Line_Remaining_Amount__c = selected_pol.ASI_MFM_Remaining_Balance__c,
                //ASI_MFM_PO_Line_Description__c = selected_pol.ASI_MFM_List_Item_Description__c,                
                //ASI_MFM_Payment_Amount__c = exchange_rate == null || exchange_rate == 0? null : (selected_pol.ASI_MFM_Remaining_Balance__c / exchange_rate).setScale(2, roundingMode.half_up),
                ASI_MFM_CN_POLineAmount__c = selected_pol.ASI_MFM_Amount__c, //ASI_MFM_CN_Invoice_Amount__c = null,//20160525,Leo@Elufa// = exchange_rate == null || exchange_rate == 0? null : (selected_pol.ASI_MFM_Remaining_Balance__c / exchange_rate).setScale(2, roundingMode.half_up),
                ASI_MFM_PO__c = selected_pol.ASI_MFM_PO__c,ASI_MFM_Sub_Brand__c = selected_pol.ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c = selected_pol.ASI_MFM_A_C_Code__c,ASI_MFM_POL_Receipt_Amount__c = selected_pol.ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_PO_Amount__c = selected_pol.ASI_MFM_Amount__c,
                ASI_MFM_tax_amount__c = 0,
                ASI_MFM_PO_Remark__c = selected_pol.ASI_MFM_PO_Remark__c,
                ASI_MFM_Receipt_but_no_Paid__c = selected_pol.ASI_MFM_CN_Receipt_Amount__c - selected_pol.ASI_MFM_CN_Paid_Amount__c,
                ASI_MFM_CN_Invoice_Amount__c = selected_pol.ASI_MFM_CN_ReceiptNotPaid__c == null || payment.ASI_MFM_VAT_Rate__c == null ? null : selected_pol.ASI_MFM_CN_ReceiptNotPaid__c * (1+payment.ASI_MFM_VAT_Rate__c/100) //20160525,Leo@Elufa
                );
                
                if (this.defPaymentLIRT != null) payment_item.RecordTypeId = this.defPaymentLIRT.Id;
                // Use ASI_MFM_MassCreateAndUpdateController.RTDEVNAME_MASTER if you have only one record type
                // Use Record Type developer name if you have more than 1 record type
                mcauC.addNewRowByInfo(DEF_RT_PAYMENT_LI_CN, payment_item);
            }
            else{
            	payment_item = new ASI_MFM_Payment_Line_Item__c();
            }

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
    public ASI_MFM_CN_InputPaymentItemsController thisController { get {return this;} set; }
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