({
    changeStatus : function(objComponent, strRecordId, boolStatus) {
        var objControllerAction = null;
        var strState = null;
        var objFiredEvent = null;
        objControllerAction = objComponent.get("c.updateStatus"); 
        objControllerAction.setParams( {
            'strRecordId': strRecordId,
            'boolActive': boolStatus
        });
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            if (objComponent.isValid() && strState === "SUCCESS") {
                objFiredEvent = $A.get("e.c:LAT_CTY_B2B_Block_Refresh_Event");
                objFiredEvent.fire();
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
    }
})