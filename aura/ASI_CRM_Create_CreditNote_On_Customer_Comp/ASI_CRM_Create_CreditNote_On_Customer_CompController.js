({
	doInit : function(component, event, helper) {
		var action = component.get("c.getRecordTypes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('@#returned');
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.lstRecordTypes",response.getReturnValue());
                var res = response.getReturnValue();  
                // set default record type value to attribute    
                for(var i = 0; i < res.length; i++){
                    if(res[i].isDefault){
                        component.set("v.selectedRecord", res[i]);
                    }
                }
                if(res.length > 1){
                    component.set("v.isOpen", true);
                }else{
                    var a = component.get("c.RedirectToCredit");
                    $A.enqueueAction(a);
                }
                
            } 
            else if (state == "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please contact your administrator"
                });
                toastEvent.fire();
            }    
        });
        $A.enqueueAction(action);
    },
    
    onRadio : function(component,event,helper){
        var recId = event.getSource().get("v.text");
        component.set("v.selectedRecord" , recId);
    } ,
    
     RedirectToCredit : function(component,event,helper){
      //  alert(component.get("v.selectedRecord").recordTypeDevName);
      
        var recordTypeDevName = component.get("v.selectedRecord").recordTypeDevName;
        var customerId = component.get("v.recordId");
        var recordTypeId = component.get("v.selectedRecord").recordTypeId;
        $A.get("e.force:closeQuickAction").fire();
         var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:ASI_CRM_SG_RedirectCreditNote_Comp",
                        componentAttributes: {
                            // Attributes here.
                            "recordTypeId" : recordTypeId,
                            "recordTypeName" :recordTypeDevName,
                            "customerId" : customerId
                        }
                    });
                evt.fire(); 
        
     }
})