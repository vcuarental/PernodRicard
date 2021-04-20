({
    showPDF : function(component, event, helper) {     
        
        var eUrl= $A.get("e.force:navigateToURL");
        var url_instance = '/apex/GRP_CC_deep_dive_PDF?id=';
        var btnId = event.getSource().getLocalId();
        console.log('component '+ component)
        url_instance += component.get("v.recordId");
        eUrl.setParams({
            "url": url_instance 
        });
        $A.get("e.force:closeQuickAction").fire();
                
        window.open(url_instance,'_blank');
        
    },
    
    savePDF : function(component, event, helper) {
        var action = component.get("c.savePDFFile");
        var recordId = component.get("v.recordId");
        action.setParams({
            "recordId": recordId,
            "typeObj" : "deepdive"
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast"); 
                toastEvent.setParams({ 
                    type: 'success',
                    title: 'Success!', 
                    message: 'The report was saved.'
                }); 
                toastEvent.fire();  
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }else{
                console.log('Problem with AttachPdF, response state : '+state);
            }
        });
        $A.enqueueAction(action);
        
    }
})