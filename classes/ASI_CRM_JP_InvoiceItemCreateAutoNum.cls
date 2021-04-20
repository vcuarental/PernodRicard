/*********************************************************************************
 * Name:ASI_CRM_JP_InvoiceItemCreateAutoNum
 * Description: Create auto number for invoice line item
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 4/30/2015       Laputa: Hank             Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_InvoiceItemCreateAutoNum extends ASI_CRM_JP_TriggerAbstract{

    public ASI_CRM_JP_InvoiceItemCreateAutoNum() {
        super('ASI_CRM_JP_InvoiceItemCreateAutoNum');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        Set<Id> invoiceIdSet = new Set<Id>();
        if (oldMap == null) {
            List<ASI_CRM_Payment_Invoice_Line_Item__c> itemList = (List<ASI_CRM_Payment_Invoice_Line_Item__c>)sObjList;
            for (ASI_CRM_Payment_Invoice_Line_Item__c item : itemList) {
                if(Global_RecordTypeCache.getRt(item.recordTypeid).developerName.contains('ASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item')){
                    invoiceIdSet.add(item.ASI_CRM_Payment_Invoice__c); 
                }  
            }
        }
        List<ASI_CRM_Payment_Invoice__c> invoiceList = [Select Id, ASI_CRM_Sys_Next_Auto_Number__c, (Select Id, ASI_CRM_Auto_Number__c From Payment_Invoice_Lines__r)
                                                        From ASI_CRM_Payment_Invoice__c Where Id In :invoiceIdSet];
        List<ASI_CRM_Payment_Invoice_Line_Item__c> itemList = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();
        for(ASI_CRM_Payment_Invoice__c invoice:invoiceList){
            for(ASI_CRM_Payment_Invoice_Line_Item__c item:invoice.Payment_Invoice_Lines__r){
                if(item.ASI_CRM_Auto_Number__c == null){
                    item.ASI_CRM_Auto_Number__c = invoice.ASI_CRM_Sys_Next_Auto_Number__c;
                    invoice.ASI_CRM_Sys_Next_Auto_Number__c = invoice.ASI_CRM_Sys_Next_Auto_Number__c + 1;
                    itemList.add(item);
                }
            }
        }
        if(invoiceList.size() >0){
            update invoiceList;
            update itemList;
        }
    }
}