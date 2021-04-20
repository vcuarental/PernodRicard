public class ASI_MFM_CN_ReceiptMassUploadCTRL {
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
    public list<Row> LOutputRow {set;get;} 
    public list<Row> LErrorRows {set;get;} 
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get 
    { 
        if (dummyVar != true) {
            init();
        } 
        return dummyVar; } 
                             set; 
                            }
    public string objName {set;get;} 
    public string nameFile {set;get;}
    public integer fileSize {set;get;}
    
    public string Msg {set;get;}
    
    public Blob contentFile {set;get;}
    
    public string currentPageURLOutput {set;get;}
    public boolean hasError {set;get;}
    public string msgEmail {set;get;}
    
    private Integer rowCount;
    private Integer colCount;
    
    public Id BatchId {get;set;}
    public Id AttId {get;set;}
    
    public void init(){
        msgEmail = 'Result should appear here...';
        if(emailNotification){
            msgEmail = 'Email Notification will be sent when upload process is completed';
        }
    }
    
    public void uploadCSVByBatch(){
        System.debug('fileSize'+fileSize);
        if(fileSize <= 5242880){ //Fix for 5MB size limit
            //20160506, added by Leo
            if(currentPageURL == '' || currentPageURL == null){
                //Mass upload log for page without header
                ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
                
                insert uploadLog;
                if(uploadLog.ASI_MFM_Error_Message__c != null)
                {
                    uploadLog.ASI_MFM_Error_Message__c = '';
                    update uploadLog;
                }
                currentPageURL = uploadLog.id;
            }
            //20160506, added by Leo
            
            if(namefile.toLowerCase().right(3)=='csv'){
                Attachment att = new Attachment(ParentId = currentPageURL, name = namefile, body=contentFile, ContentType ='text/plain; charset=GB2312');
                insert att;
                msg = 'executeBatch';
                BatchId = Database.executeBatch(new ASI_MFM_CN_ReceiptMassUpload(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
                                                                                 defaultValues, currentPageURL, att.id, recEXID, recEXIDcol, parentObjectAPIName, ParentObjectUploadMsg,
                                                                                 upsertMode, emailNotification, opt_allOrNone),1);
                AttId = att.id;
                msg = 'Batch Started';
            }
            else{
                msg = 'Error: Please select csv file only!';
            }
        }
        else{
            msg = 'Error: File too large';
        }
    }
    
    public string[] StatusMsgs {
        get {
            string s = msg==null? '': msg;
            if(BatchId!=null) {
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0) {
                    s = aajs[0].Status;
                    if(aajs[0].Status=='Completed' && AttId!=null) {
                        Attachment att = [SELECT Id, description FROM Attachment WHERE ID =:AttId];
                        if(att.description!=null)
                            s = att.description;
                    }
                }
            }
            return s.split('\n');
        }
    }
    
    public pageReference refreshPage(){
        system.debug(currentPageURL);
        return ApexPages.currentPage();
    }
    
    public void refreshPage2(){
        reloadNeeded = true;
        {
            currentPageUrlOutput = URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentPageUrl;
        }
        system.debug(ApexPages.currentPage().geturl());
    }
    
        public class Row{
        public Integer rowNumber {set;get;}
        public sObject sObj {set;get;}
        public string errorMsg {set;get;}
        
        // Start Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
        public row(sObject obj){
            sObj = obj;            
            errorMsg = '';
        }
        // End Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
        
        public row(sObject obj, string parentField, string parentID){
            sObj = obj;
            sObj.put(parentField,parentID);
            errorMsg = '';
        }
        public void addError(string errMsg){
            errorMsg = errMsg;
        }
    }
}