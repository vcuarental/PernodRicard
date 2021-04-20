({
    checkIfCheckoutIsEnabled : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objSiteStatus = null;
       
        objControllerAction = objComponent.get("c.retrieveSiteStatus"); 

        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            debugger;
            if (objComponent.isValid() && strState === "SUCCESS") {
                objSiteStatus = objResponse.getReturnValue();
                
                if(objSiteStatus !== undefined && objSiteStatus !== null && objSiteStatus.IsBlocked !== undefined && objSiteStatus.IsBlocked !== null ) {
                    objComponent.set('v.objSiteStatus', objSiteStatus);
                } else {
                    console.log('checkIfCheckoutIsEnabled[Ha ocurrido un error.]');
                }
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
    }
})