/*********************************************************************************
 * Name:ASI_CRM_JP_ContractItemUpdateApprover
 * Description: Update Contract Approver when updating items
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/12/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_ContractItemUpdateApprover extends ASI_CRM_JP_TriggerAbstract{

    public ASI_CRM_JP_ContractItemUpdateApprover() {
        super('ASI_CRM_JP_ContractItemUpdateApprover');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        Set<Id> contIdSet = new Set<Id>();
        if (oldMap == null) {
            List<ASI_CRM_Purchase_Contract_Line_Item__c> itemList = (List<ASI_CRM_Purchase_Contract_Line_Item__c>)sObjList;
            for (ASI_CRM_Purchase_Contract_Line_Item__c item : itemList) {
                contIdSet.add(item.ASI_CRM_Purchase_Contract__c);   
            }
        }
        else if (sObjList != null){
            List<ASI_CRM_Purchase_Contract_Line_Item__c> itemList = (List<ASI_CRM_Purchase_Contract_Line_Item__c>)sObjList;
            Map<ID, ASI_CRM_Purchase_Contract_Line_Item__c> oldDetailMap = (Map<ID, ASI_CRM_Purchase_Contract_Line_Item__c>) oldMap;
            for (ASI_CRM_Purchase_Contract_Line_Item__c item: itemList) {
                contIdSet.add(item.ASI_CRM_Purchase_Contract__c); 
            }
        } else {
            Map<ID, ASI_CRM_Purchase_Contract_Line_Item__c> oldDetailMap = (Map<ID, ASI_CRM_Purchase_Contract_Line_Item__c>) oldMap;
            for (ASI_CRM_Purchase_Contract_Line_Item__c item: oldDetailMap.Values()) {
                contIdSet.add(item.ASI_CRM_Purchase_Contract__c); 
            }
        }
        List<ASI_CRM_Purchase_Contract__c> contList = [Select Id, Name From ASI_CRM_Purchase_Contract__c Where Id In :contIdSet];
        update contList;
    }
}