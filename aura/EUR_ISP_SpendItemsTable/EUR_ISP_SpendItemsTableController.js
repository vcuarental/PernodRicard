({
	doInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var UserPermissions = cmp.get('v.UserPermissions');
		hlpr.setPicklistValues(UserPermissions);
		hlpr.initCustomLabels();
	},
	selectActivityData: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var SpendActivity = cmp.get('v.SpendActivity');
		var SpendActivityType = cmp.get('v.SpendActivityType');
		if (!SpendActivity || !SpendActivityType || !SpendActivityType.EUR_ISP_Product_Level_Of_Input__c) {
			return;
		}

		cmp.set('v.detectedType', SpendActivityType.EUR_ISP_Product_Level_Of_Input__c);
		cmp.set('v.isUpdated', false);
		cmp.set('v.hasError', false);
		cmp.set('v.errorMsgs', []);

		cmp.set('v.SpendItemsToInsert', {});
		cmp.set('v.SpendItemsToUpdate', {});
		cmp.set('v.SpendItemsToDelete', {});

		if (!SpendActivity.Id) {
			cmp.set('v.SpendItems', []);
			return;
		}

		var $contentElement = $('#spendItemsTable').closest('div.slds-scrollable--x');
		$contentElement.find('table').addClass('slds-hide');
		$contentElement.find('.table-content--loading').removeClass('slds-hide');

		hlpr.getActivitySpendItems(cmp, {
			spendActivityId: SpendActivity.Id
		}, function(err, data) {
			cmp.set('v.SpendItems', data || []);
		});
	},
	setTableData: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var tableData = cmp.get('v.SpendItems');
		var $contentTable = $('#spendItemsTable');
		var $contentElement = $contentTable.closest('div.slds-scrollable--x');
		$contentElement.find('table').addClass('slds-hide');

		cmp.set('v.hasError', false);
		if ($contentTable && tableData) {
			hlpr.resetTables($contentTable);
			hlpr.setTableData(cmp, tableData, $contentTable);
		}
		$contentElement.find('.table-content--loading').addClass('slds-hide');
		cmp.getEvent('hideLoading').fire();
	},
	lockTableEdit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var tableData = cmp.get('v.SpendItems');
		var $contentTable = $('#spendItemsTable');
		if ($contentTable && tableData.length) {

			hlpr.resetTables($contentTable);
			hlpr.setTableData(cmp, tableData, $contentTable);
		}
	},
	fireTableUpdatedEvent: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		if (!cmp.get('v.isUpdated')) {
			return;
		}
		$A.get('e.c:EUR_ISP_SpendActivityItemAddedEvent').fire();
	},
	createNewSpendItem: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var UserPermissions = cmp.get('v.UserPermissions');
		if (cmp.get('v.isLocked') || cmp.get('v.isActivityLocked') || !UserPermissions.EUR_ISP_Spend_Item__c.theObject.isCreateable) {
			return;
		}

		var SpendActivity = cmp.get('v.SpendActivity');
		var SpendActivityType = cmp.get('v.SpendActivityType');
		var BrandObject = e.getParams().Brand;
		var SpendItems = cmp.get('v.SpendItems');
		var SpendItem = hlpr.getNewActivitySpendItem(SpendActivity, SpendActivityType, BrandObject, SpendItems);
		if (!SpendItem) {
			return;
		}

		SpendItems.push(SpendItem);
		cmp.set('v.SpendItems', SpendItems);

		var SpendItemsToInsert = cmp.get('v.SpendItemsToInsert') || {};
		SpendItemsToInsert[SpendItem.__Id] = SpendItem;
		cmp.set('v.SpendItemsToInsert', SpendItemsToInsert);

		if (!cmp.get('v.isUpdated') && SpendActivity.Id) {
			cmp.set('v.isUpdated', true);
		}
	},
	saveUpdatedItems: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var UserPermissions = cmp.get('v.UserPermissions');
		if (!UserPermissions.EUR_ISP_Spend_Item__c.theObject.isUpdateable) {
			$A.get('e.c:EUR_ISP_SpendViewRefreshEvent').fire();
			cmp.getEvent('hideLoading').fire();
			return;
		}

		var params = e.getParams ? e.getParams() : e.target.dataset;
		var SpendActivity = params.SpendActivity ? params.SpendActivity: cmp.get('v.SpendActivity');

		var SpendItemsToInsert = cmp.get('v.SpendItemsToInsert');
		var SpendItemsToInsert = hlpr.getActivitySpendItemsToProcess(SpendItemsToInsert, SpendActivity);
		cmp.set('v.SpendItemsToInsert', {});

		var SpendItemsToUpdate = cmp.get('v.SpendItemsToUpdate');
		var SpendItemsToUpdate = hlpr.getActivitySpendItemsToProcess(SpendItemsToUpdate, SpendActivity);
		cmp.set('v.SpendItemsToUpdate', {});

		var SpendItemsToDelete = cmp.get('v.SpendItemsToDelete');
		var SpendItemsToDelete = hlpr.getActivitySpendItemsToProcess(SpendItemsToDelete, SpendActivity);
		cmp.set('v.SpendItemsToDelete', {});

		if (!SpendItemsToInsert.length && !SpendItemsToUpdate.length && !SpendItemsToDelete.length) {
			// fire event to refresh the Spend and Spend Activities
			$A.get('e.c:EUR_ISP_SpendViewRefreshEvent').fire();
			cmp.getEvent('hideLoading').fire();
			return;
		}

		var $contentElement = $('#spendItemsTable').closest('div.slds-scrollable--x');
		$contentElement.find('table').addClass('slds-hide');
		$contentElement.find('.table-content--loading').removeClass('slds-hide');

		hlpr.doAction(cmp, SpendItemsToInsert, hlpr.ACTIONS.CREATE, function(err, response) {
			if (err) {
				cmp.set('v.isUpdated', false);
				$contentElement.find('table').removeClass('slds-hide');
				$contentElement.find('.table-content--loading').addClass('slds-hide');
				cmp.getEvent('fireErrorEvnt').setParams({
					messages: hlpr.getErrors(err)
				}).fire();
				cmp.getEvent('hideLoading').fire();
				return;
			}

			hlpr.doAction(cmp, SpendItemsToUpdate, hlpr.ACTIONS.UPDATE, function(err, response) {
				if (err) {
					cmp.set('v.isUpdated', false);
					$contentElement.find('table').removeClass('slds-hide');
					$contentElement.find('.table-content--loading').addClass('slds-hide');
					cmp.getEvent('fireErrorEvnt').setParams({
						messages: hlpr.getErrors(err)
					}).fire();
					cmp.getEvent('hideLoading').fire();
					return;
				}

				hlpr.doAction(cmp, SpendItemsToDelete, hlpr.ACTIONS.DEL, function(err, response) {
					if (err) {
						cmp.set('v.isUpdated', false);
						$contentElement.find('table').removeClass('slds-hide');
						$contentElement.find('.table-content--loading').addClass('slds-hide');
						cmp.getEvent('fireErrorEvnt').setParams({
							messages: hlpr.getErrors(err)
						}).fire();
						cmp.getEvent('hideLoading').fire();
						return;
					}

					hlpr.getActivitySpendItems(cmp, {
						spendActivityId: SpendActivity.Id
					}, function(err, data) {
						cmp.set('v.isUpdated', false);
						cmp.set('v.SpendItems', data || []);
						// fire event to refresh the Spend and Spend Activities
						$A.get('e.c:EUR_ISP_SpendViewRefreshEvent').fire();
					});
				});
			});
		});
	},
	closeSpendItem: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		hlpr.closeSpendItem(cmp);
		e.stopPropagation();
		return false;
	},
	showError: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams();
		if (params && params.arguments) {
			cmp.set('v.hasError', params.arguments.hasError);
			cmp.set('v.errorMsgs', params.arguments.hasError ? params.arguments.errorMsgs : []);
		}
	}
})