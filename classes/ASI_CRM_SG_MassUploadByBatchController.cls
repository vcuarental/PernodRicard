public with sharing class ASI_CRM_SG_MassUploadByBatchController {
    
    //Attributes
    public string ObjAPIName {set;get;}
    public string ActivateTime {set;get;}
    public string parentID {set;get;}
    public string parentField {set;get;}
    public string fields {set;get;}
    public string fieldsLabel {set;get;}
    public string requiredFields {set;get;}
    public string lookupEXID {set;get;}
    public string template {set;get;}
    public string PanelName {set;get;} 
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
    public string errorLog {set;get;}
    public string noOfLastRowToIgnore {set;get;}
    
    
    public boolean upsertMode {set;get;}
    public boolean batchMode {set;get;}
    public boolean opt_allOrNone{set;get;}    
    public boolean emailNotification {set;get;}
    public boolean containsHeader {set;get;}
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {init();} return dummyVar; } set; }
    
    
    public string objName {set;get;} 
    public string nameFile {set;get;}
    public integer fileSize {set;get;}
    
    public string Msg {set;get;}
    
    public Blob contentFile {set;get;}
    
    public string currentPageURLOutput {set;get;}
    private Schema.SObjectType ObjType;
    private list<String> LFieldAPIName; 
    private list<String> LFieldLabel; 
    private map<string,string> MAPINameLabel;
    private list<Row> LInputRow;
    public list<Row> LOutputRow {set;get;} 
    public list<Row> LErrorRows {set;get;} 
    private map<string,integer> MFieldPos;
    private map<string,integer> MLookupFieldPos;
    private transient map<string,id> MRecTypeID; 
    public boolean hasError {set;get;}
    public string msgEmail {set;get;}
    private id recordtypid;
    private list<string> LDefaultVales;
    private list<string> LDefaultValesHeader;
    
    private Integer rowCount;
    private Integer colCount;
    
    public Id BatchId {get;set;}
    public Id AttId {get;set;}
    private string HeaderId; 
    
    public ASI_CRM_SG_MassUploadByBatchController(){
      
    }

    
    public void init(){
        /*if(inlineVF){
            currentPageUrlOutput = currentPageUrl;
        }
        else*/
        msgEmail = 'Result should appear here...';
        if(emailNotification){
            msgEmail = 'Email Notification will be sent when upload process is completed<br/><br/>';
			if((ObjAPIName == 'ASI_TH_CRM_Actual_Offtake__c' && recordtypeName == 'ASI CRM SG Actual Offtake' && !defaultValues.contains('Type (Uploaded):Off-Trade'))){
				msgEmail = '<br/>' +
					'Please download the template to see the format. Please arrange to column by following order:<br/>' + 
					'Type (e.g. INV/INF)<br/> Code (e.g. U)<br/> Wholesaler Code<br/> Outlet Code<br/> G/L Date (format YYYYMMDD)<br/> SKU Code<br/> Invoice No.<br/> Quantity<br/><br/>' +
					msgEmail;
			} else
            if((ObjAPIName == 'ASI_TH_CRM_Actual_Offtake__c' && recordtypeName == 'ASI CRM SG Actual Offtake' && defaultValues.contains('Type (Uploaded):Off-Trade'))){
				msgEmail = '<br/>' +
					'Please download the template to see the format. <span style="color:red">Please also remove all double spaces.</span><br/>' + 
					msgEmail;
			} 
        }
        ObjType = Schema.getGlobalDescribe().get(ObjAPIName);
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
        for(RecordType r: [Select id, name, SobjectType from RecordType]){
            string key = r.SobjectType+r.name;
            key = key.toLowerCase();
            MRecTypeID.put(key,r.id);
        }
        
        hasError = false;
        //msg = '';
        //MRecTypeDefault = new Map<string,string>();
        LDefaultVales = new list<string>();
        LDefaultValesHeader = new list<string>();
        if(String.isNotBlank(defaultValues)){
            list<string> LDefaultValuePair = defaultValues.split(';',0);
            for(String s : LDefaultValuePair){
                list<string> l = s.split(':',0);
                LDefaultValesHeader.add(l[0]);
                LDefaultVales.add(l[1]);
            }
            //MRecTypeDefault.put()
        }
        
    }
    
    public void uploadCSVByBatch(){
        system.debug('See currentPageURL : '+currentPageURL );
        system.debug('See contentFile : '+contentFile );

        System.debug('fileSize'+fileSize);
        if(fileSize <= 5242880){ //Fix for 5MB size limit
            //init();
			/*
            if(currentPageURL == '' || currentPageURL == null || (ObjAPIName == 'ASI_MFM_Purchase_Request_Line__c' && recordtypeName == 'KR Purchase Request Line')||
             (ObjAPIName == 'ASI_MFM_Payment_Line_Item__c' && recordtypeName == 'KR Payment Line Item') ){
                if((ObjAPIName == 'ASI_MFM_Purchase_Request_Line__c' && recordtypeName == 'KR Purchase Request Line') || (ObjAPIName == 'ASI_MFM_Payment_Line_Item__c' && recordtypeName == 'KR Payment Line Item')){
                     HeaderId = currentPageURL;
                }else{
                    HeaderId='';
                }
               
                
                //Mass upload log for page without header
                ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
                insert uploadLog;
                currentPageURL = uploadLog.id;
            }
			*/
            if(currentPageURL == '' || currentPageURL == null){
                HeaderId='';
				String logId = '';
				if((ObjAPIName == 'ASI_TH_CRM_Actual_Offtake__c' && recordtypeName == 'ASI CRM SG Actual Offtake')){
                    ASI_CRM_ActualOfftakeHeader__c h = new ASI_CRM_ActualOfftakeHeader__c(
						recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_SG_Actual_Offtake_Header_Upload_Log')
					);
					insert h;
					logId = h.id;
                }else{
					//Mass upload log for page without header
					ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
					insert uploadLog;
					logId = uploadLog.id;
                }
                
                currentPageURL = logId;
            }
            if(namefile.toLowerCase().right(3)=='csv'){
               Attachment att = new Attachment(ParentId = currentPageURL, name = namefile, body=contentFile, ContentType ='text/plain; charset=UTF-8'); //ks_c_5601-1987//Attachment att = new Attachment(ParentId = currentPageURL, name = namefile, body=contentFile, ContentType ='text/plain; charset=UTF-8');
                //  Attachment att = new Attachment(ParentId = currentPageURL, name = namefile, body=contentFile, ContentType ='text/plain; charset=GB2312'); 
                system.debug('Test ActivateTime '+ActivateTime);
                insert att;
                msg = 'executeBatch';

                BatchId = Database.executeBatch(new ASI_CRM_SG_MassUploadProcess(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
                                                                              defaultValues, currentPageURL, att.id, recEXID, recEXIDcol, parentObjectAPIName, ParentObjectUploadMsg,
                                                                              upsertMode, emailNotification, opt_allOrNone, containsHeader, Integer.valueOf(noOfLastRowToIgnore), requiredFields),1);

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
                    s = aajs[0].Status + (aajs[0].ExtendedStatus == null ? '' : ': ' + aajs[0].ExtendedStatus);
                    if((aajs[0].Status=='Completed' && AttId!=null)  || Test.isRunningTest() ) {
                        if(aajs[0].ExtendedStatus!=null && aajs[0].ExtendedStatus=='First error: Regex too complicated'){
                            //s='Upload Failed. The file is too large, please cut the file sizes down';
                            s='Upload Failed. Please remove all empty spaces, columns or rows from the file.';
                        }else{
                            Attachment att = [SELECT Id, description FROM Attachment WHERE ID =:AttId];
                            if(att.description!=null){
                                s = att.description;
                            }
                        }
                        
                    }
                }
            }
            return s.split('\n');
        }
    }
    
    public Boolean isDisplayErrorLog {
        
        get {
            
            Boolean isDisplayErrorLog = false;
            if(BatchId!=null) {
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0) {
                    if((aajs[0].Status=='Completed' && AttId!=null)  || Test.isRunningTest() ) {
                        //Attachment att = [SELECT Id, body, description FROM Attachment WHERE ID =:AttId];
                        //if(att.description.contains('Cannot find record')){
                            errorLog = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + AttId;
                            // errorLog =  AttId;
                            isDisplayErrorLog = true;
                        //}
                    }
                }
            }
            return isDisplayErrorLog;
        }
    }
    

    private list<string> addDefaultValues(list<string> ls, boolean isHeader){
        if(isHeader)
            ls.addAll(LDefaultValesHeader);
        else
            ls.addAll(LDefaultVales);
        return ls;
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
        //currentpageurl = ApexPages.currentPage().geturl();
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