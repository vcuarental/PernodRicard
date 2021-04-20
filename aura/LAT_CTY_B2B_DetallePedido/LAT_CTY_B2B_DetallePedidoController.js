({
	initCart : function(component, event, helper) {
		component.set('v.isLoading', true);
        helper.loadOrderId(component);
		helper.initCart(component, event);
	},
    
    reorderOpportunity: function(component, event, helper) {
		helper.reorder(component);
	},
    
    downloadFactura: function(component, event, helper) {
		var order = component.get('v.order');
        var address = order.LAT_NextStep__c;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": address,
            "isredirect" :true
        });
        urlEvent.fire();
	}

})