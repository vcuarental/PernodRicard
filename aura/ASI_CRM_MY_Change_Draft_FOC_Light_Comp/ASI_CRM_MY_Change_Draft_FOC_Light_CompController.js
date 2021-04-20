({
	doInit : function(component, event, helper) {
		var action = component.get("c.getRecord");
        action.setParams({
            "recordId" : component.get("v.recordId")
        })
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
            if(data){
                if(data.ASI_CRM_Status__c == 'Cancelled'){
                    if(data.ASI_CRM_Auto_Generation__c){
                     $A.get("e.force:closeQuickAction").fire();
                 	var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                         "type" : "warning",
                         "message": "Sorry, auto-generated FOC cannot be draft again. You may re-gen a new request for further update."
                	});
                    toastEvent.fire(); 
                    }else{
                        if(confirm('Are you sure to change the status to "Draft"?')==true){
							var action1 = component.get("c.updatToDraft");
                            action1.setParams({
                                "recordId" : component.get("v.recordId") 
                            });  
                            action1.setCallback(this, function(response){
                                var data = response.getReturValue();
                                $A.get("e.force:closeQuickAction").fire();
                                if(data){
                                    if(data=='Success'){
                                        var toastEvent = $A.get("e.force:showToast");
                                         toastEvent.setParams({
                                             "type" : "success",
                                             "message": "Succeeded! You could update the FOC and approve again."
                                        });
                                         toastEvent.fire(); 
                                    }else{
                                        var toastEvent = $A.get("e.force:showToast");
                                         toastEvent.setParams({
                                             "type" : "error",
                                             "message": data
                                        });
                                         toastEvent.fire(); 
                                    }
                                }
                            });$A.enqueueAction(action1);
                        }else{
                            $A.get("e.force:closeQuickAction").fire();
                        }
                    }
                }else{
                    $A.get("e.force:closeQuickAction").fire();
                 	var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                         "type" : "warning",
                         "message": "Only \"Cancelled\" FOC can be changed to \"Draft\"."
                	});
                     toastEvent.fire(); 
                }
            }
        });
        $A.enqueueAction(action);
        
	}
})