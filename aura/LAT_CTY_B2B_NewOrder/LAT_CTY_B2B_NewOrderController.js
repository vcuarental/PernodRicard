({
    doInit : function(component, event, helper) {
        console.info('init carrito');/*
        helper.getblockedClient(component);
        helper.getOrderTakingEnabled(component, event);
        helper.getblockedMessage(component, event);
        helper.getCategories(component);*/
        helper.getProducts(component);
        /*helper.initFilterMap(component);*/
        console.info('after init carrito');
    },
    doContinueInit : function(component, event, helper) {
        console.info('continue init carrito');
        helper.getblockedClient(component);
        helper.getOrderTakingEnabled(component, event);
        helper.getblockedMessage(component, event);
        helper.getCategories(component);
        //helper.getProducts(component);
        helper.initFilterMap(component);
        console.info('after continue init carrito');
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
    closeModalOrderBlocked: function(component, event, helper) {
        component.set('v.showModalBlockedClient', false);
    },
    selectView: function(component, event, helper) {
        var viewName = event.getSource().get('v.name');
        if (viewName === 'list-view') {
            component.set('v.isListView', true);
        } else if (viewName === 'grid-view') {
            component.set('v.isListView', false);
        }
    },
    addToCart : function(component, event, helper) {
        console.log('add controller');
        helper.addToCart(component, event);
        // var close = component.get('c.closeModal');
        // $A.enqueueAction(close);
    },
    closeModal : function(component, event, helper) {
        component.set('v.showModal', false);
    },
    selectCategory : function(component, event, helper) {
        var value = event.target.innerHTML;
        component.set('v.selectedCategory', value);
    },
    showCart : function(component, event, helper) {
        //helper.showCartSection(component);
        console.info('creating order');
        helper.createOrderAndLineItems(component);
        console.info('AFTER creating order');
    },
    setUnit : function(component, event, helper) {
        console.info('setUnit controller');
        helper.setUnit(component, event);
        
    },
    setBrandFilter : function(component, event, helper) {
        let nuevo = [];
        component.set("v.filterSelectedBrand",nuevo);
        helper.setBrandFilter(component, event);
    },
    setCategoryFilter : function(component, event, helper) {
        let nuevo = [];
        component.set("v.filterSelectedBrand",nuevo);
        helper.setCategoryFilter(component, event);
    },
    clearFilter : function(component, event, helper) {
        helper.clearFilter(component, event);
    },
    
    toggleFilterList : function(component, event, helper) {
        helper.toggleFilterList(component, event);
    },
    searchTerm : function (component, event, helper) {
        console.info('timer');
		var timer = component.get('v.timer');
		clearTimeout(timer);
		timer = setTimeout(function(){
            helper.searchTerm(component, event);	
            console.info('timer');
			clearTimeout(timer);
			component.set('v.timer', null);
		}, 500);
	
        component.set('v.timer', timer);
        // helper.searchTerm(component, event);	


    }
})