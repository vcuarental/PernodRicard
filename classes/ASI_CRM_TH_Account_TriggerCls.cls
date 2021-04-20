/****************************
Filename:     ASI_CRM_TH_Account_TriggerCls 
Author:       Twinkle LI (Introv Limited)
Purpose:      Handle TH Account Trigger Logic
Created Date: 28-04-2016
******************************/


public without sharing class ASI_CRM_TH_Account_TriggerCls {
     public static void routineAfterUpdate(list<Account> trigger_new, list<Account> trigger_old){
         List<Account> listAccount = new List<Account>();
         List<ASI_CRM_AccountsAdditionalField__c> listCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
         Set<Id> setAccoundId = new Set<Id>();
         Map<Id, Account> mapAccoundId = new Map<Id,  Account>();
         
         for(Account acc : trigger_new){
             setAccoundId.add(acc.id);
         }
         
         listAccount = [SELECT id, Owner.Manager.Name FROM Account WHERE id IN: setAccoundId];
         for(Account acc : listAccount){
             mapAccoundId.put(acc.id, acc);
         }
         system.debug('listAccount: '+listAccount.size());
         
         listCustomer = [SELECT id, ASI_CRM_Account__c, ASI_CRM_RSM__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN: setAccoundId];
         for(ASI_CRM_AccountsAdditionalField__c cust : listCustomer){
             if(mapAccoundId != null && mapAccoundId.size() > 0 && mapAccoundId.get(cust.ASI_CRM_Account__c) != null)
                 cust.ASI_CRM_RSM__c = mapAccoundId.get(cust.ASI_CRM_Account__c).Owner.Manager.Name;
         }
         system.debug('listCustomer: '+listCustomer.size());
         
         update listCustomer;
     }
}