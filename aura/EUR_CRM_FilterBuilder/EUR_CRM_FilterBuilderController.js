({
    doInit: function(cmp, event, helper) {
        helper.initHandler(cmp, helper);
    },

    addItem: function(cmp, event, helper) {
        helper.addItemHandler(cmp, event);
    },

    removeItem: function(cmp, event, helper) {
        helper.removeItemHandler(cmp, event);
    },

    enableCustomFilterLogic: function(cmp, event, helper) {
        cmp.set('v.isCustomFilterLogic', true);
    },

    disableCustomFilterLogic: function(cmp, event, helper) {
        cmp.set('v.filterLogic', null);
        cmp.set('v.isCustomFilterLogic', false);
        var filterLogic = cmp.find('filterLogic');
        filterLogic.set("v.errors", null);
    },

    onItemFieldValueChange: function(cmp, event, helper) {
        helper.onItemFieldValueChangeHandler(cmp, event, helper);
    }, 

    populateValues: function(cmp, event, helper) {
        helper.populateValuesHandler(cmp, event, helper);
    },

    validate: function(cmp, event, helper) {
        helper.validateHandler(cmp, event, helper);
    },

    addParentObjectFilters: function(cmp, event, helper) {
        helper.addParentObjectFiltersHandler(cmp, event, helper);
    },

    setInitialItems: function(cmp, event, helper) {
        helper.setInitialItemsHandler(cmp, event, helper);
    }
})