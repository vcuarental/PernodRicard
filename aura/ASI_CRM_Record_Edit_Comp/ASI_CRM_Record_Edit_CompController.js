({
	doRedirect : function(component, event, helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    },
    
    save : function(component, event, helper){
        component.set("v.isLoading","true");
        component.find("edit").get("e.recordSave").fire();              
    }, 
    handleDoneWaiting: function(component, event, helper){
        component.set("v.isLoading","false");
    },
    handleSuccess : function(component, event, helper){
        component.set("v.isLoading","false");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"Success",
            "title": "Success!",
            "message": "Record Saved Successfully"
        });
        
       
        toastEvent.fire();
        window.location.href = '/lightning/r/ASI_TH_CRM_Contract__c/'+component.get("v.recordId")+'/view' ;
    }
})