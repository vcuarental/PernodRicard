({
	initForm: function(cmp, e) {
		if (!cmp.isValid()) {
			return;
		}

		var params = e.getParams ? e.getParams() : e.target.dataset;
		var Spend = {
			sobjectType: 'EUR_ISP_Spend__c',
			CurrencyIsoCode: 'EUR',
			//EUR_ISP_Status__c: 'New',
			EUR_ISP_Allocation_Method__c: "Standard",
			EUR_ISP_Phasing_Method__c: "Pro Rata",
			EUR_ISP_Settlement_Method__c: "Vendor Invoice",
			EUR_ISP_Approval_Status__c: "Pending",
			EUR_ISP_Matched__c: 0,
			EUR_ISP_Total_Spend_Activities_Amount__c: 0
		};

		if (params.RecordType) {
			Spend.RecordType = params.RecordType;
			Spend.RecordTypeId = params.RecordType.Id;
		}
		cmp.set('v.isVisible', true);
		cmp.set('v.Spend', Spend);

		$A.get("e.c:EUR_ISP_RenderNavigationEvent").setParams({
			prevPageAPI: 'SPEND',
			curPageTitle: 'New Spend'
		}).fire();

		$A.get('e.c:EUR_ISP_NavigateToPrevPageEvent').setParams({
			prevPageAPI: 'EUR_ISP_SpendForm'
		}).fire();
	},
	renderIfCurrentPage: function(cmp, e) {
		if (!cmp.isValid()) {
			return;
		}
		cmp.set('v.isVisible', e.getParams() && 'EUR_ISP_SpendForm' === e.getParams().prevPageAPI);
	}
})