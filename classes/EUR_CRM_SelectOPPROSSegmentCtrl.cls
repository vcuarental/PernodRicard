public without sharing class EUR_CRM_SelectOPPROSSegmentCtrl {

    public EUR_CRM_ObjPromo__c objPromo {get; set;}
    public String currentURLStr {get; set;}
    public Boolean isSelectorRendered {get; set;}
    public Boolean isSelectorRerendered {get; set;}
    public Boolean initialized {get;set;}
    public Boolean initDummyVar { get { if (initDummyVar != true) initDummyVar = init(); return initDummyVar; } set; }
    public ApexPages.StandardController standardController {get; set;} 
    public String countryCode {get; set;}
    public String opAccountMappingRecordTypeName {get; set;}

    public String whereClauseString{get; set;}

    public List<String> outletImages {get;set;}
    public List<String> outletTypes {get;set;}
    public List<String> selectedOutletImages {get; set;}
    public List<String> selectedOutletTypes {get; set;}

    public List<ObjectPromWrapper> opWrapList {get;set;}

    public Id recTypeId;

    List<EUR_CRM_Account__c> euAccounts;
    Integer pSize = 20;
    @TestVisible Set<Id> selectedAccounts = new Set<Id>();
    @TestVisible Set<Id> deselectedAccounts = new Set<Id>();
    
    public Boolean sortAccount {get;set;}
    public String sortFieldName {get;set;} 
    public String oldSortFieldName  {get;set;} 
    public String sortOrder {get;set;}
    
    public Boolean isAllSelected {get; set;}
    public ApexPages.StandardSetController con {
        get {
            
            if(con == null) {          
                
                String query = 'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c,  EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
                    ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, recordTypeId, EUR_CRM_Company_Establishment__c '  + 
                    'from EUR_CRM_Account__c where eur_crm_country_code__c = \'' + countryCode + '\'';
                
                if(whereClauseString != '' && whereClauseString != null) {
                    query += ' AND ' + '(' + whereClauseString + ')';

                    con = new ApexPages.StandardSetController(Database.getQueryLocator(query));

                    this.con.setPageSize(pSize);
                    this.euAccounts = null;
                    this.selectedAccounts = new Set<Id>();
                } else {
                    con = new ApexPages.StandardSetController(new List<EUR_CRM_Account__c>());
                }

                System.debug(query);
                System.debug(con);
            }
            
            return con;
        }
        set;
    }

    public Boolean init(){
        if(objPromo.Id != null){
            recTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c' + 'EUR_' + countryCode + '_OP_PROS_Segment_Mapping');
            //recTypeId = [Select Id FROM RecordType WHERE SObjectType = 'EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c' AND DeveloperName = 'EUR_FI_OP_PROS_Segment_Mapping'].Id;

            outletImages = new List<String>();
            outletTypes = new List<String>();
            selectedOutletImages = new List<String>();
            selectedOutletTypes = new List<String>();            
            getOutletImages();
            getOutletTypes();
            createTable();
        }
        return true;
    }

    public void getOutletImages(){

        Schema.DescribeFieldResult fieldResult = EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c.EUR_CRM_Image_Level__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            outletImages.add(f.getLabel());
        }     
    }

    public void getOutletTypes(){

        Schema.DescribeFieldResult fieldResult = EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c.EUR_CRM_Group_Outlet_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            outletTypes.add(f.getLabel());
        }     
    }

    public void createTable(){

        System.debug('^^EXISTOBPR: '+objPromo.Id);

        Set<String> existingProsKey = new Set<String>();
        for(EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c existingOPPros : [SELECT Id, Name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Image_Level__c, EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c WHERE EUR_CRM_ObjPromo__c = :objPromo.Id]){
            existingProsKey.add(existingOPPros.EUR_CRM_Image_Level__c+':'+existingOPPros.EUR_CRM_Group_Outlet_Type__c);
        }

        System.debug('&&EXISTING: '+existingProsKey);

        opWrapList = new List<ObjectPromWrapper>();
        Integer opCtr = 1;
        for(String oImage : outletImages){
            for(String otype : outletTypes){
                String opWrapUnique = oImage+':'+otype;
                System.debug('&&EXISTING2: '+existingProsKey+' ----- '+opWrapUnique);
                if(existingProsKey.contains(opWrapUnique)){
                    opWrapList.add(new ObjectPromWrapper(true, opCtr, oImage, otype));
                } else{
                    opWrapList.add(new ObjectPromWrapper(false, opCtr, oImage, otype));
                }
                
                opCtr++;
            }   
        }
    }
    
    public void filter() {
        isSelectorRerendered = true;
        whereClauseString = '';

        // get a list of all selected PROS Segmentation
        for(ObjectPromWrapper opWrap: opWrapList) {
            if(opWrap.isSelected == true) {
                if(whereClauseString != ''){
                    whereClauseString += ' OR ';
                }
                whereClauseString +=  '(EUR_CRM_Image_Level_Name__c = ' + '\'' + opWrap.opOutletImage + '\''; 
                whereClauseString += ' AND EUR_CRM_Group_Outlet_Type_Name__c = ' + '\'' + opWrap.opOutletType + '\'' + ')';

                //selectedOutletImages.add(opWrap.opOutletImage);
                //selectedOutletTypes.add(opWrap.opOutletType);
            }
        }
        System.debug(whereClauseString);

        this.con = null;
        this.con.setPageNumber(1);
        this.euAccounts = null;
        this.selectedAccounts = new Set<Id>();
        this.deselectedAccounts = new Set<Id>();
        this.isAllSelected = true;

        System.debug(this.con);
        System.debug(this.con.getRecords());
    }

    public class ObjectPromWrapper{

        public Boolean isSelected {get;set;}
        public Integer indexNumber {get;set;}
        public String opOutletImage {get;set;}
        public String opOutletType {get;set;}
        public String uniquekey {get;set;}

        public ObjectPromWrapper(Boolean isSelected, Integer indexNumber, String opOutletImage, String opOutletType){

            this.isSelected = isSelected;
            this.indexNumber = indexNumber;
            this.opOutletImage = opOutletImage;
            this.opOutletType = opOutletType;
            this.uniquekey = opOutletImage+':'+opOutletType;

        }
    }

    public List<EUR_CRM_Account__c> retrieveAccounts(){
        if(euAccounts == null) {
          integer pageNumber = this.con.getPageNumber();
          this.con.first();
          
          System.debug('Re-initializing euAccounts');
          euAccounts = new List<EUR_CRM_Account__c>();          
          
          while(this.con.getHasNext()) {
              System.debug(this.con.getRecords());
              euAccounts.addAll((List<EUR_CRM_Account__c>)this.con.getRecords());
              this.con.next();
          }
          
          // Add the last page to the list of accounts
          System.debug(this.con.getRecords());
          euAccounts.addAll((List<EUR_CRM_Account__c>)this.con.getRecords());
            
          this.con.setPageNumber(pageNumber);
        }
        
        System.debug(euAccounts.size());
        return euAccounts;
    }
    
    public List<euAccountsWrapper> getWrapAccounts(){        
        List<euAccountsWrapper> wrapAccounts = new List<euAccountsWrapper>();

        for(EUR_CRM_Account__c acc : (List<EUR_CRM_Account__c>)con.getRecords()){
            if(!deselectedAccounts.contains(acc.Id))
            this.selectedAccounts.add(acc.Id);
        }

        for(sObject r : this.con.getRecords()){
            EUR_CRM_Account__c  a = (EUR_CRM_Account__c)r;
      
            euAccountsWrapper wrapAccount = new euAccountsWrapper(a,false);
            if(this.selectedAccounts.contains(a.Id)){
                  wrapAccount.IsSelected=true;
            } else {
              wrapAccount.IsSelected=false;
            }
            wrapAccounts.add(wrapAccount);                  
        }
        
        System.debug(wrapAccounts);
        return wrapAccounts;
    }
    
    public PageReference sort(){ 
        sortAccount = true;
        con = null;
        if(sortFieldName != oldSortFieldName  ){
            sortOrder = null;
            oldSortFieldName  = sortFieldName ;
        }
        sortOrder = sortOrder == null || sortOrder == 'DESC' ? 'ASC' : 'DESC';  
        return null;
    }
    
    public void doNext(){
        System.debug(this.con.getRecords());
        System.debug(this.con.getHasNext());
                
        if(this.con.getHasNext()) {
            this.con.next();
            System.debug(this.con.getRecords());
            this.isSelectorRerendered = false;
            //getWrapAccounts();
        }
        
    }

    public void doPrevious(){
        if(this.con.getHasPrevious()) {
            this.con.previous();
            getWrapAccounts();
        }
    } 
    public void first() {
        con.first();
        getWrapAccounts();
    }

    // returns the last page of records
    public void last() {
        con.last();
        getWrapAccounts();
    }
     
    public Boolean getHasPrevious(){
        return this.con.getHasPrevious();
    }

    /*
    *   return whether next page exists
    */
    public Boolean getHasNext(){
        return this.con.getHasNext();
    }
    
    public Integer getPageNumber(){
        return this.con.getPageNumber();
    }


    public Integer getTotalPages(){

        Decimal totalSize = this.con.getResultSize();
        Decimal pageSize = this.con.getPageSize();

        Decimal pages = totalSize/pageSize;

        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    public Integer getPageSize(){
        return con.getPageSize() != null ? con.getPageSize() : 0;
    }
    
    public Integer getRecordSize(){
        return con.getResultSize() != null ? con.getResultSize() : 0;
    }
    
    public String contextItem{get;set;}
    
    //Method to Select a Record
    public void doSelectItem(){
        this.selectedAccounts.add(this.contextItem);
        this.deselectedAccounts.remove(this.contextItem);    //Sid 2.1

        if(this.deselectedAccounts.size() == 0) {
            isAllSelected = true;
        }
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
        isAllSelected = false;    //Sid 2.1
    }
    
    public Boolean getHasSelectedAccounts(){
        return selectedAccounts.size() > 0;
    }
    
    //Method to Select All Record
    public void selectAll(){
        for(EUR_CRM_Account__c  a : retrieveAccounts()){
            selectedAccounts.add(a.id);
            this.deselectedAccounts.remove(a.id);    //Sid 2.1
        }
        isAllSelected = true;
    }
    
    //Method to De Select All Records
    public void deSelectAll(){

        for(EUR_CRM_Account__c  a : retrieveAccounts()){
            selectedAccounts.remove(a.id);
            this.deselectedAccounts.add(a.id);    //Sid 2.1
        }
        isAllSelected = false;
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
            List<EUR_CRM_ObjPromo_Target__c> toDeleteOPTargets = [SELECT id FROM EUR_CRM_ObjPromo_Target__c
                                                                    WHERE EUR_CRM_ObjPromo__c =:objPromo.Id
                                                                    AND EUR_CRM_O_P_Target__c != null];

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
            
            // Inserts OP Account Mapping
            List<EUR_CRM_ObjPromo_Account_Mapping__c> toInsertOPAccounts = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
            for(EUR_CRM_Account__c euAcc: retrieveAccounts()){                
                if(selectedAccounts.contains(euAcc.id) || !deselectedAccounts.contains(euAcc.id)){
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
                  ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.WARNING, Label.EUR_CRM_No_Resources_Available
                  ));
                } else { 
                  ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.INFO, Label.EUR_CRM_OP_Publish_Batch_Error
                  ));
                    //create the postDMLS 
                    Database.executeBatch(new EUR_CRM_BatchDML_Utility(toInsertOPAccounts, 'EUR_CRM_ObjPromo_Account_Mapping__c', EUR_CRM_BatchDML_Utility.Operation.INSERT_RECORDS,true, null));
                }
            }
            
            PageReference pageRef = new PageReference('/' + currentURLStr);
            pageRef.setRedirect(true);
            return pageRef;
                        
        } catch(Exception e) {
            Database.rollback(sp);
            throw e;
            system.debug('@@ ERROR : ' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e) );
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
    
    public PageReference refresh() {
        System.debug('INSIDE REFRESH');
        con = null;
        
        return null;
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