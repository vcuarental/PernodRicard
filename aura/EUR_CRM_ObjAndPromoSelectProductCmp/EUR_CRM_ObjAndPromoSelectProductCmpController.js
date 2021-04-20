({

    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    onInit: function (component, event, helper) {
        helper.onInitHandler(component);
    },


    /* ========================================================= */
    /*     Interactions
    /* ========================================================= */
    onChangeShowComponentBody: function (component, event, helper) {
        helper.downloadSelectedProductType();
    },

    onChangeSelectedProductType: function (component, event, helper) {
        helper.onChangeSelectedProductTypeHandler(component);
    },

    onChangeUserInput: function (component, event, helper) {
        helper.onChangeUserInputHandler(component, event);
    },

    onChangeProductDualListBoxComponent: function (component, event, helper) {
        helper.onChangeProductDualListBoxComponentHandler(component, event);
    },

    onClickRefresh: function (component, event, helper) {
        helper.onClickRefreshHandler(component);
    },

    onClickConfirm: function (component, event, helper) {
        helper.onClickConfirmHandler(component);
    },


    /* ========================================================= */
    /*     Methods Handlers
    /* ========================================================= */
    refreshProductListMethod: function (component, event, helper) {
        helper.onClickRefreshHandler(component);
    },

});