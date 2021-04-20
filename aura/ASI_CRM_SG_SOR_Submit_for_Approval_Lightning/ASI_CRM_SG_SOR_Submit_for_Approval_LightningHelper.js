({
	showToast : function(component, event, helper) {
		var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "type": "Warning",
        "message": component.get("v.msgString")
    });
   toastEvent.fire();
	}
})