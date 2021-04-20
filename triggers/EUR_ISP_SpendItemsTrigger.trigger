/**
 * SpendItem Trigger for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
trigger EUR_ISP_SpendItemsTrigger on EUR_ISP_Spend_Item__c (after insert, after update, after delete)
{
	if (Trigger.isAfter)
	{
		if (Trigger.isUpdate)
		{
			new EUR_ISP_SpendItemsTriggerHandler()
			.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, Trigger.new, Trigger.newMap, Trigger.oldMap);
		}
		if (Trigger.isInsert)
		{
			new EUR_ISP_SpendItemsTriggerHandler()
			.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, Trigger.new, null, null);
		}
		if (Trigger.isDelete)
		{
			new EUR_ISP_SpendItemsTriggerHandler()
			.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_DELETE, Trigger.old, null, null);
		}
	}
}