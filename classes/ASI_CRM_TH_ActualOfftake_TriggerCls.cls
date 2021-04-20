/****************************
Filename:     ASI_CRM_TH_ActualOfftake_TriggerCls 
Author:       Twinkle LI (Introv Limited)
Purpose:      Handle ASI_TH_CRM_Actual_Offtake__c Trigger Logic
Created Date: 28-04-2016
******************************/


public with sharing class ASI_CRM_TH_ActualOfftake_TriggerCls {
    public static void routineBeforeInsert(list<ASI_TH_CRM_Actual_Offtake__c> trigger_new){
        updateOfftakeCustomer(trigger_new);
    }
    
    public static void routineBeforeUpdate(list<ASI_TH_CRM_Actual_Offtake__c> trigger_new, Map<id, ASI_TH_CRM_Actual_Offtake__c> trigger_old){
        updateOfftakeCustomer(trigger_new);
    }
    
    public static void updateOfftakeCustomer(list<ASI_TH_CRM_Actual_Offtake__c> trigger_new){
        Set<Id> setAccountId = new Set<Id>(); 
        Map<Id, ASI_CRM_AccountsAdditionalField__c> mapCustomerByAccountId = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
        
        for(ASI_TH_CRM_Actual_Offtake__c aOfftake : trigger_new){
            if(aOfftake.ASI_TH_CRM_Outlet__c != null)
                setAccountId.add(aOfftake.ASI_TH_CRM_Outlet__c);
        }
        
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = [SELECT id, ASI_CRM_Account__c 
                                                                 FROM ASI_CRM_AccountsAdditionalField__c 
                                                                 WHERE ASI_CRM_Account__c IN: setAccountId];
        for(ASI_CRM_AccountsAdditionalField__c cust : listCustomer){
            if(cust.ASI_CRM_Account__c != null)
                mapCustomerByAccountId.put(cust.ASI_CRM_Account__c, cust);
        }
        for(ASI_TH_CRM_Actual_Offtake__c aOfftake : trigger_new){
            if(mapCustomerByAccountId != null && mapCustomerByAccountId.get(aOfftake.ASI_TH_CRM_Outlet__c) != null)
                aOfftake.ASI_CRM_SG_Customer__c = mapCustomerByAccountId.get(aOfftake.ASI_TH_CRM_Outlet__c).id;
        }
    }
}