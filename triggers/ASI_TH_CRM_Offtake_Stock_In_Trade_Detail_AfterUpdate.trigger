trigger ASI_TH_CRM_Offtake_Stock_In_Trade_Detail_AfterUpdate on ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c (after update) {
	if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_CRM_SG_WS_Depletion')){
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_RecalculateWSDepletion()
        };
                            
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newmap, trigger.oldmap);
        }
    }
}