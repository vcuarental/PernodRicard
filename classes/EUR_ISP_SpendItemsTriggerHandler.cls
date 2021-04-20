/**
 * SpendItems Trigger Handler class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_SpendItemsTriggerHandler extends EUR_CRM_TriggerAbstract
{
	public EUR_ISP_SpendItemsTriggerHandler()
	{
		super('EUR_ISP_SpendItemsTriggerHandler');
	}

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap)
	{
		if (TriggerAction.AFTER_UPDATE == tAction)
		{
			this.saveHistory(sObjList, oldMap);
		}
		if (TriggerAction.AFTER_INSERT == tAction)
		{
			this.saveHistory(sObjList, oldMap);
		}
		if (TriggerAction.AFTER_DELETE == tAction)
		{

		}
	}

	private void saveHistory(List<sObject> newList, Map<Id, sObject> oldMap)
	{
		oldMap = oldMap == null ? new Map<Id,  sObject>() : oldMap;
		List<String> fieldsToTrack = EUR_ISP_VolumeChangeHistoryService.getFieldsToTrack(EUR_ISP_Utils.EUR_ISP_SPEND_ITEM_API_NAME);
		Set<sObject> modifiedObjects = EUR_ISP_Utils.getModifiedObjects(fieldsToTrack, newList, oldMap);
		EUR_ISP_VolumeChangeHistoryService.saveUpdatesToHistory(oldMap, new List<sObject>(modifiedObjects), EUR_ISP_Utils.EUR_ISP_SPEND_ITEM_API_NAME);
	}
}