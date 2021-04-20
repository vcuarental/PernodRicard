({
    doInit : function(component, event, helper) {
        var action = component.get("c.getRecord");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
            if(data){
                
                if(data =='Success'){
                    var isConfirmed = window.confirm('Are you sure to archive?');
                    if (isConfirmed){
                        var action1 = component.get("c.updateRecord");
                        action1.setParams({
                            "recordId" : component.get("v.recordId")
                        });
                        action1.setCallback(this, function(response){
                            var data = response.getReturnValue();
                            $A.get("e.force:closeQuickAction").fire();
                            if(data){
                                if(data == 'Success'){
                                    $A.get('e.force:refreshView').fire(); 
                                }else{
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "type": "warning",
                                        "message": data
                                    });
                                    toastEvent.fire();
                                }
                            }else{
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "error",
                                    "message": "Unexpected error occurred"
                                });
                                toastEvent.fire();
                            }
                        });
                        $A.enqueueAction(action1);
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
        });
        $A.enqueueAction(action);
    }
})