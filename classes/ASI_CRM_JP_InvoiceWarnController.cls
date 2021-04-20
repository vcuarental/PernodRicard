/*******************************************************************************************
*Name:ASI_CRM_JP_InvoiceWarnController
*Description: Controller for ASI_CRM_JP_InvoiceWarnPage
*
*Histroy:
*Date           Developer Name          Details
*April 12,2016  Hank                    Created 
*
********************************************************************************************/
public with sharing class ASI_CRM_JP_InvoiceWarnController{
    @TestVisible private ASI_CRM_Payment_Invoice__c invoice;
    public ASI_CRM_JP_InvoiceWarnController(ApexPages.StandardController controller) {
        invoice = (ASI_CRM_Payment_Invoice__c)controller.getRecord();
        invoice = [Select ASI_CRM_Invoice_Date__c,
                          ASI_CRM_Payment_Date__c,
                          RecordType.DeveloperName,
                          (Select Id From Attachments),
                          (Select ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_AP_Code__r.ASI_CRM_Attachment__c From Payment_Invoice_Lines__r)
                   From ASI_CRM_Payment_Invoice__c 
                   Where Id =:invoice.Id];
    }
    public Boolean getOverdueFlag(){
        if((invoice.ASI_CRM_Invoice_Date__c !=null && invoice.ASI_CRM_Invoice_Date__c.addDays(-31) >= system.today() && !invoice.RecordType.DeveloperName.contains('FOC')) ||
            (invoice.ASI_CRM_Payment_Date__c !=null && invoice.ASI_CRM_Payment_Date__c.addDays(-31) >= system.today() && invoice.RecordType.DeveloperName.contains('FOC'))){
            return true;
        }else{
            return false;
        }
    }
    public Boolean getAttachFlag(){
        if(invoice.Attachments.size() == 0 && invoice.Payment_Invoice_Lines__r.size() != 0){
            for(ASI_CRM_Payment_Invoice_Line_Item__c item:invoice.Payment_Invoice_Lines__r){
                if(item.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_AP_Code__r.ASI_CRM_Attachment__c == true){
                    return true;
                }
            }
        }
        return false;
    }
    public Boolean getIsFoc(){
        if(invoice.RecordType.DeveloperName.contains('FOC')){
            return true;
        }else{
            return false;
        }
    }
}