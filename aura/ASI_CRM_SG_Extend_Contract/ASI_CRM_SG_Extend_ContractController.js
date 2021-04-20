({
	doInit : function(component, event, helper) {
		var action = component.get("c.validateExtend");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
           var data = response.getReturnValue();
            console.log('@#'+data);
            if(data){
               
                if(data == 'Success'){
                   /*  var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "/flow/ASI_SG_Extend_Contract_Period?ASI_CRM_ContractID="+component.get("v.recordId")+"&retURL="+component.get("v.recordId")
                    });
                    urlEvent.fire();*/
                    var flow = component.find("flowId");
                    var inputVariables = [{name : "ASI_CRM_ContractID",type : "SObject", value: component.get("v.recordId")}];
                    flow.startFlow("ASI_SG_Extend_Contract_Period",inputVariables);
                }else{
                     $A.get("e.force:closeQuickAction").fire(); 
                     var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "message": data
                    });
                    toastEvent.fire();
                }
            }
        });$A.enqueueAction(action);
	},
     handleStatusChange : function (component, event) {
        console.log('@#1'+event.getParam("status"));
        if(event.getParam("status") === "FINISHED") {
            console.log('it is called');
            var urlEvent = $A.get("e.force:navigateToSObject");
            urlEvent.setParams({
               "recordId": component.get("v.recordId"),
                "isredirect": "true"
            });
             urlEvent.fire();
        }
    }
})