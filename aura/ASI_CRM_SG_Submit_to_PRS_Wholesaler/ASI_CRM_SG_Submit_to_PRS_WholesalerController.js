({
	doInit : function(component, event, helper) {
		var action = component.get("c.getRecord");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
             var data = response.getReturnValue();
           if(data){
                if(data.sor == null){
					$A.get("e.force:closeQuickAction").fire();                    
                     var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "message": data.msg
                    });
                    toastEvent.fire();
                }else{
                    var addNextDay = false;
                    if(data.msg == 'reminder'){
                        alert('Gentle Reminder PRS order cut off time is at 1pm, D+2 working days delivery (With no credit hold)');
                        if(data.sor.ASI_CRM_SG_Order_Date__c == $A.localizationService.formatDate(new Date(), "yyyy-MM-dd")){
                           addNextDay = true;
                        }
                        if(data.sor.ASI_CRM_Expected_Delivery_Date__c == $A.localizationService.formatDate(new Date(), "yyyy-MM-dd")) {
                            alert('Please choose an Expected Delivery Date to be at least one day later than today');
                        }
                    }
                    if (data.sor.ASI_CRM_Over_Credit_Limit__c == true){
                        alert("Please pay immediately to avoid order disruption.");
                    }
                    var action1 = component.get("c.updateRecord");
                    action1.setParams({
                        "addNextDay" : addNextDay,
                        "recordId" : component.get("v.recordId")
                    });
                    action1.setCallback(this, function(response){
                        var data1 = response.getReturnValue();
                        if(data1){
                            if(data1 == 'Success'){
                                 $A.get("e.force:closeQuickAction").fire();    
                                $A.get('e.force:refreshView').fire() ;
                            }else{
                                $A.get("e.force:closeQuickAction").fire();                    
                                 var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "error",
                                    "message": data1
                                });
                                toastEvent.fire();
                            }
                        }
                    });$A.enqueueAction(action1);
                }
           }
                  
        });$A.enqueueAction(action);
	}
})