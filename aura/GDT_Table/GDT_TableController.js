({
	/*
     * Init action
     * Populate paginator variables
     */
	doInit: function(component, event, helper) {
        var maxPage = Math.floor((component.get("v.allRows").length + (component.get('v.itemsPerPage')-1) )/ component.get('v.itemsPerPage'));
		component.set("v.maxPageNumber", maxPage);
		component.set("v.currentPageNumber", 1);
		component.set("v.showing", component.get('v.itemsPerPage'));

	},

	onRender: function(component, event, helper) {
		 helper.renderPage(component);
    },

    /*
     * Sort column action
     */
    sortColumn: function (component, event, helper) {
    	var fieldName =  event.currentTarget.getAttribute("data-recordName");;
    	setTimeout(function() {
        	var sortDirection = component.get("v.sortedDirection") == 'asc' ? 'desc' : 'asc';
        	component.set("v.sortedDirection", sortDirection);
        	component.set("v.sortedBy", fieldName);
        	helper.sortData(component, fieldName, sortDirection);
    	}, 1000);
    },

        /*
     * Show/hide number of records select options
     */
    showDisplayAmounts: function (component, event, helper) {
        if(component.get("v.displayValue")=="none"){
            component.set("v.displayValue","block");
        }else{
            component.set("v.displayValue","none");            
        }
    },


    displayAmountSelected: function (component, event, helper) {
        var itemsPerPageString = event.target.getAttribute("id");
        component.set("v.itemsPerPage", parseInt(itemsPerPageString));
        helper.showGivenAmount(component, helper);
        component.set("v.displayValue","none");
        component.set("v.currentPageNumber",1);
        var maxPage = Math.floor((component.get("v.allRows").length + (component.get('v.itemsPerPage')-1) )/ component.get('v.itemsPerPage'));
		component.set("v.maxPageNumber", maxPage);
        helper.renderPage(component);

    },

     /*
     * Paginator buttons logic
     */
    firstPage: function(component, event, helper) {
    	if(component.get("v.currentPageNumber") >1){
	    	component.find("loadingTable").show();
	        setTimeout(function() {
	        	component.set("v.currentPageNumber", 1);
	        }, 10);
	    }
    },
    prevPage: function(component, event, helper) {
    	if(component.get("v.currentPageNumber") >1){
	    	component.find("loadingTable").show();
	    	setTimeout(function() {
	        	component.set("v.currentPageNumber", Math.max(component.get("v.currentPageNumber")-1, 1));
	        }, 1000);
	    }
    },
    nextPage: function(component, event, helper) {
		component.find("loadingTable").show();
    	setTimeout(function() {
        	component.set("v.currentPageNumber", Math.min(component.get("v.currentPageNumber")+1, component.get("v.maxPageNumber")));
		}, 1000);
    },
    lastPage: function(component, event, helper) {
    	component.find("loadingTable").show();
    	setTimeout(function() {
        	component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
        }, 1000);
    }




})