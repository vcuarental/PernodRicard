({
    doInit: function(cmp){
        var action = cmp.get("c.getHomeAnnouncement");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.announces", response.getReturnValue());
             } 
        }); 
        $A.enqueueAction(action);
    }
 })