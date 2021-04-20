({
   getDownLoadList : function(component) {

        var action = component.get("c.getDownLoadList");
        action.setParams({
            'filesName': 'ASI CTY CN Vendor DownLoad Template'
        });
        component.set('v.showSpinner', true);
        action.setCallback(this, function(response) {
            var state = response.getState();
             component.set('v.showSpinner', false);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();

                if (storeResponse && storeResponse.length > 0) {
                	var showdownLoads = storeResponse;
                    component.set("v.showdownLoads", showdownLoads);
                } else {
                }
                
            } else {
                console.log('error fetching contacts');
            }
        });
        $A.enqueueAction(action);

    },
})