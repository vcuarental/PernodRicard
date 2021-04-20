({
	initTable: function(cmp, e, hlpr) {
		hlpr.initTable(cmp);
	},
	showSettlement: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams ? e.getParams(): e.target.dataset;

		$A.get('e.c:EUR_ISP_SettlementShowEvent').setParams({
			settlementId: params.settlementId
		}).fire();

		e.preventDefault();
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