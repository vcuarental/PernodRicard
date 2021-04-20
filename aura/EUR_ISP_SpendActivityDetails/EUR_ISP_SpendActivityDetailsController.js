({
	renderData: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var SpendActivityType = cmp.get('v.SpendActivityType');
		if (!SpendActivityType) {
			return;
		}

		var SpendActivity = cmp.get('v.SpendActivity');
		if (!SpendActivity.Id) {
			SpendActivity = hlpr.initNewActivity(cmp);
			SpendActivity._SpendActivity = JSON.parse(JSON.stringify(SpendActivity));
		}

		cmp.set('v.SpendActivity', SpendActivity);
		//cmp.set('v.SpendItems', SpendActivity.Spend_Items_EU__r || []);
		cmp.set('v.SettlementLines', SpendActivity.Settlement_Lines_EU__r || []);
		cmp.set('v.isActivityLocked', hlpr.isActivityLocked(SpendActivity));
		var activityCmp = cmp.find('activityInfo');
		activityCmp.resetActivity();
	},
	validateSpendActivityDetails: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var activityCmp = cmp.find('activityInfo');
		var spendItemsInfoCmp = cmp.find('spendItemsInfo');
		var Spend = cmp.get('v.Spend');
		var SpendActivity = cmp.get('v.SpendActivity');
		var SpendActivityType = cmp.get('v.SpendActivityType');
		var SpendItems = cmp.get('v.SpendItems') || [];

		var spendItemErrs = [];
		if (!hlpr.isSpendItemsNumberMoreThanOne(SpendItems)) {
			spendItemErrs.push($A.get('$Label.c.EUR_ISP_ITEM_ADDED')); //'You must choose at least one Spend Item before the Activity can be saved.'
		}
		if (!hlpr.isPercentageCorrent(SpendItems, SpendActivityType)) {
			spendItemErrs.push($A.get('$Label.c.EUR_ISP_PERCENTAGE_INCORRECT')); //'Incorrect Percentage value.'
		}
		if (spendItemErrs.length) {
			spendItemsInfoCmp.showError(true, spendItemErrs);
		} else {
			spendItemsInfoCmp.showError(false, []);
		}

		var spendActivityErrs = hlpr.validateSpendItems(spendItemsInfoCmp);
		if (spendActivityErrs.length) {
			activityCmp.showError(false, true, spendActivityErrs);
		} else {
			activityCmp.showError(false, false, spendActivityErrs);
		}

		if (!spendItemErrs.length && !spendActivityErrs.length) {
			var amount = hlpr.getTotalItemsAmountValue(SpendItems);
			activityCmp.saveSpendActivity(amount);
		}
	},
	handleError: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var activityCmp = cmp.find('activityInfo');
		var errMsgs = e.getParams().messages;
		activityCmp.showError(true, errMsgs && errMsgs.length > 0, errMsgs);
	}
})