/*********************************************************************************
 * Name:ASI_CRM_JP_InvoiceItemUpdateApprover
 * Description: Update Invoice Approver when updating items
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/12/2014       Laputa: Hank          Created
 * 01/10/2019       Wilken Lee            [WL 1.0] Change security to without sharing to cater approver need to edit line item
*********************************************************************************/

public without sharing class ASI_CRM_JP_InvoiceItemUpdateApprover extends ASI_CRM_JP_TriggerAbstract{ //WL 1.0

    public ASI_CRM_JP_InvoiceItemUpdateApprover() {
        super('ASI_CRM_JP_InvoiceItemUpdateApprover');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        Set<Id> invoiceIdSet = new Set<Id>();
        if (oldMap == null) {
            List<ASI_CRM_Payment_Invoice_Line_Item__c> itemList = (List<ASI_CRM_Payment_Invoice_Line_Item__c>)sObjList;
            for (ASI_CRM_Payment_Invoice_Line_Item__c item : itemList) {
                invoiceIdSet.add(item.ASI_CRM_Payment_Invoice__c);   
            }
        }
        else if (sObjList != null){
            List<ASI_CRM_Payment_Invoice_Line_Item__c> itemList = (List<ASI_CRM_Payment_Invoice_Line_Item__c>)sObjList;
            Map<ID, ASI_CRM_Payment_Invoice_Line_Item__c> oldDetailMap = (Map<ID, ASI_CRM_Payment_Invoice_Line_Item__c>) oldMap;
            for (ASI_CRM_Payment_Invoice_Line_Item__c item: itemList) {
                invoiceIdSet.add(item.ASI_CRM_Payment_Invoice__c); 
            }
        } else {
            Map<ID, ASI_CRM_Payment_Invoice_Line_Item__c> oldDetailMap = (Map<ID, ASI_CRM_Payment_Invoice_Line_Item__c>) oldMap;
            for (ASI_CRM_Payment_Invoice_Line_Item__c item: oldDetailMap.Values()) {
                invoiceIdSet.add(item.ASI_CRM_Payment_Invoice__c); 
            }
        }
        List<ASI_CRM_Payment_Invoice__c> invoiceList = [Select Id, Name From ASI_CRM_Payment_Invoice__c Where Id In :invoiceIdSet];
        update invoiceList;
    }
}