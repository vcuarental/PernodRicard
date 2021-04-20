public with sharing class LAT_MX_Edit_AccountMobileController {

    //Account to be edited/created/cloned
    public Account acc {get;set;}
    public Account accTBCloned {get;set;}
    public Boolean isOffTrade {get;set;}
    public LAT_Account__C latAcc {get;set;}

    //URL PARAMETERS
    public String accIdURL {get;set;}
    public static String accRecordTypeId {get;set;}
    public String segIdURL {get;set;}
    public String credIdURL {get;set;}
    public Boolean rtSelection {get;set;}
    public String credIdParam {get;set;}


    //Clone
    public String cloneAcc {get;set;}
    public Boolean isClone {get;set;}

    //Segmentation, ClientWorkHours, Credit Analysus - Related Lists
    
    public List<LAT_BR_ClientChannelSegmentation__c> listSegmentation {get;set;}
    public LAT_BR_ClientChannelSegmentation__c segmentation {get;set;}
    public Boolean isNewSegmentation {get;set;}
    public Boolean isEditSegmentation {get;set;}
    public Boolean isNewCreditAnal {get;set;}
    public Boolean isEditCreditAnal {get;set;}
    public CRA_CredAnalysis_ARG__c creditAnal {get;set;}
    public List<CRA_CredAnalysis_ARG__c> listCreditAnal {get;set;}
    

    //Dinamyc variables - Left Sections
    public Map<String,List<FieldSetMember>> mapFieldSetWithFields {get;set;}
    public Map<String,String> mapCustomFieldPathWithFields {get;set;}
    public Map<String,List<FieldSetMember>> latMapFieldSetWithFields {get;set;}
    public Map<String, Boolean> fieldsReadOnly {get;set;}
    public Map<String,String> lookupRefNames {get;set;}


    public String sessionUserId;
    public String urlFrontDoorWithSId {get;set;}
    

    //Final Static Var
    public final static String URL_EDIT_PAGE_ACCMOB = '/apex/LAT_BR_Edit_AccountMobile';

    //RFC's Variables

    public List<SelectableRFC> listaRFCActuales {get; set;}
    public List<LAT_MX_RFC__c>  listaDeRFCNuevos {get; set;}
    public List<LAT_MX_RFC__c>  listaDeRFCViejos {get; set;}
    public String           parentID{get; set;}
    public String           rfcSelec{get; set;}
    public String           rsSelec{get; set;}
    public String toDeleteId {get;set;}

    public LAT_MX_Edit_AccountMobileController(ApexPages.StandardController controller) {

            //Get URL Paremeteres
            accIdURL =  ApexPages.currentPage().getParameters().get('id');
            cloneAcc =  ApexPages.currentPage().getParameters().get('clone');
            credIdURL = ApexPages.currentPage().getParameters().get('cred');

            //init Variables
            init();
    }


  

    public void init(){

            rtSelection = true;
            isNewCreditAnal = false;
            isEditCreditAnal = false;
            creditAnal = new CRA_CredAnalysis_ARG__c();
            listCreditAnal = new List<CRA_CredAnalysis_ARG__c>();

            if(accIdURL != null && accIdURL != ''){
                String recId = [Select RecordTypeId From Account Where Id = :accIdURL limit 1].RecordTypeId;
                isOffTrade = Global_RecordTypeCache.getRt(recId).DeveloperName == 'LAT_MX_ACC_OffTrade' ? true : false ;
            }else{
                isOffTrade = false;
            }

            //Load Account maps with fields sets
            createMapFieldSetWithFields();
            //Clone = 1
            isclone = cloneAcc != null ? true : false;

            //Edit Account Or Create Account 
            if(accIdURL != null && accIdURL != ''){

                //Account (cliente) fields, Cloned Account
                rtSelection = false;
                acc = getAllfields(accIdURL);
                acc.LAT_Account__c = latAcc.Id;

                //latAcc = new LAT_Account__c();
               
                
                accRecordTypeId = acc.RecordTypeId;
                isOffTrade = Global_RecordTypeCache.getRt(accRecordTypeId).DeveloperName == 'LAT_MX_ACC_OffTrade' ? true : false ;

                if(isClone){ 
                    acc.ParentId = accIdURL;
                }

                //Analises de credito
                listCreditAnal = getRecordsBasedOnObject('CRA_CredAnalysis_ARG__c','Account_ARG__c');

            }else{
              
                acc = new Account();
                latAcc = new LAT_Account__C();
                //acc.LAT_Account__r = latAcc;

            }

           
            
            //Creation/Editon of Credit Analisys
            isNewCreditAnal = credIdURL != null && credIdURL == 'new' ? true : false;
            isEditCreditAnal = credIdURL != null &&  credIdURL == 'edit' ? true : false;                              

            if(isEditCreditAnal){
                String credIdParam = ApexPages.currentPage().getParameters().get('credId');
                if(!listCreditAnal.isEmpty()){
                    for(CRA_CredAnalysis_ARG__c cred : listCreditAnal ) {
                        if(cred.Id == credIdParam ) {
                            creditAnal = cred;
                            break;
                        }
                    }
                }
            }



    }

    public List<sObject> getRecordsBasedOnObject(String sObjectName,String relationshipName){
        
        //Build map with Lookup Field and Its Parent Name
        Map<String,String> parentLookupsName = new Map<String,String>();

        for(Schema.SobjectField strFld : Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().Values()){

            if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE){

                parentLookupsName.put(strFld.getDescribe().getName() ,  strFld.getDescribe().getRelationshipName()  );

            }
        }

        String query = '';

        if(sObjectName != null){

           query = 'Select ';

           for(Schema.sobjectfield field : Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().values()){

              Schema.DescribeFieldResult fieldResult = field.getDescribe(); 

              query += fieldResult.getName() + ',';

              if(fieldResult.getType() == Schema.DisplayType.REFERENCE){

                query+= parentLookupsName.get(fieldResult.getName()) +'.Name,';

                lookupRefNames.put(fieldResult.getName(), parentLookupsName.get(fieldResult.getName())+'.Name');

              }
           }

           query = query.substring(0,query.length()-1);

           query += ' From ' + sObjectName + ' Where ' + relationshipName +' = \''+this.acc.Id +'\'';
        }
           system.debug('aaaaaa ' + query);

        return database.query(query);
    }

    /**
    * @descp: Get standard/custom fields from Field Set divided by Section similar to the Off Trade/On Trade Page Layouts
    *
    **/

    public void createMapFieldSetWithFields(){

            mapFieldSetWithFields = new Map<String,List<FieldSetMember>>();
            mapCustomFieldPathWithFields = new Map<String,String>();

            List<Schema.FieldSet> listFieldSetsMobile = getAccountMobileFieldSetNames();


            for(Schema.FieldSet fs : listFieldSetsMobile){
                if(fs != null){

                    if(mapFieldSetWithFields.get(fs.Name) != null){

                        mapFieldSetWithFields.get(fs.Name).addAll(fs.getFields());
                        List<String> lst = new List<String>();
                        for (FieldSetMember f : fs.getFields()) {
                            String path = f.FieldPath;
                            if (f.fieldPath.contains('__r.')) {
                                path = f.fieldPath.replace('__r.','__r-');
                            }
                            mapCustomFieldPathWithFields.put(f.FieldPath, path);
                        }
                        

                    }else{

                        mapFieldSetWithFields.put(fs.Name, new List<FieldSetMember>());
                        mapFieldSetWithFields.get(fs.Name).addAll(fs.getFields());

                        List<String> lst = new List<String>();
                        for (FieldSetMember f : fs.getFields()) {
                            String path = f.FieldPath;
                            if (f.fieldPath.contains('__r.')) {
                                path = f.fieldPath.replace('__r.','__r-');
                            }
                            mapCustomFieldPathWithFields.put(f.FieldPath, path);
                        }
                        
                    }
                }
            }
    }


    /**
    * @company: Zimmic LLC
    * @dev: Mauricio Diaz
    * @descp: Method to Read a value from a custom setting  where it has Field Look Up filters. This will filter records returned by UDC__c lookups (mostly)
    * @notes: Brasil = 0, Arg UY = 1, Mx = 2 - Depending of the Lookup filter field from Account. 
      Fields to be avoided: Record Type Id and Parent Id 
    */

    

    @RemoteAction
    public static lookupDefinition getLookupFieldInformation(String sFieldName,String rtId, String accId){

        String objectName = getLookupsType(sFieldName);
        List<sObject> listsObjects = new List<sObject>();
        List<String> listColumns = new List<String>();

        //This will get all Custom Setting values with Lookup Filters
        Map<String, LAT_Mobile_Lookup_Filter__c > filters = LAT_Mobile_Lookup_Filter__c.getAll();
        if(filters != null && sFieldName != 'RecordTypeId'){
            if (sFieldName.contains('LAT_Account__r')) {
                sFieldName = sFieldName.remove('LAT_Account__r.');
            }

            LAT_Mobile_Lookup_Filter__c filter = filters.get(sFieldName);

            if( filter.LAT_Columns__c != null ){

                String[] columns = filter.LAT_Columns__c.split(',');

                String whereFilters = filter.LAT_Filter_Value__c;

                String queryResult = 'Select Id, '+filter.LAT_Columns__c+' FROM '+ objectName  ;

                if( whereFilters != null) {

                      queryResult+= ' Where ';   
                      whereFilters = whereFilters.replace('{!rt}', 'RecordType.DeveloperName');
                      whereFilters = whereFilters.replace('{!AcconId}', '\''+accId+'\'');
                      String[] filtersSplit = whereFilters.split(',');
                       //For Brasil Cases get the first Logic separeted by comma 
                       //If this page is used for AR, UY MX you should check in what place of the CS related is the logic for the given country
                       //*** CHECK OFF TRADE ACCESS FOR VENDOR
                       //if(Schema.SObjectType.Account.getRecordTypeInfosByName().get('On Trade').getRecordTypeId() == rtId 
                       //|| Schema.SObjectType.Account.getRecordTypeInfosByName().get('Off Trade').getRecordTypeId() == rtId ){
                           queryResult += filtersSplit[0];
                      //}
                }

               listsObjects = database.query(queryResult);
               listColumns = filter.LAT_Columns__c.split(',',0);
            }

        }
        
        return new lookupDefinition(listsObjects,listColumns, getColumnsLables(listColumns, objectName));       
    }

    public static LIST<String> getColumnsLables(List<String> tColumns, String objectName){
        List<String> retList = new List<String>();

        DescribeSObjectResult result = Schema.getGlobalDescribe().get(objectName).getDescribe();

        for(String col : tColumns){
            retList.add(result.fields.getMap().get(col).getDescribe().getLabel());
        }

        return retList;
    }

    public static String getLookupsType(String apiName){
        String objectToQuery = '';
        if (!apiName.contains('LAT_Account__r')) {
            Map<String, Schema.SObjectField> objectFields = Schema.sObjectType.Account.fields.getMap();
            System.debug('%%%%%%%% apiName : '+ apiName);
            Schema.DescribeFieldResult f = objectFields.get(apiName).getDescribe();
            //// describe of your lookup field
            
            for(Schema.SObjectType reference : f.getReferenceTo()) {
                objectToQuery = reference.getDescribe().getName();
            }
            System.debug('%%%%%%%% objectToQuery : '+objectToQuery );
        } else {
            Map<String, Schema.SObjectField> objectFields = Schema.sObjectType.LAT_Account__c.fields.getMap();
            apiname = apiName.remove('LAT_Account__r.');
           
            System.debug('%%%%%%%% LAT_apiName : '+ apiName);
            Schema.DescribeFieldResult f = objectFields.get(apiName).getDescribe();
            //// describe of your lookup field
            
            for(Schema.SObjectType reference : f.getReferenceTo()) {
                objectToQuery = reference.getDescribe().getName();
            }
            System.debug('%%%%%%%% LAT_objectToQuery : '+objectToQuery );
        }

        return objectToQuery;
    }

    /**
    * @descp: Get and buuild account fields based on Field Set. Also retrieves name of parent lookups to be used in custom lookups in the related page.
    **/

    public Account getAllfields (String idAccount){

        lookupRefNames = new Map<String,String>();

        //Build map with Lookup Field and Its Parent Name
        Map<String,String> parentLookupsName = new Map<String,String>();
        for(Schema.SobjectField strFld : Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().Values()){
            if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE){
                parentLookupsName.put(strFld.getDescribe().getName() ,  strFld.getDescribe().getRelationshipName()  );
            }
        }

        //Build list of all field set members Based on maps already built 
        List<Schema.FieldSetMember> listfsetMembers = new List<Schema.FieldSetMember>();
        if(mapFieldSetWithFields != null){
            if(!mapFieldSetWithFields.values().isEmpty()){
                for(List<FieldSetMember> listFsm : mapFieldSetWithFields.values() ){
                    System.debug('%%%%%%%%%%%%% listFsm : '+listFsm);
                     listfsetMembers.addAll(listFsm);

                }
            }
        }
        String queryLatAccount = 'SELECT ';
        String query = 'SELECT ';

        for(Schema.FieldSetMember f : listfsetMembers) {

            query += f.getFieldPath() + ', ';
            if (f.getFieldPath().contains('LAT_Account__r.')) {
                queryLatAccount += f.getFieldPath().split('__r.')[1] +', ';
            }
            if(f.getType() == Schema.DisplayType.REFERENCE){
                if (f.getFieldPath().contains('LAT_Account__r') && f.getFieldPath().contains('__c')) {

                    query+= f.getFieldPath().replace('__c','__r') +'.Name, ';
                    if (f.getFieldPath().contains('LAT_Account__r.')) {
                        queryLatAccount += f.getFieldPath().split('LAT_Account__r.')[1].replace('__c','__r') +'.Name, ';
                    }
                }
                 else {
                    query+= parentLookupsName.get(f.getFieldPath()).replace('__c','__r') +'.Name, ';
                    if (f.getFieldPath().contains('LAT_Account__r.')) {
                        queryLatAccount += parentLookupsName.get(f.getFieldPath()).split('LAT_Account__r.')[1].replace('__c','__r') +'.Name, ';
                    }
                }
                
                System.debug('%%%%%% BUSCANDO EL NULL : '+f.getFieldPath() +' ||| '+parentLookupsName.get(f.getFieldPath()) +'.Name');
                
                lookupRefNames.put(f.getFieldPath(), parentLookupsName.get(f.getFieldPath())+'.Name');

            }
        }
        if (!query.contains('RecordTypeId')) {
            query += 'RecordTypeId,';
        }
        query += 'Id,isPersonAccount, LAT_Account__c  FROM Account where id =\''+idAccount+'\' LIMIT 1';
        queryLatAccount += 'Id FROM LAT_Account__c where LAT_Accountid__c=\''+idAccount+'\' LIMIT 1';
        System.debug('%%%% query : '+query);
        System.debug('%%%% query : '+queryLatAccount);
        latAcc =  Database.query(queryLatAccount);
        System.debug('%%%%%% parentLookupsName : '+parentLookupsName);
        return Database.query(query);
    }

    /**
    * @descp: This method will retrieve from Field Set where it has name lat_br_accmob + offtrade or ontrade.
    Then will create list of Field set with its fields. 
    *
    **/

    public List<FieldSet> getAccountMobileFieldSetNames(){

        List<FieldSet> sectionsLayout =  new List<FieldSet>();
        Map<String,Schema.FieldSet> fieldSetMembers = SObjectType.Account.FieldSets.getMap();
        List<Schema.FieldSet> listFs = new List<Schema.FieldSet>();
        Map<String,FieldSet> fieldSetsName = new Map<String,FieldSet>();

        String startStringByRT = isOffTrade ? 'lat_mx_accmob_off' : 'lat_mx_accmob_on';

        for(String fsName : fieldSetMembers.keySet()){

                if(fsName.startsWith(startStringByRT)){
                    fieldSetsName.put(fsName.subString(fsName.length()-2,fsName.length()),fieldSetMembers.get(fsName));
                    listFs.add(fieldSetMembers.get(fsName)); 
                    System.debug('%%%%%%%% listFs : '+listFs);
                }
        }

        for(Integer i = 01 ; i <= fieldSetsName.keySet().size() ; i++ ){

            String formatValue = '';

            if(i <= 9) {

                formatValue = '0'+i;
                sectionsLayout.add( fieldSetsName.get(formatValue) );

            }else{

                sectionsLayout.add( fieldSetsName.get(String.valueOf(i)) );    
            } 
        }
        return sectionsLayout;
    }

    public PageReference doSave(){

        try{
            //Account and its fields
            if(accIdURL != null && accIdURL != ''){

                if(!isClone){

                  update acc;

                  PageReference pf = new PageReference('/apex/LAT_BR_Return_AccountMobile?id='+acc.Id);
                  pf.setRedirect(true);
                  return pf;

                }else{

                    accTBCloned = acc.clone(false,true,false,false);
                    insert accTBCloned;
                    PageReference pf = new PageReference('/apex/LAT_BR_Edit_AccountMobile?id='+acc.Id);
                    pf.setRedirect(true);
                    return pf;

                }

            }else{

              insert acc;

              PageReference pf = new PageReference('/apex/LAT_BR_Edit_AccountMobile?id='+acc.Id);
              pf.setRedirect(true);
              return pf;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Cadastro guardado'));
            return null;

        }catch(Exception e){

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return null;
        }
        
    }

    public PageReference selectRType(){

        rtSelection = false;
        accRecordTypeId = acc.RecordTypeId;
        isOffTrade = Global_RecordTypeCache.getRt(accRecordTypeId).DeveloperName == 'LAT_MX_ACC_OffTrade' ? true : false ;
        createMapFieldSetWithFields();
        return null;
    }


   

   public class lookupDefinition {

        public List<sObject> rows{get;set;}
        public List<String> columns{get;set;}
        public List<String> labels{get;set;}

        public lookupDefinition(){
            rows = new List<sObject>();
            columns = new List<String>();
            labels = new List<String>();

        }

         public lookupDefinition(List<sObject> pRows,List<String> pColumns,List<String> pLabels ){
            rows = pRows;
            columns = pColumns;
            labels = pLabels;
        }

    }
 
   
    public class SelectableRFC {

        public Boolean selected {get; set;}
        public String  razonSocial {get; set;}
        public String  rfc {get; set;}

        public SelectableRFC(String razonParam, String rfcParam, Boolean selectedParam){
            razonSocial = razonParam;
            rfc = rfcParam;
            selected = selectedParam;
        }
    }
    
}