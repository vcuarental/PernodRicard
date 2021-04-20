global  class ASI_CRM_CN_InternalComplaintEmailhandler  implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,  Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        system.debug('enter 66666');
        string splitstr= '#';
        string EmailBody='我们已经成功将您的附件上传至对应的 Internal Complaint：'+ '\n' ;
        STRING URLLink = URL.getSalesforceBaseUrl().toExternalForm() ;
        try {
            set<String> InternalComplaintNameSet = new set<String> ();
            Map<String,ASI_CRM_Internal_Complaint__c> InternalComplaintMap= new Map<String,ASI_CRM_Internal_Complaint__c>();
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                string filename =bAttachment.fileName ;
                if(filename.indexOf(splitstr)>-1){
                    List<String> parts = filename.split(splitstr);
                    system.debug(parts[0]);
                    InternalComplaintNameSet.add(parts[0]);
                }
                
            }
            
            if(InternalComplaintNameSet.size()>0){
                List<ASI_CRM_Internal_Complaint__c> InternalComplaintList = [select id,Name from ASI_CRM_Internal_Complaint__c where name in : InternalComplaintNameSet]; 
                for(ASI_CRM_Internal_Complaint__c InternalComplaint:InternalComplaintList ){
                    InternalComplaintMap.put(InternalComplaint.Name , InternalComplaint);
                    EmailBody  +=  InternalComplaint.Name+': ' +URLLink+'/'+InternalComplaint.Id + '\n' ;
                }
            }
            
            
            List<Attachment> attachmentList = new List<Attachment> ();
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                Attachment attachment = new Attachment();
                
                string filename =bAttachment.fileName ;
                if(filename.indexOf(splitstr)>-1){
                    List<String> parts = filename.split(splitstr);
                    if(InternalComplaintMap.containskey(parts[0])){
                        attachment.Name = bAttachment.fileName;
                        attachment.Body = bAttachment.body;
                        attachment.ParentId =  InternalComplaintMap.get(parts[0]).Id;
                        attachmentList.add(attachment);
                        
                    }
                    
                    
                }
                
                
            }
            
            if(attachmentList.size()>0){
                insert attachmentList;
            }
            
            result.success = true;
            //STRING URLLink = URL.getSalesforceBaseUrl().toExternalForm()   + '/015M0000001DPnT';
            
           // result.message = (email.subject + ' OK' + '<a href=\"'+URLLink+'\">'+URLLink+'</a>' + '\n' + ' Yesy ');
            result.message=EmailBody;
        } catch (Exception e) {
            result.success = false;
            result.message = 'Oops, I failed. Error : '+e.getMessage();
            
        }
        
        
        return result;
        
    }
}