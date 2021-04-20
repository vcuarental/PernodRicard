/*********************************************************************************
 * Name:ASI_CRM_JP_SetStatusDraftController
 * Description: Set Status to Draft for Invoice 'Set Status Draft' button
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -------------------------------------
 * 103/2015       Laputa: Hank          Created
*********************************************************************************/
public without sharing class ASI_CRM_JP_SetStatusDraftController{
    private ASI_CRM_Payment_Invoice__c invoice;
    public ASI_CRM_JP_SetStatusDraftController(ApexPages.StandardController controller){
        invoice = (ASI_CRM_Payment_Invoice__c)controller.getRecord();
        invoice = [Select ASI_CRM_Status__c, ownerId From ASI_CRM_Payment_Invoice__c Where Id = :invoice.Id];
    }
    public PageReference save(){
        invoice.ASI_CRM_Status__c = 'Draft';
        update invoice;
        PageReference invoicePage = new ApexPages.StandardController(invoice).view();
        invoicePage.setRedirect(true);
        return invoicePage;
    }
}