/*********************************************************************************
    * Name: EUR_CRM_MassUploadAccountController
    * Description: Controller for EUR_CRM_MassUploadComponent. Upload .csv format file to specified object. Taken from ASI component
    *
    * Version History
    * 2015-11-03        Kim Noceda      Create
*********************************************************************************/ 
public class EUR_CRM_MassUploadAccountController {
    //Attributes
    public string ObjAPIName {set;get;}
    public string parentID {set;get;}
    public string parentField {set;get;}
    public string fields {set;get;}
    public string fieldsLabel {set;get;}
    public string lookupEXID {set;get;}
    public string template {set;get;}
    public string report{set;get;}
    public string recordtypeName {set;get;}
    public string currentPageURL {set;get;}
    public boolean inlineVF {set;get;}
    public Boolean reloadNeeded {get; set;}
    public string defaultValues {set;get;}
    public string recEXID {set;get;}
    public string recEXIDcol {set;get;} 
    public string parentObjectAPIName {set;get;}
    public string ParentObjectUploadMsg {set;get;}
    public boolean upsertMode {set;get;}
    public boolean batchMode {set;get;}
    public boolean opt_allOrNone{set;get;}    
    public boolean emailNotification {set;get;}
    // To get the numberofrecordsinserted from the batchApex
    public EUR_CRM_MassUploadAccountBatch massUploadBatch {set;get;}
    public EUR_CRM_MassUploadLog__c uploadLog {set;get;}
    public boolean isPublishReady {get;set;}
    public EUR_CRM_ObjPromo__c objPromoHeader {get;set;}
    public String objPromoHeaderStatus {get;set;}
    
    public string objName {set;get;} 
    public string nameFile {set;get;}
    public integer fileSize {set;get;}
    
    public string Msg {set;get;}
    
    public Blob contentFile {set;get;}
    
    public string currentPageURLOutput {set;get;}
    private list<String> LFieldAPIName; 
    private list<String> LFieldLabel; 
    private map<string,string> MAPINameLabel;
    private map<string,integer> MFieldPos;
    private map<string,integer> MLookupFieldPos;
    private map<string,id> MRecTypeID; 
    public boolean hasError {set;get;}
    private id recordtypid;
    private list<string> LDefaultVales;
    private list<string> LDefaultValesHeader;
    
    private Integer rowCount;
    private Integer colCount;
    
    public Id BatchId {get;set;}
    public Id AttId {get;set;}
    
    public String country {get;set;}
    
    public String currencyStr {get;set;}

    public boolean isRedirectReady {get;set;}
    public boolean isUpload {get;set;}
    
    public EUR_CRM_MassUploadAccountController(){
       isPublishReady = false;
       isUpload = false;
       isRedirectReady = false;
    }
    
    // Iterator of retries for the status message 
    private Integer statusMessageCounter {get;set;}
    
    public void uploadCSVByBatch(){
        statusMessageCounter = 0;
        System.debug('fileSize'+fileSize);
        if(fileSize <= 5242880){ //Fix for 5MB size limit
            
            uploadLog = new EUR_CRM_MassUploadLog__c();
            insert uploadLog;
            
            if(currentPageURL == '' || currentPageURL == null){
                currentPageURL = uploadLog.id;
            }
            
            /*List<EUR_CRM_ObjPromo_Account_Mapping__c> toDeleteOPAccounts = [select id from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c =: (ID)currentPageURL];
            
            if(toDeleteOPAccounts!= null && toDeleteOPAccounts.size() > 0){
                delete toDeleteOPAccounts;
            }*/
            
            if(namefile.toLowerCase().right(3)=='csv'){
                Attachment att = new Attachment(ParentId = currentPageURL, name = namefile, body=contentFile, ContentType ='text/plain; charset=UTF-8');
                 
                insert att;
                System.debug(att.parentid + att.name);
                System.debug(ObjAPIName);
                System.debug(parentID);
                System.debug(parentField);
                System.debug(fields);
                System.debug(fieldsLabel);
                System.debug(lookupEXID);
                System.debug(recordtypeName);
                System.debug(defaultValues);
                System.debug(currentPageURL);
                System.debug(att.id);
                System.debug(recEXID);
                System.debug(recEXIDcol);
                System.debug(parentObjectAPIName);
                System.debug(ParentObjectUploadMsg);
                System.debug(upsertMode);
                System.debug(emailNotification);
                msg = 'executeBatch';
                massUploadBatch = new EUR_CRM_MassUploadAccountBatch(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
                    defaultValues, currentPageURL, att.id, recEXID, recEXIDcol, parentObjectAPIName, ParentObjectUploadMsg,
                    upsertMode, emailNotification, opt_allOrNone, uploadLog, true);
                
                BatchId = Database.executeBatch(massUploadBatch,1);
                
                AttId = att.id;
                msg = 'Batch Started';
            }else{
                    msg = 'Error: Please select csv file only!';
                }
        }else if(fileSize <= 0 || fileSize == null){
            msg = 'Error: No file chosen';
        } else {
            msg = 'Error: File too large';
        }
    }
    
