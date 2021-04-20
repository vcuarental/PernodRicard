({
	getHistory: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		if (!e.getParams || !e.getParams().arguments) {
			return;
		}
		var params = e.getParams().arguments.config;
		cmp.set('v.spendId', params.spendId);
		hlpr.initTable(cmp);
	},
	refreshView: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var params = e.getParams();
		var spendId = cmp.get('v.spendId');
		params.spendId = params.spendId ? params.spendId : spendId;
		if (spendId === params.spendId) {
			hlpr.initTable(cmp);
		}
	}
})