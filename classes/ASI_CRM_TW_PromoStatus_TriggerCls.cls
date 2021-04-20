/* Filename:   ASI_CRM_TW_PromoStatus_TriggerCls.cls
* Author:      Twinkle LI (Introv Limited)
* Purpose:     Handle TW Promotion Status Trigger Logic
*/

public with sharing class ASI_CRM_TW_PromoStatus_TriggerCls{
    public static void routineBeforeInsert(list<ASI_CRM_Promotion_Status__c> trigger_new, map<id, ASI_CRM_Promotion_Status__c> trigger_oldMap){
        Set<Id> setAccId = new Set<Id>();
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
        Map<Id, ASI_CRM_AccountsAdditionalField__c> mapAccId = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_Promotion_Status__c ps: trigger_new){
            if(ps.ASI_CRM_Account__c != NULL)
                SetAccId.add(ps.ASI_CRM_Account__c);        
        }
        
        if(!(SetAccId).IsEmpty())
            listCustomer = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN:SetAccId];        
        for(ASI_CRM_AccountsAdditionalField__c cust : listCustomer){
            if(cust.ASI_CRM_Account__c != NULL)
                mapAccId.put(cust.ASI_CRM_Account__c, cust);
        }     
        
        for(ASI_CRM_Promotion_Status__c ps: trigger_new){
            if(ps.ASI_CRM_Account__c != NULL && mapAccId.get(ps.ASI_CRM_Account__c) != NULL)
                ps.ASI_CRM_Customer__c = mapAccId.get(ps.ASI_CRM_Account__c).id;           
        }  
    }
    
    public static void routineBeforeUpdate(list<ASI_CRM_Promotion_Status__c> trigger_new, map<id, ASI_CRM_Promotion_Status__c> trigger_oldMap){
        Set<Id> setAccId = new Set<Id>();
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
        Map<Id, ASI_CRM_AccountsAdditionalField__c> mapAccId = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_CRM_Promotion_Status__c ps: trigger_new){
            if(ps.ASI_CRM_Account__c != NULL){
                SetAccId.add(ps.ASI_CRM_Account__c);
            }            
        }
        
        if(!(SetAccId).IsEmpty())
            listCustomer = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN:SetAccId];        
        for(ASI_CRM_AccountsAdditionalField__c cust : listCustomer){
            if(cust.ASI_CRM_Account__c != NULL)
                mapAccId.put(cust.ASI_CRM_Account__c, cust);
        }     
        
        for(ASI_CRM_Promotion_Status__c ps: trigger_new){
            if(ps.ASI_CRM_Account__c != NULL && mapAccId.get(ps.ASI_CRM_Account__c) != NULL)
                ps.ASI_CRM_Customer__c = mapAccId.get(ps.ASI_CRM_Account__c).id;           
        }  
    }
}