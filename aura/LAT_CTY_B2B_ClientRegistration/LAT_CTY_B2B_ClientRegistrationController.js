({
    doInit : function(component, event, helper) {
        console.log('entramos en init');
        
        component.find("caseRecordCreator").getNewRecord(
            "LAT_Case__c", // sObject type (entityAPIName)
            "0121i000000cC1J",      
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newCase");
                var error = component.get("v.newCaseError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    
                }
                else {
                    console.log("Record template initialized: " + rec.apiName);
                    component.set("v.showSpinner", false);
                }
            })
        );
        console.log('salimos del init');
    },
	handleLoad : function(component, event, helper) {
        helper.getAccountRegistrationRecordtypeId(component);
		component.set("v.showSpinner", false);
	},
    handleSubmit : function(component, event, helper) {
    },
    handleSuccess : function(component, event, helper) {
        component.set("v.showSpinner", false);
        component.set("v.saved", true);
    },
    handleSaveCase: function(component, event, helper) {
        component.set("v.showSpinner", true);
        console.log('en c.handleSaveCase');
        if(helper.validateCaseForm(component)) {
            component.set("v.simpleNewCase.LAT_Origin__c", "B2B Portal");
            console.log('Caso antes: ' + JSON.stringify(component.find("caseRecordCreator")));
            component.find("caseRecordCreator").saveRecord(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // record is saved successfully
                    component.set("v.showwCaseError", false);
					component.set("v.showSpinner", false);
                    component.set("v.saved", true);
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Success",
                        "message": "El caso fue creado correctamente, nuestro equipo de soporte se contactará con Ud. a la brevedad.",
                        "type": "success"
                    });
                    resultsToast.fire();
                    
                } else if (saveResult.state === "INCOMPLETE") {
                    // handle the incomplete state
                    console.log("User is offline, device doesn't support drafts.");
                    component.set("v.showSpinner", false);
                } else if (saveResult.state === "ERROR") {
                    // handle the error state
                    console.log('Problem saving contact, error: ' + 
                                 JSON.stringify(saveResult.error));
                    component.set("v.newCaseError", saveResult.error[0].message);
                    component.set("v.showCaseError", true);
                    component.set("v.showSpinner", false);
                    console.log('cargó?:'+component.get("v.newCaseError"));
                } else {
                    component.set("v.showSpinner", false);
                    console.log('Unknown problem, state: ' + saveResult.state +
                                ', error: ' + JSON.stringify(saveResult.error));
                }
            });
        }
    }
})