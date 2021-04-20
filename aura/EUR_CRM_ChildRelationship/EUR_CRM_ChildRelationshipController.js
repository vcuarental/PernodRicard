({
    doInit: function (component, event, helper) {
        helper.describeChildRelationship(component, helper);
    },
    changePartnerRelationType: function (component, event, helper) {
        helper.changeRelationType(component, event, helper);
    },
    expandSection: function (component, event, helper) {
        helper.expandSectionHandler(component);
    },
    onBuildFilter: function (component, event, helper) {
        event.stopPropagation();
        helper.onBuildFilterHandler(component, event, helper);
    },
    buildFilter: function (compoent, event, helper) {
        helper.buildFilterHandler(compoent);
    }
})