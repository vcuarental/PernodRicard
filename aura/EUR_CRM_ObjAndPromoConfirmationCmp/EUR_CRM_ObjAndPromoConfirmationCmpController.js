({

    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    onInit: function (component, event, helper) {
        helper.handleOnInit(component);
    },


    /* ========================================================= */
    /*     Event Handlers
    /* ========================================================= */
    onChangeProducts: function (component, event, helper) {
        helper.onChangeProductsHandler();
    },

    onChangeAccountTargetGroup: function (component, event, helper) {
        helper.onChangeAccountTargetGroupHandler();
    },

    onClickSave: function (component, event, helper) {
        helper.handleOnClickSave();
    },

    onDeleteProduct: function(component, event, helper) {
          helper.handleOnDeleteProduct(component, event);
    },


    /* ========================================================= */
    /*     Method Handlers
    /* ========================================================= */
    setConfirmedProductsMethod: function (component, event, helper) {
        const confirmedProducts = event.getParam('arguments').confirmedProducts;
        helper.parentComponent.setConfirmedProductsMethod(confirmedProducts);
    },

    showSpinnerMethod: function (component, event, helper) {
        helper.parentComponent.showSpinnerMethod();
    },

    hideSpinnerMethod: function (component, event, helper) {
        helper.parentComponent.hideSpinnerMethod();
    },

});