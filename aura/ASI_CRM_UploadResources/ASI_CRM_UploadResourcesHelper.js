({
	helperMethod : function() {
		
	},
    
    createRecord : function (component, event, helper, jsonstr, uploadResourceId, recordId, sobjecttype){
        console.log('------ HELPER -------');
        console.log('@@@ jsonContext: ' + jsonstr);
        console.log('@@@ uploadResourceId: ' + uploadResourceId);
        console.log('@@@ recordId: ' + recordId);
        component.set("v.showLoadingSpinner", true);
        
        console.log('Service Start....');
        var action = component.get("c.uploadContext");
        action.setParams({
            "jsonContext" : jsonstr,
            "uploadResourceId" : uploadResourceId,
            "recordId" : recordId,
            "sobjecttype" : sobjecttype,
        });
        action.setCallback(this, function(response) {
            console.log('Service Respond Back');
            var state = response.getState();
            
            if (state === "SUCCESS") {  
                console.log("Create Record Success");
                var responseValue = response.getReturnValue();
                console.log ('Success: '+JSON.stringify(responseValue));
                responseValue.forEach(function (record) {
                    console.log ('Record: '+record);
                });    
                
                component.set("v.showLoadingSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!",
                    message: "Price List has been uploaded successfully.",
                    type: "success"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "ERROR") {
                component.set("v.showLoadingSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Failure",
                    message: "Error for upload resources",
                    type: "error"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            //var dismissActionPanel = $A.get("e.force:closeQuickAction");
            //dismissActionPanel.fire();   
        }); 
        
        $A.enqueueAction(action);
    }     
})