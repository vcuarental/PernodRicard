/*********************************************************************************
    * Name: EUR_CRM_MassUploadBatch
    * Description: Class for uploading .csv files by batch. Taken from ASI component
    *
    * Version History
    * 2015-08-27        Conrad Pantua Laputa      Create
    * 2015-10-05        Conrad Pantua Laputa      Use work around to use space as delimiter instead of comma (salesforce bug)
*********************************************************************************/ 
global class EUR_CRM_MassUploadBatch implements Database.Batchable<sObject>, Database.Stateful{

    global final String ObjAPIName;
    global final String parentID;
    global final String parentField;
    global final String fields;
    global final String fieldsLabel;
    global final String lookupEXID;
    global final String recordtypeName;
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
    global EUR_CRM_MassUploadLog__c uploadLog {set;get;}
    
    // Reactivation fields
    private String strOpStatus;
    private Set<String> existingAccountSet;
    private Map<String, EUR_CRM_ObjPromo_Account_Mapping__c> opAccMappingMap;
    private Map<String, String> accToDoNotReactivate;

    private Schema.SObjectType ObjType;
    private Schema.SObjectType ParentObjType;
    private list<String> LFieldAPIName; 
    private list<String> LFieldLabel; 
    private map<string,string> MAPINameLabel;
    private list<Row> LInputRow;
    private list<Row> LUpdateRow;
    private list<Row> LInsertRow;
    private Map<String, Row> uniqueRow;
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
    
    private Integer rowCount;
    private Integer colCount;
    
    private Set<String> OPAccountMappingWithExternalId = new Set<String> {
        'EUR_ZA_OP_Account_Mapping'  
    };
    
    private Set<String> OPAccountMappingWithId = new Set<String> {
        'EUR_RU_O_P_Account_Mapping',
        'EUR_DK_OP_Account_Mapping'
    };

    global EUR_CRM_MassUploadBatch(String ObjAPIName, String parentID, String parentField, String fields, String fieldsLabel, String lookupEXID, String recordtypeName, 
        string defaultValues, string currentPageURL, string AttID, string recEXID, string recEXIDcol, string parentObjectAPIName, string ParentObjectUploadMsg,
        boolean upsertMode, boolean emailNotification , boolean opt_allOrNone, EUR_CRM_MassUploadLog__c log){
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
   }

    global database.querylocator start(Database.BatchableContext BC){
        // This methods returns a SOQL query locator containing the records
        return Database.getQueryLocator([select id, name, body, description, parentid,owner.email from attachment where id =:AttID]);
    }
    
    // The executeBatch method is called for each chunk of records returned from start.    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('Scope: ' + scope);
        if(scope != null){
            init();
            LAttUpdate = new List<Attachment>();
            List<sObject> LParentObj = new List<sObject>();
            map<Id, string> resultTexts = new map<Id, string>();
            String messageDisplayed = '';
            
            for(sobject sc : scope){
                Attachment att = (Attachment)sc;                
                att.description = '';
                resultTexts.put(att.Id, '');
                LErrorRows = new list<Row>();
                String namefile = att.name;
                system.debug('namefile'+namefile);
                if(namefile.toLowerCase().right(3)=='csv'){
                    list<list<String>> parsedCSV = genResults(att.body);
                    list<String> LHeader = new list<String>();
                    
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
                        LUpdateRow = new List<Row>();
                        LInsertRow = new List<Row>();
                        uniqueRow = new Map<String, Row>();
                        Integer rowNumber = 1;
                        Map<string,string> MFieldType = new map<string,string>();
                        System.debug(LFieldAPINAme);
                        System.debug(MFieldType);
                        System.debug(ObjType);
                        for(string fieldname : LFieldAPIName){
                            System.debug(fieldname);
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
                            system.debug('LFieldAPIName' + LFieldAPIName);
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
                                        if(tempFieldType=='date'){
                                            string dateText = LS[MFieldPos.get(labelname)];
                                            if(dateText.contains('/') || dateText.contains('-') || dateText.length()!=8){
                                                try{
                                                    r.sObj.put(fieldname, date.valueof(dateText));
                                                    date.valueof(dateText).addMonths(1);
                                                    System.debug(date.valueof(dateText).addMonths(1));
                                                }catch(exception e){
                                                    r.addError(Labelname + ': ' + e.getMessage());
                                                    hasError = true;
                                                }
                                            }else{
                                                r.sObj.put(fieldname, date.newInstance(integer.valueOf(dateText.subString(0,4)), integer.valueOf(dateText.subString(4,6)), integer.valueOf(dateText.subString(6,8))));
                                            }
                                        }else if(tempFieldType=='double' || tempFieldType=='percent' ||tempFieldType=='currency'){
                                            try{
                                                r.sObj.put(fieldname, decimal.valueof(LS[MFieldPos.get(labelname)]));
                                            }catch(exception e){
                                                r.addError(labelname + ': ' + e.getMessage());
                                                hasError = true;
                                            }
                                        }
                                        //Custom logic for Account Mapping ZA
                                        if(recordtypeName.contains('Account_Mapping')) {
                                            if(fieldname == 'EUR_CRM_Account__c' || fieldname == 'EUR_CRM_ObjPromo__c') {
                                                if(fieldname == 'EUR_CRM_Account__c') {
                                                    r.accExtID = LS[MFieldPos.get(labelname)] != null ? LS[MFieldPos.get(labelname)] : '';
                                                }
                                            }
                                            System.debug('fieldname: ' + fieldname);
                                            
                                            if(fieldname == 'EUR_CRM_Evaluation_Required__c' || fieldname == 'EUR_CRM_Is_Active__c') {
                                                String booleanStr = LS[MFieldPos.get(labelname)] != null ? LS[MFieldPos.get(labelname)] : '';
                                                booleanStr = booleanStr.toLowerCase().trim();
                                                System.debug('booleanStr: ' + booleanStr);
                                                if(booleanStr.equalsIgnoreCase('true') && !strOpStatus.equalsIgnoreCase('ended')) {
                                                    System.debug('booleanStr==true');
                                                    r.sObj.put(fieldname, true);
                                                }
                                            }

                                            //EUR_CRM_Do_Not_Reactivate__c
                                            if(fieldname == 'EUR_CRM_Do_Not_Reactivate__c') {
                                                String booleanStr = LS[MFieldPos.get(labelname)] != null ? LS[MFieldPos.get(labelname)] : '';
                                                booleanStr = booleanStr.toLowerCase().trim();
                                                System.debug('booleanStr: ' + booleanStr);
                                                if(booleanStr.equalsIgnoreCase('true')) {
                                                    System.debug('booleanStr==true');
                                                    r.sObj.put(fieldname, true);
                                                }
                                                else{
                                                    r.sObj.put(fieldname, false);
                                                }
                                            }
                                            System.debug(r.sObj);     
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
                            System.debug(r);
                        }
                        
                        //Additional logic for Account Mapping ZA: loop through the external ids of the related list, query them, and put the correct value to the lookup fields
                        if(recordtypeName.contains('Account_Mapping')) {
                            Set<String> accExtIDSet = new Set<String>();
                            Set<String> opObjectivesExtIDSet = new Set<String>();
                            
                            for(Row r : LInputRow){
                                if(r.accExtID != null && r.accExtID != '') {
                                    accExtIDSet.add(r.accExtID);
                                }
                            }
                            Map<String, EUR_CRM_Account__c> accMap = new Map<String, EUR_CRM_Account__c>();
                           
                            if(accExtIDSet.size() > 0) {
                                List<EUR_CRM_Account__c> accList;
                                System.debug(accExtIDSet);
                                System.debug(recordtypeName);
                                if(OPAccountMappingWithExternalId.contains(recordTypeName)) {
                                    acclist = [SELECT ID, Name, EUR_CRM_External_ID__c FROM EUR_CRM_Account__c WHERE EUR_CRM_External_ID__c IN : accExtIDSet];
                                    System.debug(accList);
                                    for(EUR_CRM_Account__c acc : accList) {
                                        accMap.put(acc.EUR_CRM_External_ID__c, acc);
                                    }   
                                } 
                                else if(OPAccountMappingWithId.contains(recordTypeName)) {
                                    acclist = [SELECT ID, Name, EUR_CRM_External_ID__c FROM EUR_CRM_Account__c WHERE Id IN : accExtIDSet];  
                                    for(EUR_CRM_Account__c acc : accList) {
                                       accMap.put(String.valueOf(acc.Id).subString(0, 15), acc);
                                    } 
                                }
                            }
                            
                            // Loop all the rows to construct the acc-op map record to be upserted
                            for(Integer index = 0; index < LInputRow.size(); index++){
                                if(accMap.containsKey(LInputRow[index].accExtID)) {
                                    Row currentRow = LInputRow[index];
                                    if(existingAccountSet.contains(currentRow.accExtID) && strOpStatus.equalsIgnoreCase('ended')){
                                        currentRow.sObj.put('Id', (opAccMappingMap.get(currentRow.accExtID)).Id);
                                        if(currentRow.sObj.get('EUR_CRM_Do_Not_Reactivate__c') == false){
                                            currentRow.sObj.put('EUR_CRM_Is_Active__c', true);
                                        }
                                        LUpdateRow.add(currentRow);
                                    }
                                    else {
                                        currentRow.sObj.put('EUR_CRM_Account__c', accMap.get(currentRow.accExtID).Id);
                                        currentRow.sObj.put('EUR_CRM_ObjPromo__c', currentPageURL);

                                        String rowKey = String.valueOf(currentRow.sobj.get('EUR_CRM_ObjPromo__c')) + String.valueOf(currentRow.sObj.get('EUR_CRM_Account__c'));

                                        if(uniqueRow.get(rowKey) != null) {
                                            continue;
                                        } else {
                                            uniqueRow.put(rowKey, currentRow);
                                            System.debug(currentRow);
                                            LInsertRow.add(currentRow);
                                        }
                                    }
                                }
                            }
                        }
                        
                        list<sObject> lRecInsert = new list<sobject>();
                        list<sObject> lRecUpdate = new list<sobject>();

                        if(!hasError){
                            for(Row r : LInsertRow){
                                if(!r.hasErrors){
                                    lRecInsert.add(r.sObj);
                                }
                                system.debug('r.hasErrors: ' + r.hasErrors);
                                system.debug('r OBJECT: ' + r);
                            }
                            for(Row r : LUpdateRow){
                                if(!r.hasErrors){
                                    lRecUpdate.add(r.sObj);
                                }
                            }
                            System.debug('lRecInsert: ' + lRecInsert);
                            System.debug('lRecUpdate: ' + lRecUpdate);
                            System.debug('LInputRow: ' + LInputRow);
                            if(lRecInsert.size()>0 || lRecUpdate.size() > 0){
                                try{
                                    Database.SaveResult[] insrList = Database.Insert(lRecInsert, false);
                                    if(numberOfRecordsInserted == null) {
                                        numberOfRecordsInserted = 0;
                                    }
                                    System.debug('insrList: ' + insrList);
                                    // Iterate through each returned result
                                    for (Database.SaveResult isr : insrList) {
                                        if (isr.isSuccess()) {
                                            numberOfRecordsInserted++;
                                        }
                                    }

                                    Database.SaveResult[] updList = Database.Update(lRecUpdate, false);
                                    if(numberOfRecordsInserted == null) {
                                        numberOfRecordsInserted = 0;
                                    }
                                    System.debug('updList: ' + updList);
                                    // Iterate through each returned result
                                    for (Database.SaveResult upr : updList) {
                                        if (upr.isSuccess()) {
                                            numberOfRecordsInserted++;
                                        }
                                    }
                                    msg = 'Import Success! ' + string.valueof(lRecUpdate.size()+lRecInsert.size()) + ' record(s) imported.';
                                }
                                catch(exception e){
                                    hasError = true;
                                    if(e instanceof dmlexception){
                                        for(integer j =0;j<e.getNumDml();j++){
                                            LInputRow[j].addError(e.getDmlMessage(j));
                                            resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+e.getDmlMessage(j));
                                            LErrorRows.add(LInputRow[j]);
                                        }                                        
                                    } else {
                                        LInputRow[0].addError(e.getMessage());
                                        resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+e.getMessage());
                                        LErrorRows.add(LInputRow[0]);
                                    }
                                    System.debug(e);
                                    msg = '';
                                    LAttUpdate.add(att);
                                    sObject tempParent = ParentObjType.newSObject();
                                    tempParent.put('id',att.parentid);
                                    tempParent.put(ParentObjectUploadMsg,  resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
                                    LParentObj.add(tempParent);
                                }
                            } else{
                                // error tips for boolean, date, decimal, integer
                                String errorTips = '<div style="color: blue;"><div><img src="/img/msg_icons/info16.png" style="vertical-align: middle;"/><span style="color:blue; font-weight: bold; vertical-align: middle;"> Data Formats Supported: </span></div>';
                                errorTips += '&nbsp;&nbsp;&nbsp;Date: YYYY-MM-DD\n';
                                errorTips += '&nbsp;&nbsp;&nbsp;Currency: 12345.67</div>\n';
                                string errorText = errorTips + '<div><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Import Failed! </span></div>';
                                for(Row r : LInputRow){
                                    if(r.hasErrors){
                                        for(string errorMsg :r.errorMsgs){
                                            if(errorText!='') errorText += '<div style="color:red;">';{
                                                errorText += '       Row' + String.valueof(r.rowNumber)+': ' + errorMsg;
                                            }
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
                            string errorText = errorTips + '<div><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Import Failed! </span></div>';
                            messageDisplayed = errorText;
                            for(Row r : LInputRow){
                                if(r.hasErrors){
                                    for(string errorMsg :r.errorMsgs) {
                                        if(errorText!='') errorText += '<div style="color:red;">';{
                                            errorText += '&nbsp;&nbsp;&nbsp;Row' + String.valueof(r.rowNumber)+': ' + errorMsg;
                                        }
                                    }
                                }
                            }
                            if(errorText!=''){
                                resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+errorText);
                            }
                            LAttUpdate.add(att);
                            sObject tempParent = ParentObjType.newSObject();
                            tempParent.put('id',att.parentid);
                            tempParent.put(ParentObjectUploadMsg,resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
                            LParentObj.add(tempParent);
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
                    List<Messaging.Email> LEmails = new List<Messaging.Email>();
                    for(Attachment att1 : LAttUpdate){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        string resultText = resultTexts.get(att1.Id);
                        String resultTextHtml = resultText.replace('\n','<br/>');
                        String URLDownload = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + att1.id;
                        mail.setHtmlBody('Your mass upload submission was processed.<br/>' + resultTextHtml + '<br/><div style="color:black;">Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.<br/>Download Uploaded csv: </div><a href=\"'+URLDownload+'\">'+URLDownload+'</a>');
                        mail.setPlainTextBody('Your mass upload submission was processed.\n' + resultText + '\n<div style="color:black;">Please do not reply to this message.\nContact your system administrator if you feel you received this message in error.\nDownload Uploaded csv: </div>'+ URLDownload);
                        mail.setToAddresses(new List<String>{att1.owner.email});
                        mail.setReplyTo('noreply@salesforce.com');
                        mail.setSenderDisplayName('Mass Upload Process');
                        mail.setSubject('Mass Upload Process is Completed');
                        LEmails.add(mail);
                    }
                    if(LEmails.size()>0 && emailNotification){
                        if(!test.isrunningtest()){
                            Messaging.sendEmail(LEmails);
                        }
                    }
                }else{
                    msg = 'Error: Please select csv file only!';
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        if(uploadLog != null) {
            if(uploadLog.id != null) {
                uploadLog.EUR_CRM_Number_of_records__c = numberOfRecordsInserted;
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
    
        // Get the list of all current Account-OP mappings associated with the 
        List<EUR_CRM_ObjPromo__c> objPromoList = [SELECT EUR_CRM_Status__c,
                                                        (SELECT Id, EUR_CRM_Account__c, EUR_CRM_Account__r.EUR_CRM_External_ID__c, EUR_CRM_Do_Not_Reactivate__c 
                                                        FROM EUR_CRM_O_P_Account_Mappings__r)
                                                 FROM EUR_CRM_ObjPromo__c 
                                                 WHERE Id =: (ID)currentPageURL];

        if(objPromoList.size() > 0) {
            strOpStatus = !objPromoList.isEmpty() ? objPromoList[0].EUR_CRM_Status__c : '';
            // Set to hold the existing Account
            existingAccountSet = new Set<String>();
            // Map to hold the existing Account to acc-Op Mappings
            opAccMappingMap = new Map<String, EUR_CRM_ObjPromo_Account_Mapping__c>();

            for(EUR_CRM_ObjPromo_Account_Mapping__c mapping : objPromoList[0].EUR_CRM_O_P_Account_Mappings__r){
                existingAccountSet.add(mapping.EUR_CRM_Account__r.EUR_CRM_External_ID__c);
                opAccMappingMap.put(String.valueOf(mapping.EUR_CRM_Account__r.EUR_CRM_External_ID__c), mapping);
            }
            System.debug(opAccMappingMap);
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
    private static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
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
        public boolean hasErrors { get { return errorMsgs.size()>0; }}
        
        public row(sObject obj){
            sObj = obj;            
        }
        
        public row(sObject obj, string parentField, string parentID){
            sObj = obj;
            sObj.put(parentField,parentID);
        }
        public void addError(string errMsg){
            errorMsgs.add( errMsg);
        }
    }
}