trigger ASI_CRM_ProsImageLevel_AfterInsert on ASI_CRM_Pros_Image_Level__c (after insert) {
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG')){
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_DeleteOldProsImageVolPotHandler()
        };
        
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
        }
    }
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TW')){
        List<ASI_CRM_TW_TriggerAbstract> triggerClasses = new List<ASI_CRM_TW_TriggerAbstract> {
            new ASI_CRM_TW_DeleteOldProsImageHandler()
        };
        
        for (ASI_CRM_TW_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_TW_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
        }
    }
    
    //Added by Twinkle @04/03/2016
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TH')){
        List<ASI_CRM_TH_TriggerAbstract> triggerClasses = new List<ASI_CRM_TH_TriggerAbstract> {
            new ASI_CRM_TH_DeleteOldProsImageHandler()
        };
        
        for (ASI_CRM_TH_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_TH_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
        }
    }
}