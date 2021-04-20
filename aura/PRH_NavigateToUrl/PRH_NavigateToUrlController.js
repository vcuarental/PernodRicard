({
    gotoURL : function (component, event, helper) {
        //Goto Iconic Home page
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
          "url": "/006/o"
        });
        navEvt.fire();
    },                             
})