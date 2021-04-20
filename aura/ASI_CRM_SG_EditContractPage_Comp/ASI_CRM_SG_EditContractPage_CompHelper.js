({
    initializeData : function(component, event) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        if(component.get("v.recordTypeLabel")){
            if(component.get("v.recordTypeLabel").includes('Read-Only')){
                component.set("v.isNewReadOnly","true");    
            }
            
        }
        if(component.get("v.recordId")){
            component.set("v.isEdit","true"); 
            
        }
        var action = component.get("c.initializeContract");
        action.setParams({ recordId : component.get("v.recordId"),
                          recordTypeId : component.get("v.recordTypeId")
                         });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                console.log("From server: " + JSON.stringify(response.getReturnValue()));
                var resp = response.getReturnValue();
                component.set("v.isNewReadOnly",resp.isNewReadOnly);
                component.set("v.isEdit",resp.isEdit);
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        //  $A.enqueueAction(action);
    },
    handleCancel : function(component,event){
        var navService = component.find("navService");
        console.log('@#'+navService);
        var pageReference;
        if(component.get("v.isEdit")=="true"){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId")
            });
            navEvt.fire();
            return;
        }
        else if(component.get("v.outletId") == null){
            pageReference = {
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'ASI_TH_CRM_Contract__c',
                    actionName: 'home'
                }
            };
        }
            else {
            pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    recordId : component.get("v.outletId"),
                    objectApiName: "ASI_CRM_AccountsAdditionalField__c",
                    actionName: "view"
                }
            };
        }
        component.set("v.pageReference", pageReference); 
        event.preventDefault();
        navService.navigate(pageReference);
    },
    handleSuccessRedirect : function(component,event){
        if(component.get("v.isEdit")=="true"){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId")
            });
            navEvt.fire();
        }else{
            var navService = component.find("navService");
            console.log('@#'+navService);
            console.log('after save recordId'+event.getParams().response.id);
            var pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    recordId : event.getParams().response.id,
                    objectApiName: "ASI_CRM_AccountsAdditionalField__c",
                    actionName: "view"
                }
            };
            component.set("v.pageReference", pageReference); 
            event.preventDefault();
            navService.navigate(pageReference);
        }
        
    }
})