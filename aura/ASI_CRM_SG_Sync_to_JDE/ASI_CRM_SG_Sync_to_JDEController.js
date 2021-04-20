({
	doInit : function(component, event, helper) {
		var action= component.get("c.updateCustomer");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
           var data = response.getReturnValue();
            $A.get("e.force:closeQuickAction").fire();
            console.log('@#'+data);
            if(data){
                if(data == 'Success'){
                       
                     $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                         "type" : "success",
                         "message": 'success!'
                	});
                    
                	toastEvent.fire();
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