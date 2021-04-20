public with sharing class ASI_MFM_HK_InputPOItemsController {
    
    public ASI_MFM_PO__c PO {get; private set;}
    //public ASI_MFM_Sub_brand__c brandObj{ get; set; }{brandObj = new ASI_MFM_Sub_brand__c();}
    public ASI_MFM_PO_Line_Item__c brandObj{ get; set; }{brandObj = new ASI_MFM_PO_Line_Item__c();}
    //public ASI_CRM_AccountsAdditionalField__c brandObj{ get; set; }{brandObj = new ASI_CRM_AccountsAdditionalField__c();}
    public ASI_MFM_PO_Line_Item__c searchObj { get; set; }
    public ASI_MFM_PO_Line_Item__c searchObj2 { get; set; }
    Public ASI_MFM_PO_Line_Item__c rowObjAll {Get; Set;}
    Public List<ASI_MFM_PO_Line_Item__c> del_results {Get; Set;}
    Public id TRRecTypeID {Get; Set;}{TRRecTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'); }
    Public id pid {Get; Set;}
    
    public string SB_Name {set;get;}
    public string SB_Name1 {set;get;}
    public string AC_Code {set;get;}
    public string AC_Code1 {set;get;}
    
    Public boolean isAllowEdit {set;get;}
    Public boolean isAllowAccess {set;get;}
    
    Public List<POLineObj> results {Get; Set;}
    Public Boolean allSelected {Get; Set;}
    Public List<SelectOption> subbrandCode {Get; Set;}
    Public List<SelectOption> acCode {Get; Set;}
    Public map<string, string> ACCodeMap {Get; Set;}
    Public map<string, string> sbCodeMap {Get; Set;}
    
    public String querySOQL;
    public id subBrandId ;
    public id brandId ;
    public id acCodeId;
    public id custId;
    
    //pagination variable
    Public String recordNumberDisplay {get;set;}//show current no out of total no.
    Public integer pageSize {Get; Set;}{pageSize = 100;}// to set up the pageSize
    Public Boolean disablePrevious {Get; Set;}
    Public Boolean disableNext {Get; Set;}
    Public integer totalSize {Get; Set;}
    Public integer counter {Get; Set;}
    
    public ASI_MFM_HK_InputPOItemsController(apexpages.standardSetController sc) {
        pid = apexpages.currentPage().getParameters().get('id');
        PO = database.query(ASI_MFM_function.buildQuery('ASI_MFM_PO__c', 'ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c, ASI_MFM_Plan__r.ownerId') + ' where id = :pid');
        
        if (po.ASI_MFM_Status__c == 'Draft'){
            isAllowEdit = true;
        }else{
            isAllowEdit  = false;
        }
        isAllowAccess = true;
        if (po.ASI_MFM_PO_Type__c == 'eMarket' && UserInfo.getUserId() != PO.ASI_MFM_eMarket_Buyer__c){
            isAllowAccess = false;
            Apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'You can not access the page.'));
        }
        
        //for(ASI_MFM_PO_Line_Item__c obj : [SELECT id, FROM ASI_MFM_PO_Line_Item__c, ASI_MFM_Spread_by_Months__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_Customer_Name__c, ASI_MFM_List_Item_Description__c, ASI_MFM_Amount__c, ASI_MFM_PO_Percentage__c, ASI_MFM_G_L_Date__c, ASI_MFM_Invoice_Number__c WHERE ASI_MFM_PO__c = : pid]){
            
        //}
        //results = 
        
        //20170504
        //brandObj = new ASI_MFM_Sub_brand__c();
        searchObj = new ASI_MFM_PO_Line_Item__c();
        searchObj2 = new ASI_MFM_PO_Line_Item__c();
        rowObjAll = new ASI_MFM_PO_Line_Item__c();
        
        getACCodeNSubbrandMap();
        if(pid != Null)
            search();
    }
    
    public void getACCodeNSubbrandMap(){
        
        sbCodeMap = new map<string, string>();        
        ACCodeMap = new map<string, string>();
        acCode = new List<selectOption>();
        subbrandCode = new List<selectOption>();
        acCode.add(new selectOption('', 'None'));
        subbrandCode.add(new selectOption('', 'None'));
        
        list<ASI_MFM_A_C_Code__c> accodeList = [SELECT id, Name FROM ASI_MFM_A_C_Code__c WHERE recordType.developerName Like 'ASI_MFM_HK_A_C_Code' and ASI_MFM_Active__c = true ORDER BY Name]; 
        if (accodeList.size() > 0) {
            for (ASI_MFM_A_C_Code__c temp : accodeList){
                
                acCode.add(new selectOption(temp.id, temp.Name));
                ACCodeMap.put(temp.Name, temp.Id);
            }
        }

        list<ASI_MFM_Sub_brand__c> sbList = [SELECT id, Name FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Inactive__c = false and recordtype.developerName like 'ASI_HK_CRM_Sub_brand' ORDER BY Name]; 
        if (sbList.size() > 0) {
            for (ASI_MFM_Sub_brand__c temp : sbList){
                
                subbrandCode.add(new selectOption(temp.id, temp.Name));
                sbCodeMap.put(temp.Name, temp.Id);
            }
        }
    }
    
    public string getACnSBCode(string strName, string strType){
        
        string strReturn;
        
        if (strType == 'AC'){
            
            if (ACCodeMap.containskey(strName))
                strReturn = ACCodeMap.get(strName);
        }else if (strType == 'SB'){
            
            if (sbCodeMap.containskey(strName))
                strReturn = sbCodeMap.get(strName);
        }
        return strReturn;
    }
    
    //20170504 Introv
    Public void search(){
        
        totalSize = Database.countquery('SELECT COUNT() FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__c = \'' + pid + '\'');
        results = new List<POLineObj>();
        
        counter = 0;
        
        if (totalSize > 0){
            querySOQL = 'SELECT Name, ASI_MFM_Pay_Acc__c, ASI_MFM_A_C_Code__c, ASI_MFM_PO_Percentage__c, ASI_MFM_Invoice_Number__c, ASI_MFM_A_C_Code__r.Name, ASI_MFM_Sub_brand_Code__r.Name, ASI_MFM_PO__c, ASI_MFM_Spread_by_Months__c, ASI_MFM_Customer_Name__c,ASI_MFM_List_Item_Description__c, ASI_MFM_Sub_brand_Code__c,  ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c, ASI_MFM_Amount__c, ASI_MFM_G_L_Date__c, RecordTypeId, ASI_MFM_Synced__c FROM ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c = \'' + pid + '\' ';
            
            if (SB_Name != null && SB_Name != ''){
                subBrandId = getACnSBCode(SB_Name , 'SB');
                querySOQL += ' and ASI_MFM_Sub_brand_Code__c =:subBrandId ';
            }
            
            if (brandObj.ASI_MFM_Brand_Lookup__c != null){
                
                brandId = brandObj.ASI_MFM_Brand_Lookup__c;
                querySOQL += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c =:brandId ';
                System.debug('brandId:' + brandId + ';'  );
            }
            
            if (AC_Code != null && AC_Code != ''){
                
                acCodeId = getACnSBCode(AC_Code, 'AC');
                querySOQL += ' and ASI_MFM_A_C_Code__c =:acCodeId ';
            }
            
            if (searchObj.ASI_MFM_Customer_Name__c != null){
                
                custId = searchObj.ASI_MFM_Customer_Name__c;
                querySOQL += ' and ASI_MFM_Customer_Name__c =:custId ';
            }
            
            if (searchObj.ASI_MFM_G_L_Date__c != null) {
                
                String fromDate = DateTime.newInstance(searchObj.ASI_MFM_G_L_Date__c.year(),searchObj.ASI_MFM_G_L_Date__c.month(),searchObj.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
                querySOQL += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
            }
            
            if (searchObj2.ASI_MFM_G_L_Date__c != null) {
                String toDate = DateTime.newInstance(searchObj2.ASI_MFM_G_L_Date__c.year(),searchObj2.ASI_MFM_G_L_Date__c.month(),searchObj2.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
                querySOQL += ' AND ASI_MFM_G_L_Date__c    < ' + toDate + ''; 
            }
            
            querySOQL += ' ORDER BY Name ASC limit ' + pageSize;
            
            searchCurrentPage();
        }else{
            results = new List<POLineObj>();
        }
    }
    
    public void searchCurrentPage(){
        
        try{
            
            results = new List<POLineObj>();
            
            disablePrevious = getDisablePrevious();
            disableNext = getDisableNext();
            recordNumberDisplay = '(' + String.valueOf(counter + 1)+ ' - ' + String.valueOf(pageSize + (counter) > totalSize ? totalSize : pageSize + (counter) ) + ' of ' + String.valueOf(totalSize) + ')';
            
            List<ASI_MFM_PO_Line_Item__c > poList = Database.query(querySOQL + + ' OFFSET '+ String.valueof(counter));
            
            for (ASI_MFM_PO_Line_Item__c pobj: poList){
                POLineObj poO = new POLineObj();
                
                poO.id = pobj.Name;
                poO.ACCode = pobj.ASI_MFM_A_C_Code__r.Name;
                poO.SBCode = pobj.ASI_MFM_Sub_brand_Code__r.Name;
                poO.ppl = pobj;
                poO.selected = true;
                
                results.add(poO);      
            }                      
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }
        
    }
    
    public Class POLineObj{
        public String id{ 
            get{
                if(String.isBlank(id)) {
                    return null;
                }
                return id;
            } 
            set; }
        public string SBCode {set;get;}
        public string ACCode {set;get;}
        public Boolean selected {get; set;}
        public ASI_MFM_PO_Line_Item__c ppl {get; set;}
    }
    
    public PageReference save(){
        if(results == null) return null;
        PageReference redirect;
        Boolean isRedirect = onCommitted();
        if (isRedirect)
        {
            redirect = new PageReference('/'+ pid); 
        }else{
            redirect = null;
        }
        
        return redirect;   
    }
    public void quickSave(){
        if(results != null) {
            PageReference redirect;
            Boolean isRedirect = onCommitted();
            if (isRedirect)
            {
                search(); 
            }else{
                redirect = null;
            }
        }
    }
    public boolean onCommitted(){
        
        if(results == null) return false;
        
        Set<id> setAC = new Set<id>();
        //2014-08-07 Stella Sing Check Validation of required field (Page layout is not set to required, only style)
        boolean isBlanked = false;
        for (POLineObj rpl : results){
            if (rpl.selected){
                if (rpl.ppl.ASI_MFM_Customer_Name__c == null){
                    rpl.ppl.ASI_MFM_Customer_Name__c.addError('Required field.');
                    isBlanked = true;
                }
                if (rpl.ppl.ASI_MFM_List_Item_Description__c == null || rpl.ppl.ASI_MFM_List_Item_Description__c == ''){
                    rpl.ppl.ASI_MFM_List_Item_Description__c.addError('Required field.');
                    isBlanked = true;
                }
                if (rpl.ppl.ASI_MFM_Sub_brand_Code__c == null){
                    rpl.ppl.ASI_MFM_Sub_brand_Code__c.addError('Required field.');
                    isBlanked = true;
                }
                if (rpl.ppl.ASI_MFM_A_C_Code__c == null){
                    rpl.ppl.ASI_MFM_Sub_brand_Code__c.addError('Required field.');
                    isBlanked = true;
                }else{
                    // [SH] 2018-11-07
                    setAC.add(rpl.ppl.ASI_MFM_A_C_Code__c);
                }
            }
        }
        //A/C Code map
        Map<Id, ASI_MFM_A_C_Code__c> acMap = new Map<Id, ASI_MFM_A_C_Code__c>([Select Id, ASI_MFM_Reporting_Category__c from ASI_MFM_A_C_Code__c where id IN: setAC]);
        
        // [SH] 2018-11-07
        for(POLineObj rpl : results){
            if(rpl.selected){
                if (rpl.ppl.ASI_MFM_A_C_Code__c != null){
                    if(po.ASI_MFM_AP_AD__c == 'A&P' && acMap.get(rpl.ppl.ASI_MFM_A_C_Code__c).ASI_MFM_Reporting_Category__c == 'Sales Reduction'){
                        rpl.ppl.ASI_MFM_A_C_Code__c.addError('You need to choose A&P A/C Code');
                        isBlanked = true;
                    }else if (po.ASI_MFM_AP_AD__c == 'A&D' && acMap.get(rpl.ppl.ASI_MFM_A_C_Code__c).ASI_MFM_Reporting_Category__c != 'Sales Reduction'){
                        rpl.ppl.ASI_MFM_A_C_Code__c.addError('You need to choose A&D A/C Code');
                        isBlanked = true;
                    }
                }
            }                
        }
        //---------------Validation end (by Stella Sing) ------------------------------------------
        if (!isBlanked){
            List<ASI_MFM_PO_Line_Item__c > savePOLineList = new List<ASI_MFM_PO_Line_Item__c >();
            for (POLineObj rpl : results){
                if (rpl.selected){
                    
                    ASI_MFM_PO_Line_Item__c ppl = new ASI_MFM_PO_Line_Item__c();
                    
                    ppl = rpl.ppl;
                    
                    if (ppl.ASI_MFM_PO__c == null){
                        ppl.ASI_MFM_PO__c = pid;
                    }
                    /*ppl.ASI_MFM_List_Item_Description__c = rpl.ppl.ASI_MFM_List_Item_Description__c;
                    //ppl.ASI_MFM_Sub_brand_Code__c = rpl.ppl.ASI_MFM_Sub_brand_Code__c;
                    ppl.ASI_MFM_Sub_brand_Code__c = rpl.ppl.ASI_MFM_Sub_brand_Code__c;
                    //ppl.ASI_MFM_AP_Code__c = rpl.ppl.ASI_MFM_AP_Code__c;
                    ppl.ASI_MFM_AP_Code__c = rpl.ppl.ASI_MFM_AP_Code__c
                    ppl.ASI_MFM_Customer_Name__c = rpl.ppl.ASI_MFM_Customer_Name__c;
                    ppl.ASI_MFM_Quantity__c = rpl.ppl.ASI_MFM_Quantity__c;
                    ppl.ASI_MFM_Unit_Price__c = rpl.ppl.ASI_MFM_Unit_Price__c;
                    ppl.ASI_MFM_UOM__c = rpl.ppl.ASI_MFM_UOM__c;
                    if (rpl.ppl.ASI_MFM_G_L_Date__c != null )
                        ppl.ASI_MFM_G_L_Date__c = rpl.ppl.ASI_MFM_G_L_Date__c;
                    else 
                        ppl.ASI_MFM_G_L_Date__c = Date.Today();
                    ppl.ASI_MFM_Amount__c = rpl.ppl.ASI_MFM_Amount__c;
                    ppl.ASI_MFM_Pay_Acc__c = rpl.ppl.ASI_MFM_Pay_Acc__c;
                    ppl.ASI_MFM_Next_Year__c = rpl.ppl.ASI_MFM_Next_Year__c;*/
                    if(ppl.recordtypeid == Null)
                        ppl.recordtypeid = TRRecTypeID;
                    
                    savePOLineList.add(ppl);
                }
            }
            
            System.Savepoint sp = database.setSavepoint();
            Boolean isRedirect = false;
            
            try {
                upsert savePOLineList;
                if (del_results != null && del_results.size() >0){
                    delete del_results;
                    del_results.clear();
                }
                isRedirect = true;
            } catch (DmlException dmle) {
                database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,dmle.getMessage()));
            } catch (Exception e) {
                database.rollback(sp);
            }   
            
            return isRedirect; 
        }else{
            return false;
        }
    }
    
    public void APPLY() { //user clicked beginning
        
        for (POLineObj poO : results)
        {
            System.debug('poO.selected ' + poO.selected );
            if (poO.selected == true )
            {    
                if (rowObjAll.ASI_MFM_Customer_Name__c != null )
                    poO.ppl.ASI_MFM_Customer_Name__c = rowObjAll.ASI_MFM_Customer_Name__c;
                if (rowObjAll.ASI_MFM_List_Item_Description__c != null && rowObjAll.ASI_MFM_List_Item_Description__c != '')
                    poO.ppl.ASI_MFM_List_Item_Description__c = rowObjAll.ASI_MFM_List_Item_Description__c;
                if (SB_Name1 != null && SB_Name1 != '')
                    poO.ppl.ASI_MFM_Sub_brand_Code__c = getACnSBCode(SB_Name1, 'SB');
                if (AC_Code1 != null && AC_Code1 != '')
                    poO.ppl.ASI_MFM_A_C_Code__c = getACnSBCode(AC_Code1, 'AC');
                if (rowObjAll.ASI_MFM_G_L_Date__c != null )
                    poO.ppl.ASI_MFM_G_L_Date__c = rowObjAll.ASI_MFM_G_L_Date__c;
            }
        }
    }
    
    public PageReference DELETESELECTED() { //user clicked beginning
        del_results = new List<ASI_MFM_PO_Line_Item__c>();
        for (POLineObj rpl : results){
            if (rpl.selected == true )
            {
                if( rpl.ppl.id != null)
                {
                    del_results.add(rpl.ppl);
                }
            }
        }
        if (del_results!= null && del_results.size() > 0)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Please click Save to confirm the deletion. There are ' + del_results.size() + ' records to be deleted.'));
       
         return null;
    }
    public PageReference CLONESELECTED() { //user clicked beginning
        POLineObj selected_rpl;
        Boolean isSelected = false;
        List<POLineObj > cloneList = new List<POLineObj >();
         for (POLineObj rpl : results){
            if (rpl.selected == true)
            {
                selected_rpl = new POLineObj();
                
                selected_rpl.selected = true;
                selected_rpl.ppl = new ASI_MFM_PO_Line_Item__c();
                selected_rpl.ppl.ASI_MFM_List_Item_Description__c = rpl.ppl.ASI_MFM_List_Item_Description__c;
                selected_rpl.ppl.ASI_MFM_Sub_brand_Code__c = rpl.ppl.ASI_MFM_Sub_brand_Code__c;
                selected_rpl.ACCode = rpl.ACCode;
                selected_rpl.SBCode = rpl.SBCode;
                selected_rpl.ppl.ASI_MFM_Customer_Name__c = rpl.ppl.ASI_MFM_Customer_Name__c;
                selected_rpl.ppl.ASI_MFM_G_L_Date__c = rpl.ppl.ASI_MFM_G_L_Date__c;
                selected_rpl.ppl.ASI_MFM_Amount__c = rpl.ppl.ASI_MFM_Amount__c;
                selected_rpl.ppl.ASI_MFM_A_C_Code__c = rpl.ppl.ASI_MFM_A_C_Code__c;
                selected_rpl.ppl.ASI_MFM_Invoice_Number__c = rpl.ppl.ASI_MFM_Invoice_Number__c;
                selected_rpl.ppl.ASI_MFM_PO_Percentage__c = rpl.ppl.ASI_MFM_PO_Percentage__c;
                selected_rpl.ppl.recordtypeid = TRRecTypeID ;
                selected_rpl.ppl.ASI_MFM_Pay_Acc__c = rpl.ppl.ASI_MFM_Pay_Acc__c;//20171010 Introv
                cloneList.add(selected_rpl);
            }
         }
         results.addall(cloneList);
        
         return null;
    }
    public void ADDNEW() { //user clicked beginning
        if (results != null && results.size() > 0){
            POLineObj poO = new POLineObj();
            poO.ppl = new ASI_MFM_PO_Line_Item__c();
            poO.selected = true;
            poO.ppl.recordtypeid = TRRecTypeID ;
            poO.ppl.ASI_MFM_Pay_Acc__c = 'A';
            results.add(0,poO);   
        }else{
            results = new List<POLineObj>();
            POLineObj poO = new POLineObj();
            poO.ppl = new ASI_MFM_PO_Line_Item__c();
            poO.selected = true;
            poO.ppl.recordtypeid = TRRecTypeID ;
            poO.ppl.ASI_MFM_Pay_Acc__c = 'A';
            results.add(poO);   
        }
    }
    
    Public PageReference cacnel(){
        
        return new pageReference('/' + apexpages.currentPage().getParameters().get('id'));
    }
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        searchCurrentPage();
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= pageSize;
        searchCurrentPage();
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += pageSize;
        if(counter >= 1000)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Maximum no. of search result (1000 records) reached! Please narrow down your search range.'));
            return null;
        }
        searchCurrentPage();
        return null;
    }
    
    public PageReference End() { //user clicked end  
        counter = totalSize - Math.mod(totalSize, pageSize);
        if(counter >= 1000)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Maximum no. of search result (1000 records) reached! Please narrow down your search range.'));
            return null;
        }
        searchCurrentPage();
        return null;
    }
    
    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0) 
            disablePrevious = false;
        else 
            disablePrevious = true;
        return disablePrevious;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + pageSize < totalSize) 
            disableNext = false; 
        else 
            disableNext = true;
        return disableNext;
    }
    
    @RemoteAction
    public static String[] findSObjects(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        
        // create the filter text
        String filter = qry;
        //begin building the dynamic soql query
        
        String soql = 'select Id, Name from ' + obj + filter +' order by Name';
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
            sobjs = Database.query(soql);
            
            for(sObject sobj : sobjs){
                results.add(String.valueOf(sobj.get('Name'))); 
                System.debug('String.valueOf ' + String.valueOf(sobj.get('Name')));
            }
        }
        catch (QueryException e) {
            return null;
        }
        return results;
    }
}