    public void publishEvents () {
        
        massUploadBatch = new EUR_CRM_MassUploadAccountBatch(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
            defaultValues, currentPageURL, AttId, recEXID, recEXIDcol, parentObjectAPIName, ParentObjectUploadMsg,
            upsertMode, emailNotification, opt_allOrNone, uploadLog, false);
                
        BatchId = Database.executeBatch(massUploadBatch,1);
        isUpload = true;

    }
    
    public pageReference redirectRT () {
        /*List<EUR_CRM_ObjPromo_Account_Mapping__c> toUpdateOPAccounts = [select id, EUR_CRM_Is_Published__c from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c =: (ID)currentPageURL];
            
        if(toUpdateOPAccounts!= null && toUpdateOPAccounts.size() > 0){
            for(EUR_CRM_ObjPromo_Account_Mapping__c opAcc : toUpdateOPAccounts) {
                opAcc.EUR_CRM_Is_Published__c = true;
            }
             
            EUR_CRM_ObjPromo__c obj = new EUR_CRM_ObjPromo__c(id =(ID)currentPageURL,EUR_CRM_Status__c = 'Active' ); 
            update obj;
            update toUpdateOPAccounts;
        }
        
        return new Pagereference('/' + currentPageURL);*/
        
        EUR_CRM_Route_Template__c routTemplateRecord = [SELECT Id, EUR_CRM_Start_Date__c, EUR_CRM_Active__c FROM EUR_CRM_Route_Template__c WHERE Id = :(ID)currentPageURL];
        routTemplateRecord.EUR_CRM_Active__c = TRUE;
        routTemplateRecord.EUR_CRM_Last_Date_Populated__c = Date.Today();
        update routTemplateRecord;
        return new Pagereference('/' + currentPageURL);
    }
    
    public string[] StatusMsgs{
        get{
            string s = msg==null? '': msg;
            if(BatchId!=null){
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus, JobItemsProcessed  FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0){
                    //s = '<span style="color: blue; font-weight: bold;">' + aajs[0].Status + '</span>';
                    String inProgress = 'Upload';
                    if(isPublishReady == true){
                        inProgress = 'Publishing';
                    }
                    s = '<span style="color: blue; font-weight: bold;">' + inProgress + ' in Progress' + '</span>';
                    if(aajs[0].Status=='Completed' && AttId!=null){
                        s = '<span style="color: blue; font-weight: bold;">' + aajs[0].Status + '</span>';
                        //isPublishReady = true;
                        if(uploadLog != null) {
                            if(uploadLog.id != null) {
                                EUR_CRM_MassUploadLog__c uploadLog2 = [SELECT ID, Name, EUR_CRM_Number_of_records__c, EUR_CRM_Error_Message__c FROM EUR_CRM_MassUploadLog__c WHERE ID = :uploadLog.id ];
                                if(statusMessageCounter < 2) {
                                    //s += '<span style="font-weight: bold;"> <br/> Waiting for Finish method to execute </span>';
                                }
                                else if(uploadLog2.EUR_CRM_Number_of_records__c == null ) {
                                    isPublishReady = false;
                                    //s += '<span style="font-weight: bold;"> <br/> Error Occurred in CSV parsing. Please review the CSV file. </span>';
                                    s += '<span style="font-weight: bold;"> <br/> Error Occurred in CSV parsing. Please review the CSV file. ';
                                    s += uploadLog2.EUR_CRM_Error_Message__c;
                                } else {
                                    isPublishReady = true;
                                    if(isPublishReady == true && isUpload == true){
                                        isRedirectReady = true;
                                    }
                                    if(isPublishReady == true && isRedirectReady == false){
                                        s += '<span style="font-weight: bold;"> <br/> Number of Records to be Uploaded: ' + uploadLog2.EUR_CRM_Number_of_records__c + '</span>';
                                    }
                                    if(isRedirectReady == true){
                                        s += '<span style="font-weight: bold;"> <br/> Number of Records Inserted: ' + uploadLog2.EUR_CRM_Number_of_records__c + '</span>';
                                    }
                                }
                                statusMessageCounter++;
                            }
                        }
                        
                        Attachment att = [SELECT Id, description FROM Attachment WHERE ID =:AttId];
                        if(att.description!=null){
                            s = att.description;
                        }
                    }
                }   
            }
            return s.split('\n');
        }
    }
    
    
    public void refreshPage2(){
        reloadNeeded = true; 
        {
            currentPageUrlOutput = URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentPageUrl;
        }
    }
    
}