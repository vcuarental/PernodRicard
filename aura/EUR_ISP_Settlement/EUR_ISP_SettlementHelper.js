({
	getSettlement: function(cmp, settlementId, callback) {
		if (!cmp.isValid() || !settlementId) {
			return callback(null);
		}

		var hlpr = this;
		var action = cmp.get('c.getById');
			action.setParams({
				settlementId: settlementId
			});
			action.setCallback(this, function(response) {
				if (!cmp.isValid()) {
					return;
				}

				var Settlement = null;
				if (response.getState() === 'SUCCESS') {
					Settlement = response.getReturnValue();
				}

				hlpr.doCalculateSettlementRemainingMatch(Settlement);
				callback(Settlement);
			});
		$A.enqueueAction(action);
	},
	closeSettlement: function(cmp, settlementId, callback) {
		var hlpr = this;
		var action = cmp.get('c.closeSettlementRecord');
			action.setParams({
				settlementId: settlementId
			});
			action.setCallback(hlpr, function(response) {
				if (!cmp.isValid()) {
					return;
				}

				if (response.getState() !== 'SUCCESS') {
					return callback(response.getError());
				}

				var Settlement = response.getReturnValue() || {};
				hlpr.doCalculateSettlementRemainingMatch(Settlement);
				return callback(null, Settlement);
			});
		$A.enqueueAction(action);
	},
	createBudgetTransaction: function(cmp, params, callback) {
		var action = cmp.get('c.createBudgetTransactionRecord');
			action.setParams({
				activityId: params.activityId,
				itemId: params.itemId || null
			});
			action.setCallback(this, function(response) {
				if (!cmp.isValid()) {
					return;
				}
				if (response.getState() !== 'SUCCESS') {
					return callback(response.getError());
				}
				callback(null, response.getReturnValue() || []);
			});
		$A.enqueueAction(action);
	},
	createSettlementLine: function(cmp, params, callback) {
		var SettlementLine = {
			sobjectType               : 'EUR_ISP_Settlement_Line__c',
			EUR_ISP_Amount__c         : params.amount,
			EUR_ISP_Settlement__c     : params.settlementId,
			EUR_ISP_Spend_Activity__c : params.activityId
		};
		if (params.itemId) {
			SettlementLine.EUR_ISP_Spend_Item__c = params.itemId;
		}

		var action = cmp.get('c.createSettlementLineRecord');
			action.setParams({
				settlementLine: SettlementLine
			});
			action.setCallback(this, function(response) {
				if (!cmp.isValid()) {
					return;
				}
				if (response.getState() !== 'SUCCESS') {
					return callback(response.getError());
				}
				callback(null, response.getReturnValue() || []);
			});
		$A.enqueueAction(action);
	},
	deleteSettlementLine: function(cmp, params, callback) {
		var action = cmp.get('c.deleteSettlementLineRecord');
			action.setParams({
				settlementLineId: params.lineItemId,
				settlementId: params.settlementId
			});
			action.setCallback(this, function(response) {
				if (!cmp.isValid()) {
					return;
				}
				if (response.getState() !== 'SUCCESS') {
					return callback(response.getError());
				}
				callback(null, response.getReturnValue() || []);
			});
		$A.enqueueAction(action);
	},
	getSettlementLines: function(cmp, settlementId, callback) {
		if (!cmp.isValid() || !settlementId) {
			return callback([]);
		}

		var action = cmp.get('c.getSettlementLines');
			action.setParams({
				settlementId: settlementId
			});
			action.setCallback(this, function(response) {
				if (!cmp.isValid()) {
					return;
				}
				callback(response.getState() === 'SUCCESS' ? response.getReturnValue() : []);
			});
		$A.enqueueAction(action);
	},
	doMatchRecalculation: function(cmp, SettlementLines) {
		var currentMatchValue = 0;
		(SettlementLines || []).forEach(function(item) {
			currentMatchValue += item.EUR_ISP_Amount__c ? item.EUR_ISP_Amount__c : 0;
		});

		var Settlement = cmp.get('v.Settlement');
		Settlement.EUR_ISP_Matched__c = currentMatchValue;
		this.doCalculateSettlementRemainingMatch(Settlement)
		cmp.set('v.Settlement', Settlement);
	},
	doCalculateSettlementRemainingMatch: function(Settlement) {
		if (Settlement && Settlement.Id) {
			var amount = Settlement.EUR_ISP_Amount_Excluding_Tax__c ? Settlement.EUR_ISP_Amount_Excluding_Tax__c : 0;
			var matchedAmount = Settlement.EUR_ISP_Matched__c ? Settlement.EUR_ISP_Matched__c : 0;
			Settlement.RemainingAmount = amount - matchedAmount;
		}
		return Settlement;
	},
	showSettlementLines: function(isVisible) {
		if (isVisible) {
			$('.settlement-lines--header > button').removeClass('arrow-right');
			$('.settlement-lines--body').show('slow');
		} else {
			$('.settlement-lines--header > button').addClass('arrow-right');
			$('.settlement-lines--body').hide('slow');
		}
	},
	getErrors: function(errs) {
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
		return details.length ? details : ['Fatal Error'];
	}
})