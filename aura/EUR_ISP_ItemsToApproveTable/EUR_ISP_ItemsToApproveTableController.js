({
	initTable: function(cmp, e, hlpr) {
		hlpr.initTable(cmp);
		hlpr.initCustomLabels();
	},
	showSpend: function(cmp, e, hlpr) {
		var params = e.getParams ? e.getParams(): e.target.dataset;
		cmp.getEvent('ShowItemsToAdjustEvent').setParams({
			spendId : params.spendId
		}).fire();

		e.preventDefault();
		e.stopPropagation();
		return false;
	},
	doneApprovalUpdate: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var settings = cmp.get('v.tableSetting');
		hlpr.initTable(cmp, settings.pageNumber);
	},
	reassign: function(cmp, e, hlpr) {
		var params = e.getParams ? e.getParams(): e.target.dataset;
		var url = 'https://' + window.location.host + '/' + encodeURIComponent(params.itemId) + '/e?et=REASSIGN&retURL=' + encodeURIComponent('/apex/EUR_ISP_SpendApp?view=home');
		var urlEvent = $A.get("e.force:navigateToURL");
		if (urlEvent) {
			urlEvent.setParams({
				"url": url
			});
			return urlEvent.fire();
		}
		window.location.href = url;
		e.stopPropagation();
		return false;
	},
	approve: function(cmp, e, hlpr) {
		var params = e.getParams ? e.getParams(): e.target.dataset;
		hlpr.fireModalEvent(cmp, params, true);
		e.stopPropagation();
		return false;
	},
	reject: function(cmp, e, hlpr) {
		var params = e.getParams ? e.getParams(): e.target.dataset;
		hlpr.fireModalEvent(cmp, params, false);
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