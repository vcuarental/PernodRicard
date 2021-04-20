public with sharing class ASI_CRM_JP_FinalPrintController{
    private ASI_CRM_Payment_Invoice__c invoice;
    
    private static Boolean alreadyInitRT = false; 
    
    public ASI_CRM_JP_FinalPrintController(ApexPages.StandardController controller){
        invoice = (ASI_CRM_Payment_Invoice__c)controller.getRecord();
        invoice = [Select ASI_CRM_Status__c From ASI_CRM_Payment_Invoice__c Where Id = :invoice.Id];
    }
    
    public PageReference save(){
        try {
            if(invoice.ASI_CRM_Status__c == 'Draft'){
                invoice.ASI_CRM_Status__c = 'Approval In Progress';
                update invoice;
            }
        } catch (exception ex) {
            invoice.adderror(ex.getDmlMessage(0));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDmlMessage(0) + ' Click<a href="/' + invoice.Id +'" target="_parent">here</a>to go back to the record.'));
            //Database.rollback(sp);
            return null;
        }
        
        PageReference invoicePage = new ApexPages.StandardController(invoice).view();
        invoicePage.setRedirect(true);
        return invoicePage;
    }
}