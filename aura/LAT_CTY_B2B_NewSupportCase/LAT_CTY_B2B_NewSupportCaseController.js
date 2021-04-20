({
	handleLoad : function(component, event, helper) {
		component.set("v.showSpinner", false);
	},
    handleSubmit : function(component, event, helper) {
       //We don't need to put basic validation here as that are handle by lightning:inputfield and recordEditForm
       //event.preventDefault(); use this to stop default flow
    },
    handleSuccess : function(component, event, helper) {
	    
	//Redirect to detail page on success
		/*var payload = event.getParams().response;
        var navService = component.find("navService");
    
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": payload.id,
                "objectApiName": component.get("v.sObjectName"),
                "actionName": "view"
            }
        }
        event.preventDefault();
        navService.navigate(pageReference);*/
        component.set("v.saved", true);
    },
    doInit: function(component, event, helper) {
        // Prepare a new record from template
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        helper.getAccountIdFromUser(component);
        component.find("caseRecordCreator").getNewRecord(
            "LAT_Case__c", // sObject type (entityAPIName)
            null,      
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newCase");
                var error = component.get("v.newCaseError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    console.log("Record template initialized: " + rec.apiName);
                }
            })
        );
    },
    handleSaveCase: function(component, event, helper) {
        component.set("v.processing", true);
        if(helper.validateCaseForm(component)) {
            component.set("v.simpleNewCase.LAT_Account__c", component.get("v.accountId"));
            component.set("v.simpleNewCase.LAT_Origin__c", "B2B Portal");
             console.log('Caso antes: ' + 
                                 JSON.stringify(component.find("caseRecordCreator")));
            component.find("caseRecordCreator").saveRecord(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // record is saved successfully
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Success",
                        "message": "El caso fue creado correctamente, nuestro equipo de soporte se contactará con Ud. a la brevedad.",
                        "type": "success"
                    });
                    resultsToast.fire();
                    component.set("v.simpleNewCase.LAT_Subject__c", "");
                    component.set("v.simpleNewCase.LAT_Description__c", "");
                    var address = '/s/contactsupport';
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": address,
                      "isredirect" :true
                    });
                    urlEvent.fire();
                    component.set("v.processing", false);
                } else if (saveResult.state === "INCOMPLETE") {
                    // handle the incomplete state
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    // handle the error state
                    console.log('Problem saving contact, error: ' + 
                                 JSON.stringify(saveResult.error));
                    component.set("v.processing", false);
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state +
                                ', error: ' + JSON.stringify(saveResult.error));
                }
            });
        }
    }
})