({
	initCart : function(component, event, helper) {
        component.set('v.baseUrl' , window.location.pathname.substring(0,window.location.pathname.indexOf('/s/') + 3));        

		component.set('v.isLoading', true);
        helper.getblockedClient(component);
        helper.getMinimunOrderPrice(component, event);
		helper.initCart(component, event);
        helper.getAvailableCredit(component);
	},
	validateStock : function(component, event, helper) {
		helper.validateStock(component, event);
	},
    closeModalOrderBlocked: function(component, event, helper) {
        component.set('v.showModalBlockedClient', false);
    },
	removeItem : function(component, event, helper) {
		
        var selectedItem = event.currentTarget;
        var elementId = selectedItem.dataset.item;
        var nombreprod = selectedItem.dataset.nombreprod;
        console.log('dataset seleccionado:'+JSON.stringify(selectedItem.dataset)) ;        
        console.log('dataset nombreProd:'+nombreprod) ;
        component.set('v.currentItemId', elementId);	
        component.set('v.overlayProdName', nombreprod);	
        component.set('v.openOverlay',true);
	},
	sumQTY: function(component, event, helper) {
		component.set('v.isLoading', true);
		var selectedItem = event.currentTarget;
		var pId = selectedItem.dataset.pid;
		var itemId = selectedItem.dataset.item;
		var unit = selectedItem.dataset.unit;
		
	
		helper.sumQty(component, pId, unit, 1, itemId);
	},
	subtractQty: function(component, event, helper) {
		
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
	sendToJDE : function(component, event, helper) {
		//var res = helper.checkStockOnline(component, event);
        //helper.sendToJDE(component, event);
        var aux = component.get('v.commentsChanged');
        if(aux){
            helper.setCommentsAndIntegrate(component, event);
        } else {
            var res = helper.checkStockOnline(component, event);
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
        console.log('id enviada:' + elementId);
		
        helper.removeItemModal(component, elementId);
        component.set('v.currentItemId', '');
        component.set('v.overlayProdName', '');	
        console.log('id enviada despues:' + elementId);
        component.set('v.openOverlay',false);
    },
    setComments: function(component, event, helper) {
        
        component.set('v.commentsChanged', true);
        //
    },
	hayUnClick: function(component, event, helper) {
        component.set('v.showQuantInputs',true);
        event.stopPropagation();
        console.log('hay un click');
    },
    clickDivEntero: function(component, event, helper) {
        component.set('v.showQuantInputs',false);
        console.log('hay otro click');
    },
    assignQuant:  function(component, event, helper) {
        console.log('entramos qty:');
        component.set('v.isLoading', true);
        var selectedItem = event.currentTarget;
        console.log('entramos selectedItem:'+selectedItem);
        console.log('entramos selectedItem.value:'+selectedItem.value);
        console.log('entramos event:'+event);
		var pId = selectedItem.dataset.pid;
		var qty = selectedItem.value;
		var itemId = selectedItem.dataset.item;
		var unit = selectedItem.dataset.unit;
        console.log('entramos pid:' + pId);
        console.log('entramos qty:' + qty);
        helper.assignQty(component, pId, unit, qty, itemId);
    }
})