({
    loadProduct : function(component) {
        var itemGroupId = component.get("v.productId");
        console.log('itemGroupId' + itemGroupId);
        
        var action = component.get("c.getProduct");
        action.setParams({ "itemGroupId" : itemGroupId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var result = response.getReturnValue();
                
                var photoList = result.itemGroup.Product_Warehouse_Photos__r;
                // console.log('photoList.length' + photoList.length);
                if(photoList !== undefined && photoList != null){
                    // console.log('Product Photo Info:' + JSON.stringify(photoList));
                    photoList.forEach(function(photo){

                        photo.ASI_MFM_Image_URL_720_480__c = '/prcwholesaler' + photo.ASI_MFM_Image_URL_720_480__c;

                    });
                    component.set("v.productPhotoList", photoList);
                }
                
                
                var skuList = result.itemGroup.SKUs__r;
                if(skuList !== undefined && photoList.length > 0){
                    // console.log('SKU Info:' + JSON.stringify(skuList));
                    skuList.forEach(function(sku){
            
                        if(sku.ASI_CRM_SKU_Status__c === '001'){
                            component.set("v.sku", sku);
                        }
                        
                    });
                    var comSKU = component.get("v.sku");
                    if(comSKU === null){
                        component.set("v.sku", skuList[0]);
                    }
                }
                
                var btSizeStr = result.itemGroup.ASI_CRM_CN_BT_Size_C__c;
                if(btSizeStr !== undefined && btSizeStr !== '' && btSizeStr !== null){
                    // console.log('btSizeStr:' + btSizeStr);
                    btSizeStr = btSizeStr.toLowerCase().endsWith('cl') ? btSizeStr.split('cl')[0] : btSizeStr;
                    if(!btSizeStr.includes('.')){
                        btSizeStr = btSizeStr + 'cl';
                    }else{
                        var length = btSizeStr.split('.')[0].length;
                        btSizeStr = btSizeStr.substring(0, length+2) + 'cl';
                    }
                    result.itemGroup.ASI_CRM_CN_BT_Size_C__c = btSizeStr;
                }
                let product = result.itemGroup;
                product.CANumber = 1;
                if(product.ASI_CRM_CN_Pack_Value__c != null){
                    product.BTNumber = product.CANumber * product.ASI_CRM_CN_Pack_Value__c;
                }
                component.set("v.product", product);
                component.set("v.pack", result.itemGroup.ASI_CRM_CN_Pack_Value__c);
                component.set("v.originalPriceBTWithVAT", result.originalPriceBTWithVAT);
                if (result.originalPriceBTWithVAT != null &&
                    result.itemGroup.ASI_CRM_CN_Pack_Value__c != null){
                    component.set("v.originalPriceCAWithVAT", result.originalPriceBTWithVAT * result.itemGroup.ASI_CRM_CN_Pack_Value__c);
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
    
    loadProductId: function (component) {
        var url = decodeURIComponent(window.location.search.substring(1));
        console.log('url' + url);
        var urlParams = url.split('&');
        var productParam;
        for (var i = 0; i < urlParams.length; i++) {
            productParam = urlParams[i].split('=');
            console.log('productParam' + productParam);
            if (productParam[0] === 'productId') {
                productParam[1] === undefined ? 0 : productParam[1];
                if (productParam[1] != 0) {
                    component.set("v.productId", productParam[1]);
                }
            }
            if (productParam[0] === 'orderId') {
                productParam[1] === undefined ? 0 : productParam[1];
                if (productParam[1] != 0) {
                    component.set("v.orderId", productParam[1]);
                }
            }
        }
    },

    handleOnChangedCANumber: function (component,event) {
        let target = event.getSource();
        let CANumber = target.get('v.value');
        let pack = component.get('v.pack');
        let product = component.get('v.product');
        product.BTNumber = CANumber * pack;
        component.set("v.product", product);
    },

    addToCart : function(component, event) {
        component.set('v.showSpinner', true);
        var orderId = component.get('v.orderId');
        console.log('orderId'+orderId);
        var selectedItem = event.currentTarget;
        console.log('selectedItem:'+selectedItem);
        selectedItem.disabled = true;
        console.log('dataset : ' + JSON.stringify(selectedItem.dataset));
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
            console.log('state'+state);
            if (state === "SUCCESS") {
                
                alert($A.get('$Label.c.ASI_CTY_CN_WS_Added_Successfully'));
                component.set('v.showSpinner', false);
                console.log($A.get('$Label.c.ASI_CTY_CN_WS_Added_Successfully'));
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/choose-product?orderId=" + orderId
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
                                        alert('Internal server error: ' + errors[i].pageErrors[j].message);

                                    }
                                }
                            }
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
    
    backToProductList: function(component,event){
        var orderId = component.get('v.orderId');
        console.log('orderId'+orderId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/choose-product?orderId=" + orderId
        });
        urlEvent.fire();
    },
    
    addEle: function(component,event){
        let target = event.getSource();
        let src = target.get('v.src');
        console.log('src' + JSON.stringify(src));
        if(src !== undefined && src !== '' && src !== null){
            // use DOM HTMLImageElement

            var photo = document.createElement('img');
            photo.src = src;
            photo.alt = 'product photo';
            photo.id = 'productImg';
            console.log('photo' + photo);
            
        }
        document.body.appendChild(photo);
        // get body width and height
        var sWidth = document.body.scrollWidth;
        var sHeight = document.body.scrollHeight;
        // console.log('sWidth: ' + sWidth + 'sHeight: ' + sHeight);

        // get img width and height
        var dWidth = photo.naturalWidth;
        var dHeight = photo.naturalHeight; 

        // set style
        photo.style.position = 'absolute';
        photo.style.zIndex = '1';
        photo.style.cursor = 'pointer';
        photo.style.border = '1px solid rgb(212, 212, 212)';
        photo.style.left = sWidth/2-dWidth/2+'px';
        // photo.style.top = sHeight/2-dHeight/2+'px';
        photo.style.top = '150px';  
    },
    removeEle: function(component,event){

        var img = document.getElementById('productImg');
        if(img !== '' && img !== null && img !== undefined){
            img.remove();
        }
    },

})