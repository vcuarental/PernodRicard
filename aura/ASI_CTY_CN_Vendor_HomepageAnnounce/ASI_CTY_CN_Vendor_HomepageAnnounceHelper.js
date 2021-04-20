({
    queryHomeAnnouncementList : function(component) {

        var action = component.get("c.getHomeAnnouncement");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
             component.set('v.showSpinner', false);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();

                if (storeResponse && storeResponse.length > 0) {
                	var showdownLoads = storeResponse;
                    component.set("v.announces", showdownLoads);
                } else {
                }
                
            } else {
                console.log('error fetching contacts');
            }
        });
        $A.enqueueAction(action);

    },
})