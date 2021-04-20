@RestResource(urlMapping='/LAT_AR_SentReceiptEmaiL/*')

global with sharing class  LAT_AR_SentReceiptEmailWS {
    

    @HttpPost  
    global static void sendEmail(List<String> emailList,String body, string subject, Id recieptId) {
        //query contact  d

        String mensaje = 'Success';
        Boolean resultado = true;
        Boolean esRest = !(RestContext.response==null);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        System.debug('%%%%% emailList : ' +emailList);
        mail.setToAddresses(emailList);
        mail.setReplyTo(UserInfo.getUserEmail());
        mail.setSenderDisplayName(UserInfo.getName());
        mail.setSubject(subject);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody(body);
    
        
      //Set email file attachments
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        List<Attachment> al = [select Id, Name, Body, BodyLength, Parent.Name from Attachment where ParentId = :recieptId order by Createddate DESC];
        // Add to attachment file list
        Boolean found = false;
        for(Attachment att : al){
            System.debug('%%%% att.Name : ' + att.Name);
            System.debug('%%%% att.Parent.Name : ' + att.Parent.Name);
            if (att.Name.contains(att.Parent.Name)) {
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(att.Name);
                efa.setBody(att.Body);
                fileAttachments.add(efa);
                mail.setFileAttachments(fileAttachments);
                found = true;
                System.debug('%%%%% att : ' +att.Id);
                break;
            } 
        }
        if(!found) {
            mensaje        = 'No existe un Attachment (Impresión) para el recibo ingresado.';
            resultado      = false;
        }
        if (resultado) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        //Si estoy en REST devuelvo.s
        if (esRest) {
            if (resultado) {
                RestContext.response.statusCode = 200;
            } else {
                RestContext.response.statusCode = 404;
            }
            
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "id" : "'+recieptId+'", "success": "'+resultado+'", "message": "'+mensaje+'" }');
        }

        
        
    }




}