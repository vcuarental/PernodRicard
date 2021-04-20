({
    onInit: function (component, event, helper) {
        helper.handleOnInit(component);
    },

    onRecordLoaded: function (component, event, helper) {
        helper.handleOnRecordLoaded();
    },


    /* ========================================================= */
    /*     Event Handlers
    /* ========================================================= */
    onSelectionMethodIsChangedEvent: function (component, event, helper) {
        helper.handleOnSelectionMethodIsChangedEvent(component,event);
    },

    onAccountsIsSelectedEvent: function (component, event, helper) {
        helper.handleOnAccountsIsSelectedEvent(event);
    },

    onShowHideComponentEvent: function (component, event, helper) {
        helper.handleOnShowHideComponentEvent(event);
    },
    addAllAcc: function (component, event, helper) {
        helper.addAllAcc(component,event);
    },

    /* ========================================================= */
    /*     Interactions
    /* ========================================================= */
    onClickTargetAccounts: function (component, event, helper) {
        helper.showTargetedAccountsModalWindow();
    },

});