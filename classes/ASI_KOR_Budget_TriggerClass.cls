/***************************************************************************************************************************
* Name:        ASI_KOR_Budget_TriggerClass
* Description: Trigger class for ASI_KOR_Budget's trigger(s)
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-11-19       Alan Lau                Created
* 2019-01-04       Alan Lau                replaced [local method] with [utils getStringFieldList()] AND [indexOf < 0] with [contains]
* 2019-01-04       Alan Lau                added method for updating the remaining budget of bar-styling POSM header
****************************************************************************************************************************/
public without sharing class ASI_KOR_Budget_TriggerClass {

	private final static Map<String, ASI_KOR_Branches__c> branchCustomSetting = ASI_KOR_Branches__c.getAll();
	private final static Map<String, ASI_KOR_Regions__c> regionCustomSetting = ASI_KOR_Regions__c.getAll();

	public static void validateBranchCode(List<ASI_KOR_Budget__c> triggerNew) {

		List<String> branchCodeList = ASI_KOR_CommonUtils.getStringFieldList(branchCustomSetting.values(), 'ASI_KOR_Branch_Code__c');

		for (ASI_KOR_Budget__c budget : triggerNew) {
			if (!branchCodeList.contains(budget.ASI_KOR_Branch_Code__c)) {
				budget.addError('Invalid Branch Code');
			}
		}
	}

	public static void setRegionNameByBranchCode(List<ASI_KOR_Budget__c> triggerNew) {

		final String keyFieldForMapOfBranchCodeToRegionCode = 'ASI_KOR_Branch_Code__c';
		final String valueFieldForMapOfBranchCodeToRegionCode = 'ASI_KOR_Region_Code__c';

		final String keyFieldForMapOfRegionCodeToRegionName = 'ASI_KOR_Region_Code__c';
		final String valueFieldForMapOfRegionCodeToRegionName = 'Name';

		Map<String, String> mapOfBranchCodeToRegionCode = ASI_KOR_CommonUtils.getMapFromCustomSetting(branchCustomSetting, keyFieldForMapOfBranchCodeToRegionCode, valueFieldForMapOfBranchCodeToRegionCode);
		Map<String, String> mapOfRegionCodeToRegionName = ASI_KOR_CommonUtils.getMapFromCustomSetting(regionCustomSetting, keyFieldForMapOfRegionCodeToRegionName, valueFieldForMapOfRegionCodeToRegionName);

		for (ASI_KOR_Budget__c budget : triggerNew) {
			budget.ASI_KOR_Region__c = mapOfRegionCodeToRegionName.get(mapOfBranchCodeToRegionCode.get(budget.ASI_KOR_Branch_Code__c));
		}
	}

	public static void updateBarStylingPOSMRequestRemainingBudget(List<ASI_KOR_Budget__c> triggerNew) {

		final String keyFieldForMapOfBranchCodeToRegionCode = 'ASI_KOR_Branch_Code__c';
		final String valueFieldForMapOfBranchCodeToRegionCode = 'ASI_KOR_Region_Code__c';

		final String keyFieldForMapOfRegionCodeToRegionName = 'ASI_KOR_Region_Code__c';
		final String valueFieldForMapOfRegionCodeToRegionName = 'Name';

		Map<String, String> mapOfBranchCodeToRegionCode = ASI_KOR_CommonUtils.getMapFromCustomSetting(branchCustomSetting, keyFieldForMapOfBranchCodeToRegionCode, valueFieldForMapOfBranchCodeToRegionCode);
		Map<String, String> mapOfRegionCodeToRegionName = ASI_KOR_CommonUtils.getMapFromCustomSetting(regionCustomSetting, keyFieldForMapOfRegionCodeToRegionName, valueFieldForMapOfRegionCodeToRegionName);

		List<ASI_KOR_POSM_Order_Request__c> barStylingPOSMRequestUpdateList = new List<ASI_KOR_POSM_Order_Request__c>();

		Map<String, Decimal> mapOfRegionNameFiscalYearBrandToRemainingBudget = getMapOfRegionNameFiscalYearBrandToRemainingBudget(triggerNew);
		List<ASI_KOR_POSM_Order_Request__c> barStylingPOSMHeaderList = getBarStylingPOSMHeaderList(triggerNew);

		for (ASI_KOR_POSM_Order_Request__c posmHeader : barStylingPOSMHeaderList) {
			String branchCode = posmHeader.ASI_MFM_Sales_Branch__c.substring(0, posmHeader.ASI_MFM_Sales_Branch__c.indexOf('-'));
			String key = '' + mapOfRegionCodeToRegionName.get(mapOfBranchCodeToRegionCode.get(branchCode)) + posmHeader.ASI_KOR_Fiscal_Year__c + posmHeader.ASI_KOR_Sub_brand__r.ASI_KOR_Brand__c;

			if (mapOfRegionNameFiscalYearBrandToRemainingBudget.containsKey(key)) {
				posmHeader.ASI_KOR_Remaining_Budget_Amount__c = mapOfRegionNameFiscalYearBrandToRemainingBudget.get(key);
				barStylingPOSMRequestUpdateList.add(posmHeader);
			}
		}

		update barStylingPOSMRequestUpdateList;

	}

	private static List<ASI_KOR_POSM_Order_Request__c> getBarStylingPOSMHeaderList(List<ASI_KOR_Budget__c> triggerNew) {
		final List<String> barStylingPOSMHeaderRecordTypeDeveloperNameList = new List<String>{
				'ASI_KOR_Bar_Styling_POSM_Request',
				'ASI_KOR_Locked_Bar_Styling_Item_Request',
				'ASI_KOR_Finalized_Bar_Styling_Item_Request'
		};
		List<String> brandList = ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_KOR_Brand__c');
		List<String> fiscalYearList = ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_KOR_Fiscal_Year__c');

		List<ASI_KOR_POSM_Order_Request__c> barStylingPOSMHeaderList = [
				SELECT Id,
						ASI_KOR_Sub_brand__r.ASI_KOR_Brand__c,
						ASI_KOR_Fiscal_Year__c,
						ASI_KOR_Remaining_Budget_Amount__c,
						ASI_MFM_Sales_Branch__c
				FROM ASI_KOR_POSM_Order_Request__c
				WHERE RecordType.DeveloperName IN :barStylingPOSMHeaderRecordTypeDeveloperNameList
				AND ASI_KOR_Sub_brand__r.ASI_KOR_Brand__c IN :brandList
				AND ASI_KOR_Fiscal_Year__c IN :fiscalYearList
		];
		return barStylingPOSMHeaderList;
	}

	private static Map<String, Decimal> getMapOfRegionNameFiscalYearBrandToRemainingBudget(List<ASI_KOR_Budget__c> triggerNew) {
		List<ASI_KOR_Budget__c> budgetList = [
				SELECT ASI_KOR_Region__c,
						ASI_KOR_Fiscal_Year__c,
						ASI_KOR_Brand__c,
						ASI_KOR_Budget_Amount__c,
						ASI_KOR_Actual_Spending_Amount__c
				FROM ASI_KOR_Budget__c
				WHERE ASI_KOR_Region__c IN :ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_KOR_Region__c')
				AND ASI_KOR_Fiscal_Year__c IN :ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_KOR_Fiscal_Year__c')
				AND ASI_KOR_Brand__c IN :ASI_KOR_CommonUtils.getStringFieldList(triggerNew, 'ASI_KOR_Brand__c')
		];

		Map<String, Decimal> mapOfRegionNameFiscalYearBrandToRemainingBudget = new Map<String, Decimal>();

		for (ASI_KOR_Budget__c budget : budgetList) {
			String key = '' + budget.ASI_KOR_Region__c + budget.ASI_KOR_Fiscal_Year__c + budget.ASI_KOR_Brand__c;

			if (budget.ASI_KOR_Budget_Amount__c != null) {
				Decimal actualSpendingAmount = budget.ASI_KOR_Actual_Spending_Amount__c != null ? budget.ASI_KOR_Actual_Spending_Amount__c : 0;
				Decimal remainingBudget = budget.ASI_KOR_Budget_Amount__c - actualSpendingAmount;
				if (!mapOfRegionNameFiscalYearBrandToRemainingBudget.containsKey(key)) {
					mapOfRegionNameFiscalYearBrandToRemainingBudget.put(key, remainingBudget);
				} else {
					mapOfRegionNameFiscalYearBrandToRemainingBudget.put(key, mapOfRegionNameFiscalYearBrandToRemainingBudget.get(key) + remainingBudget);
				}
			}
		}
		return mapOfRegionNameFiscalYearBrandToRemainingBudget;
	}

}