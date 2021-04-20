/**
 * Settlement Line Trigger Handler class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_SettlementLineTriggerHandler extends EUR_CRM_TriggerAbstract
{
	public EUR_ISP_SettlementLineTriggerHandler()
	{
		super('EUR_ISP_SettlementLineTriggerHandler');
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap)
	{
		if (TriggerAction.BEFORE_INSERT == tAction || TriggerAction.BEFORE_UPDATE == tAction)
		{
			this.checkIfSpendItemLines(sObjList);
		}
		if (TriggerAction.AFTER_INSERT == tAction || TriggerAction.AFTER_UPDATE == tAction || TriggerAction.AFTER_DELETE == tAction)
		{
			this.calculateMathcedAmountForSpendItems(sObjList, oldMap);
		}
	}

	/**
	 * setup checkbox if this settlement line created for Spend Item
	 */
	private void checkIfSpendItemLines(List<EUR_ISP_Settlement_Line__c> lines)
	{
		for (EUR_ISP_Settlement_Line__c line : lines)
		{
			line.EUR_ISP_Spend_Item_Line__c = String.isNotBlank(line.EUR_ISP_Spend_Item__c);
		}
	}

	/**
	 * implementation of the Rollup summary for Spend Items
	 */
	private void calculateMathcedAmountForSpendItems(List<sObject> lines, Map<Id, sObject> oldMap)
	{
		oldMap = oldMap == null ? new Map<Id, sObject>() : oldMap;
		List<String> fieldsToCheck = new List<String> {'EUR_ISP_Amount__c', 'EUR_ISP_Spend_Item_Line__c', 'EUR_ISP_Spend_Item__c'};
		Set<sObject> modifiedObjects = EUR_ISP_Utils.getModifiedObjects(fieldsToCheck, lines, oldMap);


		Set<Id> spedItemIds = new Set<Id>();
		for (sObject sline : modifiedObjects)
		{
			EUR_ISP_Settlement_Line__c line = (EUR_ISP_Settlement_Line__c)sline;
			if (line.EUR_ISP_Spend_Item_Line__c && String.isNotBlank(line.EUR_ISP_Spend_Item__c))
			{
				spedItemIds.add(line.EUR_ISP_Spend_Item__c);
			}
		}

		List<EUR_ISP_Spend_Item__c> spendItems = [SELECT Id, EUR_ISP_Matched__c, (SELECT Id, EUR_ISP_Amount__c FROM Settlement_Lines_EU__r)
		        FROM EUR_ISP_Spend_Item__c WHERE Id IN: spedItemIds];
		for (EUR_ISP_Spend_Item__c spendItem : spendItems)
		{
			List<EUR_ISP_Settlement_Line__c> allLines = spendItem.Settlement_Lines_EU__r;
			spendItem.EUR_ISP_Matched__c = 0;
			if (!allLines.isEmpty())
			{
				for (EUR_ISP_Settlement_Line__c line : allLines)
				{
					if (line.EUR_ISP_Amount__c != null)
					{
						spendItem.EUR_ISP_Matched__c += line.EUR_ISP_Amount__c;
					}
				}
			}
		}
		update spendItems;
	}
}