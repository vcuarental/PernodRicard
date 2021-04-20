/**
 * Apex Trigger for iSPend APP
 * Create Spend, Spend Activity and Spend Items during the Contract Activation process
 *
 * @author afi
 * @copyright PARX
 */
trigger EUR_ISP_ContractTrigger on EUR_CRM_Contract__c (after insert, after update)
{
	List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>
	{
		new EUR_ISP_ContractBudgetTriggerHandler(),
		new EUR_ISP_ContractPushTriggerHandler()
	};

	if (Trigger.isAfter)
	{
		if (Trigger.isUpdate)
		{
			for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses)
			{
				triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
			}
		}

		if (Trigger.isInsert)
		{
			for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses)
			{
				triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
			}
		}
	}
}