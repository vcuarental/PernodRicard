/*********************************************************************************
 * Name:ASI_CRM_JP_PaymentInvoicePDFExtension
 * Description: Update fields when creating Pdfs
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2/12/2014       Laputa: Hank          Created
*********************************************************************************/
public with sharing class ASI_CRM_JP_PaymentInvoicePDFExtension{
    public String action {get;set;}
    public String marginValue {get;set;}
    public String firstMarginValue {get;set;}
    private ASI_CRM_Payment_Invoice__c invoice; 
    private Id paymentId;
    
    public ASI_CRM_JP_PaymentInvoicePDFExtension(ApexPages.StandardController controller) {
        invoice = (ASI_CRM_Payment_Invoice__c )controller.getRecord();
        invoice = [Select Id, ASI_CRM_Status__c,RecordType.DeveloperName From ASI_CRM_Payment_Invoice__c Where Id = :invoice.Id];
        action = ApexPages.currentPage().getParameters().get('action');
        paymentId = ApexPages.currentPage().getParameters().get('Id');

        // DC - 04/26/2016 - 
        setMargin();
    }
    
    public void checkForUpdate(){
        //system.debug('Check point 1 ' + action);
        //if(action!=null && 'finalPrint'.equals(action)){
        //    system.debug('Check point 2 ' + 'finalPrint'.equals(action));
        //    if (invoice.ASI_CRM_Status__c == 'Draft'){
        //        system.debug('Check point 3 ' + invoice.ASI_CRM_Status__c);
        //        invoice.ASI_CRM_Status__c = 'Approval In Progress';
        //        update invoice;
        //    }
        //}
    }
    // DC - 04/26/2016 - Created Method to set page margin according to Record type
    public void setMargin(){

        if(invoice.RecordType.DeveloperName.contains('ASI_CRM_JP_SPTD_FOC_Invoice'))   {
                marginValue = '220px';
                firstMarginValue = '190px';
        } else 
        if(invoice.RecordType.DeveloperName.contains('ASI_CRM_JP_SPTD_Cash_Invoice'))   {
                marginValue = '280px';
                firstMarginValue = '215px';
        } else 
        if(invoice.RecordType.DeveloperName.contains('ASI_CRM_JP_Indirect_Rebate_Invoice'))   {
                marginValue = '250px';
                firstMarginValue = '250px';
        }else if(invoice.RecordType.DeveloperName.contains('ASI_CRM_JP_Cash_Invoice')){
                marginValue = '300px';
                firstMarginValue = '270px';
        }

    }
}