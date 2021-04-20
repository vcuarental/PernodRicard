/***************************************************************************************************************************
* Name:        ASI_KOR_Budget_BeforeUpdate
* Description: Before update trigger for ASI_KOR_Budget
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-12-05       Alan Lau                Created
****************************************************************************************************************************/
trigger ASI_KOR_Budget_BeforeUpdate on ASI_KOR_Budget__c (before update) {

	if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains(
			'ASI_KOR_Bar_Styling')) {
		ASI_KOR_Budget_TriggerClass.validateBranchCode(trigger.new);
	}

}