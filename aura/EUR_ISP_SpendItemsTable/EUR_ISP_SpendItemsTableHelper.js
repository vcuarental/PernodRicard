({
	PICKLIST_FIELD_VALUES: { /* will be defined on INIT action */ },
	PICKLIST_VALUES: { /* will be defined on INIT action */ },
	CUSTOM_MESSAGES: { /* will be defined on INIT action */ },
	PICKLIST_FIELDS: {
		EUR_ISP_Spend_Item__c: ['EUR_ISP_Unit_Of_Measure__c'],
		EUR_ISP_Spend_Activity__c: [
			'EUR_ISP_Status__c',
			'EUR_ISP_Payment_Terms__c',
			'EUR_ISP_Approval_Status__c',
			'EUR_ISP_Settlement_Method__c'
		]
	},
	EUR_ISP_ACTIVITY_TYPES_MAPPING : {
		'Family'             : 'EUR_ISP_Family__',
		'Brand'              : 'EUR_ISP_Brand__',
		'Brand Quality'      : 'EUR_ISP_Brand_Quality__',
		'Brand Quality Size' : 'EUR_ISP_Brand_Quality_Size__',
		'SKU'                : 'EUR_ISP_SKU_EU__'
	},
	ACTIONS: {
		CREATE: 'createSpendItems',
		UPDATE: 'updateSpendItems',
		DEL   : 'deleteSpendItems'
	},
	setPicklistValues: function(UserPermissions) {
		var objectMap = {
			EUR_ISP_Spend_Item__c: UserPermissions.EUR_ISP_Spend_Item__c,
			EUR_ISP_Spend_Activity__c: UserPermissions.EUR_ISP_Spend_Activity__c
		};
		var picklistValues = {};
		var hlpr = this;

		Object.keys(objectMap).forEach(function(objectName) {
			hlpr.PICKLIST_FIELD_VALUES[objectName] = {};
			var isItems = objectName === 'EUR_ISP_Spend_Item__c';

			hlpr.PICKLIST_FIELDS[objectName].forEach(function(fieldName) {
				hlpr.PICKLIST_FIELD_VALUES[objectName][fieldName] = {};

				if (isItems) {
					hlpr.PICKLIST_VALUES[fieldName] = [];
				}

				;(objectMap[objectName].fields[fieldName].picklistValues || []).forEach(function(selection) {
					hlpr.PICKLIST_FIELD_VALUES[objectName][fieldName] = {};


					if (isItems) {
						hlpr.PICKLIST_VALUES[fieldName].push({
							value: selection.value,
							text: selection.label
						});
					}
				});
			});
		});
	},
	initCustomLabels: function() {
		this.CUSTOM_MESSAGES = {
			ERRORS: {
				FATAL_ERROR: $A.get('$Label.c.EUR_ISP_FATAL_ERROR'),//'Fatal Error',
				INVALID_VALUE: $A.get('$Label.c.EUR_ISP_INVALID_VALUE'),//'Invalid value',
				REQUIRED_VALUE: $A.get('$Label.c.EUR_ISP_REQUIRED_FIELD')//'This field is required'
			},
			WARNINGS: {
				CLOSE_BUDGET: $A.get('$Label.c.EUR_ISP_MATCH_AMOUNT_TEXT'),  //'This is being closed {0}, will be released to budget, click OK to continue'
			}
		};
	},
	getActivitySpendItems: function(cmp, settings, callback) {
		var hlpr = this;
		var action = cmp.get("c.getSpendActivityItems");
		action.setParams(settings);
		action.setCallback(hlpr, function(response) {
			hlpr.doResponseProcessing(cmp, response, function(err, data) {
				if (err) {
					return callback(err);
				}

				data.forEach(function(item) {
					item.__Id = Math.floor((Math.random() * 10000) + 1);
				});
				callback(null, data);
			});
		});
		$A.enqueueAction(action);
	},
	doAction: function(cmp, spendItems, actionName, callback) {
		if (!spendItems || !spendItems.length) {
			return callback(null, []);
		}

		var hlpr = this;
		var action = cmp.get('c.' + actionName);
		action.setParams({
			spendItems: spendItems
		});
		action.setCallback(hlpr, function(response) {
			hlpr.doResponseProcessing(cmp, response, function(err, data) {
				if (err) {
					cmp.set('v.errorMsgs', hlpr.getErrors(err));
					cmp.set('v.hasError', true);
					return callback(err);
				}
				callback(null, data);
			});
		});
		$A.enqueueAction(action);
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
	getActivitySpendItemsToProcess: function(spendItemsToProcess, SpendActivity) {
		var SpendItems = [];
		spendItemsToProcess = spendItemsToProcess || {};

		for (var key in spendItemsToProcess) {
			if (spendItemsToProcess.hasOwnProperty(key)) {
				var SpendItem = spendItemsToProcess[key];
				SpendItem.EUR_ISP_Spend_Activity__c = SpendActivity.Id;
				delete SpendItem.EUR_ISP_Spend_Activity__r;
				SpendItems.push(SpendItem);
			}
		}
		return SpendItems;
	},
	getNewActivitySpendItem: function(SpendActivity, SpendActivityType, BrandObject, SpendItems) {
		var SpendItem = {sobjectType : 'EUR_ISP_Spend_Item__c'};
		SpendItem.EUR_ISP_Spend_Activity__r = SpendActivity;
		SpendItem.EUR_ISP_Spend_Activity__c = SpendActivity.Id;
		SpendItem.CurrencyIsoCode = SpendActivity.CurrencyIsoCode;
		SpendItem.__Id = Math.floor((Math.random() * 10000) + 1);

		var lookupApiName = this.EUR_ISP_ACTIVITY_TYPES_MAPPING[SpendActivityType.EUR_ISP_Product_Level_Of_Input__c];
		if (!lookupApiName) {
			return null;
		}

		if (SpendActivityType.EUR_ISP_Display_Percentage__c) {
			SpendItem.EUR_ISP_Percentage__c = SpendItems.length ? 0 : 100;
		}

		SpendItem[lookupApiName + 'r'] = BrandObject;
		SpendItem[lookupApiName + 'c'] = BrandObject.Id;
		return SpendItem;
	},
	updateSpendItemField: function(params, d) {
		if (!params.cmp.isValid()) {
			return d.resolve();
		}

		;(params.cmp.get('v.SpendItems') || []).forEach(function(item) {
			if (item.__Id && item.__Id === params.pk) {
				if (!item.Id) {
					var SpendItemsToInsert = params.cmp.get('v.SpendItemsToInsert') || {};
					SpendItemsToInsert[item.__Id] = item;
					params.cmp.set('v.SpendItemsToInsert', SpendItemsToInsert);
				} else {
					var SpendItemsToUpdate = params.cmp.get('v.SpendItemsToUpdate') || {};
					SpendItemsToUpdate[item.__Id] = item;
					params.cmp.set('v.SpendItemsToUpdate', SpendItemsToUpdate);
				}
				if (!params.cmp.get('v.isUpdated')) {
					params.cmp.set('v.isUpdated', true);
				}
				// timeout to show the spinner instead of the input field
				//setTimeout(function() {
					d.resolve();
				//}, 100);
			}
		});
	},
	doDeleteSpendItem: function(cmp, rowData) {
		// remve from the Create list
		var itemsToCreate = cmp.get('v.SpendItemsToInsert') || {};
		delete itemsToCreate[rowData.__Id];
		cmp.set('v.SpendItemsToInsert', itemsToCreate);
		// remve from the Update list
		var itemsToUpdate = cmp.get('v.SpendItemsToUpdate') || {};
		delete itemsToUpdate[rowData.__Id];
		cmp.set('v.SpendItemsToUpdate', itemsToUpdate);

		var SpendItems = cmp.get('v.SpendItems') || [];
		var filtered = [];
		if (!rowData.Id) {
			filtered = SpendItems.filter(function(item) {
				return (item.__Id && item.__Id !== rowData.__Id);
			});
		} else {
			filtered = SpendItems.filter(function(item) {
				return (item.Id && item.Id !== rowData.Id);
			});

			var itemsToDelete = cmp.get('v.SpendItemsToDelete') || {};
			itemsToDelete[rowData.__Id] = {
				sobjectType: 'EUR_ISP_Spend_Item__c',
				Id         : rowData.Id,
				__Id       : rowData.__Id
			};
			cmp.set('v.SpendItemsToDelete', itemsToDelete);
		}

		cmp.set('v.SpendItems', filtered);
		if (!cmp.get('v.isUpdated')) {
			cmp.set('v.isUpdated', true);
		}
	},
	closeSpendItem: function(cmp) {
		var hlpr = this;
		var selectedItemId = cmp.get('v.selectedItemId');
		var SpendActivity = cmp.get('v.SpendActivity');

		if (!selectedItemId || !SpendActivity || !SpendActivity.Id) {
			return;
		}

		cmp.getEvent('showLoading').fire();
		var action = cmp.get('c.releaseSpendItemAmount');
			action.setParams({
				spendItemId: selectedItemId
			});
			action.setCallback(hlpr, function(response) {
				hlpr.doResponseProcessing(cmp, response, function(err, data) {
					if (err) {
						cmp.set('v.errorMsgs', hlpr.getErrors(err));
						cmp.set('v.hasError', true);
						cmp.getEvent('hideLoading').fire();
						return;
					}
					cmp.set('v.SpendItems', data || []);
					$A.get('e.c:EUR_ISP_SpendViewRefreshEvent').fire();
				});
			});
		$A.enqueueAction(action);
	},
	doResponseProcessing: function(cmp, response, callback) {
		if (!cmp.isValid()) {
			return;
		}

		if (response.getState() === "SUCCESS") {
			callback(null, response.getReturnValue());
		} else {
			callback(response.getError());
		}
	},
	showConfirmation: function(cmp, item) {
		var hlpr = this;
		var amount = parseFloat(item.EUR_ISP_Total_Spend_Item__c || 0, 10);
		var matched = parseFloat(item.EUR_ISP_Matched__c || 0, 10);

		cmp.set('v.selectedItemId', item.Id);
		var msg = $A.util.format(hlpr.CUSTOM_MESSAGES.WARNINGS.CLOSE_BUDGET, hlpr.getFormatedCurrency((amount - matched), item));
		cmp.find('confirmation').showConfirmation(msg, 'Cancel', 'Ok');
	},
	resetTables: function($contentTable) {
		$contentTable.closest('div.slds-scrollable--x').find('table.table-content--no').removeClass('slds-hide');
		$contentTable.bootstrapTable('destroy');
	},
	loadTableData: function($contentTable, tableData) {
		$contentTable.bootstrapTable('load', tableData);
	},
	getFormatedCurrency: function(value, obj) {
		var currString = value || value === 0 ? $A.localizationService.formatCurrency(value) : '0.00';
		currString = currString.replace(/[^\d+\,\.]/g, '');
		return obj.CurrencyIsoCode + ' ' + currString;
	},
	getFormatedNumber: function(value, obj) {
		return value || value === 0 ? $A.localizationService.formatNumber(value) : '-';
	},
	getFormatedPercentage: function(value, obj) {
		return value || value === 0 ? parseInt($A.localizationService.formatNumber(value), 10).toFixed(2) + '%': '-';
	},
	generateTableConfig: function(cmp, tableDataLength) {
		var MAX_ITEMS_PER_PAGE = 5;
		var hlpr = this;
		var showErrorTimeoutValue = null;

		var SpendActivity = cmp.get('v.SpendActivity');
		var brandType = cmp.get('v.detectedType');
		var isEditLock = cmp.get('v.isLocked') ? true: cmp.get('v.isActivityLocked');
		var UserPermissions = cmp.get('v.UserPermissions');
		var FieldsSettings = UserPermissions.EUR_ISP_Spend_Item__c.fields;
		var ObjectSettings = UserPermissions.EUR_ISP_Spend_Item__c.theObject;

		function saveNumber(params) {
			var d = new $.Deferred;
			setTimeout($A.getCallback(function() {
				params.value = params.value ? params.value.replace(',','.') : null;
				hlpr.updateSpendItemField(params, d);
			}), 0);
			return d.promise();
		};

		function saveText(params) {
			var d = new $.Deferred;
			setTimeout($A.getCallback(function() {
				hlpr.updateSpendItemField(params, d);
			}), 0);
			return d.promise();
		};

		function validateNumberRequired(value) {
			var err = validateRequired(value);
			if (err) {
				return err;
			}
			return validateNumber(value);
		};

		function validateNumber(value) {
			value = $.trim(value);
			value = value.replace(',','.');

			var err = '';
			if (value && !/^\d+\.{0,1}\d*$/.test(value)) {
				err = hlpr.CUSTOM_MESSAGES.ERRORS.INVALID_VALUE;
			}
			//renderCmpError(cmp, err);
			return err;
		};

		function validateRequired(value) {
			value = $.trim(value);

			var err = '';
			if (!value) {
				err = hlpr.CUSTOM_MESSAGES.ERRORS.REQUIRED_VALUE;
			}
			//renderCmpError(cmp, err);
			return err;
		};

		function getLabelRequired(fieldSettigns) {
			if (isEditLock || !fieldSettigns.isUpdateable) {
				return '<span class="slds-truncate">' + fieldSettigns.label + '</span>';
			}
			return '<span class="slds-truncate required">' + fieldSettigns.label + '</span>';
		};

		function getFormatedBrandName(value, row, index) {
			return '<span class="slds-truncate">' + (value ? value.Name : '-') + '</span>';
		};

		function getEditSettings(type, fieldSettigns, saveFnc, validateFnc) {
			if (isEditLock || !fieldSettigns.isUpdateable) {
				return false;
			}

			var label = fieldSettigns.label;
			var settings = {
				toggle:'manual',
				type: type,
				title: label,
				mode: 'inline',
				showbuttons: false,
				onblur: 'ignore',
				url: saveFnc,
				params: { cmp: cmp},
				emptytext: '-',
				validate: validateFnc
			};
			if (type === 'select') {
				settings.source = hlpr.PICKLIST_VALUES.EUR_ISP_Unit_Of_Measure__c;
			}
			return settings;
		};

		// function renderCmpError(cmp, err) {
		// 	if (showErrorTimeoutValue !=null) {
		// 		clearTimeout(showErrorTimeoutValue);
		// 	}

		// 	// just delay the err msg rendering
		// 	showErrorTimeoutValue = setTimeout(function() {
		// 		$A.run(function() {
		// 			cmp.getEvent('fireErrorEvnt').setParams({
		// 				message: err
		// 			}).fire();
		// 			// var hasError = err ? true : false;
		// 			// cmp.set('v.hasError', hasError);

		// 			// if (hasError) {
		// 			// 	cmp.set('v.errorMsgs', [err]);
		// 			// }
		// 		});
		// 	}, 100);
		// };

		function isItemAvailableForClose(item) {
			//console.log(!SpendActivity , !SpendActivity.Id , !item.Id , cmp.get('v.isUpdated'));
			if (!SpendActivity || !SpendActivity.Id || !item.Id || cmp.get('v.isUpdated')) {
				return false;
			}

			var amount = parseFloat(item.EUR_ISP_Total_Spend_Item__c || 0, 10);
			var matched = parseFloat(item.EUR_ISP_Matched__c || 0, 10);
			var statusValue = SpendActivity.EUR_ISP_Status__c;//hlpr.PICKLIST_FIELD_VALUES.EUR_ISP_Spend_Activity__c.EUR_ISP_Status__c[SpendActivity.EUR_ISP_Status__c];
			var approvalStatusValue = SpendActivity.EUR_ISP_Approval_Status__c;//hlpr.PICKLIST_FIELD_VALUES.EUR_ISP_Spend_Activity__c.EUR_ISP_Approval_Status__c[SpendActivity.EUR_ISP_Approval_Status__c];
			var isValidStatuses = approvalStatusValue === 'Approved' && statusValue === 'Committed';
			//console.log(amount, matched, statusValue, approvalStatusValue);
			return isValidStatuses && (amount - matched > 0);
		};

		var TableSettings = {
			toggle: "table",
			search: tableDataLength > MAX_ITEMS_PER_PAGE,
			pagination: tableDataLength > MAX_ITEMS_PER_PAGE,
			pageSize: MAX_ITEMS_PER_PAGE,
			pageList: [5, 10, 25],
			idField: '__Id',
			columns: [],
			onClickCell: function(field, value, row, $element) {
				if (isEditLock) {
					return false;
				}

				switch(field) {
					case 'delete':
						$element.html('<div class="editableform-loading"></div>');
						setTimeout($A.getCallback(function() { hlpr.doDeleteSpendItem(cmp, row);}),0);
					break;
					case 'close':
						setTimeout($A.getCallback(function() {
							if (isItemAvailableForClose(row)) {
								hlpr.showConfirmation(cmp, row);
							}
						}), 0);
					break;
				}
				return false;
			}
		};

		// DELETE ACTION 
		if (ObjectSettings.isDeletable && !isEditLock) {
			TableSettings.columns.push({
				field: "delete",
				title: "Delete",
				label: "Delete",
				formatter: function(value, row, index) {
					// if (isEditLock) {
					// 	return '<span class="slds-truncate">Remove</span>';
					// }
					return '<a href="javascript:void(0);" data-row-id="' + row.Id + '" class="slds-truncate">Remove</a>';
				}
			});
		}

		/** START BRANDS VARIABLES */
		if (brandType === 'Family') {
			TableSettings.columns.push({
				field: "EUR_ISP_Family__r",
				title: FieldsSettings.EUR_ISP_Family__c.label,
				label: FieldsSettings.EUR_ISP_Family__c.label,
				editable: false,
				formatter: getFormatedBrandName
			});
		}
		if (brandType === 'Brand') {
			TableSettings.columns.push({
				field: "EUR_ISP_Brand__r",
				title: FieldsSettings.EUR_ISP_Brand__c.label,
				label: FieldsSettings.EUR_ISP_Brand__c.label,
				editable: false,
				formatter: getFormatedBrandName
			});
		}
		if (brandType === 'Brand Quality') {
			TableSettings.columns.push({
				field: "EUR_ISP_Brand_Quality__r",
				title: FieldsSettings.EUR_ISP_Brand_Quality__c.label,
				label: FieldsSettings.EUR_ISP_Brand_Quality__c.label,
				editable: false,
				formatter: getFormatedBrandName
			});
		}
		if (brandType === 'Brand Quality Size') {
			TableSettings.columns.push({
				field: "EUR_ISP_Brand_Quality_Size__r",
				title: FieldsSettings.EUR_ISP_Brand_Quality_Size__c.label,
				label: FieldsSettings.EUR_ISP_Brand_Quality_Size__c.label,
				editable: false,
				formatter: getFormatedBrandName
			});
		}
		if (brandType === 'SKU') {
			TableSettings.columns.push({
				field: "EUR_ISP_SKU_EU__r",
				title: FieldsSettings.EUR_ISP_SKU_EU__c.label,
				label: FieldsSettings.EUR_ISP_SKU_EU__c.label,
				editable: false,
				formatter: getFormatedBrandName
			});
		}
		/** END BRANDS VARIABLES */

		/** START FIELDS CONFIGURATED BY SPEND TYPE */
		if (cmp.get("v.SpendActivityType.EUR_ISP_Display_Lump_Sum_1__c")) {
			TableSettings.columns.push({
				field: "EUR_ISP_Lump_Sum_1__c",
				title: FieldsSettings.EUR_ISP_Lump_Sum_1__c.label,
				label: FieldsSettings.EUR_ISP_Lump_Sum_1__c.label,
				editable: getEditSettings('text', FieldsSettings.EUR_ISP_Lump_Sum_1__c, saveNumber, validateNumber),
				formatter: hlpr.getFormatedCurrency
			});
		}
		if (cmp.get("v.SpendActivityType.EUR_ISP_Display_Lump_Sum_2__c")) {
			TableSettings.columns.push({
				field: "EUR_ISP_Lump_Sum_2__c",
				title: FieldsSettings.EUR_ISP_Lump_Sum_2__c.label,
				label: FieldsSettings.EUR_ISP_Lump_Sum_2__c.label,
				editable: getEditSettings('text', FieldsSettings.EUR_ISP_Lump_Sum_2__c, saveNumber, validateNumber),
				formatter: hlpr.getFormatedCurrency
			});
		}
		if (cmp.get("v.SpendActivityType.EUR_ISP_Display_Percentage__c")) {
			TableSettings.columns.push({
				field: "EUR_ISP_Percentage__c",
				title: FieldsSettings.EUR_ISP_Percentage__c.label,
				label: FieldsSettings.EUR_ISP_Percentage__c.label,
				editable: getEditSettings('text', FieldsSettings.EUR_ISP_Percentage__c, saveNumber, validateNumber),
				formatter: hlpr.getFormatedPercentage
			});
		}
		if (cmp.get("v.SpendActivityType.EUR_ISP_Display_Variable_Fields__c")) {
			TableSettings.columns.push({
				field: "EUR_ISP_Volume__c",
				title: getLabelRequired(FieldsSettings.EUR_ISP_Volume__c),
				label: getLabelRequired(FieldsSettings.EUR_ISP_Volume__c),
				editable: getEditSettings('text', FieldsSettings.EUR_ISP_Volume__c, saveNumber, validateNumberRequired),
				formatter: hlpr.getFormatedNumber
			});
			TableSettings.columns.push({
				field: "EUR_ISP_Unit_Of_Measure__c",
				title: getLabelRequired(FieldsSettings.EUR_ISP_Unit_Of_Measure__c),
				label: getLabelRequired(FieldsSettings.EUR_ISP_Unit_Of_Measure__c),
				editable: getEditSettings('select', FieldsSettings.EUR_ISP_Unit_Of_Measure__c, saveText, validateRequired)
			});
			TableSettings.columns.push({
				field: "EUR_ISP_Per_Unit_Amount__c",
				title: getLabelRequired(FieldsSettings.EUR_ISP_Per_Unit_Amount__c),
				label: getLabelRequired(FieldsSettings.EUR_ISP_Per_Unit_Amount__c),
				editable: getEditSettings('text', FieldsSettings.EUR_ISP_Per_Unit_Amount__c, saveNumber, validateNumberRequired),
				formatter: hlpr.getFormatedCurrency
			});
		}
		/** START FIELDS CONFIGURATED BY SPEND TYPE */

		/** START DEFAULT FIELDS */
		TableSettings.columns.push({
			field: "EUR_ISP_Matched__c",
			title: FieldsSettings.EUR_ISP_Matched__c.label,
			label: FieldsSettings.EUR_ISP_Matched__c.label,
			editable: false,
			formatter: hlpr.getFormatedCurrency
		});
		TableSettings.columns.push({
			field: "EUR_ISP_Available_Amount__c",
			title: FieldsSettings.EUR_ISP_Available_Amount__c.label,
			label: FieldsSettings.EUR_ISP_Available_Amount__c.label,
			editable: false,
			formatter: hlpr.getFormatedCurrency
		});
		TableSettings.columns.push({
			field: "EUR_ISP_Total_Spend_Item__c",
			title: FieldsSettings.EUR_ISP_Total_Spend_Item__c.label,
			label: FieldsSettings.EUR_ISP_Total_Spend_Item__c.label,
			editable: false,
			formatter: function(value, obj) {
				return '<span data-name="EUR_ISP_Total_Spend_Item__c">' + hlpr.getFormatedCurrency(value, obj) + '</span>';
			}
		});
		TableSettings.columns.push({
			field: "close",
			title: $A.get('$Label.c.EUR_ISP_CLOSE_TEXT'),
			label: $A.get('$Label.c.EUR_ISP_CLOSE_TEXT'),
			formatter: function(value, row, index) {
				//console.log(isEditLock, !isItemAvailableForClose(row), !ObjectSettings.isUpdateable);
				if (isEditLock || !isItemAvailableForClose(row) || !ObjectSettings.isUpdateable) {
					return '<input class="slds-button slds-button--destructive slds-button--small" type="button" value="'+$A.get('$Label.c.EUR_ISP_CLOSE_TEXT')+'" disabled="true">';
				}
				return '<input class="slds-button slds-button--destructive slds-button--small" type="button" value="'+$A.get('$Label.c.EUR_ISP_CLOSE_TEXT')+'">';
			}
		});
		return TableSettings;
	},
	setTableData: function(cmp, tableData, $contentTable) {
		var hlpr = this;
		$contentTable
			.bootstrapTable(this.generateTableConfig(cmp, tableData.length))
			.bootstrapTable('load', tableData)
			.removeClass('slds-hide')
			.closest('div.slds-scrollable--x')
			.find('table.table-content--no')
			.addClass('slds-hide');

		var fields = [
			'EUR_ISP_Lump_Sum_1__c',
			'EUR_ISP_Lump_Sum_2__c',
			'EUR_ISP_Per_Unit_Amount__c',
			'EUR_ISP_Percentage__c',
			'EUR_ISP_Volume__c',
			'EUR_ISP_Unit_Of_Measure__c'
		];

		$contentTable
			.off('editable-save.bs.table').on('editable-save.bs.table', function(e, field, row, oldValue, $that) {
				//var value;
				switch (field) {
					case 'EUR_ISP_Lump_Sum_1__c':
					case 'EUR_ISP_Lump_Sum_2__c':
					case 'EUR_ISP_Per_Unit_Amount__c':
						row[field] = row[field] ? parseFloat(row[field].replace(',','.'), 10) : null;
						//value = hlpr.getFormatedCurrency(row[field], row);
						setTotalValue(row, $that, hlpr);
					break;
					case 'EUR_ISP_Percentage__c':
						row[field] = row[field] ? parseFloat(row[field].replace(',','.'), 10) : null;
						//value = hlpr.getFormatedPercentage(row[field], row);
					break;
					case 'EUR_ISP_Volume__c':
						row[field] = row[field] ? parseFloat(row[field].replace(',','.'), 10) : null;
						//value = hlpr.getFormatedNumber(row[field], row);
						setTotalValue(row, $that, hlpr);
					break;
					case 'EUR_ISP_Unit_Of_Measure__c':
						//value = row[field];
					break;
				};

				// just update the View for Total item value
				// formula field logic copy
				function setTotalValue(item, $that, hlpr) {
					var $container = $that.closest('tr').find('span[data-name="EUR_ISP_Total_Spend_Item__c"]'),
						qty = (item.EUR_ISP_Volume__c && item.EUR_ISP_Volume__c !== 0 ? item.EUR_ISP_Volume__c : 0),
						pricePerUnit = (item.EUR_ISP_Per_Unit_Amount__c && item.EUR_ISP_Per_Unit_Amount__c !== 0 ? item.EUR_ISP_Per_Unit_Amount__c : 0),
						lumpSum1 = (item.EUR_ISP_Lump_Sum_1__c && item.EUR_ISP_Lump_Sum_1__c !== 0 ? item.EUR_ISP_Lump_Sum_1__c : 0),
						lumpSum2 = (item.EUR_ISP_Lump_Sum_2__c && item.EUR_ISP_Lump_Sum_2__c !== 0 ? item.EUR_ISP_Lump_Sum_2__c : 0);

					item.EUR_ISP_Total_Spend_Item__c = parseFloat(qty, 10) * parseFloat(pricePerUnit, 10) + parseFloat(lumpSum1, 10) + parseFloat(lumpSum2, 10);
					var value = hlpr.getFormatedCurrency(item.EUR_ISP_Total_Spend_Item__c, item);

					if ($container.length) {
						setTimeout(function() {
							$container.text(value);
						}, 100);
					}
				};

				// if (value) {
				// 	setTimeout(function() {
				// 		$that.text(value);
				// 	}, 100);
				// }
				return false;
			})
			.off('editable-init.bs.table').on('editable-init.bs.table', function() {
				var $table = $(this);
				 $table.find('td a').each(function() {
					var name = this.dataset.name;
					if (name && fields.indexOf(name) > -1) {
						$(this).editable('show', false);
					}
				});
				$table.off('keyup').on('keyup', 'input[type="text"], select', function(e) {
					var $input = $(this);
					$input.closest('td').find('a').data('editableContainer').tip().find('form').submit()
				});
			})
			.off('editable-hidden.bs.table').on('editable-hidden.bs.table', function(field, row, $that, reason) {
				$(this).find('td a').each(function() {
					var name = this.dataset.name;
					if (name && fields.indexOf(name) > -1) {
						var $href = $(this);
						if (!$href.hasClass('editable-open')) {
							$href.editable('show', false);
						}
					}
				});
			});
	}
})