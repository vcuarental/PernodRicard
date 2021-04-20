({  
    init: function(component, event, helper) {
        component.set('v.baseUrl' , window.location.pathname.substring(0,window.location.pathname.indexOf('/s/') + 3));            

        var action = component.get('c.getUserEmailPreferences');
	    action.setCallback(this, function(response) {
	      var state = response.getState();
	      if ( state === 'SUCCESS' ) {
            var resp = response.getReturnValue();
	      	component.set("v.emailOptOut", resp);
	      }
	    });
	    $A.enqueueAction(action);
    },
    
    updateEmailOptions: function(component, event, helper) {
        console.info('updateEmailOptions');
        var emailValue = component.find("emailOptOut").get("v.checked");
        var action = component.get('c.updateUserEmailPreferences');
        action.setParams({
            "emailOptOut": component.get("v.emailOptOut")
        });
	    action.setCallback(this, function(response){
          console.info('updateEmailOptions - callback');
	      var state = response.getState();
            console.info(state);
			console.info(response.getError());
	      if ( state === 'SUCCESS' ) {
	      	console.info("emailSuccess");
	      }
	    });
	    $A.enqueueAction(action);
	},
    
    navigateTo: function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var url = selectedItem.dataset.url;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url,
            "isredirect" :true
        });
        urlEvent.fire();
    },
})