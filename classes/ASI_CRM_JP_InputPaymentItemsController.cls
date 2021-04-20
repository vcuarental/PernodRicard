/*********************************************************************************
 * Name:ASI_CRM_JP_InputPaymentItemsController
 * Description: Controller to Handle Payment Invoices items. Related to Mass Create and Update Controller. Code from MFM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Conrad          Created
 * 24/11/2014       Laputa: Conrad          Added the filtering part for Purchase Contract Line Item
 * 02/12/2014       Laputa: Conrad          Start Implementation of SPTD FOC and Cash Purchase Payment recordtypes
*********************************************************************************/
public with sharing class ASI_CRM_JP_InputPaymentItemsController implements ASI_CRM_JP_SFObjSelectTableAbstract, ASI_CRM_JP_MassCreateAndUpdateAbstract {
    
    private String DEF_RT_PAYMENT_LI_CRM {get;set;} 
    
    public string paymentId {get; set;}       
    public ASI_CRM_Purchase_Contract__c contract_obj_filter {get; set;}
    public ASI_CRM_Purchase_Contract_Line_Item__c contractL_obj_filter {get; set;}
    public string init_search {get; private set;}   
    public string init_search_with_header_info {get; private set;}
    public ASI_CRM_Payment_Invoice__c payment {get; private set;}   
    
    public String contractNoFilter {get;set;}
    public String contractOwnerFilter {get;set;}
    public String contractBS_Retailer_ShiptoFilter {get;set;}
    public String outlet_Filter {get;set;}
    public String itemGroup_Filter {get;set;}
    public String payTo_Filter {get;set;}
    public String priceOption_Filter {get;set;}
    public String orderByOpt_Filter {get;set;}
    public String orderByDirection = '';
    public String PriceNumber_Filter1 {get;set;}
    public String PriceNumber_Filter2 {get;set;}
    public boolean isPriceRanged{get;set;}
    
    public String ownerNameFilter {get;set;}
    private RecordType defPaymentLIRT;
    public boolean isAccounting {get;set;}
    public boolean isSalesAdmin {get;set;}
    public boolean isFinal {get;set;}
    public boolean isSubmitted {get;set;}
    public boolean hasEditAccess {get;set;}
    public String recordtypeOpt{get;set;}
    public boolean isCashRebate;
    
    public final Set<String> groupExceptionList = new Set<String>{'ASI_CRM_JP_Accounting'};
    public final Set<String> groupExceptionListSales = new Set<String>{'ASI_CRM_JP_Sales_Admin'};

    public ASI_CRM_JP_InputPaymentItemsController(ApexPages.StandardSetController stdSetController) {
        hasEditAccess = true;
        //stdSetController.setPagesize(10);         
        this.componentControllerMap = new Map<String, ASI_CRM_ComponentInterface>();
        paymentId = apexpages.currentPage().getParameters().get('id');  
        recordtypeOpt = apexpages.currentPage().getParameters().get('recordtypeOpt'); 
        payment = [SELECT ID, name, ASI_CRM_Status__c, recordtype.developername,
                        ASI_CRM_Pay_To__c, ASI_CRM_Pay_To__r.Name, ownerid, recordtypeid, ASI_CRM_Total_Invoice_Amount__c , ASI_CRM_Total_Taxable_Amount__c,
                        ASI_CRM_Invoice_No__c, ASI_CRM_Invoice_Date__c, ASI_CRM_Payment_Date__c, ASI_CRM_Tax_Rate__c,
                        ASI_CRM_Journal_Voucher__c, ASI_CRM_Remarks__c,
                        ASI_CRM_From_Month__c, ASI_CRM_To_Month__c
                        FROM ASI_CRM_Payment_Invoice__c 
                        where id = :paymentId];
                        
        DEF_RT_PAYMENT_LI_CRM = '';
        
        UserRecordAccess recordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = : userinfo.getuserid() AND RecordId = : payment.id].get(0);
        this.hasEditAccess = recordAccess.HasEditAccess;
        
        if(payment.recordtype.developername == 'ASI_CRM_JP_Indirect_Rebate_Invoice') {
            DEF_RT_PAYMENT_LI_CRM = 'ASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item';
        }
        if(payment.recordtype.developername == 'ASI_CRM_JP_SPTD_Cash_Invoice') {
            DEF_RT_PAYMENT_LI_CRM = 'ASI_CRM_JP_SPTD_Cash_Invoice_Line_Item';
        }
        if(payment.recordtype.developername == 'ASI_CRM_JP_SPTD_FOC_Invoice') {
            DEF_RT_PAYMENT_LI_CRM = 'ASI_CRM_JP_SPTD_FOC_Invoice_Line_Item';
        }
        if(payment.recordtype.developername == 'ASI_CRM_JP_Cash_Invoice' && recordtypeOpt == 'AP') {
            DEF_RT_PAYMENT_LI_CRM = 'ASI_CRM_JP_SPTD_Cash_Invoice_Line_Item';
        }
        if(payment.recordtype.developername == 'ASI_CRM_JP_Cash_Invoice' && recordtypeOpt == 'Rebate') {
            DEF_RT_PAYMENT_LI_CRM = 'ASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item';
        }
        
        string user_name = userInfo.getFirstName();
        if (user_name == null) {
            user_name = userInfo.getLastName();
        }
        else {
            user_name += ' ' + userInfo.getLastName();
        }
        
        String firstName = userInfo.getFirstName();
        String lastName =  userInfo.getLastName();
        
        contractOwnerFilter = user_name;
        if(payment.recordtype.developername == 'ASI_CRM_JP_Indirect_Rebate_Invoice' || (payment.recordtype.developername == 'ASI_CRM_JP_Cash_Invoice' && recordtypeOpt == 'Rebate')) {
            payTo_Filter = payment.ASI_CRM_Pay_To__r.Name == null ? '' : payment.ASI_CRM_Pay_To__r.Name;
        } else {
            payTo_Filter = '';
        }

        
        String IDRebate = payment.recordtype.developername == 'ASI_CRM_JP_SPTD_Cash_Invoice' || payment.recordtype.developername == 'ASI_CRM_JP_SPTD_FOC_Invoice'? 
                            Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item') :
                            Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_Indirect_Rebate_Contract_Line_Item');
                            
        if(payment.recordtype.developername == 'ASI_CRM_JP_Cash_Invoice' && recordtypeOpt == 'AP'){
            IDRebate = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item');
        }
                            
        init_search = 'recordtypeID = \'' + IDRebate +'\' AND ASI_CRM_Purchase_Contract__r.ASI_CRM_Status__c = \'Activated\' AND ASI_CRM_Purchase_Contract__r.ASI_CRM_Remaining_Balance__c > 0 ';
        
        //Filter FOC payment methods only
        if(payment.recordtype.developername == 'ASI_CRM_JP_SPTD_FOC_Invoice') {
            init_search += ' AND (ASI_CRM_Payment_Method__c like \'FOC%\' OR ASI_CRM_Payment_Method__c like \'商品現品%\') ';
        }
        //Filter NOT FOC payment methods only
        if(payment.recordtype.developername.equals('ASI_CRM_JP_SPTD_Cash_Invoice') || (payment.recordtype.developername == 'ASI_CRM_JP_Cash_Invoice' && recordtypeOpt == 'AP') ) {
            init_search += ' AND ((NOT ASI_CRM_Payment_Method__c like \'FOC%\') AND (NOT ASI_CRM_Payment_Method__c like \'商品現品%\') ) ';
        }
        
        if(payment.recordtype.developername == 'ASI_CRM_JP_Indirect_Rebate_Invoice' || (payment.recordtype.developername == 'ASI_CRM_JP_Cash_Invoice' && recordtypeOpt == 'Rebate')) {
            init_search += ' AND ( (ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c <= : invoiceStartDate AND ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c >= : invoiceStartDate) ';
            init_search += ' OR (ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c >= : invoiceEndDate AND ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c <= : invoiceEndDate) ';
            init_search += ' OR (ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c > : invoiceStartDate AND ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c < : invoiceEndDate) ';
            init_search += ' OR (ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c <= : invoiceStartDate AND ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c = NULL) ) ';
        }

        init_search_with_header_info = init_search + ' and ASI_CRM_Purchase_Contract__r.owner.firstName = \'' + firstName + '\' and ASI_CRM_Purchase_Contract__r.owner.lastname = \'' + lastName + '\' ';    

        if(payment.recordtype.developername == 'ASI_CRM_JP_Indirect_Rebate_Invoice' || (payment.recordtype.developername == 'ASI_CRM_JP_Cash_Invoice' && recordtypeOpt == 'Rebate')) {
            init_search_with_header_info += ' AND ASI_CRM_Pay_To__r.name like \'' + String.escapeSingleQuotes(payTo_Filter.trim()) + '%\' ';
        }

        this.contract_obj_filter = new ASI_CRM_Purchase_Contract__c();
        this.contractL_obj_filter = new ASI_CRM_Purchase_Contract_Line_Item__c();
        List<RecordType> paymentLIRTs = [SELECT Id FROM RecordType WHERE SobjectType = 'ASI_CRM_Payment_Invoice_Line_Item__c' AND DeveloperName = :DEF_RT_PAYMENT_LI_CRM];
        this.defPaymentLIRT = paymentLIRTs.size() > 0 ? paymentLIRTs[0] : null;
        
        this.isFinal = false;
        this.isSubmitted = false;
        this.isSalesAdmin = false;
        
        if (payment.recordtype.developername.contains('Read_Only'))
            this.isFinal = true;
        
        if (payment.ASI_CRM_Status__c == 'Submitted' || payment.ASI_CRM_Status__c == 'Approval In Progress')
            this.isSubmitted = true;
           
        this.isAccounting = false;
        List<Group> relatedGroup = getGroupsForUser(userinfo.getuserid());
        for (Group i : relatedGroup)
        {
            if (groupExceptionList.contains(i.DeveloperName))
                this.isAccounting = true;
                
            if (groupExceptionListSales.contains(i.DeveloperName))
                this.isSalesAdmin = true;
        }
        
        // Add a second checking for Roles under a public group
        if(this.isAccounting == false) {
            this.isAccounting = checkRoleGroup(groupExceptionList);
        }
        
        // Add a second checking for Roles under a public group
        if(this.isSalesAdmin == false) {
            this.isSalesAdmin = checkRoleGroup(groupExceptionListSales);
        }
    }
    
    public Boolean getIsCashRebate(){
        if(recordtypeOpt == null){
            recordtypeOpt = apexpages.currentPage().getParameters().get('recordtypeOpt');
        }
        isCashRebate = false;
        if(recordtypeOpt == 'AP'){
            isCashRebate = true;
        }else if(recordtypeOpt == 'Rebate'){
            isCashRebate = false;
        }
        return isCashRebate;
    }
    
    public void checkPriceOption(){
        if(priceOption_Filter == 'Range'){
            isPriceRanged = true;
        }else{
            isPriceRanged = false;
        }  
    }
    
    public boolean checkRoleGroup(Set<String> groupException) {
        boolean isRoleGroup = false;
        
        List<group> genericGroup = [SELECT ID, Name, developername from group where developername IN : groupException LIMIT 1];
        if(genericGroup.size() > 0) {
            ID currentUserRoleID = userinfo.getuserroleid();
            ID genericGroupID = genericGroup.get(0).id;
                
            List<groupMember> genericGroupMemberList = [Select id, UserOrGroupId, GroupId from GroupMember where GroupId = : genericGroupID];
                
            List<group> userRoleGroup = [SELECT ID, name, developername, relatedID, type FROM Group WHERE relatedID = : currentUserRoleID];
            Set<ID> groupToRoleIDSet = new Set<ID>();
            for(group userRoleG : userRoleGroup) {
                groupToRoleIDSet.add(userRoleG.id);
            }
                
            for(groupMember grpMem : genericGroupMemberList) {
                if(groupToRoleIDSet.contains(grpMem.UserOrGroupId)) {
                    isRoleGroup = true;
                    return isRoleGroup;
                }
            }
        }
        
        return isRoleGroup;
    }
    
    public void orderByAsc() {
        orderByDirection = 'ASC';
        FilterContractItems();
        orderByDirection = '';
    }
    
    public void orderByDesc() {
        orderByDirection = 'DESC NULLS LAST';
        FilterContractItems();
        orderByDirection = '';
    }
    
    public void FilterContractItems() {
        string whereStatm = init_search;
        String orderByStatm = '';
        Set<String> parseNameString = null;
        
        if (contractNoFilter != null && contractNoFilter.trim() != '') {
            whereStatm += ' and ASI_CRM_Purchase_Contract__r.name like \'' + String.escapeSingleQuotes(contractNoFilter.trim()) + '%\'';
        }
        if (contractOwnerFilter != null && contractOwnerFilter.trim() != '') {
        
            parseNameString = new Set<String>(String.escapeSingleQuotes(contractOwnerFilter.trim()).split(' '));
            
            whereStatm += ' and (ASI_CRM_Purchase_Contract__r.owner.name like \'%' + String.escapeSingleQuotes(contractOwnerFilter.trim()) + '%\'';
            whereStatm += ' OR (ASI_CRM_Purchase_Contract__r.owner.firstname IN : parseNameString ';
            whereStatm += ' AND ASI_CRM_Purchase_Contract__r.owner.lastname IN : parseNameString ))';
        }
        if (contractBS_Retailer_ShiptoFilter != null && contractBS_Retailer_ShiptoFilter.trim() != '') {
            whereStatm += ' and ASI_CRM_Purchase_Contract__r.ASI_CRM_BS_Retailer_Ship_To__r.name like \'%' + String.escapeSingleQuotes(contractBS_Retailer_ShiptoFilter.trim()) + '%\'';
        }
        if (outlet_Filter != null && outlet_Filter.trim() != '') {
            whereStatm += ' and ASI_CRM_Purchase_Contract__r.ASI_CRM_Outlet__r.name like \'' + String.escapeSingleQuotes(outlet_Filter.trim()) + '%\'';
        }
        if (payTo_Filter != null && payTo_Filter.trim() != '') {
            whereStatm += ' and ASI_CRM_Pay_To__r.name like \'' + String.escapeSingleQuotes(payTo_Filter.trim()) + '%\'';
        }
        if (itemGroup_Filter != null && itemGroup_Filter.trim() != '') {
            whereStatm += ' and ASI_CRM_Item_Group__r.name like \'%' + String.escapeSingleQuotes(itemGroup_Filter.trim()) + '%\'';
        }
        if(PriceNumber_Filter1 != null && PriceNumber_Filter1.trim() != ''){
            if(priceOption_Filter == '='){
                whereStatm += ' and ASI_CRM_Unit_Price__c = ' + String.escapeSingleQuotes(PriceNumber_Filter1.trim());
            }else if(priceOption_Filter == '>'){
                whereStatm += ' and ASI_CRM_Unit_Price__c > ' + String.escapeSingleQuotes(PriceNumber_Filter1.trim());
            }else if(priceOption_Filter == '<'){
                whereStatm += ' and ASI_CRM_Unit_Price__c < ' + String.escapeSingleQuotes(PriceNumber_Filter1.trim());
            }else if(priceOption_Filter == 'Range' && PriceNumber_Filter2 != null && PriceNumber_Filter2.trim() != ''){
                whereStatm += ' and ASI_CRM_Unit_Price__c > ' + String.escapeSingleQuotes(PriceNumber_Filter1.trim());
                whereStatm += ' and ASI_CRM_Unit_Price__c < ' + String.escapeSingleQuotes(PriceNumber_Filter2.trim());
            }
        }
        
        if (orderByOpt_Filter != null && orderByOpt_Filter.trim() != '') {
            orderByStatm = String.escapeSingleQuotes(orderByOpt_Filter.trim());
        }
        
        if (orderByDirection.trim() != '' && orderByOpt_Filter != null && orderByOpt_Filter.trim() != '') {
            orderByStatm += ' ' + String.escapeSingleQuotes(orderByDirection.trim());
        }
        
        ASI_CRM_JP_SFObjSelectTableController sobjstController = (ASI_CRM_JP_SFObjSelectTableController)this.getComponentController('selectTable');
        if (sobjstController != null) {
            sobjstController.setDataFilter(whereStatm, parseNameString);
            if(!strListToStr(sobjstController.queryFieldList).contains('ASI_CRM_Purchase_Contract__c')){
                sobjstController.queryFieldList.add('ASI_CRM_Purchase_Contract__c');
            }
            sobjstController.orderByStr = orderByStatm;
            sobjstController.reloadData();
        }           
    }
    
    /**
     * Methods to implement the ASI_CRM_JP_SFObjSelectTableAbstract
     */
    
    public List<ASI_CRM_JP_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList() {
        return null;
    }
    
    public Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap() {
        return null;
    }
    
    public void sobjst_triggerActionForSObject(ASI_CRM_JP_SFObjSelectTableController controller, String actionKey, sObject sObj) {
        if (actionKey == 'add') {
            ASI_CRM_JP_MassCreateAndUpdateController mcauC = (ASI_CRM_JP_MassCreateAndUpdateController)this.getComponentController('massCreateAndUpdate');
            ASI_CRM_Purchase_Contract_Line_Item__c selected_cont = (ASI_CRM_Purchase_Contract_Line_Item__c)sObj;
            //TODO CRM JP Payment Request
            Decimal qty;
            Decimal promoAmt;
            
            String rebateType = '';
            ASI_CRM_Purchase_Contract_Line_Item__c contRemainingBalance = [SELECT ID, ASI_CRM_Rebate_Type__c, ASI_CRM_Remaining_Balance__c, ASI_CRM_Quantity__c FROM ASI_CRM_Purchase_Contract_Line_Item__c WHERE ID =  : selected_cont.id].get(0);
            rebateType = contRemainingBalance.ASI_CRM_Rebate_Type__c;
            
            if (DEF_RT_PAYMENT_LI_CRM.contains('Rebate')) {
                qty = null;
                promoAmt = null;
            } else {

                qty = contRemainingBalance.ASI_CRM_Quantity__c;
                promoAmt = selected_cont.ASI_CRM_Target_Volume__c;
            }
            
            ASI_CRM_Payment_Invoice_Line_Item__c payment_item = new ASI_CRM_Payment_Invoice_Line_Item__c(
                ASI_CRM_Purchase_Contract_Line_Item__c = selected_cont.id, 
                ASI_CRM_Contract_No__c =  selected_cont.ASI_CRM_Purchase_Contract__c,
                ASI_CRM_Payment_Invoice__c = paymentId,
                ASI_CRM_Actual_Quantity__c = qty,
                ASI_CRM_A_P_Entertainment_F_D_Code__c = 'A&P',
                ASI_CRM_BC_Code__c='B',
                ASI_CRM_Actual_Unit_Cost__c = selected_cont.ASI_CRM_Unit_Price__c,
                ASI_CRM_Sales_Result__c = promoAmt,
                ASI_CRM_Sys_BS_Retailer_Ship_To__c = selected_cont.ASI_CRM_BS_Retailer_Ship_To__c,
                ASI_CRM_SYS_Outlet__c = selected_cont.ASI_CRM_Outlet__c,
                ASI_CRM_Item_Group__c = selected_cont.ASI_CRM_Item_Group__r.name,
                ASI_CRM_Sys_Representative_SKU_Id__c = selected_cont.ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c,
                ASI_CRM_Sys_Alternative_SKU_Id__c = selected_cont.ASI_CRM_Item_Group__r.ASI_CRM_Alternative_SKU__c,
                ASI_CRM_SKU_Selection__c = 'Representative SKU',
                ASI_CRM_SKU__c= selected_cont.ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c,
                //ASI_CRM_AP_Code__c = selected_cont.ASI_CRM_Sys_AP_Code__c,
                ASI_CRM_Rebate_Type__c = rebateType
                );
                
             if(payment.recordtype.developername == 'ASI_CRM_JP_SPTD_FOC_Invoice') {
                 payment_item.ASI_CRM_AP_Code__c = selected_cont.ASI_CRM_Sys_AP_Code__c;
             }
                                 
            if (this.defPaymentLIRT != null) payment_item.RecordTypeId = this.defPaymentLIRT.Id;
            // Use ASI_MFM_MassCreateAndUpdateController.RTDEVNAME_MASTER if you have only one record type
            // Use Record Type developer name if you have more than 1 record type
            mcauC.addNewRowByInfo(DEF_RT_PAYMENT_LI_CRM, payment_item);
        }
    }

    /**
    ***  Method to select all items
    **/
    public void selectAllContractItems() {
        ASI_CRM_JP_SFObjSelectTableController sobjstController = (ASI_CRM_JP_SFObjSelectTableController)this.getComponentController('selectTable');
        ASI_CRM_JP_MassCreateAndUpdateController mcauC = (ASI_CRM_JP_MassCreateAndUpdateController)this.getComponentController('massCreateAndUpdate');
        if (sobjstController != null && mcauC != null) {
             
            Set<ID> contractLineID = new Set<ID>();
            
            for(ASI_CRM_JP_SFObjSelectTableController.SFObjSelectTableElement sObjectElement : sobjstController.tableEleList) {
                ASI_CRM_Purchase_Contract_Line_Item__c filteredContract = (ASI_CRM_Purchase_Contract_Line_Item__c)sObjectElement.sObj;
                contractLineID.add(filteredContract.id);
            }
            
            Map<ID, ASI_CRM_Purchase_Contract_Line_Item__c> contractLineHistory = new Map<ID, ASI_CRM_Purchase_Contract_Line_Item__c>([SELECT ID, ASI_CRM_Remaining_Balance__c, ASI_CRM_Rebate_Type__c, ASI_CRM_Quantity__c 
                                                                                                                                        FROM ASI_CRM_Purchase_Contract_Line_Item__c
                                                                                                                                        WHERE ID IN : contractLineID]);
            
            for(ASI_CRM_JP_SFObjSelectTableController.SFObjSelectTableElement sObjectElement : sobjstController.tableEleList) {
                
                if(sObjectElement.btnStage.containsKey('add')) {
                    if(sObjectElement.btnStage.get('add') != 1) {
                        sObjectElement.btnStage.put('add', 1);
                    } else {
                        continue;
                    }
                }
                
                ASI_CRM_Purchase_Contract_Line_Item__c filteredContract = (ASI_CRM_Purchase_Contract_Line_Item__c)sObjectElement.sObj;
                
                Decimal qty;
                Decimal promoAmt;
                String rebateType = contractLineHistory.get(filteredContract.id).ASI_CRM_Rebate_Type__c;
                
                
                if (DEF_RT_PAYMENT_LI_CRM.contains('Rebate')) {
                    qty = null;
                    promoAmt = null;
                } else {
                    qty = contractLineHistory.get(filteredContract.id).ASI_CRM_Quantity__c;
                    promoAmt = filteredContract.ASI_CRM_Target_Volume__c;
                }
                
                ASI_CRM_Payment_Invoice_Line_Item__c payment_item = new ASI_CRM_Payment_Invoice_Line_Item__c(
                    ASI_CRM_Purchase_Contract_Line_Item__c = filteredContract.id, 
                    ASI_CRM_Contract_No__c =  filteredContract.ASI_CRM_Purchase_Contract__c,
                    ASI_CRM_Payment_Invoice__c = paymentId,
                    ASI_CRM_Actual_Quantity__c = qty,
                    ASI_CRM_A_P_Entertainment_F_D_Code__c = 'A&P',
                    ASI_CRM_BC_Code__c='B',
                    ASI_CRM_Actual_Unit_Cost__c = filteredContract.ASI_CRM_Unit_Price__c,
                    ASI_CRM_Sys_BS_Retailer_Ship_To__c = filteredContract.ASI_CRM_BS_Retailer_Ship_To__c,
                    ASI_CRM_SYS_Outlet__c = filteredContract.ASI_CRM_Outlet__c,
                    ASI_CRM_Item_Group__c = filteredContract.ASI_CRM_Item_Group__r.name,
                    ASI_CRM_Rebate_Type__c = rebateType,
                    ASI_CRM_Sys_Representative_SKU_Id__c = filteredContract.ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c,
                    ASI_CRM_Sys_Alternative_SKU_Id__c = filteredContract.ASI_CRM_Item_Group__r.ASI_CRM_Alternative_SKU__c,
                    ASI_CRM_SKU_Selection__c = 'Representative SKU',
                    ASI_CRM_SKU__c= filteredContract.ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c,
                    //ASI_CRM_AP_Code__c = filteredContract.ASI_CRM_Sys_AP_Code__c,
                    ASI_CRM_Sales_Result__c = promoAmt
                    );
                    
                if(payment.recordtype.developername == 'ASI_CRM_JP_SPTD_FOC_Invoice') {
                    payment_item.ASI_CRM_AP_Code__c = filteredContract.ASI_CRM_Sys_AP_Code__c;
                }
                                 
                if (this.defPaymentLIRT != null) payment_item.RecordTypeId = this.defPaymentLIRT.Id;
                mcauC.addNewRowByInfo(DEF_RT_PAYMENT_LI_CRM, payment_item);
            }
            sobjstController.reloadData();
        }      
    }
    
    /**
     * Methods to implement the ASI_CRM_JP_MassCreateAndUpdateAbstract
     */
    
    public List<ASI_CRM_JP_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
        return null;
    }
    
    public PageReference mcau_triggerPageBlockAction(ASI_CRM_JP_MassCreateAndUpdateController controller, String actionKey) {
        return null;
    }
    
    public void mcau_triggerActionForSObject(ASI_CRM_JP_MassCreateAndUpdateController controller, String actionKey, sObject sObj) {
        ASI_CRM_Payment_Invoice_Line_Item__c payment_item = (ASI_CRM_Payment_Invoice_Line_Item__c)sObj;
        // TODO
        
        if (payment_item != null && payment_item.ASI_CRM_Purchase_Contract_Line_Item__c != null && actionKey == ASI_CRM_JP_MassCreateAndUpdateController.ACTION_REMOVE_NEW) {
            ASI_CRM_JP_SFObjSelectTableController selectTableC = (ASI_CRM_JP_SFObjSelectTableController)this.getComponentController('selectTable');
            // Revert the "add" button to "0" (0 = Add, 1 = Added) by mould record id (detail.MouldLookup__c)
            selectTableC.setBtnStageBySObjId(payment_item.ASI_CRM_Purchase_Contract_Line_Item__c, 'add', 0);
        }
    }
    
    /*
     * Methods and variables that extend the ASI_CRM_PageInterface
     */
    
    private static String DEF_CC_KEY = 'DEFAULT';
    private Map<String, ASI_CRM_ComponentInterface> componentControllerMap;
    public ASI_CRM_JP_InputPaymentItemsController thisController { get {return this;} set; }
    public void setComponentController(ASI_CRM_ComponentInterface cController) {
        this.componentControllerMap.put(DEF_CC_KEY, cController);
    }
    public void setComponentController(String key, ASI_CRM_ComponentInterface cController) {
        this.componentControllerMap.put(key, cController);
    }
    public ASI_CRM_ComponentInterface getComponentController() {
        return this.componentControllerMap.get(DEF_CC_KEY);
    }
    public ASI_CRM_ComponentInterface getComponentController(String key) {
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
    
    private String strListToStr(List<String> inputStrList) { return this.strListToStr(inputStrList, ','); }
    private String strListToStr(List<String> inputStrList, String delim) {
    String result = '';
    if (inputStrList != null && delim != null) {
      for (String ele : inputStrList) {
        result += delim + ele;
      }
    }
    if (result.length() >= delim.length()) {
      return result.substringAfter(delim);
    }
    return '';
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