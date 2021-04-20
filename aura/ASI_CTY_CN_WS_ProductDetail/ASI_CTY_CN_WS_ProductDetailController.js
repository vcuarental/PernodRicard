({
	doInit : function(component, event, helper) {
        console.log('product detail init loaded...');
        component.set('v.showSpinner', true);
		helper.loadProductId(component);
        helper.loadProduct(component);
	},
	OnChangedCANumber: function (component, event, helper) {
        helper.handleOnChangedCANumber(component,event);
    },
    addEle : function(component, event, helper) {
        helper.addEle(component, event);
    },
    removeEle : function(component, event, helper) {
        helper.removeEle(component, event);
    },
    addToCart : function(component, event, helper) {
        helper.addToCart(component, event);
    },
    backToProductList : function(component, event, helper) {
        helper.backToProductList(component, event);
    },
})