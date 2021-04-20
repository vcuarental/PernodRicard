({
    doInit: function (component, event, helper) {
        helper.handleInit(component, helper);
    },
    doCancel: function (component, event, helper) {
        helper.handleCancel(component, helper);
    },
    doSaveRecord: function (component, event, helper) {
        helper.handleSave(component, event, helper);
    },
    onParentFilterBuild: function (component, event, helper) {
        helper.buildParentFilterHandler(component, event, helper);
    },
    onChildFilterBuild: function (component, event, helper) {
        helper.buildChildFilterHandler(component, event, helper);
    },
    saveGroupFilter: function (component, event, helper) {
        helper.saveGroupFilterHandler(component, event, helper);
    },
    recordDataUpdated: function (component, event, helper) {
        helper.loadedRecordDataHandler(component, event, helper);
    },
    handleChange: function (cmp, event) {
        // var changeValue = event.getParam("groupTypeValue");
    }
})