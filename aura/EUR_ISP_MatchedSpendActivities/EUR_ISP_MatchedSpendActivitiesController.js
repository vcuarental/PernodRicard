({
	doInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		hlpr.doInit();
	},
	doDataInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams();
		if (!params || !params.spendId || cmp.get('v.spendId') !== params.spendId) {
			return;
		}

		if (cmp.get('v.hasError')) {
			cmp.set('v.hasError', false);
		}

		cmp.set('v.isDataLoaded', false);
		hlpr.getSpend(cmp, params.spendId, function(Spend) {
			cmp.set('v.Spend', Spend);
		});

		var isDEProject = cmp.get('v.UserPermissions').PROJECT_NAME === 'DE_SFA_PROJECT';
		hlpr.setupPicklistValues(cmp);
		hlpr.getSpendActivities(cmp, params.spendId, function(activities) {
			cmp.set('v.SpendActivities', activities);
			var tableData = hlpr.getTableData(activities, isDEProject);
			cmp.set('v.tableData', tableData);
			cmp.set('v.selectedActivityId', null);
			cmp.set('v.isDataLoaded', true);
		});
	},
	doDataRefresh: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		if (cmp.get('v.hasError')) {
			cmp.set('v.hasError', false);
		}

		var isDataLoaded = cmp.get('v.isDataLoaded');
		var spendId = cmp.get('v.spendId');
		var isDEProject = cmp.get('v.UserPermissions').PROJECT_NAME === 'DE_SFA_PROJECT';
		hlpr.setupPicklistValues(cmp);
		if (isDataLoaded && spendId) {
			cmp.set('v.isDataLoaded', false);
			hlpr.getSpendActivities(cmp, spendId, function(activities) {
				cmp.set('v.SpendActivities', activities);
				var tableData = hlpr.getTableData(activities, isDEProject);
				cmp.set('v.tableData', tableData);
				cmp.set('v.selectedActivityId', null);
				cmp.set('v.isDataLoaded', true);
			});
		}
	},
	goToSpend: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var spendId = cmp.get('v.spendId');
		var params = e.target.dataset;
		var selectedItem = hlpr.getSelectedActivity(cmp, params.rowId);
		if (!selectedItem) {
			return;
		}

		hlpr.fireRenderSpend(cmp, spendId, selectedItem);
		hlpr.fireRenderBrandTable(spendId, selectedItem);
	},
	createSettlementItem: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		if (cmp.get('v.hasError')) {
			cmp.set('v.hasError', false);
		}

		cmp.set('v.selectedActivityId', null);
		var params = e.getParams? e.getParams(): e.target.dataset;
		var selectedItem = hlpr.getSelectedActivity(cmp, params.itemId);
		if (!selectedItem || !selectedItem.value || !selectedItem.isValid) {
			return;
		}

		if (!hlpr.isSelectedAmountValid(cmp, selectedItem)) {
			cmp.set('v.hasError', true);
			cmp.set('v.errorMsgs', [hlpr.CUSTOM_MESSAGES.ERRORS.ACTIVITY_AMOUNT]);
			return;
		}

		hlpr.fireSettlementLineItemCreateEvent(cmp, selectedItem);

		e.preventDefault();
		e.stopPropagation();
		e.target.setAttribute('disabled', 'disabled');
		setTimeout(function() {
			e.target.removeAttribute('disabled', 'disabled');
		}, 2000);
		return false;
	},
	confirmOnCloseActivity: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams? e.getParams(): e.target.dataset;
		var selectedItem = hlpr.getSelectedActivity(cmp, params.itemId);
		if (!selectedItem || !selectedItem.isValid) {
			return;
		}

		var msg = $A.util.format(hlpr.CUSTOM_MESSAGES.WARNINGS.RELEASE_BUDGET, hlpr.getFormatedCurrency(selectedItem.Available, selectedItem));
		cmp.set('v.selectedActivityId', selectedItem.Id);
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

		var itemId = cmp.get('v.selectedActivityId');
		var selectedItem = hlpr.getSelectedActivity(cmp, itemId);
		hlpr.fireCreateBudgetTransactionEvent(cmp, selectedItem);
		e.stopPropagation();
		return false;
	}
})