global class ASI_CRM_TW_Pass_Order_Ctrl {
    public Account objAccount { get; private set; }
    public Account acc { get;set; }
    public ASI_CRM_AccountsAdditionalField__c objAccountAddt { get; private set; }
    public ASI_HK_CRM_Visitation_Plan_Detail__c objVisitPlanDetail { get; private set; }
    public Boolean isQuickSave {get;set;}
    public String encodedAccountName{get;set;}

    Public Id idAcc { get; set; }
    Public Id idVPD { get; set; }
    public boolean editOnly { get; set; }
    public boolean allowEdit { get;set; }
    public String accountRegion { get;set; }

    public List<PassOrder> listPassOrder { get; private set; }
    public Map<String, PassOrder> mapRemovePassOrder = new Map<String, PassOrder>();
    public List<Integer> lstaddRows;
    public Integer index = 10000;
    public String theRow { get; set; }
    
    public List<ASI_CRM_AccountsAdditionalField__c> accountList { get;set; }
    List<string> conditions = new List<string>();
    private integer totalRecs = 0;
    private integer OffsetSize = 0;
    private integer LimitSize= 10;
    
    public String strChannelCode {
        get { return objAccountAddt.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c; }
        set { objAccountAddt.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c = value; }
    }
    
    public String strRegion {
        get { return objAccountAddt.ASI_CRM_Region__c; }
        set { objAccountAddt.ASI_CRM_Region__c = value; }
    }
    
    global class PassOrder {
        public String idRec { get; set; }
        public String idVPD { get; set; }
        public String strName { get; set; }
        public Date dteOrderDate { get; set; }
        public String idItemGroup { get; set; }
        public Decimal decQuantity { get; set; }
        public String idSupplier { get; set; }
        public String strRemark { get; set; }
        public String strVPDName { get; set; }
        public String strErrorMessageQty { get; set; }
        
        /*global Integer compareTo(Object compareTo) {                
            PassOrder compareToPassOrder = (PassOrder)compareTo;
            if (strName > compareToPassOrder.strName) return 1;
            else if (strName < compareToPassOrder.strName) return -1;
            else return 0;        
        }*/
    }
    
    public List<SelectOption> SupplierList {
        get{
            List<ASI_CRM_AccountsAdditionalField__c> listSupplier = [SELECT id, ASI_CRM_Account__c, Name FROM ASI_CRM_AccountsAdditionalField__c 
            WHERE RecordType.DeveloperName In ('ASI_CRM_TW_Outlet', 'ASI_CRM_TW_KeyAccount', 'ASI_CRM_TW_Wholesaler')
            AND ASI_CRM_Is_Supplier__c = true
            AND ASI_CRM_Account__r.ASI_TH_CRM_Region__c = :accountRegion
            ORDER BY Name];
            
            List<SelectOption> supplierList = new List<SelectOption>();
            
            for(ASI_CRM_AccountsAdditionalField__c supplier : listSupplier ){
                supplierList.add(new SelectOption(supplier.ASI_CRM_Account__c, supplier.Name));
            }
            return supplierList;
        }
    } 
    
    public List<SelectOption> ItemGroupList {
        get{
            ASI_CRM_TW_ItemGroup_UtilityCls utilityCls = new ASI_CRM_TW_ItemGroup_UtilityCls();
            String strCh = objAccountAddt.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c + ';'+ objAccountAddt.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c;
            List<ASI_MFM_Item_Group__c> listItemGroup = utilityCls.getItemGroup(strCh);
            
            List<SelectOption> ItemGroupList = new List<SelectOption>();
            
            for (ASI_MFM_Item_Group__c itm : listItemGroup) {
                ItemGroupList.add(new SelectOption(itm.id, itm.Name));
            }
            return ItemGroupList;
        }
    }
    
    public PageReference errorMessage() {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot edit the plan, as  it is 7 days before the plannd date.'));
        return null;
    }
    
    public ASI_CRM_TW_Pass_Order_Ctrl(ApexPages.StandardController stdController) {
        initValue(true);
    }
    
    public void setAccount() {
        initValue(false);
    }
    
    public void initValue(Boolean getValue) {
        lstaddRows = new List<Integer>();
        acc = new Account();
        allowEdit = true;
        
        if (getValue) {
        	idAcc = ApexPages.currentPage().getParameters().get('accid');
            idVPD = ApexPages.currentPage().getParameters().get('vpid');
        }
        
		editOnly = ApexPages.currentPage().getParameters().get('accid') != null;
        isQuickSave = true;
        
        if (idAcc != null) {
            List<Account> lstAccounts = [
                SELECT Id, Name, ASI_KOR_Customer_Code__c, ASI_TH_CRM_Region__c, ASI_HK_CRM_Address__c, Phone, 
                    Owner.Name, 
                    (SELECT Id, Name, Title, Birthdate, MobilePhone, Email FROM Contacts WHERE ASI_HK_CRM_Main_Contact__c = true)
                FROM Account 
                WHERE Id = :idAcc
                LIMIT 1];
            
            if (lstAccounts != null && lstAccounts.size() > 0)
            {
                objAccount = lstAccounts[0];
                accountRegion = objAccount.ASI_TH_CRM_Region__c;
                encodedAccountName = EncodingUtil.urlEncode(objAccount.Name, 'UTF-8');
            }
            
            // Obtain Account Additional (Customer) fields
            List<ASI_CRM_AccountsAdditionalField__c> lstAccAddt = [
                SELECT Id, Name, ASI_CRM_Channel__c, ASI_CRM_CN_Sub_Channel__r.Name,
                    ASI_CRM_CN_Sub_Channel__c, ASI_TH_CRM_OutletImage__c,
                    ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c,
                    ASI_TH_CRM_OutletImage__r.Name, ASI_CRM_Sales_Potential__c,
                    ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c, ASI_CRM_Region__c,
                    ASI_CRM_Longitude__c, ASI_CRM_Latitude__c,
                    ASI_CRM_Account_Segment__r.Name, ASI_CRM_TW_Action_Grade__r.Name
                FROM ASI_CRM_AccountsAdditionalField__c 
                WHERE ASI_CRM_Account__c = :idAcc
                LIMIT 1
            ];
            
            if (lstAccAddt == null || lstAccAddt.size() <= 0)
                throw new ASI_CRM_TW_Function.CRM_TW_Exception('Customer Record Not Found (Account Id: ' + idAcc + ')');
            else
                objAccountAddt = lstAccAddt[0];
            
            // Visitation Plan Detail
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> lstVPD = [
                SELECT Id, Name,
                    ASI_TH_CRM_Visit_Date_Time_From__c, ASI_TH_CRM_Visit_Date_Time_To__c, ASI_HK_CRM_Visit_Date__c,
                    ASI_HK_CRM_Visit_Objective__c, ASI_TH_CRM_Activity_Remarks__c,
                    ASI_HK_CRM_Cancellation_Reason__c, ASI_HK_CRM_Visitation_Plan__r.Name, ASI_CRM_Date_Difference_Actual_Planned__c, 
                    ASI_CRM_Cancel_Reason__c, ASI_CRM_Longitude__c, ASI_CRM_Latitude__c, ASI_CRM_Last_Distance_Calculation__c
                FROM ASI_HK_CRM_Visitation_Plan_Detail__c
                WHERE Id = :idVPD
            ];
    
            if (lstVPD != null && lstVPD.size() > 0)
                objVisitPlanDetail = lstVPD[0];
            
            // Page 5 - Pass Order Record
            listPassOrder = buildPassOrder();
            if (listPassOrder == null || listPassOrder.size() <= 0){
                PassOrder tempObjPassOrder = new PassOrder();
                
                if (objVisitPlanDetail != null) {
                	tempObjPassOrder.idVPD = idVPD;
                }
                
                if (objVisitPlanDetail != null) {
                	tempObjPassOrder.strVPDName = objVisitPlanDetail.Name;
                }
                
                listPassOrder.add(tempObjPassOrder);
            }
            system.debug(listPassOrder);
        }
        else {
            system.debug('no acc id assigned');
            allowEdit = false;
            isQuickSave = false;
        }
    }
    
    public void AddRow() {
        Map<Integer, PassOrder> mapCount = new Map<Integer, PassOrder>();

        Integer rowIndex;
        if (theRow == null)
            rowIndex = 0;
        else
            rowIndex = Integer.valueof(theRow) - 1;
        
        lstaddRows.add(rowIndex);     
        for(integer i = 0; i < listPassOrder.size(); i++){
            mapCount.put(i, listPassOrder[i]);
        }
        
        system.debug('listPassOrder: '+listPassOrder);
        if(mapCount != null && mapCount.size()>0 && lstaddRows != null && lstaddRows.size() > 0){   
            PassOrder order = new PassOrder();            
            Integer tempRow = lstaddRows[lstaddRows.size()-1];
            
            if (mapCount.get(tempRow) != null){
                order.idRec = '#'+lstaddRows.size();
                order.idItemGroup = mapCount.get(tempRow).idItemGroup;    
                order.decQuantity = mapCount.get(tempRow).decQuantity;
                order.idSupplier = mapCount.get(tempRow).idSupplier;
                order.strRemark = mapCount.get(tempRow).strRemark;
                order.dteOrderDate = mapCount.get(tempRow).dteOrderDate;
                
                if (objVisitPlanDetail != null) {
                	order.idVPD = objVisitPlanDetail.Id;
                    order.strVPDName = objVisitPlanDetail.Name;
                }

                listPassOrder.add(order);
            }
        }
        system.debug('listPassOrder: '+listPassOrder);
    }
    
    public void RemoveRow() {  
        Integer rowIndex;
        if (theRow == null)
            rowIndex = 0;
        else
            rowIndex = Integer.valueof(theRow)-1;
            
        mapRemovePassOrder.put(listPassOrder[rowIndex].idRec, listPassOrder[rowIndex]);
        listPassOrder.remove(rowIndex);
    }

    public PageReference quickSave() {
        Boolean saveSuccess = implSaveChanges();
        PageReference pageRef;

        if (saveSuccess) {
            if (editOnly) {
                if (isQuickSave) {
                    pageRef = Page.ASI_CRM_TW_Pass_Order_Page;
                    
                    if (idAcc != null && idVPD != null) {
                        listPassOrder = buildPassOrder();
                        pageRef.getParameters().put('accid', objAccount.id);
                        if (idVPD != null) {
                            pageRef.getParameters().put('vpid', idVPD);
                        }
                        pageRef.setRedirect(true);
                    }
                    else {
                        pageRef.setRedirect(false);
                    }
                }
                else
                {
                    if (idVPD != null) {
                        pageRef = new PageReference('/' + idVPD);
                    }
                    else {
                        pageRef = Page.ASI_CRM_TW_ViewAccount;
                        pageRef.getParameters().put('id', objAccount.id);
                    }
                    pageRef.setRedirect(true);
                }
            }
            else {
                if (isQuickSave) {
                    pageRef = Page.ASI_CRM_TW_Pass_Order_Page;
                    pageRef.setRedirect(false);
                }
                else
                {
                    pageRef = Page.ASI_CRM_TW_ViewAccount;
                    pageRef.getParameters().put('id', objAccount.id);
                    pageRef.setRedirect(true);
                }
            }
        }
        
        return pageRef;
    }
    
    public PageReference redirect() {
        PageReference pageRef = Page.ASI_CRM_TW_Pass_Order_Page;
        pageRef.getParameters().put('accid', idAcc);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /** To save record with draft flag = false, need passing all validation rules */
    public PageReference Save() {
        // Declaration
        Boolean blnValidation =  true; // Inital set to true
        isQuickSave = false;
        
        return quickSave();
    }
    
    public Boolean implSaveChanges() {
        // Declaration
        Boolean blnIsError = false;
            
        List<ASI_CRM_Pass_Order__c> lstUpsertPassOrder = new List<ASI_CRM_Pass_Order__c>();
        List<ASI_CRM_Pass_Order__c> lstRemovePassOrder = new List<ASI_CRM_Pass_Order__c>();
        Set<id> setRemovePassOrder = new Set<id>();
        
        system.debug('listPassOrder: '+listPassOrder);
        
        set<Id> setIds = new set<Id>();

        if (listPassOrder != null && listPassOrder.size() > 0) {
            for(PassOrder order : listPassOrder){                   
                ASI_CRM_Pass_Order__c tempPassOrder = new ASI_CRM_Pass_Order__c();    
                tempPassOrder.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Pass_Order__cASI_CRM_TW_Pass_Order');           
                
                if(!mapRemovePassOrder.containsKey(order.idRec)) {
                    if (order.idRec != null && order.idRec.contains('#')) {
                       order.idRec = null;
                    }
                    else {
                       setIds.add(order.idRec);  
                    }
                    
                    tempPassOrder.id = order.idRec;
                    tempPassOrder.ASI_CRM_Order_Date__c = order.dteOrderDate;
                    tempPassOrder.ASI_CRM_Account__c = objAccount.id;  
                    tempPassOrder.ASI_CRM_Item_Group__c = order.idItemGroup;
                    tempPassOrder.ASI_CRM_Supplier__c = order.idSupplier;     
                    tempPassOrder.ASI_CRM_Quantity_Btl_Box__c = order.decQuantity;
                    tempPassOrder.ASI_CRM_Remark__c = order.strRemark;
                    tempPassOrder.ASI_CRM_Visitation_Plan_Detail__c = order.idVPD;
                    
                    if (tempPassOrder.id != null && (tempPassOrder.ASI_CRM_Quantity_Btl_Box__c == NULL || tempPassOrder.ASI_CRM_Quantity_Btl_Box__c == 0)){
                        order.strErrorMessageQty = 'Please enter Quantity.';
                        blnIsError = true;
                    }
                    else if(tempPassOrder.id != null || 
                            (tempPassOrder.id == null && (tempPassOrder.ASI_CRM_Quantity_Btl_Box__c != NULL && tempPassOrder.ASI_CRM_Quantity_Btl_Box__c != 0)))
                        lstUpsertPassOrder.add(tempPassOrder);
                }
            }
        }
        
        if(mapRemovePassOrder != null && mapRemovePassOrder.size() > 0){
            lstRemovePassOrder = [SELECT Id FROM ASI_CRM_Pass_Order__c WHERE Id IN: mapRemovePassOrder.keySet()];
            delete lstRemovePassOrder;
        }
        system.debug('lstUpsertPassOrder: '+lstUpsertPassOrder);
        
        if (blnIsError == true) 
            return false;
        else {
            if (lstUpsertPassOrder != null && lstUpsertPassOrder.size() > 0) {
                upsert lstUpsertPassOrder;
                
                for (ASI_CRM_Pass_Order__c dbOrder : lstUpsertPassOrder) {
                    if (!setIds.contains(dbOrder.Id)) {
                        for (integer i = 0; i < listPassOrder.size(); i++) {
                            PassOrder order = listPassOrder[i];
                            
                            if (order.idRec == null) {
                                order.idRec = dbOrder.Id;
                                break;
                            }
                        }
                    }
                }
            }
            
            return true;
        } 
    }
    
    /** Get Current time in local-time zone */
    public Datetime getLocalTime(Datetime dt) {
        TimeZone tz = UserInfo.getTimeZone();
        return dt.AddSeconds(tz.getOffset(dt) / 1000);
    }
    
    /*** For Pass Order Page 5 */
    private List<PassOrder> buildPassOrder() {
        // Declaration
        List<PassOrder> templistPassOrder = new List<PassOrder>();
        
        if (idAcc != null && idVPD != null) {
            // Query Pass Order records
            List<ASI_CRM_Pass_Order__c> orders = [SELECT Id, Name, ASI_CRM_Account__c, ASI_CRM_Item_Group__c, ASI_CRM_Quantity_Btl_Box__c, 
                 ASI_CRM_Remark__c, ASI_CRM_Supplier__c, ASI_CRM_Order_Date__c, ASI_CRM_Visitation_Plan_Detail__c, ASI_CRM_Visitation_Plan_Detail__r.Name
                 FROM ASI_CRM_Pass_Order__c
                 WHERE ASI_CRM_Account__c = :idAcc
                 AND ASI_CRM_Visitation_Plan_Detail__c = :idVPD];
            
            for (ASI_CRM_Pass_Order__c order : orders) {
                PassOrder tempObjPassOrder = new PassOrder();
                tempObjPassOrder.idRec = order.id;
                tempObjPassOrder.dteOrderDate = order.ASI_CRM_Order_Date__c;
                tempObjPassOrder.strName = order.Name;
                tempObjPassOrder.idItemGroup = order.ASI_CRM_Item_Group__c;
                tempObjPassOrder.decQuantity = order.ASI_CRM_Quantity_Btl_Box__c;
                tempObjPassOrder.idSupplier = order.ASI_CRM_Supplier__c;
                tempObjPassOrder.strRemark = order.ASI_CRM_Remark__c;
                tempObjPassOrder.idVPD = order.ASI_CRM_Visitation_Plan_Detail__c;
                tempObjPassOrder.strVPDName = order.ASI_CRM_Visitation_Plan_Detail__r.Name;
                
                templistPassOrder.add(tempObjPassOrder);
                index++;
            }
        }
        
        return templistPassOrder;
    }

    /** Show error message */
    private void showPageMessage(ApexPages.Severity severity, String msg) {
        ApexPages.addMessage(new ApexPages.Message(severity, msg));
    }
    /** Show error message */
    private void showPageError(String msg) {
        showPageMessage(ApexPages.Severity.ERROR, msg);
    }
    
    public void searchAcc() {
        idAcc = null;
        objAccount = null;
        objAccountAddt = null;
        objVisitPlanDetail = null;
        
        totalRecs = 0;
        OffsetSize = 0;
        if (accountList != null && accountList.size() > 0) {
            accountList = null;
        }
        
        searchAccounts();
        conditions.clear();
    }
    
    public void searchAccounts() {
        if (accountList != null && !accountList.isEmpty()) {
            accountList.clear();
        }
        
        String strQuery = 'SELECT ASI_CRM_Account__r.id, ASI_CRM_Account__c, ASI_CRM_Account__r.ASI_KOR_Customer_Code__c, ASI_CRM_Account__r.Name, ' +
            				'ASI_CRM_CN_Sub_Channel__r.Name, ASI_CRM_Account__r.ASI_HK_CRM_Address__c, ASI_CRM_Account__r.Phone, ' +
            				'ASI_CRM_Account__r.Owner.Name  ' +
                			'FROM ASI_CRM_AccountsAdditionalField__c';
        
        conditions.add('RecordType.DeveloperName In (\'ASI_CRM_TW_Outlet\')');
        
        if (acc.Name != null && acc.Name != '') {
            conditions.add('Name Like \'%' + acc.Name +'%\' ');
        }
        
        if (conditions.size() > 0) {
            strQuery += ' WHERE ' + conditions[0];
            for (Integer i = 1; i < conditions.size(); i++)
                strQuery += ' AND ' + conditions[i];
        }

        system.debug('strQuery ==>' + strQuery );
        
        if (totalRecs != null && totalRecs == 0) {
            List<ASI_CRM_AccountsAdditionalField__c> accTemp = Database.query(strQuery);
            totalRecs = (accTemp != null && accTemp.size() > 0) ? accTemp.size() : 0;
        }
        
        // add sort and limits at the end  
        strQuery += ' ORDER BY Name ASC, CreatedDate DESC LIMIT :LimitSize OFFSET :OffsetSize';
        
        accountList = Database.query(strQuery);
    }
    
    public void FirstPage() {
        OffsetSize = 0;
        searchAccounts();
    }
    
    public void previous() {
        OffsetSize = (OffsetSize-LimitSize);
        searchAccounts();
    }
    
    public void next() {
        OffsetSize = OffsetSize + LimitSize;
        searchAccounts();
    }
    
    public void LastPage() {
        OffsetSize = totalrecs - math.mod(totalRecs, LimitSize);
        searchAccounts();
    }
    
    public boolean getprev() {
        if (OffsetSize == 0) {
            return true;
        }
        else { 
            return false;
        }
    }
    
    public boolean getnxt() {
        if ((OffsetSize + LimitSize) > totalRecs) {
            return true;
        }
        else {
            return false;
        }
    }
}