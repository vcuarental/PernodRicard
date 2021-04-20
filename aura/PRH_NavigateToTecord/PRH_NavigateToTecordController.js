({
    openRecord : function (component, event, helper) {
        //Get value of record id
        var currentId = component.get("v.recordId",true);

        //Open record from id
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": currentId,
          "slideDevName": "related",
          "isredirect" : "true"
        });
        navEvt.fire();
    },                             
})