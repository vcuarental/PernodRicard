({
    doInit : function(component, event, helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.getContactInfo');
        action.setCallback(this, $A.getCallback(function (response) {
           var state = response.getState();
           if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                
                var contactInfo = response.getReturnValue();
                //  has open order with order items
                if (contactInfo.hasMultipleOrders) {
                    alert($A.get('$Label.c.ASI_CTY_CN_WS_Has_Multiple_Orders'));
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "/my-orders"
                    });
                    urlEvent.fire();
                } else if (contactInfo.hasOrderItems) {
                    // navigate to shopping cart page
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "/shopping-cart?orderId=" + contactInfo.orderId
                    });
                    urlEvent.fire();
                } else {
                    component.set("v.contactInfo",  response.getReturnValue());
                    component.set('v.showSpinner', false);
                    component.set('v.isLoaded',true);
                }
            component.set('v.showSpinner', false);
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

    gotoChooseProducts : function(component, event, helper) {
        helper.createOrderHelper(component, 'manual');
     },

     gotoUploadPage : function(component, event, helper) {
        helper.createOrderHelper(component, 'upload');
     }

})