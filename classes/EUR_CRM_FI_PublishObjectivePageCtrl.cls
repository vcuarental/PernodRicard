public class EUR_CRM_FI_PublishObjectivePageCtrl{
    private final String ACTIVE = 'Active'; 
    public EUR_CRM_ObjPromo__c objPromo {get;set;} 
    public Boolean publishDisabled {get;set;}
    Set<Id> selectedAccounts = new Set<Id>();
    List<EUR_CRM_Account__c> euAccounts;
    Integer pSize = 20;
    public String sortFieldName {get;set;} 
    public String oldSortFieldName  {get;set;} 
    public String sortOrder {get;set;}
    public Boolean sortAccount {get;set;}
    public List<String> additionalFields = new List<String>{'RecordType.Developername',
            'EUR_CRM_OP_Action_List_Template__c',
            'EUR_CRM_Status__c',
            'OwnerId',
            'EUR_CRM_Account_Selection_Type__c',
            'EUR_CRM_Product_Hierarchy_Level__c',
            'EUR_CRM_O_P_Type__c' };
    public EUR_CRM_FI_PublishObjectivePageCtrl(ApexPages.StandardController stdController) { 
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
    private List<EUR_CRM_Account__c> retrieveAccounts(){
        system.debug('@@ retrieveAccounts');
        if(euAccounts == null || sortAccount){
            system.debug('@@ sorting:');
            euAccounts = EUR_CRM_FI_UtilClass.retrieveOPAccounts(objPromo,null, sortFieldName , sortOrder);
            if(objPromo.EUR_CRM_Status__c == 'Draft'){
                for(EUR_CRM_Account__c eu : euAccounts){
                    if(sortAccount == null || !sortAccount)
                        selectedAccounts.add(eu.id);
                }
            }
            sortAccount = false;
        }
        return euAccounts;
    }
    public PageReference publish(){        
        Savepoint sp = Database.setSavepoint();
        system.debug('@@ publish: ' );
        try{  
            RecordType opamrt = [select id from recordtype where sobjecttype='EUR_CRM_ObjPromo_Account_Mapping__c' and developername='EUR_FI_O_P_Account_Mapping'];
          
            List<EUR_CRM_ObjPromo_Account_Mapping__c> toDeleteOPAccounts = [select id from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c =:objPromo.id];
            
            if(toDeleteOPAccounts!= null && toDeleteOPAccounts.size() > 0){
                 delete toDeleteOPAccounts;
             }
             
            List<EUR_CRM_ObjPromo_Account_Mapping__c> toInsertOPAccounts = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
             
           // euAccounts = retrieveEuAccountsWrapperList();
            
            for(EUR_CRM_Account__c euAcc: retrieveAccounts()){                
                if(selectedAccounts.contains(euAcc.id)){
                    EUR_CRM_ObjPromo_Account_Mapping__c opAccount = new EUR_CRM_ObjPromo_Account_Mapping__c(EUR_CRM_Account__c = euAcc.Id,EUR_CRM_ObjPromo__c = objPromo.id, EUR_CRM_Is_Active__c = true);
                    
                    if(opamrt!=null)
                        opAccount.recordtypeid = opamrt.id;
                    toInsertOPAccounts.add(opAccount); 
                }
            } 
            system.debug('@@ selectedAccounts: ' + selectedAccounts );
            system.debug('@@ toInsertOPAccounts: ' + toInsertOPAccounts);
            if(toInsertOPAccounts.size() < 10000)
                insert toInsertOPAccounts;
            else{ 
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
                  return null;
            }
            
            EUR_CRM_ObjPromo__c obj = new EUR_CRM_ObjPromo__c(id =objPromo.id,EUR_CRM_Status__c = ACTIVE ); 
            update obj; 
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
               con = new ApexPages.StandardSetController(retrieveAccounts());               
               con.setPageSize(pSize);
            }
            return con;
        }
        set; 
    }   
    public List<euAccountsWrapper> getWrapAccounts(){

        List<euAccountsWrapper> rows = new List<euAccountsWrapper>();

        for(sObject r : this.con.getRecords()){
            EUR_CRM_Account__c  a = (EUR_CRM_Account__c)r;

            euAccountsWrapper row = new euAccountsWrapper(a,false);
            if(this.selectedAccounts.contains(a.Id)){
                row.IsSelected=true;
            }
            else{
                row.IsSelected=false;
            }
            rows.add(row);
        }

        return rows;

    }
    public void doNext(){

        if(this.con.getHasNext())
            this.con.next();

    }

    public void doPrevious(){

        if(this.con.getHasPrevious())
            this.con.previous();

    } 
    public void first() {
         con.first();
     }

     // returns the last page of records
     public void last() {
         con.last();
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
    public void doSelectItem(){
    
        this.selectedAccounts.add(this.contextItem);
    
    }
    
    public void doDeselectItem(){
    
        this.selectedAccounts.remove(this.contextItem);
    
    }
    
    public Boolean getHasSelectedAccounts(){
        return selectedAccounts.size() > 0;
    }
    
    public void selectAll(){
        system.debug('## selectAll' + selectedAccounts);
        for(EUR_CRM_Account__c  a : retrieveAccounts()){
            selectedAccounts.add(a.id); 
        }
        system.debug('## selectAll2' + selectedAccounts);
    }
    public void deSelectAll(){
        for(EUR_CRM_Account__c  a : retrieveAccounts()){
            selectedAccounts.remove(a.id);  
        }
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
        List<User> salesReps = EUR_CRM_FI_UtilClass.retrieveOwners(retrieveAccounts());
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
       /*
       //commitment
       //missing objective

       if(objectiveCommitmentTarget.size() == 0 || objectiveCommitmentTarget.get(0).EUR_CRM_Visit_Targets__c == null || objectiveCommitmentTarget.get(0).EUR_CRM_Visit_Targets__c == 0){
            m = Label.EUR_CRM_Missing_Objective_Commitment_Target ; //'Missing Objective Commitment Target'; EUR_CRM_Missing_Objective_Commitment_Target
            errorMessages.add(m);
       //missing sales rep
       }else {
            for(User u: salesReps){
                EUR_CRM_ObjPromo_Target__c temp = uSRCommitmentTargetMap.get(u.id);
                if(temp == null || temp.EUR_CRM_Visit_Targets__c == null || temp.EUR_CRM_Visit_Targets__c == 0 ){
                    m = Label.EUR_CRM_Missing_Commitment_Target_for_user +': '+ u.name;// EUR_CRM_Missing_Commitment_Target_for_user
                    errorMessages.add(m);
                }
            }
       }

       */

       
       //missing procut 
       if(objectiveVolumeTargets.size() == 0 && objectiveProductTargets.size() == 0){
            m = Label.EUR_CRM_Missing_Products; //'Missing Products';
            errorMessages.add(m);
        return ;           
       }
        /*
       else if(objPromo.EUR_CRM_O_P_Type__c == 'Type 2'){
            products.remove(null);
            Map<Id,sobject> prodMap = new Map<id, sobject>();
            List<ProductUser> combo = new List<ProductUser>();
            for(Sobject o : retrieveProducts(prodApi, products)){
                prodMap.put(o.id,o);
                for(User u: salesReps)
                    combo.add(new ProductUser(u,o));
            }
           for(EUR_CRM_ObjPromo_Target__c  target : objectiveVolumeTargets){
                if(target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c   == null || target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c   == 0){
                    Id i = (id)target.get(opApi);
                    SObJect prod = prodMap.get(i);
                    m = Label.EUR_CRM_Missing_target_quantity_for_product +': '; //Missing target quantity for product: ';
                    m += prod!=null ? (String) prod.get('name') : '';
                    errorMessages.add(m);
                }           
           }
           
           for(ProductUser c: combo){
               String key = ''+ c.product.id + c.targetOwner.id;
               EUR_CRM_ObjPromo_Target__c t = existingCombo.get(key);
               if(t == null || t.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null ||  t.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == 0){
                    m = Label.EUR_CRM_Missing_target_quantity_for_product +': ';
                    m += c.product!=null ? (String) c.product.get('name') : '';
                    m += ', ' + Label.EUR_CRM_for_Sales_Representative +': ';
                    m += c.targetOwner !=null ? (String) c.targetOwner.get('name') : '';
                    errorMessages.add(m);
               }
           }
        }
        */
       //volume if type 2 
    }

    /*

    public class ProductUser{
        public User targetOwner {get;set;}
        public sObject product  {get;set;}
        public ProductUser(User targetOwner, sObject product)  {
            this.targetOwner = targetOwner;
            this.product = product;
        } 
    }

    public List<sObject> retrieveProducts(String apiname, Set<Id> prodIds){
        String q = 'select id, name from ';
        q += ' ' +apiname;
        q += ' where id in: prodIds';
        system.debug(q);
        return Database.query(q);
    }
    */
}