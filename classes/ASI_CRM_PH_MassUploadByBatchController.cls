public with sharing class ASI_CRM_PH_MassUploadByBatchController {

    //Attributes
    public String ObjAPIName { set; get; }
    public String ActivateTime { set; get; }
    public String parentID { set; get; }
    public String parentField { set; get; }
    public String fields { set; get; }
    public String fieldsLabel { set; get; }
    public String requiredFields { set; get; }
    public String lookupEXID { set; get; }
    public String template { set; get; }
    public String PanelName { set; get; }
    public String report { set; get; }
    public String recordtypeName { set; get; }
    public String currentPageURL { set; get; }
    public Boolean inlineVF { set; get; }
    public Boolean reloadNeeded { get; set; }
    public String defaultValues { set; get; }
    public String recEXID { set; get; }
    public String recEXIDcol { set; get; }
    public String parentObjectAPIName { set; get; }
    public String ParentObjectUploadMsg { set; get; }
    public String errorLog { set; get; }
    public String noOfLastRowToIgnore { set; get; }


    public Boolean upsertMode { set; get; }
    public Boolean batchMode { set; get; }
    public Boolean opt_allOrNone { set; get; }
    public Boolean emailNotification { set; get; }
    public Boolean containsHeader { set; get; }
    // a dummy variable to invoke init() method
    public Boolean dummyVar {
        get {
            if (dummyVar != true) {
                init();
            } return dummyVar;
        }
        set;
    }


    public String objName { set; get; }
    public String nameFile { set; get; }
    public Integer fileSize { set; get; }

    public String Msg { set; get; }

    public Blob contentFile { set; get; }

    public String currentPageURLOutput { set; get; }
    private Schema.SObjectType ObjType;
    private List<String> LFieldAPIName;
    private List<String> LFieldLabel;
    private Map<String, String> MAPINameLabel;
    private List<Row> LInputRow;
    public List<Row> LOutputRow { set; get; }
    public List<Row> LErrorRows { set; get; }
    private Map<String, Integer> MFieldPos;
    private Map<String, Integer> MLookupFieldPos;
    private transient Map<String, Id> MRecTypeID;
    public Boolean hasError { set; get; }
    public String msgEmail { set; get; }
    private Id recordTypeId;
    private List<String> LDefaultVales;
    private List<String> LDefaultValesHeader;

    private Integer rowCount;
    private Integer colCount;

    public Id BatchId { get; set; }
    public Id AttId { get; set; }
    private String HeaderId;

    public ASI_CRM_PH_MassUploadByBatchController() {

    }


    public void init() {
        /*if(inlineVF){
            currentPageUrlOutput = currentPageUrl;
        }
        else*/
        msgEmail = 'Result should appear here...';
        if (emailNotification) {
            msgEmail = 'Email Notification will be sent when upload process is completed<br/><br/>';
            if ((ObjAPIName == 'ASI_TH_CRM_Actual_Offtake__c' && recordtypeName == 'ASI CRM SG Actual Offtake' && !defaultValues.contains('Type (Uploaded):Off-Trade'))) {
                msgEmail = '<br/>' +
                        'Please download the template to see the format. Please arrange to column by following order:<br/>' +
                        'Type (e.g. INV/INF)<br/> Code (e.g. U)<br/> Wholesaler Code<br/> Outlet Code<br/> G/L Date (format YYYYMMDD)<br/> SKU Code<br/> Invoice No.<br/> Quantity<br/><br/>' +
                        msgEmail;
            } else
                    if ((ObjAPIName == 'ASI_TH_CRM_Actual_Offtake__c' && recordtypeName == 'ASI CRM SG Actual Offtake' && defaultValues.contains('Type (Uploaded):Off-Trade'))) {
                        msgEmail = '<br/>' +
                                'Please download the template to see the format. <span style="color:red">Please also remove all double spaces.</span><br/>' +
                                msgEmail;
                    }
        }
        ObjType = Schema.getGlobalDescribe().get(ObjAPIName);
        LFieldAPIName = fields.toLowerCase().split(',', 0);
        LFieldLabel = fieldsLabel.toLowerCase().split(',', 0);
        if ([SELECT Id FROM RecordType WHERE Name = :recordtypeName AND SobjectType = :ObjAPIName].size() > 0) {
            recordTypeId = [SELECT Id FROM RecordType WHERE Name = :recordtypeName AND SobjectType = :ObjAPIName].Id;
        }
        MAPINameLabel = new Map<String, String>();
        for (Integer i = 0; i < LFieldAPIName.size(); i++) {
            MAPINameLabel.put(LFieldAPIName[i].toLowerCase().trim(), LFieldLabel[i].toLowerCase().trim());
        }
        MRecTypeID = new Map<String, Id>();
        for (RecordType r : [SELECT Id, Name, SobjectType FROM RecordType]) {
            String key = r.SobjectType + r.Name;
            key = key.toLowerCase();
            MRecTypeID.put(key, r.Id);
        }

        hasError = false;
        //msg = '';
        //MRecTypeDefault = new Map<string,string>();
        LDefaultVales = new List<String>();
        LDefaultValesHeader = new List<String>();
        if (String.isNotBlank(defaultValues)) {
            List<String> LDefaultValuePair = defaultValues.split(';', 0);
            for (String s : LDefaultValuePair) {
                List<String> l = s.split(':', 0);
                LDefaultValesHeader.add(l[0]);
                LDefaultVales.add(l[1]);
            }
            //MRecTypeDefault.put()
        }

    }

    public void uploadCSVByBatch() {
        System.debug('See currentPageURL : ' + currentPageURL);
        Id offtakeHeaderId;

        if (fileSize > ASI_CRM_FileUploadHelper.MAX_FILE_SIZE) {
            msg = 'Error: File too large';
            return;
        }

        if (!ASI_CRM_FileUploadHelper.FileExtension.csv.name().equals(ASI_CRM_FileUploadHelper.getFileExtension(nameFile))) {
            msg = 'Error: Please select csv file only!';
            return;
        }

        if (currentPageURL == '' || currentPageURL == null) {
            HeaderId = '';
            String logId = '';
//                if ((ObjAPIName == 'ASI_TH_CRM_Actual_Offtake__c' && recordtypeName == 'ASI CRM SG Actual Offtake')) {
            ASI_CRM_ActualOfftakeHeader__c h = new ASI_CRM_ActualOfftakeHeader__c(
                    RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_SG_Actual_Offtake_Header_Upload_Log')
            );
            insert h;
            offtakeHeaderId = h.Id;
            System.debug('---------Header Id-------');
            System.debug(h.Id);
            logId = h.Id;
//                } else {
//                    //Mass upload log for page without header
//                    ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
//                    insert uploadLog;
//                    logId = uploadLog.Id;
//                }

            currentPageURL = logId;
        }

        Attachment att = new Attachment(ParentId = currentPageURL, Name = namefile, Body = contentFile, ContentType = 'text/csv; charset=UTF-8'); //ks_c_5601-1987//Attachment att = new Attachment(ParentId = currentPageURL, name = namefile, body=contentFile, ContentType ='text/plain; charset=UTF-8');
        //  Attachment att = new Attachment(ParentId = currentPageURL, name = namefile, body=contentFile, ContentType ='text/plain; charset=GB2312');
        System.debug('Test ActivateTime ' + ActivateTime);
        insert att;
        msg = 'executeBatch';

//        BatchId = Database.executeBatch(new ASI_CRM_PH_MassUploadProcess(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName,
//                defaultValues, currentPageURL, att.id, recEXID, recEXIDcol, parentObjectAPIName, ParentObjectUploadMsg,
//                upsertMode, emailNotification, opt_allOrNone, containsHeader, Integer.valueOf(noOfLastRowToIgnore), requiredFields), 1);

        BatchId = Database.executeBatch(new ASI_CRM_OfftakeCreationBatch(att.Id), 1);

        AttId = att.Id;
        msg = 'Batch Started';
    }

    public String[] StatusMsgs {
        get {
            String s = msg == null ? '' : msg;
            if (BatchId != null) {
                List<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID = :BatchId];
                if (aajs.size() > 0) {
                    s = aajs[0].Status + (aajs[0].ExtendedStatus == null ? '' : ': ' + aajs[0].ExtendedStatus);
                    if ((aajs[0].Status == 'Completed' && AttId != null) || Test.isRunningTest()) {
                        if (aajs[0].ExtendedStatus != null && aajs[0].ExtendedStatus == 'First error: Regex too complicated') {
                            //s='Upload Failed. The file is too large, please cut the file sizes down';
                            s = 'Upload Failed. Please remove all empty spaces, columns or rows from the file.';
                        } else {
                            Attachment att = [SELECT Id, Description FROM Attachment WHERE Id = :AttId];
                            if (att.Description != null) {
                                s = att.Description;
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
            if (BatchId != null) {
                List<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :BatchId];
                if (aajs.size() > 0) {
                    if ((aajs[0].Status == 'Completed' && AttId != null) || Test.isRunningTest()) {
                        //Attachment att = [SELECT Id, body, description FROM Attachment WHERE ID =:AttId];
                        //if(att.description.contains('Cannot find record')){
                        errorLog = Url.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + AttId;
                        // errorLog =  AttId;
                        isDisplayErrorLog = true;
                        //}
                    }
                }
            }
            return isDisplayErrorLog;
        }
    }


    private List<String> addDefaultValues(List<String> ls, Boolean isHeader) {
        if (isHeader) {
            ls.addAll(LDefaultValesHeader);
        } else {
            ls.addAll(LDefaultVales);
        }
        return ls;
    }


    public PageReference refreshPage() {
        System.debug(currentPageURL);
        return ApexPages.currentPage();
    }

    public void refreshPage2() {
        reloadNeeded = true;
        {
            currentPageUrlOutput = Url.getSalesforceBaseUrl().toExternalForm() + '/' + currentPageUrl;
        }
        System.debug(ApexPages.currentPage().getUrl());
        //currentpageurl = ApexPages.currentPage().geturl();
    }

    public class Row {
        public Integer rowNumber { set; get; }
        public sObject sObj { set; get; }
        public string errorMsg { set; get; }

        // Start Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null
        public row(sObject obj) {
            sObj = obj;
            errorMsg = '';
        }
        // End Update by Howard Au (Introv)@18 Mar 2014 to handle if Parent Field and Field ID is null

        public row(sObject obj, string parentField, string parentID) {
            sObj = obj;
            sObj.put(parentField, parentID);
            errorMsg = '';
        }
        public void addError(string errMsg) {
            errorMsg = errMsg;
        }
    }


}