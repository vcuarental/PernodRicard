({
	doInit : function(component, event, helper) {
		var action = component.get("c.checkPermission");
        action.setCallback(this, function(response){
           var data = response.getReturnValue();
            console.log(data);
            if(data){
                if(data==true){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "https://hkazap05.pernod-ricard-asia.com:443/analytics/saw.dll?GO&Action=Extract&Path=%2Fshared%2FPRSG%2FReport%2FOutlet%20P%26L%20See%20Through%20Report&P0=1&P1=eq&P2=%22ASI_TH_CRM_CONTRACT%22.%22ROWID%22&P3=%22"+component.get("v.recordId")+"%22"
                    });
                    urlEvent.fire();
                    
                }else{
                    $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "warning",
                    "message": "You are not allowed to access this report."
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                }
            }else{
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "warning",
                    "message": "You are not allowed to access this report."
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        });$A.enqueueAction(action);
	}
})