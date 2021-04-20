/*********************************************************************************
    * Name: EUR_CRM_MassUploadAccountBatch
    * Description: Class for uploading .csv files by batch. Taken from ASI component
*********************************************************************************/ 
global class EUR_CRM_MassUploadAccountBatch implements Database.Batchable<sObject>, Database.Stateful{

    global final String ObjAPIName;
    global final String parentID;
    global final String parentField;
    global final String fields;
    global final String fieldsLabel;
    global final String lookupEXID;
    global final String recordtypeName;
    global final String countryCode;
    global final String currentPageURL;
    global final String defaultValues; 
    global final String AttID;
    global final string recEXID {set;get;}
    global final string recEXIDcol {set;get;} 
    global final string parentObjectAPIName {set;get;}
    global final string ParentObjectUploadMsg {set;get;}
    global final boolean upsertMode {set;get;}
    global final boolean opt_allOrNone {set;get;}
    global final boolean emailNotification {set;get;}
    global List<Attachment> LAttUpdate;
    // Count the number of records being inserted by the Batch
    global Integer numberOfRecordsInserted {set;get;}
    global String specErrorMessage {get;set;}
    global EUR_CRM_MassUploadLog__c uploadLog {set;get;}
    
    private Schema.SObjectType ObjType;
    private Schema.SObjectType ParentObjType;
    private list<String> LFieldAPIName; 
    private list<String> LFieldLabel; 
    private map<string,string> MAPINameLabel;
    private list<Row> LInputRow;
    public list<Row> LErrorRows {set;get;} 
    //private list<lookupRecord> LLookupField;
    private map<string,integer> MFieldPos;
    private map<string,integer> MLookupFieldPos;
    private map<string,id> MRecTypeID; 
    public boolean hasError {set;get;}
    public string msg {set;get;}
    private id recordtypid;
    private list<string> LDefaultVales;
    private list<string> LDefaultValesHeader;
    private list<string> LEXIDFieldLabel;
    
    // Maps Event RecordTypeName to its Id in order to initialize correct events later
    private Map<String, Id> eventRecordTypeMap;
    
    private Integer rowCount;
    private Integer colCount;

    public List<EventsInsertWrapper> eventsWrap;
    public Map<String,Integer> mapDayOfWeek = new Map<String, Integer>{'Monday' => 1,
                                            'Tuesday' => 2,
                                            'Wednesday' => 3,
                                            'Thursday' => 4,
                                            'Friday' => 5 
                                            };

    public Map<String,Integer> mapFrequencyIterate = new Map<String, Integer>{'ZA_VF_28_1' => 1,
                                            'ZA_VF_28_2' => 1,
                                            'ZA_VF_28_3' => 1,
                                            'ZA_VF_28_4' => 1,
                                            'ZA_VF_28_1_3' => 2,
                                            'ZA_VF_28_2_4' => 2,
                                            'ZA_VF_7' => 4 
                                            };

    public Map<String,Integer> mapFrequencyDays = new Map<String, Integer>{'ZA_VF_28_1' => 28,
                                            'ZA_VF_28_2' => 28,
                                            'ZA_VF_28_3' => 28,
                                            'ZA_VF_28_4' => 28,
                                            'ZA_VF_28_1_3' => 14,
                                            'ZA_VF_28_2_4' => 14,
                                            'ZA_VF_7' => 7 
                                            };

    public Map<Id, String> mapVisitFrequency;

    public Boolean isUpload;

    transient Attachment att;

    public Boolean hasHeaderError;

    global EUR_CRM_MassUploadAccountBatch(String ObjAPIName, String parentID, String parentField, String fields, String fieldsLabel, String lookupEXID, String recordtypeName, 
        string defaultValues, string currentPageURL, string AttID, string recEXID, string recEXIDcol, string parentObjectAPIName, string ParentObjectUploadMsg,
        boolean upsertMode, boolean emailNotification , boolean opt_allOrNone, EUR_CRM_MassUploadLog__c log, Boolean isUpload){
        this.ObjAPIName = ObjAPIName;
        this.parentID = parentID;
        this.parentField = parentField;
        this.fields = fields;
        this.fieldsLabel = fieldsLabel;
        this.lookupEXID = lookupEXID;
        this.recordtypeName = recordtypeName;
        this.AttID = AttID;
        this.defaultValues = defaultValues;
        this.recEXID = recEXID;
        this.recEXIDcol = recEXIDcol;
        this.parentObjectAPIName = parentObjectAPIName;
        this.ParentObjectUploadMsg = ParentObjectUploadMsg;
        this.upsertMode = upsertMode;
        this.emailNotification = emailNotification;
        this.opt_allOrNone = opt_allOrNone;
        this.uploadLog = log;
        this.currentPageURL = currentPageURL;

        this.isUpload = isUpload;
        
        // Set country code to determine Event record type later
        if(this.recordtypeName != null && this.recordTypeName.contains('_')) {
            this.countryCode = recordTypeName.split('_')[1];
            
            // Initialize events record type if necessary
            if(this.eventRecordTypeMap == null) {
                eventRecordTypeMap = new Map<String, Id>();
                //List<RecordType> eventRecordTypes = Global_RecordTypeCache.getRtList('Event');

                for(RecordType rt: Global_RecordTypeCache.getRtList('Event')) {
                    eventRecordTypeMap.put(rt.DeveloperName, rt.Id);
                }                
            }
        }
   }

    global database.querylocator start(Database.BatchableContext BC){
        // This methods returns a SOQL query locator containing the records
        return Database.getQueryLocator([select id, name, body, description, parentid,owner.email from attachment where id =:AttID]);
    }
    
    // The executeBatch method is called for each chunk of records returned from start.    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('***: ' + scope);
        if(scope != null){
            init();
            LAttUpdate = new List<Attachment>();
            List<sObject> LParentObj = new List<sObject>();
            map<Id, string> resultTexts = new map<Id, string>();
            String messageDisplayed = '';
            
            for(sobject sc : scope){
                //Attachment att = (Attachment)sc;
                att = (Attachment)sc;           
                att.description = '';
                resultTexts.put(att.Id, '');
                LErrorRows = new list<Row>();
                String namefile = att.name;
                system.debug('namefile'+namefile);
                if(namefile.toLowerCase().right(3)=='csv'){
                    list<list<String>> parsedCSV = genResults(att.body);
                    System.debug('@@PARSECSV: '+parsedCSV);
                    //List<List<String>> testString = new List<List<String>>();
                    list<String> LHeader = new list<String>();

                    System.debug('%%HEADER0: '+parsedCSV[0][0]);
                    String header0 = parsedCSV[0][0];
                    header0.trim();
                    System.debug('%%HEADER0-TEST: '+parsedCSV[0][0]);
                    hasHeaderError = false;
                    if(header0 != 'ID'){
                        System.debug('%%HEY');
                        hasHeaderError = true;
                    }
                    
                    if(parsedCSV != null && parsedCSV.size()>0){
                        // retrieve header of csv
                        LHeader = addDefaultValues(parsedCSV[0],true);                  
                        parsedCSV.remove(0);
                        system.debug(LHeader);
                        integer i = 0;
                        for(List<String> LS : parsedCSV){
                            LS = addDefaultValues(LS,false);
                        }
                        MFieldPos = new map<string,integer>();
                        for(string h : LHeader){
                            system.debug('h.toLowerCase().trim() ' + h.toLowerCase().trim());
                            MFieldPos.put(h.toLowerCase().trim(),i);
                            i++;
                            system.debug('MFieldPos' + MFieldPos + h);
                        }
                        
                        LInputRow = new list<Row>();
                        Integer rowNumber = 1;
                        Map<string,string> MFieldType = new map<string,string>();
                        System.debug('%%LFIELD: '+LFieldAPINAme);
                        System.debug(MFieldType);
                        System.debug(ObjType);

                        List<string> testString = new list<string>();

                        String prefTest = 'eur_crm_preferred_day__c';
                        system.debug('@@PREFERRED: '+ObjType.getDescribe().fields.getMap());
                        for(string fieldname : LFieldAPIName){
                            
                            System.debug('@@FIELDNAME: '+fieldname);
                            System.debug('@@FIELD-SOBJECT: '+ObjType.getDescribe().fields.getMap().get(fieldname.trim()).getDescribe().getType().name().toLowerCase());
                            MFieldType.put(fieldname,ObjType.getDescribe().fields.getMap().get(fieldname.trim()).getDescribe().getType().name().toLowerCase());

                        }
                        LEXIDFieldLabel = new List<String>();

                        for(List<String> LS : parsedCSV){
                            Row r = new row(ObjType.newSObject());
                            
                            if(recordtypid != null){
                                r.sObj.put('recordtypeid',recordtypid);
                            }
                            Integer inputCol = 0;
                            system.debug(LS);
                            system.debug('@@@LFieldAPIName' + LFieldAPIName);
                            for(string fieldname : LFieldAPIName){
                                string labelname = MAPINameLabel.get(fieldname);
                                system.debug('MAPINameLabel.get(fieldname)' + MAPINameLabel.get(fieldname));
                                system.debug('MFieldPos'+MFieldPos);
                                system.debug('MFieldPosLabel'+labelname+MFieldPos.containsKey(labelname));
                                if(MFieldPos.containsKey(labelname)){
                                    system.debug('Non-Lookup Field:' + fieldname);
                                    system.debug('MFieldPos'+MFieldPos);
                                    system.debug(MFieldPos.get(labelname));
                                    system.debug(ObjType);
                                    if(MFieldType.containsKey(fieldname)){
                                        string tempFieldType = MFieldType.get(fieldname);
                                        System.debug('&&VALUE: '+LS[MFieldPos.get(labelname)]);
                                        
                                        //Custom Logic for Account
                                        if(recordtypeName == 'EUR_ZA_Route_Template') {
                                            if(fieldname == 'Id') {
                                                r.sObj.put(fieldname, '');
                                                if(fieldname == 'Id') {
                                                    
                                                    r.accExtID = LS[MFieldPos.get(labelname)] != null ? LS[MFieldPos.get(labelname)] : '';
                                                }
                                                
                                            }
                                            System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@ fieldname ' + fieldname);
                                            
                                        }
                                    }
                                }
                            }
                            r.rowNumber = rowNumber++;
                            if(r.hasErrors){
                                LErrorRows.add(r);
                            }
                            
                            String tempEXIDValue = '';
                            LInputRow.add(r);
                            System.debug('&LINPUT: '+r);
                        }
                        
                        //Additional logic for Account Mapping ZA: loop through the external ids of the related list, query them, and put the correct value to the lookup fields
                        Map<String, EUR_CRM_Account__c> accountMap = new Map<String, EUR_CRM_Account__c>();
                        if(recordtypeName == 'EUR_ZA_Route_Template') {
                            Set<String> accExtIDSet = new Set<String>();
                            Set<String> opObjectivesExtIDSet = new Set<String>();
                            
                            for(Row r : LInputRow){
                                if(r.accExtID != null && r.accExtID != '') {
                                    if(accExtIDSet.contains(r.accExtID)){
                                        //r.addError('Duplicate id value of '+r.accExtID);
                                        r.addError(Label.EUR_CRM_ZA_Duplicate_Id_Value+' '+r.accExtID);
                                        hasError = true;
                                    } else {
                                        accExtIDSet.add(r.accExtID);
                                    }
                                }
                                
                           }
                           Map<String, EUR_CRM_Account__c> accMap = new Map<String, EUR_CRM_Account__c>();

                           System.debug('ACCTID *********************** ' + accExtIDSet);
                           
                           if(accExtIDSet.size() > 0) {
                               List<EUR_CRM_Account__c> accList = [SELECT ID, Name, EUR_CRM_External_ID__c, EUR_CRM_Visit_Frequency__c, OwnerId, EUR_CRM_Preferred_Day__c FROM EUR_CRM_Account__c WHERE Id IN : accExtIDSet];
                               for(EUR_CRM_Account__c acc : accList) {
                                   String acctId = String.valueOf(acc.Id).substring(0, 15);
                                   accMap.put(acctId, acc);
                                   accountMap.put(acctId, acc);
                               }
                           }

                           if(isUpload == true){
                               for(Row r : LInputRow){
                                    if(r.accExtID != null && r.accExtID != '') {
                                        String acctId = String.valueOf(r.accExtID).substring(0, 15);
                                        if(accMap.containskey(acctId)){
                                        //if(accMap.containskey(r.accExtID)){  
                                        } else {
                                            //r.addError('Not a valid Account Id: '+r.accExtID);
                                            r.addError(Label.EUR_CRM_ZA_Invalid_Account_Id+' '+r.accExtID);
                                            hasError = true;
                                        }
                                    }
                                    
                               }
                            }

                           System.debug('ACCTMAP *********************** ' + accMap);
                           System.debug('&LINPUTROW: '+LInputRow);
                           for(Row r : LInputRow){
                                System.debug('@@CONTAINSMAP: ' +accMap.containsKey(r.accExtID)+ ' : '+ r.accExtID);
                               if(accMap.containsKey(r.accExtID)) {
                                   //r.sObj.put('EUR_CRM_Account__c', accMap.get(r.accExtID).ID);
                                   r.sObj.put('Id', accMap.get(r.accExtID).ID);
                               }
                                System.debug('RSOBJ *********************** ' + r.sObj);
                           }

                        }
                        
                        if(hasHeaderError == true){
                            hasError = true;
                        }
                        
                        list<sObject> lRecInsert = new list<sobject>();
                        eventsWrap = new List<EventsInsertWrapper>();
                        if(!hasError){
                            for(Row r : LInputRow){
                                if(!r.hasErrors){
                                    lRecInsert.add(r.sObj);
                                }
                                system.debug('r.hasErrors ************************************** ' + r.hasErrors);
                                system.debug('r OBJECT ***************************** ' + r);
                            }
                            System.debug('LInputRow *********************** ' + LInputRow);
                            System.debug('LRECINSERT *********************** ' + lRecInsert);
                            if(lRecInsert != null && lRecInsert.size()>0){
                                try{
                                    if(isUpload == false){

                                        EUR_CRM_Route_Template__c routTemplateRecord = [SELECT Id, EUR_CRM_Start_Date__c FROM EUR_CRM_Route_Template__c WHERE Id = :currentPageURL];
                                        mapVisitFrequency = new Map<Id, String>();
                                        for(EUR_CRM_Visit_Frequency__c vf : [SELECT Id, EUR_CRM_External_ID__c FROM EUR_CRM_Visit_Frequency__c WHERE Recordtype.DeveloperName = 'EUR_ZA_Visit_Frequency']){
                                            mapVisitFrequency.put(vf.Id, vf.EUR_CRM_External_ID__c);
                                        }

                                        List<EUR_CRM_Route_Template_Item__c> rtItemToInsert = new List<EUR_CRM_Route_Template_Item__c>();
                                        List<EUR_CRM_Route_Template_Day__c> rtDayToInsert = new List<EUR_CRM_Route_Template_Day__c>();
                                        List<Event> eventToInsert = new List<Event>();


                                        EUR_CRM_Route_Template_Item__c rtItem; 
                                        EUR_CRM_Route_Template_Day__c rtDay;

                                        for(EUR_CRM_Account__c acct : accountMap.values()){

                                            // Do not create an event if CSV account has NULL values for EITHER Fields EUR_CRM_Preferred_Day__c OR EUR_CRM_Visit_Frequency__c
                                            if(acct.EUR_CRM_Visit_Frequency__c == null || acct.EUR_CRM_Preferred_Day__c == null){
                                                continue;
                                            }
                                            
                                            rtItem = new EUR_CRM_Route_Template_Item__c();
                                            rtItem.EUR_CRM_Account__c = acct.id;
                                            rtItem.EUR_CRM_Route_Template__c = currentPageURL;

                                            rtDay = new EUR_CRM_Route_Template_Day__c();
                                            rtDay.EUR_CRM_Day__c = mapDayOfWeek.get(acct.EUR_CRM_Preferred_Day__c);

                                            eventsWrap.add(new EventsInsertWrapper(currentPageURL, rtItem,rtDay, createEvent(routTemplateRecord.EUR_CRM_Start_Date__c, acct.EUR_CRM_Visit_Frequency__c, acct.EUR_CRM_Preferred_Day__c, acct.OwnerId, acct.Id, acct.Name)));
                                        }

                                        for(EventsInsertWrapper ew : eventsWrap){
                                            rtItemToInsert.add(ew.rtItem);
                                        }

                                        Database.UpsertResult[] srList = Database.upsert(rtItemToInsert, false);
                                        if(numberOfRecordsInserted == null) {
                                            numberOfRecordsInserted = 0;
                                        }
                                        System.debug('srList *********************** ' + srList);
                                        // Iterate through each returned result
                                        for (Database.UpsertResult sr : srList) {
                                            if (sr.isSuccess()) {
                                                numberOfRecordsInserted++;
                                            }
                                        }

                                        for(EventsInsertWrapper ew : eventsWrap){
                                            ew.rtDay.EUR_CRM_Route_Template_Item__c = ew.rtItem.Id;
                                            rtDayToInsert.add(ew.rtDay);
                                        }

                                        Database.UpsertResult[] srList2 = Database.upsert(rtDayToInsert, false);

                                        for(EventsInsertWrapper ew : eventsWrap){
                                            for(Event e : ew.events){
                                                e.EUR_CRM_Route_Template__c = ew.rTemplate;
                                                e.EUR_CRM_Route_Template_Item__c = ew.rtItem.Id;
                                                eventToInsert.add(e);
                                            }
                                        }

                                        Database.UpsertResult[] srList3 = Database.upsert(eventToInsert, false);    

                                        msg = 'Import Success! ' + string.valueof(rtItemToInsert.size()) + ' record(s) imported.';
                                    } else{
                                        numberOfRecordsInserted = lRecInsert.size();
                                        msg = 'Import Success! ' + string.valueof(lRecInsert.size()) + ' record(s) imported.';
                                    }
                                
                                System.debug('@@SUCCESS: '+msg);
                                System.debug('@@CURRENTURL: '+currentPageURL);

                                } catch(dmlexception de){
                                    System.debug('DMLEXCEPTION ' + de);
                                    hasError = true;
                                    
                                    for(integer j =0;j<de.getNumDml();j++){
                                        LInputRow[j].addError(de.getDmlMessage(j));
                                        resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+de.getDmlMessage(j));
                                        LErrorRows.add(LInputRow[j]);
                                    }
                                    msg = '';
                                    LAttUpdate.add(att);
                                    sObject tempParent = ParentObjType.newSObject();
                                    tempParent.put('id',att.parentid);
                                    tempParent.put(ParentObjectUploadMsg,  resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
                                    LParentObj.add(tempParent);

                                } catch(exception e){
                                    system.debug('error'+e);
                                }
                            }else{
                                // error tips for boolean, date, decimal, integer
                                String errorTips = '<div style="color: blue;"><div><img src="/img/msg_icons/info16.png" style="vertical-align: middle;"/><span style="color:blue; font-weight: bold; vertical-align: middle;"> Data Formats Supported: </span></div>';
                                errorTips += '&nbsp;&nbsp;&nbsp;Date: YYYY-MM-DD\n';
                                errorTips += '&nbsp;&nbsp;&nbsp;Currency: 12345.67</div>\n';
                                string errorText = errorTips + '<div><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Import Failed! </span></div>';
                                for(Row r : LInputRow){
                                    if(r.hasErrors){
                                        for(string errorMsg :r.errorMsgs){
                                            if(errorText!='') errorText += '<div style="color:red;">';
                                            errorText += '       Row' + String.valueof(r.rowNumber)+': ' + errorMsg;
                                        } 
                                    }
                                }
                                if(errorText!=''){
                                    errorText += '</div>';
                                    resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+errorText);
                                }
                                LAttUpdate.add(att);
                                sObject tempParent = ParentObjType.newSObject();
                                tempParent.put('id',att.parentid);
                                tempParent.put(ParentObjectUploadMsg,resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
                                LParentObj.add(tempParent);
                            }
                        }else{

                            String errorTips = '<div style="color: blue;"><div><img src="/img/msg_icons/info16.png" style="vertical-align: middle;"/><span style="color:blue; font-weight: bold; vertical-align: middle;"> Data Formats Supported: </span></div>';
                            errorTips += '&nbsp;&nbsp;&nbsp;Date: YYYY-MM-DD\n';
                            errorTips += '&nbsp;&nbsp;&nbsp;Currency: 12345.67</div>\n';
                            //string errorText = errorTips + '<div><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Import Failed! </span></div>';
                            string errorText = '';
                            messageDisplayed = errorText;
                            
                            if(hasHeaderError == false){
                                for(Row r : LInputRow){
                                    Boolean isErr = false;
                                    if(r.hasErrors){
                                        for(string errorMsg :r.errorMsgs) {
                                            //if(errorText!='') errorText += '<span style="color:red;">';
                                            errorText += '<br/>';
                                            errorText += 'Row ' + String.valueof(r.rowNumber)+': ' + errorMsg;
                                            specErrorMessage = errorText;
                                            isErr = true;
                                        }
                                        if(isErr == true){
                                            specErrorMessage += '</span>';
                                        }
                                    }
                                }
                                if(errorText!=''){
                                    resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+errorText);
                                }
                            } else {
                                errorText += '<br/>';
                                //errorText += 'Please check the header of the Account Id.';
                                errorText += Label.EUR_CRM_ZA_Check_Account_Header;
                                specErrorMessage = errorText;
                                specErrorMessage += '</span>';
                            }
                            LAttUpdate.add(att);
                            sObject tempParent = ParentObjType.newSObject();
                            tempParent.put('id',att.parentid);
                            tempParent.put(ParentObjectUploadMsg,resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
                            //LParentObj.add(tempParent);
                            System.debug('##TEMP: '+tempParent);
                        }
                    }
                    System.debug(LAttUpdate);
                    if(LAttUpdate != null && LAttUpdate.size()>0){
                        for(Attachment att1: LAttUpdate) {
                            att1.description = messageDisplayed;
                        }
                        update LAttUpdate;
                    }
                    if(LParentObj != null && LParentObj.size()>0){
                        update LParentObj;
                    }
                }else{
                    //msg = 'Error: Please select csv file only!';
                    msg = Label.EUR_CRM_ZA_Select_CSV_Only;
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        if(uploadLog != null) {
            if(uploadLog.id != null) {
                uploadLog.EUR_CRM_Number_of_records__c = numberOfRecordsInserted;
                uploadLog.EUR_CRM_Error_Message__c = specErrorMessage;
                update uploadLog;
            }
        }
    }
    
    public void init(){
        ObjType = Schema.getGlobalDescribe().get(ObjAPIName);
        ParentObjType = Schema.getGlobalDescribe().get(parentObjectAPIName);
        // October 5 2015: Work around implementation to cater space as my delimiter (salesfore bug for commas)
        LFieldAPIName = fields.contains(',') ? fields.toLowerCase().split(',',0) : fields.toLowerCase().split(' ',0); 
        LFieldLabel = fieldsLabel.toLowerCase().split(',',0);
        if([select id from recordType where developername = :recordtypeName and SobjectType = :ObjAPIName].size()>0){
            recordtypid = [select id from recordType where developername = :recordtypeName and SobjectType = :ObjAPIName].id;
        }
        MAPINameLabel = new map<string,string>();
        for(integer i=0;i<LFieldAPIName.size();i++){
            MAPINameLabel.put(LFieldAPIName[i].toLowerCase().trim(),LFieldLabel[i].toLowerCase().trim());
        }
        MRecTypeID = new map<string,id>();
        for(RecordType r: [Select id, name, SobjectType from RecordType Where Id=:recordtypid]){
            string key = r.SobjectType+r.name;
            key = key.toLowerCase();
            MRecTypeID.put(key,r.id);
        }
        system.debug('MRecTypeID'+MRecTypeID);
        hasError = false;
        msg = '';
        LDefaultVales = new list<string>();
        LDefaultValesHeader = new list<string>();
        if(defaultValues != null && defaultValues != ''){
            list<string> LDefaultValuePair = defaultValues.split(';',0);
            for(String s : LDefaultValuePair){
                list<string> l = s.split(':',0);
                LDefaultValesHeader.add(l[0]);
                LDefaultVales.add(l[1]);
            }
        }
    }
    
    private list<string> addDefaultValues(list<string> ls, boolean isHeader){
        if(isHeader)
            ls.addAll(LDefaultValesHeader);
        else
            ls.addAll(LDefaultVales);
        return ls;
    }
    
    private List<List<String>> genResults(blob contentFile) {
        List<List<String>> parsedCSV = new List<List<String>>();
        rowCount = 0;
        colCount = 0;
        if (contentFile != null){
            //String fileString = contentFile.toString().toLowerCase();
            //Modify by Steve 20140617
            String fileString = contentFile.toString();
            parsedCSV = parseCSV(fileString, false);
            rowCount = parsedCSV.size();
            for (List<String> row : parsedCSV){
                if (row.size() > colCount){
                    colCount = row.size();
                }
            }
            // fill in empty value to make sure col size is the same for each row
            for (list<string> row : parsedCSV){
                while(row.size()<colCount){
                    row.add('');
                }
            }
        }
        return parsedCSV;
    }

    
    /* 
    Credit to 
    http://wiki.developerforce.com/index.php/Code_Samples#Parse_a_CSV_with_APEX
    */
    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        //hasHeaderError = false;
        List<List<String>> allFields = new List<List<String>>();
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        
        contents = contents.replaceAll('""','DBLQT');
        contents = contents.replaceAll('\r\n','\r');
        contents = contents.replaceAll('\n','\r');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try{
            //lines = contents.split('\n'); //correction: this only accomodates windows files
            lines = contents.split('\r'); // using carriage return accomodates windows, unix, and mac files
            //http://www.maxi-pedia.com/Line+termination+line+feed+versus+carriage+return+0d0a
        }catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line: lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');  
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field: fields) {
                
                if (field.startsWith('"') && field.endsWith('"') && field.length()>1) {
                    cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')  && !makeCompositeField) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"') && makeCompositeField) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('"','').replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                    system.debug('composite field2:'+compositeField.replaceAll('"','').replaceAll('DBLQT','"'));
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));
                }
            }
            allFields.add(cleanFields);
        }
        
        if (skipHeaders) allFields.remove(0);
        return allFields;       
    }
    
    public class Row {
        public Integer rowNumber {set;get;}
        public sObject sObj {set;get;}
        
        //Custom Variable used for account lookup EU for ZA
        public String accExtID {set;get;}
        //Custom Variable used for objective op lookup EU for ZA
        public String opObjectivesExtID {set;get;}
        
        private list<string> m_errorMsgs = new list<string>();
        public list<string> errorMsgs { get { return m_errorMsgs; }}
        public boolean hasErrors { get { return errorMsgs.size()>0; }set;}
        
        public row(sObject obj){
            sObj = obj;            
        }
        
        public row(sObject obj, string parentField, string parentID){
            sObj = obj;
            sObj.put(parentField,parentID);
        }
        public void addError(string errMsg){
            errorMsgs.add( errMsg);
            hasErrors = true;
        }
    }

    public class EventsInsertWrapper{
        public String rTemplate {get;set;}
        public EUR_CRM_Route_Template_Item__c rtItem {get;set;}
        public EUR_CRM_Route_Template_Day__c rtDay {get;set;}
        public List<Event> events {get;set;}

        public EventsInsertWrapper(String rTemplate, EUR_CRM_Route_Template_Item__c rtItem, EUR_CRM_Route_Template_Day__c rtDay, List<Event> events){
            this.rTemplate = rTemplate;
            this.rtItem = rtItem;
            this.rtDay = rtDay;
            this.events = events;
        }
    }

    public List<Event> createEvent(Date rtDate, Id visitFreqId, String prefDay, Id ownerId, Id accountId, String accountName){
        List<Event> eventList = new List<Event>();

        Date tempdate = rtDate;

        Boolean isEnd = false;
        Integer numWeek = 1;

        for(integer i=0;i<mapFrequencyIterate.get(mapVisitFrequency.get(visitFreqId));i++){
            DateTime dt = Datetime.newInstance(tempdate.year(), tempdate.month(),tempdate.day());
            String startOfMonthWeekDay = dt.format('EEEE');
            Event e = new Event();
            e.IsAllDayEvent = TRUE;
            e.OwnerId = ownerId;
            e.Subject = accountName;
            //e.StartDateTime = dt + mapDayOfWeek.get(prefDay);
            //tempDate = tempdate + mapFrequencyDays.get(mapVisitFrequency.get(visitFreqId));
            if(mapVisitFrequency.get(visitFreqId) == 'ZA_VF_28_1'){
                e.StartDateTime = dt + mapDayOfWeek.get(prefDay);
                tempDate = tempdate + 28;
            }
            if(mapVisitFrequency.get(visitFreqId) == 'ZA_VF_28_2'){
                e.StartDateTime = dt + mapDayOfWeek.get(prefDay);
                e.StartDateTime = e.StartDateTime+7;
                tempDate = tempdate + 28;
            }
            if(mapVisitFrequency.get(visitFreqId) == 'ZA_VF_28_3'){
                e.StartDateTime = dt + mapDayOfWeek.get(prefDay);
                e.StartDateTime = e.StartDateTime+14;
                tempDate = tempdate + 28;
            }
            if(mapVisitFrequency.get(visitFreqId) == 'ZA_VF_28_4'){
                e.StartDateTime = dt + mapDayOfWeek.get(prefDay);
                e.StartDateTime = e.StartDateTime+21;
                tempDate = tempdate + 28;
            }
            if(mapVisitFrequency.get(visitFreqId) == 'ZA_VF_28_1_3'){
                e.StartDateTime = dt + mapDayOfWeek.get(prefDay);
                tempDate = tempdate + 14;
            }
            if(mapVisitFrequency.get(visitFreqId) == 'ZA_VF_28_2_4'){
                e.StartDateTime = dt + mapDayOfWeek.get(prefDay);
                e.StartDateTime = e.StartDateTime+7;
                tempDate = tempdate + 14;
            }
            if(mapVisitFrequency.get(visitFreqId) == 'ZA_VF_7'){
                e.StartDateTime = dt + mapDayOfWeek.get(prefDay);
                tempDate = tempdate + 7;
            }
            
            // Obtain correct recordtypeid according to the countrycode from eventRecordTypeMap created earlier
            e.recordTypeId = eventRecordTypeMap.get('EUR_' + this.countryCode + '_Visitation_Event');
            
            eventList.add(e);
        }

        return eventList;
        
    }
}