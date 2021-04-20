public class EUR_CRM_SelectCustTaxComponentExtCtrller {
    public String objPromoIdStr                    {get;set;}
    public String countryCode                      {get;set;}
    public String opAccountMappingRecordTypeName   {get;set;}
    public String currentURLStr                    {get;set;}
    public String bannerValue                      {get;set;}
    public List<String> bannerMultiValue           {get;set;}
    public String groupValue                       {get;set;}
    public List<String> groupMultiValue            {get;set;}
    public String chainValue                       {get;set;}
    public List<String> chainMultiValue            {get;set;}
    public String subChainValue                    {get;set;} 
    public List<String> subChainMultiValue         {get;set;}
    public String regionValue                      {get;set;}
    public List<String> regionMultiValue           {get;set;}
    public String level1Value                      {get;set;}
    public List<String> level1MultiValue           {get;set;}
    public String level2Value                      {get;set;}
    public List<String> level2MultiValue           {get;set;}
    // TODO: Deprecate isRemoveOldOPAccountMapping?   
    public Boolean isRemoveOldOPAccountMapping     {get;set;}

    List<EUR_CRM_Account__c> euAccounts;
    Integer pSize = 20;
    @TestVisible Set<Id> selectedAccounts = new Set<Id>();
    @TestVisible Set<Id> deselectedAccounts = new Set<Id>();
    
    public Boolean sortAccount {get;set;}
    public String sortFieldName {get;set;} 
    public String oldSortFieldName  {get;set;} 
    public String sortOrder {get;set;}

    private Boolean initRegion =false;
    private Boolean initSubChain  =false;
    private Boolean initLevel1 =false;
    private Boolean initLevel2 =false;
    
    public List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList {get; set;}  
    public List<EUR_CRM_Account__c> euAccountList {get; set;}
    private final String ALL = 'All *';
    public Boolean initDummyVar { get {
        if (initDummyVar != true) initDummyVar = init(); return initDummyVar; } set; }
    public EUR_CRM_ObjPromo__c objPromo {get; set;}
    
    public Boolean isDraft {get;set;} 
    public Boolean saveDisabled {get;set;}
    public Boolean isMultiSelectEnabled {get; set;}
    public Boolean isSelectorRendered {get; set;}
    public Boolean isSelectorReRendered {get; set;}
    
    public String custTaxRecordTypeStr {get;set;} 
    public String custMappingRecordTypeStr {get;set;} 
    public String fieldsStr{get;set;}
    public Boolean limitFieldsBool {get;set;}
    
    public Boolean isAllSelected {get; set;}  
    public ApexPages.StandardController standardController {get; set;}
    public ApexPages.StandardSetController accCon {
        get {
            
            if(accCon == null) {          
                
                String query = 'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c,  EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
                    ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, recordTypeId, EUR_CRM_Company_Establishment__c '  + 
                    'from EUR_CRM_Account__c where eur_crm_status__c = \'Active\' and eur_crm_country_code__c = \'' + countryCode + '\'';
                
                List<Id> custTaxIds = new List<Id>(); 
                if(customerTaxonomyList != null) {
                    System.debug(customerTaxonomyList);
                    
                    for(EUR_CRM_Customer_Taxonomy__c cust: customerTaxonomyList) {
                        custTaxIds.add(cust.Id);
                    }
                    
                    query += ' AND EUR_JB_Customer_Taxonomy__c IN :custTaxIds';
                    accCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));

                    this.accCon.setPageSize(pSize);
                    this.euAccounts = null;
                    this.selectedAccounts = new Set<Id>();

                    System.debug(query);
                    System.debug(accCon);
                } else {
                    accCon = new ApexPages.StandardSetController(new List<EUR_CRM_Account__c>());
                }
            }
            
            return accCon;
        }
        set;
    }

    public EUR_CRM_SelectCustTaxComponentExtCtrller(){
        init();
    }

    //--
    public Boolean init(){
        isDraft = false;
        saveDisabled = false;
        customerTaxonomyList = retrieveExistingCustomerTaxonomy();
        con = new ApexPages.StandardSetController(customerTaxonomyList);

        System.debug(objPromoIdStr);

        if(objPromoIdStr != null && objPromoIdStr != ''){
            objPromo = [select id, EUR_CRM_Status__c, EUR_CRM_CustomerTaxonomy_Chain__c, EUR_CRM_Customer_Taxonomy_Chain_Region__c, EUR_CRM_Customer_Taxonomy_Sub_Chain__c, 
                EUR_CRM_CustomerTaxonomy_Level_1__c, EUR_CRM_CustomerTaxonomy_Level_2__c,
                recordtype.developername from EUR_CRM_ObjPromo__c where id = : objPromoIdStr];
            
            if(objPromo != null ){
                saveDisabled = objPromo.EUR_CRM_Status__c != 'Draft';

                System.debug(isMultiSelectEnabled);
                System.debug(objPromo);

                if(isMultiSelectEnabled != null && isMultiSelectEnabled) {
                    bannerMultiValue = new List<String>{''};
                    groupMultiValue = new List<String>{''};
                    chainMultiValue = new List<String>{objPromo.EUR_CRM_CustomerTaxonomy_Chain__c};
                    subChainMultiValue = new List<String>{objPromo.EUR_CRM_Customer_Taxonomy_Sub_Chain__c};
                    regionMultiValue = new List<String>{objPromo.EUR_CRM_Customer_Taxonomy_Chain_Region__c};
                    level1MultiValue = new List<String>{objPromo.EUR_CRM_CustomerTaxonomy_Level_1__c};
                    level2MultiValue = new List<String>{objPromo.EUR_CRM_CustomerTaxonomy_Level_2__c};
                } else {
                    bannerValue = '';
                    groupValue = '';
                    chainValue = objPromo.EUR_CRM_CustomerTaxonomy_Chain__c;
                    subChainValue = objPromo.EUR_CRM_Customer_Taxonomy_Sub_Chain__c;
                    regionValue = objPromo.EUR_CRM_Customer_Taxonomy_Chain_Region__c;
                    level1Value = objPromo.EUR_CRM_CustomerTaxonomy_Level_1__c;
                    level2Value = objPromo.EUR_CRM_CustomerTaxonomy_Level_2__c;
                }
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

        return customerTaxonomyListTemp ;
    }
    
    public Boolean getIsRegionIncluded() {
        return fieldsStr.contains('EUR_CRM_Region__c');
    }

    public Boolean getIsBannerIncluded() {
        return fieldsStr.contains('EUR_CRM_Banner__c');
    }

    public Boolean getIsGroupIncluded() {
        return fieldsStr.contains('EUR_CRM_Group__c');
    }

    public Boolean getIsSubChainIncluded() {
        return fieldsStr.contains('EUR_CRM_Sub_Chain__c');
    }
    
    public Boolean getIsLevel1Included() {
        return fieldsStr.contains('EUR_CRM_Level_1__c');
    }
    
    public Boolean getIsLevel2Included() {
        return fieldsStr.contains('EUR_CRM_Level_2__c');
    }

    public List<SelectOption> getGroupOptions(){
        return retrieveListValues(null, 'EUR_CRM_Group__c', new List<String>{''});
    }

    public List<SelectOption> getChainOptions(){
        if(countryCode != 'BE'){
            return retrieveListValues(null, 'EUR_CRM_Chain__c', new List<String>{''});
        } else {
            if(isMultiSelectEnabled != null && isMultiSelectEnabled) {
                return retrieveListValues('EUR_CRM_Group__c', 'EUR_CRM_Chain__c', groupMultiValue);
            } else {
                return retrieveListValues('EUR_CRM_Group__c', 'EUR_CRM_Chain__c', new List<String>{groupValue});
            }
        }
    }

    public List<SelectOption> getBannerOptions(){
        //return retrieveListValues(null, 'EUR_CRM_Banner__c', new List<String>{''});
        System.Debug('@@@group value:' + groupValue);

        If(countryCode == 'BE' && (chainValue == null || chainValue == '')){
            return returnAllOnly();
        }

        if(isMultiSelectEnabled != null && isMultiSelectEnabled) {
            return retrieveListValues('EUR_CRM_Chain__c', 'EUR_CRM_Banner__c', chainMultiValue);
        } else {
            return retrieveListValues('EUR_CRM_Chain__c', 'EUR_CRM_Banner__c', new List<String>{chainValue});
        }
    }

    
    public List<SelectOption> getSubChainOptions (){
        if(isMultiSelectEnabled != null && isMultiSelectEnabled) {
            return retrieveListValues('EUR_CRM_Chain__c', 'EUR_CRM_Sub_Chain__c', chainMultiValue);
        } else {
            return retrieveListValues('EUR_CRM_Chain__c', 'EUR_CRM_Sub_Chain__c', new List<String>{chainValue});
        }
    }
    
    public List<SelectOption> getRegionOptions (){
        if(isMultiSelectEnabled != null && isMultiSelectEnabled) {
            return retrieveListValues('EUR_CRM_Sub_Chain__c', 'EUR_CRM_Region__c', subChainMultiValue);
        } else {
            return retrieveListValues('EUR_CRM_Sub_Chain__c', 'EUR_CRM_Region__c', new List<String>{subChainValue});
        }
    }

    public List<SelectOption> getLevel1Options (){
        if(isMultiSelectEnabled != null && isMultiSelectEnabled) {
            return retrieveListValues('EUR_CRM_Sub_Chain__c', 'EUR_CRM_Level_1__c', subChainMultiValue);
        } else {
            return retrieveListValues('EUR_CRM_Sub_Chain__c', 'EUR_CRM_Level_1__c', new List<String>{subChainValue});
        }
    }
    
    public List<SelectOption> getLevel2Options (){
        if(isMultiSelectEnabled != null && isMultiSelectEnabled) {
            return retrieveListValues('EUR_CRM_Level_1__c', 'EUR_CRM_Level_2__c', level1MultiValue);
        } else {
            return retrieveListValues('EUR_CRM_Level_1__c', 'EUR_CRM_Level_2__c', new List<String>{level1Value});
        }
    } 

    public List<SelectOption> retrieveListValues(String controllingField, String field, List<String> controllingFieldValue){ 
        System.debug(controllingField);
        System.debug(controllingFieldValue);

        String query = 'SELECT ' + field + ' FROM EUR_CRM_Customer_Taxonomy__c ';
       
        if(String.IsEmpty(custTaxRecordTypeStr))
            query += ' WHERE recordtype.developername = \'EUR_DE_Customer_Taxonomy\' ';
        else
            query += ' WHERE recordtype.developername = \''+custTaxRecordTypeStr+'\' ';
        
        if(controllingField != null && controllingFieldValue != null) {
            query += ' AND ' + controllingField + ' IN : controllingFieldValue';
        }
        query += ' group by ' + field;

        System.debug(query);
        Boolean flag = false; 
        AggregateResult[] groupedResults = Database.query(query);
        System.debug(groupedResults);
        List<SelectOption> options = new List<SelectOption>();
        system.debug('@@ retrieve' + query);

        options.add(new SelectOption(ALL, ALL));
        
        for (AggregateResult ar : groupedResults)  {
            String x = (String) ar.get(field);
            if(x==null)
                x = '';
            system.debug('@@Option:' + x);
            options.add(new SelectOption(x, x)); 
        }

        return options;    
    }

    public List<SelectOption> returnAllOnly(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(ALL, ALL));
        return options; 
    }
    
    public void filter(){       
        System.Debug('$$$filter');
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,  Label.EUR_CRM_SelectCusTaxWarningMessage));              
        isDraft = true;
        isSelectorReRendered = true;
        String query1 =  'select id,name from EUR_CRM_Customer_Taxonomy__c ';//  where recordtype.developername = \'EUR_DE_Customer_Taxonomy\'';
        
        /*System.debug(chainMultiValue);
        System.debug(subChainMultiValue);
        System.debug(level1MultiValue);
        System.debug(level2MultiValue);*/

        If(isMultiSelectEnabled == null || !isMultiSelectEnabled){
            if(String.IsEmpty(custTaxRecordTypeStr)) {
                query1 += '  where recordtype.developername = \'EUR_DE_Customer_Taxonomy\' ';
            } else {
                query1 += '  where recordtype.developername = \''+custTaxRecordTypeStr+'\' ';
            }

            if(groupValue !=null && groupValue != ALL) {
                System.Debug('$$' + groupValue);
                query1 += ' AND EUR_CRM_Group__c = \''+ String.escapeSingleQuotes(groupValue) +'\'';
            }

            if(chainValue !=null && chainValue != ALL) {
                System.Debug('$$' + chainvalue);
                query1 += ' AND EUR_CRM_Chain__c = \''+ String.escapeSingleQuotes(chainValue) +'\'';
            }

            if(bannerValue !=null && bannerValue != ALL) {
                System.Debug('$$' + bannerValue);
                query1 += ' AND EUR_CRM_Banner__c = \''+ String.escapeSingleQuotes(bannerValue) +'\'';
            }

            if(subChainValue !=null && subChainValue != ALL) {
                System.Debug('$$' + subChainValue);
                query1 += ' AND EUR_CRM_Sub_Chain__c = \''+ String.escapeSingleQuotes(subChainValue)  +'\'';
            }

            if(regionValue !=null && regionValue != ALL) {
                System.Debug('$$' + regionValue);
                query1 += ' AND EUR_CRM_Region__c = \''+ String.escapeSingleQuotes(regionValue) +'\'';
            }

            if(level1Value !=null && level1Value != ALL) {
                System.Debug('$$' + level1Value);
                query1 += ' AND EUR_CRM_Level_1__c = \''+ String.escapeSingleQuotes(level1Value)  +'\'';
            }

            if(level2value !=null && level2Value != ALL) {
                System.Debug('$$' + level2Value);
                query1 += ' AND EUR_CRM_Level_2__c = \''+ String.escapeSingleQuotes(level2Value) +'\'';
            }
        }Else{            
            if(String.IsEmpty(custTaxRecordTypeStr)) {
                query1 += '  where recordtype.developername = \'EUR_DE_Customer_Taxonomy\' ';
            } else {
                query1 += '  where recordtype.developername = \''+custTaxRecordTypeStr+'\' ';
            }

            if(chainValue !=null && chainValue != ALL) {
                query1 += ' AND EUR_CRM_Chain__c = \''+ String.escapeSingleQuotes(chainValue) +'\'';
            } else if(chainMultiValue !=null && !isAllSelectOptionsSelected(chainMultiValue)) {
                query1 += ' AND EUR_CRM_Chain__c IN :chainMultiValue';
            }

            if(subChainValue !=null && subChainValue != ALL) {
                query1 += ' AND EUR_CRM_Sub_Chain__c = \''+ String.escapeSingleQuotes(subChainValue)  +'\'';
            } else if(subChainMultiValue !=null && !isAllSelectOptionsSelected(subChainMultiValue)) {
                query1 += ' AND EUR_CRM_Sub_Chain__c IN :subChainMultiValue';
            }

            if(regionValue !=null && regionValue != ALL) {
                query1 += ' AND EUR_CRM_Region__c = \''+ String.escapeSingleQuotes(regionValue) +'\'';
            } else if(regionMultiValue !=null && !isAllSelectOptionsSelected(regionMultiValue)) {
                query1 += ' AND EUR_CRM_Region__c IN :regionMultiValue';
            }

            if(level1Value !=null && level1Value != ALL) {
                query1 += ' AND EUR_CRM_Level_1__c = \''+ String.escapeSingleQuotes(level1Value)  +'\'';
            } else if(level1MultiValue !=null && !isAllSelectOptionsSelected(level1MultiValue)) {
                query1 += ' AND EUR_CRM_Level_1__c IN :level1MultiValue';
            }

            if(level2value !=null && level2Value != ALL) {
                query1 += ' AND EUR_CRM_Level_2__c = \''+ String.escapeSingleQuotes(level2Value) +'\'';
            } else if(level2MultiValue !=null && !isAllSelectOptionsSelected(level2MultiValue)) {
                query1 += ' AND EUR_CRM_Level_2__c IN :level2MultiValue';
            }
        }
          
        system.debug('$$$ ' +  query1);
        
        customerTaxonomyList = (List<EUR_CRM_Customer_Taxonomy__c>)Database.query(query1);

        this.accCon = null;
        this.accCon.setPageNumber(1);
        this.euAccounts = null;
        this.selectedAccounts = new Set<Id>();
        this.deselectedAccounts = new Set<Id>();
        this.isAllSelected = true;

        System.debug(this.accCon);
        System.debug(this.accCon.getRecords());
    }

    public Boolean isAllSelectOptionsSelected(List<String> selectOptions) {
        for(String selectOption: selectOptions) {
            if(selectOption == ALL) {
                return true;
            }
        }

        return false;
    }

    private Boolean initTableElements = false;
    
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

    public List<EUR_CRM_Account__c> retrieveAccounts(){
        if(euAccounts == null) {
          integer pNum = this.accCon.getPageNumber();
          this.accCon.first();
          
          System.debug('Re-initializing euAccounts');
          euAccounts = new List<EUR_CRM_Account__c>();          
          
          while(this.accCon.getHasNext()) {
              System.debug(this.accCon.getRecords());
              euAccounts.addAll((List<EUR_CRM_Account__c>)this.accCon.getRecords());
              this.accCon.next();
          }
          
          // Add the last page to the list of accounts
          euAccounts.addAll((List<EUR_CRM_Account__c>)this.accCon.getRecords());
            
          this.accCon.setPageNumber(pNum);
        }
        
        System.debug(euAccounts.size());
        return euAccounts;
    }
    
    public List<euAccountsWrapper> getWrapAccounts(){        
        List<euAccountsWrapper> wrapAccounts = new List<euAccountsWrapper>();

        for (EUR_CRM_Account__c acc : (List<EUR_CRM_Account__c>)accCon.getRecords()) {
            euAccountsWrapper wrapAccount = new euAccountsWrapper(acc, !deselectedAccounts.contains(acc.Id));
            wrapAccounts.add(wrapAccount);
        }

        return wrapAccounts;
    }
    
    public PageReference sort(){ 
        sortAccount = true;
        accCon = null;
        if(sortFieldName != oldSortFieldName  ){
            sortOrder = null;
            oldSortFieldName  = sortFieldName ;
        }
        sortOrder = sortOrder == null || sortOrder == 'DESC' ? 'ASC' : 'DESC';  
        return null;
    }
    
    public void doNext(){
        if(this.accCon.getHasNext()) {
            this.accCon.next();
            getWrapAccounts();
            System.debug(this.accCon.getRecords());
        }
        
    }

    public void doPrevious(){
        if(this.accCon.getHasPrevious()) {
            this.accCon.previous();
            getWrapAccounts();
        }
    } 
    public void accConFirst() {
        accCon.first();
        getWrapAccounts();
    }

    // returns the last page of records
    public void accConLast() {
        accCon.last();
        getWrapAccounts();
    }
     
    public Boolean getHasPrevious(){
        return this.accCon.getHasPrevious();
    }

    /*
    *   return whether next page exists
    */
    public Boolean getHasNext(){
        return this.accCon.getHasNext();
    }
    
    public Integer getAccConPageNumber(){
        return this.accCon.getPageNumber();
    }

    public Integer getTotalPages(){

        Decimal totalSize = this.accCon.getResultSize();
        Decimal pageSize = this.accCon.getPageSize();

        Decimal pages = totalSize/pageSize;

        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    // returns the page number of the current page set
    public Integer accConPageNumber {
        get {
            return accCon.getPageNumber();
        }
        set;
    }
    
    public Integer getAccConPageSize(){
        return accCon.getPageSize() != null ? accCon.getPageSize() : 0;
    }
    
    public Integer getAccConRecordSize(){
        return accCon.getResultSize() != null ? accCon.getResultSize() : 0;
    }
    
    public String contextItem{get;set;}
    
    //Method to Select a Record
    public void doSelectItem(){
        this.selectedAccounts.add(this.contextItem);
        this.deselectedAccounts.remove(this.contextItem);    //Sid 2.1

        system.debug('doSelectItem selectedAccounts ' + selectedAccounts.size());
        system.debug('doSelectItem deselectedAccounts ' + deselectedAccounts.size());
    }
    
    public List<Id> getSelectedAccounts() {
        List<Id> returnedList = new List<Id>();
        returnedList.addAll(this.selectedAccounts);
        
        return returnedList;
    }
    
    //Method to De-Select a Record
    public void doDeselectItem(){

        this.selectedAccounts.remove(this.contextItem);
        this.deselectedAccounts.add(this.contextItem);    //Sid 2.1

        system.debug('doDeselectItem selectedAccounts ' + selectedAccounts.size());
        system.debug('doDeselectItem deselectedAccounts ' + deselectedAccounts.size());
    }
    
    public Boolean getHasSelectedAccounts(){
        return selectedAccounts.size() > 0;
    }
    
    //Method to Select All Record
    public void selectAll() {
        this.isAllSelected = !this.isAllSelected;
        this.selectedAccounts = new Set<Id>();
        this.deselectedAccounts = new Set<Id>();
    }
    
    public Boolean getIsDeactivated() {
        return this.objPromo.EUR_CRM_Status__c == 'Deactivated';
    }
    
    public List<EUR_CRM_ObjPromo_Account_Mapping__c> removeDuplicateOPAccounts(Set<Id> existingOPAccountIds, List<EUR_CRM_ObjPromo_Account_Mapping__c> toInsertOPAccounts) {
        List<EUR_CRM_ObjPromo_Account_Mapping__c> uniqueOPAccounts = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        
        for(Integer i = 0; i < toInsertOPAccounts.size(); i++) {
            System.debug(toInsertOPAccounts[i]);
            if(!existingOPAccountIds.contains(toInsertOPAccounts[i].EUR_CRM_Account__c)) {
                // If the account doesn't exist, add to uniqueOPAccounts list
                uniqueOPAccounts.add(toInsertOPAccounts[i]);
            }
        }
        
        return uniqueOPAccounts;
    }
    
    public PageReference quickSaveAccounts() {
        Savepoint sp = Database.setSavepoint();
        
        try {
            Id opAccountMappingRecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Account_Mapping__c' + this.opAccountMappingRecordTypeName);
        
            System.debug(opAccountMappingRecordTypeId);
            System.debug(this.opAccountMappingRecordTypeName);
            
            List<EUR_CRM_ObjPromo_Account_Mapping__c> toDeleteOPAccounts = [select id, EUR_CRM_Account__c
                                                                            from EUR_CRM_ObjPromo_Account_Mapping__c
                                                                            where EUR_CRM_ObjPromo__c =:objPromo.id];

                                                                            
            List<EUR_CRM_ObjPromo_Target__c> toDeleteOPTargets = new List<EUR_CRM_ObjPromo_Target__c>();
            //Delete Everything If OP is BE
            if(countryCode == 'BE'){
                toDeleteOPTargets = [SELECT id FROM EUR_CRM_ObjPromo_Target__c
                                     WHERE EUR_CRM_ObjPromo__c =:objPromo.Id];
            }else {
                toDeleteOPTargets = [SELECT id FROM EUR_CRM_ObjPromo_Target__c
                                     WHERE EUR_CRM_ObjPromo__c =:objPromo.Id
                                     AND EUR_CRM_O_P_Target__c != null];
            }

            System.debug(toDeleteOPAccounts);

            if(this.objPromo.EUR_CRM_Status__c == 'Draft') {
                // Deletes all inserted accounts and targets if the O/P is still in draft mode 
                
                if(toDeleteOPAccounts!= null && toDeleteOPAccounts.size() > 0){
                    // Removes all inserted accounts regardless of duplication
                    delete toDeleteOPAccounts;
                }
                
                if(toDeleteOPTargets != null && toDeleteOPTargets.size() > 0) {
                    delete toDeleteOPTargets;
                }
            }
            List<EUR_CRM_Account__c> retrievedAccount = retrieveAccounts();
            // Inserts OP Account Mapping
            List<EUR_CRM_ObjPromo_Account_Mapping__c> toInsertOPAccounts = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();

            system.debug('*** isAllSelected ' + isAllSelected);
            system.debug('*** deselectedAccounts ' + deselectedAccounts);
            system.debug('*** selectedAccounts ' + selectedAccounts);
            for(EUR_CRM_Account__c euAcc: retrievedAccount){                
                if((isAllSelected && !deselectedAccounts.contains(euAcc.id)) || (!isAllSelected && selectedAccounts.contains(euAcc.id))){
                    EUR_CRM_ObjPromo_Account_Mapping__c opAccount = new EUR_CRM_ObjPromo_Account_Mapping__c(
                        EUR_CRM_Account__c = euAcc.Id,
                        EUR_CRM_ObjPromo__c = objPromo.id,
                        EUR_CRM_Is_Active__c = false
                    );
                    
                    if(opAccountMappingRecordTypeId != null) {
                        opAccount.recordtypeid = opAccountMappingRecordTypeId;
                    }
                    toInsertOPAccounts.add(opAccount); 
                }
            }

            system.debug('*** toInsertOPAccounts ' + toInsertOPAccounts.size());
            
            // Remove OP Accounts that are duplicates, if the O/P is Active
            if(this.objPromo.EUR_CRM_Status__c == 'Active' &&
                toDeleteOPAccounts != null && toDeleteOPAccounts.size() > 0) {
                    
                Set<Id> existingOPAccountIds = new Set<Id>();
                for(EUR_CRM_ObjPromo_Account_Mapping__c opMap : toDeleteOPAccounts) {
                    existingOPAccountIds.add(opMap.EUR_CRM_Account__c);
                }
                
                toInsertOPAccounts = removeDuplicateOPAccounts(existingOPAccountIds, toInsertOPAccounts);
            }
            
            System.debug('=========== toInsertOPAccounts ' + toInsertOPAccounts.size());
            
            system.debug('@@ selectedAccounts: ' + selectedAccounts );
            System.debug(selectedAccounts.size());
            system.debug('@@ toInsertOPAccounts: ' + toInsertOPAccounts);            

            if(toInsertOPAccounts.size() < 10000) {
                System.debug(toInsertOPAccounts.size());
                insert toInsertOPAccounts;
            } else { 
              Integer MAX_BATCHES = 5;
              Integer runningBatchJobs = [select count() from AsyncApexJob where JobType = 'BatchApex'
                and status in ('Queued','Processing','Preparing') ];

                if(runningBatchJobs >= MAX_BATCHES) {
                  System.Debug('@@ ERROR Max Batches Reach!' + runningBatchJobs);
                  /*ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.WARNING, Label.EUR_CRM_No_Resources_Available
                  ));*/
                } else { 
                  System.Debug('@@ ERROR Batch publish Error!' + runningBatchJobs);
                  /*ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.INFO, Label.EUR_CRM_OP_Publish_Batch_Error
                  ));*/
                    //create the postDMLS 
                    Database.executeBatch(new EUR_CRM_BatchDML_Utility(toInsertOPAccounts, 'EUR_CRM_ObjPromo_Account_Mapping__c', EUR_CRM_BatchDML_Utility.Operation.INSERT_RECORDS,true, null));
                }
            }


            //BE Spyders OP, create target directly after account selection
            System.Debug('@@@OP Record Type' + objPromo.RecordType.DEveloperName);
            If(objPromo.RecordType.DEveloperName == 'EUR_BE_Off_Trade_Secondary_placement_Spyder_display'){
                System.Debug('@@@Auto Create OP Target');
                List<EUR_CRM_ObjPromo_Target__c> SRTargetList = New List<EUR_CRM_ObjPromo_Target__c>();
                EUR_CRM_ObjPromo_Target__c ObjectiveTarget = New EUR_CRM_ObjPromo_Target__c();

                ObjectiveTarget.recordtypeid = [SELECT id FROM RecordType where DeveloperName = 'EUR_BE_Objective_Volume_Target'].id;
                ObjectiveTarget.EUR_CRM_ObjPromo__c = objPromo.id;
                ObjectiveTarget.EUR_CRM_Target_Quantity_Spyders__c = 0;
                ObjectiveTarget.EUR_CRM_Actual_Quantity_Spyder__c = 0;

                insert ObjectiveTarget;
                System.Debug('@@@ObjectiveTarget' + ObjectiveTarget);

                id rtTargetSR = [SELECT id FROM RecordType Where DeveloperName = 'EUR_BE_SR_Volume_Target'].id;

                List<User> TargetOwnerSR = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersAccountOwnerLevel(retrievedAccount);
                For(User usr : TargetOwnerSR){
                    EUR_CRM_ObjPromo_Target__c SRTarget = New EUR_CRM_ObjPromo_Target__c();
                    SRTarget.EUR_CRM_ObjPromo__c = objPromo.id;
                    SRTarget.recordtypeid = rtTargetSR;
                    SRTarget.EUR_CRM_Target_Quantity_Spyders__c = 0;
                    SRTarget.EUR_CRM_Actual_Quantity_Spyder__c = 0;
                    SRTarget.EUR_CRM_Target_Owner__c = usr.Id;
                    SRTarget.EUR_CRM_O_P_Target__c = ObjectiveTarget.Id;
                    SRTargetList.Add(SRTarget);
                }

                insert SRTargetList;
                System.Debug('@@@SRTargetList' + SRTargetList);
            }

            /*
            Create OP Target Objective
            Retrieve SR from account selection
            Create OP ST target Objective
            */
            
            PageReference pageRef = new PageReference('/' + currentURLStr);
            pageRef.setRedirect(true);
            return pageRef;
                        
        } catch(Exception e) {
            Database.rollback(sp);
            throw e;
            system.debug('@@ ERROR : ' + e);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e) );
            return null;
        }
    }
    
    public PageReference saveAccounts() {
        quickSaveAccounts();
        return cancel();
    }
    
    // TODO: Generalize where user can jump, for more flexibility
    public PageReference quickSaveContinue() {
        quickSaveAccounts();
        PageReference pageRef = new PageReference('/' + currentURLStr + '#tabs-2');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + objPromo.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }    
    
    public class euAccountsWrapper {
        public Boolean isSelected {get;set;}
        public EUR_CRM_Account__c euAccount {get;set;}

        public euAccountsWrapper(EUR_CRM_Account__c euAccount, Boolean isSelected){
            this.euAccount = euAccount;
            this.isSelected = isSelected;
        }
    }

}