({
    init: function(cmp, event, helper, visitID)
	{
		$A.util.removeClass(cmp.find('spinner'), 'slds-hide');
		var action = cmp.get('c.getRSP');
		action.setParams({
			visitID: visitID
		});
		action.setCallback(this, function(r)
		{
			var state = r.getState();
			if (cmp.isValid() && state === 'SUCCESS')
			{
                var resultData = r.getReturnValue();
				cmp.set('v.vpd', resultData.vpd);
				cmp.set('v.disabled', resultData.previousVisit);
				cmp.set('v.rspHeader', resultData.rspHeader);
				cmp.set('v.rspDetails', resultData.rspDetails);
				// cmp.set('v.skuList', resultData.skuList);
				$A.util.addClass(cmp.find('spinner'), 'slds-hide');
            }
		});
		$A.enqueueAction(action);
	},

	searchSKU : function(cmp, event, helper, searchStr, index)
	{
		var action = cmp.get('c.getSKUList');
		action.setParams({
			name: searchStr
		});
		action.setCallback(this, function(r)
		{
			var state = r.getState();
			if (cmp.isValid() && state === 'SUCCESS')
			{
				var resultData = r.getReturnValue();
				var rspDetails = cmp.get('v.rspDetails');
				
				rspDetails[index].skuList = resultData;
				cmp.set('v.rspDetails', rspDetails);
            }
		});
		$A.enqueueAction(action);
	},

	submitRSP : function(cmp, event, helper)
	{
		$A.util.removeClass(cmp.find('spinner'), 'slds-hide');
		var visitID = cmp.get('v.recordId');
		var rspHeader = cmp.get('v.rspHeader');
		var rspDetails = cmp.get('v.rspDetails');
		var deleteRspDetails = cmp.get('v.deleteRspDetails');
		var action = cmp.get('c.saveRSP');

		rspDetails.forEach(function(detail) {
			delete detail.ASI_CRM_SKU__r;
			delete detail.skuList;
		});

		deleteRspDetails.forEach(function(detail) {
			delete detail.ASI_CRM_SKU__r;
			delete detail.skuList;
		});

		action.setParams({
			rspHeaderStr: JSON.stringify(rspHeader),
			rspDetailsStr: JSON.stringify(rspDetails),
			deleteRspDetailsStr: JSON.stringify(deleteRspDetails)
		});
		action.setCallback(this, function(r)
		{
			var state = r.getState();

			if (cmp.isValid() && state === 'SUCCESS')
			{
				swal.fire({
					title: 'Submit RSP',
					text: r.getReturnValue(),
					confirmButtonColor: '#3085d6',
					cancelButtonColor: '#d33',
					confirmButtonText: 'OK'
				}).then((result) => {
					if (result.value)
					{
						$A.get('e.force:refreshView').fire();
					}
				});
			}
			else
			{
				cmp.set('v.isSubmitted', false);

				var errors = r.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
						swal.fire({
							title: 'Save QVAP',
							text: errors[0].message,
							confirmButtonColor: '#3085d6',
							cancelButtonColor: '#d33',
							confirmButtonText: 'OK'
						}).then((result) => {
							if (result.value)
							{
								$A.util.addClass(cmp.find('spinner'), 'slds-hide');
							}
						});
                    }
                }
			}
		});
		
		$A.getCallback(function()
		{
			$A.enqueueAction(action);
		})();
	}
})