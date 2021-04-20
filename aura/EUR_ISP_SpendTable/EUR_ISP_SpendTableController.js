({
	doSettlementTableInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams ? e.getParams() : {};
		cmp.set('v.Settlement', params.Settlement);
		cmp.find('filter').setSettlementAttribues(params);
		hlpr.initTable(cmp);
	},
	initTable: function(cmp, e, hlpr) {
		if (cmp.get('v.isMatchScreen')) {
			hlpr.showLoading(cmp);
			return;
		}
		hlpr.initTable(cmp);
	},
	doSearch: function(cmp, e, hlpr) {
		hlpr.initTable(cmp);
	},
	sort: function(cmp, e, hlpr)
	{
		// if you click on the SVG icon the action falls. SLDS sooo *goooood*!
		var sortColumn = e.target;
		var params = sortColumn.dataset;
		if (params && params.sortField) {
			var sortField = params.sortField;
			var sortOrder = sortColumn.classList.contains('asc') ? 'asc' : 'desc';
		
			hlpr.sortTableData(cmp, sortField, sortOrder);

			var sortedColumn = document.querySelector('.sortedColumn');
			if (sortedColumn) {
				sortedColumn.querySelector('.sortAsc').classList.add('slds-hide');
				sortedColumn.querySelector('.sortDesc').classList.add('slds-hide');
				$A.util.removeClass(sortedColumn, 'sortedColumn');
			}

			$A.util.toggleClass(sortColumn, 'asc');
			$A.util.toggleClass(sortColumn, 'desc');
			$A.util.addClass(sortColumn, 'sortedColumn');
			if (sortOrder === 'asc') {
				sortColumn.querySelector('.sortAsc').classList.remove('slds-hide');
				sortColumn.querySelector('.sortDesc').classList.add('slds-hide');
			} else {
				sortColumn.querySelector('.sortDesc').classList.remove('slds-hide');
				sortColumn.querySelector('.sortAsc').classList.add('slds-hide');
			}
		}
		e.preventDefault();
		e.stopPropagation();
		return false;
	},
	renderActivities: function(cmp, e, hlpr) {
		if (!e || !e.target.dataset.spendId) {
			return;
		}

		var targetEl = e.target;
		var params = targetEl.dataset;
		var $el = $('#' + cmp.get('v.tableId') + '-row-' + params.spendId);

		$('#' + cmp.get('v.tableId')).find('tr.slds-myshow').not($el).each(function() {
			$(this).addClass('slds-hide').removeClass('slds-myshow');
		});
		$('#' + cmp.get('v.tableId')).find('button.arrow').not(targetEl).each(function() {
			if (!$(this).hasClass('arrow-right')) {
				$(this).addClass('arrow-right');
			}
		});

		if ($el.hasClass('slds-hide')) {
			$el.addClass('slds-myshow').removeClass('slds-hide');
			$A.util.removeClass(targetEl, 'arrow-right');

			$A.get('e.c:EUR_ISP_ActivityShowEvent').setParams({
				spendId: params.spendId
			}).fire();
		} else {
			$el.addClass('slds-hide').removeClass('slds-myshow');
			$A.util.addClass(targetEl, 'arrow-right');
		}
	},
	renderSpend: function(cmp, e, hlpr) {
		var el = e.target;
		hlpr.renderSpend(cmp, el.dataset.spendId);
		e.preventDefault();
		e.stopPropagation();
		return false;
	},
	renderIfCurrentPage: function(cmp, e, hlpr) {
		var el = $('#' + cmp.get('v.tableId')).closest('div.cEUR_ISP_SpendTable');
		if (!el.length) {
			return;
		}

		el = el[0];
		if (e.getParams() && 'SPEND' === e.getParams().prevPageAPI) {
			if (el.classList.contains('slds-hide')) {
				el.classList.remove('slds-hide');
				el.classList.add('slds-show');
			}
		} else {
			if (!el.classList.contains('slds-hide')) {
				el.classList.remove('slds-show');
				el.classList.add('slds-hide');
			}
		}
	}
})