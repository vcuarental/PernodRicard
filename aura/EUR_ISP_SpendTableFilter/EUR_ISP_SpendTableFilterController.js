({
	doSettlementTableInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var params = e.getParams ? e.getParams() : {}
		if (!params.arguments) {
			return;
		}
		hlpr.doSettlementSearchInit(cmp, params.arguments.config);
	},
	doInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		hlpr.doSearchInit(cmp);
	},
	doSearch: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		cmp.getEvent("SpendSearchEvent").fire();
	},
	renderCreateForm: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		hlpr.fireRenderCreateForm(cmp);
	},
	setSearchParams: function(cmp, e, hlpr) {
		var searchParams = hlpr.getSearchParams(cmp);
		var oldSearchParams = cmp.get('v.searchParams');
		if (oldSearchParams) {
			searchParams.sortOrder = oldSearchParams.sortOrder; 
		}
		cmp.set('v.searchParams', searchParams);
	}
})