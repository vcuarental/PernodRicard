trigger EUR_CRM_OP_VariationAfterUpdate on EUR_CRM_ObjPromo_OnTrade_Variation__c (After Update) {
 List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> { 
      new  EUR_CRM_DE_DeleteOPVariations()
    };
    
    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}