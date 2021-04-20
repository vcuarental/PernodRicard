({	
    loadOrderId: function (component) {
        var url = decodeURIComponent(window.location.search.substring(1));
        // console.log('url' + url);
        var urlParams = url.split('&');
        var myOrdersParam;
        for (var i = 0; i < urlParams.length; i++) {
            myOrdersParam = urlParams[i].split('=');
            if (myOrdersParam[0] === 'orderId') {
                myOrdersParam[1] === undefined ? 0 : myOrdersParam[1];
                if (myOrdersParam[1] != 0) {
                    component.set("v.orderId", myOrdersParam[1]);
                }
            }
        }
        console.log('component.get("v.orderId")' + component.get("v.orderId"));
    },
	setfilterItems : function(component){
        var action = component.get("c.getFilterItems");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var filterItems = response.getReturnValue();
                // console.log('filterItems:' + JSON.stringify(filterItems));
                let categoryBrandArray = [];
                filterItems.forEach(function(filterItem){
                    
                    if (filterItem.ASI_CTY_CN_WS_Level__c === 'Bottle Size'){
                        component.set('v.bottleSize', filterItem.Name + ' > ');
                        let bottleSize = filterItem.ASI_CTY_CN_WS_Bottle_Size__c.split(';');
                        component.set('v.bottleSizeFilter', bottleSize);
                    }else {
                        // category & brand
                        categoryBrandArray.push(filterItem);
                    }
                    
                });
                component.set('v.categoryBrandFilter', categoryBrandArray);
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
    getBrandRels : function(component){
        var action = component.get("c.getBrandRels");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var brandRels = response.getReturnValue();
                
                var arrayMapKeys = [];
                for(var key in brandRels){
                    arrayMapKeys.push({key: key, value: brandRels[key]});
                }
                component.set('v.brandRels', arrayMapKeys);
            }else if (state === "INCOMPLETE") {

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
    getProducts : function(component) { 
       	var getProducts = component.get('c.fetchProducts');
        
        getProducts.setCallback(this, function(response) {
            var state = response.getState();
            if ( state === 'SUCCESS' ) { 
                // console.log('response.getReturnValue()' + response.getReturnValue());
                var actualList = component.get('v.productsBase');
                var itemGroupWrapList = response.getReturnValue();
                if (itemGroupWrapList != null){
                    itemGroupWrapList.forEach(function(itemGroupWrap){
                        let product = itemGroupWrap.itemGroup;
                        // console.log('product name' + product.Name);
                        product.originalPriceBT = itemGroupWrap.originalPriceBTWithVAT;
                        product.photoURL = '';
                        let photoList = product.Product_Warehouse_Photos__r;
                        if(photoList !== undefined && photoList.length > 0){

    	                    product.photoURL = '/ASICTYWholesalerCN' + photoList[0].ASI_MFM_Image_URL_720_480__c;

    	                }
                        product.CANumber = 1;
                        if(product.ASI_CRM_CN_Pack_Value__c != null){
                            product.BTNumber = product.CANumber * product.ASI_CRM_CN_Pack_Value__c;
                        }
                        var btSizeStr = product.ASI_CRM_CN_BT_Size_C__c;
                        if(btSizeStr !== undefined && btSizeStr !== '' && btSizeStr !== null){
                            // console.log('btSizeStr:' + btSizeStr);
                            btSizeStr = btSizeStr.toLowerCase().endsWith('cl') ? btSizeStr.split('cl')[0] : btSizeStr;
                            if(!btSizeStr.includes('.')){
                                btSizeStr = btSizeStr + 'cl';
                            }else{
                                var length = btSizeStr.split('.')[0].length;
                                if(btSizeStr.split('.')[1].startsWith('0')){
                                    btSizeStr = btSizeStr.split('.')[0] + 'cl';
                                }else{
                                    btSizeStr = btSizeStr.substring(0, length+2) + 'cl';
                                }
                            }
                            product.ASI_CRM_CN_BT_Size_C__c = btSizeStr;
                        }
                        actualList.push(product);
                    });
                }
                component.set('v.productsBase', actualList);
                component.set('v.productsFiltered', actualList);
                component.set('v.showSpinner', false);
                this.renderPage(component);
            }else if (state === "INCOMPLETE") {

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
        })
        $A.enqueueAction(getProducts);
    },
    renderPage: function(component) {
        var records = component.get("v.productsFiltered"),
            pageNumber = component.get("v.page");
        var pageRecords = records.slice((pageNumber-1)*10, pageNumber*10);
        component.set("v.total", records.length);
        component.set("v.pageRecords", pageRecords);
        if(pageRecords.length === 0){
            component.set("v.pageFirstIndex", 0);
        }else{
            component.set("v.pageFirstIndex", 10 * (pageNumber-1) + 1);
        }
        if(pageRecords.length === 10){
            component.set("v.pageLastIndex", 10 * pageNumber);
        }else{
            component.set("v.pageLastIndex", 10 * (pageNumber-1) + pageRecords.length);
        }
        component.set("v.pages", Math.floor((records.length+9)/10));
    },
    navigateToURL: function (url) {
        console.log('url'+url);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/" + url
        });
        urlEvent.fire();
    },
    onChangedCANumber: function (component,event) {
        let CANumber = event.getSource().get("v.value");
        var key = event.getSource().get("v.tabindex");
        let products = component.get('v.pageRecords');
        let product = products[key];
        product.BTNumber = CANumber * product.ASI_CRM_CN_Pack_Value__c;
        component.set("v.pageRecords", products);
    },
	addToCart : function(component, event) {
        component.set('v.showSpinner', true);
        var orderId = component.get('v.orderId');
		var selectedItem = event.currentTarget;
        var productId = selectedItem.dataset.productid;
		var caNumber = selectedItem.dataset.canumber;
        if(caNumber < 1){
            alert($A.get('$Label.c.ASI_CTY_CN_WS_Add_To_Cart_Limit'));
            component.set('v.showSpinner', false);
            return;
        }
		console.log('productId:'+productId);
        console.log('caNumber:'+caNumber);
        var action = component.get("c.generateSORItem");
        action.setParams({
            "orderId" : orderId,
            "productId" : productId,
            "caNumber" : caNumber
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                alert($A.get('$Label.c.ASI_CTY_CN_WS_Added_Successfully'));
                component.set('v.showSpinner', false);
                console.log($A.get('$Label.c.ASI_CTY_CN_WS_Added_Successfully'));
            
            }else if (state === "INCOMPLETE") {

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
                                        alert('Internal server error: ' + errors[i].pageErrors[j].message);

                                    }
                                }
                            }
                            // console.log(errors[i].message);
                            // alert(errors[i].message);
                            component.set('v.showSpinner', false);
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
	clearFilter : function(component, event) {
        var showAllProducts  = component.get('v.showAllProducts');
        if(showAllProducts){
            component.set('v.filterSelectedBrand', []);
            component.set('v.filterSelectedBottleSize', []);
            var filter = document.querySelectorAll('.allProductsFilter');
            filter.forEach(function(item){
                item.classList.remove('selected');
            });
        }else{
            component.set('v.filterSelectedSpecialSale', []);
            var filter = document.querySelectorAll('.specialSaleFilter');
            filter.forEach(function(item){
                item.classList.remove('selected');
            });
        }
		this.customFilter(component);
	},
    clearThisFilter : function(component, event) {
        var deletedItem = event.currentTarget.dataset.id;
        
        let filterSelectedBrand = component.get('v.filterSelectedBrand');
        
        const index = filterSelectedBrand.findIndex(brand => {return brand.Id == deletedItem});
        
        if (index > -1) {
          filterSelectedBrand.splice(index, 1);
        }
        component.set('v.filterSelectedBrand', filterSelectedBrand);
        
        var deletedBottleSizeItem = event.currentTarget.dataset.bottlesize;
        let filterSelectedBottleSize = component.get('v.filterSelectedBottleSize');
        const indexBottleSize = filterSelectedBottleSize.findIndex(bottlesize => {return bottlesize == deletedBottleSizeItem});
        
        if (indexBottleSize > -1) {
          filterSelectedBottleSize.splice(indexBottleSize, 1);
        }
        component.set('v.filterSelectedBottleSize', filterSelectedBottleSize);
        
        var deletedSpecialSaleItem = event.currentTarget.dataset.specialsale;
        let filterSelectedSpecialSale = component.get('v.filterSelectedSpecialSale');
        const indexSpecialSale = filterSelectedSpecialSale.findIndex(specialSale => {return specialSale == deletedSpecialSaleItem});
        if (indexSpecialSale > -1) {
          filterSelectedSpecialSale.splice(indexSpecialSale, 1);
        }
        component.set('v.filterSelectedSpecialSale', filterSelectedSpecialSale);
        
        this.customFilter(component);
    },
	setBrandFilter : function(component, event) {
        var selectedItem = event.currentTarget;
        
        var customBrand = {};
        customBrand.Name = selectedItem.dataset.brand;
        customBrand.Id = selectedItem.dataset.id;
		let filterSelectedBrand = component.get('v.filterSelectedBrand');
		const index = filterSelectedBrand.findIndex(brand => {return brand.Id == customBrand.Id});
		
        if(index <= -1) {
            filterSelectedBrand.push(customBrand);
            selectedItem.classList.add('selected');
        }      

        if (index > -1) {
            filterSelectedBrand.splice(index, 1);
            selectedItem.classList.remove('selected');
        }
		
		component.set('v.filterSelectedBrand', filterSelectedBrand);
        component.set("v.page", 1);
        this.customFilter(component);

	},

    setBottleSizeFilter : function(component, event) {
        var selectedItem = event.currentTarget;
        var bottleSize = selectedItem.dataset.bottlesize;
        let filterSelectedBottleSize = component.get('v.filterSelectedBottleSize');
        
        let exists = filterSelectedBottleSize.includes(bottleSize);
        
        if(!exists) {
            filterSelectedBottleSize.push(bottleSize);
            selectedItem.classList.add('selected');
        }else{
            const index = filterSelectedBottleSize.findIndex(bs => {return bs == bottleSize});
            if (index > -1) {
              filterSelectedBottleSize.splice(index, 1);
            }
            selectedItem.classList.remove('selected');
        }
        
        component.set('v.filterSelectedBottleSize', filterSelectedBottleSize);
        component.set("v.page", 1);
        this.customFilter(component);
    },

    setSpecialSaleFilter : function(component, event) {
        var selectedItem = event.currentTarget;
        var specialSale = selectedItem.dataset.type;
        let filterSelectedSpecialSale = component.get('v.filterSelectedSpecialSale');
        
        let exists = filterSelectedSpecialSale.includes(specialSale);
        component.set('v.filterSelectedSpecialSale', []);
        var filter = document.querySelectorAll('.specialSaleFilter');
        filter.forEach(function(item){
            item.classList.remove('selected');
        });
        if(!exists) {
            filterSelectedSpecialSale = [];
            filterSelectedSpecialSale.push(specialSale);
            selectedItem.classList.add('selected');
        }else{
            const index = filterSelectedSpecialSale.findIndex(sS => {return sS == specialSale});
            if (index > -1) {
              filterSelectedSpecialSale.splice(index, 1);
            }
            selectedItem.classList.remove('selected');
        }
        
        component.set('v.filterSelectedSpecialSale', filterSelectedSpecialSale);
        component.set("v.page", 1);
        this.customFilter(component);
    },

	customFilter : function (component) {
		var productsBase = component.get('v.productsBase');
        let filteredProducts = productsBase;
        let term = component.get('v.searchTerm');
        // term search
        console.log('term' + term);
        if(term != null && term != '') {
            component.set('v.showList', false);
            filteredProducts = filteredProducts.filter(
                function (item) {
                    if(item.Name.includes(term) 
                        || item.ASI_MFM_Item_Group_Code__c.includes(term)){
                        return item;
                    }
                }
            );
            component.set("v.page", 1);
        }

        var showAllProducts  = component.get('v.showAllProducts');
        let showSeparateItems = component.get('v.showSeparateItems');
        if(showAllProducts){
            let filterSelectedBrand = component.get('v.filterSelectedBrand');
            let filterSelectedBottleSize = component.get('v.filterSelectedBottleSize');
            var brandRels = component.get('v.brandRels');
            
            var brandIds = [];
            var subBrandIds = [];
    		if(filterSelectedBrand != '' && filterSelectedBrand.length > 0){
                // filteredProducts = filteredProducts.filter(item => (filterSelectedBrand.includes(item.Brand)));
                filterSelectedBrand.forEach(function(customBrand){
                    brandRels.forEach(function(brandRel){
                        if (customBrand.Id === brandRel.key){
                            var brandRelList = brandRel.value;
                            brandRelList.forEach(function(brand){
                                if(brand.ASI_CTY_CN_WS_Sub_brand__c != undefined &&
                                    brand.ASI_CTY_CN_WS_Sub_brand__c != null &&
                                    brand.ASI_CTY_CN_WS_Sub_brand__c != ''){
                                    subBrandIds.push(brand.ASI_CTY_CN_WS_Sub_brand__c);
                                }else if(brand.ASI_CTY_CN_WS_Brand__c != undefined &&
                                    brand.ASI_CTY_CN_WS_Brand__c != null &&
                                    brand.ASI_CTY_CN_WS_Brand__c != ''){
                                    brandIds.push(brand.ASI_CTY_CN_WS_Brand__c);
                                }
                            });
                        }
                    });
                });
            }
            var bottleSizes = [];
            if(filterSelectedBottleSize != '' && filterSelectedBottleSize.length > 0){
                filterSelectedBottleSize.forEach(function(bottleSize){
                    bottleSizes.push(bottleSize);
                });
            }
            if ((brandIds !== undefined && brandIds !== '' && brandIds !== null && brandIds.length > 0)
                || (subBrandIds !== undefined && subBrandIds !== '' && subBrandIds !== null && subBrandIds.length > 0)){
                filteredProducts = filteredProducts.filter(
                    function (item) {
                        if ((subBrandIds.includes(item.ASI_MFM_Sub_brand__c) || 
                                brandIds.includes(item.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c))){
                            if(bottleSizes !== undefined && bottleSizes !== '' && bottleSizes !== null && bottleSizes.length > 0){
                                let bottlesize = item.ASI_CRM_CN_BT_Size_C__c;
                                if(bottleSizes.includes(item.ASI_CRM_CN_BT_Size_C__c)){
                                    return item;
                                }
                            }else{
                                return item;
                            }
                        }
                    }
                ); 
            }else if(bottleSizes !== undefined && bottleSizes !== '' && bottleSizes !== null && bottleSizes.length > 0){
                filteredProducts = filteredProducts.filter(
                    function (item) {
                        let bottlesize = item.ASI_CRM_CN_BT_Size_C__c;
                        if(bottleSizes.includes(item.ASI_CRM_CN_BT_Size_C__c)){
                            return item;
                        }
                    }
                );       
            }
        } else if (!showSeparateItems){
            var specialSales = component.get('v.filterSelectedSpecialSale');
            if(specialSales != '' && specialSales.length > 0){
                filteredProducts = filteredProducts.filter(
                    function(item) {

                        var flag = false;
                        console.log('item' + JSON.stringify(item));
                        specialSales.forEach(function(specialSale) {

                            if ((specialSale == $A.get('$Label.c.ASI_CTY_CN_WS_Hot') &&
                                    item.ASI_CTY_CN_WS_Is_Hot__c) ||
                                (specialSale == $A.get('$Label.c.ASI_CTY_CN_WS_High_Level') &&
                                    item.ASI_CTY_CN_WS_Is_HighLevel__c) ||
                                (specialSale == $A.get('$Label.c.ASI_CTY_CN_WS_New') &&
                                    item.ASI_CTY_CN_WS_Is_New__c)) {
                                
                                flag = true;

                            }
                        });

                        return flag;
                    }
                );
            }
        }
        
        if (showSeparateItems) {
            filteredProducts = filteredProducts.filter( item => {
                    if (item.ASI_CTY_CN_WS_Is_Especial_For_WS__c) {
                        return item;
                    }
                }
            );
        }
		component.set('v.productsFiltered', filteredProducts);
        this.renderPage(component);
	},
    addEle: function(component,event){
        var photoItem = event.currentTarget;
        var src = photoItem.dataset.src;
        console.log('src' + src);
        
        if(src != '' && src != null && src != undefined){
            // use DOM HTMLImageElement

            var photo = document.createElement('img');
            photo.src = src;
            photo.alt = 'product photo';
            photo.id = 'productImg';

            // document.body.appendChild(photo);
            var tr = photoItem.parentElement.parentElement;
            var trIndex =  tr.rowIndex;
            tr.appendChild(photo);

            // get body width and height
            var sWidth = document.body.scrollWidth;
            var sHeight = document.body.scrollHeight;
            
            // get img width and height
            var dWidth = photo.naturalWidth * 0.5;
            var dHeight = photo.naturalHeight * 0.5;
            // var dWidth=photo.offsetWidth;
            // var dHeight=photo.offsetHeight;
            
            // set style
            photo.style.position = 'absolute';
            photo.style.zIndex = '1';
            photo.style.cursor = 'pointer';
            photo.style.width = dWidth + 'px';
            photo.style.height = dHeight + 'px';
            // photo.style.left = sWidth/2-dWidth/2+'px';
            // photo.style.top=sHeight/2-dHeight/2+'px';
            photo.style.top = 32 + trIndex * 49 + 'px';
            // photo.style.top = '0';
            photo.style.left = '0';
        }
               
    },
    removeEle: function(component,event){

        var img = document.getElementById('productImg');
        if(img != '' && img != null && img != undefined){
            img.remove();
        }
    },
})