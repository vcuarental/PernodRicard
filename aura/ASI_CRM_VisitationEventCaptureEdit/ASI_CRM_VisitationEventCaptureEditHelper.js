({
    getCurrentEvent : function(cmp) {
		
		var action = cmp.get("c.getEventCapture");
        action.setParams({ "recordId" : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Ryan test');
                console.log(response.getReturnValue());
                //console.log(response.getReturnValue().conVList);
				cmp.set("v.event", response.getReturnValue().currentEvent);
                cmp.set("v.photoList",response.getReturnValue().conVList);
                console.log(cmp.get("v.event.ASI_CRM_MY_ActivationEndTime__c"));
                cmp.set("v.event.ASI_CRM_MY_ActivationEndTime__c",this.timeMaker(cmp.get("v.event.ASI_CRM_MY_ActivationEndTime__c")/1000));
                cmp.set("v.event.ASI_CRM_MY_ActivationStartTime__c",this.timeMaker(cmp.get("v.event.ASI_CRM_MY_ActivationStartTime__c")/1000));
                //cmp.set("v.event.ASI_CRM_MY_ActivationStartTime__c",'19:30:00.000');
                console.log(cmp.get("v.event.ASI_CRM_MY_ActivationEndTime__c"));
                if(cmp.get("v.event").ASI_CRM_MY_Subbrand__c){
                var subBrand = {'label': cmp.get("v.event").ASI_CRM_MY_Subbrand__r.Name,
                                'value': cmp.get("v.event").ASI_CRM_MY_Subbrand__c};
                cmp.set("v.subBrand", subBrand);
                console.log(subBrand);
                }
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
					title: 'Get Event failed',
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
    getSubBrandRecordType : function(cmp) {
		
		var action = cmp.get("c.getSubBrandRecordType");      
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                //console.log(response.getReturnValue().conVList);			
                cmp.set("v.filterString", response.getReturnValue());
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
					title: 'Get Event failed',
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
    createEventCapture : function(cmp) {
		var action = cmp.get("c.createEventCapture");
		action.setParams({ "eventCaptureJson" : JSON.stringify(cmp.get("v.event")) });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				console.log('update successed');
                cmp.set("v.event", response.getReturnValue());
                cmp.set("v.event.ASI_CRM_MY_ActivationEndTime__c",this.timeMaker(cmp.get("v.event.ASI_CRM_MY_ActivationEndTime__c")/1000));
                cmp.set("v.event.ASI_CRM_MY_ActivationStartTime__c",this.timeMaker(cmp.get("v.event.ASI_CRM_MY_ActivationStartTime__c")/1000));
				swal.fire({
					title: 'Save Event',
					text: "Event Saved",
					confirmButtonColor: '#3085d6',
					cancelButtonColor: '#d33',
					confirmButtonText: 'Confirm'
				}).then((result) => {
					if(result.value) {
                        cmp.set("v.mode", 'Edit');
						$A.util.addClass(cmp.find('customSpinner'), 'slds-hide');
					}
				});
            }
            else {
                cmp.set("v.isCreated",false);
                console.log('Ryan test error');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
									errors[0].message);
									swal.fire({
										title: 'Save Event',
										text: errors[0].message,
										confirmButtonColor: '#3085d6',
										cancelButtonColor: '#d33',
										confirmButtonText: 'Confirm'
									}).then((result) => {
										if(result.value) {
										}
									});
                    }
				}
				$A.util.addClass(cmp.find('customSpinner'), 'slds-hide');
				swal.fire({
					title: 'Event save failed',
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
		console.log('Calling Server side');
		$A.getCallback(function() {
			$A.enqueueAction(action);
		})();
    },

    editEventCapture : function(cmp) {
		var action = cmp.get("c.updateEventCapture");
		action.setParams({ "eventCaptureJson" : JSON.stringify(cmp.get("v.event")) });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				console.log('update successed');
				
				swal.fire({
					title: 'Save Event',
					text: "Event Saved",
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
									swal.fire({
										title: 'Save Event',
										text: errors[0].message,
										confirmButtonColor: '#3085d6',
										cancelButtonColor: '#d33',
										confirmButtonText: 'Confirm'
									}).then((result) => {
										if(result.value) {
										}
									});
                    }
				}
				$A.util.addClass(cmp.find('customSpinner'), 'slds-hide');
				swal.fire({
					title: 'Event save failed',
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
		console.log('Calling Server side');
		$A.getCallback(function() {
			$A.enqueueAction(action);
		})();
    },
    
    timeMaker : function (totalSeconds) {
        console.log(totalSeconds);
        var second = totalSeconds % 60;
            var minutes = parseInt(totalSeconds / 60);
            var hours = parseInt(totalSeconds / 3600);
            if(minutes > 59)
            {
                minutes = parseInt((totalSeconds % 3600) / 60);
            }
            var secondString = second + "";
            var minutesString = minutes + "";
            var hoursString = hours + "";
            if (secondString.length < 2) {
                secondString = "0" + secondString;
            } else {
                secondString =  secondString;
            }
            
            if (minutesString.length < 2) {
                minutesString = "0" + minutesString;
            } else {
                minutesString =  minutesString;
            }
            
            if (hoursString.length < 2) {
                hoursString = "0" + hoursString;
            } else {
                hoursString =  hoursString;
            }

            var time = hoursString + ':' + minutesString + ':00.000';

            return time
    },

    getPhoto : function(cmp) {		
        var action = cmp.get("c.getPhoto");
        console.log('In helper');
        action.setParams({ "recordId" : cmp.get("v.event").Id });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Ryan test');
                console.log(response.getReturnValue());
                cmp.set("v.photoList", response.getReturnValue());
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
                    title: 'Get Photo failed',
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