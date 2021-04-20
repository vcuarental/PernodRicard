/**
 * SpendActivity Trigger for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
trigger EUR_ISP_SpendActivityTrigger on EUR_ISP_Spend_Activity__c (after insert, after update, before delete, after delete)
{
	if (Trigger.isAfter)
	{
		if (Trigger.isUpdate)
		{
			new EUR_ISP_SpendActivityTriggerHandler()
			.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, Trigger.new, Trigger.newMap, Trigger.oldMap);
		}
		if (Trigger.isInsert)
		{
			new EUR_ISP_SpendActivityTriggerHandler()
			.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, Trigger.new, null, null);
		}
		if (Trigger.isDelete)
		{
			new EUR_ISP_SpendActivityTriggerHandler()
			.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_DELETE, Trigger.old, null, null);
		}
	}

	if (Trigger.isBefore)
	{
		if (Trigger.isDelete)
		{
			new EUR_ISP_SpendActivityTriggerHandler()
			.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_DELETE, Trigger.old, null, null);
		}
	}
}