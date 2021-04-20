({
	initTable: function(cmp) {
		var that = this;
		this.getTableData(cmp, 1, function(err, settings) {
			if (!cmp.isValid()) {
				return;
			}
			if (!err) {
				that.doParseResults(cmp, settings);
				that.initPagination(cmp, cmp.get('v.tableId'), cmp.get('v.tableSetting'));
			}
		});
	},
	getTableData: function(cmp, pageNumber, callback) {
		if (!cmp.isValid()) {
			return;
		}

		var getTableDataAction = cmp.get('c.getApprovalHistory');
		getTableDataAction.setParams({
			pageNumber: pageNumber,
			spendId: cmp.get('v.spendId')
		});
		getTableDataAction.setCallback(this, function(response) {
			if (!cmp.isValid()) {
				return;
			}

			if (response.getState() === 'SUCCESS') {
				return callback(null, response.getReturnValue());
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
			if (!err) {
				callback(settings);
			}
		});
	}
})