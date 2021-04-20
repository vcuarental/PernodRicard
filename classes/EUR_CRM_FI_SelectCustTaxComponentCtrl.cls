public without sharing class EUR_CRM_FI_SelectCustTaxComponentCtrl{ 
    public String objPromoIdStr {get;set;}
    public String currentURLStr{get;set;}
    public Boolean isRegional{get;set;}
    public String chainValue {get;set;} 
    public String subChainValue {get;set;} 
    public String regionValue {get;set;} 

    private Boolean initRegion =false;
    private Boolean initSubChain  =false; 
    
    public String managementTypeValue {get;set;}     
    public List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList {get; set;}  
    public List<EUR_CRM_Account__c> euAccountList {get; set;}
    private final String ALL = 'All *';
    public Boolean initDummyVar { get { if (initDummyVar != true) initDummyVar = init(); return initDummyVar; } set; }
    private EUR_CRM_ObjPromo__c objPromo;
    
    public Boolean isDraft {get;set;} 
    public Boolean saveDisabled {get;set;}
    
    //NEW Attributes for Finland implementation that can also be use by future countries.

    public String custTaxRecordTypeStr {get;set;} 
    public String custMappingRecordTypeStr {get;set;} 
    public String fieldsStr{get;set;}
    public Boolean insertCustMappingBool {get;set;} 
    public Boolean limitFieldsBool {get;set;}
    //--
    public Boolean init(){
        isDraft = false;
        saveDisabled = false;
        customerTaxonomyList = retrieveExistingCustomerTaxonomy();
        con = new ApexPages.StandardSetController(customerTaxonomyList);
        if(objPromoIdStr != null && objPromoIdStr != ''){
            objPromo = [select id, EUR_CRM_Status__c, EUR_CRM_CustomerTaxonomy_Chain__c, EUR_CRM_Customer_Taxonomy_Chain_Region__c, EUR_CRM_Customer_Taxonomy_Sub_Chain__c, 
                recordtype.developername from EUR_CRM_ObjPromo__c where id = : objPromoIdStr];
            
            if(objPromo != null ){
            saveDisabled = objPromo.EUR_CRM_Status__c != 'Draft' || (isRegional != null && isRegional);
                
                if(objPromo.EUR_CRM_CustomerTaxonomy_Chain__c !=null && objPromo.EUR_CRM_CustomerTaxonomy_Chain__c != '')
                    chainValue = objPromo.EUR_CRM_CustomerTaxonomy_Chain__c;
                //else
                    //chainValue = getChainOptions() != null && getChainOptions().size() > 0 ? getChainOptions().get(0).getValue() : null ;//'Edeka';
                    //feb 10 2015, if no value set to the first index;
                if(objPromo.EUR_CRM_Customer_Taxonomy_Sub_Chain__c!=null && objPromo.EUR_CRM_Customer_Taxonomy_Sub_Chain__c!= '')
                    subChainValue = objPromo.EUR_CRM_Customer_Taxonomy_Sub_Chain__c;
                if(objPromo.EUR_CRM_Customer_Taxonomy_Chain_Region__c!=null && objPromo.EUR_CRM_Customer_Taxonomy_Chain_Region__c!= '')
                    regionValue = objPromo.EUR_CRM_Customer_Taxonomy_Chain_Region__c;
 
                     
            }
            
        }
        return true;
    } 
    
    public List<EUR_CRM_Customer_Taxonomy__c> retrieveExistingCustomerTaxonomy(){
        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyListTemp = new  List<EUR_CRM_Customer_Taxonomy__c>();
        
        if(objPromoIdStr != null && objPromoIdStr != ''){
            Set<id> custTaxSet = new Set<ID>();
            for(EUR_CRM_OP_Customer_Taxonomy_Mapping__c opCustTax : [select EUR_CRM_Customer_Taxonomy__c from
                EUR_CRM_OP_Customer_Taxonomy_Mapping__c  where EUR_CRM_ObjPromo__c =: objPromoIdStr]){
                custTaxSet.add(opCustTax.EUR_CRM_Customer_Taxonomy__c);
            }
            customerTaxonomyListTemp  = [select id, name  from EUR_CRM_Customer_Taxonomy__c where id in : custTaxSet];
        } 
        //total_size = customerTaxonomyList.size();
        return customerTaxonomyListTemp ;
    }
    
    public List<SelectOption> getChainOptions(){
       return retrieveListValues(null, 'EUR_CRM_Chain__c', '');
    } 
    public List<SelectOption> getSubChainOptions (){
        if(!initSubChain)
            initSubChain = true;
        else
            subChainValue = null;
        /*
        if(chainValue == null || chainValue  == ALL){
           subChainValue  = null;
            return null;
        }
        */
        return retrieveListValues('EUR_CRM_Chain__c', 'EUR_CRM_Sub_Chain__c', chainValue);
    }
    public List<SelectOption> getRegionOptions (){
        if(!initRegion)
            initRegion = true;
        else
            regionValue = null;
            
        /*
        if(subChainValue== null || subChainValue == ALL){
            regionValue = null;
            return null;
        }
        */
       return retrieveListValues('EUR_CRM_Sub_Chain__c', 'EUR_CRM_Region__c', subChainValue);
    }
    /*
    public List<SelectOption> getLevel1Options (){
        if(!initLevel1)
            initLevel1 = true;
        else
            level1Value = null;

        if(chainValue == null || chainValue  == ALL){
           level1Value = null;
            return null;
        }
        return retrieveListValues('EUR_CRM_Chain__c', 'EUR_CRM_Level_1__c', chainValue);
    }
    public List<SelectOption> getLevel2Options (){
        if(!initLevel2)
            initLevel2 = true;
        else
            level2Value = null;
        if(level1Value== null || level1Value == ALL){
            level2Value = null;
            return null;
        }
       return retrieveListValues('EUR_CRM_Level_1__c', 'EUR_CRM_Level_2__c', level1Value);
    } 
     */
    public List<SelectOption> retrieveListValues(String controllingField, String field, String controllingFieldValue ){ 
    
         String query = 'select ' + field +' from EUR_CRM_Customer_Taxonomy__c ';//where recordtype.developername = \'EUR_DE_Customer_Taxonomy\'';
       
        if(String.IsEmpty(custTaxRecordTypeStr))
            query += '  where recordtype.developername = \'EUR_DE_Customer_Taxonomy\' ';
        else
            query += '  where recordtype.developername = \''+custTaxRecordTypeStr+'\' ';
        
        Boolean flag = false; 
        /*
        if(field == 'EUR_CRM_Region__c' || flag){
            query += ' AND EUR_CRM_Sub_Chain__c  =: subChainValue';
            flag =true;
        }
        if(field == 'EUR_CRM_Sub_Chain__c' || flag){
            query += ' AND EUR_CRM_Chain__c =: chainValue';
        } 
        */
        query += ' group by ' + field;
        AggregateResult[] groupedResults = Database.query(query);
        List<SelectOption> options = new List<SelectOption>();
        system.debug('@@ retrieve' + query);
        //options.add(new SelectOption(ALL, ALL));
        //feb 10. 2015. remove 'All' option from parent record.
        //if(field != 'EUR_CRM_Chain__c')
            options.add(new SelectOption(ALL, ALL));
        
        for (AggregateResult ar : groupedResults)  {
        String x = (String) ar.get(field);
        if(x==null)
            x = '';
        system.debug('@@' + x);
             options.add(new SelectOption(x, x)); 
        }
       // if(field == 'EUR_CRM_Chain__c')
          //  chainValue = options.get(1) != null ? options.get(0).getValue() : null;
          
        return options;    
    }
    
     public void filter(){       
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,  Label.EUR_CRM_SelectCusTaxWarningMessage));              
        isDraft = true;
      String query1 =  'select id,name from EUR_CRM_Customer_Taxonomy__c ';//  where recordtype.developername = \'EUR_DE_Customer_Taxonomy\'';
        

        if(String.IsEmpty(custTaxRecordTypeStr)) //DE is the default
            query1 += '  where recordtype.developername = \'EUR_DE_Customer_Taxonomy\' ';
        else
            query1 += '  where recordtype.developername = \''+custTaxRecordTypeStr+'\' ';
       if(chainValue !=null && chainValue != ALL)
            query1 += ' AND EUR_CRM_Chain__c = \''+ String.escapeSingleQuotes(chainValue) +'\'';
            
        if(subChainValue !=null && subChainValue != ALL)
            query1 += ' AND EUR_CRM_Sub_Chain__c = \''+ String.escapeSingleQuotes(subChainValue)  +'\'';
        
        if(regionValue !=null && regionValue != ALL)
            query1 += ' AND EUR_CRM_Region__c = \''+ String.escapeSingleQuotes(regionValue) +'\'';
          
        system.debug('$$$ ' +  query1);
        
        customerTaxonomyList = (List<EUR_CRM_Customer_Taxonomy__c>)Database.query(query1);
        //total_size = customerTaxonomyList.size();
        //counter = 0;
        setCon1(); 
    }
    private Boolean initTableElements = false; 
    public PageReference quickSaveContinue(){
        quickSave();
        PageReference pageRef = new PageReference('/' + currentURLStr  +'&f=step3'); 
        pageRef.setRedirect(true); 
        return pageRef;   
    
    }
    public PageReference quickSave(){
        isDraft = false;
        Savepoint sp = Database.setSavepoint();
        try{
            //delete all customer taxonomy mapping
            //update objpromo
            //create taxonomy mapping
            RecordType ctmrt = [select id from recordtype where sobjecttype='EUR_CRM_OP_Customer_Taxonomy_Mapping__c' and developername='EUR_FI_O_P_Customer_Taxonomy_Mapping'];
            List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> toDeleteOPCustTax = [select id from EUR_CRM_OP_Customer_Taxonomy_Mapping__c where EUR_CRM_ObjPromo__c =:objPromoIdStr];
            
            if(toDeleteOPCustTax  != null && toDeleteOPCustTax.size() > 0){
                 delete toDeleteOPCustTax ;
            }
            List<EUR_CRM_ObjPromo_Target__c> toDeleteOPTargets = [select id from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =:objPromoIdStr];
            
            if(toDeleteOPTargets != null && toDeleteOPTargets.size() > 0){
                 delete toDeleteOPTargets ;
            }
            if(objpromo != null && objpromo.recordtype.developername == 'EUR_DE_Off_Trade_Trade_Fair'){
                List<EUR_CRM_ObjPromo_Trade_Fair_Participant__c> toDeleteOPParticipants = [select id from EUR_CRM_ObjPromo_Trade_Fair_Participant__c where EUR_CRM_Objectives_Promotions__c =:objPromoIdStr];
           
                if(toDeleteOPParticipants  != null && toDeleteOPParticipants.size() > 0){
                    delete toDeleteOPParticipants;
                }
            }
            List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> toInsertOPCustTax = new List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>();
            
            for(EUR_CRM_Customer_Taxonomy__c cust: customerTaxonomyList){
                EUR_CRM_OP_Customer_Taxonomy_Mapping__c temp = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c(
                EUR_CRM_Customer_Taxonomy__c = cust.id, EUR_CRM_ObjPromo__c = objPromoIdStr);
                if(ctmrt != null)
                    temp.recordtypeid = ctmrt .id;
                toInsertOPCustTax.add(temp);
            } 
                insert toInsertOPCustTax;
            objPromo.EUR_CRM_CustomerTaxonomy_Chain__c = chainValue;
            objPromo.EUR_CRM_Customer_Taxonomy_Sub_Chain__c = subChainValue;
            objPromo.EUR_CRM_Customer_Taxonomy_Chain_Region__c = regionValue;  
            
            update objPromo;
        }catch(Exception e){
            Database.rollback(sp);
          //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e) );
        } 
        PageReference pageRef = new PageReference('/' + currentURLStr  ); 
        pageRef.setRedirect(true); 
        return pageRef;  
    }
    
    public PageReference save(){
        quickSave(); 
        return cancel();  
    }  
    public PageReference cancel(){            
        PageReference pageRef = new PageReference('/' + objPromoIdStr); 
        pageRef.setRedirect(true); 
        return pageRef;    
    }
    
    public ApexPages.StandardSetController con { 
        get {
            if(con == null) {
                retrieveExistingCustomerTaxonomy(); 
                    con = new ApexPages.StandardSetController(retrieveExistingCustomerTaxonomy());               
               con.setPageSize(20);
            }
            return con;
        }
        set; 
    } 
    public void setCon1(){
        con = new ApexPages.StandardSetController(customerTaxonomyList); 
        con.setPageSize(20); 
    }
    //public List<EUR_CRM_Customer_Taxonomy__c> taxList {get;set;}
    public List<EUR_CRM_Customer_Taxonomy__c> getTaxList(){
        List<EUR_CRM_Customer_Taxonomy__c> taxList = new List<EUR_CRM_Customer_Taxonomy__c>();
                for(EUR_CRM_Customer_Taxonomy__c tax: (List<EUR_CRM_Customer_Taxonomy__c>) con.getRecords()){
                    taxList.add(tax);
                } 
        return taxList;
    } 
// indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
 
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    // returns the first page of records
     public void first() {
         con.first();
     }

     // returns the last page of records
     public void last() {
         con.last();
     }

     // returns the previous page of records
     public void previous() {
         con.previous();
     }

     // returns the next page of records
     public void next() {
         con.next();
     }

     // returns the PageReference of the original page, if known, or the home page.
    // public void cancel() {
     //    con.cancel();
    // }
     public Integer getPages(){
      return (con.getResultSize()/ con.getPageSize()) + 1;
     }
     public Integer getRecordSize(){
      return con.getResultSize() != null ? con.getResultSize() : 0;
     }
     public Integer getPageSize(){
     return con.getPageSize() != null ? con.getPageSize() : 0;
     }
}