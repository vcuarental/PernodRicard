({
	doInit : function(component, event, helper) {
		var action = component.get("c.validateRecord");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        console.log(component.get("v.recordId"));
        action.setCallback(this, function(response){
           var data = response.getReturnValue(); 
            console.log('@#data'+data);
            console.log('@#data1'+response.getState());
             $A.get("e.force:closeQuickAction").fire();
            if(data){
                if(data =='Success'){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    var recordId = component.get("v.recordId");
                    urlEvent.setParams({
                      "url": '/apex/ASI_SubmitApprovalPage?id='+recordId
                    });
                    urlEvent.fire();
                }else{
                     var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                         "type" : "warning",
                         "message": data
                	});
                    
                	toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
       
	}
})