({
	PICKLIST_FIELDS: [
		'EUR_ISP_Status__c',
		'EUR_ISP_Payment_Terms__c',
		'EUR_ISP_Approval_Status__c',
		'EUR_ISP_Settlement_Method__c'
	],
	PICKLIST_FIELD_VALUES: { /* will be defined on INIT action */ },
	CUSTOM_MESSAGES: { /* will be defined on INIT action */ },
	EUR_ISP_ACTIVITY_TYPES_MAPPING : {
		'Family'             : 'EUR_ISP_Family__',
		'Brand'              : 'EUR_ISP_Brand__',
		'Brand Quality'      : 'EUR_ISP_Brand_Quality__',
		'Brand Quality Size' : 'EUR_ISP_Brand_Quality_Size__',
		'SKU'                : 'EUR_ISP_SKU_EU__'
	},
	ENUMS: {
		APPROVAL_STATUS: 'Approved',
		STATUS: 'Committed'
	},
	doInit: function() {
		this.CUSTOM_MESSAGES = {
			ERRORS: {
				ACTIVITY_AMOUNT: $A.get('$Label.c.EUR_ISP_ACTIVITY_AMOUNT')
			},
			WARNINGS: {
				RELEASE_BUDGET: $A.get('$Label.c.EUR_ISP_MATCH_AMOUNT_TEXT'),  //'This is being closed {0}, will be released to budget, click OK to continue'
			}
		};
	},
	setupPicklistValues: function(cmp) {
		var hlpr = this;
		var UserPermissions = cmp.get('v.UserPermissions');
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
	getSpend: function(cmp, spendId, callback) {
		if (!cmp.isValid() || !spendId) {
			return callback({});
		}

		var getSpendAction = cmp.get('c.getSpend');
			getSpendAction.setParams({
				spendId: spendId
			});
			getSpendAction.setCallback(this, function(response) {
				if (!cmp.isValid()) {
					return;
				}
				var Spend = {};
				if (response.getState() === 'SUCCESS') {
					Spend = response.getReturnValue();
				}
				callback(Spend);
			});
		$A.enqueueAction(getSpendAction);
	},
	getSpendActivities: function(cmp, spendId, callback) {
		if (!cmp.isValid() || !spendId) {
			return callback([]);
		}
		var getSpendActivitiesAction = cmp.get('c.getSpendActivities');
			getSpendActivitiesAction.setParams({
				spendId: spendId
			});
			getSpendActivitiesAction.setCallback(this, function(response) {
				if (!cmp.isValid()) {
					return;
				}
				var activities = [];
				if (response.getState() === 'SUCCESS') {
					activities = response.getReturnValue();
				}
				callback(activities);
			});
		$A.enqueueAction(getSpendActivitiesAction);
	},
	getTableData: function(activities, isDEProject) {
		var outputData = [];
		var hlpr = this;
		if (!activities) {
			return outputData;
		}

		activities.forEach(function(activity) {
			if (activity.EUR_ISP_Spend_Activity_Type__r) {
				var lookupApiName = hlpr.EUR_ISP_ACTIVITY_TYPES_MAPPING[activity.EUR_ISP_Spend_Activity_Type__r.EUR_ISP_Product_Level_Of_Input__c];
				if (lookupApiName) {
					var approvalStatusValue = hlpr.PICKLIST_FIELD_VALUES.EUR_ISP_Approval_Status__c[activity.EUR_ISP_Approval_Status__c];
					var statusValue = hlpr.PICKLIST_FIELD_VALUES.EUR_ISP_Status__c[activity.EUR_ISP_Status__c];
					var isValidStatuses = approvalStatusValue === hlpr.ENUMS.APPROVAL_STATUS && statusValue === hlpr.ENUMS.STATUS;

					// generate activityData for table
					var activityData = {
						sobjectType    : 'EUR_ISP_Spend_Activity__c',
						Id             : activity.Id,
						Name           : activity.Name,
						ActivityType   : activity.EUR_ISP_Spend_Activity_Type_Name__c,
						_ActivityType  : activity.EUR_ISP_Spend_Activity_Type__r ? activity.EUR_ISP_Spend_Activity_Type__r: null,
						StartDate      : activity.EUR_ISP_Activity_Start_Date__c,
						EndDate        : activity.EUR_ISP_Activity_End_Date__c,
						CurrencyIsoCode: activity.CurrencyIsoCode,
						Total          : activity.EUR_ISP_Activity_Amount__c ? activity.EUR_ISP_Activity_Amount__c: 0,
						//Total          : activity.EUR_ISP_Total_Activity_Amount__c ? activity.EUR_ISP_Total_Activity_Amount__c: 0,
						Matched        : activity.EUR_ISP_Matched__c ? activity.EUR_ISP_Matched__c : 0,
						Available      : 0,
						isValid        : true,
						Brands         : ''
					};
					activityData.Available = activityData.Total - activityData.Matched;
					activityData.isValid = activityData.Available > 0 && isValidStatuses;

					// push activityData
					outputData.push(activityData);

					var brands = {};
					;(activity.Spend_Items_EU__r || []).forEach(function(spendItem) {
						var BrandObject = spendItem[lookupApiName + 'r'];
						if (BrandObject) {
							// push Brands
							brands[BrandObject.Name] = 1;
							var ActivityType = activity.EUR_ISP_Spend_Activity_Type__r ? activity.EUR_ISP_Spend_Activity_Type__r: {};

							if ((isDEProject && ActivityType.EUR_ISP_Spend_Activity_Type_Name_English__c === 'Pouring Refund') || !isDEProject) {
								// generate itemData for table 
								var itemData = {
									sobjectType    : 'EUR_ISP_Spend_Item__c',
									Id             : spendItem.Id,
									Name           : spendItem.Name,
									activityId     : activity.Id,
									ActivityType   : activity.EUR_ISP_Spend_Activity_Type_Name__c,
									StartDate      : activity.EUR_ISP_Activity_Start_Date__c,
									EndDate        : activity.EUR_ISP_Activity_End_Date__c,
									CurrencyIsoCode: activity.CurrencyIsoCode,
									Total          : spendItem.EUR_ISP_Total_Spend_Item__c ? spendItem.EUR_ISP_Total_Spend_Item__c: 0,
									Matched        : spendItem.EUR_ISP_Matched__c ? spendItem.EUR_ISP_Matched__c : 0,
									Available      : 0,
									isValid        : true,
									Brands         : BrandObject.Name
								};
								itemData.Available = itemData.Total - itemData.Matched;
								itemData.isValid = itemData.Available > 0 && isValidStatuses;

								// push itemData
								outputData.push(itemData);
							}
						}
					});

					// sort Brand names and populate activity field
					for (var brand in brands) {
						if (brands.hasOwnProperty(brand)) {
							activityData.Brands += brand + '<br/>';
						}
					}
				}
			}
		});
		return outputData;
	},
	getSelectedActivity: function(cmp, activityId) {
		var data = cmp.get('v.tableData') || [];
		var selectedItem;

		data.forEach(function(item) {
			if (item.Id === activityId) {
				selectedItem = item;
			}
		});
		return selectedItem;
	},
	isSelectedAmountValid: function(cmp, Activity) {
		if (Activity.Available <= 0 || Activity.Available < Activity.value) {
			return false;
		}

		var Settlement = cmp.get('v.Settlement');
		if (Settlement.RemainingAmount <= 0 || Settlement.RemainingAmount < Activity.value) {
			return false
		}
		return true;
	},
	fireRenderSpend: function(cmp, spendId, Activity) {
		if (!Activity._ActivityType) {
			return;
		}
		cmp.getEvent('ShowSpendEvent').setParams({
			spendId        : spendId,
			spendActivityId: Activity.Id,
			spendTypeId    : Activity._ActivityType.Id
		}).fire();
	},
	fireRenderBrandTable: function(spendId, Activity) {
		if (!Activity._ActivityType) {
			return;
		}
		$A.get("e.c:EUR_ISP_BrandCmpTableShowEvent").setParams({
			spendId   : spendId,
			objectName: Activity._ActivityType.EUR_ISP_Product_Level_Of_Input__c
		}).fire();
	},
	fireCreateBudgetTransactionEvent: function (cmp, activity) {
		var params = {
			activityId: activity.Id
		};

		if (activity.sobjectType && activity.sobjectType === 'EUR_ISP_Spend_Item__c') {
			params.itemId = activity.Id;
			params.activityId = activity.activityId;
		}

		$A.get('e.c:EUR_ISP_BudgetTransactionCreateEvent').setParams(params).fire();
	},
	fireSettlementLineItemCreateEvent: function (cmp, activity) {
		var params = {
			amount     : activity.value,
			activityId : activity.Id
		};

		if (activity.sobjectType && activity.sobjectType === 'EUR_ISP_Spend_Item__c') {
			params.itemId = activity.Id;
			params.activityId = activity.activityId;
		}

		$A.get('e.c:EUR_ISP_SettlementLineItemCreateEvent').setParams(params).fire();
	},
	getFormatedCurrency: function(value, obj) {
		var currString = value ? $A.localizationService.formatCurrency(value) : '0.00';
		currString = currString.replace(/[^\d+\,\.]/g, '');
		return obj.CurrencyIsoCode + ' ' + currString;
	}
})