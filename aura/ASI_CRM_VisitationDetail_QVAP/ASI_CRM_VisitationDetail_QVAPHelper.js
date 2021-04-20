({
	getCurrentVisitationPlanDetail : function(cmp,recordid) {
		console.log('Ryan helper');
		console.log(cmp);
		console.log('recordid')
		console.log(recordid);
		
		var action = cmp.get("c.getCurrentVisitationPlanDetail");
        action.setParams({ "recordId" : recordid });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Ryan test');
                console.log(response.getReturnValue().outletType);
				cmp.set("v.visitationPlanDetail", response.getReturnValue().currentVisitationPlanDetail);
				cmp.set("v.bottleLabel",response.getReturnValue().bottleLabel);
				cmp.set("v.custodyCondition",response.getReturnValue().custodyCondition);
				cmp.set("v.outletType",response.getReturnValue().outletType);
				cmp.set("v.ownActivations",response.getReturnValue().ownActivations);
				cmp.set("v.topOfStaffMind",response.getReturnValue().topOfStaffMind);
				cmp.set("v.familiarWithPRM",response.getReturnValue().familiarWithPRM);
				console.log(cmp.get("v.outletType"));
				console.log('ASI_MY_CRM_Bottle_Label__c');
				console.log(cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Bottle_Label__c"));
				//cmp.find("BottleLabel").set("v.value",cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Bottle_Label__c"));
				//cmp.find("CustodyCondition").set("v.value",cmp.get("v.visitationPlanDetail.ASI_MY_CRM_Custody_Condition__c"));
                
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
					title: 'Get QVAP failed',
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

	updateVisitationDetail : function(cmp,updateVisitationDetail) {
		var action = cmp.get("c.saveVisitationPlanDetail");
		action.setParams({ "updateVisitationDetailJson" : JSON.stringify(updateVisitationDetail) });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				console.log('update successed');
				
				swal.fire({
					title: 'Save QVAP',
					text: "QVAP Saved",
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
										title: 'Save QVAP',
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
					title: 'Visitation Detail update failed',
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
	}
})