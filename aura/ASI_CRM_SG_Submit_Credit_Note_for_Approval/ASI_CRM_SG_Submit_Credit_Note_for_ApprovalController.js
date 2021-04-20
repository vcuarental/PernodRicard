({
	doInit : function(component, event, helper) {
		var action = component.get("c.validateSubmit");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
             var data = response.getReturnValue();
            if(data){
                if(data != 'Success'){
                     $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": data
                });
                toastEvent.fire();
                }else{
                     $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "message": "Record is submitted for approval successfully."
                });
                toastEvent.fire();
                $A.get("e.force:refreshView").fire();    
                }
                $A.get("e.force:closeQuickAction").fire();
            }
        });$A.enqueueAction(action);
	}
})