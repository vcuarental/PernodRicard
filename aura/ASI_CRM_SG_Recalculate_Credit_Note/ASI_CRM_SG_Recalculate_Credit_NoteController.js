({
    doInit : function(component, event, helper) {
        var action = component.get("c.reCalculate");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var data = response.getReturnValue();
            $A.get("e.force:closeQuickAction").fire();
            if(data){
                if(data.msg == 'Success'){
                   var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": data.newId
    });
    navEvt.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "Success",
                        "message": "Credit Note has been recalculated successfully."
                    });
                    toastEvent.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Warning",
                        "message": data.msg
                    });
                    toastEvent.fire();
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "un-expected error occurred"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    }
})