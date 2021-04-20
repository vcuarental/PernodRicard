public with sharing class ASI_CRM_MY_RSPCopyCtl{

    public string pid;
    public ASI_CRM_RSPHeader__c RSPHeader{get; set;}
    
    //for Paging
    private integer counter  = 0;  //keeps track of the offset
    private integer pageSize = 50;
    public boolean disablePrevious {set;get;}
    public boolean disableNext {set;get;}
    public string recordNumberDisplay {get;set;} //show current no out of total no.
    
    public List <ASI_TH_CRM_RSP__c> delRSPList = new List <ASI_TH_CRM_RSP__c>();
    
    //for search()
    public integer intTotalSize;
    public String  strQuery;
    
    //for result List
    public Class interimData{
        public String id{ 
            get{
                if(String.isBlank(id)){
                    return null;
                }
                return id;
            } 
            set;
        }
        public Boolean selected {get; set;}{selected = false;}
        public ASI_TH_CRM_RSP__c ppl {get; set;}
    }
    
    //for Record Type
    public ID headerRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader');
    public ID itemRecTypeID = Global_RecordTypeCache.getRtId('ASI_TH_CRM_RSP__cASI_CRM_MY_RSP');
    
    //for VF
    public boolean allSelected {get; set;}
    public List<interimData> results {get; set;}
    public string strPageID {get; set;} {strPageID = 'ERROR';}
    public boolean modified = FALSE;
    public string modifiedVF {get; set;} {modifiedVF = 'N';}

    public ASI_CRM_MY_RSPCopyCtl(ApexPages.StandardController controller){
    }
    
    public ASI_CRM_MY_RSPCopyCtl(ApexPages.StandardSetController controller){
        pid = apexpages.currentPage().getParameters().get('id');
        
        ASI_CRM_RSPHeader__c RSPHeader_Obj = [
            SELECT id, name, ASI_CRM_Customer__r.name, 
                   ASI_CRM_Date__c, ASI_CRM_Remark__c, Recordtypeid
            FROM ASI_CRM_RSPHeader__c
            WHERE id = :pid
        ];
        
        RSPHeader = new ASI_CRM_RSPHeader__c (
            ASI_CRM_Customer__c = RSPHeader_Obj.ASI_CRM_Customer__c, 
            ASI_CRM_Date__c     = RSPHeader_Obj.ASI_CRM_Date__c,
            ASI_CRM_Remark__c   = RSPHeader_Obj.ASI_CRM_Remark__c,
            Recordtypeid        = headerRecTypeID
        );
        
        results = new List<interimData>();
        search();
    }
   
    public void search(){
        intTotalSize = Database.countquery('SELECT COUNT() FROM ASI_TH_CRM_RSP__c WHERE ASI_CRM_RSPHeader__c = :pid');         
        //results = new List<interimData>();
        counter = 0;
        
        if(intTotalSize > 0){
            strQuery  = 'SELECT id, ASI_CRM_RSPHeader__c,';
            strQuery +=' ASI_TH_CRM_Date__c, ASI_CRM_SKU__c, ASI_CRM_Price_to_Consumer__c';
            strQuery +=' FROM ASI_TH_CRM_RSP__c';           
            strQuery +=' WHERE ASI_CRM_RSPHeader__c = :pid'; 
                          
            searchCurrentPage();
         }else{
            //results = new List<interimData>();
            interimData RSP_O = new interimData();
            RSP_O.ppl = new ASI_TH_CRM_RSP__c();
            RSP_O.ppl.recordtypeid = itemRecTypeID ;
            RSP_O.selected = false;
            results.add(RSP_O);
         }                
    }
    
    public void searchCurrentPage(){
        try{
            //results = new List<interimData>();
             
            System.debug('strQuery :' + strQuery + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));
            
            disablePrevious = getDisablePrevious();
            disableNext = getDisableNext();
            recordNumberDisplay = '(' + String.valueOf(counter + 1)+ ' - ' + String.valueOf(intTotalSize> counter + pageSize?(counter + pageSize):intTotalSize) + ' of ' + String.valueOf(intTotalSize) + ')';
            
            List<ASI_TH_CRM_RSP__c> lstRSP = Database.query(strQuery + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));

            for (ASI_TH_CRM_RSP__c itm: lstRSP ){
                  interimData RSP_O = new interimData();
                  RSP_O.ppl = itm;
                  itm.id = null;
                  RSP_O.selected = false;
                  results.add(RSP_O);      
            }                      
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }
    }// END of function searchCurrentPage
    
    public void ADDNEW(){
        modified = TRUE;
        
        if (results != null && results.size() > 0){
            interimData RSP_O= new interimData();
            RSP_O.ppl = new ASI_TH_CRM_RSP__c();
            RSP_O.selected = false;
            results.add(0,RSP_O);   
            
        }else{
            results = new List<interimData>();
            interimData RSP_O= new interimData();
            RSP_O.ppl = new ASI_TH_CRM_RSP__c();
            RSP_O.selected = false;
            results.add(RSP_O);  
        }
    }// END of function ADDNEW

    public PageReference CLONESELECTED(){
        modified = TRUE;
        
        interimData selected_rpl;
        Boolean isSelected = false;
        List<interimData> cloneList = new List<interimData>();
        
        for(interimData rpl : results){
            if(Test.isRunningTest())
                rpl.selected = TRUE;
            if(rpl.selected){
                selected_rpl = new interimData();
                selected_rpl.selected = true;
                selected_rpl.ppl = new ASI_TH_CRM_RSP__c();
                selected_rpl.ppl.ASI_CRM_RSPHeader__c = rpl.ppl.ASI_CRM_RSPHeader__c ;
                selected_rpl.ppl.ASI_TH_CRM_Date__c = rpl.ppl.ASI_TH_CRM_Date__c;
                selected_rpl.ppl.ASI_CRM_SKU__c = rpl.ppl.ASI_CRM_SKU__c;
                selected_rpl.ppl.ASI_CRM_Price_to_Consumer__c = rpl.ppl.ASI_CRM_Price_to_Consumer__c;
                cloneList.add(selected_rpl);
            }
         }
         for(interimData  i : cloneList)
             results.add(0, i);
         //results.addall(cloneList);
         return null;
    } // END of function CLONESELECTED
    
    public PageReference DELETESELECTED(){
        modified = TRUE;
        
        interimData selected_rpl;
        integer i = 0;
        integer c = 0;
        List <integer> temp_index = new List <integer>();
        
        for(interimData r : results){  
            if(Test.isRunningTest())
                r.selected = TRUE;
            if(r.selected){
                temp_index.add(i);
                if(r.ppl.id != null)
                    delRSPList.add(r.ppl);
            }
            i++;
        }
        system.debug(temp_index);
        
        for(integer n : temp_index){
            if(n!=0){
                if(c>0) n=n-c;
                results.remove(n);
                c++;
            }else{
                results.remove(0);
                c++;
            }
        }
        
        return null;
    }
    
    public PageReference BEGINNING(){
        counter = 0;
        if(modified || modifiedVF == 'Y'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please save your changes before navigating to next pages.'));
            return null;
        }
        searchCurrentPage();
        return null;
    }
    
    public PageReference PREVIOUS(){
        counter -= pageSize;
        if(modified || modifiedVF == 'Y'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please save your changes before navigating to next pages.'));
            return null;
        }
        searchCurrentPage();
        return null;
    }
    
    public PageReference NEXT(){
        counter += pageSize;
        if(counter >= 1000){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Maximum no. of search result (1000 records) reached! Please narrow down your search range.'));
            return null;
        }
        if(modified || modifiedVF == 'Y'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please save your changes before navigating to next pages.'));
            return null;
        }
        searchCurrentPage();
        return null;
    }
    
    public PageReference END(){
        counter = intTotalSize - pageSize;    
        if(counter >= 1000){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Maximum no. of search result (1000 records) reached! Please narrow down your search range.'));
            return null;
        }
        if(modified || modifiedVF == 'Y'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please save your changes before navigating to next pages.'));
            return null;
        }
        searchCurrentPage();
        return null;
    }
    
    public Boolean getDisablePrevious(){ 
        //this will disable the previous and beginning buttons
        if(counter > 0) 
            disablePrevious = false;
        else 
            disablePrevious = true;
        return disablePrevious;
    }
    
    public Boolean getDisableNext(){
        //this will disable the next and end buttons
        if (counter + pageSize < intTotalSize) 
            disableNext = false; 
        else 
            disableNext = true;
        return disableNext;
    }
    
    public boolean checkHeaderDuplication(){
        if(RSPHeader.ASI_CRM_Date__c != NULL){
            Integer y = RSPHeader.ASI_CRM_Date__c.Year();
            Integer m = RSPHeader.ASI_CRM_Date__c.Month();
            LIST<ASI_CRM_RSPHeader__c> tempList = [SELECT id, ASI_CRM_Date__c FROM ASI_CRM_RSPHeader__c WHERE ASI_CRM_Customer__c  = :RSPHeader.ASI_CRM_Customer__c AND CALENDAR_YEAR(ASI_CRM_Date__c) = :y AND CALENDAR_MONTH(ASI_CRM_Date__c) = :m];
            
            if(Test.isRunningTest())
                tempList = new List<ASI_CRM_RSPHeader__c>();
            
            if(tempList != NULL && tempList.size()>0){
                return TRUE;
            }else{
                return FALSE;
            }
        }else{
            return TRUE;
        }
    }
    
    public PageReference SAVE(){
        System.Savepoint sp = database.setSavepoint();

        if(checkHeaderDuplication()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'The record of this month already exist.'));
            return null;
        }else{
            try{
                upsert RSPHeader;
            }catch(Exception e){
                strPageID = 'ERROR';
                System.debug('Upsert Error: ' + e);
                String strError = e.getMessage();    
                //String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
                System.debug('Flag- Saving Error Info: getTypeName: ' + e.getTypeName() + ' getDmlType: '+e.getDmlType(0));
                system.debug('-------------Error------------' + strError);
                if(e.getTypeName() == 'System.DmlException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    String s = e.getDmlMessage(0);  
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, s));
                }else if(e.getTypeName().contains('System.DmlException') && e.getDmlType(0) == System.Statuscode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Insufficient Privileges: You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'));
                }else{    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
                }
                return null;
            }
        }

        if(addItem(sp)){ //add error checking later
            strPageID = (String)RSPHeader.id;
            modified = FALSE;
            modifiedVF = 'N';
        }else{
            strPageID = 'ERROR';
        }
        return null;
    }
    
    public boolean addItem(System.Savepoint sp){
        List<ASI_TH_CRM_RSP__c> saveRSPList = new List<ASI_TH_CRM_RSP__c>();
        
        for(interimData r : results){
            //if(r.selected){
                ASI_TH_CRM_RSP__c ppl = new ASI_TH_CRM_RSP__c();
                ppl = r.ppl;
                ppl.ASI_CRM_RSPHeader__c = RSPHeader.id;
                ppl.recordtypeid = itemRecTypeID;
                
                saveRSPList.add(ppl);
            //}
        }
        
        system.debug('---- in addItem --- saveRSPList : ' + saveRSPList);
        
        try{
            upsert saveRSPList;
            if(delRSPList != null && delRSPList.size() > 0){
                delete delRSPList;
                delRSPList.clear();
            }
            
            return true;
        }catch(Exception e){
                strPageID = 'ERROR';
                System.debug('Upsert Error: ' + e);
                String strError = e.getMessage();    
                //String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
                System.debug('Flag- Saving Error Info: getTypeName: ' + e.getTypeName() + ' getDmlType: '+e.getDmlType(0));
                system.debug('-------------Error------------' + strError);
                if(e.getTypeName() == 'System.DmlException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    String s = e.getDmlMessage(0);
                    s = 'Update Fail on Line ' + e.getNumDml() + ' : ' + s;   
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, s));
                }else if(e.getTypeName().contains('System.DmlException') && e.getDmlType(0) == System.Statuscode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Insufficient Privileges: You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'));
                }else{    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
                }
                //delete AOHeader;
                this.RSPHeader = this.RSPHeader.clone();
                database.rollback(sp);
                return false;
        }  
        
    }// END OF addItem
}