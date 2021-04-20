({	
	initFilterMap : function(component){
		var newFilterMap = new Map();
		newFilterMap.set('category', {'fieldName':'LAT_B2B_Product_History__c', 'values' : []});
		newFilterMap.set('brand', {'fieldName' : 'LAT_B2B_Brand__c', 'values' : []});
		newFilterMap.set('name', {'fieldName' : 'LAT_B2B_Product_Name__c', 'values' : []});
		newFilterMap.set('size', {'fieldName' : 'LAT_B2B_Size_Value__c', 'values' : []});
		component.set('v.filtersMap', newFilterMap);
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
            }
        });
        $A.enqueueAction(action);
    },
	getOrderTakingEnabled: function (component, event) {
        console.log('en getOrderTakingEnabled');
		var action = component.get("c.getChartBlocked");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var enabled = a.getReturnValue();
                console.log('enabled:' + enabled);
                component.set('v.orderTakingBlocked', enabled);
            }
        });
        $A.enqueueAction(action);
    },	
    getblockedMessage: function (component, event) {
        console.log('en getblockedMessage');
		var action = component.get("c.getBlockingComments");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var blockMessage = a.getReturnValue();
                console.log('blockMessage:');
                console.log(JSON.stringify(blockMessage));
                component.set('v.blockedMessage', blockMessage.LAT_Value__c);
            }
        });
        $A.enqueueAction(action);
    },	
	getCategories : function(component) {
		var getAllCategories = component.get('c.getAllCategories');
	    getAllCategories.setCallback(this,function(response){
	      var state = response.getState();
	      if ( state === 'SUCCESS' ) {
          	console.log('mapa retornado : ' + JSON.stringify(response.getReturnValue()));
              var categoryList = [];
              for(var item in response.getReturnValue()){
                  var aux = item;
                  categoryList.push(aux);
                  console.log('key: ' + item);
                  console.log('value: ' + response.getReturnValue()[item]);
              }
	       	//var categoryList = response.getReturnValue();
	       	component.set('v.categories', categoryList);
	       	component.set('v.categoriesMap', response.getReturnValue());
              
	      }
	    });
	    $A.enqueueAction(getAllCategories);
	},
	addToCart : function(component, event) {
        // var cart = component.get('v.cart');
		// var productId = event.getSource().get("v.ariaLabel");
		
		var selectedItem = event.currentTarget;
        console.log('selectedItem:'+selectedItem);
        selectedItem.disabled = true;
        console.log('dataset : ' + JSON.stringify(selectedItem.dataset));
		var title = selectedItem.dataset.title;
		var subtitle = selectedItem.dataset.subtitle;
		var unit = selectedItem.dataset.unit;
		var price = selectedItem.dataset.price;
		var iva = selectedItem.dataset.iva;
		var iibb = selectedItem.dataset.iibb;
		var image = selectedItem.dataset.image;
		var pid = selectedItem.dataset.pid;
		var sku = selectedItem.dataset.sku;
		var qty = selectedItem.dataset.qty;
        if(qty > 9998){
            qty = selectedItem.dataset.qty = 9999;
        }
		
        var stockDisponible = selectedItem.dataset.stockdisponible;
        var bottlesperbox = selectedItem.dataset.bottlesperbox;
        console.log('stockDisponible : ' + stockDisponible);
        console.log('bottlesperbox : ' + bottlesperbox);
        var isOverStock = false;
        if(qty>stockDisponible){
            isOverStock = true;
        }
		console.log('isOverStock : ' + isOverStock);
        console.log('IVA || IIBB : ' + iva + ' || '+ iibb);
        // console.info('ADD to Cart - productId: ' + productId);
        // var prodObj = {};
        // prodObj.Id = productId;
        // prodObj.Qty = 1;
        // cart.push(prodObj);
		// component.set('v.cart', cart);
		console.info('ADD to Cart - productId');
		var compEvent = $A.get("e.c:LAT_CTY_B2B_AddToCart");

		console.log('evt',compEvent);
        // set the Selected sObject Record to the event attribute.
		compEvent.setParams(
			{
				"title" : title,
				"subtitle" : subtitle,
				"unit" : unit,
				"imageUrl" : image,	
				"price": price,
				"iva": iva,
				"iibb": iibb,
				"sku": sku,
				"productId": pid,
				"qty": qty,
                "stockdisponible": stockDisponible,
                "isoverstock": isOverStock,
                "bottlesperbox": bottlesperbox
			
			}
		);
		// fire the event
		compEvent.fire();
        selectedItem.dataset.qty = 1;
        selectedItem.disabled = true;
        var timer = component.get('v.timer');
        clearTimeout(timer);
        timer = setTimeout(function(){
            console.info('tiramos');
            selectedItem.disabled = false;
            clearTimeout(timer);
            component.set('v.timer', null);
        }, 2000);

	},
	getProducts : function(component) { 
        console.log('offset 1:'+component.get("v.offSet"));
		var getProducts = component.get('c.getProducts');
        getProducts.setParams({
            "offSet": component.get("v.offSet"),
        });
		getProducts.setCallback(this, function(response) {
			var state = response.getState();
			if ( state === 'SUCCESS' ) { 
                console.log('offset 2:'+component.get("v.offSet"));
				var productsString = response.getReturnValue();
                if(component.get("v.offSet") == 0){
                    var a = component.get('c.doContinueInit');
        			$A.enqueueAction(a);
                }
				if (productsString) {
                    var listaActual = component.get('v.productsBase');
					var productList = JSON.parse(productsString);
                    console.info('size productos:'+productList.length);
					this.setBrandList(component, productList);
					productList.forEach(function(product){
						// Add dummy unit to products
						
						product.unit = 'BOTELLA';
                        if(product.LAT_B2B_Visibility__c == 'Visible Caja'){
                            console.log('producto visible caja : ' + product);
                            product.unit = 'CAJA';
                        }
						product.qty = '1';
                        listaActual.push(product);
					});
                    console.log('offset 3:'+component.get("v.offSet"));
                    component.set('v.productsBase', listaActual);
                    component.set('v.productsFiltered', listaActual);
                    
                    component.set('v.offSet',component.get('v.productsBase').length);
                    console.log('offset 4:'+component.get("v.offSet"));
                    var a = component.get('c.doInit');
        			$A.enqueueAction(a);
				}
				
			}
		})
		$A.enqueueAction(getProducts);
	},

	setBrandList : function(cmp, productList) {
		let brandList = cmp.get('v.brandList');
		productList.forEach(function(product){
			if (product.LAT_B2B_Brand__c !== void 0 && brandList.indexOf(product.LAT_B2B_Brand__c) === -1) {
				brandList.push(product.LAT_B2B_Brand__c);
			}
		});
		cmp.set('v.brandList', brandList.sort());
	},

	setUnit : function (component, event) {
		console.log('setUnit helper');
		var selectedItem = event.currentTarget;
		var pid = selectedItem.dataset.pid;
		var unit = selectedItem.dataset.unit;
		var productList = component.get('v.productsFiltered');
		productList.forEach(function(product){
			// Add dummy unit to products
			if(product.Id == pid) {
				product.unit = unit;
			}
			
		});
		console.log(pid);
		console.log(unit);
		component.set('v.productsFiltered', productList );
		//document.getElementById('cart-section').classList.remove('hidden'); 
   },


	showCartSection : function (component) {
		 //document.getElementById('cart-section').classList.remove('hidden'); 
	},
    
    createOrderAndLineItems : function (component) {
        console.info('createOrderAndLineItems');
        console.info('');
		var selectedProducts = component.get('v.cart');
		var selectedAccountId = "001D0000019yuM7IAI"; 
        var selectedAccountName = "SUPERMERCADO LA SANDRO"; 
        var selectedAccountCurrencyISOCode = "ARS";
		var orderType = "SO";
		var paymentCondition = "035";
		var opportunityLineItems = [];
		var countryCodeNumber = 6;
		
        console.info('selected Products');
		console.info(selectedProducts);
        
		// Create LAT_OpportunityLineItem__c
		var products = component.get('v.productsBase'); // get all product info
        
        console.info('Products');
		console.info(products);
        
		products.forEach(function(p) { // Iterate over products to get details of selected products
            //console.info(p)
			selectedProducts.forEach(function(sp) {
				if (p.Id == sp.Id) {
					var item =  {
						sobjectType: 'LAT_OpportunityLineItem__c',
						LAT_Product__c: sp.Id,
						LAT_Quantity__c: (sp.Qty) ? parseInt(sp.Qty) : 0,
						LAT_Country__c: countryCodeNumber,
						LAT_AR_UOM__c: p.LAT_CDUnit__c,
						LAT_PaymentCondition__c: paymentCondition,
						LAT_PaymentConditionDescription__c: '35 Dias de FF',
						LAT_SkuText__c: p.LAT_Sku__c,
						LAT_UnitCode__c: p.LAT_CDUnit__c,
						LAT_BottlesPerBox__c: p.LAT_BottlesPerBox__c,
						LAT_UnitWeight__c: p.LAT_UnitWeight__c,
						CurrencyIsoCode: selectedAccountCurrencyISOCode,
						//LAT_AR_MaxDiscount__c: product.PercentualBonus__c
						//LAT_MultipleQuantity__c: 'LAT_MultipleQuantity__c',
					};
					opportunityLineItems.push(item);
				}
			});
			//console.info(p);
		}); 
		
        console.info('opportunityLineItems');
		console.log(opportunityLineItems);
        
		var deliveredDate = '2019/05/25';

		var action = component.get("c.saveOpportunity");
		action.setParams({
			record: {
				sobjectType: 'LAT_Opportunity__c',
				Name: selectedAccountName + '- B2B',
				//LAT_Type__c: orderType,
				LAT_Account__c: selectedAccountId,
				CurrencyIsoCode: selectedAccountCurrencyISOCode,
				LAT_Country__c: countryCodeNumber,
				//LAT_DTDelivery__c:  deliveredDate,
				LAT_LeadSource__c: 'B2B'
			},
			items: opportunityLineItems
		});
		console.info('before callback');
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				console.log('created');
				var newObjectId = response.getReturnValue();
				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
				  "recordId": newObjectId,
				  "slideDevName": "Detail"
				});
				navEvt.fire();
				//alert(newObjectId);
			} else {
				var errors = response.getError();
                console.log(response);
                console.log(errors);
				console.log(errors[0]);
				var message = 'Unknown error'; 
				if (errors[0].pageErrors && Array.isArray(errors[0].pageErrors) && errors[0].pageErrors.length > 0) {
					message = errors[0].pageErrors[0].message;
				}
				component.find('overlayLib').showCustomModal({
					header: "Application Error",
					body: message, 
					showCloseButton: true,
					cssClass: "error-class",
					// closeCallback: function() {
					// 	alert('You closed the alert!');
					// }
				});
				component.set('v.spinner', false);
		
			}
		});
        console.info('before enqueue');
		$A.enqueueAction(action);
        console.info('afger enqueue');
	},
	toggleFilterList : function(component, event) {
		this.toggleElementClass(event.target, 'opened');
		var currentState = component.get('v.showFilterList');
		component.set('v.showFilterList', !currentState);
	},
	toggleElementClass : function(element, className) {
		if (element != void 0 && element && className != void 0 && className) {
			if (!element.classList.contains(className)) {
				element.classList.add(className);
			} else {
				element.classList.remove(className);
			}		
		}
	},
	createNewFilter : function(component, filterName, filterValue) {
		var customFilters = component.get("v.filtersMap");
		var customFilter = customFilters.get(filterName);
		
		if (filterName === 'name') {
			customFilter.values[0] = filterValue;
		} else {
			var filterIndex = customFilter.values.findIndex(function(v) {v == filterValue;});
			if (filterIndex > -1) {
				customFilter.values[filterIndex] = filterValue;
			} else {
				customFilter.values.push(filterValue);
			}
		}
		customFilters.set(filterName, customFilter);
		component.set('v.filtersMap', customFilters);
	},
	applyFilters : function(productList, filtersMap) {
		var filteredProducts = productList;
		
		// for (var filter in filtersMap){
		// 	console.log(filter + '<<<');
		// 	filteredProducts = filteredProducts.filter(function(product){
		// 		return (filtersMap[filter].values.findIndex(function(value){	
		// 											return (value == product[filter.fieldName] || product[filter.fieldName].includes(value));
		// 										}) > -1);
		// 	});
		// }

		// // Filter by name me parece que no esta comparando bien
		// // filtered by payment condition
		
		// // Filter By Term
		// if(term.length > 2) {
		// 	porductsFilterByPayment = porductsFilterByPayment.filter(item => (item.LAT_Product__r.LAT_Sku__c.toLowerCase().includes(term) || item.LAT_Product__r.Name.toLowerCase().includes(term)));
		// }

		// console.log(JSON.parse(filtersMap));
		for (var [key, va] of filtersMap) {
			console.log(va);
			//console.log(key + ' = ' + va.fieldName);
			

			// filteredProducts = filteredProducts.filter(function(product){
			// 	return (va.values.findIndex(function(value){	
			// 		return (value == product[va.fieldName] || product[va.fieldName].includes(value));
			// 	}) > -1);
			// });

		  }
		return filteredProducts;
	},
	searchTerm : function(component, event) {
		var termToSearch = event.target.value;
		this.customFilter(component, termToSearch, component.get('v.filterSelectedBrand'));
		component.set('v.searchTerm', termToSearch);
	},

	clearFilter : function(component, event) {
		component.set('v.filterSelectedBrand', []);
		this.customFilter(component, component.get('v.searchTerm'), []);
	},
	setCategoryFilter : function(component, event) {
		var selectedItem = event.currentTarget;
		var currentNameList = selectedItem.dataset.category;
        var categoriesMap = component.get('v.categoriesMap');
        console.log(' currentName : ', currentNameList);
        console.log(' categoriesMap[currentName] : ', categoriesMap[currentNameList]);
		let filterSelectedBrand = component.get('v.filterSelectedBrand');
		
        for(var currentName in categoriesMap[currentNameList]){
            console.log(' Category currentName:' + categoriesMap[currentNameList][currentName]);
            let exists = filterSelectedBrand.includes( categoriesMap[currentNameList][currentName]);
            console.log(' exists', exists);
            // Exists in array
            if(exists) {
                const myindex = filterSelectedBrand.findIndex(bra => bra ==  categoriesMap[currentNameList][currentName]);
                console.log(' myindex', myindex);
                filterSelectedBrand.splice(myindex, 1);
            } 
            // New one, add to array
            else {
                filterSelectedBrand.push( categoriesMap[currentNameList][currentName]);
            }
        }
		

		// set the filter to the list TO DO: WE MUST CHANGE THE MODEL, TO SET NAME, AND "SELECTED"
		component.set('v.filterSelectedBrand', filterSelectedBrand);
		this.customFilter(component, component.get('v.searchTerm'), filterSelectedBrand);


	},
    setBrandFilter : function(component, event) {
		var selectedItem = event.currentTarget;
		var currentName = selectedItem.dataset.brand;
		let filterSelectedBrand = component.get('v.filterSelectedBrand');
		
		let exists = filterSelectedBrand.includes(currentName);
		console.log(' exists', exists);
        console.log(' Brand currentName:' + currentName);
		// Exists in array
		if(exists) {
			const myindex = filterSelectedBrand.findIndex(bra => bra == currentName);
			console.log(' myindex', myindex);
			filterSelectedBrand.splice(myindex, 1);
		} 
		// New one, add to array
		else {
			filterSelectedBrand.push(currentName);
		}
		

		// set the filter to the list TO DO: WE MUST CHANGE THE MODEL, TO SET NAME, AND "SELECTED"
		component.set('v.filterSelectedBrand', filterSelectedBrand);
		this.customFilter(component, component.get('v.searchTerm'), filterSelectedBrand);


	},

	customFilter : function (component, term, filterSelectedBrand) {
		var productsBase = component.get('v.productsBase');
		let filteredProducts = productsBase;
		
		// term search
		if(term != null && term != '') {
			filteredProducts = filteredProducts.filter(item => (item.Name.toLowerCase().includes(term) ||  (item.LAT_B2B_Product_Name__c && item.LAT_B2B_Product_Name__c.toLowerCase().includes(term))));
		}
		if(filterSelectedBrand && filterSelectedBrand.length > 0){

			filteredProducts = filteredProducts.filter(item => (filterSelectedBrand.includes(item.LAT_B2B_Brand__c)));

			// filterSelectedBrand.forEach(function(element) {
			// 	filteredProducts = filteredProducts.filter(item => (item.Name.toLowerCase().includes(term) || item.LAT_B2B_Product_Name__c.toLowerCase().includes(term)));

			//  });
			// filteredProducts = filteredProducts.filter(item => (
			// 	filterSelectedBrand.forEach(element => {
			// 		console.log(element);
			// 	});
			// 	return true;
			// 	//item.LAT_B2B_Brand__c.includes(filterSelectedBrand)
				
			// ));
		}
		
		component.set('v.productsFiltered', filteredProducts);

		



	}
})