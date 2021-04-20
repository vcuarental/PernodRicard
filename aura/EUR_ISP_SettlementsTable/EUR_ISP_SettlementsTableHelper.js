({
	initTable: function(cmp) {
		var that = this;
		this.showLoading(cmp);

		this.getTableData(cmp, 1, function(err, settings) {
			if (!cmp.isValid()) {
				return;
			}
			if (err) {
				console.log(err);
				return;
			}

			that.doParseResults(cmp, settings);

			var settings = cmp.get('v.tableSetting');
			cmp.set('v.totalSettlements', settings.totalRows);
			// console.log(cmp.get('v.results'));
			// console.log(settings);
			that.initPagination(cmp, cmp.get('v.tableId'), settings);
			that.hideLoading(cmp);
		});
	},
	getTableData: function(cmp, pageNumber, callback) {
		if (!cmp.isValid()) {
			return;
		}

		var getTableDataAction = cmp.get("c.getSettlements");
		getTableDataAction.setParams({
			pageNumber: pageNumber
		});
		getTableDataAction.setCallback(this, function(response) {
			if (!cmp.isValid()) {
				return;
			}

			if (response.getState() === "SUCCESS") {
				var retValue = response.getReturnValue();
				return callback(null, retValue);
			}
			
			callback(response.getError(), null);
		});
		$A.enqueueAction(getTableDataAction);
	},
	changePage: function(cmp, pageNumber, callback) {
		if (!cmp.isValid()) {
			return;
		}

		this.getTableData(cmp, pageNumber, function(err, settings) {
			if (!cmp.isValid()) {
				return;
			}
			if (err) {
				console.log(err);
				return;
			}
			callback(settings);
			var settings = cmp.get('v.tableSetting');
			cmp.set('v.totalSettlements', settings.totalRows);
		});
	}
})