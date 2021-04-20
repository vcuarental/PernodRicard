({
    loadProducts : function(component) {
    	var action = component.get("c.getUploadTemplate");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('state'+state);
            if (state === "SUCCESS") {
                
                var records = response.getReturnValue();
	            // console.log("records", records);
	            component.set("v.products", records);
                component.set('v.showSpinner', false);

            } else if (state === "INCOMPLETE") {

                console.log('Status incomplete');

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        
                                        console.log('Internal server error: ' + errors[i].pageErrors[j].message);

                                    }
                                }
                            }
                            console.log(errors[i].message);
                            alert(errors[i].message);
                            component.set('v.showSpinner', false);
                        }
                    }
                }
                else {
                    console.log('Internal server error');
                }
            }
        });
        $A.enqueueAction(action);
    },
})