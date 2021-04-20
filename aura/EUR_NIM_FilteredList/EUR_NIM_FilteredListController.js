({
	init : function(component, event, helper) {
        var filter = component.find("filter");
        filter.initFilter(component);
        helper.getParentData(component, event);

	},
	toggleFilterVisible: function(component, event, helper) {
       component.set('v.filterVisible', ! component.get('v.filterVisible'));
       var filter = component.find("filter");
       filter.set("v.filterFields", component.get("v.filterFields"));
    },
    showAllRecords : function(component, event, helper)
    {
        //var spinner = component.find("spinner");
        //spinner.getElement().classList.remove("slds-hide");

        setTimeout(function(){

        var parent = JSON.parse(component.get("v.parent"));
        parent.objectType = component.get("v.sObjectName");
        parent.recordId = component.get("v.recordId");
        var evt = $A.get("e.force:navigateToComponent");
        var table = component.find("data-table");

        evt.setParams({

            componentDef : "c:EUR_NIM_FullList",
            componentAttributes: {
                sObjectArray : component.get("v.sObjectArray"),
                columns : JSON.parse(component.get("v.fullListFields")),
                groupField : component.get("v.groupField"),
                groupExpansion : component.get("v.groupExpansion"),
                showTotal : component.get("v.showTotal"),
                pageSize: 100,
                sortField : component.get("v.fullListDefaultSortField"),
                defaultSortField : component.get("v.fullListDefaultSortField"),
                sortDir : component.get("v.fullListDefaultSortDirection"),
                defaultSortDirection : component.get("v.fullListDefaultSortDirection"),
                listTitle: component.get("v.title"),
                parent: JSON.stringify(parent),
                sObjectArrayRaw : component.get("v.sObjectArrayRaw"),
                listsObjectName: component.get("v.listsObjectName"),
                fullListFields: component.get("v.fullListFields"),
                sObjectFieldList : component.get("v.sObjectFieldList"),
                // filter parameters
                isFilterActive : component.get("v.isFilterActive"),
                translations: component.get("v.translations"),
                restrictionStatement : component.get("v.restrictionStatement"),
                filterFields: component.get("v.filterFields")
            }
        });
        evt.fire();

        },10)
    },
    hideAllRecords : function(component, event, helper)
    {
        component.set("v.showAllRecords", false);
    },
    handeFilterChange: function(component, event, helper)
    {
        var spinner = component.find("EUR_NIM_Spinner");
        $A.util.removeClass(spinner, "slds-hide");

        setTimeout(function(){
            var filter = component.find("filter");
            filter.handeFilterChange(component, event.getParam('isFrontend'));
        }, 10)
    },
    resetFilters : function(component, event, helper)
    {
        var spinner = component.find("EUR_NIM_Spinner");
        $A.util.removeClass(spinner, "slds-hide");

        setTimeout(function(){
            var filter = component.find("filter");
            filter.handeFilterReset(component);
        }, 10)
    },
})