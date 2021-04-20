({
    firstPage: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
        helper.sendPage(component, event);
    },
    prevPage: function(component, event, helper) {
        var currentPageNumber = component.get("v.currentPageNumber");
        if (currentPageNumber - 1 < 0) {
            component.set("v.currentPageNumber", 1);
            component.set("v.isLoadingPage", false);
        } else {
            component.set("v.currentPageNumber", currentPageNumber - 1);
        }
        helper.sendPage(component, event);
    },
    nextPage: function(component, event, helper) {
        var currentPageNumber = component.get("v.currentPageNumber");
        var maxPageNumber = component.get("v.maxPageNumber")
        if (currentPageNumber + 1 > maxPageNumber) {
            component.set("v.currentPageNumber", maxPageNumber);
            component.set("v.isLoadingPage", false);
        } else {
            component.set("v.currentPageNumber", currentPageNumber + 1);
        }
        helper.sendPage(component, event);
    },
    lastPage: function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
        helper.sendPage(component, event);
    }
})