({
    doInit : function(component, event, helper) {
        console.info('init carrito');
        component.set('v.isLoading', true);
        helper.getProducts(component);
        console.info('after init carrito');
    },
    avanzar1: function(component, event, helper) {
        var currentNumber = component.get("v.rowNumber");
        currentNumber++;
        component.set("v.rowNumber", currentNumber);
        helper.getProducts(component);
    },
    retroceder1: function(component, event, helper) {
        var currentNumber = component.get("v.rowNumber");
        if(currentNumber>0){
        	currentNumber--;
        }
        component.set("v.rowNumber", currentNumber);
        helper.getProducts(component);
    },
    irAlProd: function(component, event, helper) {
        console.log('ir al prod');
        var selectedItem = event.currentTarget;
        console.log('dataset : ' + JSON.stringify(selectedItem.dataset));
		var prod = selectedItem.dataset.prodid;
        console.log('prodid:'+prod);
       
        var address = '/s/detalle-producto?pid=' +prod;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": address,
            "isredirect" :true
        });
        urlEvent.fire();
        
        
    },
    selectView: function(component, event, helper) {
        var viewName = event.getSource().get('v.name');
        if (viewName === 'list-view') {
            component.set('v.isListView', true);
        } else if (viewName === 'grid-view') {
            component.set('v.isListView', false);
        }
    },
    irACarrito: function(component, event, helper) {
    	var address = '/s/nuevo-pedido';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": address,
            "isredirect" :true
        });
        urlEvent.fire();
    }
})