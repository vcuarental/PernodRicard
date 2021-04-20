({
	initTable: function(cmp, e, hlpr) {
		hlpr.initTable(cmp);
		hlpr.initCustomLabels();
	},
	showActivity: function(cmp, e, hlpr) {
		var params = e.getParams ? e.getParams(): e.target.dataset;
		cmp.getEvent('ShowItemsToAdjustEvent').setParams({
			spendId        : params.spendId,
			spendActivityId: params.activityId,
			spendTypeId    : params.activityTypeId
		}).fire();

		e.preventDefault();
		e.stopPropagation();
		return false;
	},
	confirmOnCloseActivity: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams? e.getParams(): e.target.dataset;
		cmp.set('v.selectedActivityId', params.activityId);
		var activities = cmp.get('v.results');
		var Activity = null;
		activities.forEach(function(item) {
			if (item.Id === params.activityId) {
				Activity = item;
			}
		});

		var total = Activity.EUR_ISP_Total_Activity_Amount__c ? Activity.EUR_ISP_Total_Activity_Amount__c: 0;
		var matched = Activity.EUR_ISP_Matched__c ? Activity.EUR_ISP_Matched__c : 0;
		var currString = $A.localizationService.formatCurrency(total - matched);
		currString = currString.replace(/[^\d+\,\.]/g, '');

		var msg = $A.util.format(hlpr.CUSTOM_LABELS.CONFIRM_MSG, Activity.CurrencyIsoCode + ' ' + currString);
		cmp.find('confirmation').showConfirmation(msg, 'Cancel', 'Ok');

		e.preventDefault();
		e.stopPropagation();
		e.target.setAttribute('disabled', 'disabled');
		setTimeout(function() {
			e.target.removeAttribute('disabled', 'disabled');
		}, 2000);
		return false;
	},
	closeActivity: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var activityToClose = cmp.get('v.selectedActivityId');
		hlpr.createBudgetTransaction(cmp, activityToClose);

		e.stopPropagation();
		return false;
	},
	showTooltip: function(cmp, e, hlpr) {
		var source = e.getSource();
		if (source && source.elements.length) {
			hlpr.showTooltip(source.elements[0]);
		}
	},
	hideTooltip: function(cmp, e, hlpr) {
		var source = e.getSource();
		if (source && source.elements.length) {
			hlpr.hideTooltip(source.elements[0]);
		}
	}
})