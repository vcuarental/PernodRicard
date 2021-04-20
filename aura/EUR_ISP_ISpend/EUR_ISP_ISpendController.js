({
	getSpendItem: function(cmp, e, hlpr) {
		if (!cmp.isValid()) {
			return;
		}
		if (!e.getParams || !e.getParams().arguments) {
			return;
		}

		var invoicedPicklistStatusValue = 'Invoiced';
		;(cmp.get('v.UserPermissions').EUR_ISP_Spend__c.fields.EUR_ISP_Status__c.picklistValues || []).forEach(function(val) {
			if (val.value === 'Invoiced') {
				invoicedPicklistStatusValue = val;
			}
		});

		var params = e.getParams().arguments.config;
		var that = this;
		var checkSpendForLock = cmp.get("c.isRecordLocked");
		checkSpendForLock.setParams({
			spendId: params.spendId
		});
		checkSpendForLock.setCallback(this, function(response) {
			if (!cmp.isValid() || response.getState() !== "SUCCESS") {
				return;
			}

			cmp.set('v.isLocked', response.getReturnValue());

			var action = cmp.get("c.getISpend");
			action.setParams({
				spendId: params.spendId
			});
			action.setCallback(that, function(response) {
				if (!cmp.isValid() || response.getState() !== "SUCCESS") {
					return;
				}

				var Spend = response.getReturnValue();
				// Status eq Invoiced
				if (invoicedPicklistStatusValue.value === Spend.EUR_ISP_Status__c || invoicedPicklistStatusValue.label === Spend.EUR_ISP_Status__c) {
					cmp.set('v.isLocked', true);
				}
				cmp.set('v.Spend', Spend);

				$A.get("e.c:EUR_ISP_RenderNavigationEvent").setParams({
					prevPageAPI: 'SPEND',
					curPageTitle: Spend.Name
				}).fire();

				cmp.find('treeView').refreshView(params);
				cmp.find('history').refreshView(params);
			});
			$A.enqueueAction(action);
		});
		$A.enqueueAction(checkSpendForLock);
	}
})