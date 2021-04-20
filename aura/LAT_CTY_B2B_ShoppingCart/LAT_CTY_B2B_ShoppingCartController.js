({
	openCart : function(component, event, helper) {
		component.set('v.cartIsOpen', true);
	},
	closeCart : function(component, event, helper) {
        component.set('v.showQuantInputs',false);
		component.set('v.cartIsOpen', false);
	},
	sendToJDE : function(component, event, helper) {
		helper.sendToJDE(component, event);
	},
	removeItem : function(component, event, helper) {
        component.set('v.showQuantInputs',false);
		var selectedItem = event.currentTarget;
        var elementId = selectedItem.dataset.item;
        var nombreprod = selectedItem.dataset.nombreprod;
        console.log('dataset seleccionado:'+JSON.stringify(selectedItem.dataset)) ;        
        console.log('dataset nombreProd:'+nombreprod) ;
        component.set('v.currentItemId', elementId);	
        component.set('v.overlayProdName', nombreprod);	
        component.set('v.openOverlay',true);
	},
	initCart : function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.baseUrl' , window.location.pathname.substring(0,window.location.pathname.indexOf('/s/') + 3));        

        helper.getOrderTakingEnabled(component, event);
        helper.getblockedMessage(component, event);
        helper.getMinimunOrderPrice(component, event);
		helper.initCart(component, event);
		helper.shouldOpenCart(component);
        helper.getAvailableCredit(component);
	},
	addProduct: function(component, event, helper) {
        component.set('v.showQuantInputs',false);
		component.set('v.isLoading', true);
		helper.addProduct(component, event);
	},
	sumQTY: function(component, event, helper) {
        //component.set('v.showQuantInputs',false);
		component.set('v.isLoading', true);
		var selectedItem = event.currentTarget;
		var pId = selectedItem.dataset.pid;
		var itemId = selectedItem.dataset.item;
		var unit = selectedItem.dataset.unit;
		var toAdd = 1;
		var qty = selectedItem.dataset.value;
        if(qty > 9998){
            toAdd = 0;
        }
	
		helper.sumQty(component, pId, unit, toAdd, itemId);
	},
	subtractQty: function(component, event, helper) {
		//component.set('v.showQuantInputs',false);
		var selectedItem = event.currentTarget;
		var pId = selectedItem.dataset.pid;
		var unit = selectedItem.dataset.unit;
		var isfirst = selectedItem.dataset.isfirst;
		var itemId = selectedItem.dataset.item;

		if(isfirst == 'false') {
			component.set('v.isLoading', true);
			helper.sumQty(component, pId, unit, -1, itemId);
		}
		
	},
    cancelOverlay: function(component) {
		component.set('v.openOverlay', false);
        component.set('v.currentItemId', '');	
        component.set('v.overlayProdName', '');
    },
    confirmOverlay: function(component, event, helper) {
        component.set('v.isLoading', true);
        var elementId = component.get('v.currentItemId');
		
        helper.removeItemModal(component, elementId);
        component.set('v.currentItemId', '');
        component.set('v.overlayProdName', '');	
        component.set('v.openOverlay',false);
    },
	hayUnClick: function(component, event, helper) {
        component.set('v.showQuantInputs',true);
        event.stopPropagation();
    },
    clickDivEntero: function(component, event, helper) {
        component.set('v.showQuantInputs',false);
    },
    assignQuant:  function(component, event, helper) {
        component.set('v.isLoading', true);
        var selectedItem = event.currentTarget;
        
		var pId = selectedItem.dataset.pid;
		var qty = selectedItem.value;
        if(qty > 9999) {
            selectedItem.value = qty = 9999;
            
        } 
        var itemId = selectedItem.dataset.item;
        var unit = selectedItem.dataset.unit;

        helper.assignQty(component, pId, unit, qty, itemId);       		
    }
})