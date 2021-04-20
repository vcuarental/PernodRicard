/*
Develop by Stella Sing,  2013-12-18              
Goal: Prompt a page for sending the po url to supplier

1. Lookup Supplier's Email for addressee
2. Send the email with attachment and bcc specific email

*/

public without sharing class ASI_MFM_PO_SEND_PDF_Controller {
    
    private ApexPages.StandardController c;
    public String subject{get;set;}
    public String body {get;set;}
    public List <String> ToAddresses{get;set;}
    public ASI_MFM_PO__c item {set;get;}
    
    public boolean showResult {set;get;}
    public boolean showError {set;get;}
    public string result {set;get;}
    public string exMsg {set;get;}
    public boolean debugMode {set;get;}
    public string debugMsg {set;get;}
    
    public ASI_MFM_PO_SEND_PDF_Controller (ApexPages.StandardController stdController){ 
    
        showResult = false;
        debugMode = false;
        c = stdController;
        item = (ASI_MFM_PO__c)stdController.getRecord();
        subject = 'Purchase Order from Pernod Ricard';
        body = 'Please refer to the Purchase Order attached.';
        }

    public void send() 
    {
        try{
            ASI_MFM_PO__c itemR = [SELECT id,name, recordTypeId, ASI_MFM_Supplier_Name__c,ASI_MFM_TR_Supplier_Email__c, ASI_MFM_Supplier_Name__r.ASI_LUX_Email_Business__c,  ASI_MFM_Supplier_Name__r.Name
                                   FROM ASI_MFM_PO__c WHERE id =:item.ID];
            
            ID userid = UserInfo.getUserId();
            User currentUser = [SELECT Id, Email FROM User WHERE Id =:userid];
            
            // Define the Addressee        
            ToAddresses = new List <String>();
            if (Global_RecordTypeCache.getRt(itemR.recordTypeId).developerName.contains('ASI_MFM_TR')){
                ToAddresses.add(itemR.ASI_MFM_TR_Supplier_Email__c);
            }
            else if (Global_RecordTypeCache.getRt(itemR .recordTypeId).developerName.contains('ASI_MFM_GF')){
                List<String> emails = itemR.ASI_MFM_TR_Supplier_Email__c.split(';');
                
                for (String email:emails){
                    ToAddresses.add(email);
                }
            }
            // [SH] 2019-04-02
            else if (Global_RecordTypeCache.getRt(itemR .recordTypeId).developerName.contains('ASI_MFM_MY')){
                if(itemR.ASI_MFM_TR_Supplier_Email__c != null){
                    ToAddresses.add(itemR.ASI_MFM_TR_Supplier_Email__c);
                }else{
                    ToAddresses.add(itemR.ASI_MFM_Supplier_Name__r.ASI_LUX_Email_Business__c);
                }
            }
            // END - SH
            else{                
                ToAddresses.add(itemR.ASI_MFM_Supplier_Name__r.ASI_LUX_Email_Business__c);
            }
            // Define the BCC Addressee
            List<String> bccAddr = new List<String>();
            bccAddr.add(currentUser.Email);
            
            // Define the email 
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            
            // VF PDF Pafe to send
            PageReference pdf =  Page.ASI_MFM_PO_PDF_Page;
            if (Global_RecordTypeCache.getRt(itemR .recordTypeId).developerName.contains('ASI_MFM_CN')){
                pdf = Page.ASI_MFM_CN_PO_PDF_Page;
            }
            else if (Global_RecordTypeCache.getRt(itemR .recordTypeId).developerName.contains('ASI_MFM_GF')){
                pdf = Page.ASI_MFM_GF_PO_PDF_Page;
            }
            else if (Global_RecordTypeCache.getRt(itemR .recordTypeId).developerName.contains('ASI_MFM_MY')){
                pdf = Page.ASI_MFM_MY_PO_PDF_Page;
            }
            else if (Global_RecordTypeCache.getRt(itemR .recordTypeId).developerName.contains('ASI_MFM_TR')){
                pdf = Page.ASI_MFM_TR_PO_PDF_Page;
            }
            
            if (!Global_RecordTypeCache.getRt(itemR .recordTypeId).developerName.contains('ASI_MFM_TR')){
                pdf.getParameters().put('id',item.id); 
                pdf.setRedirect(true);
                
                // Take the PDF content
                Blob b = pdf.getContent();
                
                // Create the email attachment
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setContentType('application/pdf');
                efa.setFileName('PO-'+itemR.name+'.pdf');
                efa.setBody(b);
                
                email.setSubject( subject );
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa}); 
                email.setPlainTextBody( body );
            }else
            {
                EmailTemplate et = [Select id from EmailTemplate where DeveloperName = 'ASI_MFM_TR_POSupplier_Email_Template'];
                System.debug('TR Email Template:' + et);
                
                email.setTemplateId(et.id);
                email.setTargetObjectId(currentUser.id);
                email.setWhatId(itemR.Id);
                email.saveAsActivity = false;
            }
            
            // Sets the paramaters of the email 
            
            email.setToAddresses( ToAddresses );
            email.setBccAddresses( bccAddr );
            
            // Sends the email 
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
            
            // Show sent result                
            showResult = true;
            result = 'Email sent successfully! Close this page to proceed.';
            
            //return null;
        }
        catch (Exception e){
            showResult = true;
            showError = true;
            result = 'Error occured. Please contact system administrator!';
            exMsg = e.getMessage();
            exMsg += e.getStackTraceString();
        }
    }
}