/***************************************************************************************************************************
* Name:        ASI_KOR_Budget_BeforeInsert
* Description: Before insert trigger for ASI_KOR_Budget
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-11-19       Alan Lau                Created
****************************************************************************************************************************/

trigger ASI_KOR_Budget_BeforeInsert on ASI_KOR_Budget__c (before insert) {

	if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains(
			'ASI_KOR_Bar_Styling')) {
		ASI_KOR_Budget_TriggerClass.validateBranchCode(trigger.new);
		ASI_KOR_Budget_TriggerClass.setRegionNameByBranchCode(trigger.new);
	}

}