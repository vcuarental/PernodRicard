/* Filename:    ASI_MFM_CN_InputReceiptItemsController.cls
 * Author:      Michael Yip (Introv Limited)
 * Purpose:     Controller class of ASI_MFM_CN_InputPOReceiptItemsPage
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2012-11-18   michael.yip@introv.com      Created
 * 2014-09-04   michael.yip@introv.com      change filter criteria of po line item in search
 *                                            - Remaining balance > 0 => != 0
 *                                            - po amount > 0 is removed
 * 2014-09-10   michael.yip@introv.com      exclude Free Good PO non-admin user (Not yet implemented)
 * 
 */

public with sharing class ASI_MFM_CN_InputReceiptItemsController implements ASI_MFM_SFObjSelectTableAbstract, ASI_MFM_MassCreateAndUpdateAbstract {
  
    private static final String DEF_RT_PAYMENT_LI_HK = 'ASI_MFM_CN_PO_Receipt_item';
    
    public string paymentId {get; set;}
    public string POID {set;get;}
    public ASI_MFM_PO__c PO {set;get;}
    public string initSupplierNum {get; set;}
    public string po_filter {get; set;} 
    //20151019 Ben @ Elufa
    Public List<SelectOption> fiscalYearOption { get; set; }
    Public String fiscalYear { get; set; }
    //End
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
    public ASI_MFM_objectPickListHelper budgetOwnerPickList { get; set;}
    public boolean editReceiptDate {get;set;}
    public string returnID {set;get;}
    public id recID {set;get;}
    public boolean admin{get;set;}
    public boolean Ischeck{get;set;}
    public boolean showall{get;set;}
    Public Boolean isProcurement {Get; Set;} //20170307, Elufa
    
    // Constructor if coming from PO
    /*public ASI_MFM_CN_InputReceiptItemsController(){
        POID = apexpages.currentPage().getParameters().get('poid');
        PO = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_PO__c') + ' where id = :POID');
        payment = new ASI_MFM_PO_Receipt__c();
        insert payment;
        paymentid = payment.id;
        returnID = POID;
    }*/
    
    public pagereference createPOReceipt(){
        POID = apexpages.currentPage().getParameters().get('poid');
        recID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_CN_PO_Receipt');
        system.debug(poid);
        if(POID != null && POID != ''){
            PO = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_PO__c', 'ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c') + ' where id = :POID');//20151019 Ben @ Elufa add ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c 
            payment = new ASI_MFM_PO_Receipt__c(currencyISOcode = 'CNY',recordtypeid=recID);
            insert payment;
            paymentid = payment.id;
            payment = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_PO_Receipt__c', 'recordType.developerName') + ' where id = :paymentId');
            returnID = POID;
            system.debug('payment by PO ' + payment);
            po_filter = po.name;
            this.po_obj_filter = new ASI_MFM_PO__c(ASI_MFM_Budget_Owner__c = po.ASI_MFM_Budget_Owner__c, ASI_MFM_Currency__c = po.ASI_MFM_Currency__c, ASI_MFM_Supplier_Name__c = po.ASI_MFM_Supplier_Name__c, ASI_MFM_eMarket_Buyer__c = po.ASI_MFM_eMarket_Buyer__c); //20170307, Elufa, add supplier, emarket buyer
            
        }
        else{
            paymentId = apexpages.currentPage().getParameters().get('id');
            if(paymentId == null || paymentId == ''){
                payment = new ASI_MFM_PO_Receipt__c(currencyISOcode = 'CNY',recordtypeid=recID);
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
        //20151019 Ben @ Elufa
        fiscalYearOption = new List<SelectOption>();
        fiscalYearOption.add(new SelectOption('All', 'All'));
        date thisFY = date.today();
        String fy;
        if(thisFY.month() >= 7)
            fy = 'FY' + String.valueOf(thisFY.year() - 2000) + String.valueOf(thisFY.year() - 1999);
        else
            fy = 'FY' + String.valueOf(thisFY.year() - 2001) + String.valueOf(thisFY.year() - 2000);
        fiscalYearOption.add(new SelectOption(fy, fy));
        fy = 'FY' + String.valueOf(Integer.valueOf(fy.subString(2)) - 101);
        fiscalYearOption.add(new SelectOption(fy, fy));
        //End
        init();
        /*if(POID != null){
            po_obj_filter.ASI_MFM_Currency__c = 'CNY';
        }*/
        return null;
    }
        
    public ASI_MFM_CN_InputReceiptItemsController(ApexPages.StandardController stdSetController) {
        
    }
    
    public void init(){
        user u = [select userRole.developerName, asi_mfm_country__c, ASI_MFM_Team__c, Name from user where id = :userInfo.getUserId()]; //20170307, Elufa
        isProcurement = u.ASI_MFM_Team__c != NULL && u.ASI_MFM_Team__c != '' && u.ASI_MFM_Team__c == 'Procurement' ? TRUE : FALSE; //20170307, Elufa
        subBrandPickList = new ASI_MFM_ObjectPickListHelper('ASI_MFM_PO_Line_Item__c','ASI_MFM_Sub_brand_Code__c','1000','ASI_MFM_Active_for_MFM__c = true');  
        budgetOwnerPickList = new ASI_MFM_ObjectPickListHelper('ASI_MFM_PO__c','ASI_MFM_Budget_Owner__c','1000',' isActive = true and ASI_MFM_Country__c =\'CN\' ');               
        string PORecordtypeid = [select id from recordType 
        where sobjectType = 'ASI_MFM_PO__c' and developerName = 'ASI_MFM_CN_PO' limit 1].id;
        if(this.po_obj_filter == null)
            this.po_obj_filter = new ASI_MFM_PO__c(ASI_MFM_Budget_Owner__c = userInfo.getUserId(),recordtypeid = PORecordtypeid);
        this.pol_obj_filter = new ASI_MFM_PO_Line_Item__c();
        
// 2014.08.21 change starts by twinkle           
        //Map<id, UserRole> MRole = new map<id, UserRole>([Select id, name from UserRole where name like 'CN Finan%' or name like 'CN BA%']);
        
        String StrGroupId;
        for (Group g : [SELECT id, name FROM Group where group.name='ASI MFM CN PO Receipt Admin']){
           StrGroupId = g.id;
        }
        system.debug(StrGroupId);
        
        Set<id> SGroupMemberIDs = new Set<id>();
        for (GroupMember gm : [SELECT Id, UserOrGroupId  FROM GroupMember where GroupId =:StrGroupId]){
            SGroupMemberIDs.add(gm.UserOrGroupId);
        }
        
                
        editReceiptDate = false;
        // logic to control who can edit receiptDate
        if(SGroupMemberIDs.contains(userInfo.getUserId()) || SGroupMemberIDs.contains(userInfo.getUserRoleId())){
            editReceiptDate = true;
            showall = true;
        }
// 2014.08.21 change ends by twinkle  
     
        if(payment.ASI_MFM_Receipt_Date__c == null){
            payment.ASI_MFM_Receipt_Date__c = date.today();
        }
        
        this.componentControllerMap = new Map<String, ASI_MFM_ComponentInterface>();
        
        // Modified by Michael Yip (Introv) 04Sep2014 for change in po line item filter criteria
        init_search = 'ASI_MFM_Remaining_Balance__c != 0 and ASI_MFM_PO__r.ASI_MFM_FY_End_Date__c >= TODAY and (ASI_MFM_PO_Status__c = \'Final\' or ASI_MFM_PO_Status__c = \'Complete\')';
        //init_search = 'ASI_MFM_Remaining_Balance__c > 0 and ASI_MFM_PO_Amount__c > 0 and (ASI_MFM_PO_Status__c = \'Final\' or ASI_MFM_PO_Status__c = \'Complete\')';
        //Need validation on user' role (BA, finance, Admin)
        /*if(editReceiptDate == false){
            init_search += ' and (ASI_MFM_PO__r.ASI_MFM_PO_Type__c != \'Emarket\' and ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c != \'61202305\' )';
        }*/ //20170307, Elufa
        if(editReceiptDate == false){
            if(isProcurement)
                init_search += ' and (ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c != \'61202305\' )';
            else
            	init_search += ' and (ASI_MFM_PO__r.ASI_MFM_PO_Type__c != \'Emarket\' and ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c != \'61202305\' )';
        }
        
        raised_by_filter = userInfo.getUserId();
        if(raised_by_filter != null){
            init_search_with_header_info = init_search + ' and ASI_MFM_PO__r.createdbyid = \'' + raised_by_filter + '\'';
        }
        if((po_obj_filter.ASI_MFM_Budget_Owner__c != null)){
            init_search_with_header_info = init_search + ' and ASI_MFM_PO__r.ASI_MFM_Budget_Owner__c = \'' + po_obj_filter.ASI_MFM_Budget_Owner__c + '\'';
        }
        //20170307, Elufa
		If(po_obj_filter.ASI_MFM_Supplier_Name__c != null)
		{
			init_search_with_header_info = init_search + ' AND ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c = \'' + po_obj_filter.ASI_MFM_Supplier_Name__c + '\'';
		}
		If(po_obj_filter.ASI_MFM_eMarket_Buyer__c != null)
		{
			init_search_with_header_info = init_search + ' AND ASI_MFM_PO__r.ASI_MFM_eMarket_Buyer__c = \'' + po_obj_filter.ASI_MFM_eMarket_Buyer__c + '\'';
		}
		//20170307, Elufa
        if(po_filter != null){
            init_search_with_header_info += ' and ASI_MFM_PO__r.name = \''  + String.escapeSingleQuotes(po_filter) + '\'';
        }
        //remove default
        init_search_with_header_info += ' and ASI_MFM_PO__r.name = \'lllll' + '\'';
        
        system.debug('Search string:' + init_search_with_header_info);
                
// 2013.07.17 change ends       
        //this.po_obj_filter = new ASI_MFM_PO__c(ASI_MFM_Currency__c = payment.ASI_MFM_Currency__c == null ? '' : payment.ASI_MFM_Currency__c);
        //List<RecordType> paymentLIRTs = [SELECT Id FROM RecordType WHERE SobjectType = 'ASI_MFM_PO_Receipt_Item__c' AND DeveloperName = :DEF_RT_PAYMENT_LI_HK];
        //this.defPaymentLIRT = paymentLIRTs.size() > 0 ? paymentLIRTs[0] : null;
        
        RecordType paymentLIRT = Global_RecordTypeCache.getRtRec('ASI_MFM_PO_Receipt_Item__c'+DEF_RT_PAYMENT_LI_HK);
        this.defPaymentLIRT = paymentLIRT!=null ? paymentLIRT : null;
    }
    
    public void updatePOReceipt(){
        update payment;
        //payment = database.query(ASI_MFM_Function.buildQuery('ASI_MFM_PO_Receipt__c', 'recordType.developerName') + ' where id = :paymentId');
    }
    
    public void FilterPOItems() {
        string whereStatm = init_search;
        system.debug('PO Filter: ' + po_filter);
// 2013.07.17 change starts
        if (Ischeck == true){
        
            whereStatm = init_search.remove('ASI_MFM_Remaining_Balance__c != 0 and');
			whereStatm = whereStatm.remove('ASI_MFM_PO__r.ASI_MFM_FY_End_Date__c >= TODAY and ');
        }
        
        if (po_filter != null && po_filter.trim() != '') {
            whereStatm += ' and ASI_MFM_PO__r.name like \'' + String.escapeSingleQuotes(po_filter.trim()) + '%\'';
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
        //20151019 Ben @ Elufa
        if(fiscalYear != 'All'){
            whereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c Like \'' + fiscalYear + '\'';
        }
        //End
        //20170307, Elufa
		If(po_obj_filter.ASI_MFM_Supplier_Name__c != null)
		{
			whereStatm += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c = \'' + po_obj_filter.ASI_MFM_Supplier_Name__c + '\'';
		}
		If(po_obj_filter.ASI_MFM_eMarket_Buyer__c != null)
		{
			whereStatm += ' and ASI_MFM_PO__r.ASI_MFM_eMarket_Buyer__c = \'' + po_obj_filter.ASI_MFM_eMarket_Buyer__c + '\'';
		}
		//20170307, Elufa
		
        
        //throw new ASI_MFM_Function.MFMException(whereStatm);
// 2013,07.17 change ends     
                
        ASI_MFM_SFObjSelectTableController sobjstController = (ASI_MFM_SFObjSelectTableController)this.getComponentController('selectTable');
        if (sobjstController != null) {
            system.debug('whereStatm');
            system.debug(whereStatm);
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
            
            //20151204 Ben @ Elufa System
            ASI_MFM_PO_Line_Item__c addiPOLine = new ASI_MFM_PO_Line_Item__c();
            if(!test.isRunningTest())
            	addiPOLine = [SELECT id, ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c, ASI_MFM_CN_Paid_Amount__c FROM ASI_MFM_PO_Line_Item__c WHERE id =: selected_pol.id];
            //End
            
            decimal exchange_rate;
            /*if (selected_pol.ASI_MFM_Currency__c == payment.ASI_MFM_Currency__c) {
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
            }*/
            
            decimal tmpReceiptAmount = 0;
            if(selected_pol.ASI_MFM_Receipt_ytd__c != null && selected_pol.ASI_MFM_CN_Receipt_Amount__c != null)
            {
                if(selected_pol.ASI_MFM_Receipt_ytd__c > selected_pol.ASI_MFM_CN_Receipt_Amount__c)
                    tmpReceiptAmount = selected_pol.ASI_MFM_Receipt_ytd__c;
                else
                    tmpReceiptAmount = selected_pol.ASI_MFM_CN_Receipt_Amount__c;
            }
            else
            {
                if(selected_pol.ASI_MFM_Receipt_ytd__c != null && selected_pol.ASI_MFM_CN_Receipt_Amount__c == null)
                    tmpReceiptAmount = selected_pol.ASI_MFM_Receipt_ytd__c;
                else if(selected_pol.ASI_MFM_Receipt_ytd__c == null && selected_pol.ASI_MFM_CN_Receipt_Amount__c != null)
                    tmpReceiptAmount = selected_pol.ASI_MFM_CN_Receipt_Amount__c;
                else if(selected_pol.ASI_MFM_Receipt_ytd__c == null && selected_pol.ASI_MFM_CN_Receipt_Amount__c != null)
                    tmpReceiptAmount = 0;
            }
            //20151105 Ben @ Elufa System
			Boolean isExpired = FALSE;
            if(addiPOLine.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c != NULL && addiPOLine.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c != '' ){
                Integer fy = Integer.valueOf(addiPOLine.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c.subString(2));
                Integer nowFY;
                if(date.today().month() >= 7){
                    nowFY = ( ( date.today().year() - 2000 ) * 100 ) + ( date.today().year() - 1999 );
                }else{
                    nowFY = ( ( date.today().year() - 2001 ) * 100 ) + ( date.today().year() - 2000 );
                }
                
                isExpired = nowFY > fy ? TRUE : FALSE;
                
            }
            //End
            ASI_MFM_PO_Receipt_Item__c payment_item = new ASI_MFM_PO_Receipt_Item__c(
                ASI_MFM_PO_Line_Item__c = selected_pol.id, 
                ASI_MFM_PO_Receipt__c = paymentId,
                
                //20191030:AM@introv - remove logic, simply default = PO amount
                //ASI_MFM_Amount__c = isExpired ? addiPOLine.ASI_MFM_CN_Paid_Amount__c : tmpReceiptAmount,//20151203 Ben @ Elufa System
                ASI_MFM_Amount__c = selected_pol.ASI_MFM_Amount__c,
                
                // 2014-10-16       Axel@introv
                // Change PO Receipt Screen Layout
                //ASI_MFM_List_Item_Description_Temp__c = selected_pol.ASI_MFM_List_Item_Description__c,
                ASI_MFM_CN_POLineAmount__c = selected_pol.ASI_MFM_Amount__c,
                ASI_MFM_Sub_brand_temp__c = selected_pol.ASI_MFM_Sub_brand_Code__c,
                ASI_MFM_A_C_Code_Temp__c = selected_pol.ASI_MFM_A_C_Code__c,
                ASI_MFM_Currency_Temp__c = selected_pol.ASI_MFM_Currency__c,
                PO_Line_Item_Receipt_Amount_Temp__c = selected_pol.ASI_MFM_CN_Receipt_Amount__c,
                ASI_MFM_Remaining_Receipt_Balance_Temp__c = selected_pol.ASI_MFM_CN_Remaining_Receipt_Balance__c,
                ASI_MFM_Suggested_Receipt_YTD_Temp__c = selected_pol.ASI_MFM_Receipt_YTD__c,
                ASI_MFM_PO_Remark__c = selected_pol.ASI_MFM_PO_Remark__c,
                ASI_MFM_PO__c = selected_pol.ASI_MFM_PO__c
                );
            if (this.defPaymentLIRT != null) payment_item.RecordTypeId = this.defPaymentLIRT.Id;
            // Use ASI_MFM_MassCreateAndUpdateController.RTDEVNAME_MASTER if you have only one record type
            // Use Record Type developer name if you have more than 1 record type
            if(mcauC!=null) mcauC.addNewRowByInfo(DEF_RT_PAYMENT_LI_HK, payment_item);
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
    public ASI_MFM_CN_InputReceiptItemsController thisController { get {return this;} set; }
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