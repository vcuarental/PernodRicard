({
	getNote : function (cmp,recordid){
		var action = cmp.get("c.getNote");
        action.setParams({ "recordId" : recordid });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Ryan test');
                console.log(response.getReturnValue());
				cmp.set("v.note", response.getReturnValue());
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
					title: 'Get Note failed',
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
	},

	saveNote : function(cmp) {

		var action = cmp.get("c.upsertNote");
		action.setParams({ "recordId" : cmp.get("v.noteId"),"parentIdIn" :  cmp.get("v.visitId"),
							"titleIn" : cmp.find("TitleIn").get("v.value"), 
							"bodyIn" : cmp.find("ContentIn").get("v.value")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				console.log(response.getReturnValue().Id);
				cmp.set("v.noteId", response.getReturnValue().Id);
                swal.fire({
					title: 'Save Note',
					text: "Note Saved",
					confirmButtonColor: '#3085d6',
					cancelButtonColor: '#d33',
					confirmButtonText: 'Confirm'
				}).then((result) => {
					if(result.value) {
						$A.util.addClass(cmp.find('customSpinner'), 'slds-hide');
					}
				});
                
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
				$A.util.addClass(cmp.find('customSpinner'), 'slds-hide');
				swal.fire({
					title: 'Note save failed',
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