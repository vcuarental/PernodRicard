trigger ASI_KOR_POSM_Product_BeforeInsert on ASI_KOR_POSM_Product__c (before insert) {
  if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_KOR_POSM_Product')){
       // ASI_KOR_POSM_TriggerClass.routineBeforeInsert(Trigger.New);  
            List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
                new ASI_MFM_KR_POSMProductAssignAutoNumber()       
            };
            
                        
            for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
                triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, null, null);
            }
    }
}