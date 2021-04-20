({
	doInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		cmp.set('v.isVisible', false);
		cmp.set('v.isLoading', false);
	},
	hideTable: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		cmp.set('v.isVisible', false);
		cmp.set('v.isLoading', false);
	},
	showTable: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams();
		// console.log('params :: ', params);
		// console.log('tableName :: ', cmp.get('v.tableName'));
		// console.log('isVisible :: ', cmp.get('v.isVisible'));
		// console.log('spendId :: ', cmp.get('v.spendId'));
		if (params.objectName === cmp.get('v.tableName')) {
			if (cmp.get('v.isVisible')) {
				return;
			}
			if (cmp.get('v.spendId') === params.spendId) {
				cmp.set('v.isVisible', true);
				return;
			}

			cmp.set('v.isLoading', true);
			cmp.set('v.spendId', params.spendId);
			hlpr.getBrandData(cmp, function(data) {
				hlpr.setTableData(cmp, data);
				cmp.set('v.isVisible', true);
				cmp.set('v.isLoading', false);
			});
		} else {
			cmp.set('v.isVisible', false);
			cmp.set('v.isLoading', false);
		}
	}
})