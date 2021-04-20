/*********************************************************************************
 * Name:ASI_CRM_JP_AssignAutoNumber_Invoice
 * Description: Class to Assign Custom Auto Number to Contract No. JP Specific
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/11/2014       Laputa: Conrad          Created
 * 19/03/2015       Laputa: Conrad          Created logic to differentiate autonumber depending on recordtype
*********************************************************************************/

public with sharing class ASI_CRM_JP_AssignAutoNumber_Invoice extends ASI_CRM_JP_TriggerAbstract {


    public ASI_CRM_JP_AssignAutoNumber_Invoice() {
        super('ASI_CRM_JP_AssignAutoNumber_Contract');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<ASI_CRM_Payment_Invoice__c> validInvoiceList = (List<ASI_CRM_Payment_Invoice__c>)sObjList;
        List<ASI_CRM_JP_AutoNumberAssignment> autoNumAssignList = new List<ASI_CRM_JP_AutoNumberAssignment>();
        ASI_CRM_JP_AutoNumberAssignment autoNumAssignRebate = new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_PaymentInvoice_Rebate_No');
        ASI_CRM_JP_AutoNumberAssignment autoNumAssignCash = new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_PaymentInvoice_Cash_No');
        ASI_CRM_JP_AutoNumberAssignment autoNumAssignSPTD = new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_PaymentInvoice_No');
        autoNumAssignList.add(autoNumAssignRebate);
        autoNumAssignList.add(autoNumAssignCash);
        autoNumAssignList.add(autoNumAssignSPTD);
        //ASI_CRM_JP_AutoNumberAssignment autoNumAssign = null;
        for (ASI_CRM_Payment_Invoice__c validInvoice : validInvoiceList )
        {
            if(Global_RecordTypeCache.getRt(validInvoice.recordTypeid).developerName.contains('Rebate')){
                //autoNumAssign = new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_PaymentInvoice_Rebate_No');
                validInvoice.name = autoNumAssignRebate.nextAutoNumStr();
            }else if(Global_RecordTypeCache.getRt(validInvoice.recordTypeid).developerName.contains('ASI_CRM_JP_Cash_Invoice')){
                //autoNumAssign = new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_PaymentInvoice_Cash_No');
                validInvoice.name = autoNumAssignCash.nextAutoNumStr();
            }else{
                //autoNumAssign = new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_PaymentInvoice_No');
                validInvoice.name = autoNumAssignSPTD.nextAutoNumStr();
            }
        }
        
        for(ASI_CRM_JP_AutoNumberAssignment autoNumAssign:autoNumAssignList){
            autoNumAssign.writeToDB();
        }
    }
}