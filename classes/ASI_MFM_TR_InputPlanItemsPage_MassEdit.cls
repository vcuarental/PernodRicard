public with sharing class ASI_MFM_TR_InputPlanItemsPage_MassEdit {
    //For Paging
    private integer counter = 0;  //keeps track of the offset
    private integer pageSize = 50;
    public integer totalSize; //used to show user the total size of the list
    
    public boolean disablePrevious {set;get;}
    public boolean disableNext {set;get;}

    public String recordNumberDisplay {get;set;}//show current no out of total no.
    public String totalSizeSOQL;
    public String querySOQL; 
    public id pid;
    public id subBrandId ;
    public id brandId ;
    public id apCodeId;
    public id custId;
    public String TRRecTypeID;
    public String ACRecTypeID; // Added By Alan Wong (Elufa) 20150714
    public List<PlanLineObj> results {get; set;}
    public ASI_MFM_Sub_brand__c brandObj{ get; set; }
    public List<ASI_MFM_Plan_Line_Item__c> del_results {get; set;}
    public ASI_MFM_Plan__c plan {get; private set;}
    public ASI_MFM_Plan_Line_Item__c searchObj { get; set; }
    
    public boolean allSelected { get; set; }
    public ASI_MFM_Plan_Line_Item__c rowObjAll { get; set; }
    public ASI_MFM_Plan_Line_Item__c rowObj1 { get; set; }
    public ASI_MFM_Plan_Line_Item__c rowObj2 { get; set; }
    public ASI_MFM_Plan_Line_Item__c rowObj3 { get; set; }
    public ASI_MFM_Plan_Line_Item__c rowObj4 { get; set; }
    public ASI_MFM_Plan_Line_Item__c rowObj5 { get; set; }
    
    private map<string, string> APCode_Map {set;get;}
    private map<string, string> SBCode_Map {set;get;}
    public map<string, id> Customer_Map {set;get;} // Added by Alan Wong Elufa 20150714
    public string SB_Name {set;get;}
    public string SB_Name1 {set;get;}
    public string AP_Code {set;get;}
    public string AP_Code1 {set;get;}
    //-- Added by Alan Wong (Elufa) 20150714 --//
    public string C_Code {set;get;}
    public string C_Code1 {set;get;}
    //-- End --//
    
     public ASI_MFM_TR_InputPlanItemsPage_MassEdit(ApexPages.StandardController controller) {
     }
    public ASI_MFM_TR_InputPlanItemsPage_MassEdit(ApexPages.StandardSetController controller) {
        /*
        fyFrom = 'FY1314';
        fyTo = 'FY1415';        
        fyOptionList = new List<SelectOption>();
        fyOptionList = getFYList();
        */
        pid = apexpages.currentPage().getParameters().get('id');
        plan = database.query(ASI_MFM_function.buildQuery('ASI_MFM_Plan__c') + ' where id = :pid');
        
        searchObj = new ASI_MFM_Plan_Line_Item__c();
        brandObj = new ASI_MFM_Sub_brand__c();
        rowObjAll = new ASI_MFM_Plan_Line_Item__c();
        rowObj1 = new ASI_MFM_Plan_Line_Item__c();
        rowObj2 = new ASI_MFM_Plan_Line_Item__c();
        rowObj3 = new ASI_MFM_Plan_Line_Item__c();
        rowObj4 = new ASI_MFM_Plan_Line_Item__c();
        rowObj5 = new ASI_MFM_Plan_Line_Item__c();
        allSelected = true;
       
        Map<string, id> MRecType = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_Plan_Line_Item__c');
        
        for (recordType rtt:rtList) {
            MRecType.put(rtt.DeveloperName, rtt.id);            
        }
        TRRecTypeID = MRecType.get('ASI_MFM_TR_Plan_Line_Item');
        //-- Added by Alan Wong (Elufa) 20150714 --//
        List<recordType> AccountRTList = Global_RecordTypeCache.getRtList('Account');
        for (recordType rtt:AccountRTList) {
            MRecType.put(rtt.DeveloperName, rtt.id);            
        }
        ACRecTypeID = MRecType.get('ASI_MFM_TR_Customer');
        //-- End --//
        getAPCodeMap();
        search();
        
    }
    public void getAPCodeMap(){
        APCode_Map = new map<string, string>();
        list<ASI_MFM_AP_Code__c> TRAPList = [SELECT id, Name FROM ASI_MFM_AP_Code__c WHERE ASI_MFM_Inactive__c = false and ASI_MFM_TR_Rec_Type__c = :plan.ASI_MFM_TR_Rec_Type__c]; 
        if (TRAPList.size() > 0) {
            for (ASI_MFM_AP_Code__c temp : TRAPList){
                APCode_Map.put(temp.Name, temp.Id);
            }
        }
        SBCode_Map = new map<string, string>();
        list<ASI_MFM_Sub_brand__c> TRSBList = [SELECT id, Name FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Inactive__c = false and ASI_MFM_TR_Rec_Type__c = :plan.ASI_MFM_TR_Rec_Type__c]; 
        if (TRSBList.size() > 0) {
            for (ASI_MFM_Sub_brand__c temp : TRSBList){
                SBCode_Map.put(temp.Name, temp.Id);
            }
        }
        //-- Added by Alan Wong (Elufa) 20150714 --//
        Customer_Map = new map<string, id>();
        string filter = '';
        if (plan.ASI_MFM_TR_Rec_Type__c == 'ATR'){
            if (plan.ASI_MFM_Plan_Type__c == 'Commercial')
            {
                filter = plan.ASI_MFM_Location__c != 'Airline' && plan.ASI_MFM_Location__c != 'Key Account' ? 
                               ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'ATR\' and (ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('20') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('60') + '%\' and  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('29') + '%\') and (ASI_MFM_Country_Code__c != \'' + String.escapeSingleQuotes('203') + '\' and ASI_HK_CRM_Location__c = \'' + String.escapeSingleQuotes(plan.ASI_MFM_Location__c)  + '\')' :
                                plan.ASI_MFM_Location__c == 'Airline'?
                                    ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'ATR\' and (ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('20') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('60') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('29') + '%\') and (ASI_MFM_Country_Code__c = \'' + String.escapeSingleQuotes('241') + '\' )':   // For Airline Plan    2017-08-15  Linus@introv 
                                    ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'ATR\' and (ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('20') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('60') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('29') + '%\') and (ASI_MFM_Country_Code__c = \'' + String.escapeSingleQuotes('242') + '\' )';   // For Key Account Plan    2017-08-15  Linus@introv
            }else
            {
                filter = ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'ATR\' and (ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('22') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('62') + '%\') and ASI_MFM_Country_Code__c = \'' + String.escapeSingleQuotes('203') + '\'' ;
            }
        }
        else{
            filter = ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'JDF\' and recordtypeid = \''+ ACRecTypeID + '\'';
        }
        String soql = 'select id, Name from Account ' + filter + ' order by Name';
        List<Account> TempCustomer = new List<Account>();
        try {
            TempCustomer = Database.query(soql);
            for(Account TC : TempCustomer){
                Customer_Map.put(TC.Name, TC.id); 
            }
        } catch (QueryException e) {
            
        }       
        //-- End --//
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
           
         totalSize = Database.countquery('SELECT COUNT() FROM ASI_MFM_Plan_Line_Item__c WHERE ASI_MFM_Plan__r.id = :pid');         
                       
        
         results = new List<PlanLineObj>();
         
         counter = 0;
         
         if (totalSize > 0){                
             querySOQL = 'SELECT Name, ASI_MFM_AP_Code__r.Name,ASI_MFM_Sub_brand_Code__r.Name, ASI_MFM_Plan__c, ASI_MFM_Customer_Name__c, ASI_MFM_Customer_Name__r.Name, ASI_MFM_List_Item_Description__c , ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c, ASI_MFM_AP_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_Quantity__c ,ASI_MFM_Unit_Cost__c ,ASI_MFM_Total_Cost__c, ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,ASI_MFM_Month_4_Cost__c,ASI_MFM_Month_5_Cost__c,ASI_MFM_Month_6_Cost__c,ASI_MFM_Month_7_Cost__c,ASI_MFM_Month_8_Cost__c,ASI_MFM_Month_9_Cost__c,ASI_MFM_Month_10_Cost__c,ASI_MFM_Month_11_Cost__c,ASI_MFM_Month_12_Cost__c  FROM ASI_MFM_Plan_Line_Item__c WHERE ASI_MFM_Plan__r.id = :pid ';
             /*
             if (searchObj.ASI_MFM_Sub_brand_Code__c != null)
             {
                subBrandId = searchObj.ASI_MFM_Sub_brand_Code__c;
                querySOQL += ' and ASI_MFM_Sub_brand_Code__c =:subBrandId ';
             }*/
             
             if (SB_Name != null && SB_Name != '' ){
                subBrandId = getAPCode(SB_Name, 'SB');
                querySOQL += ' and ASI_MFM_Sub_brand_Code__c =:subBrandId ';
             }
                 
             if (brandObj.ASI_MFM_Brand__c  != null)
             {
                brandId = brandObj.ASI_MFM_Brand__c;
                querySOQL += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c =:brandId ';
                System.debug('brandId:' + brandId + ';'  );
           
             }
             /*
             if (searchObj.ASI_MFM_AP_Code__c != null)
             {
                apCodeId = searchObj.ASI_MFM_AP_Code__c;
                querySOQL += ' and ASI_MFM_AP_Code__c =:apCodeId ';
             }*/
             if (AP_Code1 != null && AP_Code1 != '')
             {
                apCodeId = getAPCode(AP_Code1 , 'AP');
                querySOQL += ' and ASI_MFM_AP_Code__c =:apCodeId ';
             }
             if (C_Code1 != null && C_Code1 != '')
             {
                custId = Customer_Map.get(C_Code1);
                querySOQL += ' and ASI_MFM_Customer_Name__c =:custId ';
             }
             querySOQL += ' ORDER BY Name ASC';
             
             //pageSize = 50;
             
             searchCurrentPage();
         }else{
             results = new List<PlanLineObj>();
         }
                        
    }
    
    public void searchCurrentPage(){
        
        try{
            results = new List<PlanLineObj>();
             
            System.debug('querySOQL:' + querySOQL + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));
            
            disablePrevious = getDisablePrevious();
            disableNext = getDisableNext();
            recordNumberDisplay = '(' + String.valueOf(counter + 1)+ ' - ' + String.valueOf(totalSize > counter + pageSize?(counter + pageSize):totalSize ) + ' of ' + String.valueOf(totalSize) + ')';
            
            List<ASI_MFM_Plan_Line_Item__c > planList = Database.query(querySOQL + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));

            for (ASI_MFM_Plan_Line_Item__c pobj: planList){
                  PlanLineObj planO = new PlanLineObj();
                  planO.id = pobj.Name;
                  planO.APCode = pobj.ASI_MFM_AP_Code__r.Name;
                  planO.SBCode = pobj.ASI_MFM_Sub_brand_Code__r.Name;
                  planO.CCode = pobj.ASI_MFM_Customer_Name__r.Name; // Added by Alan Wong (Elufa) 20150714
                  planO.ppl = pobj;
                  planO.selected = true;
                  results.add(planO);      
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
         //2014-08-07 Stella Sing Check Validation of required field (Page layout is not set to required, only style)
         boolean isBlanked = false;  
         for (PlanLineObj rpl : results){
             if (rpl.selected){
                 if (rpl.CCode == null || rpl.CCode == ''){
                     //-- Added by Alan Wong (Elufa) 20150714 --//
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Customer Name is required.'));
                    //rpl.ppl.ASI_MFM_Customer_Name__c.addError('Required field.');
                    //-- End --//
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
                }
                if (rpl.SBCode == null || rpl.SBCode == ''){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sub-brand is required.'));
                    isBlanked = true;
                }
            }
        }
        //---------------Validation end (by Stella Sing) ------------------------------------------
        if (!isBlanked){
          List<ASI_MFM_Plan_Line_Item__c > savePlanLineList = new List<ASI_MFM_Plan_Line_Item__c >();
          for (PlanLineObj rpl : results){
              if (rpl.selected){
                  ASI_MFM_Plan_Line_Item__c ppl = new ASI_MFM_Plan_Line_Item__c();
                  ppl = rpl.ppl;
                  if (ppl.ASI_MFM_Plan__c == null)
                      ppl.ASI_MFM_Plan__c = pid;
                  ppl.ASI_MFM_List_Item_Description__c = rpl.ppl.ASI_MFM_List_Item_Description__c;
                  //ppl.ASI_MFM_Sub_brand_Code__c = rpl.ppl.ASI_MFM_Sub_brand_Code__c;
                  ppl.ASI_MFM_Sub_brand_Code__c = getAPCode(rpl.SBCode, 'SB');
                  //ppl.ASI_MFM_AP_Code__c = rpl.ppl.ASI_MFM_AP_Code__c;
                  ppl.ASI_MFM_AP_Code__c = getAPCode(rpl.APCode, 'AP');
                  // -- Added by Alan Wong (Elufa) 20150714 --//
                  ppl.ASI_MFM_Customer_Name__c = Customer_Map.get(rpl.CCode);
                  //ppl.ASI_MFM_Customer_Name__c = rpl.ppl.ASI_MFM_Customer_Name__c;
                  //-- End --//
                  ppl.ASI_MFM_Quantity__c = rpl.ppl.ASI_MFM_Quantity__c;
                  ppl.ASI_MFM_Unit_Cost__c = rpl.ppl.ASI_MFM_Unit_Cost__c;
                  ppl.ASI_MFM_Total_Cost__c = rpl.ppl.ASI_MFM_Total_Cost__c;
                  ppl.ASI_MFM_Month_1_Cost__c = rpl.ppl.ASI_MFM_Month_1_Cost__c;
                  ppl.ASI_MFM_Month_2_Cost__c = rpl.ppl.ASI_MFM_Month_2_Cost__c;
                  ppl.ASI_MFM_Month_3_Cost__c = rpl.ppl.ASI_MFM_Month_3_Cost__c;
                  ppl.ASI_MFM_Month_4_Cost__c = rpl.ppl.ASI_MFM_Month_4_Cost__c;
                  ppl.ASI_MFM_Month_5_Cost__c = rpl.ppl.ASI_MFM_Month_5_Cost__c;
                  ppl.ASI_MFM_Month_6_Cost__c = rpl.ppl.ASI_MFM_Month_6_Cost__c;
                  ppl.ASI_MFM_Month_7_Cost__c = rpl.ppl.ASI_MFM_Month_7_Cost__c;
                  ppl.ASI_MFM_Month_8_Cost__c = rpl.ppl.ASI_MFM_Month_8_Cost__c;
                  ppl.ASI_MFM_Month_9_Cost__c = rpl.ppl.ASI_MFM_Month_9_Cost__c;
                  ppl.ASI_MFM_Month_10_Cost__c = rpl.ppl.ASI_MFM_Month_10_Cost__c;
                  ppl.ASI_MFM_Month_11_Cost__c = rpl.ppl.ASI_MFM_Month_11_Cost__c;
                  ppl.ASI_MFM_Month_12_Cost__c = rpl.ppl.ASI_MFM_Month_12_Cost__c;
                  ppl.recordtypeid = TRRecTypeID ;
                  savePlanLineList.add(ppl);
               }
          }
          
          System.Savepoint sp = database.setSavepoint();
          Boolean isRedirect = false;
          try {
              upsert savePlanLineList;
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
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
          }   
            return isRedirect;
        }else{
            return false;
        }
    }
    
    public Class PlanLineObj{
        public String id{ 
            get{
                if(String.isBlank(id)) {
                    return null;
                }
                return id;
              } 
            set; }
        public string APCode {set;get;}
        public string SBCode {set;get;}
        public string CCode {set;get;} // Added by Alan Wong (Elufa) 20150714
        public Boolean selected {get; set;}
        public ASI_MFM_Plan_Line_Item__c ppl {get; set;}
    }
    public void onclickCheckbox() { //user clicked beginning
        System.debug('This method is for the check box quick trigger server side' );
        allSelected = false;     
    }
    public void onclickAllCheckbox() { //user clicked beginning
        System.debug('This method is for the check box quick trigger server side' );
        allSelected  = !allSelected ;
        System.debug('allSelected  ' +allSelected   );
        for (PlanLineObj poO : results)
        {
            poO.selected = allSelected ;
        }     
    }
    public void APPLY() { //user clicked beginning
          
        for (PlanLineObj planO : results)
        {
            if (planO.selected == true )
            {
                //-- Added By Alan Wong (Elufa) 20150714 --//
                //if (rowObjAll.ASI_MFM_Customer_Name__c != null )
                //    planO.ppl.ASI_MFM_Customer_Name__c = rowObjAll.ASI_MFM_Customer_Name__c;
                if (C_Code != null && C_Code != '' )
                    planO.CCode = C_Code;
                //-- End --//
                if (rowObjAll.ASI_MFM_List_Item_Description__c != null && rowObjAll.ASI_MFM_List_Item_Description__c != '')
                    planO.ppl.ASI_MFM_List_Item_Description__c = rowObjAll.ASI_MFM_List_Item_Description__c;
                if (SB_Name1 != null && SB_Name1 != '')
                    planO.SBCode = SB_Name1;
                if (AP_Code != null && AP_Code != '' )
                    planO.APCode = AP_Code;
            }
        }
        
    }
    public PageReference DELETESELECTED() { //user clicked beginning
        del_results = new List<ASI_MFM_Plan_Line_Item__c>();
        for (PlanLineObj rpl : results){
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
        PlanLineObj selected_rpl;
        Boolean isSelected = false;
        List<PlanLineObj> cloneList = new List<PlanLineObj>();
         for (PlanLineObj rpl : results){
            if (rpl.selected == true )//&& isSelected == false)
            {
                selected_rpl = new PlanLineObj();
                selected_rpl.selected = true;
                selected_rpl.ppl = new ASI_MFM_Plan_Line_Item__c();
                selected_rpl.ppl.ASI_MFM_List_Item_Description__c = rpl.ppl.ASI_MFM_List_Item_Description__c;
                //selected_rpl.ppl.ASI_MFM_Sub_brand_Code__c = rpl.ppl.ASI_MFM_Sub_brand_Code__c;
                selected_rpl.SBCode = rpl.SBCode;
                //selected_rpl.ppl.ASI_MFM_AP_Code__c = rpl.ppl.ASI_MFM_AP_Code__c;
                selected_rpl.APCode = rpl.APCode;
                //-- Added by Alan Wong (Elufa) 20150714 --//
                //selected_rpl.ppl.ASI_MFM_Customer_Name__c = rpl.ppl.ASI_MFM_Customer_Name__c;
                selected_rpl.CCode = rpl.CCode;
                //-- End --//
                selected_rpl.ppl.ASI_MFM_Quantity__c = rpl.ppl.ASI_MFM_Quantity__c;
                selected_rpl.ppl.ASI_MFM_Unit_Cost__c = rpl.ppl.ASI_MFM_Unit_Cost__c;
                selected_rpl.ppl.ASI_MFM_Total_Cost__c = rpl.ppl.ASI_MFM_Total_Cost__c;
                selected_rpl.ppl.ASI_MFM_Month_1_Cost__c = rpl.ppl.ASI_MFM_Month_1_Cost__c;
                selected_rpl.ppl.ASI_MFM_Month_2_Cost__c = rpl.ppl.ASI_MFM_Month_2_Cost__c;
                selected_rpl.ppl.ASI_MFM_Month_3_Cost__c = rpl.ppl.ASI_MFM_Month_3_Cost__c;
                selected_rpl.ppl.ASI_MFM_Month_4_Cost__c = rpl.ppl.ASI_MFM_Month_4_Cost__c;
                selected_rpl.ppl.ASI_MFM_Month_5_Cost__c = rpl.ppl.ASI_MFM_Month_5_Cost__c;
                selected_rpl.ppl.ASI_MFM_Month_6_Cost__c = rpl.ppl.ASI_MFM_Month_6_Cost__c;
                selected_rpl.ppl.ASI_MFM_Month_7_Cost__c = rpl.ppl.ASI_MFM_Month_7_Cost__c;
                selected_rpl.ppl.ASI_MFM_Month_8_Cost__c = rpl.ppl.ASI_MFM_Month_8_Cost__c;
                selected_rpl.ppl.ASI_MFM_Month_9_Cost__c = rpl.ppl.ASI_MFM_Month_9_Cost__c;
                selected_rpl.ppl.ASI_MFM_Month_10_Cost__c = rpl.ppl.ASI_MFM_Month_10_Cost__c;
                selected_rpl.ppl.ASI_MFM_Month_11_Cost__c = rpl.ppl.ASI_MFM_Month_11_Cost__c;
                selected_rpl.ppl.ASI_MFM_Month_12_Cost__c = rpl.ppl.ASI_MFM_Month_12_Cost__c;
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
            PlanLineObj planO = new PlanLineObj();
            planO.ppl = new ASI_MFM_Plan_Line_Item__c();
            planO.ppl.recordtypeid = TRRecTypeID ;
            planO.selected = true;
            results.add(0,planO);   
        }else{
            results = new List<PlanLineObj>();
            PlanLineObj planO = new PlanLineObj();
            planO.ppl = new ASI_MFM_Plan_Line_Item__c();
            planO.ppl.recordtypeid = TRRecTypeID ;
            planO.selected = true;
            results.add(planO);   
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
        
        String soql = 'select Name from ' + obj + filter +' order by Name';
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
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
                filter = spilqr[1] != 'Airline' && spilqr[1] != 'Key Account' ? // Modified by 2017-08-18  Linus@introv  ****** Airline / Key Account 
                        ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'ATR\' and (ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('20') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('60') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('29') + '%\') and (ASI_MFM_Country_Code__c != \'' + String.escapeSingleQuotes('203') + '\' and ASI_HK_CRM_Location__c = \'' + String.escapeSingleQuotes(spilqr[1])  + '\')' :
                        spilqr[1] == 'Airline' ?
                                ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'ATR\' and (ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('20') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('60') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('29') + '%\') and (ASI_MFM_Country_Code__c = \'' + String.escapeSingleQuotes('241') + '\')':   // For Airline Plan    2017-08-15  Linus@introv
                                ' WHERE ASI_HK_CRM_Inactive__c = false and ASI_HK_CRM_Type__c = \'ATR\' and (ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('20') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('60') + '%\' or  ASI_MFM_Customer_Supplier_Number__c like \'' + String.escapeSingleQuotes('29') + '%\') and (ASI_MFM_Country_Code__c = \'' + String.escapeSingleQuotes('242') + '\')';   // For Key Account Plan    2017-08-15  Linus@introv  
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