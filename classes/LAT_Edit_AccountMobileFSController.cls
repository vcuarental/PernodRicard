public with sharing class LAT_Edit_AccountMobileFSController {

    //Account to be edited/created/cloned
    public LAT_Account__c accFields {get;set;}
    public String accFieldsJS {get;set;}
    public Account acc {get;set;}
    public String accJS {get;set;}
    public Boolean isOffTrade {get;set;}
    public String fieldSetPrefix {get;set;}

    //URL PARAMETERS
    public String accIdURL {get;set;}
    public static String accRecordTypeId {get;set;}
    public String segIdURL {get;set;}
    public String credIdURL {get;set;}
    public Boolean rtSelection {get;set;}
    public Boolean isLocked {get;set;}
    public Boolean showNewCredAnalisisBtn {get;set;}
    public final Set<String> secprenchimento = new Set<String>{'lat_br_offsimples_preench_cadastro','lat_br_oncompletos_preench_cadastro','lat_br_onsimples_preench_cadastro','lat_br_offcompletos_preench_cadastro'};


    //Clone
    public String cloneAcc {get;set;}
    public Boolean isClone {get;set;}

    //Segmentation, ClientWorkHours, Credit Analysus - Related Lists
    public LAT_CWH_ClientWorkHour__c horario {get;set;}
    public String horarioJS { get;set; }
    public List<LAT_CWH_ClientWorkHour__c> listHorarios {get;set;}
    public List<LAT_BR_ClientChannelSegmentation__c> listSegmentation {get;set;}
    public LAT_BR_ClientChannelSegmentation__c segmentation {get;set;}
    public Boolean isNewSegmentation {get;set;}
    public Boolean isEditSegmentation {get;set;}
    public Boolean isNewCreditAnal {get;set;}
    public Boolean showCreditAnal {get;set;}
    public Boolean showSchedule {get;set;}
    public Boolean showAdditionalInformation {get;set;}
    public Boolean canCreateSegment {get;set;}
    public String segmentError {get;set;}



    public Boolean isEditCreditAnal {get;set;}
    public Analise_de_credito__c creditAnal {get;set;}
    public List<Analise_de_credito__c> listCreditAnal {get;set;}


    //Dinamyc variables - Left Sections
    public Map<String,List<FieldSetMember>> mapFieldSetWithFields {get;set;}
    public String mapFieldSetWithFieldsString {get;set;}
    public List<FieldSetMember> latAccountFieldSet {get;set;}
    public Map<String, Boolean> fieldsReadOnly {get;set;}
    public Map<String,String> lookupRefNames {get;set;}
    public final Set<String> blackListedSection = new Set<String>{'lat_br_accmob_off_rec_carga_08','lat_br_accmob_off_outras_obs_11'};
    public Map<String,String> requiredFieldsMapMessage {get;set;}
    public String requiredFieldsMapMessageString {get;set;}
    public static Boolean hasRequiredFieldsMissing {get;set;}
    public List<String> fieldsError {
        get {
            if ( fieldsError == null){
                fieldsError = new List<String>();
            }   
            return fieldsError;    
        } set;
    }

    public String sessionUserId;
    public String urlFrontDoorWithSId {get;set;}

    // SEGMENTATION
    public LAT_BR_ClientChannelSegmentation2Result__c segment{get;set;}
    public List<LAT_BR_ClientChannelSegmentation2__c> clientChannelSegmentation  {get;set;}
    public boolean hasSegment{get;set;}


    //Final Static Var
    public final static String URL_EDIT_PAGE_ACCMOB = '/apex/LAT_BR_Edit_AccountMobile';


    public LAT_Edit_AccountMobileFSController(ApexPages.StandardController controller) {

            //Get URL Paremeteres
            accIdURL =  ApexPages.currentPage().getParameters().get('id');
            cloneAcc =  ApexPages.currentPage().getParameters().get('clone');
            segIdURL =  ApexPages.currentPage().getParameters().get('seg');
            credIdURL = ApexPages.currentPage().getParameters().get('cred');

            //init Variables
            init();
    }


    /*
    * fieldsBasedOnRecordType
    * check the record type name, and return the field set prefix
    * @param record TypeId
    * @return prefix
    */
    private String fieldsBasedOnRecordType(String recId) {

        system.debug('recId'+  Global_RecordTypeCache.getRt(recId).DeveloperName);
        String recordName = Global_RecordTypeCache.getRt(recId).DeveloperName;
        String prefix = '';
        showCreditAnal = false;
        showSchedule = false;
        showAdditionalInformation = false;

        // Off-Trade/Completo
        if(recordName == 'LAT_Distribucao_Com_Faturamento' ||  recordName == 'LAT_Off_Trade_Faturamento') {
            prefix = 'offcompletos';
            showCreditAnal = true;
            showSchedule = true;
            //showAdditionalInformation = true;
        }
        // On-Trade/Completo
        else if(recordName == 'LAT_On_Trade_Venda_Directa' || recordName == 'LAT_On_Line_Com_Faturamento' || recordName == 'LAT_On_Trade_Com_Pagamento' ||  recordName == 'LAT_Eventos_VendaDirecta' ||  recordName == 'LAT_Eventos_Com_pagamento' ) {
            prefix = 'oncompletos';
            showCreditAnal = true;
            showSchedule = true;
        }
        // Off-Trade/Simples
        else if(recordName == 'LAT_Off_Trade_Sem_Faturamento') {
            prefix = 'offsimples';
        }
        // On-Trade/Simples
        else if(recordName == 'LAT_On_Trade_Sem_Pagamento' ||  recordName == 'LAT_Eventos_sem_pagamento') {
            prefix = 'onsimples';

        }
        else {
            prefix = 'onsimples';
        }

        return prefix;
    }

     /*
    * getSegmentationErrors
    * We want to control if the user could create a new segmentation
    * @accId account id
    * @return if the user has permisson to create.
    */ 
    private String getSegmentationErrors(String accId){
        String error = '';
        Account brAcc = [Select Id,channel__c,Type,Status__c,Lat_Account__c, Rating from Account where Id = :accId];
        List<LAT_BR_ClientChannelSegmentation2__c> currentDrafts = [select id,name from LAT_BR_ClientChannelSegmentation2__c where Account__c=:accId AND Status__c ='Draft'];
        
        if (brAcc.status__c != 'Cliente cadastrado no JDE'  && brAcc.status__c != 'Cliente cadastrado no CRM' && brAcc.Rating != 'Cliente Inativo'){
            error = 'Somente é permitido criar uma nova Segmentação para clientes com Status "Cadastrado no JDE" ou "Cadastrado no CRM"';
        } else if (currentDrafts.size() == 1) {
            error = 'Já existe uma Segmentação Em Preenchimento. Favor editar a mesma para seguir.';
        } 
        segmentError = error;
        return error;
    }

    public void init(){
            isLocked =false;
            canCreateSegment = true; 
            rtSelection = true;
            isNewSegmentation = false;
            isNewCreditAnal = false;
            isEditCreditAnal = false;
            segmentError = '';
            horario = new LAT_CWH_ClientWorkHour__c();
            segmentation = new LAT_BR_ClientChannelSegmentation__c();
            creditAnal = new Analise_de_credito__c();
            listHorarios = new List<LAT_CWH_ClientWorkHour__c>(); 
            listSegmentation = new List<LAT_BR_ClientChannelSegmentation__c>();
            listCreditAnal = new List<Analise_de_credito__c>();
            showNewCredAnalisisBtn = true;

            if(accIdURL != null && accIdURL != ''){
                String recId = [Select RecordTypeId From Account Where Id = :accIdURL limit 1].RecordTypeId;
                canCreateSegment = (getSegmentationErrors(accIdURL) == '');
                fieldSetPrefix = fieldsBasedOnRecordType(recId);
                system.debug('prefix ' + fieldSetPrefix);
                isOffTrade = Global_RecordTypeCache.getRt(recId).DeveloperName == 'Off_Trade' ? true : false ;

                List<LAT_BR_ClientChannelSegmentation2Result__c> lst = [SELECT Account__c,
                                                Beneficio_Fiscal__c,
                                                Channel__c,
                                                Client_type__c,
                                                Estrategia_comercial__c,
                                                FORMATO__c,
                                                Perfil__c,
                                                POLiTICA_DE_PRECO__c,
                                                PRIOR_DE_INVESTIMENTO__c,
                                                Segment__c,
                                                CreatedDate,
                                                Obtained_POLiTICA_DE_PRECO_Udc__r.Name,
                                                TBCI__c,
                                                Politica_Preco_Origin__r.Name,
                                                Sub_channel__c,Obtained_Layout__c
                                    FROM LAT_BR_ClientChannelSegmentation2Result__c
                                    WHERE Account__c = :accIdURL ORDER BY CreatedDate Desc];
                if(!lst.isEmpty()){
                    hasSegment = true;
                    segment = lst[0];
                } else {
                    hasSegment = false;
                }

                clientChannelSegmentation = [SELECT name, Account__c,Beneficio_Fiscal__c,
                                                Channel__c,
                                                Client_type__c,
                                                Estrategia_comercial__c,
                                                FORMATO__c,
                                                Sub_channel__c,
                                                Perfil__c,
                                                POLiTICA_DE_PRECO__c,
                                                PRIOR_DE_INVESTIMENTO__c,
                                                Segment__c,
                                                CreatedDate,Status__c
                       FROM LAT_BR_ClientChannelSegmentation2__c
                       WHERE Account__c = :accIdURL];

            }else{
                isOffTrade = false;
            }

            //Load Account maps with fields sets
            createMapFieldSetWithFields();
            requiredFieldsMapMessageString = JSON.serialize(requiredFieldsMapMessage);
            mapFieldSetWithFieldsString = JSON.serialize(mapFieldSetWithFields);
            getFieldSetLataccout();
            //Clone = 1
            isclone = cloneAcc != null ? true : false;

            //Edit Account Or Create Account
            if(accIdURL != null && accIdURL != ''){
				system.debug('accIdURL='+accIdURL);
                //get lat account data
                accFields = getLATAccount(accIdURL);
                system.debug('accFields='+accFields);
                accFieldsJS = JSON.serialize(accFields);

                //Account (cliente) fields, Cloned Account
                rtSelection = false;
                acc = getAllfields(accIdURL);
                accJS = JSON.serialize(acc);
                if((![ Select Id From ProcessInstance WHERE TargetObjectId =: acc.Id AND Status = 'Pending' ].isEmpty())){
                    isLocked = true;//Approval.isLocked(acc.Id);
                }

                accRecordTypeId = acc.RecordTypeId;
                isOffTrade = Global_RecordTypeCache.getRt(accRecordTypeId).DeveloperName == 'Off_Trade' ? true : false ;

                if (isClone) {
                    acc.ParentId = accIdURL;
                }

                //Horario ClientWorkHour object fields
                listHorarios = getRecordsBasedOnObject('LAT_CWH_ClientWorkHour__c','Account__c');
                if (!listHorarios.isEmpty()) horario = listHorarios.get(0);
                //Segmentation object fields
                listSegmentation = getRecordsBasedOnObject('LAT_BR_ClientChannelSegmentation__c','LAT_BR_Client__c');

                //Analises de credito
                listCreditAnal = getRecordsBasedOnObject('Analise_de_credito__c','Conta__c');
                if(listCreditAnal.size() > 0){
                    for(Analise_de_credito__c ac : listCreditAnal){
                        if(ac.LAT_BR_Status__c == 'Em Preenchimento'){
                            showNewCredAnalisisBtn = false;
                        }
                    }
                }
            } else {
                acc = new Account();
                horario = new LAT_CWH_ClientWorkHour__c();
            }

            //serializing horario to use in JS client-side
            horarioJS = JSON.serialize(horario);
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
                parentLookupsName.put(strFld.getDescribe().getName() ,  strFld.getDescribe().getRelationshipName());
            }
        }

        String query = '';

        if (sObjectName != null) {
           query = 'Select ';

           for(Schema.sobjectfield field : Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().values()){
              Schema.DescribeFieldResult fieldResult = field.getDescribe();
              query += fieldResult.getName() + ',';

              if (fieldResult.getType() == Schema.DisplayType.REFERENCE) {
                query+= parentLookupsName.get(fieldResult.getName()) +'.Name, ';

                lookupRefNames.put(fieldResult.getName(), parentLookupsName.get(fieldResult.getName())+'.Name');
              }
           }

           query = query.substring(0,query.length()-1);
           query += ' From ' + sObjectName + ' Where ' + relationshipName +' = \''+this.acc.Id +'\' ORDER BY CreatedDate DESC';
        }
		
        return database.query(query);
    }

    /**
    * @descp: Get standard/custom fields from Field Set divided by Section similar to the Off Trade/On Trade Page Layouts
    *
    **/
    public void createMapFieldSetWithFields() {
            mapFieldSetWithFields = new Map<String,List<FieldSetMember>>();
            requiredFieldsMapMessage = new Map<String, String>();

            List<Schema.FieldSet> listFieldSetsMobile = getAccountMobileFieldSetNames();
            Integer totalfields = 0;
			System.debug('listFieldSetsMobile= '+listFieldSetsMobile);
            for (Schema.FieldSet fs : listFieldSetsMobile) {
                if (fs != null) {
                    for (Schema.FieldSetMember field : fs.getFields()) {
                        if (field.getRequired()) {
                            requiredFieldsMapMessage.put(field.getFieldPath(), field.getLabel() + ' : É necessário inserir um valor');
                        }
                    }

                    if (mapFieldSetWithFields.get(fs.Name) != null) {
                        mapFieldSetWithFields.get(fs.Name).addAll(fs.getFields());
                    } else {
                        mapFieldSetWithFields.put(fs.Name, new List<FieldSetMember>());
                        mapFieldSetWithFields.get(fs.Name).addAll(fs.getFields());
                    }
                    totalfields += fs.getFields().size();
                }
            }
            System.debug('%%%% requiredFieldsMapMessage.size() : ' + requiredFieldsMapMessage.size());
            System.debug('%%%% totalfields : ' + totalfields);
            System.debug('%%%% requiredFieldsMapMessage : ' + requiredFieldsMapMessage);
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

        lookupRefNames = new Map<String,String>();

        //Build map with Lookup Field and Its Parent Name
        Map<String,String> parentLookupsName = new Map<String,String>();
        for(Schema.SobjectField strFld : Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().Values()){
            if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE){
                parentLookupsName.put(strFld.getDescribe().getName(), strFld.getDescribe().getRelationshipName() );
            }
        }

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
        query+= ' LAT_InformationUnfilled__c,';
        for(Schema.FieldSetMember f : listfsetMembers) {
            query += f.getFieldPath() + ', ';

            if(f.getType() == Schema.DisplayType.REFERENCE){
                query+= parentLookupsName.get(f.getFieldPath()) +'.Name, ';

                lookupRefNames.put(f.getFieldPath(), parentLookupsName.get(f.getFieldPath())+'.Name');
            }
        }

        query += 'Id, isPersonAccount FROM Account where id =\''+idAccount+'\' LIMIT 1';
		
        return Database.query(query);
    }

    public static Account getAllfieldsStatic (String idAccount, Map<String, Object> mapFieldSetFields){

        Map<String,String> lookupRefNames = new Map<String,String>();

        //Build map with Lookup Field and Its Parent Name
        Map<String,String> parentLookupsName = new Map<String,String>();
        for(Schema.SobjectField strFld : Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().Values()){
            if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE){
                parentLookupsName.put(strFld.getDescribe().getName() ,  strFld.getDescribe().getRelationshipName()  );
            }
        }

        String query = 'SELECT ';
        query+= ' LAT_InformationUnfilled__c,';
        if(mapFieldSetFields != null){
            if(!mapFieldSetFields.values().isEmpty()){                
                 for(Object listFsm : mapFieldSetFields.values() ){
                      List<Object> myList = ( List<Object>)listFsm;
                        // Esta es nuestra Lista brazil, olvidate de la otra mierda
                       	for(Object obj : myList ){
                            //dbRequired 0
                            //fieldPath 1
                            //label 2
                            //required 3
                            //type 4
                            //typeApex 5
                           
                            String[] spilt= String.ValueOf(obj).split(',');  
                            String type =  spilt[4].split('=')[1];
                            String fieldPath =  spilt[1].split('=')[1];
                            system.debug('fieldPath'+ fieldPath);
                            system.debug('type'+ type);

                            // Process Values
                            query += fieldPath + ', ';
                            if(type == String.valueOf(Schema.DisplayType.REFERENCE)){
                                query+= parentLookupsName.get(fieldPath) +'.Name, ';
                                lookupRefNames.put(fieldPath, parentLookupsName.get(fieldPath)+'.Name');
                            }
                       }
                 }
                  system.debug('lookupRefNames'+ lookupRefNames);
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

    public List<FieldSet> getAccountMobileFieldSetNames() {
        List<FieldSet> sectionsLayout =  new List<FieldSet>();
        Map<String,Schema.FieldSet> fieldSetMembers = SObjectType.Account.FieldSets.getMap();
        List<Schema.FieldSet> listFs = new List<Schema.FieldSet>();
        Map<String,FieldSet> fieldSetsName = new Map<String,FieldSet>();

        //String startStringByRT = isOffTrade ? 'lat_br_accmob_off' : 'lat_br_accmob_on';

        String startStringByRT = 'lat_br_'+ fieldSetPrefix ;
        // LAT_BR_offSimple_Basic_Info_01 ernest
        // LAT_BR_Accmob_on_Basic_Information_01
        // LAT_BR_offSimple_Basic_Info_01
        System.debug('>>>>>>>>' + startStringByRT);

        for(String fsName : fieldSetMembers.keySet()){
                system.debug('entro++' + fsName);
            if (secprenchimento.contains(fsName.toLowerCase())){
                    //fieldSetsNameFinal.put(fsName,fieldSetMembers.get(fsName));
                    //system.debug('entroaca1=+' + fsName.toLowerCase());
            } else if(fsName.startsWith(startStringByRT) && !blackListedSection.contains(fsName.toLowerCase())){
                    fieldSetsName.put(fsName.subString(fsName.length()-2,fsName.length()),fieldSetMembers.get(fsName));
                    listFs.add(fieldSetMembers.get(fsName));
            }
        }

        List<String> orderedSection = getOrderedList(fieldSetsName.keySet());
        for(String sec: orderedSection){
            sectionsLayout.add( fieldSetsName.get(sec));
        }
		System.debug('sectionsLayout = '+sectionsLayout);
        return sectionsLayout;
    }

    @RemoteAction
    public static String validateRequiredFields(Map<String, String> requiredFields, String accId, String accJSON) {

        String message = ''; 
        try{
            System.debug('%%%% accJSON : ' + accJSON);
            Account accObj = (Account)JSON.deserialize(accJSON, Account.class);
            List<String> fieldsMissing = new List<String>();
            for (String campo : requiredFields.keySet()) {
                if(accObj.get(campo) == '' || accObj.get(campo) == null) {
                    fieldsMissing.add(requiredFields.get(campo));
                }
            }
            message = string.join(fieldsMissing,',');
        } catch(Exception ex) {
            message = ex.getMessage();
        }
        return message;    
    }
    
    @RemoteAction
    public static String doSave(String accJSON, String accFieldsJSON, String horarioJSON, String accIdURLParam, Boolean isCloneParam, String mapFieldSetFieldsJSON, Boolean accChanged, Boolean accFieldsChanged, Boolean horarioChanged){
    
        try{
            Account accObj = (Account)JSON.deserialize(accJSON, Account.class);
            System.debug('%%%% accFieldsJSON : ' + accFieldsJSON);
            System.debug('%%%% horarioJSON : ' + horarioJSON);
            System.debug('%%%% mapFieldSetFieldsJSON : ' + mapFieldSetFieldsJSON);
            //Account and its fields
            if(accIdURLParam != null && accIdURLParam != ''){
                LAT_Account__c accFieldsObj = (LAT_Account__c)JSON.deserialize(accFieldsJSON, LAT_Account__c.class);
                if(!isCloneParam){

                    Map<String, Object> mapFieldSetFields = (Map<String, Object>) JSON.deserializeUntyped(mapFieldSetFieldsJSON);
                    LAT_CWH_ClientWorkHour__c horarioObj = (LAT_CWH_ClientWorkHour__c)JSON.deserialize(horarioJSON, LAT_CWH_ClientWorkHour__c.class);
                    if (horarioChanged) upsert horarioObj;
                    if (accChanged) update accObj;
                    if (accFieldsChanged) {
                        update accFieldsObj;
                        accObj = getAllfieldsStatic(accObj.Id, mapFieldSetFields);
                        accFieldsObj = getLATAccount(accObj.Id);
                    }
                    Account resultAccount = [SELECT LAT_InformationUnfilled__c FROM Account WHERE Id =:accObj.Id];
                    System.debug('%%%% LAT_InformationUnfilled__c : ' + resultAccount.LAT_InformationUnfilled__c);
                    accObj.LAT_InformationUnfilled__c = resultAccount.LAT_InformationUnfilled__c;
                    return JSON.serializePretty(new SaveRetunMap(accObj, accFieldsChanged ? accFieldsObj : null, ''));
                }else{
                    Account accTBCloned = accObj.clone(false,true,false,false);
                    insert accTBCloned;
                    accFieldsObj = getLATAccount(accObj.Id);
                    return JSON.serializePretty(new SaveRetunMap(null, accFieldsObj, '/apex/LAT_BR_Edit_AccountMobile?id='+accObj.Id));
                }

            }else{
              accObj.OwnerId = UserInfo.getUserId();
              insert accObj;
              return JSON.serializePretty(new SaveRetunMap(null, null, '/apex/LAT_BR_Edit_AccountMobile?id='+accObj.Id));
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Cadastro guardado'));
            return JSON.serializePretty(new SaveRetunMap());

        }catch(dmlException e){
            return JSON.serializePretty(new SaveRetunMap(null, null, e.getdmlMessage(0)));
        } catch (Exception e){
            return JSON.serializePretty(new SaveRetunMap(null, null, e.getMessage()));
        }

    }

    public PageReference deleteClient() {
        delete acc;
        PageReference pr = new PageReference('/apex/LAT_BR_SegmentationSlctMobile');       
        pr.setRedirect(true);
        return pr;
    }

    public Pagereference changeStatus(){
        acc.Status__c = 'Novo Cadastro';
        update acc;
        PageReference pr = new PageReference('/apex/LAT_BR_Edit_AccountMobileFieldSets?id='+acc.Id);       
        pr.setRedirect(true);
        return pr;
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

    public PageReference cancelSeg(){
        system.debug('entro cancel+++');
         PageReference pf = new PageReference(URL_EDIT_PAGE_ACCMOB+ '?id='+acc.Id);
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

    /*
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

    }*/

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

    /*

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

    }*/

    public class SaveRetunMap {
        public Account accountObject { get;set; }   
        public LAT_Account__c accountFieldObject { get;set; }
        public String resultMessage { get;set; }

        public SaveRetunMap() {
            this.accountObject = null;
            this.accountFieldObject = null;
            this.resultMessage = '';   
        }

        public SaveRetunMap(Account accObj, LAT_Account__c accFieldObj, String resultMsg) {
            this.accountObject = accObj;
            this.accountFieldObject = accFieldObj;
            this.resultMessage = resultMsg;
        }
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

    public List<String> getOrderedList(Set<String> numeberAsString) {
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
        for (Integer i : integerList) {
            String formatValue = '';

            if(i <= 9) {
                formatValue = '0'+i;
                retString.add(formatValue);
            } else {

            }
        }
        return retString;
    }

    @RemoteAction
    public static String validateAccountDataRemoting(String accId){
        return LAT_BR_SegmentationBehaviorHandler.validateAccountData(accId);
    }

    @RemoteAction
    public static String sentToApprovalRemoting(String accId){
        
        String ret = LAT_BR_SegmentationBehaviorHandler.sentToApproval(accId);
        System.debug('%%%%%%% ret : ' + ret);
        return ret;
    }

    public void getFieldSetLataccout(){
        Map<String,Schema.FieldSet> mapFieldSetLatAccount = LAT_ACCOUNT__c.sObjectType.getDescribe().FieldSets.getMap();
        List<FieldSetMember> result = new List<FieldSetMember>();
        
        result.addAll(mapFieldSetLatAccount.get('BR_BasicInfo_Mobile').getFields());
        result.addAll(mapFieldSetLatAccount.get('Know_Your_Customer_Legal').getFields());
        latAccountFieldSet = result;

/**
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
            }*/
    }
   private static LAT_Account__c getLATAccount(String accId) {
        List<LAT_Account__c>  listAccLat = [SELECT Id, Name, LAT_DirectSale__c, LAT_CustomerContractsClassification__c, 
                                            	LAT_UDCZonaVendedor__c, LAT_JDEZone__c, LAT_BR_StatusDueDiligence__c, 
                                                LAT_BR_DataDueDiligence__c, LAT_BR_PurchaseForecast__c, LAT_BR_Comments__c
                                            FROM LAT_Account__c
                                            WHERE LAT_Accountid__c =: accId];
		system.debug('listAccLat='+listAccLat);
        if (!listAccLat.isEmpty()){
            return listAccLat.get(0);
        } else {
            return new LAT_Account__c();
        }
    }


}