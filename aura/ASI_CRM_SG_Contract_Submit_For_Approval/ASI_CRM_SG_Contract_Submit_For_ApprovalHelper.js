({
	callExecute : function(component, helper, event) {
		var action = component.get("c.submitValidate");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
                action.setCallback(this, function(response){
            var data = response.getReturnValue();
            $A.get("e.force:closeQuickAction").fire();
            if(data){
                
                if(data.msg=='Success'){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "/apex/ASI_CRM_SG_ContractComparison_Page?BASE_CONTRACT_ID="+component.get("v.recordId")+"&CONTRACT_ONE="+data.lv
                    });
                    urlEvent.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "message": data.msg
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
            
        });$A.enqueueAction(action);
	}
})