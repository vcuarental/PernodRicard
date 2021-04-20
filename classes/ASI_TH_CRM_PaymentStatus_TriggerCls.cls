/*Filename:     ASI_TH_CRM_PaymentStatus_TriggerCls 
* Author:       Twinkle LI (Introv Limited)
* Purpose:      Handle TH Customer Trigger Logic
* Created Date: 07/28/2016
*/

public with sharing class ASI_TH_CRM_PaymentStatus_TriggerCls {
    public static void routineBeforeUpsert(list<ASI_TH_CRM_Payment_Status__c> trigger_new, map<id, ASI_TH_CRM_Payment_Status__c> trigger_oldMap){ 
        Set<String> setPSPOnumber = new Set<String>();
        for(ASI_TH_CRM_Payment_Status__c ps : trigger_new){
            setPSPOnumber.add(ps.ASI_CRM_PO_Number__c);
        }
        
        Map<String, ASI_TH_CRM_PaymentRequest__c> mapPRName = new Map<String, ASI_TH_CRM_PaymentRequest__c>();
        List<ASI_TH_CRM_PaymentRequest__c> listPR = new List<ASI_TH_CRM_PaymentRequest__c>();
        listPR = [SELECT id, Name FROM ASI_TH_CRM_PaymentRequest__c WHERE recordTypeId =: Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_TH_CRM_Payment_Request') AND Name IN: setPSPOnumber];
        for(ASI_TH_CRM_PaymentRequest__c pr : listPR){
            mapPRName.put(pr.Name, pr);
        }
        
        for(ASI_TH_CRM_Payment_Status__c ps : trigger_new){    
            if(mapPRName.containsKey(ps.ASI_CRM_PO_Number__c)){
                ps.ASI_CRM_Payment_Request__c = mapPRName.get(ps.ASI_CRM_PO_Number__c).id;
            }                    
        }
    }
}