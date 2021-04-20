({
    doInit : function(component, event, helper) {
        console.log('doInitFired!');
		var action = component.get("c.getUrlImage");
        //var action = component.get("c.getUrlImageObj");
        action.setParams({
            idDeepDive : component.get("v.deep_dive"),
            ecran : component.get("v.ecran")
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                component.set("v.l_latestpublishedversionid", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})