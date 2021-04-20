({
    loadSalesOrder : function(component, orderId) {
        var action = component.get('c.getSalesOrder');
        // var orderId = component.get('v.recordId');
        // if (orderId == null) {
        //   orderId = this.getJsonFromUrl().orderId;
        // }
        action.setParams({'sorId' : orderId});
        action.setCallback(this, $A.getCallback(function (response) {
           var state = response.getState();
           if (state === "SUCCESS") {
                console.log('salesOrder');
                console.log(response.getReturnValue());
               component.set("v.salesOrder",  response.getReturnValue());

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
                           component.set('v.showSpinner', false);
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

    loadOrderItems : function(component, orderId) {
        var action = component.get('c.getOrderItems');
        // var orderId = component.get('v.recordId');
        // if (orderId == null) {
        //   orderId = this.getJsonFromUrl().orderId;
        // }
        action.setParams({'sorId' : orderId});
        action.setCallback(this, $A.getCallback(function (response) {
           var state = response.getState();
           if (state === "SUCCESS") {
                console.log('orderItemList');
                console.log(response.getReturnValue());
               component.set("v.orderItemList",  response.getReturnValue());
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
                           component.set('v.showSpinner', false);
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

    loadOrderTOV : function(component, event, helper) {
        var rcdId = component.get('v.recordId');
        var recordType = 'SOR';
        if (rcdId == null) {
          rcdId = this.getJsonFromUrl().orderId;
        } else {
            recordType = 'Notification';
        }

        if (recordType == 'SOR') {
            this.loadForSOR(component, rcdId, '');
            this.loadSalesOrder(component, rcdId);
            this.loadOrderItems(component, rcdId);
        } else {
            this.loadForNotification(component, rcdId);
        }
    },

    loadForSOR : function (component, orderId, tovId) {
        var action = component.get('c.getOrderTOVs');
        action.setParams({'sorId' : orderId});
        action.setCallback(this, $A.getCallback(function (response) {
           var state = response.getState();
           if (state === "SUCCESS") {
                console.log('loadOrderTOV');
                console.log(response.getReturnValue());
               component.set("v.tovList",  response.getReturnValue());
               var tovTabId;
               if (tovId == '') {
                  tovTabId = this.getJsonFromUrl().tovTabId;
               } else {
                  tovTabId = tovId;
               }
               
               var deliveryTabId = this.getJsonFromUrl().deliveryTabId;
               if (tovTabId === undefined) {
                  tovTabId = 'sumTab';
               }
               component.set('v.tovTabId', tovTabId);
               component.set('v.deliveryTabId', deliveryTabId);

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
                           component.set('v.showSpinner', false);
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

    loadForNotification : function (component, notifId) {
        var action = component.get('c.getSalesOrderId');
        action.setParams({'notifId' : notifId});
        action.setCallback(this, $A.getCallback(function (response) {
           var state = response.getState();
           if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var resultMap = response.getReturnValue();
                var orderId = resultMap.orderId;
                var tovId = resultMap.tovId;
                this.loadForSOR(component, orderId, tovId);
                this.loadSalesOrder(component, orderId);
                this.loadOrderItems(component, orderId);
                // if (resultMap.tovId != null) {
                //     var tovId = resultMap.tovId;
                //     component.set('v.tovTabId', tovId);
                // } else {
                //     component.set('v.tovTabId', 'sumTab');
                // }
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
                           component.set('v.showSpinner', false);
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

    getJsonFromUrl : function () {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
    },

    downloadSORDetail: function (component) {
        var action = component.get("c.getSORDetail");
        var orderId = this.getJsonFromUrl().orderId;
        console.log('orderId' + orderId);
        action.setParams({'sorId' : orderId});
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (state === "SUCCESS") {
                var sorDetail = result.getReturnValue();
                console.log('sorDetail'+sorDetail);
                
                let currentDate = new Date();
                console.log('currentDate'+currentDate);
                let sor =  component.get("v.salesOrder");
                let csvContent = sorDetail.map(e => e.join(",")).join("\n");
                var encodedUri = encodeURI(csvContent);
                var universalBOM = "\uFEFF";
                var link = document.createElement("a");
                link.setAttribute('href', 'data:text/csv; charset=utf-8,' + encodeURIComponent(universalBOM+csvContent));
                link.setAttribute("download", sor.Name + ".csv");
                document.body.appendChild(link); // Required for FF

                link.click();

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
                        }
                    }
                }
                else {
                    console.log('Internal server error');
                }
            }
        });
        $A.enqueueAction(action);
    },
    
})