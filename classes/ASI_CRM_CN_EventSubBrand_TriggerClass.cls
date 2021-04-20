/* Filename:    ASI_CRM_CN_EventSubBrand_TriggerClass.cls
* Author:      Michael Yip (Introv Limited)
* Purpose:     Handle CRM CN Event Sub-Brand Trigger Logic
*
*
* History
* -----------------------------------------------------------------------------
* 2014-07-24   michael.yip@introv.com      Create
* 
*/
public with sharing class ASI_CRM_CN_EventSubBrand_TriggerClass{
    public static String className = 'ASI_CRM_CN_EventSubBrand_TriggerClass';
    public static void routineAfterInsert(list<ASI_MFM_Event_Sub_Brand__c> trigger_new, map<id, ASI_MFM_Event_Sub_Brand__c > trigger_oldMap) {
        ASI_CRM_CN_UpdateParentfromChild uef = new ASI_CRM_CN_UpdateParentfromChild();
        uef.UpdateEventSubBrandName(Trigger_new);
    
    }
    public static void routineAfterUpdate(list<ASI_MFM_Event_Sub_Brand__c> trigger_new, map<id, ASI_MFM_Event_Sub_Brand__c> trigger_oldMap) {
        ASI_CRM_CN_UpdateParentfromChild uef = new ASI_CRM_CN_UpdateParentfromChild();
        uef.UpdateEventSubBrandName(Trigger_new);
    
    }
    public static void routineAfterDelete(list<ASI_MFM_Event_Sub_Brand__c> trigger_old, map<id, ASI_MFM_Event_Sub_Brand__c> trigger_oldMap) {
        ASI_CRM_CN_UpdateParentfromChild uef = new ASI_CRM_CN_UpdateParentfromChild();
        uef.UpdateEventSubBrandName(Trigger_old);
    
    }
    
}