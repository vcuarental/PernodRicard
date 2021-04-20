/*
Controller for EUR_CRM_AccountFilterByCustTaxController
2017.JAN.03
*/

public without sharing class EUR_CRM_AccountFilterByCustTaxController{ 
    //public String objPromoIdStr {get;set;}

    private final Map<String, String> recordTypeMapping = new Map<String,String>{
        'EUR_DE_Customer_Taxonomy' => 'EUR_DE_OP_Customer_Taxonomy_Mapping',
        'EUR_FI_ON_Trade_Customer_Taxonomy' => 'EUR_FI_O_P_Customer_Taxonomy_Mapping',        
        'EUR_FI_OFF_Trade_Customer_Taxonomy' => 'EUR_FI_O_P_Customer_Taxonomy_Mapping'
    };


    public List<EUR_CRM_Account__c> AccountList {get;set;}
    public EUR_CRM_AccountFilterByCustTaxController custFilterController{get{return this;}
    																	 set;}

    public Integer AccCount {get;set;}

    public String custTaxRt {get; set;}
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
    
    private Boolean initLevel1=false;
    private Boolean initLevel2=false;
    private Boolean initLevel3=false;
    private Boolean initLevel4=false;
    private Boolean initLevel5=false;
    private Boolean initLevel6=false;
    private Boolean initLevel7=false;
    private Boolean initLevel8=false;
    private Boolean initMgmtType =false;
    private List<String> CtRtName;
    private List<RecordType> CtRt;
    private String rtInCause;
    
    public String managementTypeValue {get;set;}     
    public List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList {get; set;}  
    public List<EUR_CRM_Account__c> euAccountList {get; set;}
    private final String ALL = 'All *';
    //public Boolean initDummyVar { get { if (initDummyVar != true) initDummyVar = init(); return initDummyVar; } set; }
    public Boolean initDummyVar { get;set; }
    private EUR_CRM_ObjPromo__c objPromo;
    
    public Boolean isDraft {get;set;} 
    public Boolean saveDisabled {get;set;}

    public Void EUR_CRM_AccountFilterByCustTaxController()
    {
    	System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController: Construct');
    	//countryCode = 'DE';
    	init();
    }
    public Boolean init(){
    	System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController: init:' + custTaxRt);



    	//String CC = 'EUR_' + countryCode + '_%';
    	CtRt = [SELECT ID,DeveloperName FROM RecordType WHERE SObjectType = 'EUR_CRM_Customer_Taxonomy__c' and DeveloperName =: custTaxRt];

    	if(CtRt.Size() > 0)
    	{
	    	rtInCause = '(';

	    	for(RecordType rt : CtRt)
	    	{
	    		rtInCause = rtInCause + '\'' + rt.Id + '\',';
	    	}

	    	rtInCause = rtInCause.removeEnd(',');
	    	rtInCause = rtInCause + ') ';
    	}

    	System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController:CtRt:' + rtInCause);

        isDraft = false;
        saveDisabled = false;
        If(customerTaxonomyList == null)
        {
        	customerTaxonomyList = retrieveExistingCustomerTaxonomy();
        }
        
        System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController:New Con:customerTaxonomyList:'+customerTaxonomyList);
        if(con == null)
        {
        	con = new ApexPages.StandardSetController(customerTaxonomyList);
        }

        return true;
    } 
    

    
    public List<SelectOption> getChainOptions(){
    	//countryCode = 'DE';
    	init();
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
    	System.Debug('EUR_CRM_AccountFilterByCustTaxController:retrieveListValues');
    	String query;
    	if (CtRt.size() > 0)
    	{
    		query = 'select ' + field +' from EUR_CRM_Customer_Taxonomy__c where recordtypeid in ' + rtInCause;
    	}

        
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
        system.debug('@@@ retrieve' + query);
        AggregateResult[] groupedResults = Database.query(query);
        List<SelectOption> options = new List<SelectOption>();
        
        //options.add(new SelectOption(ALL, ALL));
        //feb 10. 2015. remove 'All' option from parent record.
        //if(field != 'EUR_CRM_Chain__c')
            options.add(new SelectOption(ALL, ALL));
        
        for (AggregateResult ar : groupedResults)  {
        String x = (String) ar.get(field);
        if(x==null)
            x = '';
        system.debug('@@@SelectOption:' + x);
             options.add(new SelectOption(x, x)); 
        }
       // if(field == 'EUR_CRM_Chain__c')
          //  chainValue = options.get(1) != null ? options.get(0).getValue() : null;
          
        return options;    
    }
    //String query1 = 'select id,name, recordtype.developername from EUR_CRM_Customer_Taxonomy__c  where recordtype.name = \'' + CtRtName + '\'';
    String query1 = 'select id,Name,recordtypeid from EUR_CRM_Customer_Taxonomy__c  where recordtypeid in ' + rtInCause;

    public void filter(){       
        System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController:filter:');
        isDraft = true;


        String SurveyID = currentURLStr.split('=')[1];
        System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController:filter:SurveyID:' + SurveyID);

        EUR_CRM_Survey_Header__c Header = [SELECT Id,Name FROM EUR_CRM_Survey_Header__c Where Id =: SurveyID Limit 1];

//query1 = 'select id,name, recordtype.developername from EUR_CRM_Customer_Taxonomy__c  where recordtype.name = \'' + CtRtName + '\'';

        query1 = 'select id,Name,recordtypeid from EUR_CRM_Customer_Taxonomy__c  where recordtypeid in ' + rtInCause;
        if(chainValue !=null && chainValue != ALL){
            query1 += ' AND EUR_CRM_Chain__c = \''+ String.escapeSingleQuotes(chainValue) +'\'';
            Header.EUR_CRM_Account_Filter_CustTax_Chain__c = String.escapeSingleQuotes(chainValue);
        }
        else{Header.EUR_CRM_Account_Filter_CustTax_Chain__c = null;}    
        if(level1Value !=null && level1Value != ALL){
            query1 += ' AND EUR_CRM_Level_1__c = \''+ String.escapeSingleQuotes(level1Value)  +'\'';
        	Header.EUR_CRM_Account_Filter_CustTax_Level_1__c = String.escapeSingleQuotes(level1Value);
        }
        else{Header.EUR_CRM_Account_Filter_CustTax_Level_1__c = null;}
        if(level2value !=null && level2Value != ALL){
            query1 += ' AND EUR_CRM_Level_2__c = \''+ String.escapeSingleQuotes(level2Value) +'\'';
        	Header.EUR_CRM_Account_Filter_CustTax_Level_2__c = String.escapeSingleQuotes(level2Value);
        }
        else{Header.EUR_CRM_Account_Filter_CustTax_Level_2__c = null;}
        if(level3value !=null && level3Value != ALL){
            query1 += ' AND EUR_CRM_Level_3__c = \''+ String.escapeSingleQuotes(level3Value) +'\'';
        	Header.EUR_CRM_Account_Filter_CustTax_Level_3__c = String.escapeSingleQuotes(level3Value);
        }
        else{Header.EUR_CRM_Account_Filter_CustTax_Level_3__c = null;}
        if(level4value !=null && level4Value != ALL){
            query1 += ' AND EUR_CRM_Level_4__c = \''+ String.escapeSingleQuotes(level4Value) +'\'';
        	Header.EUR_CRM_Account_Filter_CustTax_Level_4__c = String.escapeSingleQuotes(level4Value);
        }
        else{Header.EUR_CRM_Account_Filter_CustTax_Level_4__c = null;}
        if(level5value !=null && level5Value != ALL){
            query1 += ' AND EUR_CRM_Level_5__c = \''+ String.escapeSingleQuotes(level5Value) +'\'';
        	Header.EUR_CRM_Account_Filter_CustTax_Level_5__c = String.escapeSingleQuotes(level5Value);
        }
        else{Header.EUR_CRM_Account_Filter_CustTax_Level_5__c = null;}
        if(level6value !=null && level6Value != ALL){
            query1 += ' AND EUR_CRM_Level_6__c = \''+ String.escapeSingleQuotes(level6Value) +'\''; 
        	Header.EUR_CRM_Account_Filter_CustTax_Level_6__c = String.escapeSingleQuotes(level6Value);
        }
        else{Header.EUR_CRM_Account_Filter_CustTax_Level_6__c = null;}
        if(level7value !=null && level7Value != ALL){
            query1 += ' AND EUR_CRM_Level_7__c = \''+ String.escapeSingleQuotes(level7Value) +'\'';  
        	Header.EUR_CRM_Account_Filter_CustTax_Level_7__c = String.escapeSingleQuotes(level7Value);
        }
        else{Header.EUR_CRM_Account_Filter_CustTax_Level_7__c = null;}
        if(level8value !=null && level8Value != ALL){
            query1 += ' AND EUR_CRM_Level_8__c = \''+ String.escapeSingleQuotes(level8Value) +'\'';
        	Header.EUR_CRM_Account_Filter_CustTax_Level_8__c = String.escapeSingleQuotes(level8Value);
        }
        else{Header.EUR_CRM_Account_Filter_CustTax_Level_8__c = null;}
        Header.EUR_CRM_Account_Filter_ID__c = null;
        //Header.EUR_CRM_Account_Filter_PROS_ImageLevel__c = null;
        //Header.EUR_CRM_Account_Filter_PROS_OutletType__c = null;

        if(managementTypeValue !=null && managementTypeValue != Label.EUR_CRM_Regie_and_Independent)
            query1 += ' AND EUR_CRM_Management_Type__c = \''+ managementTypeValue+'\'';        
        //query1 += ' limit 1000';
        system.debug('$$$ ' +  query1);
        
        customerTaxonomyList = (List<EUR_CRM_Customer_Taxonomy__c>)Database.query(query1);

        System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController:filter:query1:' + query1);

        AccountList = [SELECT id FROM EUR_CRM_Account__c WHERE EUR_JB_Customer_Taxonomy__c in :customerTaxonomyList Limit 1000];
        AccCount = AccountList.size();
        System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController:filter:AccountListSize:' + AccountList.size());




        

        update Header;
        System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController:updateHeader:');

        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,  'Number of Account Selected:' + AccountList.Size()));

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
    
    public List<EUR_CRM_Account__c> retrieveAccount()
    {
    	List<EUR_CRM_Account__c> accList = New List<EUR_CRM_Account__c>();

    	return accList;
    }


    
    public ApexPages.StandardSetController con { 
        get {
            if(con == null) {
                //retrieveExistingCustomerTaxonomy(); 
               //con = new ApexPages.StandardSetController(retrieveExistingCustomerTaxonomy()); 
               System.Debug('@@@con is null');
               System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController:New Con:retrieveExistingCustomerTaxonomy:');
               con = new ApexPages.StandardSetController(retrieveExistingCustomerTaxonomy());               
               con.setPageSize(20);
            }
            return con;
        }
        set; 
    } 
    public void setCon1(){
    	System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController:New Con:customerTaxonomyList:' + customerTaxonomyList);
        con = new ApexPages.StandardSetController(customerTaxonomyList); 
        con.setPageSize(20); 
    }

    //public List<EUR_CRM_Customer_Taxonomy__c> taxList {get;set;}
    public List<EUR_CRM_Customer_Taxonomy__c> getTaxList(){
        List<EUR_CRM_Customer_Taxonomy__c> taxList = new List<EUR_CRM_Customer_Taxonomy__c>();
            for(EUR_CRM_Customer_Taxonomy__c tax: (List<EUR_CRM_Customer_Taxonomy__c>) con.getRecords()){
            	system.Debug('@@@getTaxList:' + tax.name);
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


    public List<EUR_CRM_Customer_Taxonomy__c> retrieveExistingCustomerTaxonomy(){
        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyListTemp = new  List<EUR_CRM_Customer_Taxonomy__c>();
        
        /*if(objPromoIdStr != null && objPromoIdStr != ''){
            Set<id> custTaxSet = new Set<ID>();
            for(EUR_CRM_OP_Customer_Taxonomy_Mapping__c opCustTax : [select EUR_CRM_Customer_Taxonomy__c from
                EUR_CRM_OP_Customer_Taxonomy_Mapping__c  where EUR_CRM_ObjPromo__c =: objPromoIdStr]){
                custTaxSet.add(opCustTax.EUR_CRM_Customer_Taxonomy__c);
            }
            customerTaxonomyListTemp  = [select id, name, recordtype.developername  from EUR_CRM_Customer_Taxonomy__c where id in : custTaxSet];
        } */
        //total_size = customerTaxonomyList.size();
        customerTaxonomyListTemp  = [select id, name, recordtype.developername  from EUR_CRM_Customer_Taxonomy__c where recordtypeid in :CtRt];
		System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController: CtRt :' + CtRt);
        System.Debug('@@@EUR_CRM_AccountFilterByCustTaxController: customerTaxonomyListTemp :' + customerTaxonomyListTemp);

        return customerTaxonomyListTemp ;
    }


/*****************************************

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

 *****************/
}