({
    doInit : function(component, event, helper) {
        var action = component.get("c.validateContract");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
            $A.get("e.force:closeQuickAction").fire();
            if(data){
                if(data=='Success'){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/apex/ASI_CRM_SG_BuildContractPage?IS_EDIT=True&Id="+ component.get("v.recordId")
                    });
                    urlEvent.fire();
                }else if(data=='Success1'){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/apex/ASI_CRM_SG_ContractManageAll_Page?isReadOnly=False&Id="+component.get("v.recordId")
                    });
                    urlEvent.fire();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "message": data
                    });
                    toastEvent.fire();
                }
            }else{
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