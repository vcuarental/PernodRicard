({
    sendPage : function(component, event) {
    	var pageEvent = component.getEvent('changePageEvent');
    	pageEvent.setParams({
    		'currentPage': component.get("v.currentPageNumber"),
    		'isLoadingPage':  component.get("v.isLoadingPage")
    	});
    	pageEvent.fire();
    }
})