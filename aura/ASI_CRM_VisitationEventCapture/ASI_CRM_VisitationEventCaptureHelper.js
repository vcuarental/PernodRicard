({
    getEventList : function(cmp) {
        var action = cmp.get("c.getEventList");
        action.setParams({ "recordId" : cmp.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('In helper');
                console.log(response.getReturnValue());
				cmp.set("v.eventList", response.getReturnValue());
                
            }
            else {
                console.log('Ryan test error');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
				}
				swal.fire({
					title: 'Get Event Capture failed',
					text: "Please contact administrator for the issue.",
					confirmButtonColor: '#3085d6',
					cancelButtonColor: '#d33',
					confirmButtonText: 'Confirm'
				}).then((result) => {
					if(result.value) {
					}
				});
            }
        });
        $A.enqueueAction(action);
	}
})