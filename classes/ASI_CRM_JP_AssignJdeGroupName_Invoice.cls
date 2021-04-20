/**********************************************************************************
 * Name : ASI_CRM_SG_ContractCloneController
 * Created : DC @04/06/2016 1:34 PM
 * Revision History:
 * 1. 04/06/2016 - [DC 1.0] Created
 **********************************************************************************/

public with sharing class ASI_CRM_JP_AssignJdeGroupName_Invoice {

    public List<ASI_CRM_Payment_Invoice__c> assignGroupName(List<ASI_CRM_Payment_Invoice__c> pLstSelectedInvoices) {
        List<ASI_CRM_Payment_Invoice__c> lstSelectedInvoices = pLstSelectedInvoices;
        
        ASI_CRM_JP_AutoNumberAssignment autoNumAssign = null;
        for (ASI_CRM_Payment_Invoice__c selectedInvoice : lstSelectedInvoices )
        {
            autoNumAssign = new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_PaymentInvoice_JDE_Group_Name');
            selectedInvoice.ASI_CRM_JDE_Group_Name__c = autoNumAssign.nextAutoNumStr();
        }
        
        if (autoNumAssign != null)
            autoNumAssign.writeToDB();

        return lstSelectedInvoices;
    }

}