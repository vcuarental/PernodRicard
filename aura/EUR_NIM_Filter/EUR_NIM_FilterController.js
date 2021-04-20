({
    initFilter : function(component, event, helper) {
        var params = event.getParam('arguments');
        helper.initFilter(params.callerComponent, helper);
    },
    handeFilterChange : function(component, event, helper)
    {
        var params = event.getParam('arguments');
        params.callerComponent.set("v.isFilterActive", true);
        if (!params.isFrontend)
        {
            helper.applyBackendFilter(params.callerComponent, helper);
        }
        else
        {
            helper.applyFrontendFilter(params.callerComponent, helper);
        }
    },
    handeFilterReset : function(component, event, helper)
    {
        var params = event.getParam('arguments');
        var callerComponent = params.callerComponent;

        callerComponent.set("v.isFilterActive", false);
        var filters = callerComponent.find("filter").find("filter-field");

        helper.applyBackendFilter(params.callerComponent, helper, true);
        helper.applyFrontendFilter(params.callerComponent, helper);

        filters.forEach(filter => filter.reset());

        var dataTable = params.callerComponent.find('data-table');
        dataTable.set("v.sortField", params.callerComponent.get("v.defaultSortField"));
        dataTable.set("v.sortDir", params.callerComponent.get("v.defaultSortDirection"));
        dataTable.applyDefaultSorting();
    }
})