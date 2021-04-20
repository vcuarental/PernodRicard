public without sharing class EUR_CRM_SelectCustTaxComponentController{ 
    public String objPromoIdStr {get;set;}
    public String currentURLStr{get;set;}
    public Boolean isRegional{get;set;}
    public String chainValue {get;set;}
    public String level1Value {get;set;}
    public String level2Value {get;set;}
    public String level3Value {get;set;}
    public String level4Value {get;set;}
    public String level5Value {get;set;}
    public String level6Value {get;set;}
    public String level7Value {get;set;}
    public String level8Value {get;set;}
    
    private Boolean initLevel1 =false;
    private Boolean initLevel2 =false;
    private Boolean initLevel3=false;
    private Boolean initLevel4=false;
    private Boolean initLevel5=false;
    private Boolean initLevel6=false;
    private Boolean initLevel7=false;
    private Boolean initLevel8=false;
    private Boolean initMgmtType =false;

    public string cTaxRecordType {get;set;}
    
    public String managementTypeValue {get;set;}     
    public List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList {get; set;}  
    public List<EUR_CRM_Account__c> euAccountList {get; set;}
    private final String ALL = 'All *';
    public Boolean initDummyVar { get { if (initDummyVar != true) initDummyVar = init(); return initDummyVar; } set; }
    private EUR_CRM_ObjPromo__c objPromo;
    
    public Boolean isDraft {get;set;} 
    public Boolean saveDisabled {get;set;}
    private final Map<String, String> recordTypeMapping = new Map<String,String>{
        'EUR_DE_Customer_Taxonomy' => 'EUR_DE_OP_Customer_Taxonomy_Mapping',
        'EUR_DE_WS_Customer_Taxonomy' => 'EUR_DE_OP_Customer_Taxonomy_Mapping',
        'EUR_FI_ON_Trade_Customer_Taxonomy' => 'EUR_FI_O_P_Customer_Taxonomy_Mapping',        
        'EUR_FI_OFF_Trade_Customer_Taxonomy' => 'EUR_FI_O_P_Customer_Taxonomy_Mapping'
    };
    public Boolean init(){
        
        if(String.IsEmpty(cTaxRecordType) || cTaxRecordType == null){
            cTaxRecordType = 'EUR_DE_Customer_Taxonomy';
        }
        
        isDraft = false;
        saveDisabled = false;
        customerTaxonomyList = retrieveExistingCustomerTaxonomy();
        con = new ApexPages.StandardSetController(customerTaxonomyList);

        /*tem.debug('Before RT: '+cTaxRecordType);
        if(String.IsEmpty(cTaxRecordType)){
            cTaxRecordType = 'EUR_DE_Customer_Taxonomy';
        }
        system.debug('After RT: '+cTaxRecordType);*/

        if(objPromoIdStr != null && objPromoIdStr != ''){
            objPromo = [select id, EUR_CRM_Status__c, EUR_CRM_CustomerTaxonomy_Chain__c, EUR_CRM_CustomerTaxonomy_Level_1__c, EUR_CRM_CustomerTaxonomy_Level_2__c, EUR_CRM_CustomerTaxonomy_Level_3__c,
              EUR_CRM_CustomerTaxonomy_Level_4__c,  EUR_CRM_CustomerTaxonomy_Level_5__c, EUR_CRM_CustomerTaxonomy_Level_6__c,  EUR_CRM_CustomerTaxonomy_Level_7__c, EUR_CRM_CustomerTaxonomy_Level_8__c,
              EUR_CRM_CustomerTaxonomy_Mgmt_Type__c, recordtype.developername from EUR_CRM_ObjPromo__c where id = : objPromoIdStr];
            
            if(objPromo != null ){
            saveDisabled = objPromo.EUR_CRM_Status__c != 'Draft' || (isRegional != null && isRegional);
                
                if(objPromo.EUR_CRM_CustomerTaxonomy_Chain__c !=null && objPromo.EUR_CRM_CustomerTaxonomy_Chain__c != '')
                    chainValue = objPromo.EUR_CRM_CustomerTaxonomy_Chain__c;
                //else
                    //chainValue = getChainOptions() != null && getChainOptions().size() > 0 ? getChainOptions().get(0).getValue() : null ;//'Edeka';
                    //feb 10 2015, if no value set to the first index;
                if(objPromo.EUR_CRM_CustomerTaxonomy_Level_1__c!=null && objPromo.EUR_CRM_CustomerTaxonomy_Level_1__c!= '')
                    level1Value = objPromo.EUR_CRM_CustomerTaxonomy_Level_1__c;
                if(objPromo.EUR_CRM_CustomerTaxonomy_Level_2__c!=null && objPromo.EUR_CRM_CustomerTaxonomy_Level_2__c!= '')
                    level2Value = objPromo.EUR_CRM_CustomerTaxonomy_Level_2__c;
                if(objPromo.EUR_CRM_CustomerTaxonomy_Level_3__c!=null && objPromo.EUR_CRM_CustomerTaxonomy_Level_3__c!= '')
                    level3Value = objPromo.EUR_CRM_CustomerTaxonomy_Level_3__c;
                if(objPromo.EUR_CRM_CustomerTaxonomy_Level_4__c!=null && objPromo.EUR_CRM_CustomerTaxonomy_Level_4__c!= '')
                    level4Value = objPromo.EUR_CRM_CustomerTaxonomy_Level_4__c;
                if(objPromo.EUR_CRM_CustomerTaxonomy_Level_5__c!=null && objPromo.EUR_CRM_CustomerTaxonomy_Level_5__c!= '')
                    level5Value = objPromo.EUR_CRM_CustomerTaxonomy_Level_5__c;
                if(objPromo.EUR_CRM_CustomerTaxonomy_Level_6__c!=null && objPromo.EUR_CRM_CustomerTaxonomy_Level_6__c!= '')
                    level6Value = objPromo.EUR_CRM_CustomerTaxonomy_Level_6__c;
                if(objPromo.EUR_CRM_CustomerTaxonomy_Level_7__c!=null && objPromo.EUR_CRM_CustomerTaxonomy_Level_7__c!= '')
                    level7Value = objPromo.EUR_CRM_CustomerTaxonomy_Level_7__c;
                if(objPromo.EUR_CRM_CustomerTaxonomy_Level_8__c!=null && objPromo.EUR_CRM_CustomerTaxonomy_Level_8__c!= '')
                    level8Value = objPromo.EUR_CRM_CustomerTaxonomy_Level_8__c;
                
                if(objPromo.EUR_CRM_CustomerTaxonomy_Mgmt_Type__c !=null && objPromo.EUR_CRM_CustomerTaxonomy_Mgmt_Type__c != '')
                    managementTypeValue = objPromo.EUR_CRM_CustomerTaxonomy_Mgmt_Type__c ;
                     
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
            customerTaxonomyListTemp  = [select id, name, recordtype.developername  from EUR_CRM_Customer_Taxonomy__c where id in : custTaxSet];
        } 
        //total_size = customerTaxonomyList.size();
        return customerTaxonomyListTemp ;
    }
    
    public List<SelectOption> getChainOptions(){
       return retrieveListValues(null, 'EUR_CRM_Chain__c', '');
    } 
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
    
    public List<SelectOption> getLevel3Options (){
        if(!initLevel3)
            initLevel3 = true;
        else
            level3Value = null;
        if(level2Value== null || level2Value == ALL){
            level3Value = null;        
            return null;
        }
       return retrieveListValues('EUR_CRM_Level_2__c', 'EUR_CRM_Level_3__c', level2Value);
    } 
    public List<SelectOption> getLevel4Options (){       
        if(!initLevel4)
            initLevel4 = true;
        else
            level4Value = null;
        if(level3Value== null || level3Value == ALL){
            level4Value = null;            
            return null;
        }
       return retrieveListValues('EUR_CRM_Level_3__c', 'EUR_CRM_Level_4__c', level3Value);
    } 
    public List<SelectOption> getLevel5Options (){
   
        if(!initLevel5)
            initLevel5 = true;
        else
            level5Value = null;
        if(level4Value== null || level4Value == ALL){
            level5Value = null;            
            return null;
       }
       return retrieveListValues('EUR_CRM_Level_4__c', 'EUR_CRM_Level_5__c', level4Value);
    } 
    public List<SelectOption> getLevel6Options (){
       
        if(!initLevel6)
            initLevel6 = true;
        else
            level6Value = null;
        if(level5Value== null || level5Value == ALL){
            level6Value = null;
            return null;
        }
       return retrieveListValues('EUR_CRM_Level_5__c', 'EUR_CRM_Level_6__c', level5Value);
    } 
    public List<SelectOption> getLevel7Options (){
      
        if(!initLevel7)
            initLevel7 = true;
        else
            level7Value = null;
        if(level6Value== null || level6Value == ALL){
            level7Value = null;
            return null;
        }
       return retrieveListValues('EUR_CRM_Level_6__c', 'EUR_CRM_Level_7__c', level6Value);
    } 
    public List<SelectOption> getLevel8Options (){
        
        if(!initLevel8)
            initLevel8 = true;
        else
            level8Value = null;
        if(level7Value== null || level7Value == ALL){
            level8Value = null;
            return null;
        }
       return retrieveListValues('EUR_CRM_Level_7__c', 'EUR_CRM_Level_8__c', level7Value);
    } 
    public List<SelectOption> getMgmtTypeOptions (){
         List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
        EUR_CRM_Customer_Taxonomy__c.EUR_CRM_Management_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
       options.add(new SelectOption(Label.EUR_CRM_Regie_and_Independent, Label.EUR_CRM_Regie_and_Independent));
       if(managementTypeValue == null || managementTypeValue == '') 
            managementTypeValue = Label.EUR_CRM_Regie_and_Independent; //ple != null && ple.size() >0 ?  ple.get(0).getValue() : '';
          for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getValue(),f.getLabel() ));
       }       
       //options.add(new SelectOption(Label.EUR_CRM_Regie_and_Independent, Label.EUR_CRM_Regie_and_Independent));
        return options;
    } 
     public void setMgmtTypeOptions (){ 
    } 
    public List<SelectOption> retrieveListValues(String controllingField, String field, String controllingFieldValue ){ 
    	if(String.IsEmpty(cTaxRecordType) || cTaxRecordType == null){
            cTaxRecordType = 'EUR_DE_Customer_Taxonomy';
        }
        String query = 'select ' + field +' from EUR_CRM_Customer_Taxonomy__c where recordtype.developername = \'' + cTaxRecordType + '\'';
        //if(controllingField != null)
        //    query += ' AND ' + controllingField + ' =: controllingFieldValue'; 
        
        Boolean flag = false;

        if(field == 'EUR_CRM_Level_8__c'){
            query += ' AND EUR_CRM_Level_7__c =: level7Value';
            flag =true;
        }
        if(field == 'EUR_CRM_Level_7__c' || flag){
            query += ' AND EUR_CRM_Level_6__c =: level6Value';
            flag =true;
        }
        if(field == 'EUR_CRM_Level_6__c' || flag){
            query += ' AND EUR_CRM_Level_5__c =: level5Value';
            flag =true;
        }
        if(field == 'EUR_CRM_Level_5__c' || flag){
            query += ' AND EUR_CRM_Level_4__c =: level4Value';
            flag =true;
        }
        if(field == 'EUR_CRM_Level_4__c' || flag){
            query += ' AND EUR_CRM_Level_3__c =: level3Value';
            flag =true;
        }
        if(field == 'EUR_CRM_Level_3__c' || flag){
            query += ' AND EUR_CRM_Level_2__c =: level2Value';
            flag =true; 
        }
        if(field == 'EUR_CRM_Level_2__c' || flag){
            query += ' AND EUR_CRM_Level_1__c =: level1Value';
            flag =true;
        }
        if(field == 'EUR_CRM_Level_1__c' || flag){
            query += ' AND EUR_CRM_Chain__c =: chainValue';
        }
        query += ' group by ' + field;
        AggregateResult[] groupedResults = Database.query(query);
        List<SelectOption> options = new List<SelectOption>();
        system.debug('@@ retrieve: ' + query);
        //options.add(new SelectOption(ALL, ALL));
        //feb 10. 2015. remove 'All' option from parent record.
        //if(field != 'EUR_CRM_Chain__c')
            options.add(new SelectOption(ALL, ALL));
        
        for (AggregateResult ar : groupedResults)  {
        String x = (String) ar.get(field);
        if(x==null)
            x = '';
        system.debug('@@ ' + x);
             options.add(new SelectOption(x, x)); 
        }
       // if(field == 'EUR_CRM_Chain__c')
          //  chainValue = options.get(1) != null ? options.get(0).getValue() : null;
          
        return options;    
    }
    
    //String query1 = 'select id,name, recordtype.developername from EUR_CRM_Customer_Taxonomy__c  where recordtype.name = \'' + cTaxRecordType + '\'';
    public void filter(){       
        String query1;
        if(String.IsEmpty(cTaxRecordType) || cTaxRecordType == null){
            cTaxRecordType = 'EUR_DE_Customer_Taxonomy';
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,  Label.EUR_CRM_SelectCusTaxWarningMessage));              
        isDraft = true;
        query1 = 'select id,name, recordtype.developername from EUR_CRM_Customer_Taxonomy__c  where recordtype.developername = \'' + cTaxRecordType + '\'';
        if(chainValue !=null && chainValue != ALL)
            query1 += ' AND EUR_CRM_Chain__c = \''+ String.escapeSingleQuotes(chainValue) +'\'';
            
        if(level1Value !=null && level1Value != ALL)
            query1 += ' AND EUR_CRM_Level_1__c = \''+ String.escapeSingleQuotes(level1Value)  +'\'';
        
        if(level2value !=null && level2Value != ALL)
            query1 += ' AND EUR_CRM_Level_2__c = \''+ String.escapeSingleQuotes(level2Value) +'\'';
        
        if(level3value !=null && level3Value != ALL)
            query1 += ' AND EUR_CRM_Level_3__c = \''+ String.escapeSingleQuotes(level3Value) +'\'';
        
        if(level4value !=null && level4Value != ALL)
            query1 += ' AND EUR_CRM_Level_4__c = \''+ String.escapeSingleQuotes(level4Value) +'\'';
        
        if(level5value !=null && level5Value != ALL)
            query1 += ' AND EUR_CRM_Level_5__c = \''+ String.escapeSingleQuotes(level5Value) +'\'';
        
        if(level6value !=null && level6Value != ALL)
            query1 += ' AND EUR_CRM_Level_6__c = \''+ String.escapeSingleQuotes(level6Value) +'\''; 
        
        if(level7value !=null && level7Value != ALL)
            query1 += ' AND EUR_CRM_Level_7__c = \''+ String.escapeSingleQuotes(level7Value) +'\'';  
        
        if(level8value !=null && level8Value != ALL)
            query1 += ' AND EUR_CRM_Level_8__c = \''+ String.escapeSingleQuotes(level8Value) +'\'';
        if(managementTypeValue !=null && managementTypeValue != Label.EUR_CRM_Regie_and_Independent)
            query1 += ' AND EUR_CRM_Management_Type__c = \''+ managementTypeValue+'\'';        
        //query1 += ' limit 1000';
        system.debug('$$$ ' +  query1);
        
        customerTaxonomyList = (List<EUR_CRM_Customer_Taxonomy__c>)Database.query(query1);
        //total_size = customerTaxonomyList.size();
        //counter = 0;
        setCon1(); 
    }
    private Boolean initTableElements = false;
    /*
    public List<EUR_CRM_Customer_Taxonomy__c> getTableElements(){
        if(!initTableElements){
            initTableElements = true;
            return customerTaxonomyList;
        } else{
           query1 +=' limit '+list_size+ ' offset ' + counter;
          system.debug('@@ ' + query1);
          customerTaxonomyList = (List<EUR_CRM_Customer_Taxonomy__c>)Database.query(query1);
          return customerTaxonomyList;
          }
    }*/
    
    public PageReference quickSave(){
        isDraft = false;
        Savepoint sp = Database.setSavepoint();
        try{
            //delete all customer taxonomy mapping
            //update objpromo
            //create taxonomy mapping
            RecordType ctmrt = [select id from recordtype where sobjecttype='EUR_CRM_OP_Customer_Taxonomy_Mapping__c' and developername='EUR_DE_OP_Customer_Taxonomy_Mapping'];
            List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> toDeleteOPCustTax = [select id from EUR_CRM_OP_Customer_Taxonomy_Mapping__c where EUR_CRM_ObjPromo__c =:objPromoIdStr];
            Map<String,Id> rMapping = new Map<String, Id>();

            for(RecordType rt : [select id,developername from recordtype where sobjecttype='EUR_CRM_OP_Customer_Taxonomy_Mapping__c'  ]){
                rMapping.put(rt.developername, rt.id); 
            }

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
            
            system.debug('### customerTaxonomyList: ' + customerTaxonomyList);
            system.debug('### recordTypeMapping: ' + recordTypeMapping);
            system.debug('### rMapping: ' + rMapping);

            for(EUR_CRM_Customer_Taxonomy__c cust: customerTaxonomyList){
                EUR_CRM_OP_Customer_Taxonomy_Mapping__c temp = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c(
                EUR_CRM_Customer_Taxonomy__c = cust.id, EUR_CRM_ObjPromo__c = objPromoIdStr);

                String devName = recordTypeMapping.get(cust.recordtype.developername);
                if(devName != null && rMapping.get(devName) != null)
                    temp.recordtypeid = rMapping.get(devName);               

                toInsertOPCustTax.add(temp);
            } 
                insert toInsertOPCustTax;
            objPromo.EUR_CRM_CustomerTaxonomy_Chain__c = chainValue;
            objPromo.EUR_CRM_CustomerTaxonomy_Level_1__c= level1Value;
            objPromo.EUR_CRM_CustomerTaxonomy_Level_2__c= level2Value; 
            objPromo.EUR_CRM_CustomerTaxonomy_Level_3__c= level3Value;
            objPromo.EUR_CRM_CustomerTaxonomy_Level_4__c= level4Value;
            objPromo.EUR_CRM_CustomerTaxonomy_Level_5__c= level5Value;
            objPromo.EUR_CRM_CustomerTaxonomy_Level_6__c= level6Value;
            objPromo.EUR_CRM_CustomerTaxonomy_Level_7__c= level7Value;
            objPromo.EUR_CRM_CustomerTaxonomy_Level_8__c= level8Value;
            objPromo.EUR_CRM_CustomerTaxonomy_Mgmt_Type__c =  managementTypeValue;
            
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