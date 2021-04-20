({
	doInit : function(component, event, helper) {
		var action = component.get("c.validateContract");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
           
            if(data){
                
                if(data=='Success'){
                    console.log('@#');
                    var isConfirmed = window.confirm('Are you sure to convert?');
                    
					if (isConfirmed){
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                          "url": "/apex/ASI_CRM_SG_ContractClonePage?id="+component.get("v.recordId")+"&copy=3"
                        });
                         $A.get("e.force:closeQuickAction").fire();
                        urlEvent.fire();
                    }else{
                         $A.get("e.force:closeQuickAction").fire();
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