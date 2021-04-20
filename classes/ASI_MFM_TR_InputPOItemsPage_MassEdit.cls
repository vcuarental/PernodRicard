public with sharing class ASI_MFM_TR_InputPOItemsPage_MassEdit {
    //For Paging
    private integer counter = 0;  //keeps track of the offset
    private integer pageSize = 25;
    public integer totalSize; //used to show user the total size of the list
    
    public boolean disablePrevious {set;get;}
    public boolean disableNext {set;get;}
    public boolean isAllowEdit{set;get;}

    public String recordNumberDisplay {get;set;}//show current no out of total no.
    public String totalSizeSOQL;
    public String querySOQL; 
    public id pid;
    public id subBrandId ;
    public id brandId ;
    public id apCodeId;
    public id custId;
    public String TRRecTypeID;
    public List<POLineObj> results {get; set;}
    public ASI_MFM_PO__c po {get; private set;}
    public ASI_MFM_PO_Line_Item__c searchObj { get; set; }
    public boolean allSelected { get; set; }
    public ASI_MFM_Sub_brand__c brandObj{ get; set; }
    public ASI_MFM_PO_Line_Item__c gl_fromDate { get; set; }
    public ASI_MFM_PO_Line_Item__c gl_toDate { get; set; }
    
    public List<ASI_MFM_PO_Line_Item__c> del_results {get; set;}
    
    public ASI_MFM_PO_Line_Item__c rowObjAll { get; set; }
    public ASI_MFM_PO_Line_Item__c rowObj1 { get; set; }
    public ASI_MFM_PO_Line_Item__c rowObj2 { get; set; }
    public ASI_MFM_PO_Line_Item__c rowObj3 { get; set; }
    public ASI_MFM_PO_Line_Item__c rowObj4 { get; set; }
    public ASI_MFM_PO_Line_Item__c rowObj5 { get; set; }
    
    private map<string, string> APCode_Map {set;get;}
    private map<string, string> SBCode_Map {set;get;}
    public string SB_Name {set;get;}
    public string SB_Name1 {set;get;}
    public string AP_Code {set;get;}
    public string AP_Code1 {set;get;}
    
    public decimal getPOAmount(){
        decimal value = 0;
        for(POLineObj a : results){
            if (a.ppl.ASI_MFM_Amount__c != null)
                value += a.ppl.ASI_MFM_Amount__c;
        }
        return value;
    }
     public ASI_MFM_TR_InputPOItemsPage_MassEdit(ApexPages.StandardController controller) {
     }
    public ASI_MFM_TR_InputPOItemsPage_MassEdit(ApexPages.StandardSetController controller) {
        /*
        fyFrom = 'FY1314';
        fyTo = 'FY1415';        
        fyOptionList = new List<SelectOption>();
        fyOptionList = getFYList();
        */
        pid = apexpages.currentPage().getParameters().get('id');
        po = database.query(ASI_MFM_function.buildQuery('ASI_MFM_PO__c', 'ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c, ASI_MFM_Plan__r.ownerId, ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c, ASI_MFM_Plan__r.ASI_MFM_Location__c, ASI_MFM_Plan__r.Name') + ' where id = :pid');
        if (po.ASI_MFM_Status__c == 'Draft'){
            isAllowEdit = true;
        }else{
            isAllowEdit  = checkPermissionSet();
        }
        searchObj = new ASI_MFM_PO_Line_Item__c();
        brandObj = new ASI_MFM_Sub_brand__c();
        gl_fromDate = new ASI_MFM_PO_Line_Item__c ();
        gl_toDate = new ASI_MFM_PO_Line_Item__c ();    
        rowObjAll = new ASI_MFM_PO_Line_Item__c();
        rowObj1 = new ASI_MFM_PO_Line_Item__c();
        rowObj2 = new ASI_MFM_PO_Line_Item__c();
        rowObj3 = new ASI_MFM_PO_Line_Item__c();
        rowObj4 = new ASI_MFM_PO_Line_Item__c();
        rowObj5 = new ASI_MFM_PO_Line_Item__c();
        allSelected = true;
        
        Map<string, id> MRecType = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_PO_Line_Item__c');
        
        for (recordType rtt:rtList) {
            MRecType.put(rtt.DeveloperName, rtt.id);            
        }
        TRRecTypeID = MRecType.get('ASI_MFM_TR_PO_Line_Item');
        getAPCodeMap();
        search();
        
    }
    private static boolean checkPermissionSet(){
         String soql = 'SELECT PermissionSetId,AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = \'ASI_TR_MFM_Admin_User\'';
         System.debug('soql :' + soql + ';'  );
          //UserInfo.getUserId()
         List<PermissionSetAssignment> pmsList = database.query(soql);
         if (pmsList.size()>0 ){
             for(PermissionSetAssignment psa : pmsList)
             {
                 if (psa.AssigneeId  == UserInfo.getUserId())
                     return true;
             }
             return false;
         }else{
             return false;
         }
    }
    public void getAPCodeMap(){
        APCode_Map = new map<string, string>();
        list<ASI_MFM_AP_Code__c> TRAPList = [SELECT id, Name FROM ASI_MFM_AP_Code__c WHERE ASI_MFM_Inactive__c = false and ASI_MFM_TR_Rec_Type__c = :po.ASI_MFM_TR_Rec_Type__c]; 
        if (TRAPList.size() > 0) {
            for (ASI_MFM_AP_Code__c temp : TRAPList){
                APCode_Map.put(temp.Name, temp.Id);
            }
        }
        SBCode_Map = new map<string, string>();
        list<ASI_MFM_Sub_brand__c> TRSBList = [SELECT id, Name FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Inactive__c = false and ASI_MFM_TR_Rec_Type__c = :po.ASI_MFM_TR_Rec_Type__c]; 
        if (TRSBList.size() > 0) {
            for (ASI_MFM_Sub_brand__c temp : TRSBList){
                SBCode_Map.put(temp.Name, temp.Id);
            }
        }
    }
    public string getAPCode(string strName, string strType){
        string strReturn;
        if (strType == 'AP'){
            if (APCode_Map.containskey(strName))
                strReturn = APCode_Map.get(strName);
        }else if (strType == 'SB'){
            if (SBCode_Map.containskey(strName))
                strReturn = SBCode_Map.get(strName);
        }
        return strReturn;
    }
    public void search(){
           
         totalSize = Database.countquery('SELECT COUNT() FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__r.id = :pid');         
                       
        
         results = new List<POLineObj>();
         
         counter = 0;
         
         if (totalSize > 0){                
             querySOQL = 'SELECT Name,ASI_MFM_AP_Code__r.Name, ASI_MFM_Sub_brand_Code__r.Name, ASI_MFM_PO__c , ASI_MFM_Customer_Name__c,ASI_MFM_List_Item_Description__c, ASI_MFM_Sub_brand_Code__c,  ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c, ASI_MFM_AP_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_Quantity__c ,ASI_MFM_Unit_Price__c ,ASI_MFM_Amount__c, ASI_MFM_BU_Code__c,ASI_MFM_G_L_Date__c,ASI_MFM_UOM__c,ASI_MFM_Pay_Acc__c,ASI_MFM_Next_Year__c, ASI_MFM_Synced__c FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__r.id = :pid ';
             
             /*if (searchObj.ASI_MFM_Sub_brand_Code__c != null)
             {
                subBrandId = searchObj.ASI_MFM_Sub_brand_Code__c;
                querySOQL += ' and ASI_MFM_Sub_brand_Code__c =:subBrandId ';
             }*/
             if (SB_Name != null && SB_Name != '')
             {
                subBrandId = getAPCode(SB_Name , 'SB');
                querySOQL += ' and ASI_MFM_Sub_brand_Code__c =:subBrandId ';
             }
             if (brandObj.ASI_MFM_Brand__c  != null)
             {
              
                brandId = brandObj.ASI_MFM_Brand__c;
                querySOQL += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c =:brandId ';
                System.debug('brandId:' + brandId + ';'  );
           
             }
             System.debug('querySOQL:' + brandId + ';'  );
             /*
             if (searchObj.ASI_MFM_AP_Code__c != null)
             {
                apCodeId = searchObj.ASI_MFM_AP_Code__c;
                querySOQL += ' and ASI_MFM_AP_Code__c =:apCodeId ';
             }*/
             if (AP_Code != null && AP_Code != '')
             {
                apCodeId = getAPCode(AP_Code, 'AP');
                querySOQL += ' and ASI_MFM_AP_Code__c =:apCodeId ';
             }
             if (searchObj.ASI_MFM_Customer_Name__c != null)
             {
                custId = searchObj.ASI_MFM_Customer_Name__c;
                querySOQL += ' and ASI_MFM_Customer_Name__c =:custId ';
             }
             if (gl_fromDate.ASI_MFM_G_L_Date__c != null) {
                String fromDate = DateTime.newInstance(gl_fromDate.ASI_MFM_G_L_Date__c.year(),gl_fromDate.ASI_MFM_G_L_Date__c.month(),gl_fromDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
                querySOQL += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
             }
             if (gl_toDate.ASI_MFM_G_L_Date__c != null) {
                String toDate = DateTime.newInstance(gl_toDate.ASI_MFM_G_L_Date__c.year(),gl_toDate.ASI_MFM_G_L_Date__c.month(),gl_toDate.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
                querySOQL += ' AND ASI_MFM_G_L_Date__c    < ' + toDate + ''; 
             }
            
             querySOQL += ' ORDER BY Name ASC';
             searchCurrentPage();
         }else{
             results = new List<POLineObj>();
         }
                        
    }
    
    public void searchCurrentPage(){
        
        try{
            results = new List<POLineObj>();
             
            System.debug('querySOQL:' + querySOQL + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));
            
            disablePrevious = getDisablePrevious();
            disableNext = getDisableNext();
            recordNumberDisplay = '(' + String.valueOf(counter + 1)+ ' - ' + String.valueOf(totalSize > pageSize?pageSize:totalSize ) + ' of ' + String.valueOf(totalSize) + ')';
            
            List<ASI_MFM_PO_Line_Item__c > poList = Database.query(querySOQL + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));

            for (ASI_MFM_PO_Line_Item__c pobj: poList){
                  POLineObj poO = new POLineObj();
                  poO.id = pobj.Name;
                  poO.APCode = pobj.ASI_MFM_AP_Code__r.Name;
                  poO.SBCode = pobj.ASI_MFM_Sub_brand_Code__r.Name;
                  poO.ppl = pobj;
                  poO.selected = true;
                  results.add(poO);      
            }                      
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }
        
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
    public PageReference quickSave(){
         if(results != null) {
              PageReference redirect;
              Boolean isRedirect = onCommitted();
              /*if (isRedirect)
                {
                    search(); 
                }else{
                    redirect = null;
                }*/
            }
        
        PageReference pageRef = new PageReference('/apex/ASI_MFM_TR_InputPOItemsPage_MassEdit?id='+ pid); 
        pageRef.setRedirect(true);
        return pageRef;
     }
     
    public boolean onCommitted(){
        
        if(results == null) return false;
        
        Set<id> setAP = new Set<id>();
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
                /*
if (rpl.ppl.ASI_MFM_Sub_brand_Code__c == null){
rpl.ppl.ASI_MFM_Sub_brand_Code__c.addError('Required field.');
isBlanked = true;
}

if (rpl.ppl.ASI_MFM_AP_Code__c == null){
rpl.ppl.ASI_MFM_AP_Code__c.addError('Required field.');
isBlanked = true;
}*/
                if (rpl.APCode == null || rpl.APCode == ''){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'AP Code is required.'));
                    isBlanked = true;
                }else{
                    setAP.add(getAPCode(rpl.APCode, 'AP'));
                }
                if (rpl.SBCode == null || rpl.SBCode == ''){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sub-brand is required.'));
                    isBlanked = true;
                }
            }
        }
        
        // AP Code Map
        Map<Id, ASI_MFM_AP_Code__c> apMap = new Map<Id, ASI_MFM_AP_Code__c>([Select Id, ASI_MFM_AP_AD__c from ASI_MFM_AP_Code__c where id IN: setAP]);
        
        // [SH] 2018-11-07
        for(POLineObj rpl : results){
            if(rpl.selected){
                if (rpl.APCode != null){
                    if(po.ASI_MFM_AP_AD__c == 'A&P' && apMap.get(getAPCode(rpl.APCode, 'AP')).ASI_MFM_AP_AD__c == 'A&D'){
                        rpl.ppl.ASI_MFM_AP_Code__c.addError('You need to choose AP Code for A&P');
                        isBlanked = true;
                    }else if (po.ASI_MFM_AP_AD__c == 'A&D' && apMap.get(getAPCode(rpl.APCode, 'AP')).ASI_MFM_AP_AD__c == 'A&P'){
                        rpl.ppl.ASI_MFM_AP_Code__c.addError('You need to choose AP Code for A&D');
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
                    ppl.ASI_MFM_List_Item_Description__c = rpl.ppl.ASI_MFM_List_Item_Description__c;
                    //ppl.ASI_MFM_Sub_brand_Code__c = rpl.ppl.ASI_MFM_Sub_brand_Code__c;
                    ppl.ASI_MFM_Sub_brand_Code__c = getAPCode(rpl.SBCode, 'SB');
                    //ppl.ASI_MFM_AP_Code__c = rpl.ppl.ASI_MFM_AP_Code__c;
                    ppl.ASI_MFM_AP_Code__c = getAPCode(rpl.APCode, 'AP');
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
                    ppl.ASI_MFM_Next_Year__c = rpl.ppl.ASI_MFM_Next_Year__c;
                    ppl.recordtypeid = TRRecTypeID ;
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
        public string APCode {set;get;}
        public Boolean selected {get; set;}
        public ASI_MFM_PO_Line_Item__c ppl {get; set;}
    }
    public void onclickCheckbox() { //user clicked beginning
        System.debug('This method is for the check box quick trigger server side' );
        allSelected = false;     
    }
    public void onclickAllCheckbox() { //user clicked beginning
        System.debug('This method is for the check box quick trigger server side' );
        allSelected  = !allSelected ;
        System.debug('allSelected  ' +allSelected   );
        for (POLineObj poO : results)
        {
            poO.selected = allSelected ;
        }     
    }
    public void APPLY() { //user clicked beginning
             
        for (POLineObj poO : results)
        {
            System.debug('poO.selected ' + poO.selected );
            if (poO.selected == true )
            {
                System.debug('poO.ppl.ASI_MFM_List_Item_Description__c' + poO.ppl.ASI_MFM_List_Item_Description__c);
                 
                if (rowObjAll.ASI_MFM_Customer_Name__c != null )
                    poO.ppl.ASI_MFM_Customer_Name__c = rowObjAll.ASI_MFM_Customer_Name__c;
                if (rowObjAll.ASI_MFM_List_Item_Description__c != null && rowObjAll.ASI_MFM_List_Item_Description__c != '')
                    poO.ppl.ASI_MFM_List_Item_Description__c = rowObjAll.ASI_MFM_List_Item_Description__c;
                /*if (rowObjAll.ASI_MFM_Sub_brand_Code__c != null)
                    poO.ppl.ASI_MFM_Sub_brand_Code__c = rowObjAll.ASI_MFM_Sub_brand_Code__c;
                if (rowObjAll.ASI_MFM_AP_Code__c != null )
                    poO.ppl.ASI_MFM_AP_Code__c = rowObjAll.ASI_MFM_AP_Code__c;
                    */
                if (SB_Name1 != null && SB_Name1 != '')
                    poO.SBCode = SB_Name1;
                if (AP_Code1 != null && AP_Code1 != '')
                    poO.APCode = AP_Code1;
                if (rowObjAll.ASI_MFM_G_L_Date__c != null )
                    poO.ppl.ASI_MFM_G_L_Date__c = rowObjAll.ASI_MFM_G_L_Date__c;
                if (rowObjAll.ASI_MFM_Next_Year__c!= null )
                    poO.ppl.ASI_MFM_Next_Year__c = rowObjAll.ASI_MFM_Next_Year__c;
                System.debug('rowObjAll.ASI_MFM_List_Item_Description__c' + rowObjAll.ASI_MFM_List_Item_Description__c);
                System.debug('poO.ppl.ASI_MFM_List_Item_Description__c 2' + poO.ppl.ASI_MFM_List_Item_Description__c);
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
                //selected_rpl.ppl.ASI_MFM_Sub_brand_Code__c = rpl.ppl.ASI_MFM_Sub_brand_Code__c;
                //selected_rpl.ppl.ASI_MFM_AP_Code__c = rpl.ppl.ASI_MFM_AP_Code__c;
                selected_rpl.APCode = rpl.APCode;
                selected_rpl.SBCode = rpl.SBCode;
                selected_rpl.ppl.ASI_MFM_Customer_Name__c = rpl.ppl.ASI_MFM_Customer_Name__c;
                selected_rpl.ppl.ASI_MFM_Quantity__c = rpl.ppl.ASI_MFM_Quantity__c;
                selected_rpl.ppl.ASI_MFM_Unit_Price__c = rpl.ppl.ASI_MFM_Unit_Price__c;
                selected_rpl.ppl.ASI_MFM_UOM__c = rpl.ppl.ASI_MFM_UOM__c;
                selected_rpl.ppl.ASI_MFM_G_L_Date__c = rpl.ppl.ASI_MFM_G_L_Date__c;
                selected_rpl.ppl.ASI_MFM_Amount__c = rpl.ppl.ASI_MFM_Amount__c;
                selected_rpl.ppl.ASI_MFM_Pay_Acc__c = rpl.ppl.ASI_MFM_Pay_Acc__c;
                selected_rpl.ppl.ASI_MFM_Next_Year__c = rpl.ppl.ASI_MFM_Next_Year__c;
                selected_rpl.ppl.recordtypeid = TRRecTypeID ;
               cloneList.add(selected_rpl);
            }
         }
         results.addall(cloneList);
               /* isSelected = true;
            }else if (rpl.selected == true && isSelected == true)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Only Allow select one row to clone'));
                isSelected = false;
                break;
            }
         }
         if (isSelected)
            results.add(0,selected_rpl);
            */
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
        counter = totalSize - pageSize;    
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
    public static String[] findRecSObjects(string obj, string qry, string rec) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        Map <String,Schema.RecordTypeInfo> recordTypes = sot.getDescribe().getRecordTypeInfosByName(); system.debug('SH: recordtypes: ' + recordTypes);
        String recordTypeId = recordTypes.get(rec).getRecordTypeId();
        String checkRecSql = '';
        if (recordTypeId == null) {
            // recordTypeId not valid
            return null;
        }else
        {
            checkRecSql = ' where recordtypeid = \''+ recordTypeId + '\'';
        }
        // create the filter text
        String filter = ' like \'%' + String.escapeSingleQuotes(qry) + '%\'';
        //begin building the dynamic soql query
        //String soql = 'select Name from ' + obj + ' where Name like \'%' + String.escapeSingleQuotes(qry) + '%\' order by Name';
        
        String soql = 'select Name from ' + obj + checkRecSql  +' order by Name';
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
            if(!Test.isRunningTest())
                sobjs = Database.query(soql);
            
            for(sObject sobj : sobjs){
               results.add(String.valueOf(sobj.get('Name'))); 
            }
        }
        catch (QueryException e) {
            return null;
        }
        return results;
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
            if(!Test.isRunningTest())
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
   @RemoteAction
    public static String[] findCustSObjects(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        String filter;
        string[] spilqr = qry.split(';');
        if (spilqr[2] == 'ATR'){
            if (spilqr[0] == 'Commercial')
            {
                filter = spilqr[1] != 'Airline' && spilqr[1] != 'Key Account' ?   // Modified by 2017-08-18  Linus@introv  ****** Airline / Key Account 
                            ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'ATR\' and (ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('20') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('60') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('29') + '%\') and (ASI_MFM_Country_Code__c != \'' + String.escapeSingleQuotes('203') + '\' and ASI_HK_CRM_Location__c = \'' + String.escapeSingleQuotes(spilqr[1])  + '\')' :
                            spilqr[1] == 'Airline'?    
                                ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'ATR\' and (ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('20') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('60') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('29') + '%\') and (ASI_MFM_Country_Code__c = \'' + String.escapeSingleQuotes('241') + '\')':                         
                                ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'ATR\' and (ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('20') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('60') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('29') + '%\') and (ASI_MFM_Country_Code__c = \'' + String.escapeSingleQuotes('242') + '\')';   
            }else
            {
                filter = ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'ATR\' and (ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('22') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('62') + '%\') and ASI_MFM_Country_Code__c = \'' + String.escapeSingleQuotes('203') + '\'' ;
            }
        }
        else{
            Map <String,Schema.RecordTypeInfo> recordTypes = sot.getDescribe().getRecordTypeInfosByName();
            String recordTypeId = recordTypes.get('TR Customer').getRecordTypeId();
            filter = ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'JDF\' and recordtypeid = \''+ recordTypeId + '\'';
        }
        //begin building the dynamic soql query
        
        String soql = 'select Name from ' + obj + filter +' order by Name';
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
            if(!Test.isRunningTest())
                sobjs = Database.query(soql);
            
            for(sObject sobj : sobjs){
               results.add(String.valueOf(sobj.get('Name'))); 
            }
        }
        catch (QueryException e) {
            return null;
        }
        return results;
   }

}