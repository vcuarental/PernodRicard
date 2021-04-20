({
	getSystemConfig: function(cmp, callback) {
		var getSystemSettings = cmp.get('c.getAppConfiguration');
		getSystemSettings.setCallback(this, function(response) {
			if (!cmp.isValid() || response.getState() !== "SUCCESS") {
				return callback();
			}
			callback(response.getReturnValue());
		});
		$A.enqueueAction(getSystemSettings);
	},
	showSpend: function(cmp) {
		$A.get("e.c:EUR_ISP_RenderNavigationEvent").fire();
		// $A.get("e.c:EUR_ISP_RenderNavigationEvent").setParams({
		// 	curPageTitle: 'Spend Table'
		// }).fire();
		cmp.set('v.viewName', 'SPEND');
	},
	showSettlement: function(cmp) {
		$A.get("e.c:EUR_ISP_RenderNavigationEvent").setParams({
			curPageTitle: $A.get('$Label.c.EUR_ISP_MATCH_SCREEN')
		}).fire();
		cmp.set('v.viewName', 'MATCH');
	},
	showHome: function(cmp, params) {
		$A.get("e.c:EUR_ISP_RenderNavigationEvent").fire();
		cmp.set('v.viewName', 'HOME');
	},
	showCreate: function(cmp) {
		cmp.set('v.viewName', 'SPENDCREATE');
		this.fireRenderCreateForm(cmp);
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