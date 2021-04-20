({
	CUSTOM_LABELS: {},
	initTable: function(cmp, pageNumber) {
		var that = this;
		pageNumber = pageNumber || 1;

		this.showLoading(cmp);
		this.changePage(cmp, pageNumber, function(settings) {
			that.doParseResults(cmp, settings);

			var settings = cmp.get('v.tableSetting');
			cmp.set('v.totalSpends', settings.totalRows);
			that.initPagination(cmp, cmp.get('v.tableId'), settings);
			that.hideLoading(cmp);
		});
	},
	initCustomLabels: function() {
		this.CUSTOM_LABELS = {
			APPROVE: $A.get('$Label.c.EUR_ISP_APPROVE_TEXT'), //'Approve'
			REJECT: $A.get('$Label.c.EUR_ISP_REJECT_TEXT'), //'Reject'
			APPROVE_LABEL: $A.get('$Label.c.EUR_ISP_APPROVE_HEADER_TEXT'),//'Approve Approval Request'
			REJECT_LABEL: $A.get('$Label.c.EUR_ISP_REJECT_HEADER_TEXT'),//'Reject Approval Request'
		};
	},
	getTableData: function(cmp, pageNumber, callback) {
		if (!cmp.isValid()) {
			return;
		}

		var getTableDataAction = cmp.get("c.getItemsToApprove");
		getTableDataAction.setParams({
			pageNumber: pageNumber
		});
		getTableDataAction.setCallback(this, function(response) {
			if (!cmp.isValid()) {
				return;
			}

			if (response.getState() === "SUCCESS") {
				var retValue = response.getReturnValue();
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
		});
	},
	fireModalEvent: function(cmp, params, isApproveStep) {
		var LABELS = this.CUSTOM_LABELS;

		$A.get('e.c:EUR_ISP_ModalWindowShowEvent').setParams({
			title: isApproveStep ? LABELS.APPROVE_LABEL : LABELS.REJECT_LABEL,
			actionButtonLabel: isApproveStep ? LABELS.APPROVE : LABELS.REJECT,
			saveEventName: 'EUR_ISP_SpendApproveEvent',
			cmpName: 'EUR_ISP_SpendApproveForm',
			width: '50%',
			settings: {
				spendId   : params.spendId,
				workItemId: params.itemId,
				status    : isApproveStep ? LABELS.APPROVE : LABELS.REJECT
			}
		}).fire();
	}
})