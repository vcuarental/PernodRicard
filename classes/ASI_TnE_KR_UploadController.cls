/*********************************************************************************
    * Name: ASI_TnE_MassUploadCorpCardController
    * Description: Controller for ASI_TnE_MassUploadCorpCardComponent. Upload .csv format file to Corp Card Object
    *
    * Version History
    * 2015-03-02        Laputa      Create
*********************************************************************************/ 
public class ASI_TnE_KR_UploadController {
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
    public string msgCorpCardEmail {set;get;}
    public string msgGenerateTnEEmail {set;get;}
    private id recordtypid;
    private list<string> LDefaultVales;
    private list<string> LDefaultValesHeader;
    
    private Integer rowCount;
    private Integer colCount;
    
    public Id BatchId {get;set;}
    public Id AttId {get;set;}
    
    public String country {get;set;}
    public String TnEMessage {get;set;}
    
    public Id GenBatchId {get;set;}
    public Id userId = UserInfo.getUserId();
    public Id logId;

    public string[] GenStatusMsgs{
        get{
            string s = TnEMessage ==null? '': TnEMessage;
            if(GenBatchId!=null){
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: GenBatchId  ];
                if(aajs.size()>0){
                    s = '<span style="color: blue; font-weight: bold;">' + aajs[0].Status + '</span>';
                    }
                if(aajs[0].Status=='Completed' && logId != null){
                    ASI_TnE_Mass_Upload_Log__c uploadLog = [SELECT ASI_TnE_Error_Message__c FROM ASI_TnE_Mass_Upload_Log__c WHERE Id =: logId];
                    if(uploadLog.ASI_TnE_Error_Message__c!=null){
                        if(uploadLog.ASI_TnE_Error_Message__c == 'success')
                        {
                            s = '<div style="height: 25px;"><img src="/img/msg_icons/confirm16.png" style="vertical-align: middle;"/> <span style="color:green; font-weight: bold; vertical-align: middle;"> Successfully generated T&E! </span></div>';
                            s += '<div style="color:blue;">Please review the generated T&E by clicking this link > <a href="javascript:void(0)" style="color: blue;" onClick="window.open(\'' + reportTnE + '\',\'T&E Report\', \'height=600,width=1000,left=100,top=80,scrollbars=yes,toolbar=no,status=no\')"> View T&E Report</a><div>';
                        }
                        else
                        {
                            s = uploadLog.ASI_TnE_Error_Message__c;
                        }
                    }
                }
            }
            return s.split('\n');
        }
    }
    

    public String reportCorpCard {get;set;}
    public String reportTnE {get;set;}
    
    public String statementDateStr;
    String exId;
    String detailYear;
    String detailMonth;
    Attachment att;
        
    public ASI_TnE_KR_UploadController(){
        User usr = [Select Id, Country From User Where Id =: Userinfo.getUserId()];
        
        if(usr.Country != '' && usr.Country != null){
            //if(usr.Country.trim().toLowerCase() == 'korea'){ //20160829, edited by Leo
            if(usr.Country.trim().toLowerCase().contains('korea')){
                recordtypeName = 'TnE KR Corp Card Upload';
                country = 'KR';
                reportCorpCard = retrieveCorpCardReport('ASI_T_E_KR_CorpCardReport');
                reportTnE = retrieveTnEReport('ASI_T_E_KR_TnE_AnP_Report');
                system.debug('reportCorpCard111 ' + reportCorpCard + ' reportTnE111 ' + reportTnE);
            }
        }else{
            recordtypeName = 'TnE KR Corp Card Upload';
            country = 'KR';
            reportCorpCard = retrieveCorpCardReport('ASI_T_E_KR_CorpCardReport');
            reportTnE = retrieveTnEReport('ASI_T_E_KR_TnE_AnP_Report');
        }
        
        TnEMessage = '';
        msgCorpCardEmail = 'Email Notification will be sent when upload process is completed';
    }
    
    private String retrieveCorpCardReport(String repRecType){
        String reportType = '#';
        List<Report> report = [Select Id, Name, DeveloperName From Report Where DeveloperName =: repRecType];
        
        if(report.size() > 0){
            reportType = '/' + report[0].Id;
        }
        return reportType;
    }
    
    private String retrieveTnEReport(String repRecType){
        String reportType = '#';
        List<Report> report = [Select Id, Name, DeveloperName From Report Where DeveloperName =: repRecType];
        
        if(report.size() > 0){
            reportType = '/' + report[0].Id + '?pv2=' + Userinfo.getName();
        }
        return reportType;
    }
    
    public void uploadCSVByBatch(){
        GenBatchId = null;
        if(country == 'KR'){
            recordtypeName = 'TnE KR Corp Card Upload';
            //reportCorpCard = retrieveCorpCardReport('ASI_TnE_SG_Corp_Card_Statement_Uploaded');
            //reportTnE = retrieveTnEReport('ASI_TnE_SG_Corp_Card_TnE_Generated_Rpt');
        }
        
        System.debug('fileSize'+fileSize);
        if(fileSize <= 5242880){ //Fix for 5MB size limit

            if(currentPageURL == '' || currentPageURL == null){
                //Mass upload log for page without header
                ASI_TnE_Mass_Upload_Log__c uploadLog = new ASI_TnE_Mass_Upload_Log__c();
                
                insert uploadLog;
                if(uploadLog.ASI_TnE_Error_Message__c != null)
                {
                    uploadLog.ASI_TnE_Error_Message__c = '';
                    update uploadLog;
                }
                currentPageURL = uploadLog.id;
            }
            statementDateStr = namefile.toLowerCase().left(10);
            
            if(namefile.toLowerCase().right(3)=='csv'){
                att = new Attachment(ParentId = currentPageURL, name = namefile, body=contentFile, ContentType ='text/plain; charset=UTF-8');
                 
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
                //msg = 'executeBatch';
                
                BatchId = Database.executeBatch(new ASI_TnE_KR_MassUploadCorpCardBatch(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
                    defaultValues, currentPageURL, att.id, recEXID, recEXIDcol, parentObjectAPIName, ParentObjectUploadMsg,
                    upsertMode, emailNotification, opt_allOrNone),1);
                
                AttId = att.id;
                //msg = 'Batch Started';
            }else{
                    msg = 'Error: Please select csv file only!';
                }
        }else{
            msg = 'Error: File too large';
        }
        TnEMessage = '';
    }
    
    public string[] StatusMsgs{
        get{
            string s = msg==null? '': msg;
            if(BatchId!=null){
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId];
                if(aajs.size()>0){
                    s = '<span style="color: blue; font-weight: bold;">' + aajs[0].Status + '</span>';
                    if(aajs[0].Status=='Completed' && AttId!=null){
                        Attachment att = [SELECT Id, description FROM Attachment WHERE ID =:AttId];
                        if(att.description!=null){
                            s = att.description;
                            //att.description = '';
                            //update att;
                        }
                    }
                    if(TnEMessage != ''){
                        s = '';
                    }
                }
            }
            return s.split('\n');
        }
    }
    public void generateTnERecords2()
    {
        ASI_TnE_Mass_Upload_Log__c uploadLog = new ASI_TnE_Mass_Upload_Log__c();
        
        insert uploadLog;
        logId = uploadLog.id;
        List<ASI_TnE_Corp_Card_Statement_Upload__c> cCardList = 
            new List<ASI_TnE_Corp_Card_Statement_Upload__c>([SELECT id FROM ASI_TnE_Corp_Card_Statement_Upload__c WHERE OwnerId =: userId]);
        if(cCardList.size() > 0)
            GenBatchId = Database.executeBatch(new ASI_TnE_KR_MassGenBatch(uploadLog),200);
        else
            TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/info16.png" style="vertical-align: middle;"/> <span style="color:blue; font-weight: bold; vertical-align: middle;"> No Record(s) to Generate! </span></div>';
    }
    
    public void deleteCorpCardStatements(){
        TnEMessage = '';
        list<ASI_TnE_Corp_Card_Statement_Upload__c> corpCardDelete = new List<ASI_TnE_Corp_Card_Statement_Upload__c>();
        List<ASI_TnE_Corp_Card_Statement_Upload__c> tempIntray = new List<ASI_TnE_Corp_Card_Statement_Upload__c>
                ([Select Id From ASI_TnE_Corp_Card_Statement_Upload__c Where OwnerId =: userId]);
        for(ASI_TnE_Corp_Card_Statement_Upload__c ccUp: tempIntray){
            corpCardDelete.add(ccUp);
        }//end for
        if(corpCardDelete.size() > 0){
            delete corpCardDelete;
        }
        TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/confirm16.png" style="vertical-align: middle;"/> <span style="color:green; font-weight: bold; vertical-align: middle;"> Successfully deleted all Corp Card Statements </span></div>' + 
                        '<div style="color:blue;">Please upload the Corp Card Statement file again.</div>';
    }//end method
    
    public void refreshPage2(){
        reloadNeeded = true;
        {
            currentPageUrlOutput = URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentPageUrl;
        }
    }
    
    // list of valid country for import
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        if(country == 'KR'){
            options.add(new SelectOption('KR','KR'));
        }
        return options;
    }
}