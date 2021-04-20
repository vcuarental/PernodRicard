/* Filename:    ASI_MFM_CN_InputReceiptItemsController.cls
 * Author:      Michael Yip (Introv Limited)
 * Purpose:     Controller class of ASI_MFM_CN_InputPOReceiptItemsPage
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2012-11-18   michael.yip@introv.com      Created
 * 
 */

public with sharing class ASI_MFM_GF_InputReceiptItemsController implements ASI_MFM_SFObjSelectTableAbstract, ASI_MFM_MassCreateAndUpdateAbstract {
  
    private static final String DEF_RT_PAYMENT_LI_GF = 'ASI_MFM_GF_PO_Receipt_item';
    
    public string paymentId {get; set;}
    public string POID {set;get;}
    public ASI_MFM_PO__c PO {set;get;}
    public string initSupplierNum {get; set;}
    public string po_filter {get; set;} 
    public string supplier_filter {get; set;}
    public string plan_filter {get; set;}               
    public ASI_MFM_PO__c po_obj_filter {get; set;}
    public ASI_MFM_PO_Line_Item__c pol_obj_filter {get; set;}
    public string raised_by_filter {get; set;}
    public string init_search {get; private set;}   
    public string init_search_with_header_info {get; private set;}
    public ASI_MFM_PO_Receipt__c payment {get; private set;}   
    private RecordType defPaymentLIRT;
    public ASI_MFM_objectPickListHelper subBrandPickList { get; set;}
    public boolean editReceiptDate {get;set;}
    public string returnID {set;get;}
    public id recID {set;get;}
    public ASI_MFM_PO_Line_Item__c gl_fromDate { get; set; }
    public ASI_MFM_PO_Line_Item__c gl_toDate { get; set; }
    public string user_name {get; set;}
    
        
    public pagereference createPOReceipt(){
        POID = apexpages.currentPage().getParameters().get('poid');
        recID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_GF_PO_Receipt');
        system.debug(poid);
        if(POID != null && POID != ''){
            PO = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_PO__c') + ' where id = :POID');
            payment = new ASI_MFM_PO_Receipt__c(currencyISOcode = 'USD',recordtypeid=recID);
            insert payment;
            paymentid = payment.id;
            payment = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_PO_Receipt__c', 'recordType.developerName') + ' where id = :paymentId');
            returnID = POID;
            system.debug('payment by PO ' + payment);
            po_filter = po.name;
            this.po_obj_filter = new ASI_MFM_PO__c(OwnerID = po.OwnerID, ASI_MFM_Currency__c = po.ASI_MFM_Currency__c);
        }
        else{
            paymentId = apexpages.currentPage().getParameters().get('id');
            if(paymentId == null || paymentId == ''){
                payment = new ASI_MFM_PO_Receipt__c(currencyISOcode = 'USD',recordtypeid=recID);
                insert payment;
                paymentid = payment.id;
                payment = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_PO_Receipt__c', 'recordType.developerName') + ' where id = :paymentId');
            
            }
            else{  
                payment = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_PO_Receipt__c', 'recordType.developerName') + ' where id = :paymentId');
            }
            returnID = paymentId;
            system.debug('payment by PO receipt  ' + payment);
        }
        init();

        return null;
    }
        
    public ASI_MFM_GF_InputReceiptItemsController(ApexPages.StandardController stdSetController) {
        user_name = userInfo.getFirstName();
        
        if (user_name == null) {
            user_name = userInfo.getLastName();
        }
        else {
            user_name += ' ' + userInfo.getLastName();
        }
        
        raised_by_filter = user_name;  
    }
    
    public void init(){
        subBrandPickList = new ASI_MFM_ObjectPickListHelper('ASI_MFM_PO_Line_Item__c','ASI_MFM_Sub_brand_Code__c');  
        string PORecordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO');
        if(this.po_obj_filter == null)
            this.po_obj_filter = new ASI_MFM_PO__c(OwnerID = userInfo.getUserId(),recordtypeid = PORecordtypeid, ASI_MFM_Currency__c = '');
            
        this.pol_obj_filter = new ASI_MFM_PO_Line_Item__c();
                                
        if(payment.ASI_MFM_Receipt_Date__c == null){
            payment.ASI_MFM_Receipt_Date__c = date.today();
        }
        
        gl_fromDate = new ASI_MFM_PO_Line_Item__c ();
        gl_toDate = new ASI_MFM_PO_Line_Item__c ();    
        
        this.componentControllerMap = new Map<String, ASI_MFM_ComponentInterface>();
        
		//Wilken 20160922: Completed PO should not be able to receipt
        //init_search = 'ASI_MFM_CN_Remaining_Receipt_Balance__c <> 0 and ASI_MFM_PO_Amount__c <> 0 and (ASI_MFM_PO_Status__c = \'Final\' or ASI_MFM_PO_Status__c = \'Complete\')';
		init_search = 'ASI_MFM_CN_Remaining_Receipt_Balance__c <> 0 and ASI_MFM_PO_Amount__c <> 0 and (ASI_MFM_PO_Status__c = \'Final\')';

        if((po_obj_filter.OwnerID != null)){
            init_search_with_header_info = init_search + ' and ASI_MFM_PO__r.OwnerID = \'' + po_obj_filter.OwnerID + '\'';
        }
        if(po_filter != null){
            init_search_with_header_info += ' and ASI_MFM_PO__r.name = \''  + String.escapeSingleQuotes(po_filter) + '\'';
        }
        
        init_search_with_header_info += ' and ASI_MFM_PO_Raised_By__c = \'' + user_name + '\'';
        
        //remove default
        init_search_with_header_info += ' and ASI_MFM_PO__r.name = \'lllll' + '\'';
        
        system.debug('Search string:' + init_search_with_header_info);
                        
        RecordType paymentLIRT = Global_RecordTypeCache.getRtRec('ASI_MFM_PO_Receipt_Item__c'+DEF_RT_PAYMENT_LI_GF);
        this.defPaymentLIRT = paymentLIRT!=null ? paymentLIRT : null;
    }
    
    public void updatePOReceipt(){
        update payment;
        //payment = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_PO_Receipt__c', 'recordType.developerName') + ' where id = :paymentId');
    }
    
    public void FilterPOItems() {
        string whereStatm = init_search;
        system.debug('PO Filter: ' + po_filter);
        
        if (po_filter != null && po_filter.trim() != '') {
            whereStatm += ' and ASI_MFM_PO__r.name like \'' + String.escapeSingleQuotes(po_filter.trim()) + '%\'';
        }
        if (po_obj_filter.ASI_MFM_Currency__c != null && po_obj_filter.ASI_MFM_Currency__c.trim() != '') {
            whereStatm += ' AND ASI_MFM_Currency__c = \'' + String.escapeSingleQuotes(po_obj_filter.ASI_MFM_Currency__c) + '\'';
        }
        if (pol_obj_filter.ASI_MFM_Sub_brand_Code__c != null) {
            whereStatm += ' AND ASI_MFM_Sub_brand_Code__c = \'' + pol_obj_filter.ASI_MFM_Sub_brand_Code__c + '\'';
        }
        
        if (gl_fromDate.ASI_MFM_G_L_Date__c != null) {
            String fromDate = DateTime.newInstance(gl_fromDate.ASI_MFM_G_L_Date__c.year(),gl_fromDate.ASI_MFM_G_L_Date__c.month(),gl_fromDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            whereStatm += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
            System.debug('GL From Date Filter: ' + whereStatm);
        }
        if (gl_toDate.ASI_MFM_G_L_Date__c != null) {
            String toDate = DateTime.newInstance(gl_toDate.ASI_MFM_G_L_Date__c.year(),gl_toDate.ASI_MFM_G_L_Date__c.month(),gl_toDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            whereStatm += ' AND ASI_MFM_G_L_Date__c <= ' + toDate + ''; 
            System.debug('GL To Date Filter: ' + whereStatm);
        }
        
        if (raised_by_filter != null && raised_by_filter.trim() != '') {
            whereStatm += ' and ASI_MFM_PO_Raised_By__c like \'' + String.escapeSingleQuotes(raised_by_filter.trim()) + '%\'';
        }
        /*if((po_obj_filter.OwnerID != null)){
            whereStatm += ' and ASI_MFM_PO__r.OwnerID = \'' + po_obj_filter.OwnerID + '\'';
        }*/  

        System.debug('whereStatm: ' + whereStatm);
        
        ASI_MFM_SFObjSelectTableController sobjstController = (ASI_MFM_SFObjSelectTableController)this.getComponentController('selectTable');
        if (sobjstController != null) {
            sobjstController.setDataFilter(whereStatm);
            sobjstController.reloadData();
        }           
    }
    
    // Update by Michael 5 Feb 2014 for add all function
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

            ASI_MFM_PO_Receipt_Item__c payment_item = new ASI_MFM_PO_Receipt_Item__c(
                ASI_MFM_PO_Line_Item__c = selected_pol.id, 
                ASI_MFM_PO_Receipt__c = paymentId,
                ASI_MFM_Amount__c = selected_pol.ASI_MFM_CN_Remaining_Receipt_Balance__c,
                ASI_MFM_List_Item_Description_Temp__c = selected_pol.ASI_MFM_List_Item_Description__c,
                ASI_MFM_Sub_brand_temp__c = selected_pol.ASI_MFM_Sub_brand_Code__c,
                ASI_MFM_A_C_Code_Temp__c = selected_pol.ASI_MFM_A_C_Code__c,
                ASI_MFM_Currency_Temp__c = selected_pol.ASI_MFM_Currency__c,
                PO_Line_Item_Receipt_Amount_Temp__c = selected_pol.ASI_MFM_CN_Receipt_Amount__c,
                ASI_MFM_Remaining_Receipt_Balance_Temp__c = selected_pol.ASI_MFM_CN_Remaining_Receipt_Balance__c,
                ASI_MFM_PO_Remark__c = selected_pol.ASI_MFM_PO_Remark__c,
                ASI_MFM_PO__c = selected_pol.ASI_MFM_PO__c
                );
            if (this.defPaymentLIRT != null) payment_item.RecordTypeId = this.defPaymentLIRT.Id;
            // Use ASI_MFM_MassCreateAndUpdateController.RTDEVNAME_MASTER if you have only one record type
            // Use Record Type developer name if you have more than 1 record type
            System.debug('mcauC.addNewRowByInfo ' + DEF_RT_PAYMENT_LI_GF + ' ' + payment_item);
            if(mcauC!=null) mcauC.addNewRowByInfo(DEF_RT_PAYMENT_LI_GF, payment_item);
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
        ASI_MFM_PO_Receipt_Item__c payment_item = (ASI_MFM_PO_Receipt_Item__c)sObj;
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
    public ASI_MFM_GF_InputReceiptItemsController thisController { get {return this;} set; }
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