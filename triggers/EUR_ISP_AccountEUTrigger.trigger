/**
 * AccountEU Trigger class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
trigger EUR_ISP_AccountEUTrigger on EUR_CRM_Account__c (after update)
{
	if (Trigger.isAfter && Trigger.isUpdate)
	{
		new EUR_ISP_AccountEUTriggerHandler()
		.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, Trigger.new, Trigger.newMap, Trigger.oldMap);
	}
}