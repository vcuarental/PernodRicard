({
	doInit: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		var UserPermissions = cmp.get('v.UserPermissions') || {};
		hlpr.init(UserPermissions);
		var selectionData = hlpr.getSelectionData(UserPermissions);
		cmp.set('v.selectionData', selectionData);
		cmp.set('v.hasError', false);
		cmp.set('v.errorMsgs', []);
		cmp.set('v.isSaving', false);
	},
	initActivity: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		//hlpr.resetActivityData(cmp);
		hlpr.updatedSelectionData(cmp);
		cmp.set('v.hasError', false);
		cmp.set('v.errorMsgs', []);
		cmp.set('v.isSaving', false);
		cmp.set('v.isValidForClose', hlpr.isValidForClose(cmp));
	},
	clearErrs: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		cmp.set('v.hasError', false);
		cmp.set('v.errorMsgs', []);
		cmp.set('v.isSaving', false);
		cmp.set('v.isValidForClose', hlpr.isValidForClose(cmp));
	},
	handleUpdateEvent: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var SpendActivity = cmp.get('v.SpendActivity');
		if (!SpendActivity.__isUpdated) {
			SpendActivity.__isUpdated = true;
			cmp.set('v.SpendActivity', SpendActivity);
		}
	},
	showError: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams();
		if (params && params.arguments) {
			cmp.set('v.hasError', params.arguments.hasError);
			cmp.set('v.errorMsgs', params.arguments.hasError ? params.arguments.errorMsgs : []);

			if (params.arguments.clearSpendActivity) {
				hlpr.resetActivityData(cmp);
			}
		}
	},
	triggerValidationEvent: function(cmp, e, hlpr) {
		cmp.getEvent('validationEvent').fire();
	},
	closeActivity: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		if (e.getParams().eventName === 'close') {
			hlpr.closeActivity(cmp, cmp.get('v.SpendActivity'));
			e.stopPropagation();
		}
	},
	confirmOnCloseActivity: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		if (!hlpr.isValidForClose(cmp)) {
			return;
		}

		var SpendActivity = cmp.get('v.SpendActivity');
		var msg = $A.util.format(hlpr.CUSTOM_MESSAGES.WARNINGS.CLOSE_BUDGET, hlpr.getFormatedCurrency(hlpr.getAvailableAmount(SpendActivity), SpendActivity));
		cmp.find('confirmation').showConfirmation(msg, 'Cancel', 'Ok', 'close');

		e.target.setAttribute('disabled', 'disabled');
		setTimeout(function() {
			e.target.removeAttribute('disabled', 'disabled');
		}, 2000);
	},
	confirmedSaveAction: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		if (e.getParams().eventName === 'save') {
			var SpendActivity = cmp.get('v.SpendActivity');
			hlpr.saveSpendActivity(cmp, SpendActivity);
			e.stopPropagation();
		}
	},
	saveSpendActivity: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams() && e.getParams().arguments;
		if (cmp.get('v.hasError')) {
			cmp.set('v.hasError', false);
			cmp.set('v.errorMsgs', []);
		}

		var SpendActivity = cmp.get('v.SpendActivity');
		if (!SpendActivity.__isUpdated && !SpendActivity.__isItemUpdated) {
			return;
		}

		hlpr.validateActivityAndSave(cmp, SpendActivity, params.calculatedAmount, function(err) {
			if (!err) {
				return;
			}

			cmp.set('v.errorMsgs', hlpr.getErrors(err));
			cmp.set('v.hasError', true);
		});
	}
})