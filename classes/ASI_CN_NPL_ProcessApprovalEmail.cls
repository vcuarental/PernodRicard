/*      Written by Michael Yip 29May2013
        Email Service Class to handle email replied from approver/delegated approver
        
        Setting
        1. Approval Notification Email Sent by HandleApprovalEmail.cls
        2. Approval Notification Email Subject should contain record id of record waiting for approval
        3. Approval Email must be reply using the same email address as the notification email sent to
        4. Keyword approve/yes, reject/no should be put in first line of email body to identify approval action
        5. Comments should be put in second line of email body
        

 */
global class ASI_CN_NPL_ProcessApprovalEmail implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        system.debug(email.subject);
        
            id objID = (id)email.subject.trim().right(15);
            String approverEmail = envelope.fromAddress;
            System.debug(approverEmail);
            
            User LApprover = [Select id, email, DelegatedApproverId from User where id =:UserInfo.getUserId() limit 1];
            System.debug('ApproverID: ' + String.valueof(LApprover.id));
            System.debug('objID: ' + String.valueof(objID));
            
            // Return approval request when approver reply email
            List<ProcessInstanceWorkitem> LProcessItem = [SELECT ActorId, ProcessInstanceId, Id 
                FROM ProcessInstanceWorkitem 
                where processinstance.targetobjectid = :objID and actorId = :LApprover.id limit 1];
            
            //Query for original approver when delegated approver reply email
            if(LProcessItem == null || LProcessItem.size()==0){
                Set<id> SOriginalApproverID = new Set<id>();
                for(User u : [Select id, email, DelegatedApproverId 
                    from User where DelegatedApproverId = :LApprover.id]){
                        SOriginalApproverID.add(u.id);
                    }
                if(SOriginalApproverID != null && SOriginalApproverID.size()>0){
                    LProcessItem = [SELECT ActorId, ProcessInstanceId, Id 
                    FROM ProcessInstanceWorkitem 
                    where processinstance.targetobjectid = :objID and actorId IN :SOriginalApproverID limit 1];
                }
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // Process email first line for approval keyword, second line for approval comments
            List<String> emailBody = email.plainTextBody.split('\n', 0);
            if(LProcessItem != null && LProcessItem.size()>0){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(LProcessItem[0].id);
                req.setComments(emailBody[1]);
                system.debug('Keyword: ' + emailBody[0].toLowerCase().trim());
                system.debug('Comment: ' + emailBody[1].toLowerCase().trim());
                if(emailBody[0].toLowerCase().trim()=='approve' || emailBody[0].toLowerCase().trim()=='yes' || emailBody[0].toLowerCase().trim()=='approved'){
                    req.setAction('Approve');
                    Approval.ProcessResult result2 =  Approval.process(req);
                }
                else if(emailBody[0].toLowerCase().trim()=='reject' || emailBody[0].toLowerCase().trim()=='no'  || emailBody[0].toLowerCase().trim()=='rejected'){
                    req.setAction('Reject');
                    Approval.ProcessResult result2 =  Approval.process(req);
                }
                else{   //Approval keyword was not understood. Return error message email 
                    mail.setHtmlBody('Your workflow approval message was not processed.<br/>The word used to approve or reject the item was not understood.<br/>Please contact your system administrator if you feel you received this message in error.');
                    mail.setPlainTextBody('Your workflow approval message was not processed.\nThe word used to approve or reject the item was not understood.\nPlease contact your system administrator if you feel you received this message in error.');
                    mail.setToAddresses(new List<String>{envelope.fromAddress});
                    mail.setReplyTo('noreply@salesforce.com');
                    mail.setSenderDisplayName('Email Approval');
                    mail.setSubject(email.subject);
                    Messaging.sendEmail(new List<Messaging.Email>{mail});
                }
                
            }
            else{   //Approval Request cannot be found, approval process has already been processed. Return error message email
                mail.setHtmlBody('Your workflow approval message was not processed.<br/>The referenced object has already been processed.<br/>Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.');
                mail.setPlainTextBody('Your workflow approval message was not processed.\nThe referenced object has already been processed.\nPlease do not reply to this message.\nContact your system administrator if you feel you received this message in error.');
                mail.setToAddresses(new List<String>{envelope.fromAddress});
                mail.setReplyTo('noreply@salesforce.com');
                mail.setSenderDisplayName('Email Approval');
                mail.setSubject(email.subject);
                Messaging.sendEmail(new List<Messaging.Email>{mail});
            }
        //}
    
        return result;
    }
}