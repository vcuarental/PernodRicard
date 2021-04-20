({
    doInit : function(component, event, helper) {
        helper.initializeData(component, event);
    },
    handleSubmit : function(component, event, helper){
        event.preventDefault(); // stop form submission
        if(component.get("v.contractRecord")){ 
            component.set("v.outletId",component.get("v.contractRecord").ASI_CRM_CN_Outlet_WS__c);
           
        }
        var action = component.get("c.save");
        action.setParams({ outletId : component.get("v.outletId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + JSON.stringify(response.getReturnValue()));
                var resp = response.getReturnValue();
                if(resp == 'Success'){
                    console.log("success: " + resp);
                    component.find('form').submit();
                }
                if(resp != 'Success'){
                    console.log("Error: " + resp);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error!",
                        "message": resp
                    });
                    toastEvent.fire();
                }
            }else{
                console.log("Error: " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);       
    },
    recordUpdated : function(component, event, helper) {
        //helper.initializeData(component, event);
        console.log('recordUpdated');
        var changeType = event.getParams().changeType; 
        if (changeType === "LOADED") { 
        }
    },
    handleError : function(component, event, helper) {
        var response = event.getParams();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error!",
            "message": event.getParam("output").errors[0].errorCode + ': ' + event.getParam("output").errors[0].message
        });
        toastEvent.fire();
    },
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "Contract has been saved successfully."
        });
        toastEvent.fire();
        //   helper.handleCancel(component,event);
        helper.handleSuccessRedirect(component, event);
    },
    handleCancel : function(component,event,helper){
        helper.handleCancel(component,event);
    }
})