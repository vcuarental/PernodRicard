/*
*    Description : Apex controller class for ZA OP Publish Accounts
*
*    Version            Date                Author            Description
*    1.0                08/27/2015          Kim               Initial Draft
*    2.0                12/14/2015          Sid               Code Optimization
*                                                             1) Code refactoring for Account Filtering 
*    2.1                12/15/2015          Sid               Code changes to resolve filter issue
*
*    2.2                12/16/2015          Sid               Code development to carry out the validation
*                                                             that only permissible Accounts are considered
*                                                             for OP Account Mapping Creation
*
*   2.3                 03/14/2017          Kevin Choi        Status changed to 'Published' if it hasn't reach 
*                                                             active start day; if selected account is incative, error msg
*                                                             will shown on the page 'Some accounts are inactive'                 
*/

public class EUR_CRM_ZA_PublishObjectivePageCtrl{
	
	private static final String STR_OP_ONTRADE_RECTYPE = 'EUR_ZA_On_Trade_Promotion';    //Sid 2.2
	private static final String STR_OP_OFFTRADE_RECTYPE = 'EUR_ZA_Off_Trade_Promotion';    //Sid 2.2
	
	//True - All Selcted Accounts can be entered
	//False - All Selected Accounts cannot be entered
	public Boolean blnIsPermissible {get; set;}    //Sid 2.2
	
	List<EUR_CRM_Account__c> permissibleAccList = new List<EUR_CRM_Account__c>();    //Sid 2.2
	
    private final String ACTIVE = 'Active';
    private final String PUBLISH = 'Published'; 
    public EUR_CRM_ObjPromo__c objPromo {get;set;} 
    public Boolean publishDisabled {get;set;}
    public Boolean refreshCSVContent {get;set;}

    /*
    public Set<Id> selectedAccounts {get{
        if(selectedAccounts == null) {
            selectedAccounts = new Set<Id>();
        }
        return selectedAccounts;
    }set;}*/
    
    //public Set<Id> deselectedAccounts {get; set;}    //Sid 2.1
    @TestVisible Set<Id> selectedAccounts = new Set<Id>();
    @TestVisible Set<Id> deselectedAccounts = new Set<Id>();
   
