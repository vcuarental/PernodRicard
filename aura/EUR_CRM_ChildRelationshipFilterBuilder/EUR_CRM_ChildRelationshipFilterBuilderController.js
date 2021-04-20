({
    doInit: function (component, event, helper) {
        helper.getChildRelationships(component);
    },
    buildFilter: function (component, event, helper) {
        helper.buildFilterHandler(component, helper);
    },
    onChildRelationshipFilterBuild: function (component, event, helper) {
        event.stopPropagation();
        helper.childRelationshipFilterBuild(component, event);
    },
    fireBuildFilterEvent: function (component, event, helper) {
        helper.fireBuildFilterEventHandler(component, event, helper);
    },
    populateFilter: function (component, event, helper) {
        helper.filterPopulationHandler(component, event);
    }
})