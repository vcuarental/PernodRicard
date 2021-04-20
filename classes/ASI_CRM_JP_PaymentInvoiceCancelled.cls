/*********************************************************************************
 * Name:ASI_CRM_JP_PaymentInvoiceCancelled
 * Description: Payment Invoice Trigger to check the status if it's cancelled
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/03/2015       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_PaymentInvoiceCancelled extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_PaymentInvoiceCancelled() {
        super('ASI_CRM_JP_PaymentInvoiceCancelled');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Payment_Invoice__c> pmtList = (List<ASI_CRM_Payment_Invoice__c>)sObjList;
        Map<ID, ASI_CRM_Payment_Invoice__c> pmtMap = (Map<ID, ASI_CRM_Payment_Invoice__c>)oldMap;
        List<ASI_CRM_Payment_Invoice__c> validpmtList = new List<ASI_CRM_Payment_Invoice__c>();
        
        for(ASI_CRM_Payment_Invoice__c pmt : pmtList) {
            if(pmt.ASI_CRM_Status__c == 'Cancelled' && pmtMap.get(pmt.id).ASI_CRM_Status__c != pmt.ASI_CRM_Status__c) {
                validpmtList.add(pmt);
            }
        }
        
        if(validpmtList.size() > 0) {
            
            Set<ID> pmtIdSet = new Set<ID>();
            for(ASI_CRM_Payment_Invoice__c pmt : validpmtList) {
                pmtIdSet.add(pmt.id);
            }
        
            List<ASI_CRM_Payment_Invoice_Line_Item__c> pmtItemList = [SELECT ID, Name, ASI_CRM_Sys_is_cancelled__c 
                                                                        FROM ASI_CRM_Payment_Invoice_Line_Item__c 
                                                                        WHERE ASI_CRM_Payment_Invoice__c IN : pmtIdSet
                                                                        AND ASI_CRM_Sys_is_cancelled__c <> true];
                                                                        
            List<ASI_CRM_Payment_Invoice_Line_Item__c> pmtItemsToUpdate = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();
        
            for(ASI_CRM_Payment_Invoice_Line_Item__c pmItem : pmtItemList) {
                pmItem.ASI_CRM_Sys_is_cancelled__c = true;
                pmtItemsToUpdate.add(pmItem);
            }
        
            if(pmtItemsToUpdate.size() > 0) {
                update pmtItemsToUpdate;
            }
        }
        
    }
    
}