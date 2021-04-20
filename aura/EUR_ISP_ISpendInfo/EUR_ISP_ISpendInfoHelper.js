({
	PICKLIST_FIELDS: [
		'EUR_ISP_Status__c',
		'EUR_ISP_Allocation_Method__c',
		'EUR_ISP_Approval_Status__c',
		'EUR_ISP_Phasing_Method__c',
		'EUR_ISP_Funding_Based__c',
		'EUR_ISP_Settlement_Method__c'
	],
	PICKLIST_FIELD_VALUES: { /* will be defined on INIT action */ },
	CUSTOM_MESSAGES: { /* will be defined on INIT action */ },
	REQUIRED_FIELDS: [],
	STATUS_FIELD_FLOW : {
		'Ringfence' : ['Ringfence', 'Planned', 'Committed'],
		'Planned'   : ['Ringfence', 'Planned', 'Committed'],
		'Committed' : ['Committed'],
		'SKIP'      : ['Invoiced']
	},
	init: function(UserPermissions) {
		var hlpr = this;

		hlpr.CUSTOM_MESSAGES = {
			ERRORS: {
				FATAL_ERROR: $A.get('$Label.c.EUR_ISP_FATAL_ERROR'),//'Fatal Error',
				REQUIRED_VALUE: $A.get('$Label.c.EUR_ISP_REQUIRED_FIELDS')//'Required fields have been left blank'
			}
		};
		if (UserPermissions.PROJECT_NAME !== 'DE_SFA_PROJECT') {
			hlpr.REQUIRED_FIELDS = [
				'EUR_ISP_Status__c',
				'EUR_ISP_Approval_Status__c',
				'EUR_ISP_Allocation_Method__c',
				'EUR_ISP_Phasing_Method__c',
				'EUR_ISP_Settlement_Method__c',
				'EUR_ISP_Description__c',
				'EUR_ISP_Start_Date__c',
				'EUR_ISP_End_Date__c',
				'EUR_ISP_Account__c'
			];
		}

		hlpr.PICKLIST_FIELDS.forEach(function(fieldName) {
			hlpr.PICKLIST_FIELD_VALUES[fieldName] = hlpr.PICKLIST_FIELD_VALUES[fieldName] || {};
			;(UserPermissions.EUR_ISP_Spend__c.fields[fieldName].picklistValues || []).forEach(function(val) {
				// value to value
				hlpr.PICKLIST_FIELD_VALUES[fieldName][val.value] = val.value;
				// label to value
				hlpr.PICKLIST_FIELD_VALUES[fieldName][val.label] = val.value;
			});
		});
	},
	getSelectionData: function(UserPermissions, Spend) {
		if (!Spend) {
			return;
		}

		var hlpr = this;
		var acceptedValues = hlpr.STATUS_FIELD_FLOW[ hlpr.PICKLIST_FIELD_VALUES.EUR_ISP_Status__c[Spend.EUR_ISP_Status__c] ];
		acceptedValues = acceptedValues ? acceptedValues : hlpr.STATUS_FIELD_FLOW.Ringfence;

		var selectionData = {};
		hlpr.PICKLIST_FIELDS.forEach(function(fieldName) {
			var newArr = [];
			;(UserPermissions.EUR_ISP_Spend__c.fields[fieldName].picklistValues || []).forEach(function(val) {
				if (fieldName !== 'EUR_ISP_Status__c') {
					newArr.push({
						value : val.value,
						text  : val.label
					});
				} else {
					if (!~hlpr.STATUS_FIELD_FLOW.SKIP.indexOf(val.value)) {
						if (!!~acceptedValues.indexOf(val.value)) {
							newArr.push({
								value : val.value,
								text  : val.label
							});
						}
					}
				}
			});
			selectionData[fieldName] = newArr;
		});
		return selectionData;
	},
	isObjectValid: function(cmp, Spend) {
		var isValid = true;
		this.REQUIRED_FIELDS.forEach(function(field) {
			if (!Spend[field]) {
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
	doRefreshSpend: function(cmp, callback) {
		var fieldsToRefresh = [
			'EUR_ISP_Status__c',
			'EUR_ISP_Approval_Status__c',
			'EUR_ISP_Awaiting_Approval_Amount__c',
			'EUR_ISP_Deductible_Value__c',
			'EUR_ISP_Matched__c',
			'EUR_ISP_Total_Spend_Activities_Amount__c'
		];

		var Spend = cmp.get('v.Spend');
		var getSpend = cmp.get("c.getISpend");

		getSpend.setParams({
			spendId: Spend.Id
		});
		getSpend.setCallback(this, function(response) {
			if (!cmp.isValid() || response.getState() !== "SUCCESS") {
				return;
			}

			var tempSpend = response.getReturnValue() || {};
			fieldsToRefresh.forEach(function(field) {
				Spend[field] = tempSpend[field];
			});

			callback(Spend);
		});
		$A.enqueueAction(getSpend);
	},
	doSave: function(cmp) {
		if (cmp.get('v.hasError')) {
			cmp.set('v.hasError', false);
			cmp.set('v.errorMsgs', []);
		}
		cmp.set('v.isSaving', true);

		var hlpr = this;
		var Spend = cmp.get('v.Spend');
		hlpr.saveSpend(cmp, Spend, function(err, data) {
			if (err) {
				cmp.set('v.errorMsgs', hlpr.getErrors(err));
				cmp.set('v.hasError', true);
				cmp.set('v.isSaving', false);
				return;
			}

			if (data) {
				cmp.set('v.Spend', data);
				cmp.set('v.isUpdated', false);
				cmp.getEvent('ShowSpendEvent').setParams({
					spendId: data.Id
				}).fire();
			}
			cmp.set('v.isSaving', false);
		});
	},
	mapCorrectPickListValues: function(cmp, Spend) {
		var UserPermissions = cmp.get('v.UserPermissions') || {};
		this.PICKLIST_FIELDS.forEach(function(fieldName) {
			var value = Spend[fieldName];
			if (value) {
				;(UserPermissions.EUR_ISP_Spend__c.fields[fieldName].picklistValues || []).forEach(function(entry) {
					if (value === entry.label) {
						Spend[fieldName] = entry.value;
					}
				});
			}
		});
	},
	saveSpend: function(cmp, Spend, callback) {
		if (!cmp.isValid()) {
			return;
		}

		Spend.sobjectType = 'EUR_ISP_Spend__c';
		if (!Spend.RecordTypeId && Spend.RecordType) {
			Spend.RecordTypeId = Spend.RecordType.Id
		}
		Spend.EUR_ISP_Account__c = Spend.EUR_ISP_Account__r ? Spend.EUR_ISP_Account__r.Id : null;
		Spend.EUR_ISP_Vendor__c = Spend.EUR_ISP_Vendor__r ? Spend.EUR_ISP_Vendor__r.Id : null;

		if (!this.isObjectValid(cmp, Spend)) {
			var msg = this.CUSTOM_MESSAGES.ERRORS.REQUIRED_VALUE;
			return callback({message: msg});
		}

		// map picklilst values
		this.mapCorrectPickListValues(cmp, Spend);

		var updateSpendAction = Spend.Id ? cmp.get("c.updateSpendRecord") : cmp.get("c.createSpendRecord");
		updateSpendAction.setParams({
			spendItem: Spend
		});
		updateSpendAction.setCallback(this, function(response) {
			if (!cmp.isValid()) {
				return;
			}

			if (response.getState() === "SUCCESS") {
				return callback(null, response.getReturnValue());
			}

			callback(response.getError());
		});
		$A.enqueueAction(updateSpendAction);
	},
	submitForApproval: function(cmp, Spend, callback) {
		var submitRequest = cmp.get("c.submitSpendForApproval");
		submitRequest.setParams({
			spendId: Spend.Id
		});
		submitRequest.setCallback(this, function(response) {
			if (!cmp.isValid()) {
				return;
			}

			if (response.getState() === "SUCCESS") {
				return callback(null, response.getReturnValue());
			}

			callback(response.getError());
		});
		$A.enqueueAction(submitRequest);
	},
	fireModalEvent: function(cmp, spendId) {
		$A.get('e.c:EUR_ISP_ModalWindowShowEvent').setParams({
			title: 'Recall Approval Request',
			actionButtonLabel: 'Recall Approval Request',
			saveEventName: 'EUR_ISP_SpendApproveEvent',
			cmpName: 'EUR_ISP_SpendApproveForm',
			width: '50%',
			settings: {
				spendId: spendId,
				status: 'Removed'
			}
		}).fire();
	}
})