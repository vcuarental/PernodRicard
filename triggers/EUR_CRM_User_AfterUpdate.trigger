/*********************************************************************************
 * Name: EUR_CRM_User_AfterUpdate
 * Description: Trigger Handler Class to automatically update the field 
 * 				'Manager of the Account Owner' in Account 
 *			   	 when the field 'Manager' is updated in User profile
 *
 * Version History
 * Date			Developer	Comments
 * ----------	----------	-------------------------------------------------------
 *	25-7-2017	Kevin Choi  Created, combined with RU	
*********************************************************************************/
trigger EUR_CRM_User_AfterUpdate on User (after update) {

    List<User> newUsers = new List<User>();
    Map<Id, User> newMap = new Map<Id, User>();
    Map<Id, User> oldMap = new Map<Id, User>();
    for (User u : [select Id FROM User WHERE User.profile.name LIKE 'EUR%' AND Id IN :Trigger.newMap.keySet()]) {
        newUsers.add(Trigger.newMap.get(u.Id));
        newMap.put(u.Id,Trigger.newMap.get(u.Id));
        oldMap.put(u.Id,Trigger.oldMap.get(u.Id));
    }

    if (!newUsers.isEmpty()) {
        List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>{
                new EUR_CRM_UpdateAccountMgrHandlr(),
                new EUR_CRM_UpdateAccountRoleAPI()
        };

        for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, newUsers, newMap, oldMap);
        }
    }

}