({
	initCart: function (component, event) {

        var action = component.get("c.getOpenOrder");
        let _this = this;
        action.setCallback(this, function (response) {

            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isLoading", false);
                var order = response.getReturnValue();
                var comments = '';
                if(order.LAT_DSMessage1__c) {
                    comments = order.LAT_DSMessage1__c;
                    if(order.LAT_DSMessage2__c) {
                    	comments = comments + order.LAT_DSMessage2__c;  
                    }
                }
                component.set("v.comments", comments);
                component.set("v.order", order);
                if(order.LAT_Account__r){
                    component.set("v.accName", order.LAT_Account__r.Name);
                    component.set("v.accCNPJ", order.LAT_Account__r.CNPJ__c);
                    component.set("v.accAddress", order.LAT_Account__r.AddressLine1_AR__c);
                    component.set("v.accCorporateName", order.LAT_Account__r.Corporate_Name__c);
                }
                if (order.OpportunityLineItems__r) {
                    order.OpportunityLineItems__r.forEach(function (prod) {
                        if ( prod.LAT_Product__r) {
                            console.log('Stock en cajas : '+prod.LAT_Product__r.LAT_MX_ClientStock__c);
                            console.log('Stock en botellas : '+prod.LAT_Product__r.LAT_MX_StockPRM__c);
                            prod.LAT_Product__r.stockBottles = 20; // Dummy data to change with Javi field
                            prod.LAT_Product__r.stockBoxes = 1; // Dummy data to change with Javi field
                        }
                        // if(prod.LAT_UnitCode__c == 'BT') {
                        //     prod.isOverStock = (prod.LAT_QTTotal__c > prod.LAT_Product__r.stockBottles);
                        // } else {
                        //     prod.isOverStock = (prod.LAT_QTTotal__c > prod.LAT_Product__r.stockBoxes);
                        // }
                    });
                    
                    component.set("v.orderProducts", order.OpportunityLineItems__r);
                }
                // {! or( and(item.LAT_UnitCode__c == 'BT', greaterthanorequal(item.LAT_QTTotal__c, item.LAT_Product__r.stockBottles) ), and(item.LAT_UnitCode__c != 'BT', greaterthanorequal(item.LAT_QTTotal__c, item.LAT_Product__r.stockBoxes) ) ) ? ' my-row' : 'my-row stock'}
                //component.set("v.orderProducts", order.OpportunityLineItems__r);
                console.log('order', order);
                _this.calculatePrice(component);
                _this.validateStock(component);
                component.set('v.isLoading', false);

            }
        });
        $A.enqueueAction(action);
	}, 
    getMinimunOrderPrice: function (component, event) {
        console.log('en getCurrentMinimunPrice');
		var action = component.get("c.getMinimunPrice");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var price = a.getReturnValue();
                var minPrice = parseFloat(price);
                console.log('minPrice:'+minPrice);
                component.set('v.orderMin', minPrice);
            }
        });
        $A.enqueueAction(action);
    },
    getblockedClient : function(component){
        console.log('en getblockedClient');
		var action = component.get("c.getBlockedClient");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var enabled = a.getReturnValue();
                console.log('client blocked:' + enabled);
                component.set('v.showModalBlockedClient', enabled);
                component.set('v.blockedClient', enabled);
                
            }
        });
        $A.enqueueAction(action);
    },
    removeItem: function (component, event) {
		
        let currentItems = component.get('v.orderProducts');
        var selectedItem = event.currentTarget;
        var elementId = selectedItem.dataset.item;

        let newList = currentItems.filter(product => product.Id !=  elementId);    
        console.log(elementId);

        var action = component.get("c.deleteProductItem");
        let record = {
            sobjectType: 'LAT_OpportunityLineItem__c',
            Id: elementId
        };
        console.log(record);
        var toastEvent = $A.get("e.force:showToast");
        action.setParams({
            "record": record,
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {

                
                component.set('v.isLoading', false);
                toastEvent.setParams({
                    "title": "El producto se ha eliminado correctamente!",
                    "message": "El producto se ha eliminado correctamente!",
                    "type": "success"
                });
                
                toastEvent.fire();
                console.log(newList);
                component.set("v.orderProducts", newList);
                this.calculatePrice(component);
                this.validateStock(component);
                component.set('v.isLoading', false);
               
                
                
            } else {
                alert('error');
                component.set('v.isLoading', false);
                
            }
        });

        $A.enqueueAction(action);
        

    },
	validateStock: function (component) {
		// TO DO - run a validation to check if we have the shopping cart items with enough stock
        let orderProducts = component.get('v.orderProducts')
        if (orderProducts) {
            orderProducts.forEach(function (prod) {
                if(prod.LAT_UnitCode__c == 'BT') {
                    prod.isOverStock = (prod.LAT_QTTotal__c > prod.LAT_Product__r.LAT_MX_StockPRM__c);
                } else {
                    prod.isOverStock = (prod.LAT_QTTotal__c > prod.LAT_Product__r.LAT_MX_ClientStock__c);
                }
            });
            
            component.set("v.orderProducts", orderProducts);
        }

        let isValid = (orderProducts.filter(product => product.isOverStock ==  true).length > 0);
        component.set("v.stockIssues", isValid);

    },
    updateOrInsertLineItem: function (component, record, type, currentItems, obj) {

        console.log(record);
        console.log(type);

        if (type == 'insert') {
            var action = component.get("c.insertLineItem");
            action.setParams({
                record: record
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log();
                    console.log('Object Pirate');
                    // console.log('record despues del insert : ' + newLineItem);
                    obj.Id = response.getReturnValue();
                    currentItems.push(obj);
                    component.set('v.isLoading', false);
                    component.set('v.orderProducts', currentItems);
                    this.calculatePrice(component);
                } else {
                    console.log('error');
                    //alert('error');
                }
            });
            $A.enqueueAction(action);
            
        } else {
            var action = component.get("c.updateLineItem");
            action.setParams({
                record: record
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.isLoading', false);
                    var itemInserted = response.getReturnValue();
                } else {
                    console.log('error');
                    //alert('error');
                }
            });
            $A.enqueueAction(action);
            component.set('v.orderProducts', currentItems);
            this.calculatePrice(component);
            this.validateStock(component);
        }
    },
    sumQty: function (component, productId, unit, qty, itemId) {
        let currentItems = component.get('v.orderProducts');
        let record = null;
        currentItems.forEach(function (prod) {
            if (productId == prod.LAT_Product__c && unit == prod.LAT_UnitCode__c) {
                prod.LAT_QTTotal__c = prod.LAT_QTTotal__c + qty;
                record = {
                    sobjectType: 'LAT_OpportunityLineItem__c',
                    Id: itemId,
                    LAT_Quantity__c: parseInt(prod.LAT_QTTotal__c),
                };


            }
        });

        if (record) {
            this.updateOrInsertLineItem(component, record, 'update', currentItems);
        }

    },
    calculatePrice: function (component) {
        let currentItems = component.get('v.orderProducts');
        let price = 0;
        let iva = 0;
        let iibb = 0;
        currentItems.forEach(function (prod) {
            price += (prod.LAT_QTTotal__c * prod.LAT_UnitPrice__c);
            iva += (prod.LAT_QTTotal__c * prod.LAT_UnitIva__c);
            console.log('prod.LAT_UnitIva__c', prod.LAT_UnitIva__c);
            console.log('prod.LAT_UnitIIBB__c', prod.LAT_UnitIibb__c);
            iibb += (prod.LAT_QTTotal__c * prod.LAT_UnitIibb__c );
        });

        
        console.log('price', price);
        component.set("v.price", price);
        console.log('iva', iva);
        component.set("v.ivaPrice", iva);
        console.log('iibb', iibb);
        component.set("v.iibbPrice", iibb);

    },
	sendToJDE: function (component) {
        var action = component.get("c.integrateToJDE");
        var order = component.get('v.order') ;
        var comments = component.get('v.comments') ;
        console.log('entramos : ');
        console.log('orden : '+ JSON.stringify(order));
        var sentOrderId = order.Id;
        
        action.setParams({
            "oppId": sentOrderId,
            "comments": comments,
        });
        var toastEvent = $A.get("e.force:showToast");
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
				var actionEmail = component.get("c.sendConfirmationEmail");
                var orderResponse = response.getReturnValue();
                console.log('sentOrderId:' + sentOrderId);
                console.log('orderResponse:' + orderResponse);
                actionEmail.setParams({
                    "oppId": sentOrderId
                });
                actionEmail.setCallback(this, function (response) {
           			if (response.getState() === 'SUCCESS') {
                    }
                });
                $A.enqueueAction(actionEmail);
                
                component.set('v.isLoading', false);
                toastEvent.setParams({
                    "title": "Tu pedido fue enviado correctamente!",
                    "message": "Tu número de referencia es : "+order.LAT_NRCustomerOrder__c,
                    "type": "success"
                });
                console.log('antes de refrescar');
                toastEvent.fire();
                var address = '/s/nuevo-pedido?opencart=1';
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": address,
                  "isredirect" :true
                });
                var timer = component.get('v.timer');
				clearTimeout(timer);
                timer = setTimeout(function(){
                    console.info('tiramos');
                    urlEvent.fire();
                    clearTimeout(timer);
                    component.set('v.timer', null);
                }, 2000);
                
                console.log('despues de toast');
                
                
            } else {
                var errors = response.getError();
                var message = 'Unknown error';
                if (errors[0].pageErrors && Array.isArray(errors[0].pageErrors) && errors[0].pageErrors.length > 0) {
                    message = errors[0].pageErrors[0].message;
                }
                toastEvent.setParams({
                    "title": "Hubo un error al Integrar",
                    "type": "error",
                    "message": message
                });
                component.set('v.isLoading', false);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);

    },
	checkStockOnline: function (component) {
        component.set('v.isCheckingStock', true);
        var action = component.get("c.checkStockOnline");
        var order = component.get('v.order') ;
        var comments = component.get('v.comments') ;
        console.log('entramos a stockonline: ');
    	var self = this;
        action.setParams({
            "oppId": order.Id
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {

                var orderResponse = response.getReturnValue();
                console.log('orderResponse:' + orderResponse);
                if(orderResponse== 'true'){
                    console.log('Hay Stock!!');
                    self.sendToJDE(component);
                }else{

                    console.log('No Hay Stock!!');
                    self.initCart(component);
                }
                component.set('v.isCheckingStock', false);
                
            } else {
               
            }
        });
        $A.enqueueAction(action);
    },
    removeItemModal: function (component, elementId) {
		console.log('entramos en el helper');
        
        let currentItems = component.get('v.orderProducts');

        let newList = currentItems.filter(product => product.Id !=  elementId);    
        console.log(elementId);

        var action = component.get("c.deleteProductItem");
        let record = {
            sobjectType: 'LAT_OpportunityLineItem__c',
            Id: elementId
        };
        console.log(record);
        var toastEvent = $A.get("e.force:showToast");
        action.setParams({
            "record": record,
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                component.set('v.isLoading', false);
                toastEvent.setParams({
                    "title": "El producto se ha eliminado correctamente!",
                    "message": "El producto se ha eliminado correctamente!",
                    "type": "success"
                });
                
                toastEvent.fire();
                console.log(newList);
                component.set("v.orderProducts", newList);
                this.calculatePrice(component);
                this.validateStock(component);
                component.set('v.isLoading', false);
               
                
                
            } else {
                alert('error');
                component.set('v.isLoading', false);
                
            }
        });

        $A.enqueueAction(action);
       

    },
    setCommentsAndIntegrate: function (component){
        let _this = this;
        var order = component.get('v.order') ;
        var comments = component.get('v.comments') ;
        console.log('entramos : ');
        var action = component.get("c.setCommentarios");
        console.log('seguimos : ');
        action.setParams({
            "oppId": order.Id,
            "comments": comments,
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {

                var orderResponse = response.getReturnValue();
                console.log('orderResponse:' + orderResponse);
                _this.checkStockOnline(component);
            
            } else {
            }
        });
        $A.enqueueAction(action);
    },
    getAvailableCredit: function (component){
        var getAccountDetails = component.get('c.getAccountDetail');
	    getAccountDetails.setCallback(this,function(response){
	      	var state = response.getState();
	      	if ( state === 'SUCCESS' ) {
	       	var objString = response.getReturnValue();                
	       		if (objString) {
		       		var obj = JSON.parse(objString);
                    var available = obj.credLimit - obj.credDebt - obj.credOrderAppr;
                    console.log('available limit :' + available);
			       	component.set('v.availableCredit', available);
		      	}
	      	}
	    });
	    $A.enqueueAction(getAccountDetails);
    },
    assignQty: function (component, productId, unit, qty, itemId) {
        let currentItems = component.get('v.orderProducts');
        let record = null;
        currentItems.forEach(function (prod) {
            if (productId == prod.LAT_Product__c && unit == prod.LAT_UnitCode__c) {
                
                prod.LAT_QTTotal__c = parseInt(qty,10);
                record = {
                    sobjectType: 'LAT_OpportunityLineItem__c',
                    Id: itemId,
                    LAT_Quantity__c: parseInt(prod.LAT_QTTotal__c),
                };


            }
        });

        if (record) {
            this.updateOrInsertLineItem(component, record, 'update', currentItems);
        }

    }, 
})