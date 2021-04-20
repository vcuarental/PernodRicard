({
	/*
     * Init action
     * Populate paginator variables
     */
	doInit: function(component, event, helper) {
		var actionGetActivityRequests = component.get("c.getActivityRequests");
        component.set("v.isAdmin",component.get("v.isAdmin") == 'true');


        actionGetActivityRequests.setCallback(this, function(a) {
            if(actionGetActivityRequests.getState() ==='SUCCESS'){
                var result = a.getReturnValue();
                component.set("v.allRows" ,result);
                component.set("v.rows" , result.slice(0,100));
                var maxPage = Math.floor((component.get("v.allRows").length + (component.get('v.itemsPerPage')-1) )/ component.get('v.itemsPerPage'));
				component.set("v.maxPageNumber", maxPage);
				component.set("v.currentPageNumber", 1);
				component.set("v.showing", component.get('v.itemsPerPage'));


            }else{ 
                //component.find("loadingViews").hide();
                var errors = a.getError();
                var errorTxt = '';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorTxt = errors[0].message
                    }
                } else {
                    errorTxt = "Unknown error";
                }
               console.log( "There was an error retrieving the record list: \n" +  errorTxt);
            }
        });
        $A.enqueueAction(actionGetActivityRequests);		
	},

	newRequest:function(component, event, helper) {
		 window.location.href = 'GDT_ManageActivity_NewActivityRequest';
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
    	console.log()
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
    	if(component.get("v.currentPageNumber") < component.get("v.maxPageNumber")){
			component.find("loadingTable").show();
	    	setTimeout(function() {
	        	component.set("v.currentPageNumber", Math.min(component.get("v.currentPageNumber")+1, component.get("v.maxPageNumber")));
			}, 1000);
    	}
    },
    lastPage: function(component, event, helper) {
    	if(component.get("v.currentPageNumber") < component.get("v.maxPageNumber")){
	    	component.find("loadingTable").show();
	    	setTimeout(function() {
	        	component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
	        }, 1000);
    	}
    }




})