({
    searchCustomer : function(cmp, event, helper, searchStr)
	{
		var action = cmp.get('c.getCustomerList');
		action.setParams({
			name: searchStr
		});
		action.setCallback(this, function(r)
		{
			var state = r.getState();
			if (cmp.isValid() && state === 'SUCCESS')
			{
				var resultData = r.getReturnValue();
				cmp.set('v.customerList', resultData);
            }
		});
		$A.enqueueAction(action);
	},

	submitAdhoc : function(cmp, event, helper)
	{
		var customerID = cmp.get('v.customerID');
		var action = cmp.get('c.saveAdhoc');
console.log(customerID);
		action.setParams({
			customerID: customerID
		});
		action.setCallback(this, function(r)
		{
			var state = r.getState();

			if (cmp.isValid() && state === 'SUCCESS')
			{
				cmp.set('v.cbObject', {
					alert: {
						title: 'Adhoc Visitation',
						text: r.getReturnValue()
					},
					refresh: true
				});
				cmp.find('overlayLib').notifyClose();
			}
			else
			{
				cmp.set('v.isSubmitted', false);

				var errors = r.getError();
				if (errors)
				{
					if (errors[0] && errors[0].message)
					{
						cmp.set('v.cbObject', {
							alert: {
								title: 'Adhoc Visitation',
								text: errors[0].message
							}
						});
					}
				}
				cmp.find('overlayLib').notifyClose();
			}
		});
		
		$A.enqueueAction(action);
	}
})