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
    onClickCancelModalWindow: function (component, event, helper) {
        helper.onClickCancelModalWindowHandler();
    },

    onClickClone: function (component, event, helper) {
        helper.onClickCloneHandler();
    },

});