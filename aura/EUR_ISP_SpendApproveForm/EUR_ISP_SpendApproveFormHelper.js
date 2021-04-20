({
	getSpend: function(cmp, spendId, callback) {
		var getSpendAction = cmp.get("c.getSpendForApproval");
		getSpendAction.setParams({
			spendId: spendId
		});
		getSpendAction.setCallback(this, function(response) {
			if (!cmp.isValid()) {
				return;
			}

			if (response.getState() === "SUCCESS") {
				return callback(null, response.getReturnValue())
			}
			callback(response.getError(), null);
		});
		$A.enqueueAction(getSpendAction);
	},
	doAppoveOrRejectProcess: function(cmp, callback) {
		var doApproveProcess = cmp.get("c.abortApprovalProcess");
		var Spend = cmp.get('v.Spend');
		doApproveProcess.setParams({
			ispendId  : Spend.Id,
			workItemId: cmp.get('v.workItemId'),
			comments  : cmp.get('v.Comment'),
			status    : cmp.get('v.status')
		});
		doApproveProcess.setCallback(this, function(response) {
			if (!cmp.isValid()) {
				return;
			}

			if (response.getState() === "SUCCESS") {
				return callback(null, response.getReturnValue())
			}
			callback(response.getError(), null);
		});
		$A.enqueueAction(doApproveProcess);
	},
	doErrorProcessing: function(errs) {
		var msgs = this.getErrors(errs, 'You don’t have the necessary permissions to approve this Spend.');
		$A.get('e.c:EUR_ISP_ModalWindowErrorEvent').setParams({
			details: msgs.join('<br/>')
		}).fire();
	},
	getErrors: function(errs, defaultErr) {
		var details = [];
		if (errs.message) {
			details.push(errs.message);
			return details;
		}

		errs.forEach(function(err) {
			if (err.message) {
				details.push(err.message);
			}
			if (!err.message) {
				;(err.pageErrors || []).forEach(function(pErr) {
					details.push(pErr.message);
				});

				if (err.fieldErrors) {
					for (var field in err.fieldErrors) {
						if (!err.fieldErrors.hasOwnProperty(field)) {
							continue;
						}
						;(err.fieldErrors[field] || []).forEach(function(pErr) {
							details.push(pErr.message);
						});
					}
				}
			}
		});
		return details.length ? details : [defaultErr];
	}
})