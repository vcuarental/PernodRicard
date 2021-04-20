trigger EUR_CRM_ObjPromoTrigger on EUR_CRM_ObjPromo__c (before insert, before update, after update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
                new EUR_CRM_ObjectivePromoHandler()
            };

            for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
                triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, null);
            }
        }

        if (Trigger.isUpdate) {
            List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
                new EUR_CRM_ObjectivePromoHandler()
            };

            for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
                triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
            }
        }
    }

    if (Trigger.isAfter) {
//        if (Trigger.isInsert) {
//
//        }

        if (Trigger.isUpdate) {
            List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
                new EUR_CRM_DeactivateEMObjPromoHandler()
            ,   new EUR_CRM_DE_ExpiredObjectivePromoHandler()
            };

            for(EUR_CRM_TriggerAbstract triggerClass: triggerClasses) {
                triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
            }
        }
    }

}