/**
 * Settlement Line Trigger for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
trigger EUR_ISP_SettlementLineTrigger on EUR_ISP_Settlement_Line__c (before insert, before update, before delete, after insert, after update, after delete)
{
	if (Trigger.isAfter)
	{
		if (Trigger.isInsert)
		{
			new EUR_ISP_SettlementLineTriggerHandler()
			.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, Trigger.new, null, null);
		}
		if (Trigger.isUpdate)
		{
			new EUR_ISP_SettlementLineTriggerHandler()
			.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, Trigger.new, Trigger.newMap, Trigger.oldMap);
		}
		if (Trigger.isDelete)
		{
			new EUR_ISP_SettlementLineTriggerHandler()
			.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_DELETE, Trigger.old, null, null);
		}
	}

	if (Trigger.isBefore)
	{
		if (Trigger.isInsert)
		{
			new EUR_ISP_SettlementLineTriggerHandler()
			.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, Trigger.new, null, null);
		}
		if (Trigger.isUpdate)
		{
			new EUR_ISP_SettlementLineTriggerHandler()
			.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, Trigger.new, Trigger.newMap, Trigger.oldMap);
		}
	}
}