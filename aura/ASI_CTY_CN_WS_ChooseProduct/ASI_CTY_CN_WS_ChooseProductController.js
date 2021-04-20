({  
    doInit : function(component, event, helper) {
        console.info('init  loaded..');
        component.set('v.showSpinner', true);
        helper.loadOrderId(component);
        helper.setfilterItems(component);
        helper.getBrandRels(component);
        helper.getProducts(component);
        
    },
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },
    customFilter: function(component, event, helper) {
        helper.customFilter(component);
    },
    orderSettlement: function(component, event, helper) {
        var orderId = component.get("v.orderId");
        console.log('orderId' + orderId);
        helper.navigateToURL('shopping-cart?orderId=' + orderId);
    },
    showRowDetails: function (component, event, helper){
        var orderId = component.get("v.orderId");
        console.log('orderId' + orderId);
        var productId = event.currentTarget.id;
        console.log('productId' + productId);
        helper.navigateToURL('product-detail?orderId=' + orderId + '&productId=' + productId);
    },
    addToCart : function(component, event, helper) {
        helper.addToCart(component, event);
    },
    hideAllProductFilterItems : function(component, event, helper) {
        component.set('v.showAllProductFilterItems', false);
    },
    hideCurrentSeasonMainProductFilterItems : function(component, event, helper) {
        component.set('v.showCurrentSeasonMainProductFilterItems', false);
    },
    setBrandFilter : function(component, event, helper) {
        helper.setBrandFilter(component, event);
    },
    setBottleSizeFilter : function(component, event, helper) {
        helper.setBottleSizeFilter(component, event);
    },
    setSpecialSaleFilter : function(component, event, helper) {
        helper.setSpecialSaleFilter(component, event);
    },
    clearFilter : function(component, event, helper) {
        helper.clearFilter(component, event);
    },
    clearThisFilter : function(component, event, helper) {
        helper.clearThisFilter(component, event);
    },
    
    toggleFilterList : function(component, event, helper) {
        helper.toggleFilterList(component, event);
    },
    hideList : function(component, event, helper) {
        component.set('v.showList', false);
    },
    showList : function(component, event, helper) {
        component.set('v.showList', true);
    },
    handleActive: function (component, event, helper) {
        var tab = event.getSource();
        switch (tab.get('v.id')) {
            case 'one' :
                component.set('v.showList', true);
                component.set('v.showAllProductFilterItems', true);
                component.set('v.showAllProducts', true);
                component.set('v.showSeparateItems', false);
                break;
            case 'two' :
                component.set('v.showList', false);
                component.set('v.showCurrentSeasonMainProductFilterItems', true);
                component.set('v.showAllProducts', false);
                component.set('v.showSeparateItems', false);
                break;
            case 'three' :
                component.set('v.showList', false);
                component.set('v.showSeparateItems', true);
                component.set('v.showAllProducts', false);
                break;
        }
        helper.customFilter(component);
    },
    addEle : function(component, event, helper) {
        helper.addEle(component, event);
    },
    removeEle : function(component, event, helper) {
        helper.removeEle(component, event);
    },
    OnChangedCANumber: function (component, event, helper) {
        helper.onChangedCANumber(component,event);
    },
})