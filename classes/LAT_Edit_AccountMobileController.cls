public with sharing class LAT_Edit_AccountMobileController {

    //Account to be edited/created/cloned
    public LAT_Account__c accFields {get;set;}
    public Account acc {get;set;}
    public Account accTBCloned {get;set;}
    public Boolean isOffTrade {get;set;}

    //URL PARAMETERS
    public String accIdURL {get;set;}
    public static String accRecordTypeId {get;set;}
    public String segIdURL {get;set;}
    public String credIdURL {get;set;}
    public Boolean rtSelection {get;set;}
    public Boolean isLocked {get;set;}


    //Clone
    public String cloneAcc {get;set;}
    public Boolean isClone {get;set;}

    //Segmentation, ClientWorkHours, Credit Analysus - Related Lists
    public LAT_CWH_ClientWorkHour__c horario {get;set;}
    public List<LAT_CWH_ClientWorkHour__c> listHorarios {get;set;}
    public List<LAT_BR_ClientChannelSegmentation__c> listSegmentation {get;set;}
    public LAT_BR_ClientChannelSegmentation__c segmentation {get;set;}
    public Boolean isNewSegmentation {get;set;}
    public Boolean isEditSegmentation {get;set;}
    public Boolean isNewCreditAnal {get;set;}
    public Boolean isEditCreditAnal {get;set;}
    public Analise_de_credito__c creditAnal {get;set;}
    public List<Analise_de_credito__c> listCreditAnal {get;set;}
    

    //Dinamyc variables - Left Sections
    public Map<String,List<FieldSetMember>> mapFieldSetWithFields {get;set;}
    public Map<String, Boolean> fieldsReadOnly {get;set;}
    public Map<String,String> lookupRefNames {get;set;}
    public final Set<String> blackListedSection = new Set<String>{'lat_br_accmob_off_rec_carga_08','lat_br_accmob_off_outras_obs_11'};

    public String sessionUserId;
    public String urlFrontDoorWithSId {get;set;}
    

    //Final Static Var
    public final static String URL_EDIT_PAGE_ACCMOB = '/apex/LAT_BR_Edit_AccountMobile';


    public LAT_Edit_AccountMobileController(ApexPages.StandardController controller) {

            //Get URL Paremeteres
            accIdURL =  ApexPages.currentPage().getParameters().get('id');
            cloneAcc =  ApexPages.currentPage().getParameters().get('clone');
            segIdURL =  ApexPages.currentPage().getParameters().get('seg');
            credIdURL = ApexPages.currentPage().getParameters().get('cred');

            //init Variables
            init();
    }

  

    public void init(){
            isLocked =false;
            rtSelection = true;
            isNewSegmentation = false;
            isNewCreditAnal = false;
            isEditCreditAnal = false;
            horario = new LAT_CWH_ClientWorkHour__c();
            segmentation = new LAT_BR_ClientChannelSegmentation__c();
            creditAnal = new Analise_de_credito__c();
            listHorarios = new List<LAT_CWH_ClientWorkHour__c>();
            listSegmentation = new List<LAT_BR_ClientChannelSegmentation__c>();
            listCreditAnal = new List<Analise_de_credito__c>();

            if(accIdURL != null && accIdURL != ''){
                String recId = [Select RecordTypeId From Account Where Id = :accIdURL limit 1].RecordTypeId;
                isOffTrade = Global_RecordTypeCache.getRt(recId).DeveloperName == 'Off_Trade' ? true : false ;
            }else{
                isOffTrade = false;
            }

            //Load Account maps with fields sets
            createMapFieldSetWithFields();

            //Clone = 1
            isclone = cloneAcc != null ? true : false;

            //Edit Account Or Create Account 
            if(accIdURL != null && accIdURL != ''){

                //get lat account data
                //if(!isOffTrade){
                    accFields = getLATAccount(accIdURL);
                //}

                //Account (cliente) fields, Cloned Account
                rtSelection = false;
                acc = getAllfields(accIdURL);
                if((![ Select Id From ProcessInstance WHERE TargetObjectId =: acc.Id AND Status = 'Pending' ].isEmpty())){
                    isLocked = true;//Approval.isLocked(acc.Id);
                }
                
                accRecordTypeId = acc.RecordTypeId;
                isOffTrade = Global_RecordTypeCache.getRt(accRecordTypeId).DeveloperName == 'Off_Trade' ? true : false ;

                if(isClone){ 
                    acc.ParentId = accIdURL;
                }

                //Horario ClientWorkHour object fields
                listHorarios = getRecordsBasedOnObject('LAT_CWH_ClientWorkHour__c','Account__c');
                if(!listHorarios.isEmpty()) horario = listHorarios.get(0);
                //Segmentation object fields
                listSegmentation = getRecordsBasedOnObject('LAT_BR_ClientChannelSegmentation__c','LAT_BR_Client__c');

                //Analises de credito
                listCreditAnal = getRecordsBasedOnObject('Analise_de_credito__c','Conta__c');

            }else{
              
                acc = new Account();
                horario = new LAT_CWH_ClientWorkHour__c();
            }

            //Creation/edition of Segmentation
            isNewSegmentation = segIdURL != null && segIdURL == 'new' ? true : false;
            isEditSegmentation = segIdURL != null &&  segIdURL == 'edit' ? true : false;                              

            if(isEditSegmentation){
                String segIdParam = ApexPages.currentPage().getParameters().get('segId');
                if(!listSegmentation.isEmpty()){
                    for(LAT_BR_ClientChannelSegmentation__c seg : listSegmentation ) {
                        if(seg.Id == segIdParam ) {
                            segmentation = seg;
                            break;
                        }
                    }
                }
            }

            //Creation/Editon of Credit Analisys
            isNewCreditAnal = credIdURL != null && credIdURL == 'new' ? true : false;
            isEditCreditAnal = credIdURL != null &&  credIdURL == 'edit' ? true : false;                              

            /**if(isEditCreditAnal){
                String credIdParam = ApexPages.currentPage().getParameters().get('credId');
                if(!listCreditAnal.isEmpty()){
                    for(Analise_de_credito__c cred : listCreditAnal ) {
                        if(cred.Id == credIdParam ) {
                            creditAnal = cred;
                            break;
                        }
                    }
                }
            }*/



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

                query+= parentLookupsName.get(fieldResult.getName()) +'.Name, ';

                lookupRefNames.put(fieldResult.getName(), parentLookupsName.get(fieldResult.getName())+'.Name');

              }
           }

           query = query.substring(0,query.length()-1);

           query += ' From ' + sObjectName + ' Where ' + relationshipName +' = \''+this.acc.Id +'\'';
        }

        return database.query(query);
    }

    /**
    * @descp: Get standard/custom fields from Field Set divided by Section similar to the Off Trade/On Trade Page Layouts
    *
    **/

    public void createMapFieldSetWithFields(){

            mapFieldSetWithFields = new Map<String,List<FieldSetMember>>();

            List<Schema.FieldSet> listFieldSetsMobile = getAccountMobileFieldSetNames();


            for(Schema.FieldSet fs : listFieldSetsMobile){
                if(fs != null){

                    if(mapFieldSetWithFields.get(fs.Name) != null){

                        mapFieldSetWithFields.get(fs.Name).addAll(fs.getFields());

                    }else{

                        mapFieldSetWithFields.put(fs.Name, new List<FieldSetMember>());

                        mapFieldSetWithFields.get(fs.Name).addAll(fs.getFields());
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
    public static lookupDefinition getLookupFieldInformation(String sFieldName,String rtId){

        String objectName = getLookupsType(sFieldName);
        List<sObject> listsObjects = new List<sObject>();
        List<String> listColumns = new List<String>();

        //This will get all Custom Setting values with Lookup Filters
        Map<String, LAT_Mobile_Lookup_Filter__c > filters = LAT_Mobile_Lookup_Filter__c.getAll();

        if(filters != null && sFieldName != 'RecordTypeId'){

            LAT_Mobile_Lookup_Filter__c filter = filters.get(sFieldName);

            if( filter.LAT_Columns__c != null ){

                String[] columns = filter.LAT_Columns__c.split(',');

                String whereFilters = filter.LAT_Filter_Value__c;

                String queryResult = 'Select Id, '+filter.LAT_Columns__c+' FROM '+ objectName  ;

                if( whereFilters != null) {

                      queryResult+= ' Where ';   
                      whereFilters = whereFilters.replace('{!rt}', 'RecordType.DeveloperName');
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
               listColumns = filter.LAT_Columns__c.split(',',0 );
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

        Map<String, Schema.SObjectField> objectFields = Schema.sObjectType.Account.fields.getMap();
        Schema.DescribeFieldResult f = objectFields.get(apiName).getDescribe();
        //// describe of your lookup field
        String objectToQuery = '';
        for(Schema.SObjectType reference : f.getReferenceTo()) {
            objectToQuery = reference.getDescribe().getName();
        }

        return objectToQuery;
    }

    /**
    * @descp: Get and buuild account fields based on Field Set. Also retrieves name of parent lookups to be used in custom lookups in the related page.
    **/

    public Account getAllfields (String idAccount){
        Set<String> setQueryFields = null;

        lookupRefNames = new Map<String,String>();

        //Build map with Lookup Field and Its Parent Name
        Map<String,String> parentLookupsName = new Map<String,String>();
        for(Schema.SobjectField strFld : Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().Values()){
            if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE){
                parentLookupsName.put(strFld.getDescribe().getName() ,  strFld.getDescribe().getRelationshipName()  );
            }
        }

        setQueryFields = new Set<String>();
        //Build list of all field set members Based on maps already built 
        List<Schema.FieldSetMember> listfsetMembers = new List<Schema.FieldSetMember>();
        if(mapFieldSetWithFields != null){
            if(!mapFieldSetWithFields.values().isEmpty()){
                for(List<FieldSetMember> listFsm : mapFieldSetWithFields.values() ){
                     listfsetMembers.addAll(listFsm);
                }
            }
        }

        String query = 'SELECT ';

        for(Schema.FieldSetMember f : listfsetMembers) {

            if(!setQueryFields.contains(f.getFieldPath())) {
                query += f.getFieldPath() + ', ';
                setQueryFields.add(f.getFieldPath());
            }
 
            if(f.getType() == Schema.DisplayType.REFERENCE){

                query+= parentLookupsName.get(f.getFieldPath()) +'.Name, ';

                lookupRefNames.put(f.getFieldPath(), parentLookupsName.get(f.getFieldPath())+'.Name');

            }
        }

        query += 'Id,isPersonAccount FROM Account where id =\''+idAccount+'\' LIMIT 1';

        return Database.query(query);
    }

    /**
    * @descp: This method will retrieve from Field Set where it has name lat_br_accmob + offtrade or ontrade.
    * Then will create list of Field set with its fields. 
    *
    **/

    public List<FieldSet> getAccountMobileFieldSetNames(){

        List<FieldSet> sectionsLayout =  new List<FieldSet>();
        Map<String,Schema.FieldSet> fieldSetMembers = SObjectType.Account.FieldSets.getMap();
        List<Schema.FieldSet> listFs = new List<Schema.FieldSet>();
        Map<String,FieldSet> fieldSetsName = new Map<String,FieldSet>();

        String startStringByRT = isOffTrade ? 'lat_br_accmob_off' : 'lat_br_accmob_on';

        for(String fsName : fieldSetMembers.keySet()){
                system.debug('entro++' + fsName);
               if(fsName.startsWith(startStringByRT) && !blackListedSection.contains(fsName.toLowerCase())){
                
                    fieldSetsName.put(fsName.subString(fsName.length()-2,fsName.length()),fieldSetMembers.get(fsName));
                    listFs.add(fieldSetMembers.get(fsName)); 
                }
        }

        List<String> orderedSection = getOrderedList(fieldSetsName.keySet());

        for(String sec: orderedSection){
            sectionsLayout.add( fieldSetsName.get(sec));
        }


        return sectionsLayout;
    }

    public PageReference doSave(){
        ApexPages.getMessages().clear();
        system.debug('entro save');
        try{
            //Account and its fields
            if(accIdURL != null && accIdURL != ''){

                if(!isClone){

                  upsert horario;
                  system.debug('error ++++ ' + horario);
                  update acc;
                  //if(!isOffTrade){
                    update accFields;
                  //}
                  acc = getAllfields(acc.Id);
                  accFields = getLATAccount(acc.Id);
                  PageReference pf = new PageReference('/apex/LAT_BR_Edit_AccountMobile?id='+acc.Id);//new PageReference('/apex/LAT_BR_Return_AccountMobile?id='+acc.Id);
                  pf.setRedirect(true);
                  //return pf;

                  return null;
                }else{

                    accTBCloned = acc.clone(false,true,false,false);
                    insert accTBCloned;
                    accFields = getLATAccount(acc.Id);
                    PageReference pf = new PageReference('/apex/LAT_BR_Edit_AccountMobile?id='+acc.Id);
                    pf.setRedirect(true);
                    return pf;

                }

            }else{
              acc.OwnerId = UserInfo.getUserId();
              insert acc;

              PageReference pf = new PageReference('/apex/LAT_BR_Edit_AccountMobile?id='+acc.Id);
              pf.setRedirect(true);
              return pf;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Cadastro guardado'));
            return null;

        }catch(dmlException e){
            system.debug('error ++++ ' + e.getMessage());
            if (!ApexPages.hasMessages()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getdmlMessage(0)));
            }
            return null;
        } catch (Exception e){
            system.debug('error ++++ ' + e.getMessage());
            if (!ApexPages.hasMessages()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            }
            return null;
        }
        
    }

    public PageReference selectRType(){
        system.debug('entro select+++');
        rtSelection = false;
        accRecordTypeId = acc.RecordTypeId;
        isOffTrade = Global_RecordTypeCache.getRt(accRecordTypeId).DeveloperName == 'Off_Trade' ? true : false ;
        createMapFieldSetWithFields();
        return null;
    }


   /** public PageReference doCancel(){
        system.debug('entro cancel+++');
        rtSelection = true;
        acc = new Account();
                horario = new LAT_CWH_ClientWorkHour__c();
        accRecordTypeId = null;
        mapFieldSetWithFields = null;
        system.debug('entro cancel2++++');
        return null;
    }*/

    public PageReference reset() {
        PageReference newpage = new PageReference(System.currentPageReference().getURL());
    newpage.setRedirect(true);
    return newpage;
    }


    public PageReference newSegmentationFlag(){

          system.debug('entro cancel+++');
           String sUrl = LAT_BR_BTN02_ClientChannelSegment.validationOfNewSeg(this.accIdURL);

           if (sUrl.indexOf('/') == 0){ 
                 isNewSegmentation = true;
                 //window.top.location = ; 

                 //PageReference pf = new PageReference(sUrl);

                 //pf.setRedirect(true);
                 return null;
           }else{ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, sUrl));
            return null;
           }

        
    }

    public PageReference cancelSeg(){
        system.debug('entro cancel+++');
         PageReference pf = new PageReference(URL_EDIT_PAGE_ACCMOB+'?id='+acc.Id);
         pf.setRedirect(true);
         return pf;
    }

    public String credIdParam {get;set;}
    public String segIdParam {get;set;}

    public PageReference editSegmentation(){
        system.debug('segId ===+++ ' + segIdParam);
        if( segIdParam != null ){
                system.debug('entro ===+++ ' + segIdParam);
             PageReference pf = new PageReference(URL_EDIT_PAGE_ACCMOB+'?seg=edit&id='+acc.Id+'&segId='+segIdParam);
             system.debug('segId ===+++ ' + pf);
             pf.setRedirect(true);
             return pf;
        }
        return null;
    }

    public PageReference saveSegmentation(){
        system.debug('entro cancel+++');
        try{
            if(segmentation != null){
                if(segmentation.LAT_BR_Client__c!= null){
                    upsert segmentation;
                }else{
                    segmentation.LAT_BR_Client__c = acc.Id;
                    insert segmentation;
                }
            }
            PageReference pf = new PageReference(URL_EDIT_PAGE_ACCMOB+'?id=' + acc.Id);
            pf.setRedirect(true);
            return pf;
           }catch(dmlException e){
            system.debug('error ++++ ' + e.getMessage());
            if (!ApexPages.hasMessages()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getdmlMessage(0)));
            }
            return null;
        } catch (Exception e){
            system.debug('error ++++ ' + e.getMessage());
            if (!ApexPages.hasMessages()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            }
            return null;
        }
    }


    public PageReference sendApproval(){

        system.debug('entro cancel+++');
         String sMsg = LAT_BR_BTN02_ClientChannelSegment.validationOfSegBeforeAproval(segIdParam); 

         if (sMsg == '' || sMsg == null){ 
                PageReference pf = new PageReference(URL_EDIT_PAGE_ACCMOB+'?id=' + acc.Id);
                pf.setRedirect(true);
                return pf; 

         }else{ 

              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,sMsg));
              return null;
         }

    }

    public PageReference sendApprovalCredit(){
        try {
            Approval.ProcessSubmitRequest req1 =
            new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(credIdParam);
            req1.setSubmitterId(sessionUserId);
            // Submit the record to specific process and skip the criteria evaluation
            //req1.setProcessDefinitionNameOrId('PTO_Request_Process');
            //req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);
        }catch(Exception e){

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Não foi encontrado nenhum processo de aprovação aplicável'));
            return null;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Credito enviado a aprovação com sucesso.'));
        return null;

    }

     public PageReference sendApprovalAccount(){
        try {
            Approval.ProcessSubmitRequest req1 =
            new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(acc.id);
            req1.setSubmitterId(sessionUserId);
            // Submit the record to specific process and skip the criteria evaluation
            //req1.setProcessDefinitionNameOrId('PTO_Request_Process');
            //req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);
        }catch(Exception e){

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Não foi encontrado nenhum processo de aprovação aplicável'));
            return null;
        }
        isLocked = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Cliente enviado a aprovação com sucesso.'));
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
            system.debug('entro cancel+++');
            rows = pRows;
            columns = pColumns;
            labels = pLabels;
        }

    }

    public List<String> getOrderedList(Set<String> numeberAsString){
        List<Integer> integerList = new List<integer>();
        for (String num: numeberAsString){
            integerList.add(Integer.valueOf(num));
        }

        for(Integer i = 0 ; i < integerList.size() ; i ++) {
            for(integer j = i+1 ; j <= integerList.size() -1 ; j ++ ){
              integer x = 0 ;
              if(integerList[i] >  integerList[j]){
                   x = integerList[i]  ;
                   integerList[i] = integerList[j]  ;
                   integerList[j]  = x;
                   system.debug(integerList) ;
              }
            }
        }  

        List<String> retString = new List<String>();
        for (Integer i:integerList) {
            String formatValue = '';

            if(i <= 9) {
                formatValue = '0'+i;
                retString.add(formatValue); 
            } else {
                retString.add(String.valueOf(i));
            }  

        }
        return retString;

    }

   private LAT_Account__c getLATAccount(String accId) {
        List<LAT_Account__c>  listAccLat = [SELECT Id, Name, LAT_DirectSale__c, LAT_CustomerContractsClassification__c, 
                                                LAT_UDCZonaVendedor__c, LAT_JDEZone__c, LAT_BR_StatusDueDiligence__c, 
                                                LAT_BR_DataDueDiligence__c, LAT_BR_PurchaseForecast__c, LAT_BR_Comments__c
                                            FROM LAT_Account__c
                                            WHERE LAT_Accountid__c =: accId];

        if (!listAccLat.isEmpty()){
            return listAccLat.get(0);
        } else {
            return new LAT_Account__c();
        }
    }

    
}