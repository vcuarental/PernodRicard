public without sharing class ASI_CRM_TW_PAF_Customer_TriggerCls{
    public static void routineBeforeUpsert(list<ASI_CRM_HK_Pre_Approval_Form_Customer__c> trigger_new, map<id, ASI_CRM_HK_Pre_Approval_Form_Customer__c> trigger_oldMap) {
        Set<Id> pafId = new Set<Id>();
        Map<Id, ASI_HK_CRM_Pre_Approval_Form__c> mapPaf = new Map<Id, ASI_HK_CRM_Pre_Approval_Form__c>();
        
        for(ASI_CRM_HK_Pre_Approval_Form_Customer__c paf_cus : trigger_new){
            pafId.add(paf_cus.ASI_CRM_HK_Pre_Approval_Form__c);
        }
        
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : [SELECT id, ASI_HK_CRM_PAF_Customer__c, ASI_HK_CRM_PAF_Customer__r.Name FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE Id IN: pafId]){
            mapPaf.put(paf.id, paf);
        }
        
        for(ASI_CRM_HK_Pre_Approval_Form_Customer__c paf_cus : trigger_new){
            if(mapPaf != null && mapPaf.get(paf_cus.ASI_CRM_HK_Pre_Approval_Form__c) != null && 
               paf_cus.ASI_CRM_HK_Customer__c != mapPaf.get(paf_cus.ASI_CRM_HK_Pre_Approval_Form__c).ASI_HK_CRM_PAF_Customer__c &&
               paf_cus.ASI_CRM_Customer_Parent__c != mapPaf.get(paf_cus.ASI_CRM_HK_Pre_Approval_Form__c).ASI_HK_CRM_PAF_Customer__c){
                paf_cus.addError('Customer is not child of PAF Customer \''+mapPaf.get(paf_cus.ASI_CRM_HK_Pre_Approval_Form__c).ASI_HK_CRM_PAF_Customer__r.Name+'\'.');
            }
        }
    }
}