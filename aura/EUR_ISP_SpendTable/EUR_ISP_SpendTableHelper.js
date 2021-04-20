({
	initTable: function(cmp) {
		var hlpr = this;
		hlpr.showLoading(cmp);
		hlpr.changePage(cmp, 1, function(settings) {
			hlpr.doParseResults(cmp, settings);

			var settings = cmp.get('v.tableSetting');
			hlpr.initPagination(cmp, cmp.get('v.tableId'), settings);
			hlpr.hideLoading(cmp);
		});
	},
	getTableData: function(cmp, searchParams, callback) {
		if (!cmp.isValid()) {
			return;
		}
		var getSpendsSearchAction = cmp.get("c.getISpendsSearch");
		getSpendsSearchAction.setParams({
			settingsJson: JSON.stringify(searchParams)
		});
		getSpendsSearchAction.setCallback(this, function(response) {
			if (!cmp.isValid()) {
				return;
			}
			if (response.getState() === "SUCCESS") {
				var retValue = response.getReturnValue();
				return callback(null, retValue);
			}
			callback(response.getError(), null);
		});
		$A.enqueueAction(getSpendsSearchAction);
	},
	changePage: function(cmp, pageNumber, callback) {
		if (!cmp.isValid()) {
			return;
		}

		cmp.find('filter').setSearchParams();
		var searchParams = cmp.find('filter').get('v.searchParams');
		searchParams.pageNumber = pageNumber;
		this.getTableData(cmp, searchParams, function(err, settings) {
			if (!cmp.isValid()) {
				return;
			}
			if (err) {
				console.log(err);
				return;
			}
			callback(settings);
		});
	},
	sortTableData: function(cmp, sortColumn, sortOrder) {
		if (!cmp.isValid()) {
			return;
		}

		var searchParams = cmp.find('filter').get('v.searchParams');
		searchParams.sortOrder = sortColumn + ' ' + (sortOrder === 'asc' ?  'ASC' : 'DESC');
		cmp.find('filter').set('v.searchParams', searchParams);

		var hlpr = this;
		hlpr.changePage(cmp, 1, function(settings) {
			hlpr.doParseResults(cmp, settings);
			var settings = cmp.get('v.tableSetting');
			hlpr.initPagination(cmp, cmp.get('v.tableId'), settings);
		});
	},
	renderSpend: function(cmp, spendId) {
		cmp.getEvent("ShowSpendEvent").setParams({
			spendId: spendId
		}).fire();
	}
})