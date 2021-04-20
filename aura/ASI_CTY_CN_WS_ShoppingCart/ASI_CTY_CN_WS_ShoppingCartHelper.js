({
    doInitHelper : function (component, event) {
    	let orderId = this.getJsonFromUrl().orderId;
        component.set('v.sorId', orderId);
    	console.log('orderId: ' + orderId);
    	var action = component.get('c.getSalesOrder');
    	
        action.setParams({'sorId' : orderId});
        action.setCallback(this, $A.getCallback(function (response) {
           var state = response.getState();
           if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var salesOrder = response.getReturnValue();
                console.log(salesOrder.orderItems);
                component.set('v.sor', salesOrder.sor);
                component.set('v.originOrderItems', salesOrder.orderItems);
                var orderItems = salesOrder.orderItems;
                var totalAmount = 0.0;
                var disAmount = 0.0;
                for (var i = orderItems.length - 1; i >= 0; i--) {
                    orderItems[i].actualPrice = orderItems[i].actualPrice.toFixed(2);
                    totalAmount += (orderItems[i].caseQty 
                                  * orderItems[i].packValue
                                  * orderItems[i].originPrice);
                    disAmount += orderItems[i].originDisAmount;
                }
                console.log(totalAmount);
                console.log(disAmount);
                // if (isNaN(totalAmount)) totalAmount = 0.0;
                // if (isNaN(disAmount)) disAmount = 0.0;
                component.set('v.totalAmount', totalAmount.toFixed(2));
                component.set('v.discountedAmount', disAmount.toFixed(2));
                var discountRate = totalAmount == 0 ? 0 : ((totalAmount-disAmount)/totalAmount) * 100;
                component.set('v.discountRate', discountRate.toFixed(2));
                component.set('v.showSpinner', false);
                this.renderPage(component);
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

    renderPage: function(component) {
        var records = component.get("v.originOrderItems"),
            pageNumber = component.get("v.page"),
            size = component.get("v.recordToDisply"),
            term = component.get("v.term");
        if(term != null && term != '' && term != undefined) {
            records = records.filter(item => (item.cnName.includes(term) || item.enName.includes(term)));
        }
        var pageRecords = records.slice((pageNumber-1)*size, pageNumber*size);
        component.set("v.orderItems", pageRecords);
        component.set("v.total", records.length);
        component.set("v.pages", Math.floor((records.length+(size-1))/size));
        if(pageRecords.length === 0){
            component.set("v.pageFirstIndex", 0);
        }else{
            component.set("v.pageFirstIndex", size * (pageNumber-1) + 1);
        }
        if(pageRecords.length === size){
            component.set("v.pageLastIndex", size * pageNumber);
        }else{
            component.set("v.pageLastIndex", size * (pageNumber-1) + pageRecords.length);
        }
    },


    getJsonFromUrl : function () {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
    }


})