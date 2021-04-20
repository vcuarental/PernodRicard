({
    showModal : function(component) {      
        var modal = component.find("modal");
        $A.util.removeClass(modal, 'hideDiv');        
    },
    
    close : function(component) {
        console.log('close');
        $A.get("e.force:closeQuickAction").fire();
    },
    
    addImage : function(component) {
        console.log('addImage');
        
    },
    
    deleteImage : function(component, event, helper, recordId) {        
        var action = component.get("c.deleteLastImageApex");
        
        action.setParams({ 
            pRecordId : recordId,
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response.getReturnValue()', response.getReturnValue());
                if(response.getReturnValue() != null){
                    console.log('response.getReturnValue().ContentDocumentId', response.getReturnValue().ContentDocumentId);
                    component.set("v.urlImage", '/sfc/servlet.shepherd/document/download/' + response.getReturnValue());
                }
                else{
                    component.set("v.urlImage", '');
                }
                this.showToast(component, event, helper, 'La photo a bien été supprimée.');
                var appEvent = $A.get("e.c:RefreshImage");
                appEvent.fire();
            }
            else if (state === "INCOMPLETE") {
                console.log("State : INCOMPLETE");
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message delete : " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    updateContentDocumentTitle : function(component, event, helper, contentDocumentId){
        var action = component.get("c.updateContentDocumentTitleApex");
        
        action.setParams({ 
            pContentDocumentId : contentDocumentId,
        });
        
        action.setCallback(this, function(response) {
            console.log('response : ', response);
            var state = response.getState();
            console.log('state : ', state);
            if (state === "SUCCESS") {
                console.log('response.getReturnValue()', response.getReturnValue());
                if(response.getReturnValue() != null){
                    console.log('update ContentDocument.Title ', response.getReturnValue());
                }
                else{
                    console.log('update ContentDocument.Title ', response.getReturnValue());
                }
            }
            else if (state === "INCOMPLETE") {
                console.log("State : INCOMPLETE");
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message delete : " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(component, event, helper, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Succès!",
            "type" : "success",
            "message": msg
        });
        toastEvent.fire();
    }
    
    
})