({
	PICKLIST_FIELDS: [
		'EUR_ISP_Status__c',
		'EUR_ISP_Payment_Terms__c',
		'EUR_ISP_Approval_Status__c',
		'EUR_ISP_Settlement_Method__c'
	],
	PICKLIST_FIELD_VALUES: { /* will be defined on INIT action */ },
	CUSTOM_MESSAGES: { /* will be defined on INIT action */ },
	REQUIRED_FIELDS: [],
	STATUS_FIELD_FLOW : {
		'Ringfence' : ['Ringfence', 'Planned', 'Committed', 'Cancelled'],
		'Planned'   : ['Ringfence', 'Planned', 'Committed', 'Cancelled'],
		'Committed' : ['Committed', 'Cancelled'],
		'Cancelled' : ['Cancelled'],
		'SKIP'      : ['Invoiced']
	},
	init: function(UserPermissions) {
		var hlpr = this;

		hlpr.CUSTOM_MESSAGES = {
			ERRORS: {
				FATAL_ERROR: $A.get('$Label.c.EUR_ISP_FATAL_ERROR'),//'Fatal Error',
				REQUIRED_VALUE: $A.get('$Label.c.EUR_ISP_REQUIRED_FIELDS')//'Required fields have been left blank'
			},
			WARNINGS: {
				RELEASE_BUDGET: $A.get('$Label.c.EUR_ISP_INCREASE_AMOUNT_TEXT'),  //'This performance will release {0} to budget, click OK to continue'
				DECREASE_BUDGET: $A.get('$Label.c.EUR_ISP_DECREASE_AMOUNT_TEXT'), //'This performance will decrease {0} to budget, click OK to continue'
				CLOSE_BUDGET: $A.get('$Label.c.EUR_ISP_MATCH_AMOUNT_TEXT'),  //'This is being closed {0}, will be released to budget, click OK to continue'
			}
		};

		if (UserPermissions.PROJECT_NAME !== 'DE_SFA_PROJECT') {
			hlpr.REQUIRED_FIELDS = [
				'EUR_ISP_Status__c',
				'EUR_ISP_Approval_Status__c',
				'EUR_ISP_Payment_Terms__c',
				'EUR_ISP_Settlement_Method__c',
				'EUR_ISP_Spend__c',
				'EUR_ISP_Spend_Activity_Type__c',
				'RecordType'
			];
		}

		hlpr.PICKLIST_FIELDS.forEach(function(fieldName) {
			hlpr.PICKLIST_FIELD_VALUES[fieldName] = hlpr.PICKLIST_FIELD_VALUES[fieldName] || {};
			;(UserPermissions.EUR_ISP_Spend_Activity__c.fields[fieldName].picklistValues || []).forEach(function(val) {
				// value to value
				hlpr.PICKLIST_FIELD_VALUES[fieldName][val.value] = val.value;
				// label to value
				hlpr.PICKLIST_FIELD_VALUES[fieldName][val.label] = val.value;
			});
		});
	},
	resetActivityData: function(cmp) {
		var activity = cmp.get('v.SpendActivity');
		if (activity && activity._SpendActivity) {
			var oldActivity = activity._SpendActivity;
			oldActivity._SpendActivity = JSON.parse(JSON.stringify(oldActivity));
			//console.log(oldActivity);
			cmp.set('v.SpendActivity', oldActivity);
		}
	},
	fireSpendActivitySaveEvent: function(SpendActivity) {
		$A.get('e.c:EUR_ISP_SpendActivitySaveEvent').setParams({
			SpendActivity : SpendActivity,
			spendId       : SpendActivity.EUR_ISP_Spend__c
		}).fire();
	},
	getSelectionData: function(UserPermissions) {
		var selectionData = {};
		var hlpr = this;

		hlpr.PICKLIST_FIELDS.forEach(function(fieldName) {
			var newArr = [];
			;(UserPermissions.EUR_ISP_Spend_Activity__c.fields[fieldName].picklistValues || []).forEach(function(val) {
				if (fieldName === 'EUR_ISP_Status__c' && val.value === 'Invoiced') {
					// skip this value
				} else {
					newArr.push({
						value : val.value,
						text  : val.label
					});
				}
			});
			selectionData[fieldName] = newArr;
		});
		return selectionData;
	},
	updatedSelectionData: function(cmp) {
		var selectionData = cmp.get('v.selectionData'),
			SpendActivity = cmp.get('v.SpendActivity'),
			fieldName = 'EUR_ISP_Status__c';

		if (!selectionData || !SpendActivity || !SpendActivity.EUR_ISP_Status__c) {
			return;
		}

		var hlpr = this;
		var statusValue = hlpr.PICKLIST_FIELD_VALUES.EUR_ISP_Status__c[SpendActivity.EUR_ISP_Status__c];
		var picklistValues = cmp.get('v.UserPermissions').EUR_ISP_Spend_Activity__c.fields[fieldName].picklistValues || [];
		var acceptedValues = hlpr.STATUS_FIELD_FLOW[statusValue] || [];
		var newArr = [];

		picklistValues.forEach(function(val) {
			if (!~hlpr.STATUS_FIELD_FLOW.SKIP.indexOf(val.value)) {
				if (!!~acceptedValues.indexOf(val.value) || !SpendActivity.Id) {
					if (val.value !== 'Cancelled' ||
						(val.value === 'Cancelled' && SpendActivity.EUR_ISP_Matched__c === 0)) {
						newArr.push({
							value : val.value,
							text  : val.label
						});
					}
				}
			}
		});

		selectionData[fieldName] = newArr;
		cmp.set('v.statusReload', true);
		cmp.set('v.selectionData', selectionData);
		cmp.set('v.statusReload', false);
	},
	isObjectValid: function(cmp, SpendActivity) {
		var isValid = true;
		this.REQUIRED_FIELDS.forEach(function(field) {
			if (!SpendActivity[field]) {
				isValid = false;
			}
		});
		return isValid;
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
		return details.length ? details : [this.CUSTOM_MESSAGES.ERRORS.FATAL_ERROR];
	},
	getAvailableAmount: function(SpendActivity) {
		var amount = parseFloat(SpendActivity.EUR_ISP_Activity_Amount__c || 0, 10);
		var matched = parseFloat(SpendActivity.EUR_ISP_Matched__c || 0, 10);
		return amount - matched;
	},
	getFormatedCurrency: function(value, obj) {
		var currString = value ? $A.localizationService.formatCurrency(value) : '0.00';
		currString = currString.replace(/[^\d+\,\.]/g, '');
		return obj.CurrencyIsoCode + ' ' + currString;
	},
	isValidForClose: function(cmp) {
		var SpendActivity = cmp.get('v.SpendActivity');
		if (!SpendActivity) {
			return false;
		}

		var statusValue = this.PICKLIST_FIELD_VALUES.EUR_ISP_Status__c[SpendActivity.EUR_ISP_Status__c];
		var approvalStatusValue = this.PICKLIST_FIELD_VALUES.EUR_ISP_Approval_Status__c[SpendActivity.EUR_ISP_Approval_Status__c];
		var isValidStatuses = approvalStatusValue === 'Approved' && statusValue === 'Committed';
		var availableAmount = this.getAvailableAmount(SpendActivity);
		//console.log(isValidStatuses, availableAmount, SpendActivity.EUR_ISP_Approval_Status__c , SpendActivity.EUR_ISP_Status__c);
		return isValidStatuses && (availableAmount > 0);
	},
	mapCorrectPickListValues: function(cmp, SpendActivity) {
		var UserPermissions = cmp.get('v.UserPermissions') || {};
		this.PICKLIST_FIELDS.forEach(function(fieldName) {
			var value = SpendActivity[fieldName];
			if (value) {
				;(UserPermissions.EUR_ISP_Spend_Activity__c.fields[fieldName].picklistValues || []).forEach(function(entry) {
					if (value === entry.label) {
						SpendActivity[fieldName] = entry.value;
					}
				});
			}
		});
	},
	closeActivity: function(cmp, SpendActivity) {
		var hlpr = this;
		cmp.getEvent('showLoading').fire();
		var action = cmp.get('c.releaseActivityAmount');
			action.setParams({
				activityId: SpendActivity.Id
			});
			action.setCallback(this, function(response) {
				if (!cmp.isValid()) {
					return;
				}
				if (response.getState() !== 'SUCCESS') {
					var err = response.getError();
					cmp.set('v.errorMsgs', hlpr.getErrors(err));
					cmp.set('v.hasError', true);
					cmp.getEvent('hideLoading').fire();
					return;
				}
				var data = response.getReturnValue();
				cmp.set('v.SpendActivity', data);
				hlpr.fireSpendActivitySaveEvent(data);
			});
		$A.enqueueAction(action);
	},
	saveSpendActivity: function(cmp, SpendActivity) {
		var hlpr = this;
		var itemsAmount = cmp.get('v.tmpAmount') || 0;
		SpendActivity.EUR_ISP_Total_Spend_Items_Amount__c = parseFloat(itemsAmount || 0, 10);
		SpendActivity.EUR_ISP_Total_Activity_Amount__c = parseFloat(itemsAmount || 0, 10) + parseFloat(SpendActivity.EUR_ISP_Activity_Amount__c || 0, 10);
		
		//console.log('!!!' , itemsAmount, SpendActivity);
		hlpr.mapCorrectPickListValues(cmp, SpendActivity);
		cmp.getEvent('showLoading').fire();

		var updateSpendActivityAction = SpendActivity.Id ? cmp.get("c.updateSpendActivityRecord") : cmp.get("c.createSpendActivityRecord");
		updateSpendActivityAction.setParams({
			activityItem: SpendActivity
		});
		updateSpendActivityAction.setCallback(hlpr, function(response) {
			if (!cmp.isValid()) {
				return;
			}

			if (response.getState() === "SUCCESS") {
				var data = response.getReturnValue();
				// copy data coz this fields will be calculated only after the Spend Items update/create
				if (data) {
					// make copy to rollback changes
					data._SpendActivity = JSON.parse(JSON.stringify(data));
					data.EUR_ISP_Total_Spend_Items_Amount__c = SpendActivity.EUR_ISP_Total_Spend_Items_Amount__c;
					data.EUR_ISP_Total_Activity_Amount__c = SpendActivity.EUR_ISP_Total_Activity_Amount__c;
				}

				cmp.set('v.tmpAmount', null);
				cmp.set('v.SpendActivity', data);
				hlpr.fireSpendActivitySaveEvent(data);
				hlpr.updatedSelectionData(cmp);
				return;
			}

			var err = response.getError();
			//console.log('err', err, cmp.get('v.SpendActivity'));
			hlpr.resetActivityData(cmp);

			cmp.set('v.errorMsgs', hlpr.getErrors(err));
			cmp.set('v.hasError', true);
			cmp.getEvent('hideLoading').fire();
		});
		$A.enqueueAction(updateSpendActivityAction);
	},
	validateActivityAndSave: function(cmp, SpendActivity, itemsAmount, callback) {
		if (!cmp.isValid()) {
			return;
		}

		// check lookups
		SpendActivity.sobjectType = 'EUR_ISP_Spend_Activity__c';
		if (!SpendActivity.RecordTypeId) {
			SpendActivity.RecordTypeId = SpendActivity.RecordType ? SpendActivity.RecordType.Id : null;
		}
		if (!SpendActivity.EUR_ISP_Spend__c) {
			SpendActivity.EUR_ISP_Spend__c = SpendActivity.EUR_ISP_Spend__r ? SpendActivity.EUR_ISP_Spend__r.Id : null;
		}
		if (!SpendActivity.EUR_ISP_Spend_Activity_Type__c) {
			SpendActivity.EUR_ISP_Spend_Activity_Type__c = SpendActivity.EUR_ISP_Spend_Activity_Type__r ? SpendActivity.EUR_ISP_Spend_Activity_Type__r.Id : null;
		}
		SpendActivity.EUR_ISP_Vendor__c = SpendActivity.EUR_ISP_Vendor__r ? SpendActivity.EUR_ISP_Vendor__r.Id : null;

		// validate required fields
		if (!this.isObjectValid(cmp, SpendActivity)) {
			var msg = this.CUSTOM_MESSAGES.ERRORS.REQUIRED_VALUE;
			return callback({message: msg});
		}

		// save tmp data 
		cmp.set('v.SpendActivity', SpendActivity);
		cmp.set('v.tmpAmount', itemsAmount);

		// calculate delta amount and save if Amount does not changed
		var prevActivityAmount = parseFloat(SpendActivity.EUR_ISP_Total_Activity_Amount__c || 0, 10);
		var currentActivityAmount = parseFloat(itemsAmount || 0, 10) + parseFloat(SpendActivity.EUR_ISP_Activity_Amount__c || 0, 10);
		var deltaValue = prevActivityAmount - currentActivityAmount;
		if (deltaValue === 0) {
			return this.saveSpendActivity(cmp, SpendActivity);
		}

		// show message that delta will be added to the Budget 
		var tmplMsg = deltaValue > 0 ? this.CUSTOM_MESSAGES.WARNINGS.RELEASE_BUDGET : this.CUSTOM_MESSAGES.WARNINGS.DECREASE_BUDGET;
		var msg = $A.util.format(tmplMsg, ((deltaValue > 0 ? deltaValue : -deltaValue) + ' ' + SpendActivity.CurrencyIsoCode));
		cmp.find('confirmation').showConfirmation(msg, 'Cancel', 'Ok', 'save');
	}
})