/*********************************************************************************
* Project : TW CRM Offtake upload system
* Test class : ASI_CRM_TW_Function_Test
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 08/12/2020       PRA COE               Created

*********************************************************************************/

global  class ASI_CRM_TW_OfftakeUploadBatch implements Database.Batchable<String>, Database.Stateful {
    
    public final Blob content;
    public final String uploadLogId;
    public final String ChannelStr;
    public final String uploadedPage;
    
    public ASI_CRM_TW_OfftakeUploadBatch(Blob content,string uploadLogId, string ChannelStr, string uploadedPage){
        this.content = content;
        this.uploadLogId = uploadLogId;
        this.ChannelStr = ChannelStr;
        this.uploadedPage = uploadedPage;
    }
    
    public List<String> start(Database.BatchableContext BC) {
        List<String> fileLines = new List<String>();
        
        HttpRequest tmp = new HttpRequest();
        tmp.setBodyAsBlob(this.content);
        string  csvAsString = tmp.getBody();
        fileLines = ASI_CRM_TW_Function.safeSplit(csvAsString,'\n');
        
        //List<String> fileLines = ASI_CRM_TW_Function.safeSplit( ASI_CRM_TW_Function.blobToString(this.content,'UTF-8'),'\n'); //UTF-8 ISO 8859-2
        //List<String> fileLines = ASI_CRM_TW_Function.safeSplit(this.content.toString(),'\n');
        return fileLines;
    }
    
    public void execute(Database.BatchableContext BC, List<string> scope){
        List<String> fileLines = scope;
        //  false: if a record fails, the remainder of the DML operation can still succeed.
        //  true, an exception is thrown if the method is not successful. 
        boolean opt_allOrNone = false;
        
        
        List<ASI_TH_CRM_Actual_Offtake__c> InsertList = ASI_CRM_TW_Function.ConvertUploadLinetoAO(fileLines,uploadLogId,ChannelStr);
        Schema.SObjectType ObjType;
        
        
        ObjType = Schema.getGlobalDescribe().get('ASI_TH_CRM_Actual_Offtake__c');
        List<Database.upsertResult> uResults = new List<Database.upsertResult>();
        uResults = database.upsert(InsertList,ObjType.getDescribe().fields.getMap().get('ASI_TH_CRM_Actual_Offtake_External_ID__c'),opt_allOrNone);
        
        ASI_MFM_Mass_Upload_Log__c uploadLog = [select id,ASI_MFM_Status__c,ASI_MFM_Error_Message__c,ASI_CRM_Number_of_Created_Records__c,ASI_CRM_Number_of_Failed_Records__c,ASI_CRM_Number_of_Updated_Records__c from ASI_MFM_Mass_Upload_Log__c where id = :UploadLogId limit 1 ];
        
        for (Database.UpsertResult saveResult : uResults) {
            if(saveResult.isSuccess()) {
                if(saveResult.isCreated()){
                    uploadLog.ASI_CRM_Number_of_Created_Records__c++;
                }else{
                    uploadLog.ASI_CRM_Number_of_Updated_Records__c++;
                }
            }else{// failed
                uploadLog.ASI_CRM_Number_of_Failed_Records__c++;
                for(Database.Error error : saveResult.getErrors()) {
                    uploadLog.ASI_MFM_Error_Message__c += 'Error Status: ' + error.getStatusCode() + ' ;\n' + 'Message: ' + error.getMessage() + ' ;\n' + 'Problem Fields: ' + error.getFields() + '.\n'; 
                }
            }
            
        }
        
        
        update uploadLog;
        
        
    }
    
    public void finish(Database.BatchableContext BC){
        
        
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, ExtendedStatus,Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        
        List<string> ccEmailList = new List<string>();
        
        
        ASI_MFM_Mass_Upload_Log__c uploadLog = [select id,Name, ASI_CRM_File_Name__c, ASI_MFM_Status__c,ASI_CRM_Result__c,Owner.Email,ASI_MFM_Error_Message__c,ASI_CRM_Number_of_Failed_Records__c,ASI_CRM_Total_Records__c,ASI_CRM_Success_Records__c from ASI_MFM_Mass_Upload_Log__c where id = :UploadLogId limit 1 ];
        
        if(a.ExtendedStatus!=null ){
            uploadLog.ASI_MFM_Status__c= 'Failed';
        }else if(uploadLog.ASI_CRM_Number_of_Failed_Records__c==0){ 
            uploadLog.ASI_MFM_Status__c= 'Success';
        }else if(uploadLog.ASI_CRM_Success_Records__c==0){
            uploadLog.ASI_MFM_Status__c= 'Failed';
        }else{
            uploadLog.ASI_MFM_Status__c= 'Partially Success';  
        }
        
        
        
        
        string resultstr ='Upload Process Result :'+uploadLog.ASI_MFM_Status__c+
            '<br/>Total Records:'+string.valueof(uploadLog.ASI_CRM_Total_Records__c)+
            '<br/>Successful Records:'+string.valueof(uploadLog.ASI_CRM_Success_Records__c)+	
            '<br/>Failed Records:'+string.valueof(uploadLog.ASI_CRM_Number_of_Failed_Records__c)+
            '<br/>Log ID: ' + uploadLog.Name;
        uploadLog.ASI_CRM_Result__c = resultstr;
        
        
        if(uploadLog.ASI_MFM_Error_Message__c!=null && uploadLog.ASI_MFM_Error_Message__c!='' && a.ExtendedStatus!=null ){
            uploadLog.ASI_MFM_Error_Message__c +=a.ExtendedStatus;
            resultstr+='<br/>Error: ' + a.ExtendedStatus;
        }else if(a.ExtendedStatus!=null){
            uploadLog.ASI_MFM_Error_Message__c =a.ExtendedStatus;
            resultstr+='<br/>Error: ' + a.ExtendedStatus;
        }
        update uploadLog;
        
        
        if(uploadLog.ASI_CRM_File_Name__c!=null && uploadLog.ASI_CRM_File_Name__c.contains('@') && uploadLog.ASI_CRM_File_Name__c.contains('_')){
            List<string> FNList = uploadLog.ASI_CRM_File_Name__c.split('_');
            if( FNList.size()>0){
                //remove .csv replaceAll('\\D','');
                string ccEmail = FNList[FNList.size()-1];
                ccEmail =ccEmail.replaceAll('.csv','');
                ccEmailList.add(ccEmail);
                
                for(user u:[select id, email from user where id in (select  UserOrGroupId   from GroupMember   where Group.DeveloperName='ASI_CRM_TW_Offtake_Upload_Email_Group')]){
                    ccEmailList.add(u.email);
                }
            }
        }
        
        
        Id orgEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'pra.sfdcitsupport@pernod-ricard.com' LIMIT 1].Id;
        //send email 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setHtmlBody('Your mass upload submission was processed.<br/><br/>'+resultstr+ '<br/><br/>Please find the attachment for the result. <br/><br/>Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.');
        /*
        mail.setPlainTextBody('Your mass upload submission was processed.Upload Process Result :'+uploadLog.ASI_MFM_Status__c+
        '\n\n Total Records:'+string.valueof(uploadLog.ASI_CRM_Total_Records__c)+
        '\n Successful Records:'+string.valueof(uploadLog.ASI_CRM_Success_Records__c)+	
        '\n Failed Records:'+string.valueof(uploadLog.ASI_CRM_Number_of_Failed_Records__c)+
        '\n Log ID: ' + uploadLog.Name+ '\n\nPlease find the attachment for the result. \n\nPlease do not reply to this message.\nContact your system administrator if you feel you received this message in error.');
        */
        if(uploadedPage=='ASI_CRM_TW_Offtake_UploadPage2'){
            mail.setToAddresses(new List<String>{uploadLog.owner.email});
        }
        
        if(ccEmailList.size()>0){
            mail.setCcAddresses(ccEmailList); 
        }
        
        
        mail.setReplyTo('noreply@salesforce.com');
        //mail.setSenderDisplayName('Pernod Ricard TW Mass Upload Process');
        mail.setSubject('TW Offtake Mass Upload Process is Completed');
        List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();
        mail.setOrgWideEmailAddressId(orgEmailAddressId);
        
        for(Attachment att :[select id,Body,Name,ContentType from Attachment where ParentId =: UploadLogId and description='Log file']){
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();   //Define the email
            efa.setFileName(att.Name);
            efa.setBody(att.Body);
            efa.setContentType(att.ContentType);
            efaList.add(efa);
        }
        
        if(efaList.size()>0){
            mail.setFileAttachments(efaList);
        }
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}