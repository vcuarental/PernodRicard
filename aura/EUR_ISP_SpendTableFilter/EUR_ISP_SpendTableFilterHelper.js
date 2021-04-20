({
	doSearchInit: function(cmp) {
		var currentDate = new Date();
		var currentMonth = currentDate.getMonth() + 1;
		var startDate = new Date(currentDate.getFullYear() - 1, 6, 1, 0, 0, 0, 0);
		var endDate = new Date(currentDate.getFullYear(), 5, 30, 0, 0, 0, 0);
		if (currentMonth >= 7) {
			startDate = new Date(currentDate.getFullYear(), 6, 1, 0, 0, 0, 0);
			endDate = new Date(currentDate.getFullYear() + 1, 5, 30, 0, 0, 0, 0);
		}

		cmp.set('v.startDate', startDate);
		cmp.set('v.endDate', endDate);

		var UserPermissions = cmp.get('v.UserPermissions');
		if (UserPermissions && UserPermissions.EUR_ISP_Spend__c) {
			var picklistValues = {
				RecordType: UserPermissions.EUR_ISP_Spend__c.theObject.recordTypes || []
			};

			var fields = ['EUR_ISP_Approval_Status__c'];
			fields.forEach(function(fieldName) {
				picklistValues[fieldName] = UserPermissions.EUR_ISP_Spend__c.fields[fieldName].picklistValues || [];
			});

			cmp.set('v.picklistValues', picklistValues);
		}
	},
	doSettlementSearchInit: function(cmp, params) {
		if (params.Vendor) {
			cmp.set('v.Vendor', params.Vendor);
			cmp.set('v.vendorId', params.Vendor.Id);
		}
		if (params.Account) {
			cmp.set('v.Account', params.Account);
			cmp.set('v.accountId', params.Account.Id);
		}
	},
	getSearchParams: function(cmp) {
		var startDt = null;
		var endDt = null;

		if (cmp.get('v.startDate')) {
			startDt = $A.localizationService.formatDate(cmp.get('v.startDate'), 'yyyy-MM-dd HH:mm:ss');
		}
		if (cmp.get('v.endDate')) {
			endDt = $A.localizationService.formatDate(cmp.get('v.endDate'), 'yyyy-MM-dd HH:mm:ss');
		}

		return {
			pageNumber: 1,
			startDate: startDt,
			endDate: endDt,
			spendName: cmp.get('v.spendName') || null,
			contractName: cmp.get('v.contractName') || null,
			vendorId: cmp.get('v.vendorId') || null,
			accountId: cmp.get('v.accountId') || null,
			recordTypeId:  cmp.get('v.recordTypeId') || null,
			approvalStatus: cmp.get('v.approvalStatus') || null
		};
	},
	fireRenderCreateForm: function(cmp) {
		$A.get('e.c:EUR_ISP_ModalWindowShowEvent').setParams({
			title: 'Select Record Type',
			actionButtonLabel: 'Select',
			saveEventName: 'EUR_ISP_RecordTypeSelectEvent',
			cmpName: 'EUR_ISP_RecordTypeSelectionForm',
			settings: {
				sObjectApiName: 'EUR_ISP_Spend__c'
			}
		}).fire();
	}
})