/***************************************************************************************************************************
* Name:        ASI_KOR_Budget_TriggerClassTest
* Description: Test class for ASI_KOR_Budget's trigger(s)
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-11-20       Alan Lau                Created
* 2019-06-17       Wilson Chow             Increase Code Coverage: testUpdateBarStylingPOSMRequestRemainingBudget()
****************************************************************************************************************************/

@IsTest
private class ASI_KOR_Budget_TriggerClassTest {

	static final String barStylingRecordTypeName = 'ASI_KOR_Budget__cASI_KOR_Bar_Styling';
	static final String branchCode = 'B01';
	static final String regionCode = 'R01';
	static final String fiscalYear = 'FY0001';
	static final String invalidBranchCodeErrorMessage = 'Invalid Branch Code';

	@TestSetup
	static void setup() {
		setTestBranchCustomSetting();
		setTestRegionCustomSetting();
	}

	@IsTest
	static void testAutoFillRegionName() {
		Id barStylingRecordTypeId = Global_RecordTypeCache.getRtId(barStylingRecordTypeName);
		ASI_KOR_Budget__c budget = new ASI_KOR_Budget__c(RecordTypeId = barStylingRecordTypeId, ASI_KOR_Branch_Code__c = branchCode, ASI_KOR_Fiscal_Year__c = fiscalYear);

		insert budget;
	}

	@IsTest
	static void testValidateBranchCodePassInsert() {
		Id barStylingRecordTypeId = Global_RecordTypeCache.getRtId(barStylingRecordTypeName);
		ASI_KOR_Budget__c budget = new ASI_KOR_Budget__c(RecordTypeId = barStylingRecordTypeId, ASI_KOR_Branch_Code__c = branchCode, ASI_KOR_Fiscal_Year__c = fiscalYear);

		insert budget;
	}

	@IsTest
	static void testValidateBranchCodePassUpdate() {
		Id barStylingRecordTypeId = Global_RecordTypeCache.getRtId(barStylingRecordTypeName);
		ASI_KOR_Budget__c budget = new ASI_KOR_Budget__c(RecordTypeId = barStylingRecordTypeId, ASI_KOR_Branch_Code__c = branchCode, ASI_KOR_Fiscal_Year__c = fiscalYear);

		insert budget;

		ASI_KOR_Budget__c budgetForUpdate = [SELECT Id FROM ASI_KOR_Budget__c WHERE Id = :budget.Id LIMIT 1];

		budgetForUpdate.ASI_KOR_Branch_Code__c = branchCode;
		update budgetForUpdate;
	}

	@IsTest
	static void testUpdateBarStylingPOSMRequestRemainingBudget() {
		Id barStylingRecordTypeId = Global_RecordTypeCache.getRtId(barStylingRecordTypeName);
		ASI_KOR_Budget__c budget = new ASI_KOR_Budget__c(RecordTypeId = barStylingRecordTypeId, ASI_KOR_Branch_Code__c = branchCode, ASI_KOR_Fiscal_Year__c = fiscalYear, ASI_KOR_Actual_Spending_Amount__c=100);

		insert budget;

		ASI_KOR_Budget__c budgetForUpdate = [SELECT Id FROM ASI_KOR_Budget__c WHERE Id = :budget.Id LIMIT 1];

		budgetForUpdate.ASI_KOR_Branch_Code__c = branchCode;
		budgetForUpdate.ASI_KOR_Actual_Spending_Amount__c = 0;
		update budgetForUpdate;
	}

	@IsTest
	static void testValidateBranchCodeFailInsert() {
		try {
			Id barStylingRecordTypeId = Global_RecordTypeCache.getRtId(barStylingRecordTypeName);
			ASI_KOR_Budget__c budget = new ASI_KOR_Budget__c(RecordTypeId = barStylingRecordTypeId, ASI_KOR_Branch_Code__c = 'TEST', ASI_KOR_Fiscal_Year__c = fiscalYear);

			insert budget;
		} catch (Exception e) {

			Boolean expectedExceptionThrown = e.getMessage().contains(invalidBranchCodeErrorMessage) ? true : false;

			System.assert(expectedExceptionThrown);
		}
	}

	@IsTest
	static void testValidateBranchCodeFailUpdate() {
		try {
			Id barStylingRecordTypeId = Global_RecordTypeCache.getRtId(barStylingRecordTypeName);
			ASI_KOR_Budget__c budget = new ASI_KOR_Budget__c(RecordTypeId = barStylingRecordTypeId, ASI_KOR_Branch_Code__c = branchCode, ASI_KOR_Fiscal_Year__c = fiscalYear);

			insert budget;

			ASI_KOR_Budget__c budgetForUpdate = [SELECT Id FROM ASI_KOR_Budget__c WHERE Id = :budget.Id LIMIT 1];

			budgetForUpdate.ASI_KOR_Branch_Code__c = 'TEST';
			update budgetForUpdate;
		} catch (Exception e) {

			Boolean expectedExceptionThrown = e.getMessage().contains(invalidBranchCodeErrorMessage) ? true : false;

			System.assert(expectedExceptionThrown);
		}
	}

	private static void setTestBranchCustomSetting() {
		List<ASI_KOR_Branches__c> branchCustomSettingList = new List<ASI_KOR_Branches__c>();

		ASI_KOR_Branches__c branchCustomSetting = new ASI_KOR_Branches__c(Name = 'Test Branch', ASI_KOR_Branch_Code__c = branchCode, ASI_KOR_Region_Code__c = regionCode);
		ASI_KOR_Branches__c branchCustomSettingWithoutValue = new ASI_KOR_Branches__c(Name = 'Test Branch 2');

		branchCustomSettingList.add(branchCustomSetting);
		branchCustomSettingList.add(branchCustomSettingWithoutValue);

		insert branchCustomSettingList;
	}

	private static void setTestRegionCustomSetting() {
		List<ASI_KOR_Regions__c> regionCustomSettingList = new List<ASI_KOR_Regions__c>();

		ASI_KOR_Regions__c regionCustomSetting = new ASI_KOR_Regions__c(Name = 'Test Region', ASI_KOR_Region_Code__c = regionCode);
		ASI_KOR_Regions__c regionCustomSettingWithoutValue = new ASI_KOR_Regions__c(Name = 'Test Region 2');

		regionCustomSettingList.add(regionCustomSetting);
		regionCustomSettingList.add(regionCustomSettingWithoutValue);

		insert regionCustomSettingList;
	}

}