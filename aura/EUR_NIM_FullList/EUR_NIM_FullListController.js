({
    init : function(component, event, helper) {
        // resetting v.columns to the table to fire change event for data table to call helper.recreateGroups() function to display totals. On initial render flow this doesn't happen
        var datatable = component.find("data-table");
        datatable.set("v.columns", component.get("v.columns"));
        component.set("v.parentName", JSON.parse(component.get("v.parent")).name);
        component.set("v.parentPluralLabel", JSON.parse(component.get("v.parent")).pluralLabel);

        component.set("v.listSize", datatable.get("v.visibleRows").length);
        var sortColumn = [].filter.call(component.get("v.columns"), col => col.fieldName == component.get("v.sortField"));
        if ( sortColumn[0] )
        {
            component.set("v.sortColumnLabel", sortColumn[0].label);
        }
    },
    onRender : function(component, event, helper) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    openParentsList : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/one/one.app?source=alohaHeader#/sObject/" + JSON.parse(component.get("v.parent")).objectType + "/list"
        });
        urlEvent.fire();

    },
    openParent : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": JSON.parse(component.get("v.parent")).recordId,
          "slideDevName": "related"
        });
        navEvt.fire();
    },
    handleSortChange : function(component, event, helper) {
        helper.showSpinner(component);

        setTimeout(function(){
            var table = component.find("data-table");
            var sortColumn = [].filter.call(component.get("v.columns"), col => col.fieldName == table.get("v.sortField"));
            component.set("v.sortColumnLabel", sortColumn[0].label);
        }, 10);
    },
    toggleFilterVisible: function(component, event, helper) {
       component.set('v.filterVisible', ! component.get('v.filterVisible'));
    },
    handeFilterChange: function(component, event, helper)
    {
        helper.showSpinner(component);

        setTimeout(function(){
            var filter = component.find("filter");
            filter.handeFilterChange(component, event.getParam('isFrontend'));
        })
    },
    resetFilters : function(component, event, helper)
    {
        helper.showSpinner(component);

        setTimeout(function(){
            var filter = component.find("filter");
            filter.handeFilterReset(component);
        })
    },
})