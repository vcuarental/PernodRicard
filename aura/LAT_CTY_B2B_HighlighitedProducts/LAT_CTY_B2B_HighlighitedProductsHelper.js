({	
	getProducts : function(component) { 
		var getProducts = component.get('c.getHighlightedProducts');
        getProducts.setParams({
            "rowNumber": component.get("v.rowNumber"),
        });
		getProducts.setCallback(this, function(response) {
			var state = response.getState();
			if ( state === 'SUCCESS' ) { 
				var productsString = response.getReturnValue();
                
				if (productsString) {
					var productList = JSON.parse(productsString);
                    console.info(productList);
					productList.forEach(function(product){
						// Add dummy unit to products
						
						product.unit = 'BOTELLA';
                        if(product.LAT_B2B_Visibility__c == 'Visible Caja'){
                            console.log('producto visible caja : ' + product);
                            product.unit = 'CAJA';
                        }
						product.qty = '1';
					});
                    component.set('v.productsBase', productList);
                    component.set('v.productsFiltered', productList);
                    component.set('v.isLoading', false);
				}
				
			}
		})
		$A.enqueueAction(getProducts);
	},

})