({

    doInit: function (cmp, event, helper) {
        helper.doInitHelper(cmp);
    },

    setResultRecords: function (cmp, event, helper) {
        helper.setResultRecordsHandler(cmp);
    },

    displayMore : function (cmp, event, helper) {
        helper.handleDisplayMore(cmp, helper);
    },

    handleToggleOptions : function (cmp, event, helper) {
        helper.toggleOptions(cmp, event, helper);
    },

    handleConditionsModalSave : function (cmp, event, helper) {
        helper.saveConditions(cmp, event, helper);
    },

    toggleTileSelection : function (cmp, event, helper) {
        helper.toggleTileSelectionHandler(cmp, event);
    }
});