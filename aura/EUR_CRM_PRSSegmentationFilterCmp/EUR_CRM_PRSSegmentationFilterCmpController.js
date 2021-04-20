({

    onInit: function (component, event, helper) {
        helper.handleOnInit(component);
    },


    /* ========================================================= */
    /*     Method Handlers
    /* ========================================================= */
    onValidate: function (component, event, helper) {
        helper.handleOnValidate();
    },

    onSetInitialItems: function (component, event, helper) {
        helper.handleOnSetInitialItems(event);
    },


    /* ========================================================= */
    /*     Interactions
    /* ========================================================= */
    onChangedSelectionMethod: function (component, event, helper) {
        helper.handleOnChangedSelectionMethod();
    },

    onChangedImageLevel: function (component, event, helper) {
        helper.handleOnChangedImageLevel(event);
    },

    onChangedGOT: function (component, event, helper) {
        helper.handleOnChangedGOT(event);
    },

    onChangedInnerPros: function (component, event, helper) {
        helper.handleOnChangedInnerPros(event);
    },

});