({
	doInit : function(component, event, helper) {
		var action = component.get("c.preSubmitValidate");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
            if(data){
                if(data=='Success'){
                     helper.callExecute(component,event, helper);
                }else if(data == 'Confirm'){
                  var isConfirmedPartner = window.confirm('This contract is able to be a Key Account. Do you still want to submit it as Partner? Otherwise, please change contract type to Key Account and re-submit.');
			if (!isConfirmedPartner){
				$A.get("e.force:closeQuickAction").fire();
            }else{
                helper.callExecute(component,event, helper);
            }
                }else{
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "message": data
                    });
                    toastEvent.fire();
                }
            }else{
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Unexpected error occurred"
                });
                toastEvent.fire();
            }
            
        });$A.enqueueAction(action);
	}
    
    
})