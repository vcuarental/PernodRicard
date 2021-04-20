({
    createOrderHelper : function(component, type) {
        console.log('click');
        component.set('v.showSpinner', true);

        var action = component.get('c.saveSaleOrder');
        var contactJson = JSON.stringify(component.get('v.contactInfo'));
        action.setParams({'contactJson' : contactJson});
        action.setCallback(this, $A.getCallback(function (response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               console.log(response.getReturnValue());
               var orderId = response.getReturnValue();
               if (orderId == 'noTeamLeader') {
               	 alert($A.get('$Label.c.ASI_CTY_CN_WS_NO_Team_Leader'));
               	 component.set('v.showSpinner', false);
               	 return;
               }
               	if (type == 'upload') {
               		var contactInfo = component.get('v.contactInfo');
	                // Go to upload csv page
	                var urlEvent = $A.get("e.force:navigateToURL");
	                urlEvent.setParams({
	                  "url": "/upload-products?orderId=" + orderId + '&customerId=' + contactInfo.accountId
	                });
	                urlEvent.fire();
               	} else {
               		var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "/choose-product?orderId=" + orderId
                    });
                    urlEvent.fire();
               	}
                  
           } else if (state === "INCOMPLETE") {
               console.log('Status incomplete');
           } else if (state === "ERROR") {
               var errors = response.getError();
               if (errors) {
                   if (errors.length > 0) {
                       for (var i = 0; i < errors.length; i++) {
                           if (errors[0].pageErrors) {
                               if (errors[0].pageErrors.length > 0) {
                                   for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                       console.log('Internal server error: ' + errors[i].pageErrors[j].message);
                                   }
                               }
                           }
                           console.log(errors[i].message);
                           alert(errors[i].message);
                       }
                   }
               }
               else {
                   console.log('Internal server error');
               }
           }
        }));
       $A.enqueueAction(action);
     },
})