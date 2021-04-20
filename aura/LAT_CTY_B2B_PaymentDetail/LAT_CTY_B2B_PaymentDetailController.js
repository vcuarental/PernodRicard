({
	doInit : function(component, event, helper) {
        helper.loadPaymentId(component);
        helper.loadColumns(component);
        helper.getPaymentsList(component, event, helper);
        helper.getPayment(component);
	},
    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'viewPayment':
                console.log('row: '+JSON.stringify(row));
                component.set("v.paymentId", row.Id);
                helper.getPayment(component);
                break;
            
        }
	}
})