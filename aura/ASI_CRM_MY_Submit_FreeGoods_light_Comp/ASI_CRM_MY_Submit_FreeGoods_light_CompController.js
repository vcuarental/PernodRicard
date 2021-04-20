({
    doInit : function(component, event, helper) {
        var action = component.get("c.getRecord");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
            if(data){
                if(data.ASI_CRM_Status__c=='Draft'){
                    if(data.ASI_CRM_MY_JDE_SO_Type__c == '' || data.ASI_CRM_MY_JDE_SO_Type__c == null){
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type" : "warning",
                            "message": "Please input the \"JDE SO Type\" first before you submit!"
                        });
                        
                        toastEvent.fire();
                    }else if(confirm('Are you sure to commit FOC? (Record will send to JDE later.)')==true){
                        var action1 = component.get("c.updateFGR");
                        action1.setParams({
                            "recordId" : component.get("v.recordId")
                        });
                            action1.setCallback(this, function(response){
                            var data = response.getReturnValue();
                                console.log('@#data'+data);
                            if(data){
                            if(data == 'Success'){
                            $A.get("e.force:closeQuickAction").fire();
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                            "type" : "confirm",
                            "message": "Succeeded! The FOC is submitted."
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                        
                    }else{
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type" : "warning",
                            "message": data
                        });
                        toastEvent.fire();
                    }
                }
            }) ;   $A.enqueueAction(action1);
                    }else{
                        $A.get("e.force:closeQuickAction").fire();
                    }
                           }else{
                           $A.get("e.force:closeQuickAction").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : "warning",
            "message": "Only \"Draft\" FOC can be submitted."
        });
        
        toastEvent.fire();
    }
}
 });
$A.enqueueAction(action);
}
})