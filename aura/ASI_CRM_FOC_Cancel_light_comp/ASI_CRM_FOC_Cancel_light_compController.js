({
  doInit: function(component, event, helper) {
    var action = component.get("c.getRecord");
    action.setParams({
      recordId: component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
      var data = response.getReturnValue();

      if (data) {
        var crm_status = data.ASI_CRM_Status__c;
        if (
          data.ASI_CRM_Status__c != "Submit for Cancel" &&
          data.ASI_CRM_Status__c != "Cancelled"
        ) {
          var isAutoRequest =
            data.ASI_CRM_Auto_Generation__c == true ? true : false;
          var msg_str =
            isAutoRequest == true
              ? "Are you sure to cancel the request? You may need to unlock offtake and re-generate for update."
              : "Are you sure to cancel the request?";
          if (confirm(msg_str) == true) {
            var action1 = component.get("c.updateStatus");
            action1.setParams({
              recordId: component.get("v.recordId"),
              status: data.ASI_CRM_Status__c
            });
            action1.setCallback(this, function(response) {
              var data1 = response.getReturnValue();
              if (data1) {
                $A.get("e.force:closeQuickAction").fire();
                if (data1 == "Success") {
                  var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                    type: "confirm",
                    message:
                      crm_status == "Draft"
                        ? "Cancelled successfully!"
                        : "Cancelled successfully! You may need to inform responsible person for the rest of the process."
                  });
                  toastEvent.fire();
                  $A.get("e.force:refreshView").fire();
                } else {
                  var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                    type: "warning",
                    message: data1
                  });
                  toastEvent.fire();
                }
              }
            });
            $A.enqueueAction(action1);
          } else {
            $A.get("e.force:closeQuickAction").fire();
          }
        } else if (crm_status == "Submit for Cancel") {
          if (confirm("Are you sure to cancel the request?") == true) {
            var action1 = component.get("c.checkAccess");
            action1.setCallback(this, function(response) {
              var data2 = response.getReturnValue();
              if (data2) {
                if (data2 == "true") {
                  var action2 = component.get("c.updateStatus2");
                  action2.setparams({
                    recordId: component.get("v.recordId")
                  });
                  action2.setCallback(this, function(response) {
                    var data3 = response.getReturnValue();

                    if (data3) {
                      $A.get("e.force:closeQuickAction").fire();
                      if (data3 == "Success") {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                          type: "confirm",
                          message: "Cancelled successfully!"
                        });
                        toastEvent.fire();
                        $A.get("e.force:refreshView").fire();
                      } else {
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                          type: "warning",
                          message: data1
                        });
                        toastEvent.fire();
                      }
                    }
                  });
                  $A.enqueueAction(action2);
                } else {
                  $A.get("e.force:closeQuickAction").fire();
                  var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                    type: "warning",
                    message:
                      "The request has been submitted for cancel. Please inform responsible person for the rest of the process."
                  });
                  toastEvent.fire();
                }
              }
            });
            $A.enqueueAction(action1);
          }
        } else {
          $A.get("e.force:closeQuickAction").fire();
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "warning",
            message: "The request has been cancelled already."
          });
          toastEvent.fire();
        }
      }
    });
    $A.enqueueAction(action);
  }
});