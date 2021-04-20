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
    onRecordsAreSelectedEvent: function (component, event, helper) {
        helper.handleOnRecordsAreSelectedEvent(event);
    },


    /* ========================================================= */
    /*     Interaction
    /* ========================================================= */
    onChangedSelectionMethod: function (component, event, helper) {
        helper.handleOnChangedSelectionMethod();
    },

    onChangedListView: function (component, event, helper) {
        helper.handleOnChangedListView();
    },

    onChangedCustomerTaxonomy: function (component, event, helper) {
        helper.handleOnChangedCustomerTaxonomy();
    },

    onChangedImageLevel: function (component, event, helper) {
        helper.handleOnChangedImageLevel(component,event);
    },

    onChangedGOT: function (component, event, helper) {
        helper.handleOnChangedGOT(component,event);
    },

    onChangedInnerPros: function (component, event, helper) {
        helper.handleOnChangedInnerPros(component,event);
    },

    onClickApplyPros: function (component, event, helper) {
        helper.handleOnClickApplyPros();
    },
    selectTable: function (component, event, helper) {
        console.log('PROS => '+component.get("v.pros"))
    },
});