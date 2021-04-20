({
    onClickAddToCart: function (component, event, helper) {
        console.log('onClickAddToCart()');
        helper.handleOnClickAddToCart(component);
    },

    resort: function (component, event, helper) {
        console.log('resort()');
        helper.handleResort(component, event);
    },
});