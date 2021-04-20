/**
 * SpendActivity Trigger for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
trigger EUR_ISP_SpendTrigger on EUR_ISP_Spend__c (after update, before update)
{
	if (Trigger.isAfter && Trigger.isUpdate)
	{
		new EUR_ISP_SpendTriggerHandler()
		.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, Trigger.new, Trigger.newMap, Trigger.oldMap);
	}
	if (Trigger.isBefore && Trigger.isUpdate)
	{
		new EUR_ISP_SpendTriggerHandler()
		.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, Trigger.new, Trigger.newMap, Trigger.oldMap);
	}
}