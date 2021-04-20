public without sharing class ASI_CRM_TW_Pass_Order_TriggerCls{
    public static void routineBeforeUpsert(list<ASI_CRM_Pass_Order__c> trigger_new, map<id, ASI_CRM_Pass_Order__c> trigger_oldMap) {
        Set<Id> setAccId = new Set<Id>();
        Map<Id, ASI_CRM_AccountsAdditionalField__c> mapCust = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
    
        for(ASI_CRM_Pass_Order__c order : trigger_new){
            setAccId.add(order.ASI_CRM_Account__c);
        }
        
        for(ASI_CRM_AccountsAdditionalField__c cust : [SELECT id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN: setAccId]){
            mapCust.put(cust.ASI_CRM_Account__c, cust);
        }
        
        for(ASI_CRM_Pass_Order__c order : trigger_new){
            if(mapCust != null && mapCust.get(order.ASI_CRM_Account__c) != null)
                order.ASI_CRM_Customer__c = mapCust.get(order.ASI_CRM_Account__c).Id;
        }
    }
}