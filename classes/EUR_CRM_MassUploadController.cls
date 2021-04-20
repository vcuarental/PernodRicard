/*********************************************************************************
    * Name: EUR_CRM_MassUploadController
    * Description: Controller for EUR_CRM_MassUploadComponent. Upload .csv format file to specified object. Taken from ASI component
    *
    * Version History
    * 2015-08-27        Conrad Pantua Laputa      Create
*********************************************************************************/ 
public class EUR_CRM_MassUploadController {
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
    public EUR_CRM_MassUploadBatch massUploadBatch {set;get;}
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
    
    public EUR_CRM_MassUploadController(){
       isPublishReady = false;
    }
    
    public Boolean getIsUploadDisabled() {
        if(recordtypeName == 'EUR_ZA_OP_Account_Mapping'){
            if(objPromoHeaderStatus != 'Draft'){
                return true;
            }
        } else if(objPromoHeaderStatus == 'Deactivated') {
            return true;
        }
        
        return false;
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
            
            if(objPromoHeaderStatus == 'Draft'){
                List<EUR_CRM_ObjPromo_Account_Mapping__c> toDeleteOPAccounts = [select id from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c =: (ID)currentPageURL];
                List<EUR_CRM_ObjPromo_Target__c> toDeleteOPTargets = [select id from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: (ID)currentPageURL AND EUR_CRM_O_P_Target__c != null];
                    
                delete toDeleteOPAccounts;
                delete toDeleteOPTargets;
            }
            
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
                massUploadBatch = new EUR_CRM_MassUploadBatch(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
                    defaultValues, currentPageURL, att.id, recEXID, recEXIDcol, parentObjectAPIName, ParentObjectUploadMsg,
                    upsertMode, emailNotification, opt_allOrNone, uploadLog);
                
                BatchId = Database.executeBatch(massUploadBatch,1);
                
                AttId = att.id;
                msg = 'Batch Started';
            }else{
                    msg = 'Error: Please select csv file only!';
                }
        }else{
            msg = 'Error: File too large';
        }
    }
    
    public pageReference publishOpAccount () {
        //Check for Date Validation
        if(objPromoHeaderStatus.equalsIgnoreCase('ended')){
            Boolean blnAllowReactivate = true;
            if(objPromoHeader.EUR_CRM_Active_Start_Date__c < date.today()){
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_StartDate_Validation));
                blnAllowReactivate = false;
            }
            if(objPromoHeader.EUR_CRM_Active_End_Date__c < objPromoHeader.EUR_CRM_Active_Start_Date__c){
            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_EndDate_Validation));
                blnAllowReactivate = false;
            }
            if(objPromoHeader.EUR_CRM_Evaluation_Period_End_Date__c < objPromoHeader.EUR_CRM_Active_End_Date__c){
            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_EvalEndDate_Validation));
                blnAllowReactivate = false;
            }           
            if(!blnAllowReactivate){
                return null;
            } 
        }
        Map<Id,EUR_CRM_ObjPromo_Account_Mapping__c> relatedAcc = new Map<Id,EUR_CRM_ObjPromo_Account_Mapping__c>();
        List<EUR_CRM_ObjPromo_Account_Mapping__c> toUpdateOPAccounts = [SELECT Id, EUR_CRM_Account__c, EUR_CRM_Is_Published__c, EUR_CRM_Is_Active__c, EUR_CRM_Do_Not_Reactivate__c
                                                                       FROM EUR_CRM_ObjPromo_Account_Mapping__c 
                                                                       WHERE EUR_CRM_ObjPromo__c =: (ID)currentPageURL
                                                                       AND EUR_CRM_Do_Not_Reactivate__c = false];
        system.debug('Account Mapping: '+toUpdateOPAccounts);
        EUR_CRM_ObjPromo__c objec = [SELECT Id, EUR_CRM_Active_Start_Date__c
                                                FROM EUR_CRM_ObjPromo__c 
                                                WHERE id =: (ID)currentPageURL
                                                LIMIT 1];
        system.debug('Current ObjectPromo: '+objec);

        if(toUpdateOPAccounts!= null && toUpdateOPAccounts.size() > 0){
            for(EUR_CRM_ObjPromo_Account_Mapping__c opAcc : toUpdateOPAccounts) {
                opAcc.EUR_CRM_Is_Published__c = true;
                relatedAcc.put(opAcc.EUR_CRM_Account__c,opAcc);
                
                if(objec.EUR_CRM_Active_Start_Date__c > date.today()){
                    opAcc.EUR_CRM_Is_Active__c = false;
                }else{
                   opAcc.EUR_CRM_Is_Active__c = true; 
                }
                if(objPromoHeaderStatus.equalsIgnoreCase('ended')){
                    opAcc.EUR_CRM_Is_Active__c = true;
                }
            }
            List<EUR_CRM_Account__c> accounts = [SELECT Id,Name, EUR_CRM_Status__c FROM EUR_CRM_Account__c WHERE Id IN: relatedAcc.keyset()];
            system.debug('Selected Account: '+ accounts);

            for (EUR_CRM_Account__c acc:accounts){
                if(acc.EUR_CRM_Status__c != 'Active'){
                    delete toUpdateOPAccounts;//will only do once if inactive record found, delete all existing OP Mapping 
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.EUR_CRM_InactiveAccountSelected));
                    return null;
                    }    
            }


        system.debug('Account Mapping: '+toUpdateOPAccounts);
            EUR_CRM_ObjPromo__c obj = new EUR_CRM_ObjPromo__c(Id =(ID)currentPageURL);

                if(objec.EUR_CRM_Active_Start_Date__c > date.today()){
                    obj.EUR_CRM_Status__c = 'Published';
                } else{
                    obj.EUR_CRM_Status__c = 'Active';
                }

            if(objPromoHeaderStatus.equalsIgnoreCase('ended')){
               obj.EUR_CRM_Active_Start_Date__c = objPromoHeader.EUR_CRM_Active_Start_Date__c;
               obj.EUR_CRM_Active_End_Date__c = objPromoHeader.EUR_CRM_Active_End_Date__c;
               obj.EUR_CRM_Evaluation_Period_End_Date__c = objPromoHeader.EUR_CRM_Evaluation_Period_End_Date__c;
            }
            update obj;
            update toUpdateOPAccounts;
        }
        
        return new Pagereference('/' + currentPageURL);
    }
    
    public string[] StatusMsgs{
        get{
            string s = msg==null? '': msg;
            if(BatchId!=null){
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus, JobItemsProcessed  FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0){
                    s = '<span style="color: blue; font-weight: bold;">' + aajs[0].Status + '</span>';
                    if(aajs[0].Status=='Completed' && AttId!=null){
                        isPublishReady = true;
                        if(uploadLog != null) {
                            if(uploadLog.id != null) {
                                EUR_CRM_MassUploadLog__c uploadLog2 = [SELECT ID, Name, EUR_CRM_Number_of_records__c FROM EUR_CRM_MassUploadLog__c WHERE ID = :uploadLog.id ];
                                if(statusMessageCounter < 2) {
                                    s += '<span style="font-weight: bold;"> <br/> Waiting for Finish method to execute </span>';
                                }
                                else if(uploadLog2.EUR_CRM_Number_of_records__c == null ) {
                                    s += '<span style="font-weight: bold;"> <br/> Error Occured in CSV parsing. Please review the CSV file. </span>';
                                } else {
                                    s += '<span style="font-weight: bold;"> <br/> Number of Records Inserted: ' + uploadLog2.EUR_CRM_Number_of_records__c + '</span>';
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

    public PageReference refreshPage() {
        System.Debug('@@objPromoHeaderStatus:'+objPromoHeaderStatus);
        System.Debug('@@isPublishReady:'+isPublishReady);
        System.Debug('@@currentPageURL:'+currentPageURL);
        
        if(isPublishReady == true) {
            
            if(objPromoHeaderStatus == 'Active') {
                List<EUR_CRM_ObjPromo_Account_Mapping__c> linkedOPAccounts = [SELECT id, EUR_CRM_Account__c 
                                                                                FROM EUR_CRM_ObjPromo_Account_Mapping__c 
                                                                                WHERE EUR_CRM_ObjPromo__c =: (ID)currentPageURL                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
                                                                                ORDER BY Name];
                System.Debug('@@linkedOPAccounts:'+linkedOPAccounts);
                //Map<Id, EUR_CRM_ObjPromo_Account_Mapping__c> accountsToOPMap = new Map<Id, EUR_CRM_ObjPromo_Account_Mapping__c>();
                Set<Id> uniqueAccountIds = new Set<Id>();
                List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMappingToDelete = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
                
                for(EUR_CRM_ObjPromo_Account_Mapping__c opMap: linkedOPAccounts) {
                    if(!uniqueAccountIds.contains(opMap.EUR_CRM_Account__c)) {
                        uniqueAccountIds.add(opMap.EUR_CRM_Account__c);
                    } else {
                        opAccountMappingToDelete.add(opMap);
                    }
                }
                
                System.debug(opAccountMappingToDelete);
                
                delete opAccountMappingToDelete;
                Database.emptyRecycleBin(opAccountMappingToDelete);
            }
            
            String objPromoIdParam = '?ObjPromoId=' + ApexPages.currentPage().getParameters().get('ObjPromoId');

            // URL Manipulation to just only take the base URL
            String pageURL = ApexPages.currentPage().getUrl();
            pageURL = pageURL.substringBefore('?');
            pageURL += objpromoIdParam;

            PageReference pageRef = new PageReference(pageURL);
            pageRef.setRedirect(true);
            return pageRef;
        }

        return null;
    }
    
    
    public void refreshPage2(){
        reloadNeeded = true; 
        {
            currentPageUrlOutput = URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentPageUrl;
        }
    }
    
}