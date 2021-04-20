({
	CUSTOM_LABELS: {},
	initTable: function(cmp) {
		var that = this;
		this.showLoading(cmp);

		this.getTableData(cmp, 1, function(err, settings) {
			if (!cmp.isValid()) {
				return;
			}
			if (err) {
				console.log(err);
				return;
			}

			that.doParseResults(cmp, settings);

			var settings = cmp.get('v.tableSetting');
			cmp.set('v.totalActivities', settings.totalRows);
			that.initPagination(cmp, cmp.get('v.tableId'), settings);
			that.hideLoading(cmp);
		});
	},
	initCustomLabels: function() {
		this.CUSTOM_LABELS = {
			CONFIRM_MSG: $A.get('$Label.c.EUR_ISP_CLOSE_ACTIVITY_TEXT'), //'This is being closed, {0} will be released to budget, click OK to continue'
		};
	},
	getTableData: function(cmp, pageNumber, callback) {
		if (!cmp.isValid()) {
			return;
		}

		var getTableDataAction = cmp.get("c.getActivitiesToAdjust");
		getTableDataAction.setParams({
			pageNumber: pageNumber
		});
		getTableDataAction.setCallback(this, function(response) {
			if (!cmp.isValid()) {
				return;
			}

			if (response.getState() === "SUCCESS") {
				var retValue = response.getReturnValue();
				if (retValue) {
					(retValue.sdata || []).forEach(function(item) {
						if (item.EUR_ISP_Activity_Start_Date__c) {
							item.StartDate = item.EUR_ISP_Activity_Start_Date__c
						} else {
							item.StartDate = item.EUR_ISP_Sales_In_Start_Date__c;
						}
						if (item.EUR_ISP_Activity_End_Date__c) {
							item.EndDate = item.EUR_ISP_Activity_End_Date__c
						} else {
							item.EndDate = item.EUR_ISP_Sales_In_End_Date__c;
						}
					});
				}
				return callback(null, retValue);
			}
			
			callback(response.getError(), null);
		});
		$A.enqueueAction(getTableDataAction);
	},
	changePage: function(cmp, pageNumber, callback) {
		if (!cmp.isValid()) {
			return;
		}

		this.getTableData(cmp, pageNumber, function(err, settings) {
			if (!cmp.isValid()) {
				return;
			}
			if (err) {
				console.log(err);
				return;
			}
			callback(settings);
			var settings = cmp.get('v.tableSetting');
			cmp.set('v.totalActivities', settings.totalRows);
		});
	},
	createBudgetTransaction: function(cmp, activityId) {
		if (!cmp.isValid()) {
			return;
		}

		this.showLoading(cmp);
		var that = this;
		var settings = cmp.get('v.tableSetting');
		var action = cmp.get('c.createBudgetTransactionRecord');
			action.setParams({
				activityId: activityId
			});
			action.setCallback(this, function(response) {
				if (!cmp.isValid()) {
					return;
				}
				if (response.getState() !== 'SUCCESS') {
					return;
				}

				that.getTableData(cmp, settings.pageNumber, function(err, settings) {
					if (!cmp.isValid()) {
						return;
					}
					if (err) {
						console.log(err);
						return;
					}

					that.doParseResults(cmp, settings);

					var settings = cmp.get('v.tableSetting');
					cmp.set('v.totalActivities', settings.totalRows);
					that.initPagination(cmp, cmp.get('v.tableId'), settings);
					that.hideLoading(cmp);
					$A.get('e.c:EUR_ISP_SpendViewRefreshEvent').fire();
				});
			});
		$A.enqueueAction(action);
	}
})