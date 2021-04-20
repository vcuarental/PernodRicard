/*
 * Block comments with details of changes
 */
public class ASI_GnH_KR_UploadRecipientController{
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

    public String reportCorpCard {get;set;}
    public String reportTnE {get;set;}

    public String statementDateStr;
    String exId;
    String detailYear;
    String detailMonth;
    Attachment att;

    public string[] StatusMsgs{
        get{
            string s = msg==null? '': msg;
            if(BatchId!=null){
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId];
                if(aajs.size()>0){
                    if (aajs[0].ExtendedStatus != null){
                        String errorStatus = aajs[0].ExtendedStatus;
                        errorStatus = errorStatus.replace('First error: Upsert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ','');
                        errorStatus = errorStatus.replace(': []','');
                        s = '<span style="color: blue; font-weight: bold;">' + errorStatus + '</span>';
                    }else{ 
                        s = '<span style="color: blue; font-weight: bold;">' + aajs[0].Status + '</span>';
                    }
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

    public ASI_GnH_KR_UploadRecipientController(){
        User usr = [Select Id, Country From User Where Id =: Userinfo.getUserId()];

        if(usr.Country != '' && usr.Country != null){
            //if(usr.Country.trim().toLowerCase() == 'korea'){ //20160829, edited by Leo
            if(usr.Country.trim().toLowerCase().contains('korea')){
                recordtypeName = 'ASI GnH KR Request Recipient';
                country = 'KR';
                //reportCorpCard = retrieveCorpCardReport('ASI_T_E_KR_CorpCardReport');
                //reportTnE = retrieveTnEReport('ASI_T_E_KR_TnE_AnP_Report');
                system.debug('reportCorpCard111 ' + reportCorpCard + ' reportTnE111 ' + reportTnE);
            }
        }else{
            recordtypeName = 'ASI GnH KR Request Recipient';
            country = 'KR';
            //reportCorpCard = retrieveCorpCardReport('ASI_T_E_KR_CorpCardReport');
            //reportTnE = retrieveTnEReport('ASI_T_E_KR_TnE_AnP_Report');
        }

        TnEMessage = '';
        msgCorpCardEmail = 'Email Notification will be sent when upload process is completed';  
    }

    public PageReference uploadCSVByBatch(){
        GenBatchId = null;
        if(country == 'KR'){
            recordtypeName = 'ASI GnH KR Request Recipient';
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

                ASI_GnH_KR_MassUploadRecipientBatch bc = new ASI_GnH_KR_MassUploadRecipientBatch(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
                                                                                                  defaultValues, currentPageURL, att.id, recEXID, recEXIDcol, parentObjectAPIName, ParentObjectUploadMsg,
                                                                                                  upsertMode, emailNotification, opt_allOrNone);
                BatchId = Database.executeBatch(bc,1);
                /*    return null;
                }catch(exception e){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
                    system.debug('Error');
                    return null;
                }*/
                system.debug(bc.hasDMLError + ' AND '+bc.dmlErrMsg);
                if (bc.hasDMLError == true && bc.dmlErrMsg.length()>0){
                    system.debug('Catch an error');
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,bc.dmlErrMsg));
                    return null;
                }

                AttId = att.id;
                //msg = 'Batch Started';
            }else{
                msg = 'Error: Please select csv file only!';
                return null;
            }
        }else{
            msg = 'Error: File too large';
            return null;
        }
        TnEMessage = '';
        return null;
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