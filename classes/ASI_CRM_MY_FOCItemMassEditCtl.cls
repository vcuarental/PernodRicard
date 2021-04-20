/***************************************************************************************************
 * Name : ASI_CRM_MY_FOCItemMassEditCtl
 * Test Class: ASI_CRM_MY_FOCItemMassEditCtl_Test
 * Revision History:
 * 1. 11/12/2020 - [Ceterna 11122020] - Change sku id tracking to sku name and sku code for query  
  **************************************************************************************************/
public with sharing class ASI_CRM_MY_FOCItemMassEditCtl{
    public class ASI_CRM_MY_FOCItemMassEditCtlException extends Exception {}
    public List<SelectOption> ContractSetupCodeValue {get; set;} {ContractSetupCodeValue = ASI_CRM_MY_Function.getContractSetupCodeValue();}
    public string pid;
    public Boolean isKH{get;set;}
    public ASI_FOC_Free_Goods_Request__c FOC {get; set;}
    
    //for Paging
    private integer counter  = 0;  //keeps track of the offset
    private integer pageSize = 50;
    public boolean disablePrevious {set;get;}
    public boolean disableNext {set;get;}
    public string recordNumberDisplay {get;set;} //show current no out of total no.
    public boolean isEdit {get;set;}
    public string errorMessage;
    {isEdit = true;}
    /*
    public boolean isEdit 
    { 
        get{
            return isEdit;
        }
        set{
            isEdit = true;
        } 
    } 
    */

    public Map <Id,ASI_FOC_Request_Item__c> delItemList = new Map <Id,ASI_FOC_Request_Item__c>();
    
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
        public ASI_FOC_Request_Item__c ppl {get; set;}
        public integer availableSKUQuantity {get;set;}
         public integer availableSKUQuantityBottle {get;set;}
        public String invalidReason {get; set;}
    }
    
    //for Record Type
    public ID ItemRecTypeID = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_MY_RequestItem');
    public ID ItemKHRecTypeID = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_CRM_KH_FOC_Request_Items');
    public RecordType rt = [Select Id, Name from RecordType where developerName = 'ASI_CRM_KH_FOC_Request_Items' limit 1];
    
    //for VF
    public boolean allSelected {get; set;}
    public List<interimData> results {get; set;}
    public string strPageID {get; set;} {strPageID = 'ERROR';}
    public boolean modified = FALSE;
    public string modifiedVF {get; set;} {modifiedVF = 'N';}
    
    
    public ASI_CRM_MY_FOCItemMassEditCtl(ApexPages.StandardController controller){
    }
    
  /*  public void populateFOCType(){
        string sid  =System.currentPageReference().getParameters().get('nodeType');
        Integer sid1  =Integer.valueOf(System.currentPageReference().getParameters().get('node1Type').replace('\"',''));
        system.debug('@#@#'+sid+'@#'+sid1);
        if(sid != null && sid != ''){
            if(sid == 'STK2' || sid == '0025'){
                results[sid1].ppl.ASI_CRM_SG_FOC_Type__c = 'A&D';
            }else{
                results[sid1].ppl.ASI_CRM_SG_FOC_Type__c = 'A&P';
            }
        }else{
            results[sid1].ppl.ASI_CRM_SG_FOC_Type__c= '';
        }
    } */
    
    public void populatePrice(){
                string sid  =System.currentPageReference().getParameters().get('node');
         Integer sid1  =Integer.valueOf(System.currentPageReference().getParameters().get('node1').replace('\"',''));
        system.debug('@#'+sid1);
        Date foc1 = Date.valueOf(foc.createdDate);
         /* [Ceterna 11122020] Start */     
        List<ASI_CRM_MY_SKUPriceCost__c> priceList = [Select Id, ASI_CRM_Price__c,ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c,ASI_CRM_SKU__r.Name, ASI_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c, ASI_CRM_SKU__r.ASI_CRM_Available_Quantity_Carton__c from ASI_CRM_MY_SKUPriceCost__c where  (ASI_CRM_SKU__r.name = :sid or ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c = :sid ) and ASI_CRM_EffectiveDate__c <=: foc1 order by ASI_CRM_EffectiveDate__c desc limit 1];
             /* [Ceterna 11122020] End */
        if(priceList.size()>0){
            List<ASI_CRM_ContractTarget__c> contractTargetList = [Select Id from ASI_CRM_ContractTarget__c where ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c = :priceList[0].ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c and recordType.developerName = 'ASI_KH_Merchandising_Support' and ASI_CRM_Contract__c = :foc.ASI_CRM_Contract__c];            
            if((contractTargetList == null || contractTargetList.size()<=0)
                    &&  foc.ASI_CRM_Contract__c != null){//Wilken Lee 2020-09-03: Allow FOC not to link to contract             
                results[sid1].ppl =  new ASI_FOC_Request_Item__c(ASI_FOC_Request_Order__c = FOC.id, RecordTypeId = isKH ? ItemKHRecTypeID :ItemRecTypeID );
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'This SKU sub-brand is not in contract Target'));
                return;
            }else{
                results[sid1].ppl.ASI_CRM_SG_Unit_Price__c = priceList[0].ASI_CRM_Price__c;
                results[sid1].availableSKUQuantity = integer.valueOf(priceList[0].ASI_CRM_SKU__r.ASI_CRM_Available_Quantity_Carton__c);
                 results[sid1].availableSKUQuantityBottle = integer.valueOf(priceList[0].ASI_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c);
                results[sid1].invalidReason = null;
            }
        }else{
            results[sid1].ppl.ASI_FOC_SKU__c = null;
            results[sid1].ppl.ASI_CRM_SG_Unit_Price__c = null;
             results[sid1].availableSKUQuantity = null;
             results[sid1].availableSKUQuantityBottle = null;
            results[sid1].invalidReason = 'Effective date is not valid for the SKU';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Effective date is not valid for this SKU'));
            return;
            
        }
        
       
    }
    public ASI_CRM_MY_FOCItemMassEditCtl(ApexPages.StandardSetController controller){
        pid = apexpages.currentPage().getParameters().get('id');
        List <ASI_FOC_Free_Goods_Request__c> lstFOC = [
            SELECT id, name, ASI_FOC_Date_of_Delivery__c,createdDate, ASI_CRM_Contract__c, RecordType.DeveloperName,ASI_CRM_SG_Total_Amount__c,
                   ASI_CRM_JDE_SO_Number__c,ASI_FOC_Request_Status__c, ASI_CRM_KH_Total_Amount__c
            FROM ASI_FOC_Free_Goods_Request__c
            WHERE id = :pid
        ];
        FOC = lstFOC[0];
        if(FOC.RecordType.DeveloperName.contains('_KH_')){
            isKH = true;
           
        }else{
            isKH = false;
        }
        system.debug(FOC);
        results = new List<interimData>();
        search();
    }
   
    public void search(){
        intTotalSize = Database.countquery('SELECT COUNT() FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c = :pid');         
        results = new List<interimData>();
        counter = 0;
        
        if (intTotalSize > 0){
            strQuery  = 'SELECT id, Name, ASI_FOC_SKU__c, ASI_FOC_Issued_Qty__c,';
            strQuery +=' ASI_CRM_SetupCode__c, ASI_CRM_GLReasonCode__c,';
            strQuery +=' ASI_FOC_Request_Order__r.ASI_CRM_Auto_Generation__c,';
            strQuery +=' ASI_FOC_Request_Order__r.RecordTypeId,';
            strQuery +=' ASI_CRM_JDECOA__c, ASI_FOC_Remark__c, RecordTypeId, RecordType.Name, ';
            strQuery +=' ASI_FOC_Request_Quantity_Bottle__c, ASI_CRM_KH_AP_Code__c, ASI_FOC_SKU__r.ASI_HK_CRM_Active__c,ASI_FOC_SKU__r.ASI_HK_CRM_Available_Quantity__c,ASI_FOC_SKU__r.ASI_CRM_Available_Quantity_Carton__c,';
            strQuery +=' ASI_CRM_SG_FOC_Type__c, ASI_CRM_SG_Available_Quantity__c, ASI_CRM_SG_Unit_Price__c';
            strQuery +=' FROM ASI_FOC_Request_Item__c';
            strQuery +=' WHERE ASI_FOC_Request_Order__c = :pid'; 
                          
            searchCurrentPage();
        }else{
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
            recordNumberDisplay = '(' + String.valueOf(counter + 1)+ ' - ' + String.valueOf(intTotalSize > counter + pageSize? (counter + pageSize) : intTotalSize) + ' of ' + String.valueOf(intTotalSize) + ')';
            
            List<ASI_FOC_Request_Item__c> lstFOCLineItem = Database.query(strQuery + ' LIMIT ' + String.valueOf(pageSize) + ' OFFSET '+ String.valueof(counter));

            for (ASI_FOC_Request_Item__c itm: lstFOCLineItem){
                interimData FOCLineItem_O = new interimData();
                
                boolean isAutoGen = itm.ASI_FOC_Request_Order__r.ASI_CRM_Auto_Generation__c;
                id recordTypeId = itm.ASI_FOC_Request_Order__r.RecordTypeId;
                id read_only_recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_FOC_MY_FreeGoodsRequest_Read_Only');
                 id read_only_KH_recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_KH_FOC_Request_Read_Only');               
                id KH_recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_KH_FOC_Request');               

                // read-only
                boolean isReadOnly = (recordTypeId == read_only_recordTypeId || recordTypeId == read_only_KH_recordTypeId || (recordTypeId ==KH_recordTypeId && foc.ASI_FOC_Request_Status__c != '' && foc.ASI_FOC_Request_Status__c != null && foc.ASI_FOC_Request_Status__c != 'Draft' && foc.ASI_FOC_Request_Status__c != 'Cancelled' && foc.ASI_FOC_Request_Status__c != 'Rejected')) ? true : false;
                system.debug('@#debug'+isReadOnly+'@#'+foc.ASI_FOC_Request_Status__c);
                isEdit = (isAutoGen || isReadOnly) ? false : true;
                
                FOCLineItem_O.ppl = itm;
                FOCLineItem_O.availableSKUQuantity = integer.valueOf(itm.ASI_FOC_SKU__r.ASI_CRM_Available_Quantity_Carton__c);
                FOCLineItem_O.availableSKUQuantityBottle = integer.valueOf(itm.ASI_FOC_SKU__r.ASI_HK_CRM_Available_Quantity__c);
                FOCLineItem_O.selected = false;
                results.add(FOCLineItem_O);      
            }                      
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }
    }// END of function searchCurrentPage
    
    public void ADDNEW(){
        modified = TRUE;
        
        if (results != null && results.size() > 0){
            interimData FOCLineItem_O= new interimData();
            FOCLineItem_O.ppl = new ASI_FOC_Request_Item__c(ASI_FOC_Request_Order__c = FOC.id, RecordTypeId = isKH ? ItemKHRecTypeID :ItemRecTypeID);
            FOCLineItem_O.selected = false;
            results.add(0,FOCLineItem_O);   
        }else{
            results = new List<interimData>();
            interimData FOCLineItem_O= new interimData ();
            system.debug('@#@#'+FOC.Id+'@#'+isKH+'@#'+ItemKHRecTypeID+'@#'+ItemRecTypeID);
            FOCLineItem_O.ppl = new ASI_FOC_Request_Item__c(ASI_FOC_Request_Order__c = FOC.id, RecordTypeId = isKH ? ItemKHRecTypeID :ItemRecTypeID );
            FOCLineItem_O.selected = false;
            results.add(FOCLineItem_O);  
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
                selected_rpl.ppl = new ASI_FOC_Request_Item__c();
                selected_rpl.ppl.ASI_FOC_SKU__c              = rpl.ppl.ASI_FOC_SKU__c;
                selected_rpl.ppl.ASI_FOC_Issued_Qty__c       = rpl.ppl.ASI_FOC_Issued_Qty__c;
                selected_rpl.ppl.ASI_CRM_SetupCode__c        = rpl.ppl.ASI_CRM_SetupCode__c;
                selected_rpl.ppl.ASI_CRM_GLReasonCode__c     = rpl.ppl.ASI_CRM_GLReasonCode__c;
                selected_rpl.ppl.ASI_CRM_JDECOA__c           = rpl.ppl.ASI_CRM_JDECOA__c;
                selected_rpl.ppl.ASI_FOC_Remark__c           = rpl.ppl.ASI_FOC_Remark__c;
                selected_rpl.ppl.ASI_FOC_Request_Quantity_Bottle__c           = rpl.ppl.ASI_FOC_Request_Quantity_Bottle__c;
                selected_rpl.ppl.ASI_CRM_KH_AP_Code__c              = rpl.ppl.ASI_CRM_KH_AP_Code__c;
                selected_rpl.ppl.ASI_CRM_SG_FOC_Type__c             = rpl.ppl.ASI_CRM_SG_FOC_Type__c;
                selected_rpl.ppl.ASI_CRM_SG_Available_Quantity__c   = rpl.ppl.ASI_CRM_SG_Available_Quantity__c;
                selected_rpl.ppl.ASI_CRM_SG_Unit_Price__c           = rpl.ppl.ASI_CRM_SG_Unit_Price__c;
                selected_rpl.ppl.RecordTypeId           = rpl.ppl.RecordTypeId;
                selected_rpl.ppl.ASI_FOC_Request_Order__c    = FOC.id;
                selected_rpl.invalidReason           = rpl.invalidReason;
                selected_rpl.availableSKUQuantity = integer.valueOf(rpl.availableSKUQuantity);
                selected_rpl.availableSKUQuantityBottle = integer.valueOf(rpl.availableSKUQuantityBottle);
                
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
                    delItemList.put(r.ppl.id,r.ppl);
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
    
    public boolean onCommitted(){
        if(results == null) return false;
        boolean isBlanked = true;  
        for(interimData rpl : results){
            if(Test.isRunningTest())
                rpl.selected = TRUE;
             if(rpl.selected){
                 if(rpl.ppl.ASI_FOC_SKU__c== null){
                    rpl.ppl.ASI_FOC_SKU__c.addError('Required field.');
                    isBlanked = false;
                 }
             }
        }
        return isBlanked;
    }
    
    public PageReference SAVE(){
        if(addItem()){ //add error checking later
            strPageID = (String)FOC.id;
        }
        return null;
    }
    
    public PageReference QUICKSAVE(){
        if(addItem()){ //add error checking later
            modified = FALSE;
            modifiedVF = 'N';
        }
        return null;
    }
    
  
    
    public boolean addItem(){
        System.Savepoint sp = database.setSavepoint();
        List<ASI_FOC_Request_Item__c> saveItemList = new List<ASI_FOC_Request_Item__c>();
         List<ASI_FOC_Request_Item__c> saveItemList1 = new List<ASI_FOC_Request_Item__c>();
        for(interimData r : results){
            if(isKH && r.invalidReason != null){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,r.invalidReason));
                return false;
            }
                ASI_FOC_Request_Item__c ppl = new ASI_FOC_Request_Item__c();
                ppl = r.ppl;
                //ppl.ASI_FOC_Request_Order__c = FOC.id;
            if(isKH){
                 ppl.recordtypeid = ItemKHRecTypeID;
                ppl.ASI_CRM_KH_Total_Price__c = ppl.ASI_FOC_Request_Quantity_Bottle__c*ppl.ASI_CRM_SG_Unit_Price__c;
                    }else{
                         ppl.recordtypeid = ItemRecTypeID;
                    }
               
                
                saveItemList.add(ppl);
        }
        
        system.debug('---- in addItem --- saveItemList : ' + saveItemList);
        system.debug('---- in saveEdit --- saveItemList : ' + foc.ASI_CRM_SG_Total_Amount__c);
      
             try{
             saveItemList1 = saveItemList.deepclone(true) ; 
            for(integer i=0; i< saveItemList.size();i++){
                 system.debug('@#'+saveItemList[i]);
            }
             for(integer i=0; i< saveItemList1.size();i++){
                 system.debug('@#1'+saveItemList1[i]);
            }    
            upsert saveItemList1;
                 saveItemList = saveItemList1;
            if(isKH) {
                if(!validateFOCOrderItems(foc)){
                    throw new ASI_CRM_MY_FOCItemMassEditCtlException(errorMessage);
                         
                }
                 }
            if(delItemList != null && delItemList.keyset().size() > 0){
                delete delItemList.values();
                delItemList.clear();
            }
            
            return true;
        }catch(Exception e){
            strPageID = 'ERROR';
            System.debug('Upsert Error: ' + e);
            String strError = e.getMessage();    
            //String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
          //  System.debug('Flag- Saving Error Info: getTypeName: ' + e.getTypeName() + ' getDmlType: '+e.getDmlType(0));
            system.debug('-------------Error------------' + strError);
            if(e.getTypeName()=='ASI_CRM_MY_FOCItemMassEditCtl.ASI_CRM_MY_FOCItemMassEditCtlException'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
            }
            if(e.getTypeName() == 'System.DmlException' && e.getDmlType(0) == System.Statuscode.DUPLICATE_VALUE) 
            {
                //String s = e.getDmlMessage(0);
                //strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Invoice Number'));
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
            for(integer i=0; i< saveItemList1.size();i++){
                 system.debug('@#1'+saveItemList1[i]);
            }
            saveItemList = saveItemList1;
            for(integer i=0; i< saveItemList.size();i++){
                 system.debug('@#'+saveItemList[i]);
            }
           
            return false;
        }   

    return true;  
        
    }// END OF addItem
    
     public boolean validateFOCOrderItems(ASI_FOC_Free_Goods_Request__c newfoc) {
         
        Map<String, Decimal> contractSubBrandTotalMap = new Map<String, Decimal>();
         Map<String, Decimal> focItemSubBrandTotalMap = new Map<String, Decimal>();
        for(AggregateResult agr : [Select sum(ASI_CRM_KH_Total_Valoume_Bottle__c) volumeSum, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name subBrand from ASI_CRM_ContractTarget__c where 
                                   ASI_CRM_Contract__c = :newfoc.ASI_CRM_Contract__c and recordType.developerName = 'ASI_KH_Merchandising_Support' group by ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name]){
                     contractSubBrandTotalMap.put((String)agr.get('subBrand'),(Decimal)agr.get('volumeSum'));                  
        }
        system.debug('@#@#'+contractSubBrandTotalMap);
        for(AggregateResult agr : [Select sum(ASI_CRM_KH_Total_Valoume_Bottle__c) volumeSum,ASI_FOC_SKU__r.ASI_MFM_Sub_brand__r.Name subBrand from ASI_FOC_Request_Item__c where 
                                   ASI_FOC_Request_Order__c = :newfoc.Id and id NOT IN :(delItemList.keyset()) group by ASI_FOC_SKU__r.ASI_MFM_Sub_brand__r.Name]){
                     focItemSubBrandTotalMap.put((String)agr.get('subBrand'),(Decimal)agr.get('volumeSum'));                  
        }
        system.debug('@#@#1'+focItemSubBrandTotalMap);
        for(String subBrand : focItemSubBrandTotalMap.keySet()){
            if(focItemSubBrandTotalMap.get(subBrand) > contractSubBrandTotalMap.get(subBrand)){
               Decimal totalvlm = (Decimal)focItemSubBrandTotalMap.get(subBrand);
                errorMessage =  'Total FOC Volume for '+subBrand+' ( ' +totalvlm+' cl) should not exceed Contract Target ( '+string.valueOf(contractSubBrandTotalMap.get(subBrand))+' cl)';
                system.debug('@#@#1'+totalvlm);
                return false;
            }
            
        }
         return true;
    }
}