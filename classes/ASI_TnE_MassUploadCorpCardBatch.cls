/*********************************************************************************
    * Name: ASI_TnE_MassUploadCorpCardBatch
    * Description: Class for uploading .csv files by batch.
    *
    * Version History
    * 2015-03-02        Laputa      Create
*********************************************************************************/ 
global class ASI_TnE_MassUploadCorpCardBatch implements Database.Batchable<sObject>, Database.Stateful{

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
    global Set<String> mccGroupSet;
    
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
    
    private Integer rowCount;
    private Integer colCount;

    global ASI_TnE_MassUploadCorpCardBatch(String ObjAPIName, String parentID, String parentField, String fields, String fieldsLabel, String lookupEXID, String recordtypeName, 
        string defaultValues, string currentPageURL, string AttID, string recEXID, string recEXIDcol, string parentObjectAPIName, string ParentObjectUploadMsg,
        boolean upsertMode, boolean emailNotification , boolean opt_allOrNone){
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

        mccGroupSet = new Set<String>();
        List<ASI_TnE_Corp_Card_MCC_Account_Mapping__c> mccAccountMappingList = [SELECT ASI_TnE_MCC_Group__c FROM ASI_TnE_Corp_Card_MCC_Account_Mapping__c];
        for(ASI_TnE_Corp_Card_MCC_Account_Mapping__c mccAccountMapping : mccAccountMappingList) {
            mccGroupSet.add(mccAccountMapping.ASI_TnE_MCC_Group__c);
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
                            // Start Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
                            Row r = new row(ObjType.newSObject());
                            // End Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
                            
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
                                            if((labelname == 'charge date' || labelname == 'statement date') && (LS[MFieldPos.get(labelname)] == null || LS[MFieldPos.get(labelname)] == '')){
                                                r.addError(Labelname + ': Required field is missing');
                                                hasError = true;
                                            }else{
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
                                            }
                                        }else if(tempFieldType=='double' ||
                                                tempFieldType=='percent' ||
                                                tempFieldType=='currency'){
                                            if(labelname == 'amount' && (LS[MFieldPos.get(labelname)] == null || LS[MFieldPos.get(labelname)] == '')){
                                                r.addError(Labelname + ': Required field is missing');
                                                hasError = true;
                                            }else{
                                                try{
                                                    r.sObj.put(fieldname, decimal.valueof(LS[MFieldPos.get(labelname)]));
                                                }catch(exception e){
                                                    r.addError(labelname + ': ' + e.getMessage());
                                                    hasError = true;
                                                }
                                            }
                                        }else{
                                            if((labelname == 'card number' || labelname == 'submitted currency' || labelname == 'supplier name') && 
                                                (LS[MFieldPos.get(labelname)] == null || LS[MFieldPos.get(labelname)] == '')){
                                                
                                                r.addError(Labelname + ': Required field is missing');
                                                hasError = true;
                                            } else if(recordtypeName == 'ASI TnE HK Corp Card Upload' && 
                                                      labelname == 'mcc group' && 
                                                      !mccGroupSet.contains(LS[MFieldPos.get(labelname)])) {
                                                r.addError(Labelname + ': MCC Group not found');
                                                hasError = true;
                                            }else{
                                                try{
                                                    r.sObj.put(fieldname, LS[MFieldPos.get(labelname)]);
                                                }catch(exception e){
                                                    r.addError(labelname + ': ' + e.getMessage());
                                                    hasError = true;
                                                }
                                            }
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
                        list<sObject> lRecInsert = new list<sobject>();
                        if(!hasError){
                            for(Row r : LInputRow){
                                if(!r.hasErrors){
                                    lRecInsert.add(r.sObj);
                                }
                                system.debug('r.hasErrors ************************************** ' + r.hasErrors);
                                system.debug('r OBJECT ***************************** ' + r);
                            }
                            System.debug('LInputRow *********************** ' + LInputRow);
                            if(lRecInsert != null && lRecInsert.size()>0){
                                try{
                                    Set<String> duplicateUpload = new Set<String>();
                                    Set<String> noCorpCardMapUpload = new Set<String>();
                                    List<Database.upsertResult> uResults = new List<Database.upsertResult>();
                                    
                                    // Hard Code for Casting before upsert
                                    if(ObjAPIName == 'ASI_TnE_Corp_Card_Statement_Upload__c'){
                                        List<ASI_TnE_Corp_Card_Statement_Upload__c> LUpsert = new List<ASI_TnE_Corp_Card_Statement_Upload__c>();
                                        Integer randomKey = lRecInsert.size();
                                        for(sObject s : lRecInsert){
                                            ASI_TnE_Corp_Card_Statement_Upload__c item = (ASI_TnE_Corp_Card_Statement_Upload__c)s;
                                            LUpsert.add(item);
                                        }
                                        
                                        List<String> cardNum = new List<String>();
                                        List<Date> sDate = new List<Date>();
                                        Set<String> cardNumMap = new Set<String>();
                                        for(ASI_TnE_Corp_Card_Statement_Upload__c up :LUpsert){
                                            cardNum.add(up.ASI_TnE_Card_Number__c);
                                            sDate.add(up.ASI_TnE_Statement_Date__c);
                                            if(up.ASI_TnE_Card_Number__c != null) {
                                                cardNumMap.add(up.ASI_TnE_Card_Number__c);
                                            }
                                        }
                                        for(ASI_TnE_Corp_Card_Statement_Upload__c uState: [Select Id,ASI_TnE_Card_Number__c,ASI_TnE_Statement_Date__c 
                                                                                            From ASI_TnE_Corp_Card_Statement_Upload__c
                                                                                            Where ASI_TnE_Card_Number__c IN: cardNum
                                                                                            AND ASI_TnE_Statement_Date__c IN: sDate]){
                                            String cCard_sDate = uState.ASI_TnE_Card_Number__c + '~' + String.ValueOf(uState.ASI_TnE_Statement_Date__c);
                                            duplicateUpload.add(cCard_sDate);
                                        }
                                        
                                        List<ASI_TnE_Corp_Card_Employee_Mapping__c> corpCardMappingList = [SELECT ID, Name, ASI_TnE_Card_Number_1__c, ASI_TnE_Card_Number_2__c 
                                                                                                        FROM ASI_TnE_Corp_Card_Employee_Mapping__c 
                                                                                                        WHERE ASI_TnE_Card_Number_1__c IN : cardNumMap 
                                                                                                        OR ASI_TnE_Card_Number_2__c IN : cardNumMap];
                                        
                                        Map<String, ID> corpCardMappingMap = new Map<String, ID>();

                                        for(ASI_TnE_Corp_Card_Employee_Mapping__c corpCard : corpCardMappingList) {
                                            if(cardNumMap.contains(corpCard.ASI_TnE_Card_Number_1__c) && corpCard.ASI_TnE_Card_Number_1__c != null) {
                                                corpCardMappingMap.put(corpCard.ASI_TnE_Card_Number_1__c, corpCard.id);
                                            }

                                            if(cardNumMap.contains(corpCard.ASI_TnE_Card_Number_2__c) && corpCard.ASI_TnE_Card_Number_2__c != null) {
                                                corpCardMappingMap.put(corpCard.ASI_TnE_Card_Number_2__c, corpCard.id);
                                            }
                                        }
                                        
                                        
                                        if(duplicateUpload.size() < 1){
                                            System.debug('ObjType.getDescribe().fields.getMap().get(recEXIDcol)' + ObjType.getDescribe().fields.getMap().get(recEXIDcol)); 
                                            for(ASI_TnE_Corp_Card_Statement_Upload__c up :LUpsert){
                                                if(corpCardMappingMap.containsKey(up.ASI_TnE_Card_Number__c)) {
                                                    up.ASI_TnE_Corp_Card_Employee_Mapping__c = corpCardMappingMap.get(up.ASI_TnE_Card_Number__c);
                                                } else {
                                                    noCorpCardMapUpload.add(up.ASI_TnE_Card_Number__c);
                                                }
                                            }
                                            if(noCorpCardMapUpload.size() < 1) { 
                                                uResults = database.upsert(LUpsert,ObjType.getDescribe().fields.getMap().get(recEXIDcol),opt_allOrNone);
                                                System.debug(LUpsert);
                                            }
                                        }
                                    }
                                    
                                    integer succInsert = 0;
                                    integer succUpdate = 0;
                                    string validationErrorText = '';
                                    integer rowNo = 0;
                                    for(Database.upsertResult res:uResults){
                                        rowNo ++;
                                        if(res.isSuccess()){
                                            if(res.isCreated()){
                                                System.debug('Created record ID ' + res.getId() + '.');
                                                succInsert ++;
                                            }else{
                                                System.debug('Updated record ID ' + res.getId() + '.');
                                                succUpdate ++;
                                            }
                                        }else{
                                            if(res.getErrors().size() > 0){
                                                System.debug(res.getErrors()[0].getMessage());
                                                validationErrorText += 'Row' + String.valueof(rowNo)+': ' + res.getErrors()[0].getMessage();
                                            }
                                        }
                                    }
                                    msg = '<div style="height: 25px;"><img src="/img/msg_icons/confirm16.png" style="vertical-align: middle;"/> <span style="color:green; font-weight: bold; vertical-align: middle;"> Import Completed! </span></div>';
                                    msg += '<div style="color:green;"> ' + string.valueof(succInsert) + ' record(s) created. </div>';
                                    msg += '<div style="color:blue;">Please review the uploaded Corp Card Statements to verify the record(s) by clicking the \'View Report\' link.</div>';
                                    
                                    String errorText = '';
                                    String errorExt = '';
                                    if(duplicateUpload.size() > 0){
                                        msg = '';
                                        errorText = '<div><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Import Failed! </span></div>';
                                        errorExt = '<div style="color:blue;">Upload failed due to duplicate Card number and Statement date.<br/>';
                                        errorExt += '<div style="color:blue;">Please check your email to see the full list of Statements with errors.';
                                    }
                                    
                                    if(noCorpCardMapUpload.size() > 0) {
                                        msg = '';
                                        errorText = '<div><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Import Failed! </span></div>';
                                        errorExt = '<div style="color:blue;">Upload failed due to some records with missing Corp Card Mapping.<br/>';
                                        errorExt += '<div style="color:blue;">Please check your email to see the full list of Statements with errors.';
                                    }
                                    
                                    messageDisplayed = msg + errorText + errorExt;
                                    for(Row r : LInputRow){
                                        if(r.hasErrors){
                                            for(string errorMsg :r.errorMsgs){
                                                errorText += 'Row' + String.valueof(r.rowNumber)+': ' + errorMsg;
                                            }
                                        }
                                    }
                                    if(duplicateUpload.size() > 0){
                                        errorText += '<div style="color:blue;">The following Card No. below failed to Upload due to duplicate Card number and Statement date.<ul>';
                                        for(String cn :duplicateUpload){
                                            String cCard = cn.split('~')[0];
                                            String sDate = cn.split('~')[1];
                                            errorText += '<li>' + cCard + ' with Statement date ' + sDate + '</li>';
                                        }
                                        errorText += '</ul>';
                                    }
                                    
                                    if(noCorpCardMapUpload.size() > 0){
                                        errorText += '<div style="color:blue;">The following Card No. below failed to Upload due to no Corp Card Employee Mapping.<ul>';
                                        for(String cn :noCorpCardMapUpload){
                                            errorText += '<li>' + cn + '</li>';
                                        }
                                        errorText += '</ul>';
                                    }
                                    
                                    if(errorText!='')
                                        msg += errorText;
                                    resultTexts.put(att.Id, msg);
                                    LAttUpdate.add(att);
                                    sObject tempParent = ParentObjType.newSObject();
                                    tempParent.put('id',att.parentid);
                                    tempParent.put(ParentObjectUploadMsg,att.description + '\n' + msg);
                                    LParentObj.add(tempParent);
                                }catch(dmlexception de){
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
                                }catch(exception e){
                                    system.debug('error'+e);
                                    hasError = true;
                                    LInputRow[0].addError(e.getMessage());
                                    resultTexts.put(att.Id, resultTexts.get(att.Id)+'\n'+e.getMessage());
                                    LErrorRows.add(LInputRow[0]);
                                    msg = '';
                                    LAttUpdate.add(att);
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
    }
    
    public void init(){
        ObjType = Schema.getGlobalDescribe().get(ObjAPIName);
        ParentObjType = Schema.getGlobalDescribe().get(parentObjectAPIName);
        LFieldAPIName = fields.toLowerCase().split(',',0);
        LFieldLabel = fieldsLabel.toLowerCase().split(',',0);
        if([select id from recordType where name = :recordtypeName and SobjectType = :ObjAPIName].size()>0){
            recordtypid = [select id from recordType where name = :recordtypeName and SobjectType = :ObjAPIName].id;
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