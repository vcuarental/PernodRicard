({
    doInit : function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.doInitHelper(component, event);
    },

    renderPage : function(component, event, helper) {
        helper.renderPage(component);
    },

    goToProductDetail :  function(component, event, helper) {
      var productId = event.target.name;
      var orderId = component.get('v.sorId');
        var urlEvent = $A.get("e.force:navigateToURL");
          urlEvent.setParams({
            "url": "/product-detail?orderId=" + orderId + '&productId=' + productId
          });
          urlEvent.fire();
    },

    qtyChanged : function (component, event){
        console.log('qty changed');
        console.log(event);
        var qtyValue = event.target.value == '' ? 0 : event.target.value;
        var key = event.currentTarget.dataset.key;
        var orderItems = component.get('v.orderItems');
        var originOrderItems = component.get('v.originOrderItems');
        orderItems[key].caseQty = parseInt(qtyValue);
        orderItems[key].freeQty = orderItems[key].freeQty == null ? 0 : orderItems[key].freeQty;
        if (orderItems[key].buyx != null)  {
            orderItems[key].freeQty = Math.floor(orderItems[key].caseQty/orderItems[key].buyx) * orderItems[key].gety;
            orderItems[key].promotionAmount = orderItems[key].caseQty == 0 ? 0 : (orderItems[key].freeQty * orderItems[key].originPrice/(orderItems[key].freeQty + orderItems[key].caseQty)).toFixed(2);
        }
        if (orderItems[key].promotionDiscount != null && orderItems[key].buyx == null) {
            orderItems[key].promotionAmount = orderItems[key].caseQty == 0 ? 0 : (orderItems[key].originPrice * orderItems[key].promotionDiscount/100 * orderItems[key].caseQty/(orderItems[key].freeQty + orderItems[key].caseQty)).toFixed(2);
        }

        // Only Discount OR Promotion free and Discount
        if ((orderItems[key].freeQty != 0 && orderItems[key].promotionDiscount != null && orderItems[key].discount != null)
            || 
            (orderItems[key].freeQty == 0 && orderItems[key].promotionDiscount == null && orderItems[key].discount != null)) {
            orderItems[key].originDisAmount = (parseInt(qtyValue) * orderItems[key].originPrice * orderItems[key].packValue * (1 - orderItems[key].discount/100));
        // Promotion Discount and Discount
        } else if (orderItems[key].freeQty == 0 && orderItems[key].promotionDiscount != null && orderItems[key].discount != null) {
            orderItems[key].originDisAmount = (parseInt(qtyValue) * orderItems[key].originPrice * orderItems[key].packValue * (1 - orderItems[key].promotionDiscount/100) * (1 - orderItems[key].discount/100));
        // Only promotion discount 
        } else if (orderItems[key].freeQty == 0 && orderItems[key].promotionDiscount != null && orderItems[key].discount == null) {
            orderItems[key].originDisAmount = (parseInt(qtyValue) * orderItems[key].originPrice * orderItems[key].packValue * (1 - orderItems[key].promotionDiscount/100));
        } else {
            orderItems[key].originDisAmount = (parseInt(qtyValue) * orderItems[key].originPrice * orderItems[key].packValue);
        }
        orderItems[key].bottleQty = parseInt(qtyValue) * orderItems[key].packValue;
       
        orderItems[key].actualPrice = orderItems[key].caseQty == 0 ? orderItems[key].originPrice.toFixed(2) : (orderItems[key].originDisAmount/(orderItems[key].freeQty + orderItems[key].caseQty)/orderItems[key].packValue).toFixed(2);
        originOrderItems.forEach(orderItem => {
                if (orderItem.itemId == orderItems[key].itemId) {
                    orderItem.originDisAmount = orderItems[key].originDisAmount;
                }
            }
        );
        
        console.log(originOrderItems);
        
        var totalAmount = 0.0;
        var discountedAmount = 0.0;
        for (var i = originOrderItems.length - 1; i >= 0; i--) {
            totalAmount += (originOrderItems[i].caseQty
                            * originOrderItems[i].packValue
                            * originOrderItems[i].originPrice);
            discountedAmount += parseFloat(originOrderItems[i].originDisAmount);
        }
        orderItems[key].disAmount = (orderItems[key].originDisAmount).toFixed(2);
        
        component.set('v.orderItems', orderItems);
        component.set('v.originOrderItems', originOrderItems);
        component.set('v.totalAmount', totalAmount.toFixed(2));
        component.set('v.discountedAmount', discountedAmount.toFixed(2));
        var discountRate = (totalAmount == 0 || totalAmount - discountedAmount < 0)  ? 0 : ((totalAmount - discountedAmount)/totalAmount) * 100;
        component.set('v.discountRate', discountRate.toFixed(2));
    },

    deleteItem : function (component, event, helper){
        console.log('delete click');
        if (confirm('确认删除该产品？')){
            component.set('v.showSpinner', true);
            var itemId = event.currentTarget.dataset.id;
            var action = component.get('c.deleteOrderItem');
            action.setParams({'sorItemId' : itemId});
            action.setCallback(this, $A.getCallback(function (response) {
               var state = response.getState();
               if (state === "SUCCESS") {
                   var delId = response.getReturnValue();
                    console.log(delId);
                   var sorItems = component.get('v.originOrderItems');
                   for (var i = sorItems.length - 1; i >= 0; i--) {
                     if (sorItems[i].itemId == delId) {
                        sorItems.splice(i,1);
                     }
                   }
                    var totalAmount = 0.0;
                    var discountedAmount = 0.0;
                    for (var i = sorItems.length - 1; i >= 0; i--) {
                        totalAmount += (sorItems[i].caseQty
                                        * sorItems[i].packValue
                                        * sorItems[i].originPrice);
                        discountedAmount += parseFloat(sorItems[i].originDisAmount);
                    }
                   
                   component.set('v.originOrderItems', sorItems);
                   component.set('v.orderItems', sorItems);
                   // if (isNaN(totalAmount)) totalAmount = 0.0;
                   // if (isNaN(discountedAmount)) discountedAmount = 0.0;
                   component.set('v.totalAmount', totalAmount.toFixed(2));
                    component.set('v.discountedAmount', discountedAmount.toFixed(2));
                    var discountRate = (totalAmount == 0 || totalAmount - discountedAmount < 0) ? 0 : ((totalAmount - discountedAmount)/totalAmount) * 100;
                    component.set('v.discountRate', discountRate.toFixed(2));
                   helper.renderPage(component);
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
                           }
                       }
                   }
                   else {
                       console.log('Internal server error');
                   }
               }
            }));
           $A.enqueueAction(action);
        }
    },

    showMessage : function (component, event, helper){
        console.log('showMessage');
        var key = event.currentTarget.dataset.key;
        console.log(key);
        var orderItems = component.get('v.orderItems');
        orderItems[key].showMessage = true;
        component.set('v.orderItems', orderItems);
    },

    hiddeMessage : function (component, event, helper){
        console.log('hiddeMessage');
        var key = event.currentTarget.dataset.key;
        var orderItems = component.get('v.orderItems');
        orderItems[key].showMessage = false;
        component.set('v.orderItems', orderItems);
    },

    addOrderItems : function (component, event, helper) {
        var orderId = component.get('v.sorId');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/choose-product?orderId=" + orderId
        });
        urlEvent.fire();
    },

    submitOrder : function (component, event, helper){
        console.log('saveSor click');
        if (!confirm('确认提交该订单吗？')) {
           return;
        }
        component.set('v.showSpinner', true);
        var sor = component.get('v.sor');
         if (sor.ASI_CRM_CN_Contact_Person__c == null 
              || sor.ASI_CRM_CN_Tel_Mobile__c == null 
              || sor.ASI_CRM_CN_Address__c == null) {
          alert('姓名，电话，收货地址 不能为空');
          component.set('v.showSpinner', false);
          return;
        }
        sor.ASI_KOR_Sales_Amount__c = component.get('v.discountedAmount');
        var orderItems = component.get('v.originOrderItems');
        if (orderItems.length == 0) {
          alert('该订单没有选择产品，不能提交订单。');
          component.set('v.showSpinner', false);
          return;
        }
        var errorItems = [];
        // var errorMsg = '';
        for (var i = orderItems.length - 1; i >= 0; i--) {
            if (orderItems[i].caseQty * orderItems[i].packValue > orderItems[i].maxBottleQty) {
                errorItems.push(orderItems[i].cnName);
            }
            console.log(orderItems[i].caseQty);
            if (isNaN(orderItems[i].caseQty) || orderItems[i].caseQty <= 0) {
                alert('该产品：' + orderItems[i].cnName + ' 数量无效。');
                component.set('v.showSpinner', false);
                return;
            }
            
            // mdy by Bls(wzq) Increase the number of minimum order boxes begin
            if(null != orderItems[i].miniOrderQty && orderItems[i].miniOrderQty >1 )
            {
               if( parseInt(orderItems[i].caseQty) %  parseInt(orderItems[i].miniOrderQty) != 0 )
               {
                  alert(orderItems[i].cnName + '的最小下单量为' + orderItems[i].miniOrderQty +'箱或'+ orderItems[i].miniOrderQty +'的倍数.');
                  component.set('v.showSpinner', false);
                  return;
               }
            }
            // mdy by Bls(wzq) Increase the number of minimum order boxes begin
        }
        if (errorItems.length > 0) {
            alert('以下产品超过最大可下单瓶数：' + JSON.stringify(errorItems));
            component.set('v.showSpinner', false);
            return;
        }

        var order = {'sor' : sor, 'orderItems' : orderItems};
        var action = component.get('c.saveOrder');
        action.setParams({'orderJson' : JSON.stringify(order)});
        action.setCallback(this, $A.getCallback(function (response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               component.set('v.showSpinner', false);
               var orderId = component.get('v.sorId');
               var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/order-detail?orderId=" + orderId
                });
                urlEvent.fire();
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
    }

})