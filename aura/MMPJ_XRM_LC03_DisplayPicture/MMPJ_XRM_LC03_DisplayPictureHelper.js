({
    
    getLastImage : function(component, event, helper, recordId) {
        
        var action = component.get("c.getLastImageApex");
        
        action.setParams({ 
            pRecordId : recordId,
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {                
                if(response.getReturnValue() != null){
                    console.log('response.getReturnValue()', response.getReturnValue());
                    component.set("v.urlImage", '/sfc/servlet.shepherd/document/download/' + response.getReturnValue());
                }
                else{
                    component.set("v.urlImage", '');
                }
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
                console.log("State : INCOMPLETE");
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
})