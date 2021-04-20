/*********************************************************************************
    * Name: ASI_BRD_Generic_UploadAccBatch
    * Description: Class for uploading .csv files by batch.
    *
    * Version History
    * March 9,2016        Laputa      Create
*********************************************************************************/ 
global class ASI_BRD_Generic_UploadAccBatch implements Database.Batchable<sObject>, Database.Stateful{
    global final String ObjAPIName = 'Account';
    global final String fields;
    global final String fieldsLabel;
    global final String lookupEXID;
    global final String recordtypeName;
    global final String AttID;
    global final string parentObjectAPIName {set;get;}
    global final string ParentObjectUploadMsg {set;get;}
    global final boolean upsertMode {set;get;}
    global final boolean opt_allOrNone {set;get;}
    global final boolean emailNotification {set;get;}
    global List<Attachment> LAttUpdate;
    global final boolean isLux{set;get;}
    
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
    public boolean hasError {set;get;}
    public string msg {set;get;}
    private id recordtypid;
    
    private Integer rowCount;
    private Integer colCount;

    global ASI_BRD_Generic_UploadAccBatch(String fields, String fieldsLabel, String recordtypeName, 
        string AttID, string parentObjectAPIName, string ParentObjectUploadMsg,
        boolean upsertMode, boolean opt_allOrNone,boolean isLux){
        this.fields = fields;
        this.fieldsLabel = fieldsLabel;
        this.lookupEXID = lookupEXID;
        this.recordtypeName = recordtypeName;
        this.AttID = AttID;
        this.parentObjectAPIName = parentObjectAPIName;
        this.ParentObjectUploadMsg = ParentObjectUploadMsg;
        this.upsertMode = upsertMode;
        this.emailNotification = emailNotification;
        this.opt_allOrNone = opt_allOrNone;
        this.isLux = isLux;
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
                        LHeader = parsedCSV[0]; 
                        //Remove top 3 rows                 
                        parsedCSV.remove(0);
                        system.debug(LHeader);
                        integer i = 0;
                        MFieldPos = new map<string,integer>();
                        for(string h : LHeader){
                            MFieldPos.put(h.toLowerCase().trim(),i);
                            i++;
                        }
                        
                        LInputRow = new list<Row>();
                        Integer rowNumber = 1;
                        Map<string,string> MFieldType = new map<string,string>();
                        for(string fieldname : LFieldAPIName){
                            MFieldType.put(fieldname,ObjType.getDescribe().fields.getMap().get(fieldname.trim()).getDescribe().getType().name().toLowerCase());
                        }
                        System.debug('checkpoint 1');
                        for(List<String> LS : parsedCSV){
                            Row r = new row(ObjType.newSObject());
                            System.debug('checkpoint 2');
                            if(recordtypid != null){
                                r.sObj.put('recordtypeid',recordtypid);
                            }
                            Integer inputCol = 0;
                            for(string fieldname : LFieldAPIName){
                                string labelname = MAPINameLabel.get(fieldname);
                                if(MFieldPos.containsKey(labelname)){
                                    if(MFieldType.containsKey(fieldname)){
                                        string tempFieldType = MFieldType.get(fieldname);
                                        if(tempFieldType=='date'){
                                            string dateText = LS[MFieldPos.get(labelname)];
                                            if(dateText.contains('/') || dateText.contains('-') || dateText.length()!=8){
                                                try{
                                                    r.sObj.put(fieldname, date.valueof(dateText));
                                                    date.valueof(dateText).addMonths(1);
                                                }catch(exception e){
                                                    r.addError(Labelname + ': ' + e.getMessage());
                                                    hasError = true;
                                                }
                                            }else{
                                                r.sObj.put(fieldname, date.newInstance(integer.valueOf(dateText.subString(0,4)), integer.valueOf(dateText.subString(4,6)), integer.valueOf(dateText.subString(6,8))));
                                            }
                                        }else if(tempFieldType=='double' ||
                                                tempFieldType=='percent' ||
                                                tempFieldType=='currency'){
                                            try{
                                                r.sObj.put(fieldname, decimal.valueof(LS[MFieldPos.get(labelname)]));
                                            }catch(exception e){
                                                r.addError(labelname + ': ' + e.getMessage());
                                                hasError = true;
                                            }
                                        }else if(tempFieldType=='boolean'){
                                            try{
                                                System.debug('checkpoint 2,9'); 
                                                r.sObj.put(fieldname, boolean.valueOf(LS[MFieldPos.get(labelname)]));
                                            }catch(exception e){
                                                r.addError(labelname + ': ' + e.getMessage());
                                                hasError = true;
                                            }
                                        }else{
                                            try{
                                                System.debug('checkpoint 3');
                                                r.sObj.put(fieldname, LS[MFieldPos.get(labelname)]);
                                            }catch(exception e){
                                                r.addError(labelname + ': ' + e.getMessage());
                                                hasError = true;
                                            }
                                        }
                                    }
                                }
                            }
                            r.rowNumber = rowNumber++;
                            if(r.hasErrors){
                                LErrorRows.add(r);
                            }
                            LInputRow.add(r);
                        }
                        list<sObject> lRecInsert = new list<sobject>();
                        if(!hasError){
                            for(Row r : LInputRow){
                                if(!r.hasErrors){
                                    lRecInsert.add(r.sObj);
                                    System.debug('checkpoint 4');
                                }
                            }
                            if(lRecInsert != null && lRecInsert.size()>0){
                                try{
                                    List<Database.SaveResult> uResults = new List<Database.SaveResult>();
                                    // Hard Code for Casting before upsert
                                    if(ObjAPIName == 'Account'){
                                        List<Account> LUpsert = new List<Account>();
                                        for(sObject s : lRecInsert){
                                            System.debug('checkpoint 4.5');
                                            Account item = (Account)s;
                                            item.ASI_BRD_Acquired_By__pc = item.ASI_BRD_Acquired_By__pc == 'Perrier-Jouet' ? 'Perrier-Jouët' : item.ASI_BRD_Acquired_By__pc;
                                            LUpsert.add(item);
                                        }
                                        System.debug('checkpoint 5: ' + isLux);
                                        //Process validation logic here
                                        Boolean validateSuccess = true;
                                        List<String> existEmailList = new List<String>();
                                        List<String> existPhoneList = new List<String>();
                                        List<String> existBusinessList = new List<String>();
                                        List<String> existMobileList = new List<String>();
                                        Set<Account> duplicateAccEmailList = new Set<Account>();
                                        Set<Account> duplicateAccPhoneList = new Set<Account>();
                                        Id profileId = userinfo.getProfileId();
                                        Profile p = [Select Name From Profile Where Id = :profileId]; 
                                        for(Account acc:LUpsert){
                                            System.debug('checkpoint 6: ' + acc);
                                            //check mandatory fields for uploading luxury accounts
                                            if(isLux && 
                                                        (acc.Salutation == null || acc.Salutation == '' || 
                                                         acc.FirstName == null || acc.FirstName == '' || 
                                                         acc.LastName == null || acc.LastName == '' ||
                                                         acc.PersonEmail == null || acc.PersonEmail == '' ||
                                                         acc.ASI_LUX_Gender__c == null || acc.ASI_LUX_Gender__c == '' ||
                                                         acc.ASI_LUX_Profile__c == null || acc.ASI_LUX_Profile__c == '' ||
                                                         acc.ASI_LUX_Occasion_at_First_Meeting__c == null || acc.ASI_LUX_Occasion_at_First_Meeting__c == '' || 
                                                         acc.ASI_BRD_Salesforce_Campaign_Reference__pc == null || acc.ASI_BRD_Salesforce_Campaign_Reference__pc == '' ||
                                                         acc.ASI_LUX_Preferred_Contact_Number__c == null || acc.ASI_LUX_Preferred_Contact_Number__c == '' ||
                                                         acc.ASI_LUX_Preferred_Language_1__c == null || acc.ASI_LUX_Preferred_Language_1__c == '' ||
                                                         acc.ASI_BRD_Country_of_Residence__pc == null || acc.ASI_BRD_Country_of_Residence__pc == '' ||
                                                         acc.ASI_BRD_Primary_Market__pc == null || acc.ASI_BRD_Primary_Market__pc == '' ||
                                                         acc.ASI_LUX_Membership_Category__c == null || acc.ASI_LUX_Membership_Category__c == '' )){
                                                System.debug('checkpoint 6.5');
                                                messageDisplayed = 'Fail - No record is created\nThere are accounts in your CSV file with missing mandatory data. Please review your data.';
                                                validateSuccess = false;
                                                break;
                                            }
                                            //check mandatory fields for uploading generic brand accounts                                            
                                            if(!isLux && (acc.Salutation == null || acc.Salutation == '' ||
                                                          acc.FirstName == null || acc.FirstName == '' || 
                                                          acc.LastName == null || acc.LastName == '' || 
                                                          acc.PersonEmail == null || acc.PersonEmail == '' ||
                                                          acc.ASI_LUX_Gender__c == null || acc.ASI_LUX_Gender__c == '' || 
                                                          acc.ASI_LUX_Occasion_at_First_Meeting__c == null || acc.ASI_LUX_Occasion_at_First_Meeting__c == '' || 
                                                          acc.ASI_BRD_Salesforce_Campaign_Reference__pc == null || acc.ASI_BRD_Salesforce_Campaign_Reference__pc == '' || 
                                                          acc.ASI_LUX_Preferred_Language_1__c == null || acc.ASI_LUX_Preferred_Language_1__c == '' ||
                                                          acc.ASI_BRD_Country_of_Residence__pc == null || acc.ASI_BRD_Country_of_Residence__pc == '' ||
                                                          acc.ASI_BRD_Primary_Market__pc == null || acc.ASI_BRD_Primary_Market__pc == ''||
                                                          acc.ASI_BRD_Acquired_By__pc == null || acc.ASI_BRD_Acquired_By__pc == '')){                                                         
                                                System.debug('checkpoint 7');
                                                messageDisplayed = 'Fail - No record is created\nThere are accounts in your CSV file with missing mandatory data. Please review your data.';
                                                validateSuccess = false;
                                                break;
                                            }
                                            //for duplicate email checking
                                            if(acc.PersonEmail != null && acc.PersonEmail != '' && acc.ASI_BRD_Ignore_Matching_Records__pc != true && !p.Name.contains('Marketo Sync')){
                                                existEmailList.add(acc.PersonEmail);
                                            }
                                            if(acc.PersonMobilePhone != null && acc.PersonMobilePhone != '' && acc.ASI_BRD_Ignore_Matching_Records__pc != true && !p.Name.contains('Marketo Sync')){
                                                existMobileList.add(acc.PersonMobilePhone);
                                            }
                                        }
                                        if(validateSuccess){
                                            List<Account> existAccList = [Select LastName,
                                                                                 FirstName,
                                                                                 personEmail,
                                                                                 ASI_LUX_Email_Business__c,
                                                                                 Phone,
                                                                                 PersonMobilePhone 
                                                                          From   Account 
                                                                          Where (personEmail in:existEmailList /*OR ASI_LUX_Email_Business__c in :existBusinessList OR ASI_BRD_Phone_Business__pc In :existPhoneList*/ OR PersonMobilePhone In :existMobileList) AND RecordTypeId = :recordtypid 
                                                                          Limit 10];

                                            if(existAccList.size() > 0){
                                                System.debug('checkpoint 8');
                                                validateSuccess = false;
                                                messageDisplayed = 'Fail - No record is created: \n';
                                                
                                                for(Account acc:LUpsert){
                                                    for(Account existAcc:existAccList){
                                                        if(acc.PersonEmail != null && acc.PersonEmail != '' && acc.PersonEmail == existAcc.PersonEmail){
                                                            if(!duplicateAccEmailList.contains(acc)){
                                                                duplicateAccEmailList.add(acc);
                                                            }
                                                        }
                                                        if(acc.PersonMobilePhone != null && acc.PersonMobilePhone != '' && acc.PersonMobilePhone == existAcc.PersonMobilePhone){
                                                            if(!duplicateAccPhoneList.contains(acc)){
                                                                duplicateAccPhoneList.add(acc);
                                                            }
                                                        }
                                                    }      
                                                }
                                                
                                                if(duplicateAccEmailList.size() > 0){
                                                    messageDisplayed += 'The following records are duplicated in Email: \n';
                                                }
                                                for(Account acc:duplicateAccEmailList){
                                                    messageDisplayed += acc.FirstName + ' ' + acc.LastName + ' ' + acc.PersonEmail + '\n';
                                                }
                                                if(duplicateAccEmailList.size() > 0){
                                                    messageDisplayed += '\n';
                                                }
                                                if(duplicateAccPhoneList.size() > 0){
                                                    messageDisplayed += 'The following records are duplicated in Mobile: \n';
                                                }
                                                for(Account acc:duplicateAccPhoneList){
                                                    messageDisplayed += acc.FirstName + ' ' + acc.LastName + ' ' + acc.PersonMobilePhone + '\n';
                                                }
                                            }   
                                        }
                                        LAttUpdate.add(att);
                                        if(validateSuccess){
                                            uResults = database.insert(LUpsert,opt_allOrNone);
                                            System.debug('checkpoint 9');
                                        }
                                        System.debug('checkpoint 9.5');
                                    }
                                    string validationErrorText = '';
                                    integer rowNo = 0;
                                    for(Database.SaveResult res:uResults){
                                        rowNo ++;
                                        if(res.getErrors().size() > 0){
                                            System.debug(res.getErrors()[0].getMessage());
                                            validationErrorText += 'Row' + String.valueof(rowNo)+': ' + res.getErrors()[0].getMessage();
                                            break;
                                        }
                                    }
                                    if(validationErrorText != '' && validationErrorText != null){
                                        System.debug('checkpoint 10: ' + validationErrorText);
                                        messageDisplayed = validationErrorText;
                                    }
                                    //LAttUpdate.add(att);
                                    //sObject tempParent = ParentObjType.newSObject();
                                    //tempParent.put('id',att.parentid);
                                    //tempParent.put(ParentObjectUploadMsg,att.description + '\n' + msg);
                                    //LParentObj.add(tempParent);
                                }catch(dmlexception de){
                                    hasError = true;
                                    
                                    for(integer j =0;j<de.getNumDml();j++){
                                        LInputRow[j].addError(de.getDmlMessage(j));
                                        resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+de.getDmlMessage(j));
                                        messageDisplayed += de.getDmlMessage(j) + '\n';
                                        LErrorRows.add(LInputRow[j]);
                                        break;
                                    }
                                    msg = '';
                                    
                                    //LAttUpdate.add(att);
                                    sObject tempParent = ParentObjType.newSObject();
                                    tempParent.put('id',att.parentid);
                                    tempParent.put(ParentObjectUploadMsg,  resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
                                    LParentObj.add(tempParent);
                                }catch(exception e){
                                    system.debug('error'+e);
                                    hasError = true;
                                    LInputRow[0].addError(e.getMessage());
                                    resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+e.getMessage());
                                    LErrorRows.add(LInputRow[0]);
                                    msg = '';
                                    messageDisplayed += e.getMessage();
                                    //LAttUpdate.add(att);
                                    sObject tempParent = ParentObjType.newSObject();
                                    tempParent.put('id',att.parentid);
                                    tempParent.put(ParentObjectUploadMsg,  resultTexts.get(att.Id).length()>32000? resultTexts.get(att.Id).substring(0,32000): resultTexts.get(att.Id));
                                    LParentObj.add(tempParent);
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
                                messageDisplayed = errorText;
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
                                        if(errorText!='') errorText += '<div style="color:red;">';
                                        errorText += '&nbsp;&nbsp;&nbsp;Row' + String.valueof(r.rowNumber)+': ' + errorMsg;
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
                            if(messageDisplayed.length() >= 500){
                                messageDisplayed = messageDisplayed.subString(0,499);
                                system.debug('checkpoint 11: ' + messageDisplayed);
                            }
                            att1.description = messageDisplayed;
                        }
                        update LAttUpdate;
                    }
                    if(LParentObj != null && LParentObj.size()>0){
                        update LParentObj;
                    }
                }else{
                    msg = 'Error: Please select csv file only!';
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    public void init(){
        ObjType = Schema.getGlobalDescribe().get('Account');
        ParentObjType = Schema.getGlobalDescribe().get(parentObjectAPIName);
        LFieldAPIName = fields.toLowerCase().split(',',0);
        LFieldLabel = fieldsLabel.toLowerCase().split(',',0);
        recordtypid = Global_RecordTypeCache.getRtId('Account' + recordtypeName);
        MAPINameLabel = new map<string,string>();
        for(integer i=0;i<LFieldAPIName.size();i++){
            MAPINameLabel.put(LFieldAPIName[i].toLowerCase().trim(),LFieldLabel[i].toLowerCase().trim());
        }
        hasError = false;
        msg = '';
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
        
        private list<string> m_errorMsgs = new list<string>();
        public list<string> errorMsgs { get { return m_errorMsgs; }}
        public boolean hasErrors { get { return errorMsgs.size()>0; }}
        
        // Start Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
        public row(sObject obj){
            sObj = obj;            
        }
        // End Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
        
        public row(sObject obj, string parentField, string parentID){
            sObj = obj;
            sObj.put(parentField,parentID);
        }
        public void addError(string errMsg){
            errorMsgs.add( errMsg);
        }
    }
}