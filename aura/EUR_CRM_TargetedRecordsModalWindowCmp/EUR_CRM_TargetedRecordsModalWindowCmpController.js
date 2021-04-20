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


    /* ========================================================= */
    /*     Handlers of Assigned Records Component
    /* ========================================================= */
    onAssignedRecordsRowSelection: function (component, event, helper) {
        helper.assignedRecordsCmp.handleOnAssignedRecordsRowSelection();
    },

    onClickDeleteAssignedRecords: function (component, event, helper) {
        helper.assignedRecordsCmp.handleOnClickDeleteAssignedRecords();
    },


    /* ========================================================= */
    /*     Handlers of Target Records Component
    /* ========================================================= */
    onTargetRecordsRowSelection: function (component, event, helper) {
        helper.targetRecordsCmp.handleOnTargetRecordsRowSelection();
    },

    onChangeTargetRecords: function (component, event, helper) {
        helper.targetRecordsCmp.handleOnChangeTargetRecords();
    },
});