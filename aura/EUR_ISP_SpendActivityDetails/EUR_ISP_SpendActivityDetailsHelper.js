({
	initNewActivity: function(cmp) {
		var SpendActivity = cmp.get('v.SpendActivity');
		var Spend = cmp.get('v.Spend');
		var SpendActivityType = cmp.get('v.SpendActivityType');
		var RecordTypes = cmp.get('v.UserPermissions').EUR_ISP_Spend_Activity__c.theObject.recordTypesFull;

		SpendActivity.sobjectType = 'EUR_ISP_Spend_Activity__c';
		SpendActivity.CurrencyIsoCode =  Spend.CurrencyIsoCode;
		SpendActivity.EUR_ISP_Spend__r = Spend;
		SpendActivity.EUR_ISP_Spend__c = Spend.Id;
		SpendActivity.EUR_ISP_Settlement_Method__c = Spend.EUR_ISP_Settlement_Method__c;
		SpendActivity.EUR_ISP_Total_Spend_Items_Amount__c = 0;
		SpendActivity.EUR_ISP_Total_Activity_Amount__c = 0;
		SpendActivity.EUR_ISP_Matched__c = 0;
		SpendActivity.EUR_ISP_Approval_Status__c = 'Pending';
		SpendActivity.EUR_ISP_Status__c = 'Planned';
		if (Spend.EUR_ISP_Status__c === 'Planned' || Spend.EUR_ISP_Status__c === 'Committed' || Spend.EUR_ISP_Status__c === 'Ringfence') {
			SpendActivity.EUR_ISP_Status__c = Spend.EUR_ISP_Status__c;
		}

		SpendActivity.EUR_ISP_Spend_Activity_Type__r = SpendActivityType;
		SpendActivity.EUR_ISP_Spend_Activity_Type__c = SpendActivityType.Id;
		SpendActivity.EUR_ISP_Spend_Activity_Type_Name__c = SpendActivityType.EUR_ISP_Spend_Activity_Type_Name__c;
		if (SpendActivityType.EUR_ISP_Display_Vendor__c && Spend.EUR_ISP_Vendor__r) {
			SpendActivity.EUR_ISP_Vendor__c = Spend.EUR_ISP_Vendor__r.Id;
			SpendActivity.EUR_ISP_Vendor__r = Spend.EUR_ISP_Vendor__r;
		}

		var recordTypeName = Spend.RecordType.Name;
		;(RecordTypes || []).forEach(function(rType) {
			if (rType.label === recordTypeName) {
				SpendActivity.RecordType = {
					Id: rType.value,
					Name: rType.label
				};
				SpendActivity.RecordTypeId = rType.value;
			}
		});
		return SpendActivity;
	},
	getActivitySpendItemsToProcess: function(spendItemsToProcess) {
		var SpendItems = [];
		spendItemsToProcess = spendItemsToProcess || {};

		for (var key in spendItemsToProcess) {
			if (spendItemsToProcess.hasOwnProperty(key)) {
				var SpendItem = spendItemsToProcess[key];
				SpendItems.push(SpendItem);
			}
		}
		return SpendItems;
	},
	validateSpendItems: function(spendItemsInfoCmp) {
		var hlpr = this;
		var isVariableVisible = spendItemsInfoCmp.get("v.SpendActivityType.EUR_ISP_Display_Variable_Fields__c");
		var isLumtSum1Visible = spendItemsInfoCmp.get("v.SpendActivityType.EUR_ISP_Display_Lump_Sum_1__c");
		var isLumtSum2Visible = spendItemsInfoCmp.get("v.SpendActivityType.EUR_ISP_Display_Lump_Sum_2__c");
		var isPercentageVisible = spendItemsInfoCmp.get("v.SpendActivityType.EUR_ISP_Display_Percentage__c");

		var SpendItemsToInsert = spendItemsInfoCmp.get('v.SpendItemsToInsert');
		var SpendItemsToUpdate = spendItemsInfoCmp.get('v.SpendItemsToUpdate');
		var data = hlpr.getActivitySpendItemsToProcess(SpendItemsToInsert);
		data = data.concat(hlpr.getActivitySpendItemsToProcess(SpendItemsToUpdate));

		var errorMsgs = {};
		data.forEach(function(item) {
			if (isVariableVisible) {
				errorMsgs[hlpr.validateNumberRequired(item.EUR_ISP_Volume__c, hlpr)] = 1;
				errorMsgs[hlpr.validateNumberRequired(item.EUR_ISP_Per_Unit_Amount__c, hlpr)] = 1;
				errorMsgs[hlpr.validateRequired(item.EUR_ISP_Unit_Of_Measure__c, hlpr)] = 1;
			}
			if (isLumtSum1Visible) {
				errorMsgs[hlpr.validateNumber(item.EUR_ISP_Lump_Sum_1__c)] = 1;
			}
			if (isLumtSum2Visible) {
				errorMsgs[hlpr.validateNumber(item.EUR_ISP_Lump_Sum_2__c)] = 1;
			}
			if (isPercentageVisible) {
				errorMsgs[hlpr.validateNumber(item.EUR_ISP_Percentage__c)] = 1;
			}
		});
		delete errorMsgs[''];
		return Object.getOwnPropertyNames(errorMsgs);
	},
	validateNumberRequired: function (value, hlpr){
		var err = hlpr.validateRequired(value, hlpr);
		if (err) {
			return err;
		}
		return hlpr.validateNumber(value, hlpr);
	},
	validateNumber: function (value) {
		value = $.trim(value);
		value = value.replace(',','.');

		var err = '';
		if (value && !/^\d+\.{0,1}\d*$/.test(value)) {
			err = $A.get('$Label.c.EUR_ISP_INVALID_VALUE');
		}
		return err;
	},
	validateRequired: function(value) {
		value = $.trim(value);

		var err = '';
		if (!value) {
			err = $A.get('$Label.c.EUR_ISP_REQUIRED_FIELDS');
		}
		return err;
	},
	getTotalItemsAmountValue: function(SpendItems) {
		var totalItemsAmount = 0;
		SpendItems.forEach(function(item) {
			totalItemsAmount += parseFloat(item.EUR_ISP_Total_Spend_Item__c || 0, 10);
		});
		return parseFloat(totalItemsAmount, 10);
	},
	isActivityLocked: function(SpendActivity) {
		return SpendActivity && (SpendActivity.EUR_ISP_Status__c === 'Invoiced' || SpendActivity.EUR_ISP_Status__c === 'Cancelled');
	},
	isSpendItemsNumberMoreThanOne: function(SpendItems) {
		return SpendItems.length >= 1;
	},
	isPercentageCorrent: function(SpendItems, SpendActivityType) {
		if (!SpendActivityType.EUR_ISP_Display_Percentage__c || SpendItems.length === 0) {
			return true;
		}

		var total = 0;
		SpendItems.forEach(function(item) {
			total += item.EUR_ISP_Percentage__c || 0;
		});
		return total === 100;
	}
})