({
	doInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var settlementId = cmp.get('v.settlementId');
		if (!settlementId) {
			return;
		}

		hlpr.getSettlement(cmp, settlementId, function(Settlement) {
			cmp.set('v.Settlement', Settlement);

			if (Settlement.Id) {
				$A.get('e.c:EUR_ISP_SettlementLoadedEvent').setParams({
					Settlement: Settlement,
					settlementId: settlementId,
					Account: Settlement.EUR_ISP_Account__r,
					Vendor: Settlement.EUR_ISP_Vendor__r
				}).fire();
			}
		});
		hlpr.getSettlementLines(cmp, settlementId, function(SettlementLines) {
			cmp.set('v.SettlementLines', SettlementLines);
		});

		//// it is not possible to implement with LocerService in short terms 
		// var screenHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight || 0;
		// if ($) {
		// 	$(window).off('scroll').on('scroll', function(e) {
		// 		if (window.pageYOffset > screenHeight / 2) {
		// 			$('.settlement-component--body').addClass('settlement-component--fixed');
		// 			//hlpr.showSettlementLines(false);
		// 		} else {
		// 			$('.settlement-component--body').removeClass('settlement-component--fixed');
		// 			//hlpr.showSettlementLines(true);
		// 		}
		// 	});
		// }
	},
	showSettlementLines: function(cmp, e, hlpr) {
		hlpr.showSettlementLines($(e.target).hasClass('arrow-right'));
		e.stopPropagation();
		return false;
	},
	createBudgetTransaction: function(cmp,  e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams ? e.getParams(): e.target.dataset;
		cmp.set('v.errorMsgs', []);
		cmp.set('v.hasError', false);
		hlpr.createBudgetTransaction(cmp, params, function(err) {
			if (err) {
				cmp.set('v.errorMsgs', hlpr.getErrors(err));
				cmp.set('v.hasError', true);
				return;
			}
			hlpr.doMatchRecalculation(cmp, cmp.get('v.SettlementLines'));
			$A.get('e.c:EUR_ISP_SpendViewRefreshEvent').fire();
		});
		e.stopPropagation();
		return false;
	},
	createSettlementLine: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams ? e.getParams(): e.target.dataset;
		params.settlementId = cmp.get('v.settlementId');
		cmp.set('v.errorMsgs', []);
		cmp.set('v.hasError', false);
		hlpr.createSettlementLine(cmp, params, function(err, SettlementLines) {
			if (err) {
				cmp.set('v.errorMsgs', hlpr.getErrors(err));
				cmp.set('v.hasError', true);
				return;
			}
			hlpr.doMatchRecalculation(cmp, SettlementLines);
			cmp.set('v.SettlementLines', SettlementLines);
			$A.get('e.c:EUR_ISP_SpendViewRefreshEvent').fire();
		});
		e.stopPropagation();
		return false;
	},
	deleteSettlementLine: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams ? e.getParams(): e.target.dataset;
		params.settlementId = cmp.get('v.settlementId');
		cmp.set('v.errorMsgs', []);
		cmp.set('v.hasError', false);
		hlpr.deleteSettlementLine(cmp, params, function(err, SettlementLines) {
			if (err) {
				cmp.set('v.errorMsgs', hlpr.getErrors(err));
				cmp.set('v.hasError', true);
				return;
			}
			hlpr.doMatchRecalculation(cmp, SettlementLines);
			cmp.set('v.SettlementLines', SettlementLines);
			$A.get('e.c:EUR_ISP_SpendViewRefreshEvent').fire();
		});
		e.stopPropagation();
		return false;
	},
	closeSettlement: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		cmp.set('v.errorMsgs', []);
		cmp.set('v.hasError', false);
		cmp.set('v.Settlement', {});
		hlpr.closeSettlement(cmp, cmp.get('v.settlementId'), function(err, Settlement) {
			if (err) {
				cmp.set('v.errorMsgs', hlpr.getErrors(err));
				cmp.set('v.hasError', true);
				return;
			}
			cmp.set('v.Settlement', Settlement);
		});
		e.stopPropagation();
		return false;
	}
})