({
	doInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var spendId = cmp.get('v.spendId');
		hlpr.getSpend(cmp, spendId, function(err, data) {
			if (!err) {
				cmp.set('v.Spend', data);
			} else {
				hlpr.doErrorProcessing(err);
			}
			cmp.set('v.isLoaded', true);
		});
	},
	doApprovalUpdate: function(cmp, e, hlpr) {
		cmp.set('v.isLoaded', false);
		hlpr.doAppoveOrRejectProcess(cmp, function(err, data) {
			if (err || data === false) {
				hlpr.doErrorProcessing(err);
				cmp.set('v.isLoaded', true);
				return;
			}
			$A.get('e.c:EUR_ISP_SpendApproveSaveEvent').fire();
			$A.get('e.c:EUR_ISP_ModalWindowCloseEvent').fire();
		});
	}
})