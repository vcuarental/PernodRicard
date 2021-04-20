/*********************************************************************************
    * Name: ASI_BRD_Generic_UploadAccControllerLux
    * Description: Controller for ASI_BRD_Generic_UploadAccComponentLux Upload .csv format file to Account Object
    *
    * Version History
    * March 9, 2016        Laputa      Create
*********************************************************************************/ 
public class ASI_BRD_Generic_UploadAccControllerLux{
    public string fields {set;get;}
    public string fieldsLabel {set;get;}
    public String country {get;set;}
    public string nameFile {set;get;}
    public integer fileSize {set;get;}
    public Blob contentFile {set;get;}
    public string template {set;get;}
    public string Msg {set;get;}
    public Id BatchId {get;set;}
    public Id AttId {get;set;}
    public String currentPageURL;
    //public string recEXID {set;get;}
    //public string recEXIDcol {set;get;} 
    public string parentObjectAPIName {set;get;}
    public string ParentObjectUploadMsg {set;get;}
    public boolean upsertMode {set;get;}
    //public boolean opt_allOrNone{set;get;}    
    public boolean isLux{get;set;}
    public String reportName{get;set;}
    public String accReport;
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('TWN','TWN'));
        return options;
    }
    
    public String getAccReport(){
        accReport = retrieveReport('ASI_LUX_Accounts_created_today');
        return accReport;
    }
    public void uploadCSVByBatch(){
        if(fileSize <= 5242880){
            if(currentPageURL == '' || currentPageURL == null){
                //Mass upload log for page without header
                ASI_TnE_Mass_Upload_Log__c uploadLog = new ASI_TnE_Mass_Upload_Log__c();
                insert uploadLog;
                currentPageURL = uploadLog.id;
            }
            if(namefile.toLowerCase().right(3)=='csv'){
                Attachment att = new Attachment(ParentId = currentPageURL, name = namefile, body=contentFile, ContentType ='text/plain; charset=UTF-8');
                insert att;
                msg = 'executeBatch';
                Id userId = UserInfo.getUserId();
                User u = [Select ASI_BRD_CRM_Market__c From User Where Id = :userId];
                Map <String, ASI_BRD_Generic_CRM_Mapping__c> mktMap = ASI_BRD_Generic_CRM_Mapping__c.getAll();
                String recordtypeName = '';
                if(u.ASI_BRD_CRM_Market__c != null && isLux == false){
                    recordtypeName = mktMap.get(u.ASI_BRD_CRM_Market__c).ASI_BRD_Record_Type__c;
                }else if(u.ASI_BRD_CRM_Market__c != null && isLux == true){
                    recordtypeName = mktMap.get(u.ASI_BRD_CRM_Market__c).ASI_BRD_LUX_Record_Type__c;
                }else{
                    recordtypeName = 'ASI_BRD_Generic_CRM_Account';
                }
                BatchId = Database.executeBatch(new ASI_BRD_Generic_UploadAccBatch(fields, fieldsLabel, recordtypeName, 
                    att.id, parentObjectAPIName, ParentObjectUploadMsg,
                    upsertMode, true, isLux),1);
                
                AttId = att.id;
                msg = 'Batch Started';
            }else{
                    msg = 'Error: Please select csv file only!';
                }
        }else{
            msg = 'Error: File too large';
        }
    }
    
    public string[] StatusMsgs{
        get{
            string s = msg==null? '': msg;
            if(BatchId!=null){
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0){
                    s = '<span style="color: blue; font-weight: bold;">' + aajs[0].Status + '</span>';
                    if(aajs[0].Status=='Completed' && AttId!=null){
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
    
    private String retrieveReport(String repRecType){
        String reportType = '#';
        List<Report> report = [Select Id, Name, DeveloperName From Report Where DeveloperName =: repRecType];
        
        if(report.size() > 0){
            reportType = '/' + report[0].Id;
        }
        return reportType;
    }
}