    transient List<EUR_CRM_Account__c> euAccounts;
    Integer pSize = 20;
    public String sortFieldName {get;set;} 
    public String oldSortFieldName  {get;set;} 
    public String sortOrder {get;set;}
    public Boolean sortAccount {get;set;}
    public Boolean isAllSelected {get; set;}
    public List<String> additionalFields = new List<String>{'RecordType.Developername',
            'EUR_CRM_OP_Action_List_Template__c',
            'EUR_CRM_Status__c',
            'OwnerId',
            'EUR_CRM_Account_Selection_Type__c',
            'EUR_CRM_Product_Hierarchy_Level__c',
            'EUR_CRM_O_P_Type__c' };
    public EUR_CRM_ZA_PublishObjectivePageCtrl(ApexPages.StandardController stdController) { 
    	
    	deselectedAccounts = new Set<Id>();    //Sid 2.1
    	
    	//Sid 2.2
    	blnIsPermissible = true;
    	refreshCSVContent = true;
        publishDisabled = false;
        if(!Test.isRunningTest()){
            stdController.addFields(additionalFields);
        }
     
        this.objPromo= (EUR_CRM_ObjPromo__c)stdController.getRecord();
        
        sortFieldName = 'Name';
        oldSortFieldName  = 'Name';
        sortOrder = 'ASC';
        for(EUR_CRM_ObjPromo_Account_Mapping__c op :[select id, eur_crm_account__c from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c =:objPromo.id]){
            selectedAccounts.add(op.eur_crm_account__c);
        }
        verifyMissingTargets();
        if(errorMessages != null && errorMessages.size() > 0){
            publishDisabled = true;
            for(String s : errorMessages)
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, s));
        }
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
    public List<EUR_CRM_Account__c> retrieveAccounts(){
        if(euAccounts == null) {
            System.debug('Re-initializing euAccounts');
            euAccounts = new List<EUR_CRM_Account__c>();
        
          integer pageNumber = this.con.getPageNumber();
          this.con.first();
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
        return euAccounts;
    }
    
    public PageReference publish(){        
        Savepoint sp = Database.setSavepoint();
        
        // retrieve the isQuickSave parameter
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('isQuickSave');
        System.debug('Flag - Save Payment - isQuickSave:' + isQuickSaveStr);
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);
        
        system.debug('@@ publish: ' );
        try{  
            RecordType opamrt = [select id from recordtype where sobjecttype='EUR_CRM_ObjPromo_Account_Mapping__c' and developername='EUR_ZA_OP_Account_Mapping'];
                      
            List<EUR_CRM_ObjPromo_Account_Mapping__c> toDeleteOPAccounts = [select id from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c =:objPromo.id];
            
            if(toDeleteOPAccounts!= null && toDeleteOPAccounts.size() > 0){
                delete toDeleteOPAccounts;
            }
             
            List<EUR_CRM_ObjPromo_Account_Mapping__c> toInsertOPAccounts = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
             
           // euAccounts = retrieveEuAccountsWrapperList();
           //System.debug(retrieveAccounts());    //2.2
           //Sid 2.2
           /*
            for(EUR_CRM_Account__c euAcc: retrieveAccounts()){                
                if(selectedAccounts.contains(euAcc.id)){
                    EUR_CRM_ObjPromo_Account_Mapping__c opAccount = new EUR_CRM_ObjPromo_Account_Mapping__c(EUR_CRM_Account__c = euAcc.Id,EUR_CRM_ObjPromo__c = objPromo.id, EUR_CRM_Is_Active__c = true, EUR_CRM_Is_Published__c = !isQuickSave);
                    
                    if(opamrt!=null)
                        opAccount.recordtypeid = opamrt.id;
                    toInsertOPAccounts.add(opAccount); 
                }
            }*/
            
            System.debug('=========== permissibleAccList ' + permissibleAccList);
            EUR_CRM_ObjPromo__c objec = [Select id,EUR_CRM_Active_Start_Date__c from EUR_CRM_ObjPromo__c where id =:objPromo.id];
            Date objStartDate = objec.EUR_CRM_Active_Start_Date__c;
            //Sid 2.2
            if(!permissibleAccList.isEmpty()){
                for(EUR_CRM_Account__c acc : permissibleAccList){
                    if(acc.EUR_CRM_Status__c != 'Active'){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.EUR_CRM_InactiveAccountSelected));
                        return null;
                    }    
                    EUR_CRM_ObjPromo_Account_Mapping__c opAccount = new EUR_CRM_ObjPromo_Account_Mapping__c(EUR_CRM_Account__c = acc.Id,
                                                                                                            EUR_CRM_ObjPromo__c = objPromo.id,
                                                                                                            EUR_CRM_Is_Published__c = !isQuickSave);
                        if (objStartDate > date.today()){
                            opAccount.EUR_CRM_Is_Active__c = false;
                        } else{
                            opAccount.EUR_CRM_Is_Active__c = true;
                        }

                        if(opamrt!=null)
                            opAccount.recordtypeid = opamrt.id;
                            toInsertOPAccounts.add(opAccount);                             
                }
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
                    
                  publishDisabled = true;
                }
            }
            
            if(!isQuickSave) {
            //Date startDate = Date.valueOf(ApexPages.currentPage().getParameters().get('Active Start Date'));
            //EUR_CRM_ObjPromo__c objec = [Select id,EUR_CRM_Active_Start_Date__c from EUR_CRM_ObjPromo__c where id =:objPromo.id];
            //Date objStartDate = objec.EUR_CRM_Active_Start_Date__c;
 
            EUR_CRM_ObjPromo__c obj = new EUR_CRM_ObjPromo__c(id =objPromo.id);
            if (objStartDate > date.today()){
                obj.EUR_CRM_Status__c = PUBLISH;
            } else{
                obj.EUR_CRM_Status__c = ACTIVE;
            }
              update obj;
            } else {
              return null;
            }
        }catch(Exception e){
            Database.rollback(sp);
            system.debug('@@ ERROR : ' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e) );
            return null;
        }
        
        return cancel();
    }
    
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                //con = new ApexPages.StandardSetController(retrieveAccounts());

                //Sid 2.0                
                List<EUR_CRM_Account__c> accList = new List<EUR_CRM_Account__c>();
                if(String.isBlank(filterId)){
                    con = new ApexPages.StandardSetController(accList);
                }
                else{
                    con = new ApexPages.StandardSetController(Database.getQueryLocator(
                        'select name, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,EUR_CRM_Outlet_Type__r.EUR_CRM_name__c,EUR_CRM_Status__c,  EUR_CRM_City__c ,EUR_CRM_Image_Level_Name__c ,EUR_CRM_Group_Outlet_Type_Name__c ' +
                        ', EUR_CRM_No_of_Active_Contracts__c, ownerid, owner.name, recordTypeId, EUR_CRM_Company_Establishment__c '  + 
                        'from EUR_CRM_Account__C where eur_crm_country_code__c = \'ZA\' LIMIT 1'
                    ));                
                }
                
                //this.con.setPageSize(pSize);
                
                if(filterId != null) {
                
                    this.con.setPageSize(pSize);
                    con.setFilterId(filterId);
                    //this.wrapAccounts = null;
                    this.euAccounts = null;
                    this.selectedAccounts = new Set<Id>();
                }
            }
            
            return con;
        }
        set;
    }
    public String filterId {get; set;}
    
    public SelectOption[] getListViewOptions() {
        
        List<SelectOption> selOpList = new List<SelectOption>();
        selOpList.add(new SelectOption('', '--None--'));
        selOpList.addAll(con.getListViewOptions());
        //return con.getListViewOptions();
        return selOpList;
    }

    public PageReference resetFilter() {
        System.debug('Changing filter to ' + filterId);
        this.con = null;
        this.con.setPageNumber(1);
        this.con.setFilterId(filterId);
        this.euAccounts = null;
        //this.wrapAccounts = null;
        this.selectedAccounts = new Set<Id>();
        
        this.deselectedAccounts = new Set<Id>();    //Sid 2.1
        
        this.isAllSelected = false;
        
        this.selectAll();    //Sid 2.2
        System.debug('========================= this.selectedAccounts ' + this.selectedAccounts.size());
        blnIsPermissible = true;    //Sid 2.2
        //refreshCSVContent = false;
        
        return null;
    }
    
    public List<euAccountsWrapper> getWrapAccounts(){
        //if(wrapAccounts == null) {
          List<euAccountsWrapper> wrapAccounts = new List<euAccountsWrapper>();

            //Sid 2.1
            for(EUR_CRM_Account__c acc : (List<EUR_CRM_Account__c>)con.getRecords()){
            	if(!deselectedAccounts.contains(acc.Id))
                this.selectedAccounts.add(acc.Id);
            }

          for(sObject r : this.con.getRecords()){
              EUR_CRM_Account__c  a = (EUR_CRM_Account__c)r;
              
                  euAccountsWrapper wrapAccount = new euAccountsWrapper(a,false);
                  if(this.selectedAccounts.contains(a.Id)){
                      wrapAccount.IsSelected=true;
                  }
                  else{
                      wrapAccount.IsSelected=false;
                  }
                  wrapAccounts.add(wrapAccount);                  
          }
        //}
        
        System.debug(wrapAccounts);
        return wrapAccounts;
    }
    
    public void doNext(){
        if(this.con.getHasNext()) {
            this.con.next();
            getWrapAccounts();
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
    }// returns the page number of the current page set
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
        system.debug(selectedAccounts);
        this.deselectedAccounts.remove(this.contextItem);    //Sid 2.1
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
        system.debug(deselectedAccounts);
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

    public PageReference changeTabRefresh(){
        if (refreshCSVContent == true){
                refreshCSVContent = false;
            }else{
                refreshCSVContent = true;    
            }
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
    public PageReference cancel(){
        PageReference pr = new PageReference('/' + objPromo.id);
        pr.setRedirect(true);
        return pr;
    }
    public List<String> errorMessages {get;set;}
    void verifyMissingTargets(){
        errorMessages  = new List<String>(); 
        Set<Id> products = new Set<Id>();
          List<EUR_CRM_ObjPromo_Target__c> objectiveVolumeTargets = new List<EUR_CRM_ObjPromo_Target__c>();
          List<EUR_CRM_ObjPromo_Target__c> objectiveProductTargets = new List<EUR_CRM_ObjPromo_Target__c>();
          List<EUR_CRM_ObjPromo_Target__c> srVolumeTargets = new List<EUR_CRM_ObjPromo_Target__c>();
          List<EUR_CRM_ObjPromo_Target__c> objectiveCommitmentTarget= new List<EUR_CRM_ObjPromo_Target__c>();
          List<EUR_CRM_ObjPromo_Target__c> srCommitmentTargets= new List<EUR_CRM_ObjPromo_Target__c>();
        List<User> salesReps = EUR_CRM_ZA_UtilClass.retrieveOwners(retrieveAccounts());
        Map<Id,EUR_CRM_ObjPromo_Target__c> uSRCommitmentTargetMap = new Map<Id,EUR_CRM_ObjPromo_Target__c>();
        String h = objPromo.eur_crm_product_hierarchy_Level__c;
        String prodApi = '';
        String opApi= '';
        prodApi =  h == 'BQ'? 'EUR_CRM_Quality__c' : prodApi;
        prodApi =  h == 'BQS'? 'EUR_CRM_Size__c' : prodApi;
        prodApi =  h == 'SKU'? 'EUR_CRM_SKU__c' : prodApi; 
        opApi=  h == 'BQ'? 'EUR_CRM_BQ__c' : opApi;
        opApi=  h == 'BQS'? 'EUR_CRM_BQS__c' : opApi;
        opApi=  h == 'SKU'? 'EUR_CRM_SKU__c' : opApi; 
        Map<String,EUR_CRM_ObjPromo_Target__c > existingCombo = new Map<String,EUR_CRM_ObjPromo_Target__c >();
        for(EUR_CRM_ObjPromo_Target__c target : [select id,
                                                    EUR_CRM_BQS__c,
                                                    EUR_CRM_BQS__r.name,
                                                    EUR_CRM_BQ__c,
                                                    EUR_CRM_BQ__r.name,
                                                    EUR_CRM_SKU__c,
                                                    recordtype.developername,
                                                    EUR_CRM_Visit_Targets__c,
                                                    EUR_CRM_Is_Quota__c,
                                                    EUR_CRM_Target_Owner__c ,
                                                    EUR_CRM_Unit_of_Measure__c,
                                                    EUR_CRM_Grouping_Type__c,
                                                    EUR_CRM_SKU__r.name,EUR_CRM_Qty_Sell_in_Amount_Bottle__c   from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromo.Id
                                                    ] ){ 
             if(target.recordtype.developername == 'EUR_CRM_Objective_Volume_Target'){
                objectiveVolumeTargets.add(target);
                products.add(target.EUR_CRM_BQS__c);
                products.add(target.EUR_CRM_BQ__c);
                products.add(target.EUR_CRM_SKU__c);
            }if(target.recordtype.developername == 'EUR_CRM_Objective_Product'){
                objectiveProductTargets.add(target);
                products.add(target.EUR_CRM_BQS__c);
                products.add(target.EUR_CRM_BQ__c);
                products.add(target.EUR_CRM_SKU__c);
            }
             if(target.recordtype.developername == 'EUR_CRM_Objective_Commitment_Target'){
                objectiveCommitmentTarget.add(target);
            }
             if(target.recordtype.developername == 'EUR_CRM_SR_Commitment_Target'){
                srCommitmentTargets.add(target);
                uSRCommitmentTargetMap.put(target.EUR_CRM_Target_Owner__c,target );
            }
             if(target.recordtype.developername == 'EUR_CRM_SR_Volume_Target'){
                srVolumeTargets.add(target);
                existingCombo.put(''+ ((String) target.get(opApi)) +'' + target.EUR_CRM_Target_Owner__c, target);
            }
        }
        String m ='';
       
       //missing product 
       if(objectiveVolumeTargets.size() == 0 && objectiveProductTargets.size() == 0){
            m = Label.EUR_CRM_Missing_Products; //'Missing Products';
            errorMessages.add(m);
        return ;           
       }

       //volume if type 2 
    }
    
    //Sid 2.2    
    //Validate Selected Accounts against permissible record types
    public void validateAccounts(){

        //Permissible Record Types
        List<String> permissibleRecTypes = new List<String>();    

        Map<Id, RecordType> objPromoRecType = new Map<Id, RecordType>([select Id,
                                                                              DeveloperName 
                                                                       from RecordType 
                                                                       where DeveloperName =: STR_OP_ONTRADE_RECTYPE OR
                                                                             DeveloperName =: STR_OP_OFFTRADE_RECTYPE]);
        
        //On Trade Objective and Promotion
        if(objPromoRecType.get(objPromo.RecordTypeId).DeveloperName.equalsIgnoreCase(STR_OP_ONTRADE_RECTYPE)){
            permissibleRecTypes = new List<String> {'EUR_ZA_On_Trade_Direct', 
            	                                    'EUR_ZA_On_Trade_Indirect', 
            	                                    'EUR_ZA_On_Trade_Informal'};
        }
        
        //Off Trade Objective and Promotion
        if(objPromoRecType.get(objPromo.RecordTypeId).DeveloperName.equalsIgnoreCase(STR_OP_OFFTRADE_RECTYPE)){
            permissibleRecTypes = new List<String> {'EUR_ZA_Off_Trade'};
        }        
    
        //Selected Accounts
        System.debug('=================== Selected Accounts ' + selectedAccounts.size());
        List<EUR_CRM_Account__c> selectedAccountList = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> inactiveAccountList = new List<EUR_CRM_Account__c>();
        
        selectedAccountList = [select Id, EUR_CRM_Status__c,  
                                      recordTypeId 
                               from EUR_CRM_Account__c 
                               where Id IN: selectedAccounts];

        System.debug('============== selectedAccountList ' + selectedAccountList.size());

        EUR_CRM_ZA_AccountValidator oEUR_CRM_ZA_AccountValidator = new EUR_CRM_ZA_AccountValidator();
        permissibleAccList = oEUR_CRM_ZA_AccountValidator.getValidatedAccountList(selectedAccountList, permissibleRecTypes);
        
        System.debug('============ permissibleAccList ' + permissibleAccList.size());
        //If deviation happens in Selected Account records and Permissible Account records
        if(permissibleAccList.size() != selectedAccountList.size()){
            blnIsPermissible = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.EUR_CRM_OP_Publish_Validation)); 
        }
        //If all the selected account records are qualified for OP Account Mapping
        if(permissibleAccList.size() == selectedAccountList.size()){
            blnIsPermissible = true;
        }
    }
}