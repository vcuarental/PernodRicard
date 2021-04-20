/*Filename:    ASI_CRM_TW_PromoTarget_TriggerCls.cls
* Author:      Twinkle LI (Introv Limited)
* Purpose:     Handle TW Promotion Target Trigger Logic
*
*/
public with sharing class ASI_CRM_TW_PromoTarget_TriggerCls {
    public static void routineAfterUpdate(list<ASI_CRM_Promotion_Target__c> trigger_new, map<id, ASI_CRM_Promotion_Target__c> trigger_oldMap){ 
        Map<String, ASI_CRM_Promotion_Target__c> mapPromoTarget = new Map<String, ASI_CRM_Promotion_Target__c>();
        Set<String> setRegion = new Set<String>();
        Set<Id> setPromotionId = new Set<Id>();
        
        //Get confirmed regions
        for(ASI_CRM_Promotion_Target__c pt : trigger_new){
            setRegion.add(pt.ASI_CRM_Region__c);
            setPromotionId.add(pt.ASI_CRM_Promotion__c);               
            mapPromoTarget.put(pt.ASI_CRM_Promotion__c+pt.ASI_CRM_Region__c, pt);
        }
        
        List<ASI_CRM_Merchandiser_Task__c> listMerchanTask = new List<ASI_CRM_Merchandiser_Task__c>();
        listMerchanTask = [SELECT id, ASI_CRM_Confirmed__c, ASI_CRM_Promotion_Status__c, ASI_CRM_Promotion_Status__r.ASI_CRM_Region__c, ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__c 
                           FROM ASI_CRM_Merchandiser_Task__c
                           WHERE ASI_CRM_Promotion_Status__r.ASI_CRM_Region__c IN:setRegion AND ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__c IN:setPromotionId];
        
        for(ASI_CRM_Merchandiser_Task__c mt : listMerchanTask){
            mt.ASI_CRM_Confirmed__c = mapPromoTarget.get(mt.ASI_CRM_Promotion_Status__r.ASI_CRM_Promotion__c+mt.ASI_CRM_Promotion_Status__r.ASI_CRM_Region__c).ASI_CRM_Confirmed__c;
        }
        Update listMerchanTask;
    }       
}