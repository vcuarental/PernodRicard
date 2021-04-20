({
	doInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var UserPermissions = cmp.get('v.UserPermissions') || {};
		hlpr.init(UserPermissions);
		var selectionData = hlpr.getSelectionData(UserPermissions, cmp.get('v.Spend'));
		cmp.set('v.selectionData', selectionData);
		cmp.set('v.isUpdated', false);
		cmp.set('v.hasError', false);
		cmp.set('v.errorMsgs', []);
		cmp.set('v.isSaving', false);
	},
	doRefreshSpend: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		hlpr.doRefreshSpend(cmp, function(Spend) {
			cmp.set('v.Spend', Spend);
		});
	},
	handleUpdateEvent: function(cmp, e, hlpr) {
		if (!cmp.isValid() || cmp.get('v.isUpdated')) {
			return;
		}
		cmp.set('v.isUpdated', true);
	},
	saveSpend: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		hlpr.doSave(cmp);
	},
	doneApprovalUpdate: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		cmp.set('v.isSaving', true);

		var Spend = cmp.get('v.Spend');
		Spend.EUR_ISP_Approval_Status__c = 'Pending';
		cmp.set('v.Spend', Spend);
		cmp.set('v.isLocked', false);

		//setTimeout(function() {
			$A.run(function() {
				//$A.get('e.c:EUR_ISP_SpendViewRefreshEvent').fire();
				$A.get('e.c:EUR_ISP_SpendApprovalSubmitEvent').fire();
				cmp.set('v.isSaving', false);
			});
		//}, 100);
	},
	recallApproval: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var Spend = cmp.get('v.Spend');
		hlpr.fireModalEvent(cmp, Spend.Id);
	},
	submitForApproval: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		if (cmp.get('v.hasError')) {
			cmp.set('v.hasError', false);
			cmp.set('v.errorMsgs', []);
		}
		cmp.set('v.isSaving', true);

		var Spend = cmp.get('v.Spend');
		hlpr.submitForApproval(cmp, Spend, function(err, results) {
			if (err) {
				cmp.set('v.errorMsgs', hlpr.getErrors(err));
				cmp.set('v.hasError', true);
				cmp.set('v.isSaving', false);
				return;
			}

			if (results) {
				cmp.set('v.Spend', results.Spend);
				cmp.set('v.isLocked', results.isLocked === true);
			}

			//$A.get('e.c:EUR_ISP_SpendViewRefreshEvent').fire();
			$A.get('e.c:EUR_ISP_SpendApprovalSubmitEvent').fire();
			cmp.set('v.isSaving', false);
		});
	}
})