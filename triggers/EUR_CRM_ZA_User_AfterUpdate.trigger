trigger EUR_CRM_ZA_User_AfterUpdate on User (after update) {

    List<User> newUsers = new List<User>();
    Map<Id, User> newMap = new Map<Id, User>();
    Map<Id, User> oldMap = new Map<Id, User>();
    for (User u : [select Id FROM User WHERE User.profile.name LIKE 'EUR%' AND Id IN :Trigger.newMap.keySet()]) {
        newUsers.add(Trigger.newMap.get(u.Id));
        newMap.put(u.Id,Trigger.newMap.get(u.Id));
        oldMap.put(u.Id,Trigger.oldMap.get(u.Id));
    }

    if (!newUsers.isEmpty()) {
        List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
                new EUR_CRM_ZA_UpdateSOTeleSalesHandler(),
                new EUR_CRM_ZA_UpdateContractSalesMngrHandlr()
        };

        for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, newUsers, newMap, oldMap);
        }
    }
}