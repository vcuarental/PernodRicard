({
    initCart: function (component, event) {
        var action = component.get("c.getOpenOrder");
        let _this = this;

        action.setCallback(this, function (response) {
            let state = response.getState();

            if (state === "SUCCESS") {
                var order = response.getReturnValue();
                component.set("v.isLoading", false);            
                component.set("v.order", order);

                if (order.OpportunityLineItems__r) {
                    order.OpportunityLineItems__r.forEach(function (prod) {
                        if ( prod.LAT_Product__r) {
                            prod.LAT_Product__r.stockBottles = 20; // Dummy data to change with Javi field
                            prod.LAT_Product__r.stockBoxes = 1; // Dummy data to change with Javi field
                        }
                    });
                    component.set("v.orderProducts", order.OpportunityLineItems__r);
                }

                _this.calculatePrice(component);
                _this.validateStock(component);
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },
	getOrderTakingEnabled: function (component, event) {
        var action = component.get("c.getChartBlocked");
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var enabled = a.getReturnValue();
                component.set('v.orderTakingBlocked', enabled);
            }
        });
        $A.enqueueAction(action);
    },	
    getblockedMessage: function (component, event) {
		var action = component.get("c.getBlockingComments");
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var blockMessage = a.getReturnValue();
                component.set('v.blockedMessage', blockMessage.LAT_Value__c);
            }
        });

        $A.enqueueAction(action);
    },	
    getMinimunOrderPrice: function (component, event) {
		var action = component.get("c.getMinimunPrice");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var price = a.getReturnValue();
                console.log('getMinimunOrderPrice [ price : ' + price + ']');
                var minPrice = parseFloat(price);
                component.set('v.orderMin', minPrice);
            }
        });
        $A.enqueueAction(action);
    },
    shouldOpenCart: function (component) {
        var url = decodeURIComponent(window.location.search.substring(1));
        var urlParams = url.split('&');
        var reorderParam;

        for (var i = 0; i < urlParams.length; i++) {
            reorderParam = urlParams[i].split('=');
            if (reorderParam[0] === 'opencart') {
                reorderParam[1] === undefined ? 0 : reorderParam[1];
                if (reorderParam[1] == 1) {
                    component.set('v.cartIsOpen', true);
                }
            }
        }
    },
    removeItem: function (component, event) {
        let currentItems = component.get('v.orderProducts');
        var selectedItem = event.currentTarget;
        var elementId = selectedItem.dataset.item;

        let newList = currentItems.filter(product => product.Id !=  elementId);
        var action = component.get("c.deleteProductItem");
        let record = {
            sobjectType: 'LAT_OpportunityLineItem__c',
            Id: elementId
        };

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

                component.set("v.orderProducts", newList);
                this.calculatePrice(component);
                this.validateStock(component);
                component.set('v.isLoading', false);
            } else {
                component.set('v.isLoading', false);                
            }
        });

        $A.enqueueAction(action);        
    },
    calculatePrice: function (component) {
        let currentItems = component.get('v.orderProducts');
        let price = 0;
        let iva = 0;
        let iibb = 0;

        currentItems.forEach(function (prod) {
            price += (prod.LAT_QTTotal__c * prod.LAT_UnitPrice__c);
            iva += (prod.LAT_QTTotal__c * prod.LAT_UnitIva__c);            
            iibb += (prod.LAT_QTTotal__c * prod.LAT_UnitIibb__c );
        });

        component.set("v.price", price);
        component.set("v.ivaPrice", iva);
        component.set("v.iibbPrice", iibb);
    },
    /*
     * sendToJDE 
     */
    sendToJDE: function (component) {
        var action = component.get("c.integrateToJDE");
        var order = component.get('v.order') ;
                
        action.setParams({
            "oppId": order.Id,
        });
        var toastEvent = $A.get("e.force:showToast");

        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var orderResponse = response.getReturnValue();
                
                component.set('v.isLoading', false);
                toastEvent.setParams({
                    "title": "Tu pedido fue enviado correctamente!",
                    "message": "Tu número de referencia es : " + order.LAT_NRCustomerOrder__c,
                    "type": "success"
                });

                $A.get('e.force:refreshView').fire();
                toastEvent.fire();                
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
    addProduct: function (component, event) {
        var title = event.getParam("title");
        var subtitle = event.getParam("subtitle");
        var imageUrl = event.getParam("imageUrl");
        var price = event.getParam("price");
        var iva = event.getParam("iva");
        var iibb = event.getParam("iibb");
        var unit = event.getParam("unit");
        var productId = event.getParam("productId");
        var sku = event.getParam("sku");
        var qty = event.getParam("qty");
        var stockDisponible = event.getParam("stockdisponible");
        var bottlesperbox = event.getParam("bottlesperbox");
        var isOverStock = event.getParam("isoverstock");
        var bottlesperbox = event.getParam("bottlesperbox");
        var toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
            "title": title,
            "message": "Ha sido agregado con exito a su carrito!",
            "type": "success"
        });
        toastEvent.fire();

        let LAT_Product__r = {
            Name: title,
            LAT_B2B_Product_Name__c: subtitle,
            LAT_B2B_Thumbnail_URL__c: imageUrl,
            LAT_MX_StockPRM__c: stockDisponible,
            LAT_MX_ClientStock__c: Math.floor(stockDisponible/bottlesperbox),
        };


        let obj = {
            Name: title,
            LAT_QTTotal__c: parseInt(qty),
            LAT_UnitPrice__c: price,
            LAT_UnitIva__c: iva,
            LAT_UnitIibb__c: iibb,
            LAT_UnitCode__c: unit,
            LAT_Product__r: LAT_Product__r,
            LAT_Product__c: productId,
        };

        let currentItems = component.get('v.orderProducts');
        let order = component.get('v.order');

        // If the prodyct and unit exists we must to sum to the current box
        let existsInTable = false;
        let record = null;
        currentItems.forEach(function (prod) {
            console.log('addProduct [ obj.LAT_Product__c : ' + obj.LAT_Product__c + ']');
            console.log('addProduct [ prod.LAT_Product__c : ' + prod.LAT_Product__c + ']');
            console.log('addProduct [ obj.LAT_Product__c : ' + obj.LAT_Product__c + ']');
            console.log('addProduct [ obj.LAT_UnitCode__c : ' + prod.LAT_UnitCode__c + ']');

            if (obj.LAT_Product__c == prod.LAT_Product__c && obj.LAT_UnitCode__c == prod.LAT_UnitCode__c) {
                existsInTable = true;
                prod.LAT_QTTotal__c = prod.LAT_QTTotal__c + obj.LAT_QTTotal__c;
                record = {
                    sobjectType: 'LAT_OpportunityLineItem__c',
                    Id: prod.Id,
                    LAT_Quantity__c: parseInt(prod.LAT_QTTotal__c)
                };
            }
        });

        console.log('addProduct [ existsInTable : ' + existsInTable + ']');

        if (!existsInTable) {
            console.log('addProduct [Inserting record...]');

            record = {
                sobjectType: 'LAT_OpportunityLineItem__c',
                LAT_Product__c: productId,
                LAT_QTTotal__c: parseInt(qty),
                LAT_UnitPrice__c: parseFloat(price),
                LAT_UnitIva__c: parseFloat(iva),
                LAT_UnitIibb__c : parseFloat(iibb),
                LAT_UnitCode__c: unit,
                LAT_AR_UOM__c: unit,
                LAT_Opportunity__c: order.Id,
                LAT_SkuText__c: sku,
                LAT_PaymentCondition__c: "035",
                LAT_Quantity__c: parseInt(qty),
            };
            this.updateOrInsertLineItem(component, record, 'insert', currentItems, obj);
        } else {
            console.log('addProduct [Updating record...]');
            this.updateOrInsertLineItem(component, record, 'update', currentItems, obj);
        }
    },
    updateOrInsertLineItem: function (component, record, type, currentItems, obj) {
        if (type == 'insert') {
            var action = component.get("c.insertLineItem");
            action.setParams({
                record: record
            });

            console.log('updateOrInsertLineItem [Inserting record...]');

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    obj.Id = response.getReturnValue();
                    currentItems.push(obj);
                    component.set('v.isLoading', false);
                    component.set('v.orderProducts', currentItems);
                    
                    this.calculatePrice(component);
                    this.validateStock(component);
                } else {
                    console.log('error');
                }
            });
            $A.enqueueAction(action);
            
        } else {
            var action = component.get("c.updateLineItem");
            action.setParams({
                record: record
            });

            console.log('updateOrInsertLineItem [Updating record...]');

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.isLoading', false);
                    var itemInserted = response.getReturnValue();
                } else {
                    alert('error');
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
                prod.LAT_QTTotal__c = parseInt(prod.LAT_QTTotal__c, 10) + qty;
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
	assignQty: function (component, productId, unit, qty, itemId) {
        let currentItems = component.get('v.orderProducts');
        let record = null;
        
        currentItems.forEach(function (prod) {
            if (productId == prod.LAT_Product__c && unit == prod.LAT_UnitCode__c) {                
                prod.LAT_QTTotal__c = parseInt(qty , 10);
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
    removeItemModal: function (component, elementId) {
        let currentItems = component.get('v.orderProducts');
        let newList = currentItems.filter(product => product.Id !=  elementId);
        
        var action = component.get("c.deleteProductItem");
        let record = {
            sobjectType: 'LAT_OpportunityLineItem__c',
            Id: elementId
        };

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
    getAvailableCredit: function (component){
        var getAccountDetails = component.get('c.getAccountDetail');
        
        getAccountDetails.setCallback(this,function(response){
	      	var state = response.getState();
	      	if ( state === 'SUCCESS' ) {
	       	var objString = response.getReturnValue();                
	       		if (objString) {
                    var obj = JSON.parse(objString);
                    console.log('getAccountDetails');
                    console.log(obj);
                    var available = obj.credLimit - obj.credDebt - obj.credOrderAppr;

			       	component.set('v.availableCredit', available);
		      	}
	      	}
	    });
	    $A.enqueueAction(getAccountDetails);
    },
})