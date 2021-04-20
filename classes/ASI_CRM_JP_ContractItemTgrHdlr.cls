/*********************************************************************************
 * Name:ASI_CRM_JP_ContractItemTgrHdlr
 * Description: Purchase Contract Line Item Trigger Handler for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_ContractItemTgrHdlr extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_ContractItemTgrHdlr() {
        super('ASI_CRM_JP_ContractItemTgrHdlr');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        Set<Id> itemIdSet = new Set<Id>();
        List<ASI_CRM_Purchase_Contract_Line_Item__c> itemList = (List<ASI_CRM_Purchase_Contract_Line_Item__c>)sObjList;
        if (oldMap == null) {
            for (ASI_CRM_Purchase_Contract_Line_Item__c item : itemList) {
                
            } 
        }
        else {
            Map<ID, ASI_CRM_Purchase_Contract_Line_Item__c> oldDetailMap = (Map<ID, ASI_CRM_Purchase_Contract_Line_Item__c>) oldMap;
            for (ASI_CRM_Purchase_Contract_Line_Item__c item: itemList) {
                if(item.ASI_CRM_AP_Code__c != oldDetailMap.get(item.Id).ASI_CRM_AP_Code__c){
                    itemIdSet.add(item.Id);
                }   
            }
        }
        
        Map<Id,ASI_CRM_Purchase_Contract_Line_Item__c> itemMap = new Map<Id,ASI_CRM_Purchase_Contract_Line_Item__c>([Select Id,
                                                                                                                            ASI_CRM_Purchase_Contract__r.RecordType.DeveloperName, 
                                                                                                                            (Select ASI_CRM_Payment_Invoice__r.ASI_CRM_Status__c From Payment_Invoice_Line_Items__r)
                                                                                                                     From ASI_CRM_Purchase_Contract_Line_Item__c
                                                                                                                     Where Id In:itemIdSet]);
        if (oldMap == null) {
            for (ASI_CRM_Purchase_Contract_Line_Item__c item : itemList) {
                
            } 
        }
        else {
            Map<ID, ASI_CRM_Purchase_Contract_Line_Item__c> oldDetailMap = (Map<ID, ASI_CRM_Purchase_Contract_Line_Item__c>) oldMap;
            for (ASI_CRM_Purchase_Contract_Line_Item__c item: itemList) {
                if(item.ASI_CRM_AP_Code__c != oldDetailMap.get(item.Id).ASI_CRM_AP_Code__c){
                    system.debug('Checkpoint 1');
                    if(itemMap.get(item.Id).ASI_CRM_Purchase_Contract__r.RecordType.DeveloperName.Contains('ASI_CRM_JP_SPTD_Contract_Read_Only')){
                        system.debug('Checkpoint 2');
                        for(ASI_CRM_Payment_Invoice_Line_Item__c line:itemMap.get(item.Id).Payment_Invoice_Line_Items__r){
                            system.debug('Checkpoint 3:' + line.ASI_CRM_Payment_Invoice__r.ASI_CRM_Status__c);
                            if(line.ASI_CRM_Payment_Invoice__r.ASI_CRM_Status__c != null && (
                                    line.ASI_CRM_Payment_Invoice__r.ASI_CRM_Status__c == 'Final' ||
                                    line.ASI_CRM_Payment_Invoice__r.ASI_CRM_Status__c == 'Complete' ||
                                    line.ASI_CRM_Payment_Invoice__r.ASI_CRM_Status__c == 'Approved' ||
                                    line.ASI_CRM_Payment_Invoice__r.ASI_CRM_Status__c == 'Final' ||
                                    line.ASI_CRM_Payment_Invoice__r.ASI_CRM_Status__c == 'Complete' ||
                                    line.ASI_CRM_Payment_Invoice__r.ASI_CRM_Status__c == 'Partial Complete' ||
                                    line.ASI_CRM_Payment_Invoice__r.ASI_CRM_Status__c == 'Shipment Cancelled'
                                    )){
                                item.addError(System.Label.ASI_CRM_JP_CannotChangeAPCode);
                            }
                        }
                    }  
                }   
            }
        }                                                                                                   
    }
}