({
    listBlocks : function(objComponent, strFrom, strTo, boolEnabled) {
        var objControllerAction = null;
        var strState = null;
        var arrBlocks = null;
       
        objControllerAction = objComponent.get("c.listBlocks"); 
        objControllerAction.setParams( {
            'strFrom': strFrom,
            'strTo': strTo,
            'boolEnabled': boolEnabled
        });
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();

            if (objComponent.isValid() && strState === "SUCCESS") {
                arrBlocks = objResponse.getReturnValue();
                
                objComponent.set('v.blocks', arrBlocks);
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
    }
})