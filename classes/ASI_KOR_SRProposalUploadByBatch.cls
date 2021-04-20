/*---------------------------------------------------------------------------
 * Filename: ASI_MFM_MassUploadByBatchController
 * Author:   Michael Yip
 * Purpose:  Mass upload component using batch class
 *
 * Copyright 2013 Introv Limited. All rights reserved.
 * Customer confidential. Do not distribute.
 *
 * History
 * -----------------------------------------------------------------------------
 * 2014-04-03 Michael Yip           Create
 */
public class ASI_KOR_SRProposalUploadByBatch {
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
        
    public ASI_KOR_SRProposalUploadByBatch(){
        
		reportCorpCard = '';
		reportTnE = '';
        TnEMessage = '';
        msgCorpCardEmail = '';
    }
    
    public void uploadCSVByBatch(){
        GenBatchId = null;
        
        System.debug('fileSize'+fileSize);
        if(fileSize <= 5242880){ //Fix for 5MB size limit

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
                
                BatchId = Database.executeBatch(new ASI_KOR_SRProposalUpload_Batch(ObjAPIName, parentID, parentField, fields, fieldsLabel, lookupEXID, recordtypeName, 
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
                        /*
                        Attachment att = [SELECT Id, description FROM Attachment WHERE ID =:AttId];
                        if(att.description!=null){
                            s = att.description;
                            //att.description = '';
                            //update att;
                        }
                        */
                        ASI_KOR_SR_Proposal_Header__c header = [select ASI_KOR_Mass_Upload_Message__c from ASI_KOR_SR_Proposal_Header__c where id = :parentID limit 1];
                        s = header.ASI_KOR_Mass_Upload_Message__c;
                    }
                    if(TnEMessage != ''){
                        s = '';
                    }
                }
            }
            return s.split('\n');
        }
    }
}