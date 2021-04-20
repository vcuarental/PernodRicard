@RestResource(urlMapping='/attachContractPDFContent/*')
global without sharing class EUR_CRM_DE_AttachContractPDFContent{

    /*@HttpPost
    global static void attachContractPDFContent(String contractIds) {
        String BASIC_CONTRACT = 'Basic Contract';
        String CONCEPT_CONTRACT = 'Concept Contract';
        String STANDARD_CONTRACT = 'Standard Contract';

        List<String> contractIdList = contractIds.split(',');
        
        List<EUR_CRM_Contract__c> contracts = [select id,EUR_CRM_Contract_Sub_Type__c,EUR_CRM_Contract_Copy_File_Name__c
             from EUR_CRM_Contract__c where id in: contractIdList];

        List<Attachment> attachments = new List<Attachment>();
        for(EUR_CRM_Contract__c contract : contracts){
            
            Id contractId = contract.id;
            
            if(contractId == null)
                continue;

            PageReference pdf = null;
            
            if(contract.EUR_CRM_Contract_Sub_Type__c == BASIC_CONTRACT){
                pdf = Page.EUR_CRM_DE_ContractPDF_Basic;     
            }else if(contract.EUR_CRM_Contract_Sub_Type__c == CONCEPT_CONTRACT){
                pdf = Page.EUR_CRM_DE_ContractPDF_Concept;
            }else{
                return;
            } 
            pdf.getParameters().put('id',contractId);

            Attachment attach = new Attachment(); 
            Blob body;
            String fileName = contract.EUR_CRM_Contract_Copy_File_Name__c == null ? 'CONTRACT_PDF_NO_NAME' : contract.EUR_CRM_Contract_Copy_File_Name__c ;
            try {
                body = pdf.getContent(); 
            } catch (VisualforceException e) {
                body = Blob.valueOf('Some Text');
            } 
            attach.Body = body;
            attach.Name = fileName + '.pdf';
            attach.IsPrivate = false; 
            attach.ParentId = contractId; 
            attachments.add(attach);
        }
        insert attachments;
    }*/

    // @HttpPost
    global static void attachContractPDFContent(String contractId, String contractSubType, String contractFileName) {
        System.debug('@@EUR_CRM_DE_AttachContractPDFContentattachContractPDFContent');
        String BASIC_CONTRACT = 'Basic Contract';
        String CONCEPT_CONTRACT = 'Concept Contract';
        String STANDARD_CONTRACT = 'Standard Contract';

        Attachment attach = new Attachment();
        PageReference pdf = null;

        System.debug(contractId);
        System.debug(contractSubType);
        System.debug(contractFileName);

        if(contractSubType == BASIC_CONTRACT) {
            pdf = Page.EUR_CRM_DE_ContractPDF_Basic;
        } else if(contractSubType == CONCEPT_CONTRACT) {
            pdf = Page.EUR_CRM_DE_ContractPDF_Concept;
        } else {
            return;
        }
        pdf.getParameters().put('id', contractId);

        Blob body;
        String fileName = contractFileName == null ? 'CONTRACT_PDF_NO_NAME' : contractFileName ;
        try {
            body = pdf.getContent();
        } catch (VisualforceException e) {
            body = Blob.valueOf('Some Text');
        }
        attach.Body = body;
        attach.Name = fileName + '.pdf';
        attach.IsPrivate = false;
        attach.ParentId = contractId;

        System.debug(attach);
        insert attach;
    }

    @Future(Callout=true)
    global static void attachPDFToContractAsync(String contractId, String sessionId) {
        EUR_CRM_Contract__c contract = [SELECT Id,EUR_CRM_Contract_Sub_Type__c,EUR_CRM_Contract_Copy_File_Name__c FROM EUR_CRM_Contract__c WHERE Id=:contractId];
        attachContractPDFContent(contract.Id, contract.EUR_CRM_Contract_Sub_Type__c, contract.EUR_CRM_Contract_Copy_File_Name__c);
    }

    global static void attachPDFToContract(EUR_CRM_Contract__c contract, String sessionId) {
        System.debug(sessionId);
        System.debug(contract);

        attachContractPDFContent(contract.Id, contract.EUR_CRM_Contract_Sub_Type__c, contract.EUR_CRM_Contract_Copy_File_Name__c);

        /*String bUrl = URL.getSalesforceBaseUrl().toExternalForm();
        bUrl = bUrl.toLowerCase(); 
        String addr = bUrl + '/services/apexrest/attachContractPDFContent';
        HttpRequest req = new HttpRequest();
        req.setEndpoint( addr );
        req.setMethod('POST');
        req.setHeader('Authorization', 'OAuth ' + sessionId);
        req.setHeader('Content-Type','application/json');
        req.setTimeout(60000);

        Map<String,String> postBody = new Map<String,String>();
        postBody.put('contractId',contract.Id);
        postBody.put('contractSubType', contract.EUR_CRM_Contract_Sub_Type__c);
        postBody.put('contractFileName', contract.EUR_CRM_Contract_Copy_File_Name__c);
        String reqBody = JSON.serialize(postBody);
        req.setBody(reqBody);
        //req.setBody('contractId=' + contract.Id + '&contractSubType=' + contract.EUR_CRM_Contract_Sub_Type__c.split(' ')[0] + '&contractFileName=' + contract.EUR_CRM_Contract_Copy_File_Name__c);

        Http http = new Http();
        HttpResponse response = null;
        Boolean sendEmail = true;
        Boolean check = true;
        List<EUR_CRM_Contract__c> contracts = new List<EUR_CRM_Contract__c>{contract};
        List<Note> insertNotes = new List<Note>(); 
        List<Attachment> toDeleteAttach = new List<Attachment>();
        Set<Id> attach = new Set<Id>();
        //for(Integer i = 0 ; i < 5 ; i++){
            try{  
                response = http.send(req);
                if(response.getStatusCode() == 200){
                    sendEmail = false;
                    break;
                }
            }catch(CalloutException e){
                system.debug('Error attaching contract pdf: ' + e);
                system.debug(i + ' try');
                List<Attachment> temp = checkAndRemoveContractAttachments(contracts);
                if(temp != null && temp.size() > 0){
                for(Attachment a : temp){
                    if(!attach.contains(a.id)){
                        toDeleteAttach.add(a);
                        attach.add(a.id);
                    }
                }
            }
                check =false; 
                 continue;
            }
        //}

        System.debug(response);
        if(sendEmail || response == null || response.getStatusCode() != 200  ){

            if(check){
                checkAndRemoveContractAttachments(contracts);
                
                List<Attachment> temp = checkAndRemoveContractAttachments(contracts);
                if(temp != null && temp.size() > 0){
                for(Attachment a : temp){
                    if(!attach.contains(a.id)){
                        toDeleteAttach.add(a);
                        attach.add(a.id);
                    }
                }
                }
             }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setToAddresses(new String[]{UserInfo.getUserEmail()}); 
            mail.setSubject(Label.EUR_CRM_AutoAttachContractPdfFail_Subject); 
            String htmlBody = Label.EUR_CRM_AutoAttachContractPdfFail_Body;
              
           // List<Note> insertNotes = new List<Note>(); 
            for(EUR_CRM_Contract__c c: contracts){
              htmlBody +=  '<br/> <a href="' + bUrl + '/' + c.id +'">'+c.name +' </a>';
                Note n = new Note();
                n.title = Label.EUR_CRM_AutoAttachContractPdfFail_Subject;
                n.ParentId = c.id;
                insertNotes.add(n);
            } 
            mail.setHtmlBody(htmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailmessage[] {mail});
            system.debug('insertNotes' + insertNotes);
            if(insertNotes != null && insertNotes.size() > 0 && !Test.isRunningtest())
                insert insertNotes;
            if(toDeleteAttach != null && toDeleteAttach.size() > 0 && !Test.isRunningtest())
                delete toDeleteAttach;
         }*/
    }
/*
    public static List<Attachment> checkAndRemoveContractAttachments(List<EUR_CRM_Contract__c> contracts){
      
        Set<String> pdfNames = new Set<String>(); 
        pdfNames.add('CONTRACT_PDF_NO_NAME.pdf');
           Set<String> contractIds = new Set<String>(); 
      
        system.debug('### pdfNames' + pdfNames);
        List<Attachment> attachments = [select id from Attachment where ParentId in: contractIds and name in: pdfNames];
       // if(attachments != null && attachments.size() > 0)
       return attachments;
    }
*/

/*
        PageReference ref = Page.PDF_DEMO;
        Blob b = ref.getContentAsPDF();

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
        efa1.setFileName('attachment_WORK.pdf');
        efa1.setBody(b);

        String addresses;
        email.setSubject( Subject +String.valueOf(DateTime.now()));
        email.setToAddresses( EmailIds  );
        email.setPlainTextBody(Body);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        */

}