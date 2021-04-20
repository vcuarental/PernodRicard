public class ASI_MFM_KR_PRSubmitForApprovalCtrl {
    
    Boolean checkAttachNeed = false;
    public id headerID {GET;SET;}
    String Msg = '';
    Set<String> AttachmentTypeSet = new Set<String>();
    List<String> listStrings = new List<String>();    
    
    ASI_MFM_Purchase_Request__c prHeader = new ASI_MFM_Purchase_Request__c();
    List <ASI_MFM_Purchase_Request_Line__c> prLines= new List <ASI_MFM_Purchase_Request_Line__c>();
    public ASI_MFM_KR_PRSubmitForApprovalCtrl(apexpages.standardController sc) {
        
        headerID = sc.getId();
        prHeader = [select id, ASI_MFM_Status__c, ASI_MFM_Service_Item_POSM__c,ASI_MFM_Submit_for_Approval__c,ASI_MFM_Total_Amount__c  from ASI_MFM_Purchase_Request__c where id = :headerID];                  //Header 
        
        //Checking 2: PR Header: type is Service?     &&              PR Line: AP Code need attachment?
        prLines = [select id, name, ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_PR__c  from ASI_MFM_Purchase_Request_Line__c where ASI_MFM_Purchase_Request__c = :headerID];   //Lines
        for (ASI_MFM_Purchase_Request_Line__c Lines : prLines) {
            
            if(Lines.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_PR__c != NULL && prHeader.ASI_MFM_Service_Item_POSM__c == 'Service'){
                checkAttachNeed = true;
                //Msg = 'AP code is attachment needed.';
                AttachmentTypeSet.add(Lines.ASI_MFM_AP_Code__r.ASI_MFM_Attachments_for_PR__c);
            }
            
        }
        
        if(AttachmentTypeSet!=null && AttachmentTypeSet.size()>0){
                            listStrings = new List<String>(AttachmentTypeSet);
                            system.debug('Need Attachment:' + listStrings);

            Msg = String.join(listStrings, ',');
        }
        

        
    }  
    
    
    public pageReference setStatus() { 
        
        if(prHeader.ASI_MFM_Status__c == 'Draft'){
            if(checkAttachNeed){
                //Check attchachment
                List<Attachment> att =    [select id, parentid from attachment where parentid = : headerID];
                if(att.size() >0){
                    prHeader.ASI_MFM_Submit_for_Approval__c=true;
                	update prHeader;
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(headerID);
                    Approval.ProcessResult result = Approval.process(req1);
                    return new pageReference('/' +headerID );
                }
                else{//apexpages.addMessage(new apexpages.Message(apexpages.severity.error, Msg + 'Please upload attachment.'));
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Need attachment: '+ msg));
                    return null;
                }
            }
            else if (prLines.size()==0){
                apexpages.addMessage(new apexpages.Message(apexpages.severity.error, Msg + 'Purchase Request Line needed.'));
                return null;
            }else if(prHeader.ASI_MFM_Total_Amount__c<=0){
                 apexpages.addMessage(new apexpages.Message(apexpages.severity.error, Msg + 'Cannot submit for approval. Total Amount smaller than 0.'));
                return null;
            }
            else{
                prHeader.ASI_MFM_Submit_for_Approval__c=true;
                update prHeader;
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(headerID);
                try{
                    Approval.ProcessResult result = Approval.process(req1);
                    return new pageReference('/' +headerID );
                }catch(exception ex){
                 	apexpages.addMessage(new apexpages.Message(apexpages.severity.error,  ex.getMessage()));
                    return null;    
                }
                
                
            }
        } else if(prHeader.ASI_MFM_Status__c == 'Rejected'){  
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error,  'Cannot submit for approval. Please set this PR to Draft.'));
            return null;    
        }else{
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error,  'Cannot submit for approval. This Purchase Request is already submitted.'));
            return null;            
        }
    }
    
    
}