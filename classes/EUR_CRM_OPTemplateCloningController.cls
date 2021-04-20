public with sharing class EUR_CRM_OPTemplateCloningController {


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    @AuraEnabled
    public static EUR_CRM_OP_Template__c getRecordToClone(Id recordId) {
        EUR_CRM_OP_Template__c template = selectOPTemplateWhereId(recordId);
        template.Name = template.Name + ' - Cloned';
        return template;
    }

    @AuraEnabled
    public static String cloneRecordWithRelatedLists(EUR_CRM_OP_Template__c record) {
        Id templateIdToClone = record.Id;
        setFieldsToNull(record, new Set<String> { 'Id' });
        insert record;

        cloneActions(templateIdToClone, record.Id);

        return record.Id;
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private static void cloneActions(Id originalOPTemplateId, Id clonedOPTemplateId) {
        List<EUR_CRM_OP_Action__c> actions = selectOPActionsWhereOPTemplateId(originalOPTemplateId);
        Map<Decimal, Decimal> parentStepOrderByActionStepOrder = getParentStepOrderByActionStepOrder(actions);
        setFieldsToNull(actions, new Set<String> { 'Id', 'EUR_CRM_Parent_Action__c' });

        for (EUR_CRM_OP_Action__c action : actions) {
            action.EUR_CRM_OP_Template__c = clonedOPTemplateId;
            action.OwnerId = UserInfo.getUserId();
        }
        insert actions;

        if (parentStepOrderByActionStepOrder.isEmpty()) { return ; }
        updateParentActionLinks(parentStepOrderByActionStepOrder, actions);
    }

    private static void updateParentActionLinks(Map<Decimal, Decimal> parentStepOrderByActionStepOrder, List<EUR_CRM_OP_Action__c> actions) {
        List<EUR_CRM_OP_Action__c> opActionsToUpdate = new List<EUR_CRM_OP_Action__c>();
        Map<Decimal, Id> actionIdByStepOrder = getActionIdByStepOrder(actions);

        for (Decimal actionStepOrder : parentStepOrderByActionStepOrder.keySet()) {
            Decimal parentStepOrder = parentStepOrderByActionStepOrder.get(actionStepOrder);
            if (actionIdByStepOrder.containsKey(actionStepOrder) && actionIdByStepOrder.containsKey(parentStepOrder)) {
                opActionsToUpdate.add(new EUR_CRM_OP_Action__c(
                    Id = actionIdByStepOrder.get(actionStepOrder)
                ,   EUR_CRM_Parent_Action__c = actionIdByStepOrder.get(parentStepOrder)
                ));
            }
        }
        update opActionsToUpdate;
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private static Map<Decimal, Decimal> getParentStepOrderByActionStepOrder(List<EUR_CRM_OP_Action__c> actions) {
        Map<Decimal, Decimal> parentStepOrderByActionStepOrder = new Map<Decimal, Decimal>();

        for (EUR_CRM_OP_Action__c action : actions) {
            if (action.EUR_CRM_Parent_Action__c != null) {
                parentStepOrderByActionStepOrder.put(action.EUR_CRM_Step_Order__c, action.EUR_CRM_Parent_Action__r.EUR_CRM_Step_Order__c);
            }
        }

        return parentStepOrderByActionStepOrder;
    }

    private static Map<Decimal, Id> getActionIdByStepOrder(List<EUR_CRM_OP_Action__c> actions) {
        Map<Decimal, Id> actionIdByStepOrder = new Map<Decimal, Id>();

        for (EUR_CRM_OP_Action__c action : actions) {
            actionIdByStepOrder.put(action.EUR_CRM_Step_Order__c, action.Id);
        }

        return actionIdByStepOrder;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private static void setFieldsToNull(EUR_CRM_OP_Template__c template, Set<String> fields) {
        for (String field : fields) {
            template.put(field, null);
        }
        template.OwnerId = UserInfo.getUserId();
    }

    private static void setFieldsToNull(List<EUR_CRM_OP_Action__c> actions, Set<String> fields) {
        for (EUR_CRM_OP_Action__c action : actions) {
            for (String field : fields) {
                action.put(field, null);
            }
            action.OwnerId = UserInfo.getUserId();
        }
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static EUR_CRM_OP_Template__c selectOPTemplateWhereId(Id templateId) {
        return ((List<EUR_CRM_OP_Template__c>) new EUR_CRM_QueryBuilder(EUR_CRM_OP_Template__c.class)
            .qbAllCreatableFields()
            .qbCondition()
            .add(new EUR_CRM_QueryBuilder.CompareCondition('Id').eq(templateId))
            .endCondition()
            .toList())[0];
    }

    private static List<EUR_CRM_OP_Action__c> selectOPActionsWhereOPTemplateId(Id templateId) {
        return (List<EUR_CRM_OP_Action__c>) new EUR_CRM_QueryBuilder(EUR_CRM_OP_Action__c.class)
            .qbAllCreatableFields()
            .qbFields(new List<String>{'EUR_CRM_Parent_Action__r.EUR_CRM_Step_Order__c'})
            .qbCondition()
            .add(new EUR_CRM_QueryBuilder.CompareCondition('EUR_CRM_OP_Template__c').eq(templateId))
            .endCondition()
            .toList();
    }


}