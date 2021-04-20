({
	initCart: function (component, event) {
        var action = component.get("c.getOrder");
        action.setParams({ "orderId": component.get("v.orderId") });
        let _this = this;
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isLoading", false);
                var order = response.getReturnValue();
                console.info(order);
                component.set("v.order", order);
                if(order.LAT_Account__r){
                    component.set("v.accName", order.LAT_Account__r.Name);
                    component.set("v.accCNPJ", order.LAT_Account__r.CNPJ__c);
                    component.set("v.accAddress", order.LAT_Account__r.AddressLine1_AR__c);
                    component.set("v.accCorporateName", order.LAT_Account__r.Corporate_Name__c);
                }
                if (order.OpportunityLineItems__r) {
                    component.set("v.orderProducts", order.OpportunityLineItems__r);
                }
                if (order.LAT_NextStep__c) {
                    component.set('v.downloadInvoice', true);
                }
                console.log('order', order);
                _this.calculatePrice(component);
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
	},
    
	calculatePrice: function (component) {
        let currentItems = component.get('v.orderProducts');
        let price = 0;
        currentItems.forEach(function (prod) {
            price += (prod.LAT_QTTotal__c * prod.LAT_UnitPrice__c);
        });
        console.log('price', price);
        component.set("v.price", price);
    },
    
    loadOrderId: function (component) {
        var url = decodeURIComponent(window.location.search.substring(1));
        var urlParams = url.split('&');
        var reorderParam;
        for (var i = 0; i < urlParams.length; i++) {
            reorderParam = urlParams[i].split('=');
            if (reorderParam[0] === 'order') {
                reorderParam[1] === undefined ? 0 : reorderParam[1];
                if (reorderParam[1] != 0) {
                    component.set("v.orderId", reorderParam[1]);
                }
            }
        }
    },
    
    reorder: function (component, row) {
        component.set('v.isLoading', true);
        var action = component.get("c.reOrderOppty");
        action.setParams({ "opptyId" : component.get("v.orderId") });
        action.setCallback(this, function (response) {
            console.info('callback');
            var state = response.getState();
            if (state === "SUCCESS") {
                console.info(response.getReturnValue());
                window.location.href = '/s/nuevo-pedido?opencart=1';
            }
        });
        $A.enqueueAction(action);
    }
    
})