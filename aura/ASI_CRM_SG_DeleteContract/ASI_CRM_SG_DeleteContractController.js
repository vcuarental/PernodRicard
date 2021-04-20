({
	doInit : function(component, event, helper) {
		var action = component.get("c.validateDelete");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var data = response.getReturnValue();
            if(data){
                if(data=='Success'){
                    var isConfirmed = window.confirm('Are you sure?');
                    if(isConfirmed == true) {
                        var action1 = component.get("c.deleteAction");
                        action1.setParams({
                            "recordId" : component.get("v.recordId")
                        });
                        action1.setCallback(this, function(response1){
                            var data1 = response1.getReturnValue();
                            if(data1){
                                if(data1=='redirect'){
                                    var urlEvent = $A.get("e.force:navigateToURL");
                                    urlEvent.setParams({
                                        "url": "/apex/ASI_CRM_SG_RollbackContract_Page?id="+component.get("v.recordId")
                                    });
                                    urlEvent.fire();
                                }else if(data1=='Success'){
                                    var homeEvent = $A.get("e.force:navigateToObjectHome");
                                    homeEvent.setParams({
                                        "scope": "ASI_TH_CRM_Contract__c"
                                    });
                                    homeEvent.fire();
                                }else{
                                    $A.get("e.force:closeQuickAction").fire();
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "type": "warning",
                                        "message": data
                                    });
                                    toastEvent.fire();
                                }
                            }else{
                                $A.get("e.force:closeQuickAction").fire();
                                 var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "error",
                                    "message": "Unexpected error occurred"
                                });
                                toastEvent.fire();
                            }
                        });
                        $A.enqueueAction(action1);
                    }else{
                        $A.get("e.force:closeQuickAction").fire();
                    }

                }else{
                     $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "message": data
                    });
                    toastEvent.fire();
                }
            }else{
                 $A.get("e.force:closeQuickAction").fire();
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Unexpected error occurred"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	}
})