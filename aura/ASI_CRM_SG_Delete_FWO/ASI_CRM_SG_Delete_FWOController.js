({
    doInit : function(component, event, helper) {
        var action = component.get("c.deleteFWO");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var data = response.getReturnValue();
            $A.get("e.force:closeQuickAction").fire();
            if(data){
                if(data == 'Success'){
                     var homeEvent = $A.get("e.force:navigateToObjectHome");
                    homeEvent.setParams({
                        "scope": "ASI_CRM_Credit_Debit_Note__c"
                    });
                    homeEvent.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "Success",
                        "message": "The record has been deleted successfully."
                    });
                    toastEvent.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Warning",
                        "message": data
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