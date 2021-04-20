/*********************************************************************************
 * Name: ASI_CRM_MY_OfftakeMassEditCtl
 * Description: Controller class for ASI_CRM_MY_OfftakeMassEditPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-11-18       Daniel WONG             Created
 * 2014-12-31       Daniel WONG             Add Adjustment check 
 */

public with sharing class ASI_CRM_MY_OfftakeMassEditCtl{

    public string pid;
    public ASI_CRM_ActualOfftakeHeader__c AOHeader{get; set;}
    
    //for Paging
    private integer counter  = 0;  //keeps track of the offset
    private integer pageSize = 50;
    public boolean disablePrevious {set;get;}
    public boolean disableNext {set;get;}
    public string recordNumberDisplay {get;set;} //show current no out of total no.
    public boolean isShowDuplicate {get;set;}
    
    public List <ASI_TH_CRM_Actual_Offtake__c> delItemList = new List <ASI_TH_CRM_Actual_Offtake__c>();
    public List<ASI_TH_CRM_Actual_Offtake__c> listOfDuplicateOfftake {set;get;}
    
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
        public ASI_TH_CRM_Actual_Offtake__c ppl {get; set;}
    }
    
    //for Record Type
    public ID HeaderRecTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
    public ID ItemRecTypeID = Schema.SObjectType.ASI_TH_CRM_Actual_Offtake__c.RecordTypeInfosByName.get('Actual Offtake (MY)').RecordTypeId;
    
    //for VF
    public boolean allSelected {get; set;}
    public List<interimData> results {get; set;}
    public string strPageID {get; set;} {strPageID = 'ERROR';}
    public boolean modified = FALSE;
    public string modifiedVF {get; set;} {modifiedVF = 'N';}
    
    public ASI_CRM_MY_Function MYFunction = new ASI_CRM_MY_Function();
    
    public boolean isGroupMember{get; set;} { isGroupMember = FALSE; }
    public boolean isAdjustable{get; set;} { isAdjustable = FALSE; }
    //Page becomes read-only when status is Final
    public boolean boolReadOnly {get; set;}
    public boolean isEdit {get; set;}

    public ASI_CRM_MY_OfftakeMassEditCtl(ApexPages.StandardController controller){
    }
    
    public ASI_CRM_MY_OfftakeMassEditCtl(ApexPages.StandardSetController controller){
        pid = apexpages.currentPage().getParameters().get('id');
        
        if(ASI_CRM_MY_Function.isGroupMember(UserInfo.getUserId(), 'ASI_CRM_MY_Offtake_Adjustment'))
            isGroupMember = TRUE;
                     
        List <ASI_CRM_ActualOfftakeHeader__c> lstAOHeader = [
            SELECT id, name, ASI_CRM_ToOutlet__r.name, ASI_CRM_ToOutlet__c,
                   ASI_CRM_OfftakeDate__c, ASI_CRM_Status__c, ASI_CRM_Invoice_Month__c,
            	   ASI_CRM_Month_Number__c, ASI_CRM_Year_Number__c
            FROM ASI_CRM_ActualOfftakeHeader__c
            WHERE id = :pid
        ];
        AOHeader = lstAOHeader[0];
        
        if(AOHeader.ASI_CRM_Status__c == 'Final'){
            boolReadOnly = true;
        }else{
            boolReadOnly = false;
        } 
	        
        isAdjustable = ASI_CRM_MY_Function.isGroupMember(UserInfo.getUserId(), 'ASI_CRM_MY_Offtake_Adjustment');
        system.debug('@@@isAdjustable@@@: '+isAdjustable);
        //isAdjustable = true;
        isEdit = (isAdjustable || !boolReadOnly) ? true : false;
        isShowDuplicate = false;
        results = new List<interimData>();
        listOfDuplicateOfftake = new List<ASI_TH_CRM_Actual_Offtake__c>();
        search();
    }
   
    public void search(){
        intTotalSize = Database.countquery('SELECT COUNT() FROM ASI_TH_CRM_Actual_Offtake__c WHERE ASI_CRM_ActualOfftakeHeader__c = :pid');         
        results = new List<interimData>();
        counter = 0;
        
        if (intTotalSize > 0){
        
            strQuery = 'SELECT id, ASI_CRM_SKU__c,  '; 
            strQuery +=' ASI_CRM_FromWS__c, ASI_CRM_InvoiceNumber__c, ASI_CRM_InvoiceDate__c,';
            strQuery +=' ASI_TH_CRM_Quantity__c, ASI_CRM_Price__c, ';
            strQuery +=' ASI_CRM_Adjustment__c, ASI_CRM_Adjustment_Remarks__c ';
            strQuery +=' FROM ASI_TH_CRM_Actual_Offtake__c ';
            strQuery +=' WHERE ASI_CRM_ActualOfftakeHeader__c = :pid'; 
                          
            searchCurrentPage();
         }else{
             //interimData AO_O = new interimData();
             //AO_O.ppl = new ASI_TH_CRM_Actual_Offtake__c();
             //AO_O.selected = true;
             //results.add(AO_O);
             results = new List<interimData>();
             disablePrevious = true;
             disableNext = true;
         }
    }
    
    public void searchCurrentPage(){
        try{
            results = new List<interimData>();
             
            System.debug('strQuery :' + strQuery + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));
            
            disablePrevious = getDisablePrevious();
            disableNext = getDisableNext();
            recordNumberDisplay = '(' + String.valueOf(counter + 1)+ ' - ' + String.valueOf(intTotalSize> counter + pageSize?(counter + pageSize):intTotalSize) + ' of ' + String.valueOf(intTotalSize) + ')';
            
            List<ASI_TH_CRM_Actual_Offtake__c> lstAO = Database.query(strQuery + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));

            for (ASI_TH_CRM_Actual_Offtake__c itm: lstAO ){
                  interimData AO_O= new interimData();
                  
                  AO_O.ppl = itm;
                  AO_O.selected = false;
                  results.add(AO_O);      
            }                      
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }
    }// END of function searchCurrentPage
    
    public void ADDNEW(){
        modified = TRUE;
        
        if (results != null && results.size() > 0){
            interimData AO_O = new interimData();
            AO_O.ppl = new ASI_TH_CRM_Actual_Offtake__c();
            AO_O.selected = false;
            results.add(0,AO_O);
        }else{
            results = new List<interimData>();
            interimData AO_O = new interimData();
            AO_O.ppl = new ASI_TH_CRM_Actual_Offtake__c();
            AO_O.selected = false;
            results.add(AO_O);  
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
                selected_rpl.ppl = new ASI_TH_CRM_Actual_Offtake__c();
                selected_rpl.ppl.ASI_CRM_SKU__c = rpl.ppl.ASI_CRM_SKU__c;
                selected_rpl.ppl.ASI_CRM_FromWS__c = rpl.ppl.ASI_CRM_FromWS__c;
                selected_rpl.ppl.ASI_CRM_InvoiceNumber__c = rpl.ppl.ASI_CRM_InvoiceNumber__c;
                selected_rpl.ppl.ASI_CRM_InvoiceDate__c = rpl.ppl.ASI_CRM_InvoiceDate__c;
                selected_rpl.ppl.ASI_TH_CRM_Quantity__c = rpl.ppl.ASI_TH_CRM_Quantity__c;
                selected_rpl.ppl.ASI_CRM_Price__c = rpl.ppl.ASI_CRM_Price__c;
                selected_rpl.ppl.ASI_CRM_Adjustment__c = rpl.ppl.ASI_CRM_Adjustment__c;
                selected_rpl.ppl.ASI_CRM_Adjustment_Remarks__c = rpl.ppl.ASI_CRM_Adjustment_Remarks__c;
                
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
            if(Test.isRunningTest())
                r.selected = TRUE;
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
        if(counter + pageSize < intTotalSize) 
            disableNext = false; 
        else 
            disableNext = true;
        return disableNext;
    }
    
    public PageReference SAVE(){
        if(addItem()){ //add error checking later 
            strPageID = (String)AOHeader.id;
            modified = FALSE;
            modifiedVF = 'N';
        }else{
            strPageID = 'ERROR';
        }
        return null;
    }
    
    public boolean addItem(){
        System.Savepoint sp = database.setSavepoint();
       	this.listOfDuplicateOfftake = new List<ASI_TH_CRM_Actual_Offtake__c>();
        List<ASI_TH_CRM_Actual_Offtake__c> saveItemList = new List<ASI_TH_CRM_Actual_Offtake__c>();
		
        /*
        Id ToOutlet = AOHeader.ASI_CRM_ToOutlet__c;
        Decimal Month_Number = AOHeader.ASI_CRM_Month_Number__c;
        Decimal Year_Number = AOHeader.ASI_CRM_Year_Number__c;

        Integer totalHeader = [SELECT COUNT() FROM ASI_CRM_ActualOfftakeHeader__c 
                               WHERE ASI_CRM_ToOutlet__c = :ToOutlet
                               AND ASI_CRM_Month_Number__c = :Month_Number 
                               AND ASI_CRM_Year_Number__c = :Year_Number];
        if(totalHeader > 1){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only allow to input one offtake record for one month for one customer'));
            return false;
        }
        else{
		*/
            
            Set<String> invoiceNum_customerId_skuId = new Set<String>();
            for(interimData r : results){
                String invoiceNum = r.ppl.ASI_CRM_InvoiceNumber__c;
                String customerId = r.ppl.ASI_CRM_FromWS__c;
                String skuId = r.ppl.ASI_CRM_SKU__c;
                String key = invoiceNum + '_' + customerId + '_' + skuId;
                invoiceNum_customerId_skuId.add(key);
                
                ASI_TH_CRM_Actual_Offtake__c ppl = new ASI_TH_CRM_Actual_Offtake__c();
                String invoice_number = r.ppl.ASI_CRM_InvoiceNumber__c;
                if(!String.isBlank(invoice_number)){
                    invoice_number = invoice_number.replaceAll( '\\s+', '');                
                }        
                system.debug('@@@invoice_number@@@: '+invoice_number);
                r.ppl.ASI_CRM_InvoiceNumber__c = invoice_number;
                
                ppl = r.ppl;
                ppl.ASI_CRM_ActualOfftakeHeader__c = AOHeader.id;
                ppl.recordtypeid = ItemRecTypeID;
                
                saveItemList.add(ppl);
            }
            
    
            
            system.debug('---- in addRSP --- saveItemList : ' + saveItemList);
            
            try{
                if(delItemList != null && delItemList.size() > 0){
                    delete delItemList;
                    delItemList.clear();
                }
                upsert saveItemList;
                
                
                return true;
            }/*catch(DmlException dmle){
                database.rollback(sp);
                system.debug('-------------------------------------------------------------------------' + dmle.getDmlType(0));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,dmle.getMessage()));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,dmle.getTypeName()));
                
                return false;
            }catch(Exception e){
                database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
                return false;
            }*/
            catch(Exception e){
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
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Invoice Number'));
                    
                    
                    String s = 'Duplicate Invoice Number';
                    
                    //s = 'Update Fail on Line ' + e.getNumDml() + ' : ' + s;
                    s = 'Update Fail on Line ' + (e.getDmlIndex(0)+1) + ' : ' + s;
                     
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, s));
                    
                    
                    AggregateResult[] aggregateResults = [
                        SELECT 
                            ASI_CRM_SKU__c skuId,
                            ASI_CRM_FromWS__c customerId,
                            ASI_CRM_InvoiceNumber__c invoiceNum
                        FROM ASI_TH_CRM_Actual_Offtake__c
                        WHERE ASI_TH_CRM_Actual_Offtake_External_ID__c IN :invoiceNum_customerId_skuId 
                        AND ASI_CRM_ActualOfftakeHeader__c != :pid
                        GROUP BY ASI_CRM_InvoiceNumber__c, ASI_CRM_FromWS__c, ASI_CRM_SKU__c
                        HAVING COUNT(ASI_CRM_SKU__c) > 0
                    ];
                    system.debug('@@@aggregateResults@@@: '+aggregateResults); 
                    
                    Set<String> duplicate_invoiceNum_customerId_skuId = new Set<String>();
                    for (AggregateResult aggResult : aggregateResults){
                        String invoiceNum = (String)aggResult.get('invoiceNum');
                        String customerId = (String)aggResult.get('customerId');
                        String skuId = (String)aggResult.get('skuId');
                        String key = invoiceNum + '_' + customerId + '_' + skuId;
                        duplicate_invoiceNum_customerId_skuId.add(key);
                    }
                    
                    if(duplicate_invoiceNum_customerId_skuId.size() > 0){
                        isShowDuplicate = true;
                        List<ASI_TH_CRM_Actual_Offtake__c> duplicateOfftakeList = [
                            SELECT 
                                id,
                                ASI_CRM_SKU__c,
                                ASI_CRM_SKU__r.Name,
                                ASI_CRM_ActualOfftakeHeader__c,
                                ASI_CRM_FromWS__c,
                                ASI_CRM_FromWS__r.Name,
                                ASI_CRM_InvoiceNumber__c 
                            FROM ASI_TH_CRM_Actual_Offtake__c
                            WHERE ASI_TH_CRM_Actual_Offtake_External_ID__c IN :duplicate_invoiceNum_customerId_skuId 
                        ];
                        
                        listOfDuplicateOfftake = duplicateOfftakeList;
                        system.debug('@@@listOfDuplicateOfftake@@@: '+listOfDuplicateOfftake);
                    }
                }
                else if(e.getTypeName() == 'System.DmlException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    String s = e.getDmlMessage(0);
                    s = 'Update Fail on Line ' +(e.getDmlIndex(0)+1)  + ' : ' + s;   
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, s));
                }
                else if(e.getTypeName().contains('System.DmlException') && e.getDmlType(0) == System.Statuscode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Insufficient Privileges: You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'));
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
                }
                database.rollback(sp);
                return false;
            }
        /*    
        } 
        */
        
    }// END OF addItem
}