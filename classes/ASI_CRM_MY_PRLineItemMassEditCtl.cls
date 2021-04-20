public with sharing class ASI_CRM_MY_PRLineItemMassEditCtl{

    public string pid;
    public ASI_TH_CRM_PaymentRequest__c PR {get; set;}
    
    //for Paging
    private integer counter  = 0;  //keeps track of the offset
    private integer pageSize = 50;
    public boolean disablePrevious {set;get;}
    public boolean disableNext {set;get;}
    public string recordNumberDisplay {get;set;} //show current no out of total no.
    public boolean isEdit {get; private set;}
    public boolean isAdjustedEdit {get; private set;}
    
    public List <ASI_TH_CRM_PaymentRequestLineItem__c> delItemList = new List <ASI_TH_CRM_PaymentRequestLineItem__c>();
    public List<SelectOption> ContractSetupCodeValue {get; set;} {ContractSetupCodeValue = ASI_CRM_MY_Function.getContractSetupCodeValue();}
    
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
        public ASI_TH_CRM_PaymentRequestLineItem__c ppl {get; set;}
    }
    
    //for Record Type
    public ID ItemRecTypeID = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_MY_Payment_Request_Detail');
    
    //for VF
    public boolean allSelected {get; set;}
    public List<interimData> results {get; set;}
    public string strPageID {get; set;} {strPageID = 'ERROR';}
    public boolean modified = FALSE;
    public string modifiedVF {get; set;} {modifiedVF = 'N';}

    public ASI_CRM_MY_PRLineItemMassEditCtl(ApexPages.StandardController controller){
    }
    
    public ASI_CRM_MY_PRLineItemMassEditCtl(ApexPages.StandardSetController controller){
        pid = apexpages.currentPage().getParameters().get('id');
        List <ASI_TH_CRM_PaymentRequest__c> lstPR = [
            SELECT id, name, ASI_CRM_CN_OutletWS__c, ASI_TH_CRM_Contract__c, 
                   ASI_CRM_PayTo__c, ASI_CRM_PayTo3Party__c, ASI_CRM_ForAccountOf__c,
                   ASI_CRM_GSTTaxAmount__c, ASI_CRM_TotalPayment__c, ASI_TH_CRM_Status__c,
                   ASI_TH_CRM_RequestBy__c, ASI_CRM_ChequeDate__c,
                   ASI_CRM_PVRaiseDate__c, ASI_CRM_JDEPVNum__c,
            	   ASI_CRM_Auto_Generate__c,
                   ASI_CRM_GST__c,
            	   RecordTypeId	
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE id = :pid
        ];
        PR = lstPR[0];
        system.debug(PR);
        boolean isAutoGen; 
        boolean isReadOnly;
        String status = '';
        for(ASI_TH_CRM_PaymentRequest__c pr : lstPR){
            isAutoGen = pr.ASI_CRM_Auto_Generate__c;
            id recordTypeId = pr.RecordTypeId;
            id read_only_recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_MY_Payment_Request_Read_Only');
            // read-only
            isReadOnly = (recordTypeId == read_only_recordTypeId) ? true : false;
            status = pr.ASI_TH_CRM_Status__c;
            isEdit = (isAutoGen || isReadOnly) ? false : true;
            isAdjustedEdit = pr.ASI_TH_CRM_Status__c =='Draft' ? true: false;
        }
        
        //boolean isGroupMember = ASI_CRM_MY_Function.isGroupMember(UserInfo.getUserId(), 'ASI_CRM_MY_Salesman');
        //isAdjustedEdit = (!isReadOnly && isAutoGen) ? true : false;
        
        search();
    }
   
    public void search(){
        intTotalSize = Database.countquery('SELECT COUNT() FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE ASI_TH_CRM_Payment_Request__c = :pid');         
        results = new List<interimData>();
        counter = 0;
        
        if (intTotalSize > 0){
        
            strQuery = 'SELECT id, ASI_CRM_SKU__c, ASI_CRM_SKU__r.Name, ASI_CRM_CN_Actual_Vol__c,';
            strQuery +=' ASI_CRM_CN_Target_BT__c, ASI_TH_CRM_Amount__c,';
            strQuery +=' ASI_TH_CRM_Payment_Request__r.ASI_CRM_Auto_Generate__c,';
            strQuery +=' ASI_CRM_SetupCode__c, ASI_CRM_AC_Code_Desc__c,';
            strQuery +=' ASI_CRM_UOM__c, ASI_CRM_CN_AC_Code__c,';
            strQuery +=' ASI_CRM_Net_Amount__c, ASI_CRM_Tax_Amount__c,';
            strQuery +=' ASI_CRM_MY_Adjusted_Amount__c';
            strQuery +=' FROM ASI_TH_CRM_PaymentRequestLineItem__c '; 
            strQuery +=' WHERE ASI_TH_CRM_Payment_Request__c = :pid'; 
            strQuery +=' ORDER BY ASI_CRM_SKU__r.Name'; 
                          
             searchCurrentPage();
         }else{
             results = new List<interimData>();
         }                
    }
    
    public void searchCurrentPage(){
        try{
            results = new List<interimData>();
             
            System.debug('strQuery :' + strQuery + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));
            
            disablePrevious = getDisablePrevious();
            disableNext = getDisableNext();
            recordNumberDisplay = '(' + String.valueOf(counter + 1)+ ' - ' + String.valueOf(intTotalSize> counter + pageSize?(counter + pageSize):intTotalSize) + ' of ' + String.valueOf(intTotalSize) + ')';
            
            List<ASI_TH_CRM_PaymentRequestLineItem__c> lstRPLineItem = Database.query(strQuery + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));

            for (ASI_TH_CRM_PaymentRequestLineItem__c itm: lstRPLineItem){
                interimData RPLineItem_O= new interimData();
                  
				
                RPLineItem_O.ppl = itm;
                RPLineItem_O.selected = false;
                results.add(RPLineItem_O);      
            }                      
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }
    }// END of function searchCurrentPage
    
    public void ADDNEW(){
        modified = TRUE;
        
        if(results != null && results.size() > 0){
            interimData RPLineItem_O= new interimData();
            RPLineItem_O.ppl = new ASI_TH_CRM_PaymentRequestLineItem__c();
            RPLineItem_O.selected = false;
            results.add(0,RPLineItem_O);
        }else{
            results = new List<interimData>();
            interimData RPLineItem_O= new interimData ();
            RPLineItem_O.ppl = new ASI_TH_CRM_PaymentRequestLineItem__c();
            RPLineItem_O.selected = false;
            results.add(RPLineItem_O);  
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
                selected_rpl.ppl = new ASI_TH_CRM_PaymentRequestLineItem__c();
                selected_rpl.ppl.ASI_CRM_SKU__c             	= rpl.ppl.ASI_CRM_SKU__c ;
                selected_rpl.ppl.ASI_CRM_CN_Actual_Vol__c   	= rpl.ppl.ASI_CRM_CN_Actual_Vol__c;
                selected_rpl.ppl.ASI_CRM_CN_Target_BT__c    	= rpl.ppl.ASI_CRM_CN_Target_BT__c;
                selected_rpl.ppl.ASI_TH_CRM_Amount__c       	= rpl.ppl.ASI_TH_CRM_Amount__c;
                selected_rpl.ppl.ASI_CRM_SetupCode__c       	= rpl.ppl.ASI_CRM_SetupCode__c;
                selected_rpl.ppl.ASI_CRM_Net_Amount__c      	= rpl.ppl.ASI_CRM_Net_Amount__c;
                selected_rpl.ppl.ASI_CRM_Tax_Amount__c      	= rpl.ppl.ASI_CRM_Tax_Amount__c;
                selected_rpl.ppl.ASI_CRM_MY_Adjusted_Amount__c  = rpl.ppl.ASI_CRM_MY_Adjusted_Amount__c;
                cloneList.add(selected_rpl);
            }
         }
         
         for(interimData  i : cloneList)
             results.add(0, i);
         //results.addall(cloneList);
         return null;
    }// END of function CLONESELECTED
    
    public PageReference DELETESELECTED(){
        modified = TRUE;
        
        interimData selected_rpl;
        integer i = 0;
        integer c = 0;
        List <integer> temp_index = new List <integer>();
        
        for(interimData r : results){  
            if(r.selected){
                temp_index.add(i);
                if(r.ppl.id != null)
                    delItemList.add(r.ppl);
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
    
    public PageReference SAVE(){
        if(addItem()){ //add error checking later
            strPageID = (String)PR.id;
            modified = FALSE;
            modifiedVF = 'N';
        }
        return null;
    }
    
    public boolean addItem(){
        System.Savepoint sp = database.setSavepoint();
        List<ASI_TH_CRM_PaymentRequestLineItem__c> saveItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        
        for(interimData r : results){
            ASI_TH_CRM_PaymentRequestLineItem__c ppl = new ASI_TH_CRM_PaymentRequestLineItem__c();
            ppl = r.ppl;
            ppl.recordtypeid = ItemRecTypeID;
            
            if(ppl.id==NULL){
                ppl.ASI_TH_CRM_Payment_Request__c = PR.id;
            }
                
            saveItemList.add(ppl);
        }
        
        system.debug('---- in addItem --- saveItemList : ' + saveItemList);
        
        try{
            if(saveItemList.size() > 0)
                upsert saveItemList;
            if(delItemList != null && delItemList.size() > 0){
                delete delItemList;
                delItemList.clear();
            }
            
            return true;
        }catch(Exception e){
            strPageID = 'ERROR';
            System.debug('Upsert Error: ' + e);
            String strError = e.getMessage();    
            //String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
            System.debug('Flag- Saving Error Info: getTypeName: ' + e.getTypeName() + ' getDmlType: '+e.getDmlType(0));
            system.debug('-------------Error------------' + strError);
            if(e.getTypeName() == 'System.DmlException' && e.getDmlType(0) == System.Statuscode.DUPLICATE_VALUE) 
            {
                //String s = e.getDmlMessage(0);
                //strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Duplicate Invoice Number'));
            }else if(e.getTypeName() == 'System.DmlException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                String s = e.getDmlMessage(0);
                s = 'Update Fail on Line ' + e.getNumDml() + ' : ' + s;   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, s));
            }else if(e.getTypeName().contains('System.DmlException') && e.getDmlType(0) == System.Statuscode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Insufficient Privileges: You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'));
            }else{  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
            }
            database.rollback(sp);
            return false;
        }   
        
    }// END OF addItem
}