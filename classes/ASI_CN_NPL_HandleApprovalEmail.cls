/*    Written by Michael Yip 28May2013
      Handle notification email for approval process
      
      Setup:
      1.Add "Approval In Progress" checkbox and "Email notification template" text to object for approval process  
      2.Include field update to check "Approval In Progress" at initial submission actions
      3.Include field update to uncheck "Approval In Progress" at final approval & rejection actions
      4.Include field update to write Notification template's developer name to "Email notification template" field at initial submission actions
      5.Initiate sendEmail in after update triger of object for approval
      6.Set up email services and email service name "approvalemailservice"  
*/

public with sharing class ASI_CN_NPL_HandleApprovalEmail {
    public ASI_CN_NPL_HandleApprovalEmail (){
    
    }
    @future
    public static void sendEmail(List<id> LID, String objType){
        if(LID != null && LID.size()>0){
            List<ProcessInstanceWorkitem> LProcessItem = [SELECT ActorId, OriginalActorId, ProcessInstanceId, Id, processinstance.targetobjectid 
                FROM ProcessInstanceWorkitem 
                where processinstance.targetobjectid IN :LID
                order by processinstance.targetobjectid
                ];
            system.debug('ProcessInstanceWorkitem number: ' + String.valueof(LProcessItem.size()));
            // NPL Approval email handling
            if(objType == 'ASI_CN_NPL_NPL_Request__c'){
                Map<id,ASI_CN_NPL_NPL_Request__c> Mnpl = new Map<id,ASI_CN_NPL_NPL_Request__c>([Select ASI_CN_NPL_Status__c, ASI_CN_NPL_Email_Notification_Template__c, id, owner.name 
                    from ASI_CN_NPL_NPL_Request__c where id IN :LID order by id]);
                    
                /*List<>[SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, 
                    ContentDocument.CreatedById, LinkedEntityId 
                    FROM ContentDocumentLink WHERE LinkedEntityId IN :LID];*/
                
                //Create map between npl & npl document records
                Set<id> SDocID = new Set<id>();
                Map<id,List<id>> MNPLDoc = new Map<id,List<id>>();
                List<id> LDocID = new List<id>();
                id tempID;
                for(ASI_CN_NPL_Product_Document__c doc : [Select id, ASI_CN_NPL_Parent__c from ASI_CN_NPL_Product_Document__c 
                    where ASI_CN_NPL_Attach_in_Approval__c = true and ASI_CN_NPL_Parent__c IN :LID ]){
                        SDocID.add(doc.id);
                        if(tempID == null || tempID == doc.ASI_CN_NPL_Parent__c){
                            LDocID.add(doc.id);
                        }
                        else{
                            MNPLDoc.put(tempID, LDocID);
                            LDocID = new List<id>{doc.id};
                        }
                        tempID = doc.ASI_CN_NPL_Parent__c;
                        
                    }
                if(tempID != null)
                    MNPLDoc.put(tempID, LDocID);
                
                LDocID = null;
                
                //Assume one chatter file per ASI_CN_NPL_Product_Document__c
                system.debug('ParentID Size: ' + String.valueof(SDocID));
                /*Map<id, FeedItem> MFeedItem = new Map<id,FeedItem>();   
                for(FeedItem fItem : [SELECT Id, Type, Body, Title, LinkUrl, ParentId, ContentData, ContentSize, ContentFileName, ContentType 
                    From FeedItem where Type = 'ContentPost' and ParentId IN :SDocID and id != null ]){
                        MFeedItem.put(fItem.ParentId,fItem);
                        system.debug('FeedItem ID: ' + String.valueof(fItem.id));
                    }*/
                    
                Map<id, ASI_CN_NPL_Product_Document__Feed> MFeedItem = new Map<id,ASI_CN_NPL_Product_Document__Feed>();   
                for(ASI_CN_NPL_Product_Document__Feed fItem : [SELECT Id, Type, ParentId, ContentData, ContentSize, ContentFileName, ContentType 
                    From ASI_CN_NPL_Product_Document__Feed where Type = 'ContentPost' and ParentId IN :SDocID and id != null ]){
                        MFeedItem.put(fItem.ParentId,fItem);
                        system.debug('FeedItem ID: ' + String.valueof(fItem.id));
                    }
                //system.debug('Photo Size: ' + LFItem.size());
                
                //Create map between npl & npl document files as email attachment
                Map<id, List<Messaging.EmailFileAttachment>> MNPLEmailAtt = new Map<id,List<Messaging.EmailFileAttachment>>();
                for(id nplID : LID){
                    List<Messaging.EmailFileAttachment> LAtt = new List<Messaging.EmailFileAttachment>();
                    if(MNPLDoc.containsKey(nplID)){
                        LDocID = MNPLDoc.get(nplID);
                        for(id docID : LDocID){
                            if(MFeedItem.containsKey(docID)){
                                ASI_CN_NPL_Product_Document__Feed item = MFeedItem.get(docID);
                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName(item.ContentFileName);
                                efa.setBody(item.ContentData);
                                LAtt.add(efa);
                            }
                        }
                        if(LAtt != null){
                            MNPLEmailAtt.put(nplID,LAtt);
                        }
                    }
                }
                
                
                List<String> LTemplateName = new List<String>();
                Set<id> SApproverID = new Set<ID>();
                // Loop to include all email template names for approval process
                for(ProcessInstanceWorkitem processItem : LProcessItem){
                    system.debug('processItem targetobjectid: ' + String.valueof(processItem.processinstance.targetobjectid));
                    SApproverID.add(processItem.actorid);
                    if(Mnpl.containsKey(processItem.processinstance.targetobjectid)){
                        system.debug('targetobjectid: ' + String.valueof(processItem.processinstance.targetobjectid));
                        ASI_CN_NPL_NPL_Request__c npl = Mnpl.get(processItem.processinstance.targetobjectid);
                        if(npl.ASI_CN_NPL_Email_Notification_Template__c != null){
                            LTemplateName.add(npl.ASI_CN_NPL_Email_Notification_Template__c);
                        }
                    }
                }
                
                System.debug('Number of Approval Request: ' + String.valueof(SApproverID.size()));
                
                //Query Approver info
                List<User> LApprover = [Select id, email, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId from user where id IN: SApproverID];
                Map<id,User> MApprover = new Map<id,User>(LApprover);
                
                //Query Delegated Approver info
                Set<id> SDelApproverID = new Set<id>(); 
                for(User u : LApprover){
                    if(u.DelegatedApproverId != null){
                        SDelApproverID.add(u.DelegatedApproverId);
                    }
                }
                Map<id,User> MDelApprover = new Map<id,User>([Select id, email, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId from user where id IN: SDelApproverID]);
                System.debug('Number of Approver: ' + String.valueof(LApprover.size()));
                System.debug('Number of Delegated Approver: ' + String.valueof(MDelApprover.size()));
                //Filter out approver/delegated approver who receive notification email
                Map<id, List<String>> MApproverEmail = new Map<id,List<String>>();
                List<Contact> LCont = new List<Contact>();
                for(User u : LApprover){
                    List<String> LEmail = new List<String>();
                    if(u.ASI_CN_NPL_Receive_Approval_Request__c == 'If I am an approver or delegated approver' || u.ASI_CN_NPL_Receive_Approval_Request__c == 'Only if I am an approver'){
                        LEmail.add(u.email);
                        LCont.add(new Contact(lastname=string.valueof(u.id),email=u.email));
                        system.debug('Approver Email: ' + u.email);
                    }
                    if(u.DelegatedApproverId != null){
                        if(MDelApprover.containsKey(u.DelegatedApproverId)){
                            User DelApprover = MDelApprover.get(u.DelegatedApproverId);
                            if(DelApprover.ASI_CN_NPL_Receive_Approval_Request__c == 'If I am an approver or delegated approver' || DelApprover.ASI_CN_NPL_Receive_Approval_Request__c == 'Only if I am a delegated approver'){
                                LEmail.add(DelApprover.email);
                                LCont.add(new Contact(lastname=string.valueof(DelApprover.id),email=DelApprover.email));
                                system.debug('Delegated Approver Email: ' + DelApprover.email);
                            }
                        }
                    }
                    MApproverEmail.put(u.id,LEmail);                
                }
                if(LCont != null && LCont.size()>0)
                    insert LCont;
                Map<String, Contact> MDummyCont = new Map<String, Contact>();
                for(Contact c : LCont){
                    MDummyCont.put(c.email, c);
                }
                
                // Query email template id  
                Map<String, id> MTemplate = new Map<String,id>();
                for(EmailTemplate e : [Select id, DeveloperName from EmailTemplate where DeveloperName IN: LTemplateName]){
                    MTemplate.put(e.DeveloperName,e.id);
                }
                if(MTemplate != null){
                    EmailServicesAddress ServiceAddressDefault = [SELECT IsActive, LocalPart, EmailDomainName, RunAsUserId FROM EmailServicesAddress where LocalPart = 'approvalemailservicedefault' and isActive = true limit 1];
                    Map<id, EmailServicesAddress> MServiceAddr = new Map<id,EmailServicesAddress>();
                    for(EmailServicesAddress e : [SELECT IsActive, LocalPart, EmailDomainName, RunAsUserId FROM EmailServicesAddress where LocalPart = 'customapprovalemailservice' and RunAsUserId IN :SApproverID and isActive = true ]){
                        MServiceAddr.put(e.RunAsUserId,e);
                    }
                    //if(test.isRunningTest())
                    //    replyToAddress = 'test@test.com';
                    //Compose email to approver/delegated approver who will receive notification email
                    List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();  
                    for(ProcessInstanceWorkitem processItem : LProcessItem){
                        if(MApproverEmail.containsKey(processItem.actorID)){
                            system.debug('Email Address Size: ' + String.valueof(MApproverEmail.get(processItem.actorID).size()));
                            for(String e : MApproverEmail.get(processItem.actorID)){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if(MDummyCont.containsKey(e)){
                                    mail.setTargetObjectId(MDummyCont.get(e).id);
                                    mail.setWhatId(processItem.processinstance.targetobjectid);                             
                                    EmailServicesAddress ServiceAddress = ServiceAddressDefault;
                                    if(MServiceAddr.containsKey(processItem.actorid)){
                                        ServiceAddress = MServiceAddr.get(processItem.actorid);                                     
                                    }
                                    String replyToAddress = ServiceAddress.LocalPart + '@' + ServiceAddress.EmailDomainName;
                                    System.debug(replyToAddress); 
                                    mail.setReplyTo(replyToAddress); 
                                    mail.setSaveAsActivity(false);
                                    if(Mnpl.containsKey(processItem.processinstance.targetobjectid)){
                                        ASI_CN_NPL_NPL_Request__c tempNpl = Mnpl.get(processItem.processinstance.targetobjectid);
                                        mail.setSenderDisplayName(tempNpl.owner.name);
                                        if(MNPLEmailAtt.containsKey(tempNpl.id)){
                                            mail.setFileAttachments(MNPLEmailAtt.get(tempNpl.id));
                                        }
                                        if(MTemplate.containsKey(tempNpl.ASI_CN_NPL_Email_Notification_Template__c))
                                            mail.setTemplateId(MTemplate.get(tempNpl.ASI_CN_NPL_Email_Notification_Template__c));
                                    }
                                    allMail.add(mail);
                                }
                                
                            }
                        }
                    }
                    system.debug('Mail Size: '+ String.valueof(allMail.size()));
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(allMail);
                    for(integer i=1;i<results.size();i++){
                        if(results.get(i).isSuccess()){
                            system.debug(String.valueof(i)+' is success');
                        }
                        else{
                            system.debug(String.valueof(i)+' error message: ' + results.get(0).getErrors()[0].getMessage());
                        }
                     }
                }
                delete LCont;
                
            }
            // FOC Request Header Approval email handling
            else if(objType == 'ASI_FOC_Free_Goods_Request__c'){
                Map<id,ASI_FOC_Free_Goods_Request__c> Mnpl = new Map<id,ASI_FOC_Free_Goods_Request__c>([Select ASI_FOC_Email_Notification_Template__c, id, owner.name 
                    from ASI_FOC_Free_Goods_Request__c where id IN :LID order by id]);
                
                List<String> LTemplateName = new List<String>();
                Set<id> SApproverID = new Set<ID>();
                // Loop to include all email template names for approval process
                for(ProcessInstanceWorkitem processItem : LProcessItem){
                    system.debug('processItem targetobjectid: ' + String.valueof(processItem.processinstance.targetobjectid));
                    SApproverID.add(processItem.actorid);
                    if(Mnpl.containsKey(processItem.processinstance.targetobjectid)){
                        system.debug('targetobjectid: ' + String.valueof(processItem.processinstance.targetobjectid));
                        ASI_FOC_Free_Goods_Request__c foc = Mnpl.get(processItem.processinstance.targetobjectid);
                        if(foc.ASI_FOC_Email_Notification_Template__c != null){
                            LTemplateName.add(foc.ASI_FOC_Email_Notification_Template__c);
                        }
                    }
                }
                
                System.debug('Number of Approval Request: ' + String.valueof(SApproverID.size()));
                
                //Query Approver info
                List<User> LApprover = [Select id, email, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId from user where id IN: SApproverID];
                Map<id,User> MApprover = new Map<id,User>(LApprover);
                
                //Query Delegated Approver info
                Set<id> SDelApproverID = new Set<id>(); 
                for(User u : LApprover){
                    if(u.DelegatedApproverId != null){
                        SDelApproverID.add(u.DelegatedApproverId);
                    }
                }
                Map<id,User> MDelApprover = new Map<id,User>([Select id, email, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId from user where id IN: SDelApproverID]);
                System.debug('Number of Approver: ' + String.valueof(LApprover.size()));
                System.debug('Number of Delegated Approver: ' + String.valueof(MDelApprover.size()));
                //Filter out approver/delegated approver who receive notification email
                Map<id, List<String>> MApproverEmail = new Map<id,List<String>>();
                List<Contact> LCont = new List<Contact>();
                for(User u : LApprover){
                    System.debug('Queried Approver ID: ' + u.id);
                    List<String> LEmail = new List<String>();
                    if(u.ASI_CN_NPL_Receive_Approval_Request__c == 'If I am an approver or delegated approver' || u.ASI_CN_NPL_Receive_Approval_Request__c == 'Only if I am an approver'){
                        LEmail.add(u.email);
                        LCont.add(new Contact(lastname=string.valueof(u.id),email=u.email));
                        system.debug('Approver Email: ' + u.email);
                    }
                    if(u.DelegatedApproverId != null){
                        if(MDelApprover.containsKey(u.DelegatedApproverId)){
                            User DelApprover = MDelApprover.get(u.DelegatedApproverId);
                            if(DelApprover.ASI_CN_NPL_Receive_Approval_Request__c == 'If I am an approver or delegated approver' || DelApprover.ASI_CN_NPL_Receive_Approval_Request__c == 'Only if I am a delegated approver'){
                                LEmail.add(DelApprover.email);
                                LCont.add(new Contact(lastname=string.valueof(DelApprover.id),email=DelApprover.email));
                                system.debug('Delegated Approver Email: ' + DelApprover.email);
                            }
                        }
                    }
                    MApproverEmail.put(u.id,LEmail);                
                }
                if(LCont != null && LCont.size()>0)
                    insert LCont;
                Map<String, Contact> MDummyCont = new Map<String, Contact>();
                for(Contact c : LCont){
                    MDummyCont.put(c.email, c);
                }
                
                // Query email template id  
                Map<String, id> MTemplate = new Map<String,id>();
                for(EmailTemplate e : [Select id, DeveloperName from EmailTemplate where DeveloperName IN: LTemplateName]){
                    MTemplate.put(e.DeveloperName,e.id);
                }
                if(MTemplate != null){
                    EmailServicesAddress ServiceAddressDefault = [SELECT IsActive, LocalPart, EmailDomainName, RunAsUserId FROM EmailServicesAddress where LocalPart = 'approvalemailservicedefault' and isActive = true limit 1];
                    Map<id, EmailServicesAddress> MServiceAddr = new Map<id,EmailServicesAddress>();
                    for(EmailServicesAddress e : [SELECT IsActive, LocalPart, EmailDomainName, RunAsUserId FROM EmailServicesAddress where LocalPart = 'customapprovalemailservice' and RunAsUserId IN :SApproverID and isActive = true ]){
                        MServiceAddr.put(e.RunAsUserId,e);
                    }
                    //if(test.isRunningTest())
                    //    replyToAddress = 'test@test.com';
                    //Compose email to approver/delegated approver who will receive notification email
                    List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();  
                    for(ProcessInstanceWorkitem processItem : LProcessItem){
                        if(MApproverEmail.containsKey(processItem.actorID)){
                            system.debug('Email Address Size: ' + String.valueof(MApproverEmail.get(processItem.actorID).size()));
                            for(String e : MApproverEmail.get(processItem.actorID)){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if(MDummyCont.containsKey(e)){
                                    mail.setTargetObjectId(MDummyCont.get(e).id);
                                    mail.setWhatId(processItem.processinstance.targetobjectid);                             
                                    EmailServicesAddress ServiceAddress = ServiceAddressDefault;
                                    if(MServiceAddr.containsKey(processItem.actorid)){
                                        ServiceAddress = MServiceAddr.get(processItem.actorid);                                     
                                    }
                                    String replyToAddress = ServiceAddress.LocalPart + '@' + ServiceAddress.EmailDomainName;
                                    System.debug(replyToAddress); 
                                    mail.setReplyTo(replyToAddress); 
                                    mail.setSaveAsActivity(false);
                                    if(Mnpl.containsKey(processItem.processinstance.targetobjectid)){
                                        ASI_FOC_Free_Goods_Request__c tempFoc = Mnpl.get(processItem.processinstance.targetobjectid);
                                        mail.setSenderDisplayName(tempFoc.owner.name);

                                        if(MTemplate.containsKey(tempFoc.ASI_FOC_Email_Notification_Template__c))
                                            mail.setTemplateId(MTemplate.get(tempFoc.ASI_FOC_Email_Notification_Template__c));
                                    }
                                    allMail.add(mail);
                                }
                                
                            }
                        }
                    }
                    system.debug('Mail Size: '+ String.valueof(allMail.size()));
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(allMail);
                    for(integer i=1;i<results.size();i++){
                        if(results.get(i).isSuccess()){
                            system.debug(String.valueof(i)+' is success');
                        }
                        else{
                            system.debug(String.valueof(i)+' error message: ' + results.get(0).getErrors()[0].getMessage());
                        }
                     }
                }
                delete LCont;
            }
            // FOC Item Detail Approval email handling
            else if(objType == 'ASI_FOC_Request_Item__c'){
                Map<id,ASI_FOC_Request_Item__c> Mnpl = new Map<id,ASI_FOC_Request_Item__c>([Select ASI_FOC_Email_Notification_Template__c, ASI_FOC_Request_Order__r.owner.name, id
                    from ASI_FOC_Request_Item__c where id IN :LID order by id]);
                
                List<String> LTemplateName = new List<String>();
                Set<id> SApproverID = new Set<ID>();
                // Loop to include all email template names for approval process
                for(ProcessInstanceWorkitem processItem : LProcessItem){
                    system.debug('processItem targetobjectid: ' + String.valueof(processItem.processinstance.targetobjectid));
                    SApproverID.add(processItem.actorid);
                    if(Mnpl.containsKey(processItem.processinstance.targetobjectid)){
                        system.debug('targetobjectid: ' + String.valueof(processItem.processinstance.targetobjectid));
                        ASI_FOC_Request_Item__c foc = Mnpl.get(processItem.processinstance.targetobjectid);
                        if(foc.ASI_FOC_Email_Notification_Template__c != null){
                            LTemplateName.add(foc.ASI_FOC_Email_Notification_Template__c);
                        }
                    }
                }
                
                System.debug('Number of Approval Request: ' + String.valueof(SApproverID.size()));
                
                //Query Approver info
                List<User> LApprover = [Select id, email, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId from user where id IN: SApproverID];
                Map<id,User> MApprover = new Map<id,User>(LApprover);
                
                //Query Delegated Approver info
                Set<id> SDelApproverID = new Set<id>(); 
                for(User u : LApprover){
                    if(u.DelegatedApproverId != null){
                        SDelApproverID.add(u.DelegatedApproverId);
                    }
                }
                Map<id,User> MDelApprover = new Map<id,User>([Select id, email, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId from user where id IN: SDelApproverID]);
                System.debug('Number of Approver: ' + String.valueof(LApprover.size()));
                System.debug('Number of Delegated Approver: ' + String.valueof(MDelApprover.size()));
                //Filter out approver/delegated approver who receive notification email
                Map<id, List<String>> MApproverEmail = new Map<id,List<String>>();
                List<Contact> LCont = new List<Contact>();
                for(User u : LApprover){
                    List<String> LEmail = new List<String>();
                    if(u.ASI_CN_NPL_Receive_Approval_Request__c == 'If I am an approver or delegated approver' || u.ASI_CN_NPL_Receive_Approval_Request__c == 'Only if I am an approver'){
                        LEmail.add(u.email);
                        LCont.add(new Contact(lastname=string.valueof(u.id),email=u.email));
                        system.debug('Approver Email: ' + u.email);
                    }
                    if(u.DelegatedApproverId != null){
                        if(MDelApprover.containsKey(u.DelegatedApproverId)){
                            User DelApprover = MDelApprover.get(u.DelegatedApproverId);
                            if(DelApprover.ASI_CN_NPL_Receive_Approval_Request__c == 'If I am an approver or delegated approver' || DelApprover.ASI_CN_NPL_Receive_Approval_Request__c == 'Only if I am a delegated approver'){
                                LEmail.add(DelApprover.email);
                                LCont.add(new Contact(lastname=string.valueof(DelApprover.id),email=DelApprover.email));
                                system.debug('Delegated Approver Email: ' + DelApprover.email);
                            }
                        }
                    }
                    MApproverEmail.put(u.id,LEmail);                
                }
                if(LCont != null && LCont.size()>0)
                    insert LCont;
                Map<String, Contact> MDummyCont = new Map<String, Contact>();
                for(Contact c : LCont){
                    MDummyCont.put(c.email, c);
                }
                
                // Query email template id  
                Map<String, id> MTemplate = new Map<String,id>();
                for(EmailTemplate e : [Select id, DeveloperName from EmailTemplate where DeveloperName IN: LTemplateName]){
                    MTemplate.put(e.DeveloperName,e.id);
                }
                if(MTemplate != null){
                    EmailServicesAddress ServiceAddressDefault = [SELECT IsActive, LocalPart, EmailDomainName, RunAsUserId FROM EmailServicesAddress where LocalPart = 'approvalemailservicedefault' and isActive = true limit 1];
                    Map<id, EmailServicesAddress> MServiceAddr = new Map<id,EmailServicesAddress>();
                    for(EmailServicesAddress e : [SELECT IsActive, LocalPart, EmailDomainName, RunAsUserId FROM EmailServicesAddress where LocalPart = 'customapprovalemailservice' and RunAsUserId IN :SApproverID and isActive = true ]){
                        MServiceAddr.put(e.RunAsUserId,e);
                    }
                    //if(test.isRunningTest())
                    //    replyToAddress = 'test@test.com';
                    //Compose email to approver/delegated approver who will receive notification email
                    List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();  
                    for(ProcessInstanceWorkitem processItem : LProcessItem){
                        if(MApproverEmail.containsKey(processItem.actorID)){
                            system.debug('Email Address Size: ' + String.valueof(MApproverEmail.get(processItem.actorID).size()));
                            for(String e : MApproverEmail.get(processItem.actorID)){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if(MDummyCont.containsKey(e)){
                                    mail.setTargetObjectId(MDummyCont.get(e).id);
                                    mail.setWhatId(processItem.processinstance.targetobjectid);                             
                                    EmailServicesAddress ServiceAddress = ServiceAddressDefault;
                                    if(MServiceAddr.containsKey(processItem.actorid)){
                                        ServiceAddress = MServiceAddr.get(processItem.actorid);                                     
                                    }
                                    String replyToAddress = ServiceAddress.LocalPart + '@' + ServiceAddress.EmailDomainName; 
                                    System.debug(replyToAddress);
                                    mail.setReplyTo(replyToAddress); 
                                    mail.setSaveAsActivity(false);
                                    if(Mnpl.containsKey(processItem.processinstance.targetobjectid)){
                                        ASI_FOC_Request_Item__c tempFoc = Mnpl.get(processItem.processinstance.targetobjectid);
                                        mail.setSenderDisplayName(tempFoc.ASI_FOC_Request_Order__r.owner.name);

                                        if(MTemplate.containsKey(tempFoc.ASI_FOC_Email_Notification_Template__c))
                                            mail.setTemplateId(MTemplate.get(tempFoc.ASI_FOC_Email_Notification_Template__c));
                                    }
                                    allMail.add(mail);
                                }
                                
                            }
                        }
                    }
                    system.debug('Mail Size: '+ String.valueof(allMail.size()));
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(allMail);
                    for(integer i=1;i<results.size();i++){
                        if(results.get(i).isSuccess()){
                            system.debug(String.valueof(i)+' is success');
                        }
                        else{
                            system.debug(String.valueof(i)+' error message: ' + results.get(0).getErrors()[0].getMessage());
                        }
                     }
                }
                delete LCont;
            }
            else{
                
            }
        }
    }
}