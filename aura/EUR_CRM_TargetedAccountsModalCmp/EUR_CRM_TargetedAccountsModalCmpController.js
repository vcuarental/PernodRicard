({
    onInit: function (component, event, helper) {
        helper.handleOnInit(component);
    },


    /* ========================================================= */
    /*     Handlers of  Parent Modal Window Component
    /* ========================================================= */
    onChangeShowModalWindow: function (component, event, helper) {
        helper.parentModalWindowCmp.handleOnChangeShowModalWindow();
    },

    onClickCancelModalWindow: function (component, event, helper) {
        helper.parentModalWindowCmp.handleOnClickCancelModalWindow();
    },

    onClickSaveModalWindow: function (component, event, helper) {
        helper.parentModalWindowCmp.handleOnClickSaveModalWindow();
    },

    onClickSaveAllTargetAccounts: function (component, event, helper) {
        helper.parentModalWindowCmp.handleOnClickSaveAllTargetAccounts();
    },



    /* ========================================================= */
    /*     Handlers of Assigned Accounts Component
    /* ========================================================= */
    onAssignedAccountsRowSelection: function (component, event, helper) {
        helper.assignedAccountsCmp.handleOnAssignedAccountsRowSelection();
    },

    onClickDeleteAssignedAccounts: function (component, event, helper) {
        helper.assignedAccountsCmp.handleOnClickDeleteAssignedAccounts();
    },


    /* ========================================================= */
    /*     Handlers of Target Accounts Component
    /* ========================================================= */
    onTargetAccountsRowSelection: function (component, event, helper) {
        helper.targetAccountsCmp.handleOnTargetAccountsRowSelection();
    },

    onChangeTargetAccounts: function (component, event, helper) {
        helper.targetAccountsCmp.handleOnChangeTargetAccounts();
    },

    setFilterData: function (component, event, helper) {
        helper.setFilterData(component,event);
    },
    getAllAccounts: function (component, event, helper) {
        helper.getAllAccounts(component,event);
    },
    loadMoreAssignedAccounts: function (component, event, helper) {
        helper.loadMoreAssignedAccounts(component, event, helper);
    },
    loadMoreAccountToAssign: function (component, event, helper) {
        helper.loadMoreAccountToAssign(component, event, helper);
    },
});