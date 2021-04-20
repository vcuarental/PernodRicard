({
    onInit: function (component, event, helper) {
        helper.handleOnInit(component);
    },


    /* ========================================================= */
    /*     Event Handlers
    /* ========================================================= */
    onRecordsAreSelectedEvent: function (component, event, helper) {
        helper.handleOnRecordsAreSelectedEvent(event);
    },

    onShowHideComponentEvent: function (component, event, helper) {
        helper.handleOnShowHideComponentEvent(event);
    },

    onAccountsIsSelectedEvent: function (component, event, helper) {
        helper.handleOnAccountsIsSelectedEvent(event);
    },


    /* ========================================================= */
    /*     Interactions
    /* ========================================================= */
    onClickTargetUserRole: function (component, event, helper) {
        helper.handleOnClickTargetUserRole();
    },

    onChangeCountryCodeOption: function (component, event, helper) {
        helper.handleOnChangeCountryCodeOption();
    },

});