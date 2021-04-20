({
	doInit: function(cmp) {
		if (!cmp.get('v.tableId')) {
			var randomId = (cmp.get('v.spendId')? cmp.get('v.spendId') : '')+ '-tableId-' + Math.floor((Math.random() * 10000) + 1);
			randomId = randomId.replace(/\W*\s/gi, '');
			cmp.set('v.tableId', randomId);
		}
	},
	doSettlementTableInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams ? e.getParams() : {};
		if (params.Vendor) {
			cmp.set('v.Vendor', params.Vendor);
		}
	},
	setTableData: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var tableData = cmp.get('v.activities');
		if (tableData && tableData.length) {
			hlpr.setTableData(cmp);
		} else {
			var $contentElement = $('#' + cmp.get('v.tableId')).closest('div.slds-scrollable--x');
			$contentElement.find('table.table-content--no').removeClass('slds-hide');
		}
	},
	getActivities: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams();
		if (!params || !params.spendId || cmp.get('v.spendId') !== params.spendId) {
			return;
		}
		var $contentElement = $('#' + cmp.get('v.tableId')).closest('div.slds-scrollable--x');
		$contentElement.find('table').addClass('slds-hide');
		$contentElement.find('.table-content--loading').removeClass('slds-hide');
		if (cmp.get('v.isMatchScreen')) {
			params.vendorId = cmp.get('v.Vendor') ? cmp.get('v.Vendor').Id : null;
		}

		hlpr.setActivities(cmp, params, function(data) {
			cmp.set('v.activities', data);
			$contentElement.find('.table-content--loading').addClass('slds-hide');
		});
	},
	refreshData: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var spendId = cmp.get('v.spendId');
		var activities = cmp.get('v.activities');
		if (!spendId || !activities.length || !cmp.get('v.isMatchScreen')) {
			return;
		}
		var params = {
			spendId   : spendId,
			vendorId  : cmp.get('v.Vendor') ? cmp.get('v.Vendor').Id : null
		};

		var $contentElement = $('#' + cmp.get('v.tableId')).closest('div.slds-scrollable--x');
		$contentElement.find('table').addClass('slds-hide');
		$contentElement.find('.table-content--loading').removeClass('slds-hide');
		hlpr.setActivities(cmp, params, function(data) {
			cmp.set('v.activities', data);
			$contentElement.find('.table-content--loading').addClass('slds-hide');
		});
	},
	renderCreateForm: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		hlpr.fireRenderCreateForm(cmp.get('v.spendId'), cmp.get('v.activityTypeId'));
	}
})