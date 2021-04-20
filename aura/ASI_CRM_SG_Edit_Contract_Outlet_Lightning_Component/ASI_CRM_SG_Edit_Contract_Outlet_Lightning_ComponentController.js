({
	doInit : function(component, event, helper) {
		var action = component.get("c.getRecord");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
                          var data = response.getReturnValue();
        if(data){
            if(data == 'Success'){
                var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/apex/ASI_CRM_SG_ContractManageAll_Page?id="+component.get("v.recordId")+"&isSimulation=false&isEditContractOutlets=true&isReadOnly=false"
                    });
                    urlEvent.fire();
            }else{
                 $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                         "type" : "warning",
                         "message": data
                	});
                    
                	toastEvent.fire();
            }
        }else{
                             $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                         "type" : "error",
                         "message": "unexpected error occurred"
                	});
                    
                	toastEvent.fire();
        }
                           
        }); $A.enqueueAction(action);
	}
})