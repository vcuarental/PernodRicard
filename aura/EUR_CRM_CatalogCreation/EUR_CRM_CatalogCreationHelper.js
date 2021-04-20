({
    onInitHandler: function(cmp, helper) {

        var urlPrms = helper.getUrlParams(window.location.href);
        var recordTypeId = urlPrms['recordTypeId'] || null;
        if(!$A.util.isEmpty(recordTypeId)){
            // record type change should cause products to update too
            cmp.set('v.doUpdateProducts',true);
        }
        cmp.set('v.recordTypeId',recordTypeId);

        //helper.setAccountGroups(cmp);

        var recordId = cmp.get('v.recordId');
        var cloneRecordId = window.location.href.match(/(ct=)[\w]{18}/);
        var action = 'new';
        if(!$A.util.isEmpty(recordId)) {
            //console.log('Editing catalog Id: ' + recordId);
            action = 'edit';
            helper.loadCatalog(cmp, helper, recordId, true);
            helper.presetCloneSharing(cmp, helper, recordId);
        } else if(!$A.util.isEmpty(cloneRecordId)) {
            var cloneId = cloneRecordId[0].substring(3);
            //console.log('Clone catalog Id: ' + cloneId);
            action = 'clone';
            helper.loadCatalog(cmp, helper, cloneId, false);
            helper.presetCloneSharing(cmp, helper, cloneId);
        } else {
            // @edit 24.04.18 - brought back order type
            //helper.getOrderTypes(cmp);
            // load catalog -> get rectype -> get order types -> get products
            helper.getRecTypeDetails(cmp);
        }
        cmp.set('v.action', action);

        helper.setCatalogFieldLabels(cmp);
        helper.getCatalogHeaderInfo(cmp);
        helper.setDefaults(cmp);
        //helper.getProductList(cmp);
        helper.checkHasBegun(cmp, helper);
    },

    setDefaults: function(cmp) {
        var newAccountGroupData = {
            isSet: false,
            groupName: '',
            listViewId: '',
            accIds: '',
            recordsSource: '',
            type: ''
        }
        cmp.set('v.newAccountGroupData', newAccountGroupData);

        var productDisplayData = {
            productBrands: [],
            productBrandsFilter: ['All'],
            selectedProductBrands: [],
            selectedProductBrandsFilter: ['All'],
            collapsedItems: [],
            filter: 'All',
            searchFilter: '',
            selectedFilter: 'All',
            productsCount: 0,
            productsPagMessage: '',
            productsCountToShow: 99999,
            productsCurrentPage: 1,
            productsSelectedCount: 0,
            productsSelectedPagMessage: '',
            productsSelectedCountToShow: 99999,
            productsSelectedCurrentPage: 1
        };
        cmp.set('v.productDisplayData', productDisplayData);
    },

    getCatalogHeaderInfo: function(cmp) {
        var catalogHeaderInfo = {};
        var getCatalogHeaderInfo = cmp.get("c.getCatalogHeaderInfo");
        getCatalogHeaderInfo.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                catalogHeaderInfo.catalogLabel = result.catalogObjectLabel;
                catalogHeaderInfo.catalogIconName = 'custom:' + result.catalogIconName;
                cmp.set("v.catalogHeaderInfo", catalogHeaderInfo);
            }
        });
        $A.enqueueAction(getCatalogHeaderInfo);
    },

    getRecTypeDetails: function(cmp,result) {
        var recordTypeId = cmp.get("v.recordTypeId");
        console.log('==> Getting rec type by id: '+recordTypeId);
        //if(!$A.util.isEmpty(recordTypeId)){
        // if rt override is provided - check if it is template
        var getIsTempl = cmp.get("c.getRecTypeDevName");
        getIsTempl.setParams({ "rtId" : recordTypeId });

        getIsTempl.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var tuple = response.getReturnValue();

                cmp.set("v.recordTypeDevName",tuple.label);

                if($A.util.isEmpty(recordTypeId) && ($A.util.isUndefinedOrNull(result) || !$A.util.isEmpty(result.catalogRecTypeId) )){
                    // set to default rt, if not specified explicitly
                    // in url params, or pulled from catalog record
                    cmp.set("v.recordTypeId",tuple.value);
                }

                cmp.set("v.isTransfer", false);
                cmp.set("v.isTemplate", false);
                cmp.set("v.isReturn", false);
                cmp.set("v.isOrder", false);
                cmp.set("v.isPOSM", false);

                switch(tuple.label) {
                    case 'EUR_Indirect':
                        cmp.set("v.isTransfer", true);
                        break;
                    case 'EUR_Template':
                        cmp.set("v.isTemplate", true);
                        break;
                    case 'EUR_Credit_Note':
                        cmp.set('v.isReturn', true);
                        break;
                    case 'EUR_Direct':
                        cmp.set('v.isOrder', true);
                        break;
                    case 'EUR_POSM':
                        cmp.set("v.isPOSM", true);
                        break;
                }

                var catalog = cmp.get('v.catalog');
                // process fields dependent on RTs
                if(true != cmp.get('v.isReturn')){
                    catalog.ReturnReason__c = '';
                } else {
                    catalog.MininmumDeliveryDelay__c = null;
                }
                if(true == cmp.get('v.isTransfer')){
                    // transfer catalogs should be available for all
                    catalog.AvailableForAll__c = true;
                }

                if(result && true == cmp.get('v.isTransfer')){
                    //cmp.find('wholesaler').set('v.value',result.wholesalerId);
                }
                cmp.set('v.catalog',catalog);
                // get order types for known rec type
                this.getOrderTypes(cmp,result);
            }
            else if (cmp.isValid() && state === "INCOMPLETE") {
                alert('The server didn\'t return a response.');
            }
            //else if (cmp.isValid() && state === "ERROR") {
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(getIsTempl);
        //}
    },

    getOrderTypes: function(cmp,result) {

        var getOTypes = cmp.get("c.getOrderTypes");
        var recordTypeId = cmp.get("v.recordTypeId");


        getOTypes.setParams({ "rtId" : recordTypeId });

        getOTypes.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var orderTypes = response.getReturnValue();
                cmp.set("v.orderTypes", orderTypes);

                if($A.util.isArray(orderTypes)){
                    var cat = cmp.get('v.catalog');
                    var oldOTs = [];
                    var resOTs = [];
                    if(!$A.util.isUndefinedOrNull(result) && !$A.util.isUndefinedOrNull(result.catalogOrderType)){
                        // form array of order types saved on catalog
                        resOTs = result.catalogOrderType.split(';');
                        oldOTs = JSON.parse(JSON.stringify(resOTs));

                        var allowedVals = [];
                        for(var j=0; j<orderTypes.length; j++){
                            allowedVals.push(orderTypes[j].value);
                        }
                        for(var i=0; i<resOTs.length; i++){
                            var resOT = resOTs[i];
                            if(allowedVals.indexOf(resOT) == -1){
                                // remove by index, if not available for rt
                                resOTs.splice(i,1);
                            }
                        }
                        cat.OrderType__c = resOTs.join(';');
                        cmp.set('v.catalog',cat);

                    }

                    // if(($A.util.isUndefinedOrNull(cat.OrderType__c) || $A.util.isEmpty(cat.OrderType__c)) && orderTypes.length == 1){
                    // 	// set default
                    // 	cat.OrderType__c = orderTypes[0].value;
                    // 	resOTs = [orderTypes[0].value];
                    // 	cmp.set('v.catalog',cat);
                    // }

                    if(($A.util.isUndefinedOrNull(cat.OrderType__c) || $A.util.isEmpty(cat.OrderType__c)) && orderTypes.length >= 1){
                        // set default
                        console.log('Setting default ot'+JSON.stringify(orderTypes));
                        cat.OrderType__c = orderTypes.map(function(el){ return el.value; }).join(';');
                        resOTs = orderTypes.map(function(el){ return el.value; });
                        cmp.set('v.catalog',cat);
                    }


                    if(oldOTs.indexOf(cmp.get('v.presalesAPIName')) != resOTs.indexOf(cmp.get('v.presalesAPIName'))){
                        // changed presale status on load, so force product recalculation
                        //cmp.set('v.doUpdateProducts',true);
                    }
                    if(resOTs.indexOf(cmp.get('v.presalesAPIName')) != -1){
                        // loaded catalog is presale
                        cmp.set('v.isPresales',true);
                    }
                    // fetch products when record type details and presales status are known
                    this.getProductList(cmp);
                }

            }
            else if (cmp.isValid() && state === "INCOMPLETE") {
                alert('The server didn\'t return a response.');
            }
            //else if (cmp.isValid() && state === "ERROR") {
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(getOTypes);
    },

    setAccountGroups: function(cmp) {
        var getGroups = cmp.get("c.getAccountGroups");
        getGroups.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {

                var accountGroups = response.getReturnValue();
                cmp.set("v.accountGroups", accountGroups);
            }
            else if (cmp.isValid() && state === "INCOMPLETE") {
                alert('The server didn\'t return a response.');
            }
            //else if (cmp.isValid() && state === "ERROR") {
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(getGroups);
    },

    setCatalogFieldLabels: function(cmp) {
        var getCatalogFieldLabels = cmp.get("c.getCatalogFieldLabels");
        getCatalogFieldLabels.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var catalogFieldLabels = response.getReturnValue();
                cmp.set("v.catalogFieldLabels", catalogFieldLabels);
            }
            else if (cmp.isValid() && state === "INCOMPLETE") {
                alert('The server didn\'t return a response.');
            }
            //else if (cmp.isValid() && state === "ERROR") {
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(getCatalogFieldLabels);
    },

    presetCloneSharing : function (cmp, helper, parentId) {

        var getCloneSharing = cmp.get('c.getCloneSharing');
        getCloneSharing.setParams({ 'parentId': parentId });
        getCloneSharing.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                if (!$A.util.isEmpty(result)) {
                    for (let i = 0; i < result.length; i++) {
                        result[i].Id = null;
                        result[i].ParentId = null;
                    }

                    cmp.find('sharing').setRecords(result);
                }
            }
        });
        $A.enqueueAction(getCloneSharing);
    },

    loadCatalog: function(cmp, helper, catalogId, toCloneIdField) {
        helper.showSpinner(cmp);
        var action = cmp.get('c.getCatalogData');
        action.setParams({ 'catalogId' : catalogId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === 'SUCCESS') {
                var result = JSON.parse(response.getReturnValue());
                console.log(result);
                // loading catalog info
                var catalog = cmp.get('v.catalog');
                //catalog.OrderType__c = result.catalogOrderType;
                //catalog.AvailableForAll__c = result.availableForAll;
                catalog.ViewName1__c = result.viewName1;
                catalog.ViewName2__c = result.viewName2;

                cmp.find('accountGroup').set('v.value',result.groupId);

                catalog.RecordTypeId = result.catalogRecTypeId;
                //catalog.Wholesaler__c = result.wholesalerId;
                //catalog.PricingSchemaSAP__c = result.sapPricing;
                catalog.FuturePricingDate__c = result.pricingDate;

                if(toCloneIdField) catalog.Id = catalogId;
                /*
                if(!$A.util.isEmpty(catalog.OrderType__c) && catalog.OrderType__c.indexOf('Credit_Note') != -1) {
                    catalog.ReturnReason__c = result.catalogReturnReason;
                    cmp.set('v.isReturn', true);
                }
                 */

                catalog.ReturnReason__c = result.catalogReturnReason;

                //console.log('catalog', catalog);

                cmp.set('v.catalog', catalog);
                cmp.set('v.isDynamic', result.isDynamic);
                cmp.set('v.hasBegun', result.hasBegun);
                cmp.set('v.today', result.today);
                cmp.set('v.templDelDates', result.templDelDates || []);

                if(!cmp.get('v.recordTypeId')){
                    cmp.set('v.recordTypeId',result.catalogRecTypeId);
                }
                // @edit 24.04.18 - brought back order type
                //helper.getOrderTypes(cmp,result);
                cmp.find('catalogName').set('v.value', result.catalogName);
                cmp.find('viewName1').set('v.value', result.viewName1);
                if(cmp.find('viewName2')){
                    cmp.find('viewName2').set('v.value', result.viewName2);
                }
                if(cmp.find('isDynamic')){
                    cmp.find('isDynamic').set('v.value', result.isDynamic);
                }


                // TODO: check why though?
                // ensure dates are correctly padded for ISO specifiaction
                // Safari considers date illegal without padding
                cmp.find('startDateField').set('v.value', result.startDate[0] + "-" + ("0" + result.startDate[1]).slice(-2) + "-" + ("0" + result.startDate[2]).slice(-2));
                cmp.find('endDateField').set('v.value', result.endDate[0] + "-" + ("0" + result.endDate[1]).slice(-2) + "-" + ("0" + result.endDate[2]).slice(-2));
                // check record type and edit related fields
                helper.getRecTypeDetails(cmp,result);

                // loading catalog items info
                var loadedProducts = [];
                result.productsInfo.forEach(function(data) {
                    if(result.isDynamic) {
                        loadedProducts.push({
                            OrderView1: data.OrderView1,
                            OrderView2: data.OrderView2,
                            multiplication_factor: data.multiplication_factor,
                            ProductLevel1: data.ProductLevel1,
                            ProductLevel2: data.ProductLevel2,
                            ProductLevel3: data.ProductLevel3,
                            ProductLevel4: data.ProductLevel4,
                            ProductLevel5: data.ProductLevel5,
                            View1Level1: data.View1Level1,
                            View1Level2: data.View1Level2,
                            View1Level3: data.View1Level3,
                            View1Level4: data.View1Level4,
                            MarketingLevel1: data.MarketingLevel1,
                            MarketingLevel2: data.MarketingLevel2,
                            MarketingLevel3: data.MarketingLevel3,
                            MarketingLevel4: data.MarketingLevel4,
                            View2Level1: data.View2Level1,
                            View2Level2: data.View2Level2,
                            View2Level3: data.View2Level3,
                            View2Level4: data.View2Level4,
                            // inject data
                            ExpectAvailabiltyDate: data.ExpectAvailabiltyDate,
                            MinQty: data.MinQty,
                            MaxQty: data.MaxQty,
                            DelStart: data.DelStart,
                            DelEnd: data.DelEnd,
                            Pckg: data.Pckg,
                            TemplQty: data.TemplQty,
                            Price: data.Price,
                            OOSStart : data.OOSStart,
                            OOSEnd : data.OOSEnd,
                            PrStart : data.PrStart,
                            PrEnd : data.PrEnd,
                            templPBIs: data.templPBIs
                        });
                    } else {
                        loadedProducts.push({
                            Id: data.productId,
                            OrderView1: data.OrderView1,
                            OrderView2: data.OrderView2,
                            multiplication_factor: data.multiplication_factor,
                            View1Level1: data.View1Level1,
                            View1Level2: data.View1Level2,
                            View1Level3: data.View1Level3,
                            View1Level4: data.View1Level4,
                            View2Level1: data.View2Level1,
                            View2Level2: data.View2Level2,
                            View2Level3: data.View2Level3,
                            View2Level4: data.View2Level4,

                            ExpectAvailabiltyDate: data.ExpectAvailabiltyDate,
                            MinQty: data.MinQty,
                            MaxQty: data.MaxQty,
                            DelStart: data.DelStart,
                            DelEnd: data.DelEnd,
                            Pckg: data.Pckg,
                            TemplQty: data.TemplQty,
                            Price: data.Price,
                            OOSStart : data.OOSStart,
                            OOSEnd : data.OOSEnd,
                            PrStart : data.PrStart,
                            PrEnd : data.PrEnd,
                            templPBIs: data.templPBIs,
                            dynamicfields: data.dynamicfields,
                            pbi: data.pbi
                        });
                    }
                });
                //console.log('loadedProducts', loadedProducts);
                cmp.set("v.loadedProducts", loadedProducts);
                helper.hideSpinner(cmp);
            } else if (cmp.isValid() && state === 'INCOMPLETE') {
                console.log("Call of getModel() INCOMPLETE");
            } else if (cmp.isValid() && state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error('Error message: ' +
                            errors[0].message);
                    }
                } else {
                    console.log('Unknown error');
                }
            }
        });
        $A.enqueueAction(action);
    },

    moveToTheNextStep: function(cmp, isSAPCodesSelection) {
        var
            helper = this,
            currentStep = parseInt(cmp.get('v.currentStep')),
            isDynamic = cmp.get('v.isDynamic');
        console.log('currentStep => ', currentStep);

        if(currentStep == 1) {
            try {
                helper.validateCatalogInputs(cmp);
            } catch(e) {
                cmp.set('v.errorMessage', { isError: true, title: $A.get("$Label.c.EUR_CRM_Error"), message: e.message} );
                return;
            }
            var
                viewName1 = cmp.find('viewName1'),
                viewName1Value = viewName1.get('v.value') || '',
                viewName2 = cmp.find('viewName2'),
                viewName2Value = viewName2 ? viewName2.get('v.value') : '',
                hierarchyViews = cmp.get('v.hierarchyViews'),
                hierarchyDepths = cmp.get('v.hierarchyDepths'),
                droppedItems = cmp.get('v.droppedItems'),
                hierarchyMap = cmp.get('v.hierarchyBuildingItems'),
                productsDataMaster = cmp.get('v.productsDataMaster'),
                productDisplayData = cmp.get('v.productDisplayData'),
                products = cmp.get('v.products'),
                loadedProducts = cmp.get('v.loadedProducts'),
                isDynamicChbx = cmp.find('isDynamic') ? cmp.find('isDynamic').get('v.value') : false,
                isReturn = cmp.get('v.isReturn'),
                dynamicChanged = false,
                viewsChanged = false;

            if($A.util.isUndefinedOrNull(isDynamic) || isDynamic != isDynamicChbx) {
                isDynamic = isDynamicChbx;
                dynamicChanged = true;
            }
            cmp.set('v.isDynamic', isDynamic);

            if(!hierarchyViews || viewName1Value.trim() != hierarchyViews[0] ||
                (!viewName2Value && hierarchyViews[1]) ||
                (viewName2Value && viewName2Value.trim() != hierarchyViews[1])) {
                viewsChanged = true;
                hierarchyViews = [];
                if(viewName1Value) hierarchyViews.push(viewName1Value.trim());
                if(viewName2Value && viewName2Value.trim()) hierarchyViews.push(viewName2Value.trim());
                if(!hierarchyDepths) hierarchyDepths = {};
                if(!droppedItems) droppedItems = {};
                if(!hierarchyMap) hierarchyMap = {};
                hierarchyViews.forEach( function(view) {
                    // Set default hierarchy depth equal to 1 for each view
                    if(!hierarchyDepths[view]) hierarchyDepths[view] = 1;
                    // Initialize dropped items list for each view
                    if(!droppedItems[view]) droppedItems[view] = [];
                    // Initialize hierarchy list for each view
                    if(!hierarchyMap[view]) hierarchyMap[view] = [
                        {
                            LevelName: '',
                            SubLevels: [],
                            collapsed: false
                        }
                    ];
                });
                cmp.set('v.activeView', hierarchyViews[0]);
                cmp.set("v.hierarchyBuildingItems", hierarchyMap);
                cmp.set('v.hierarchyViews', hierarchyViews);
                cmp.set('v.hierarchyDepths', hierarchyDepths);
                cmp.set('v.droppedItems', droppedItems);
            }
            // Get products for the first load
            /*
            if($A.util.isUndefinedOrNull(productsDataMaster) || $A.util.isEmpty(productsDataMaster)) {
                helper.getProductList(cmp, currentStep, isDynamic);
            }
             */
            // Re-generate products in case order Dynamic is changed
            //else if(dynamicChanged) {
            if(dynamicChanged || !products.length) {
                var products = productsDataMaster;
                if(!isReturn) products = helper.filterProductsByStatus(products, true);
                if(isDynamic) products = helper.generateDynamicProductList(products);
                if(loadedProducts && loadedProducts.length) helper.getSelectedFromLoadedProducts(cmp, products, loadedProducts);
                cmp.set('v.products', products);
                helper.setCollapsedItems(cmp, products);
                helper.changeProductDisplay(cmp, productDisplayData.productsCurrentPage, productDisplayData.productsCountToShow, null, true);

            }
            // Just add|remove inactive products depends on Order Type value
            else {

                var isInactiveInList = false;
                var toChangeDisplay = false;
                products.forEach(function(product) {
                    if(!product.isActive) isInactiveInList = true;
                });
                if(isReturn && !isInactiveInList) {
                    var inactiveProducts = [];
                    productsDataMaster.forEach(function(product) {
                        if(!product.isActive) inactiveProducts.push(product);
                    });
                    if(inactiveProducts.length) {
                        products = products.concat(inactiveProducts);
                        toChangeDisplay = true;
                    }
                } else if(!isReturn && isInactiveInList) {
                    products = helper.filterProductsByStatus(products, true);
                    toChangeDisplay = true;
                }
                cmp.set('v.products', products);
                if(toChangeDisplay) {
                    helper.setCollapsedItems(cmp, products);
                    helper.changeProductDisplay(cmp, productDisplayData.productsCurrentPage, productDisplayData.productsCountToShow, null, true);
                }
                cmp.set('v.currentStep', currentStep + 1);
            }
        } else if(currentStep == 2) {
            try {
                var
                    products = cmp.get("v.products"),
                    productDisplayData = cmp.get("v.productDisplayData"),
                    selectedProducts = [],
                    activeView = cmp.get("v.activeView"),
                    hierarchyViews = cmp.get('v.hierarchyViews'),
                    checked,
                    hierarchyFields = [];

                if(isDynamic && hierarchyViews.length > 1) {
                    if(activeView == hierarchyViews[0]) {
                        checked = false;
                    } else {
                        checked = true;
                    }
                } else if(isDynamic && hierarchyViews.length == 1) {
                    checked = cmp.find('hierarchyView').get('v.checked');
                }
                var selectedProductBrands = [];
                var productBrandField = 'ProductLevel1Description';
                products.forEach(function(product) {
                    if(product.checked) {
                        selectedProducts.push(product);
                        var productBrand = product[productBrandField] || product[productBrandField.replace('Description', '')];
                        if(selectedProductBrands.indexOf(productBrand) == -1) {
                            selectedProductBrands.push(productBrand);
                        }
                    }
                });
                productDisplayData.selectedProductBrands = selectedProductBrands;
                if(!selectedProducts.length) {
                    throw new Error($A.get("$Label.c.EUR_CRM_CG_NoProductsSelected"));
                }
                if(!isDynamic) {
                    console.log('selectedProducts => ', selectedProducts);
                    helper.setCollapsedItems(cmp, selectedProducts);
                    productDisplayData.productsSelectedCount = selectedProducts.length;
                } else {
                    var
                        checked = cmp.find('hierarchySelectedView').get('v.checked'),
                        dynamicLowestSelectedLevel = cmp.get("v.dynamicLowestSelectedLevel"),
                        view1hierarchyFields = helper.getHierarchyFields(cmp, null, false),
                        view2hierarchyFields = helper.getHierarchyFields(cmp, null, true),
                        maxLevelPV = 0,
                        maxLevelMV = 0;
                    // define what lower level will be used for each view
                    for(var key in dynamicLowestSelectedLevel) {
                        if(key.startsWith('PV') && maxLevelPV < dynamicLowestSelectedLevel[key]) {
                            maxLevelPV = dynamicLowestSelectedLevel[key];
                        } else if(key.startsWith('MV') && maxLevelMV < dynamicLowestSelectedLevel[key]) {
                            maxLevelMV = dynamicLowestSelectedLevel[key];
                        }
                    }
                    // cut hierarchy field with the lowest depths selected
                    view1hierarchyFields.length = maxLevelPV;
                    view2hierarchyFields.length = maxLevelMV;
                    cmp.set('v.hierarchyFields1', view1hierarchyFields);
                    cmp.set('v.hierarchyFields2', view2hierarchyFields);
                    // using selected products and hierarchy fields for each view
                    // gather unique product and marketing categories separated by special tag
                    var
                        productData = [],
                        productViewCategories = { display: [], code: [] },
                        marketingViewCategories = { display: [], code: [] },
                        multipliedViewCategories = { display: [], code: [] },
                        oneViewMode = false;
                    separator = '<cat>';

                    console.log('selectedProducts', selectedProducts);
                    selectedProducts.forEach(function(product){
                        var hierarchyFieldsToUse;
                        var categoriesToFill;
                        var categoryPath = {
                            display: '',
                            code: ''
                        };
                        if(product.Id.startsWith('PV')) {
                            hierarchyFieldsToUse = view1hierarchyFields;
                            categoriesToFill = productViewCategories;
                        } else if(product.Id.startsWith('MV')) {
                            hierarchyFieldsToUse = view2hierarchyFields;
                            categoriesToFill = marketingViewCategories;
                        }
                        hierarchyFieldsToUse.forEach(function(field) {
                            categoryPath.display += product[field] + separator;
                            var codeLabel = product[field.replace('Description', '')] || product[field];
                            categoryPath.code += codeLabel + separator;
                        });
                        for(var key in categoryPath) {
                            categoryPath[key] = categoryPath[key].substr(0, categoryPath[key].length - separator.length);
                        }
                        if(categoryPath.code && categoriesToFill.code.indexOf(categoryPath.code) == -1) {
                            categoriesToFill.display.push(categoryPath.display);
                            categoriesToFill.code.push(categoryPath.code);
                        }
                    });
                    console.log('productViewCategories', productViewCategories);
                    console.log('marketingViewCategories', marketingViewCategories);
                    // 1) define the state of checkbox for switching view on the 3rd step
                    // 2) choose what categories will be multiplied by another
                    // 3) define what hierarchyFields going first in each multiplied category path
                    var
                        mainCategory,
                        mainHierarchyFields,
                        secondaryCategory,
                        secondaryHierarchyFields,
                        hierarchyDisplayField,
                        fieldsPosition;

                    mainCategories = !checked ? productViewCategories : marketingViewCategories;
                    mainHierarchyFields = !checked ? view1hierarchyFields : view2hierarchyFields;
                    secondaryCategories = !checked ? marketingViewCategories : productViewCategories;
                    secondaryHierarchyFields = !checked ? view2hierarchyFields : view1hierarchyFields;
                    hierarchyDisplayField = !checked ? 'Name' : 'SecondaryName';
                    fieldsPosition = !checked ? ['Name', 'SecondaryName'] : ['SecondaryName', 'Name'];
                    // Multiply categories by each other
                    if(mainCategories.code.length && secondaryCategories.code.length) {
                        for(var key in multipliedViewCategories) {
                            mainCategories[key].forEach(function(mc){
                                secondaryCategories[key].forEach(function(sc){
                                    multipliedViewCategories[key].push(mc + separator + sc);
                                });
                            });
                        }
                        oneViewMode = false;
                        cmp.set('v.oneViewMode', oneViewMode);
                    } else {
                        multipliedViewCategories = mainCategories.code.length ? mainCategories : secondaryCategories;
                        oneViewMode = true;
                        cmp.set('v.oneViewMode', oneViewMode);
                    }
                    console.log('multipliedViewCategories', multipliedViewCategories);
                    // Using multiplied View Categories create a new set of data that will be used
                    // in dynamic catalog generation
                    // each category is treated as a product
                    multipliedViewCategories['code'].forEach(function(dynamicCategory, index) {
                        var
                            obj = {
                                Id : dynamicCategory,
                                checked : true
                            }, // a new product that represents category
                            codeDynamicPath = dynamicCategory.split(separator); // list with product and marketing categories codes
                        labelDynamicPath = multipliedViewCategories['display'][index].split(separator); // list with product and marketing categories labels
                        // first categories are gathered from main category fields, so using index
                        // getting field names and appropriate values in the list of categories
                        // and setting as the product's attributes
                        mainHierarchyFields.concat(secondaryHierarchyFields).forEach(function(field, index) {
                            obj[field] = labelDynamicPath[index];
                            obj[field.replace('Description', '')] = codeDynamicPath[index];
                            // last field in each hierarchy fields list is used in a new product name for each hierarchy
                            if(mainHierarchyFields.length && mainHierarchyFields.length == index + 1 ||
                                (!mainHierarchyFields.length && secondaryHierarchyFields.length && secondaryHierarchyFields.length == index + 1)) {
                                var displayValue = labelDynamicPath[index] || codeDynamicPath[index];
                                obj[fieldsPosition[0]] = displayValue;
                                obj[fieldsPosition[1]] = displayValue;
                            } else if(mainHierarchyFields.length && secondaryHierarchyFields.length && mainHierarchyFields.length + secondaryHierarchyFields.length == index + 1) {
                                var displayValue = labelDynamicPath[index] || codeDynamicPath[index];
                                obj[fieldsPosition[0]] += ' - ' + displayValue;
                                obj[fieldsPosition[1]] = displayValue + ' - ' + obj[fieldsPosition[1]];
                            }
                        });
                        // in case the last hierarchy fields have similar names
                        // additional value from hierarchy level above will be added
                        var
                            searchSimilarNames = true,
                            searchValuesDepth = 2, // start search from the next after the last item in list
                            fieldIndexes = [0 , 1],
                            fieldsToSearch = view1hierarchyFields;
                        while(searchSimilarNames) {
                            var isFound = false;
                            var fieldsLength = fieldsToSearch.length;
                            productData.forEach(function(product){
                                if(product.Name == obj.Name || product.SecondaryName == obj.SecondaryName) {
                                    var
                                        productNameSplit = product.Name.split(' - '),
                                        productSecondaryNameSplit = product.SecondaryName.split(' - '),
                                        objNameSplit = obj.Name.split(' - '),
                                        objSecondaryNameSplit = obj.SecondaryName.split(' - '),
                                        prevField = fieldsToSearch[fieldsLength - searchValuesDepth],
                                        prevProductFieldValue, prevObjFieldValue;
                                    if(prevField) {
                                        prevProductFieldValue = product[prevField];
                                        prevObjFieldValue = obj[prevField];
                                        productNameSplit[fieldIndexes[0]] = prevProductFieldValue + ' ' + productNameSplit[fieldIndexes[0]];
                                        productSecondaryNameSplit[fieldIndexes[1]] = prevProductFieldValue + ' ' + productSecondaryNameSplit[fieldIndexes[1]];
                                        product.Name = productNameSplit.join(' - ');
                                        product.SecondaryName = productSecondaryNameSplit.join(' - ');
                                        objNameSplit[fieldIndexes[0]] = prevObjFieldValue + ' ' + objNameSplit[fieldIndexes[0]];
                                        objSecondaryNameSplit[fieldIndexes[1]] = prevObjFieldValue + ' ' + objSecondaryNameSplit[fieldIndexes[1]];
                                        obj.Name = objNameSplit.join(' - ');
                                        obj.SecondaryName = objSecondaryNameSplit.join(' - ');
                                    } else {
                                        searchValuesDepth = 2;
                                        fieldsToSearch = view2hierarchyFields;
                                        searchSimilarNames = true;
                                        fieldIndexes = [1 , 0];
                                    }
                                    if(product.Name == obj.Name || product.SecondaryName == obj.SecondaryName) {
                                        isFound = true;
                                    }
                                }
                            });
                            searchSimilarNames = isFound;
                            searchValuesDepth++;
                            if(searchValuesDepth > 5) searchSimilarNames = false;
                        }
                        productData.push(obj);
                    });
                    //console.log('productData', productData);
                    helper.setCollapsedItems(cmp, []);
                    productDisplayData.productsSelectedCount = productData.length;
                    cmp.set('v.dynamicProductData', productData);
                }
                cmp.set('v.productDisplayData', productDisplayData);
                helper.buildViewsFromLoadedProducts(cmp);
                helper.switchSelectedProductsView(cmp, null, cmp.find('hierarchySelectedView').get('v.checked'), true);
            } catch(e) {
                cmp.set('v.errorMessage', { isError: true, title: $A.get("$Label.c.EUR_CRM_Error"), message: e.message} );
                return;
            }
        }
    },

    moveToThePrevStep: function(cmp) {
        var currentStep = cmp.get('v.currentStep');
        if(currentStep == 3) {
            this.setCollapsedItems(cmp, cmp.get('v.products'));
            cmp.set('v.oneViewMode', false);
        }
        cmp.set('v.currentStep', currentStep - 1);
    },

    /* Function to get product list from controller and build hierarchy based on toggle checkbox
    * on the 3rd step
    */
    getProductList: function(cmp) {
        var
            helper = this,
            productBrands = [],
            productBrandField = 'ProductLevel1Description',
            productDisplayData = cmp.get('v.productDisplayData'),
            action = cmp.get("c.getProductList");

        action.setParams({ "catalogRecordTypeDevName" : cmp.get("v.recordTypeDevName") });

        //helper.showSpinner(cmp);
        // lock buttons
        var nsCmps = cmp.find('nextStep');
        for(let i=0; i<nsCmps.length; i++){
            nsCmps[i].set("v.disabled", true);
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                var productsDataMaster = [];
                result.forEach(function(item) {
                    var product = item;
                    product.Id = item.productId;
                    product.checked = false;
                    productsDataMaster.push(product);
                    var productBrand = item[productBrandField] || item[productBrandField.replace('Description', '')];
                    if(productBrands.indexOf(productBrand) == -1) {
                        productBrands.push(productBrand);
                    }
                });
                cmp.set('v.productsDataMaster', productsDataMaster);
                //console.log('Product data master'+JSON.stringify(productsDataMaster));
                productDisplayData.productBrands = productBrands ? productBrands.sort() : [];
                productDisplayData.productsCount = productsDataMaster.length;
                cmp.set('v.productDisplayData', productDisplayData);
                // unlock next step button
                // do not concat, as Safari
                // breaks on setting attributes to
                // components that have been concated
                // since api 39.0
                var nsCmps = cmp.find('nextStep');
                for(let i=0; i<nsCmps.length; i++){
                    nsCmps[i].set("v.disabled", false);
                }

            } else if (cmp.isValid() && state === "INCOMPLETE") {
                alert('The server didn\'t return a response.');
            } else if (cmp.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        cmp.find('msgs').showNotice({
                            "variant": "error",
                            "header": "Something has gone wrong!",
                            "message": errors[0].message,
                            closeCallback: function() {

                            }
                        });
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    generateDynamicProductList: function(products) {
        var dynamicProducts = [];
        products.forEach(function(product) {
            dynamicProducts.push({
                Name: product.Name,
                ProductSAPcode: product.ProductSAPcode,
                NationalCode: product.NationalCode,
                EAN: product.EAN,
                Id: 'PV' + product.Id,
                ProductLevel1 : product.ProductLevel1,
                ProductLevel2 : product.ProductLevel2,
                ProductLevel3 : product.ProductLevel3,
                ProductLevel4 : product.ProductLevel4,
                ProductLevel5 : product.ProductLevel5,
                ProductLevel1Description : product.ProductLevel1Description,
                ProductLevel2Description : product.ProductLevel2Description,
                ProductLevel3Description : product.ProductLevel3Description,
                ProductLevel4Description : product.ProductLevel4Description,
                ProductLevel5Description : product.ProductLevel5Description,
                checked: false,
                isActive: product.isActive
            });
            dynamicProducts.push({
                Name: product.Name,
                ProductSAPcode: product.ProductSAPcode,
                Id: 'MV' + product.Id,
                MarketingLevel1 : product.MarketingLevel1,
                MarketingLevel2 : product.MarketingLevel2,
                MarketingLevel3 : product.MarketingLevel3,
                MarketingLevel4 : product.MarketingLevel4,
                MarketingLevel1Description : product.MarketingLevel1Description,
                MarketingLevel2Description : product.MarketingLevel2Description,
                MarketingLevel3Description : product.MarketingLevel3Description,
                MarketingLevel4Description : product.MarketingLevel4Description,
                checked: false,
                isActive: product.isActive
            });
        });
        return dynamicProducts;
    },

    getSelectedFromLoadedProducts: function(cmp, products, loadedProducts) {
        var
            helper = this,
            isDynamic = cmp.get('v.isDynamic'),
            productFields = { name: 'ProductLevel', count: 5},
            marketingFields = { name: 'MarketingLevel', count: 4},
            loadedProductsMap = {},
            dynamicLowestSelectedLevel = {};

        loadedProducts.forEach(function(product) {
            if(isDynamic) {
                let
                    productPath = '',
                    productDepth = 0,
                    marketingPath = '',
                    marketingDepth = 0;

                for(let i = 1; i <= productFields.count; i++) {
                    let loadedValue = product[productFields.name + i];
                    if(loadedValue) {
                        productPath += loadedValue
                        productDepth++;
                    }
                }
                for(let i = 1; i <= marketingFields.count; i++) {
                    let loadedValue = product[marketingFields.name + i];
                    if(loadedValue) {
                        marketingPath += loadedValue
                        marketingDepth++;
                    }
                }
                product.productDepth = productDepth;
                loadedProductsMap[productPath] = product;
                product.marketingDepth = marketingDepth;
                loadedProductsMap[marketingPath] = product;
            } else {
                loadedProductsMap[product.Id] = product;
            }
        });
        products.forEach(function(product) {
            product.checked = false;
            if(isDynamic) {
                let fieldsToCompare = product.Id.startsWith('PV') ? productFields : marketingFields;
                let productIdentifier = '';
                for(let i = 1; i <= fieldsToCompare.count; i++) {
                    productIdentifier += product[fieldsToCompare.name + i];
                    let loadedProduct = loadedProductsMap[productIdentifier];
                    if(loadedProduct) {
                        loadedProduct.isFound = true;
                        product.checked = true;
                        dynamicLowestSelectedLevel[product.Id] = product.Id.startsWith('PV') ? loadedProduct.productDepth : loadedProduct.marketingDepth;
                        break;
                    }
                }
            } else {
                let loadedProduct = loadedProductsMap[product.Id];
                if(loadedProduct) {
                    loadedProduct.isFound = true;
                    product.checked = true;

                    product.multiplication_factor = loadedProduct.multiplication_factor;
                    // TODO: inject here?
                    // loaded product - wrapper for the actual pbi for the pricebook
                    // product - ctpg_product object wrapper
                    product.MinQty = loadedProduct.MinQty ? loadedProduct.MinQty : product.MinQtyP;
                    product.MaxQty = loadedProduct.MaxQty ? loadedProduct.MaxQty : product.MaxQtyP;

                    product.DelStart = loadedProduct.DelStart ? loadedProduct.DelStart : product.DelStartP;
                    product.DelEnd = loadedProduct.DelEnd ? loadedProduct.DelEnd : product.DelEndP;

                    product.Pckg = loadedProduct.Pckg ? loadedProduct.Pckg : product.PckgP;
                    product.TemplQty = loadedProduct.TemplQty ? loadedProduct.TemplQty : product.TemplQtyP;
                    product.Price = loadedProduct.Price ? loadedProduct.Price : null;

                    product.OOSStart = loadedProduct.OOSStart ? loadedProduct.OOSStart : product.OOSStart;
                    product.OOSEnd = loadedProduct.OOSEnd ? loadedProduct.OOSEnd : product.OOSEnd;
                    product.PrStart = loadedProduct.PrStart ? loadedProduct.PrStart : product.PrStart;
                    product.PrEnd = loadedProduct.PrEnd ? loadedProduct.PrEnd : product.PrEnd;
                    product.templPBIs = loadedProduct.templPBIs ? loadedProduct.templPBIs : [];

                    //console.log('Product '+JSON.stringify(product));
                    //console.log('Loaded Product '+JSON.stringify(loadedProduct));
                }
            }
        });
        console.log('dynamicLowestSelectedLevel', dynamicLowestSelectedLevel);
        cmp.set("v.dynamicLowestSelectedLevel", dynamicLowestSelectedLevel);
        var availableLoadedProducts = [];
        loadedProducts.forEach(function(loaded_product) {
            if(loaded_product.isFound) {
                availableLoadedProducts.push(loaded_product);
            }
        });
        cmp.set("v.loadedProducts", availableLoadedProducts);

    },

    buildViewsFromLoadedProducts: function(cmp) {
        var loadedProducts = cmp.get('v.loadedProducts');
        // console.log('loadedProducts', loadedProducts);
        // console.log('isDynamic => ', cmp.get('v.isDynamic'));
        if(!loadedProducts || !loadedProducts.length) return;
        var
            helper = this,
            droppedItems = cmp.get('v.droppedItems'),
            isDynamic = cmp.get('v.isDynamic'),
            products = isDynamic ? cmp.get('v.dynamicProductData') : cmp.get('v.products'),
            views = cmp.get('v.hierarchyViews'),
            hierarchyBuildingItems = {},
            hierarchyDepths = {},
            hierarchyFields1 = helper.getHierarchyFields(cmp, null, false),
            hierarchyFields2 = helper.getHierarchyFields(cmp, null, true),
            view1Fields = ['View1Level1', 'View1Level2', 'View1Level3', 'View1Level4'],
            view2Fields = ['View2Level1', 'View2Level2', 'View2Level3', 'View2Level4'],
            viewStartFields = ['View1Level1', 'View2Level1'];

        loadedProducts.forEach(function(loaded_product) {
            // set hierarchyDepths on each view and set views
            var view1HierarchyDepth = 0;
            var view2HierarchyDepth = 0;
            var hierarchyView1Path = [];
            var hierarchyView2Path = [];
            view1Fields.forEach(function(field) {
                if(loaded_product[field]) {
                    view1HierarchyDepth++;
                    hierarchyView1Path.push(loaded_product[field]);
                }
            });
            view2Fields.forEach(function(field) {
                if(loaded_product[field]) {
                    view2HierarchyDepth++;
                    hierarchyView2Path.push(loaded_product[field]);
                }
            });
            console.log('hierarchyView1Path', hierarchyView1Path);
            if(hierarchyView1Path.length && views[0]) {
                hierarchyBuildingItems = helper.addLoadedCategory(hierarchyBuildingItems, hierarchyView1Path, views[0]);
            }
            console.log('hierarchyView2Path', hierarchyView2Path);
            if(hierarchyView2Path.length && views[1]) {
                hierarchyBuildingItems = helper.addLoadedCategory(hierarchyBuildingItems, hierarchyView2Path, views[1]);
            }
            if(!hierarchyDepths[views[0]] || hierarchyDepths[views[0]] < view1HierarchyDepth) hierarchyDepths[views[0]] = view1HierarchyDepth;
            if(!hierarchyDepths[views[1]] || hierarchyDepths[views[1]] < view2HierarchyDepth) hierarchyDepths[views[1]] = view2HierarchyDepth;
        });
        views.forEach(function(viewName) {
            if(!hierarchyBuildingItems[viewName] || !hierarchyBuildingItems[viewName].length) {
                hierarchyBuildingItems[viewName] = [{
                    LevelName: '',
                    SubLevels: [],
                    collapsed: true
                }];
            } else {
                helper.removeEmptyBranches(helper, hierarchyBuildingItems[viewName], 0, hierarchyDepths[viewName]);
            }
        });
        console.log('hierarchyDepths', hierarchyDepths);
        cmp.set('v.hierarchyDepths', hierarchyDepths);
        console.log('hierarchyBuildingItems', hierarchyBuildingItems);
        cmp.set('v.hierarchyBuildingItems', hierarchyBuildingItems);
        // set dropped items
        droppedItems = {};
        views.forEach(function(viewName) {
            if(!droppedItems[viewName]) droppedItems[viewName] = [];
        });
        var productDataMap = {};
        products.forEach(function(product) {
            console.log('products.forEach product => ', product);
            if(product.checked) {
                productDataMap[product.Id] = product;
            }
        });

        loadedProducts.forEach(function(loaded_product) {
            var matchedProduct;
            var sequenceInViews = [loaded_product.OrderView1, loaded_product.OrderView2];
            if(!isDynamic) {
                // console.log('!isDynamic');
                // console.log('loaded_product => ', loaded_product);
                // console.log('productDataMap => ', productDataMap);
                if ( ! productDataMap[loaded_product.Id]) { return; }
                matchedProduct = productDataMap[loaded_product.Id];
                matchedProduct.dynamicfields = loaded_product.dynamicfields;
                matchedProduct.pbi = loaded_product.pbi;
            } else {
                var separator = '<cat>';
                var loadedProductIdentifier = '';
                var productHierarchyPath = '';
                hierarchyFields1.concat(hierarchyFields2).forEach(function(field) {
                    var loadedValue = loaded_product[field.replace('Description', '')];
                    if(loadedValue) {
                        loadedProductIdentifier += loadedValue + separator;
                        productHierarchyPath += loadedValue + '<path>';
                    }
                });
                loadedProductIdentifier = loadedProductIdentifier.substr(0, loadedProductIdentifier.length - separator.length);
                var product = productDataMap[loadedProductIdentifier];
                if(product) {
                    matchedProduct = {
                        Id: product.Id,
                        Name: product.Name,
                        Path: productHierarchyPath
                    };
                }
            }
            if(matchedProduct) {
                console.log('matchedProduct => ', matchedProduct);
                viewStartFields.forEach(function(initField, index) {
                    if(views[index] && loaded_product[initField]) {
                        var droppedProduct = { product : matchedProduct };
                        if(!droppedItems[views[index]]) droppedItems[views[index]] = [];
                        droppedProduct.branchIndex = 'branch';
                        var branches = hierarchyBuildingItems[views[index]];
                        var fieldsToCompare = index == 0 ? view1Fields : view2Fields;
                        var indexSeparator = '__';
                        fieldsToCompare.forEach(function(field) {
                            if(loaded_product[field]) {
                                var hierarchyObjectIndex = helper.arrayObjectIndexOf(branches, loaded_product[field], 'Id');
                                if(hierarchyObjectIndex != -1) {
                                    droppedProduct.branchIndex += '-' + hierarchyObjectIndex;
                                    branches = branches[hierarchyObjectIndex].SubLevels;
                                }
                            }
                        });
                        if(sequenceInViews[index]) {
                            droppedItems[views[index]][sequenceInViews[index]] = droppedProduct;
                        } else {
                            droppedItems[views[index]].push(droppedProduct);
                        }
                    }
                });
            }
        });
        views.forEach(function(viewName) {
            if(droppedItems[viewName] && droppedItems[viewName].length) {
                for(var i = droppedItems[viewName].length - 1; i >= 0; i--) {
                    if(droppedItems[viewName][i] === undefined) {
                        droppedItems[viewName].splice(i, 1);
                        continue;
                    }
                }
            }
        });
        console.log('droppedItems', droppedItems);
        cmp.set('v.droppedItems', droppedItems);
        var viewCmpList = [];
        var viewBuilderCmp = cmp.find('viewBuilderCmp');
        if(viewBuilderCmp) {
            viewCmpList.concat(viewBuilderCmp).forEach(function(viewBuilder) {
                var cmpViewName = viewBuilder.get('v.viewName');
                viewBuilder.setCategories(hierarchyDepths, hierarchyBuildingItems, droppedItems[cmpViewName]);
            });
        }
        cmp.set('v.loadedProducts', null);
    },


    removeEmptyBranches: function(helper, array, level, currentDepth) {
        for(let i = array.length - 1; i >= 0; i--) {
            if(level < currentDepth) {
                if(array[i] === undefined) {
                    array.splice(i, 1);
                } else {
                    helper.removeEmptyBranches(helper, array[i].SubLevels, level + 1, currentDepth);
                }
            }
        }
    },

    addLoadedCategory: function(hierarchyBuildingItems, hierarchyPath, viewName) {
        var
            helper = this,
            indexSeparator = '__',
            viewArray;

        if(!hierarchyBuildingItems[viewName]) hierarchyBuildingItems[viewName] = [];
        viewArray = hierarchyBuildingItems[viewName];
        hierarchyPath.forEach(function(branchName) {
            var separatorLocation = branchName.lastIndexOf(indexSeparator);
            var branchIndex = separatorLocation > -1 ? parseInt(branchName.substr(separatorLocation + indexSeparator.length, branchName.length - separatorLocation)) : null;
            var branchNameWithoutIndex = separatorLocation > -1 ? branchName.substr(0, separatorLocation) : branchName;
            var hierarchyObjectIndex = helper.arrayObjectIndexOf(viewArray, branchName, 'Id');
            if (hierarchyObjectIndex == -1) {
                var newBranchObj = {
                    Id: branchName,
                    LevelName: branchNameWithoutIndex,
                    SubLevels: [],
                    collapsed: true
                };
                if(branchIndex != null && viewArray.indexOf(branchIndex) == -1) {
                    viewArray[branchIndex] = newBranchObj;
                    viewArray = viewArray[branchIndex].SubLevels;
                } else {
                    viewArray.push(newBranchObj);
                    viewArray = viewArray[viewArray.length-1].SubLevels;
                }
            } else {
                viewArray = viewArray[hierarchyObjectIndex].SubLevels;
            }
        });
        return hierarchyBuildingItems;
    },

    changeProductsCountToShowHandler: function(cmp, auraId) {

        if(auraId == 'productsCount') {
            this.changeProductDisplay(cmp, 1, cmp.find('productsCount').get('v.value'));
        } else if(auraId == 'productsSelectedCount') {
            var
                productDisplayData = cmp.get('v.productDisplayData'),
                checked = cmp.find('hierarchySelectedView').get('v.checked'),
                productsSelectedCountToShow = cmp.find('productsSelectedCount').get('v.value');

            productDisplayData.productsSelectedCountToShow = productsSelectedCountToShow;
            productDisplayData.productsSelectedCurrentPage = 1;
            cmp.set('v.productDisplayData', productDisplayData);
            this.switchSelectedProductsView(cmp, null, checked);
        }
    },

    setNextPage: function(cmp, auraId) {
        var productDisplayData = cmp.get('v.productDisplayData');
        if(auraId == 'step2next') {
            this.changeProductDisplay(cmp, productDisplayData.productsCurrentPage + 1, productDisplayData.productsCountToShow);
        } else if(auraId == 'step3next') {
            var
                checked = cmp.find('hierarchySelectedView').get('v.checked'),
                currentPage = productDisplayData.productsSelectedCurrentPage;

            productDisplayData.productsSelectedCurrentPage = currentPage + 1;
            cmp.set('v.productDisplayData', productDisplayData);
            this.switchSelectedProductsView(cmp, null, checked);
        }
    },

    setPreviousPage: function(cmp, auraId) {
        var productDisplayData = cmp.get('v.productDisplayData');
        if(auraId == 'step2prev') {
            this.changeProductDisplay(cmp, productDisplayData.productsCurrentPage - 1, productDisplayData.productsCountToShow);
        } else if(auraId == 'step3prev') {
            var
                checked = cmp.find('hierarchySelectedView').get('v.checked'),
                currentPage = productDisplayData.productsSelectedCurrentPage;

            productDisplayData.productsSelectedCurrentPage = currentPage - 1;
            cmp.set('v.productDisplayData', productDisplayData);
            this.switchSelectedProductsView(cmp, null, checked);
        }
    },

    setLastPage: function(cmp, auraId) {
        var
            productDisplayData = cmp.get('v.productDisplayData'),
            productsCountToShow,
            productsCount,
            lastPageNumber;

        if(auraId == 'step2last') {
            lastPageNumber = Math.ceil(productDisplayData.productsCount / productDisplayData.productsCountToShow);
            this.changeProductDisplay(cmp, lastPageNumber, productDisplayData.productsCountToShow);
        } else if(auraId == 'step3last') {
            var checked = cmp.find('hierarchySelectedView').get('v.checked');
            lastPageNumber = Math.ceil(productDisplayData.productsSelectedCount / productDisplayData.productsSelectedCountToShow);
            productDisplayData.productsSelectedCurrentPage = lastPageNumber;
            cmp.set('v.productDisplayData', productDisplayData);
            this.switchSelectedProductsView(cmp, null, checked);
        }
    },

    setFirstPage: function(cmp, auraId) {
        var productDisplayData = cmp.get('v.productDisplayData');
        if(auraId == 'step2first') {
            this.changeProductDisplay(cmp, 1, productDisplayData.productsCountToShow);
        } else if(auraId == 'step3first') {
            var checked = cmp.find('hierarchySelectedView').get('v.checked');
            productDisplayData.productsSelectedCurrentPage = 1;
            cmp.set('v.productDisplayData', productDisplayData);
            this.switchSelectedProductsView(cmp, null, checked);
        }
    },

    changeProductDisplay: function(cmp, productsCurrentPage, productsCountToShow, isSAPCodesSelection, isNextStepAction) {
        var
            helper = this,
            products = cmp.get("v.products"),
            productDisplayData = cmp.get('v.productDisplayData'),
            currentStep = cmp.get('v.currentStep'),
            productsMap = [],
            hierarchyViewCheckBox = cmp.find('hierarchyView').get('v.checked'),
            hierarchyFields = helper.getHierarchyFields(cmp, null, hierarchyViewCheckBox),
            isDynamic = cmp.get('v.isDynamic'),
            dynamicLowestSelectedLevel,
            filteredProducts = [],
            productsToShow = [],
            fromIndex = productsCurrentPage*productsCountToShow - productsCountToShow,
            toIndex = productsCurrentPage*productsCountToShow;

        if(!isDynamic) {
            filteredProducts = helper.filterProducts(cmp, products, isNextStepAction);
        } else {
            dynamicLowestSelectedLevel = cmp.get("v.dynamicLowestSelectedLevel");
            var filterValue = hierarchyViewCheckBox ? 'MV' : 'PV';
            filteredProducts = products.filter(function(item) {
                return item.Id.startsWith(filterValue);
            });
        }
        productDisplayData.productsCount = filteredProducts.length;
        productsToShow = filteredProducts.slice(fromIndex, toIndex);
        helper.buildHierarchy(productsToShow, productsMap, hierarchyFields, dynamicLowestSelectedLevel, null, productDisplayData.collapsedItems);
        productDisplayData.productsCountToShow = productsCountToShow;
        helper.showSpinner(cmp);
        productDisplayData.productsCurrentPage = productsCurrentPage;
        productDisplayData.productsPagMessage = $A.get("$Label.c.EUR_CRM_CG_PagdisplayLabel")
            .replace('{1}', productsCurrentPage * productsCountToShow - productsCountToShow + 1)
            .replace('{2}', (productsCurrentPage * productsCountToShow >= productDisplayData.productsCount) ? productDisplayData.productsCount : productsCurrentPage * productsCountToShow)
            .replace('{3}', productDisplayData.productsCount);
        cmp.set("v.productDisplayData", productDisplayData);
        cmp.find('hiddenProduct').focus();
        window.setTimeout($A.getCallback(function() {
            cmp.set("v.treeItems", productsMap);
            if(isNextStepAction) {
                // Move to the next step
                cmp.set('v.currentStep', currentStep + 1);
            }
            helper.hideSpinner(cmp);
        }), 1);
    },

    setCollapsedItems: function(cmp, products) {
        var
            productDisplayData = cmp.get('v.productDisplayData'),
            collapsedItems = [],
            hierarchyProductFields = [
                'ProductLevel1',
                'ProductLevel2',
                'ProductLevel3',
                'ProductLevel4',
                'ProductLevel5'
            ],
            hierarchyMarketFields = [
                'MarketingLevel1',
                'MarketingLevel2',
                'MarketingLevel3',
                'MarketingLevel4'
            ],
            productDefaultExpandLevel = 1,
            marketDefaultExpandLevel = 0;

        products.forEach(function(product) {
            var productCategoryIdentifier = '';
            hierarchyProductFields.forEach(function(field, index) {
                if(product[field]) productCategoryIdentifier += product[field] + ':';
                if(index >= productDefaultExpandLevel) {
                    var collapsedToAdd = productCategoryIdentifier.substr(0, productCategoryIdentifier.length - 1);
                    if(collapsedItems.indexOf(collapsedToAdd) == -1) collapsedItems.push(collapsedToAdd);
                }
            });
            var marketCategoryIdentifier = '';
            hierarchyMarketFields.forEach(function(field, index) {
                if(product[field]) marketCategoryIdentifier += product[field] + ':';
                if(index >= marketDefaultExpandLevel) {
                    var collapsedToAdd = marketCategoryIdentifier.substr(0, marketCategoryIdentifier.length - 1)
                    if(collapsedItems.indexOf(collapsedToAdd) == -1) collapsedItems.push(collapsedToAdd);
                }
            });
        });
        productDisplayData.collapsedItems = collapsedItems;
        cmp.set('v.productDisplayData', productDisplayData);
    },

    productsFilterChangeHandler: function(cmp, event) {
        var
            helper = this,
            productDisplayData = cmp.get('v.productDisplayData'),
            currentStep = cmp.get("v.currentStep"),
            filterOption = event.getSource().get('v.name');

        if(currentStep == 2) {
            if(filterOption) {
                productDisplayData.filter = filterOption.split('-')[1];
            }
            productDisplayData.productBrandsFilter = cmp.find('productBrands').get('v.value').split(';');
            cmp.set('v.productDisplayData', productDisplayData);
            helper.changeProductDisplay(cmp, 1, productDisplayData.productsCountToShow);
        } else if(currentStep == 3) {
            var checked = cmp.find('hierarchySelectedView').get('v.checked');
            if(filterOption) {
                productDisplayData.selectedFilter = filterOption.split('-')[1];
            }
            productDisplayData.selectedProductBrandsFilter = cmp.find('selectedProductBrands').get('v.value').split(';');
            cmp.set('v.productDisplayData', productDisplayData);
            helper.switchSelectedProductsView(cmp, null, checked);
        }
    },

    filterProducts: function(cmp, products, isNextStepAction) {
        //console.log('==> Filtering products <==');
        var
            productDisplayData = cmp.get('v.productDisplayData'),
            currentStep = cmp.get('v.currentStep'),
            productBrandField = 'ProductLevel1Description',
            filter,
            searchFilter,
            productBrands,
            filteredProducts = [];

        if(isNextStepAction) currentStep++;
        if(currentStep == 2) {
            filter = productDisplayData.filter;
            productBrands = productDisplayData.productBrandsFilter;
        } else {
            filter = productDisplayData.selectedFilter;
            searchFilter = productDisplayData.searchFilter;
            productBrands = productDisplayData.selectedProductBrandsFilter;
        }

        // returned products previously
        if(filter == 'All' && productBrands.indexOf('All') > -1) return this.filterByName(cmp,products,searchFilter,products);

        products.forEach( function(product) {
            if((product.rtName == filter || filter == 'All') &&
                (productBrands.indexOf('All') > -1 ||
                    productBrands.indexOf(product[productBrandField]) > -1 ||
                    productBrands.indexOf(product[productBrandField.replace('Description', '')]) > -1)) {

                filteredProducts.push(product);
            }
        });
        // returned filtered products previously
        return this.filterByName(cmp,filteredProducts,searchFilter,filteredProducts);
    },

    filterByName: function(cmp, products, sTerm, filteredProducts) {
        var fltr = [];
        if($A.util.isEmpty(sTerm)){
            return filteredProducts;
        } else {
            sTerm = sTerm.toLowerCase();
        }

        filteredProducts.forEach( function(product) {
            // ignore case when filtering by name
            if( (product.Name && product.Name.toLowerCase().indexOf(sTerm) != -1)
                || (product.ProductSAPcode && product.ProductSAPcode.toLowerCase().indexOf(sTerm) != -1)
                || (product.EAN && product.EAN.toLowerCase().indexOf(sTerm) != -1)
            ){
                //console.log('Found matching product: '+product.Name + ' EAN: ' +product.EAN+ ' SAP: '+product.ProductSAPcode );
                fltr.push(product);
            }

        });

        return fltr;
    },

    selectTabActionHandler: function(cmp, event, helper) {
        var
            viewTitle = event.target.getAttribute('title'),
            activeView = cmp.get('v.activeView'),
            checked = cmp.find('hierarchySelectedView').get('v.checked');

        if(activeView != viewTitle) {
            cmp.set('v.activeView', viewTitle);
            helper.switchSelectedProductsView(cmp, null, checked, null, true);
            // optimization: inject target viewBuilder with relevant records
            var viewCmpList = [];
            var viewBuilderCmp = cmp.find('viewBuilderCmp');
            if(viewBuilderCmp) {
                viewCmpList.concat(viewBuilderCmp).forEach(function(viewBuilder) {
                    var cmpViewName = viewBuilder.get('v.viewName');
                    if(cmpViewName == viewTitle){
                        console.log('Setting categories to view builder: '+viewTitle);
                        var droppedItems = cmp.get('v.droppedItems');
                        viewBuilder.setCategories(null, null, droppedItems[cmpViewName]);
                    }

                });
            }

        }
    },

    updateHierarchyEventHandler: function(cmp, event, helper) {
        var
            hierarchyBuildingItems = cmp.get("v.hierarchyBuildingItems"),
            hierarchy = event.getParam("hierarchy"),
            viewName = event.getParam("viewName"),
            branchIndex = event.getParam("branchIndex"),
            isDrop = event.getParam("isDrop"),
            sourceBranchIndex = event.getParam("sourceBranchIndex"),
            source = event.getParam("source"),
            hierarchyChanged = event.getParam("hierarchyChanged"),
            increaseIndexes = event.getParam("increaseIndexes"),
            droppedItems = JSON.parse(JSON.stringify(cmp.get('v.droppedItems'))),
            //droppedItems = cmp.get('v.droppedItems'),
            updateDroppedItems = false;

        if(source != 'viewBuilderCmp') return;

        console.log('viewName', viewName);
        console.log('hierarchy', hierarchy);

        if(viewName && hierarchy && hierarchyBuildingItems[viewName]) {
            if(hierarchyChanged) updateDroppedItems = true;
            hierarchyBuildingItems[viewName] = hierarchy;
            cmp.set("v.hierarchyBuildingItems", hierarchyBuildingItems);
            if (increaseIndexes && branchIndex && !isDrop) {
                droppedItems[viewName].forEach(function (item) {
                    if (item.branchIndex == branchIndex) {
                        item.branchIndex += '-0';
                        updateDroppedItems = true;
                    }
                });
            } else if (isDrop && sourceBranchIndex && branchIndex) {
                helper.changeProductsBranchIndexesOnCategoryDrop(droppedItems[viewName], branchIndex, sourceBranchIndex);
                updateDroppedItems = true;
            }
            if(updateDroppedItems) {
                console.log('==> Dropped items ', JSON.stringify(droppedItems));
                cmp.set('v.droppedItems', droppedItems);
                var viewCmpList = [];
                var viewBuilderCmp = cmp.find('viewBuilderCmp');
                if (viewBuilderCmp) {
                    viewCmpList.concat(viewBuilderCmp).forEach(function (viewBuilder) {
                        var cmpViewName = viewBuilder.get('v.viewName');
                        if (viewName == cmpViewName) {
                            viewBuilder.setCategories(null, null, droppedItems[cmpViewName]);
                        }
                    });
                }
            }
        }
    },

    viewItemsInputChangeEventHandler: function(cmp, event, helper) {
        var
            eventViewName = event.getParam("viewName"),
            productId = event.getParam("productId"),
            product = event.getParam("product"),
            droppedItems = JSON.parse(JSON.stringify(cmp.get('v.droppedItems'))),
            updateView;

        for(var viewName in droppedItems) {
            droppedItems[viewName].forEach(function (item) {
                if(item.product.Id == productId) {
                    if(eventViewName != viewName) {
                        updateView = viewName;
                    }
                    //TODO:inject other values?
                    //item.product.multiplication_factor = factor;
                    //console.log('Updating dropped item '+JSON.stringify(item.product));
                    //console.log('From product '+JSON.stringify(product));

                    item.product = product;



                    /*
                    item.product.ExpectAvailabiltyDate = product.ExpectAvailabiltyDate;
                    item.product.MinQty = product.MinQty;
                    item.product.MaxQty = product.MaxQty;
                    item.product.DelStart =  product.DelStart;
                    item.product.DelEnd = product.DelEnd;
                    item.product.Pckg = product.Pckg;
                    item.product.TemplQty = product.TemplQty;
                    item.product.Price = product.Price;
                    item.product.OOSStart = product.OOSStart;
                    item.product.OOSEnd = product.OOSEnd;
                    item.product.PrStart = product.PrStart;
                    item.product.PrEnd = product.PrEnd;
                     */

                }
            });
        }
        cmp.set('v.droppedItems', droppedItems);

        /* Optimization: items for other views should be set on tab navigation

        if(updateView !== undefined) {
            var viewCmpList = [];
            var viewBuilderCmp = cmp.find('viewBuilderCmp');
            if (viewBuilderCmp) {
                viewCmpList.concat(viewBuilderCmp).forEach(function (viewBuilder) {
                    var cmpViewName = viewBuilder.get('v.viewName');
                    if (updateView == cmpViewName) {
                        viewBuilder.setCategories(null, null, droppedItems[cmpViewName]);
                    }
                });
            }
        }
        */
    },

    changeDynamicLevelSelectionEventHandler: function(cmp, event) {
        var
            dynamicLowestSelectedLevel = cmp.get("v.dynamicLowestSelectedLevel"),
            level = event.getParam("level"),
            productIdentifier = event.getParam("productIdentifier"),
            hierarchyFields = this.getHierarchyFields(cmp, "hierarchyView"),
            products = cmp.get("v.products"),
            itemIdentifier = cmp.get("v.treeConfig").itemIdentifier;
        if(!productIdentifier) return;
        if($A.util.isUndefinedOrNull(dynamicLowestSelectedLevel)) dynamicLowestSelectedLevel = {};
        console.log('level', level);
        console.log('productIdentifier', productIdentifier);
        products.forEach(function(product) {
            var productHierarchyPath = '';
            hierarchyFields.forEach(function(field, index) {
                productHierarchyPath += (index != 0 ? ':' : '') + product[field.replace('Description', '')];
            });
            if(product[itemIdentifier] == productIdentifier || productHierarchyPath.startsWith(productIdentifier)) {
                dynamicLowestSelectedLevel[product[itemIdentifier]] = level;
            }
        });
        console.log(dynamicLowestSelectedLevel);
        cmp.set("v.dynamicLowestSelectedLevel", dynamicLowestSelectedLevel);

    },

    dropEventHandler: function(cmp, event, helper) {
        var
            itemIdentifier = event.getParam("itemIdentifier"),
            branchIndex = event.getParam("branchIndex"),
            eventView = event.getParam("eventView"),
            items = event.getParam("items"),
            moveByIndex = event.getParam("moveByIndex"),
            action = event.getParam("action"),
            isDynamic = cmp.get('v.isDynamic'),
            products = (isDynamic ? cmp.get("v.dynamicProductData") : cmp.get("v.products")),
            droppedItems = JSON.parse(JSON.stringify(cmp.get('v.droppedItems'))),
            //droppedItems = cmp.get('v.droppedItems'),
            eventViewDroppedItemsMap = [],
            allViewProductFactors = [],
            filteredProducts = [],
            selectedProducts = [],
            updateDroppedItems = false,
            updatedIndexes = [],
            checked = cmp.find('hierarchySelectedView').get('v.checked'),
            draggedProds = cmp.get("v.draggedProducts");


        for(let viewName in droppedItems) {
            droppedItems[viewName].forEach(function(item) {
                allViewProductFactors[item.product.Id] = item;
                if(viewName == eventView) {
                    eventViewDroppedItemsMap[item.product.Id] = item;
                }
            });
        }

        if(itemIdentifier && branchIndex && action == 'drop') {
            if(!isDynamic) {
                var hierarchyFields = this.getHierarchyFields(cmp, null, checked);
                filteredProducts = helper.filterProducts(cmp, products);
                filteredProducts.forEach(function (product) {
                    if(product.checked) selectedProducts.push(product);
                });
                selectedProducts.forEach(function (product) {
                    var productHierarchyPath = '';
                    hierarchyFields.forEach(function (field, index) {
                        productHierarchyPath += (index != 0 ? ':' : '') + product[field.replace('Description', '')];
                    });

                    if(product.Id == itemIdentifier || productHierarchyPath.startsWith(itemIdentifier)) {
                        if(!eventViewDroppedItemsMap[product.Id]) {
                            var droppedItem = {
                                product: product,
                                branchIndex: branchIndex
                            };
                            if(allViewProductFactors[product.Id]) {
                                // copies product filled data from concatenated list
                                //droppedItem.product.multiplication_factor = allViewProductFactors[product.Id].product.multiplication_factor;
                                //TODO: inject here?
                                droppedItem.product = allViewProductFactors[product.Id].product;
                                //console.log('Setting dp '+JSON.stringify(droppedItem.product));
                                //console.log('FROM '+JSON.stringify(allViewProductFactors[product.Id].product));
                            }

                            droppedItems[eventView].push(droppedItem);

                            updatedIndexes.push(branchIndex);
                            updateDroppedItems = true;

                            eventViewDroppedItemsMap[product.Id] = product;
                        }
                    }
                    /* add from buffer */
                    if(draggedProds && draggedProds.length){
                        for (let j = 0; j < draggedProds.length; j++) {
                            if(product.Id == draggedProds[j] && !eventViewDroppedItemsMap[draggedProds[j]]) {
                                var droppedItem = {
                                    product: product,
                                    branchIndex: branchIndex
                                };
                                if(allViewProductFactors[product.Id]) {
                                    // copies product filled data from concatenated list
                                    //droppedItem.product.multiplication_factor = allViewProductFactors[product.Id].product.multiplication_factor;
                                    //TODO: inject here?
                                    droppedItem.product = allViewProductFactors[product.Id].product;
                                }
                                droppedItems[eventView].push(droppedItem);

                                updatedIndexes.push(branchIndex);
                                updateDroppedItems = true;

                                eventViewDroppedItemsMap[product.Id] = product;
                            }
                        }
                    }


                });
            } else {
                var
                    hierarchyFields = [],
                    hierarchyFields1 = cmp.get('v.hierarchyFields1'),
                    hierarchyFields2 = cmp.get('v.hierarchyFields2'),
                    oneViewMode = cmp.get('v.oneViewMode'),
                    displayField,
                    productsInCategory = [];

                if (oneViewMode) {
                    hierarchyFields = hierarchyFields1.length ? hierarchyFields1 : hierarchyFields2;
                    displayField = hierarchyFields1.length ? 'Name' : 'SecondaryName';
                } else {
                    hierarchyFields = checked ? hierarchyFields2 : hierarchyFields1;
                    displayField = checked ? 'SecondaryName' : 'Name';
                }
                products.forEach(function (product) {
                    var categoryPath = '';
                    var categoryIdentifier = '';
                    hierarchyFields1.concat(hierarchyFields2).forEach(function (field) {
                        categoryPath += product[field.replace('Description', '')] + '<path>';
                    });
                    hierarchyFields.forEach(function (field) {
                        categoryIdentifier += product[field.replace('Description', '')] + ':';
                    });
                    categoryIdentifier = categoryIdentifier.substr(0, categoryIdentifier.length - 1);
                    if ((product.Id == itemIdentifier || categoryIdentifier.startsWith(itemIdentifier)) && !productsInCategory[categoryPath]) {
                        productsInCategory[categoryPath] = {
                            Name: product[displayField],
                            Path: categoryPath,
                            Id: product.Id
                        };
                    }
                });
                for (var key in productsInCategory) {
                    if (!eventViewDroppedItemsMap[key]) {
                        droppedItems[eventView].push({
                            product: productsInCategory[key],
                            branchIndex: branchIndex
                        });
                        updatedIndexes.push(branchIndex);
                        updateDroppedItems = true;
                    }
                }
            }
        } else if (items && action === 'indexUpdate') {
            items.forEach(function(item) {
                if(eventViewDroppedItemsMap[item.product.Id]) {
                    eventViewDroppedItemsMap[item.product.Id].branchIndex = item.branchIndex;
                    updateDroppedItems = true;
                }
            });
        } else if (itemIdentifier && moveByIndex !== undefined && action === 'replace') {
            var itemIndex, itemIndexToReplace;
            droppedItems[eventView].forEach(function(item, index) {
                if(item.product.Id == itemIdentifier) {
                    itemIndex = index;
                }
            });
            if(itemIndex === undefined) return;
            if(moveByIndex == 1) {
                for(let i = itemIndex + 1; i < droppedItems[eventView].length; i++) {
                    if(droppedItems[eventView][i].branchIndex == droppedItems[eventView][itemIndex].branchIndex) {
                        itemIndexToReplace = i;
                        break;
                    }
                }
            } else if(moveByIndex == -1) {
                for(let i = itemIndex - 1; i >= 0; i--) {
                    if(droppedItems[eventView][i].branchIndex == droppedItems[eventView][itemIndex].branchIndex) {
                        itemIndexToReplace = i;
                        break;
                    }
                }
            }
            if(itemIndexToReplace === undefined) return;
            var buff = droppedItems[eventView][itemIndex];
            droppedItems[eventView][itemIndex] = droppedItems[eventView][itemIndexToReplace];
            droppedItems[eventView][itemIndexToReplace] = buff;
            updateDroppedItems = true;
        } else if(itemIdentifier && action == 'remove') {
            droppedItems[eventView].forEach(function(item, index) {
                if(item.product.Id == itemIdentifier) {
                    droppedItems[eventView].splice(index, 1);
                    return;
                }
            });
            cmp.set('v.droppedItems', droppedItems);
        } else if(branchIndex && action == 'categoryDelete') {
            if(droppedItems[eventView] && droppedItems[eventView].length) {
                for(var i = droppedItems[eventView].length - 1; i >= 0; i--) {
                    if(droppedItems[eventView][i].branchIndex.startsWith(branchIndex)) {
                        droppedItems[eventView].splice(i, 1);
                    }
                }
                var branchPrefix = branchIndex.substr(0, branchIndex.length - 1);
                var deletedProductIndex = parseInt(branchIndex.substr(branchIndex.length - 1, 1));
                if(droppedItems[eventView] && droppedItems[eventView].length) {
                    droppedItems[eventView].forEach(function(item) {
                        var productViewPosition = item.branchIndex.substr(branchPrefix.length).split('-')[0];
                        var productViewIndex = parseInt(productViewPosition);
                        if(item.branchIndex.startsWith(branchPrefix) && productViewIndex >= deletedProductIndex) {
                            item.branchIndex = branchPrefix + (productViewIndex - 1) + item.branchIndex.substr(branchPrefix.length + productViewPosition.length);
                        }
                    });
                }
                updateDroppedItems = true;
            }
        }

        if(updateDroppedItems) {

            cmp.set('v.droppedItems', droppedItems);
            var viewCmpList = [];
            var viewBuilderCmp = cmp.find('viewBuilderCmp');
            if (viewBuilderCmp) {
                viewCmpList.concat(viewBuilderCmp).forEach(function (viewBuilder) {
                    var cmpViewName = viewBuilder.get('v.viewName');
                    if(eventView == cmpViewName) {
                        viewBuilder.setCategories(null, null, droppedItems[cmpViewName], updatedIndexes);
                    }
                });
            }
        }



        var
            helper = this,
            checked = cmp.find('hierarchySelectedView').get('v.checked');

        helper.switchSelectedProductsView(cmp, null, checked, false, true);
        // clear buffer
        cmp.set("v.draggedProducts",[]);
    },

    changeProductsBranchIndexesOnCategoryDrop: function(viewDroppedItems, branchIndex, sourceBranchIndex) {
        if(viewDroppedItems && viewDroppedItems.length) {
            var currentIndexes = branchIndex.split('-');
            var currentBranchPosition = parseInt(currentIndexes[currentIndexes.length - 1]);
            currentIndexes.splice(currentIndexes.length - 1, 1);
            var dataIndexes = sourceBranchIndex.split('-');
            var dataBranchPosition = parseInt(dataIndexes[dataIndexes.length - 1]);
            dataIndexes.splice(dataIndexes.length - 1, 1);
            viewDroppedItems.forEach(function(item) {
                if(item.branchIndex.startsWith(sourceBranchIndex)) {
                    item.branchIndex = item.branchIndex.replace(sourceBranchIndex, branchIndex);
                } else {
                    var itemIndexes = item.branchIndex.split('-');
                    if(itemIndexes.length > currentIndexes.length) {
                        var itemPosition = parseInt(itemIndexes[currentIndexes.length]);
                        itemIndexes.splice(currentIndexes.length);
                        if(itemIndexes.join('-').startsWith(currentIndexes.join('-'))) {
                            itemIndexes = item.branchIndex.split('-');
                            if(currentBranchPosition < dataBranchPosition && itemPosition >= currentBranchPosition && itemPosition < dataBranchPosition) {
                                itemIndexes[currentIndexes.length] = parseInt(itemIndexes[currentIndexes.length]) + 1;
                            } else if(currentBranchPosition > dataBranchPosition && itemPosition <= currentBranchPosition && itemPosition > dataBranchPosition) {
                                itemIndexes[currentIndexes.length] = parseInt(itemIndexes[currentIndexes.length]) - 1;
                            }
                            item.branchIndex = itemIndexes.join('-');
                        }
                    }
                }
            });
        }
    },

    setAvailableCategories: function(cmp, products, productIdsInView, hierarchyFields) {
        var availableCategories = [];
        products.forEach(function(product) {
            if(productIdsInView.indexOf(product.Id) == -1) {
                var categoryIdentifier = '';
                hierarchyFields.forEach(function(field, index) {
                    var fieldValue = product[field.replace('Description', '')] || product[field];
                    if(fieldValue) categoryIdentifier += fieldValue + ':';
                    var availableCategory = categoryIdentifier.substr(0, categoryIdentifier.length - 1);
                    if(availableCategories.indexOf(availableCategory) == -1) availableCategories.push(availableCategory);
                });
                if(availableCategories.indexOf(product.Id) == -1) availableCategories.push(product.Id);
            }
        });
        console.log('availableCategories', availableCategories);
        cmp.find('selectedTreeCmp').setDroppedProducts(availableCategories);
    },

    /* TODO:Remove
        addGroupHandler: function(cmp, event, helper) {
            var newAccountGroupData = cmp.get('v.newAccountGroupData');
            var data = event.getParam('data').get('v.resultRecords');
            var selectedAccountsIds = [];
            data.forEach(function(item) {
                if(item && item.Id) selectedAccountsIds.push(item.Id);
            });
            if(!newAccountGroupData.isDynamic && !selectedAccountsIds.length) {
                cmp.set('v.errorMessage', { isError: true, title: $A.get("$Label.c.EUR_CRM_Error"), message: $A.get("$Label.c.CG_NoAccountsError") } );
                return;
            }
            newAccountGroupData.accIds = selectedAccountsIds;
            newAccountGroupData.isSet = true;
            console.log(newAccountGroupData);
            cmp.set('v.newAccountGroupData', newAccountGroupData);
            // add new category to existing selection
            var preselected = cmp.find('accountGroup').get('v.value');
            cmp.find('accountGroup').set('v.value', $A.util.isEmpty(preselected) ? newAccountGroupData.type : preselected+';'+newAccountGroupData.type);
            helper.showToast($A.get("$Label.c.Success"), $A.get("$Label.c.CG_GroupCreateSuccessMsg"));
        },

        reviewGroupEventHandler: function(cmp, event, helper) {
            var
                newAccountGroupData = cmp.get('v.newAccountGroupData'),
                groupInfo = JSON.parse(event.getParam("result"));

            console.log(groupInfo);

            if(!groupInfo.result.success) {
                cmp.set('v.errorMessage', { isError: true, title: $A.get("$Label.c.EUR_CRM_Error"), message: groupInfo.result.message } );
            } else {
                newAccountGroupData.groupName = groupInfo.groupName;
                newAccountGroupData.isDynamic = groupInfo.isDynamic;
                newAccountGroupData.type = groupInfo.type;
                newAccountGroupData.isSet = false;
                if(newAccountGroupData.isDynamic || groupInfo.result.filter) {
                    newAccountGroupData.items = groupInfo.result.filter.items;
                    newAccountGroupData.filterLogic = groupInfo.result.filter.filterLogic;
                    newAccountGroupData.criteria = JSON.stringify(groupInfo.result.filter);
                    // get account data for preview
                    helper.getPreviewForFilterGroup(cmp, helper, newAccountGroupData.isDynamic, groupInfo.result.filter.testQuery);
                } else {
                    newAccountGroupData.accIds = groupInfo.result.accIds;
                    // get account data for preview
                    helper.getCSVGroupPreview(cmp, helper, newAccountGroupData.accIds);
                }
                cmp.set('v.newAccountGroupData', newAccountGroupData);
                //cmp.find('accountGroup').set('v.value', null);
            }
        },

        getCSVGroupPreview: function(cmp, helper, accIds) {
            var getAccountsForCSVGroupPreview = cmp.get('c.getAccountsForCSVGroupPreview');
            getAccountsForCSVGroupPreview.setParams({
                'accountIds' : accIds
            });
            helper.showSpinner(cmp);
            getAccountsForCSVGroupPreview.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === 'SUCCESS') {
                    var records = response.getReturnValue();
                    console.log(records);
                    if (!$A.util.isEmpty(records)) {
                        helper.displayPreview(cmp,records,true);
                    }
                }
                helper.hideSpinner(cmp);
            });
            $A.enqueueAction(getAccountsForCSVGroupPreview);
        },

        getPreviewForFilterGroup: function(cmp, helper, isDynamic, query) {
            var getAccountsForFilterGroupPreview = cmp.get('c.getAccountsForFilterGroupPreview');
            getAccountsForFilterGroupPreview.setParams({
                'query' : query
            });
            helper.showSpinner(cmp);
            getAccountsForFilterGroupPreview.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === 'SUCCESS') {
                    var records = response.getReturnValue();
                    console.log(records);
                    if (!$A.util.isEmpty(records) || isDynamic) {
                        helper.displayPreview(cmp, records, !isDynamic);
                    } else if(!isDynamic) {
                        cmp.set('v.errorMessage', { isError: true, title: $A.get("$Label.c.EUR_CRM_Error"), message: $A.get("$Label.c.CG_NoAccountsFoundError") } );
                    }
                }
                helper.hideSpinner(cmp);
            });
            $A.enqueueAction(getAccountsForFilterGroupPreview);
        },

        displayPreview: function(cmp, records, selectableRecords) {
            var modal = cmp.find('selectedRecordsModal');
            modal.set('v.modalHeader', $A.get('$Label.c.GC_GroupPreview'));
            $A.createComponent(
                'c:tilesView',
                {
                    'aura:id' : 'records-from-account',
                    'records' : records,
                    'resultRecords' : records,
                    'selectableRecords': selectableRecords,
                    'type' : 'account',
                    'showOptionsBtn' : false
                },
                function (newCmp, status, errorMessage) {
                    if (status === 'SUCCESS') {
                        modal.set('v.modalContent', newCmp);
                        modal.set('v.visible', true);
                    } else if (status === 'INCOMPLETE') {
                        console.log("No response from server or client is offline.");
                    } else if (status === 'ERROR') {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
        },
    */
    onSelectDragNodeHandler : function(cmp, event) {
        var
            helper = this,
            productIdentifier = cmp.get("v.treeConfig").itemIdentifier,
            draggedProducts = cmp.get("v.draggedProducts"),
            isDynamic = cmp.get('v.isDynamic'),
            products = (isDynamic ? cmp.get("v.dynamicProductData") : cmp.get("v.products")),
            filteredProducts = [],
            selectedProducts = [],
            checked = cmp.find('hierarchySelectedView').get('v.checked');

        var itemIdentifier = event.getParam("data-id");
        var doAdd = event.getParam("doAdd");

        if(! itemIdentifier){
            // clear selected buffer
            cmp.set("v.draggedProducts",[]);
            return;
        }

        if(!isDynamic) {
            var hierarchyFields = this.getHierarchyFields(cmp, null, checked);
            filteredProducts = helper.filterProducts(cmp, products);
            filteredProducts.forEach(function(product) {
                if(product.checked) selectedProducts.push(product);
            });
            selectedProducts.forEach(function(product) {
                var productHierarchyPath = '';
                hierarchyFields.forEach(function(field, index) {
                    productHierarchyPath += (index != 0 ? ':' : '') + product[field.replace('Description', '')];
                });
                if(product[productIdentifier] == itemIdentifier || productHierarchyPath.startsWith(itemIdentifier)) {
                    if(draggedProducts.indexOf(product.Id) == -1){
                        console.log('==> Adding selected product '+JSON.stringify(product));
                        draggedProducts.push(product.Id);
                    } else {
                        // product in buffer, toggle selection
                        if(!doAdd){
                            draggedProducts.splice( draggedProducts.indexOf(product.Id), 1 );
                        }
                    }
                }
            });

            cmp.set("v.draggedProducts",draggedProducts);
        } else {
            var
                hierarchyFields = [],
                hierarchyFields1 = cmp.get('v.hierarchyFields1'),
                hierarchyFields2 = cmp.get('v.hierarchyFields2'),
                oneViewMode = cmp.get('v.oneViewMode'),
                displayField,
                productsInCategory = [];

            if(oneViewMode) {
                hierarchyFields = hierarchyFields1.length ? hierarchyFields1 : hierarchyFields2;
                displayField = hierarchyFields1.length ? 'Name' : 'SecondaryName';
            } else {
                hierarchyFields = checked ? hierarchyFields2 : hierarchyFields1;
                displayField = checked ? 'SecondaryName' : 'Name';
            }
            products.forEach(function(product) {
                var categoryPath = '';
                var categoryIdentifier = '';
                hierarchyFields1.concat(hierarchyFields2).forEach(function(field) {
                    categoryPath += product[field.replace('Description', '')] + '<path>';
                });
                hierarchyFields.forEach(function(field) {
                    categoryIdentifier += product[field.replace('Description', '')] + ':';
                });
                categoryIdentifier = categoryIdentifier.substr(0, categoryIdentifier.length - 1);
                if((product[productIdentifier] == itemIdentifier || categoryIdentifier.startsWith(itemIdentifier)) && !productsInCategory[categoryPath]) {
                    productsInCategory[categoryPath] = {
                        name: product[displayField],
                        path: categoryPath,
                        productId: product.Id
                    };
                }
            });
            for(var key in productsInCategory) {
                var product = productsInCategory[key];
                var contained = false;
                for(var i = 0; i< draggedProducts.length; i++){
                    var draggedProduct = draggedProducts[i];
                    if(draggedProduct === product.productId){
                        contained = true;
                    }
                }
                if(!contained){
                    draggedProducts.push(product.Id);
                } else {
                    if(!doAdd){
                        draggedProducts.splice( draggedProducts.indexOf(product.Id), 1 );
                    }
                }
            }

            cmp.set("v.draggedProducts",draggedProducts);
        }
    },

    onElementDragHandler: function(cmp, event) {
        // TODO: should be removed
        var
            helper = this,
            productIdentifier = cmp.get("v.treeConfig").itemIdentifier,
            //draggedProductIds = [],
            draggedProducts = JSON.parse(JSON.stringify(cmp.get("v.draggedProducts"))),
            isDynamic = cmp.get('v.isDynamic'),
            products = (isDynamic ? cmp.get("v.dynamicProductData") : cmp.get("v.products")),
            filteredProducts = [],
            selectedProducts = [],
            checked = cmp.find('hierarchySelectedView').get('v.checked');

        var el = event.path.filter(function(el) {
            return el.className && typeof(el.className) == 'string' && el.className.indexOf('slds-tree__item') > -1;
        })[0];
        var itemIdentifier = el.getAttribute('data-id');



        if(!isDynamic) {
            var hierarchyFields = this.getHierarchyFields(cmp, null, checked);
            filteredProducts = helper.filterProducts(cmp, products);
            filteredProducts.forEach(function(product) {
                if(product.checked) selectedProducts.push(product);
            });
            selectedProducts.forEach(function(product) {
                var productHierarchyPath = '';
                hierarchyFields.forEach(function(field, index) {
                    productHierarchyPath += (index != 0 ? ':' : '') + product[field.replace('Description', '')];
                });
                if(product[productIdentifier] == itemIdentifier || productHierarchyPath.startsWith(itemIdentifier)) {
                    /*
                    if(draggedProducts.indexOf(product) == -1){
                        draggedProducts.push(product);
                    }
                     */
                    var inBuffer = false;
                    if(!$A.util.isEmpty(draggedProducts)){
                        for(var i=0; i<draggedProducts.length; i++){
                            if(product.Id === draggedProducts[i].productId){
                                inBuffer = true;
                                break;
                            }
                        }
                    }
                    if(!inBuffer){
                        draggedProducts.push(product);
                    }
                }
            });

            event.dataTransfer.setData("Text", JSON.stringify(draggedProducts));
            event.dataTransfer.effectAllowed = "link";

            cmp.set("v.draggedProducts",draggedProducts);


        } else {
            var
                hierarchyFields = [],
                hierarchyFields1 = cmp.get('v.hierarchyFields1'),
                hierarchyFields2 = cmp.get('v.hierarchyFields2'),
                oneViewMode = cmp.get('v.oneViewMode'),
                displayField,
                productsInCategory = [];

            if(oneViewMode) {
                hierarchyFields = hierarchyFields1.length ? hierarchyFields1 : hierarchyFields2;
                displayField = hierarchyFields1.length ? 'Name' : 'SecondaryName';
            } else {
                hierarchyFields = checked ? hierarchyFields2 : hierarchyFields1;
                displayField = checked ? 'SecondaryName' : 'Name';
            }
            products.forEach(function(product) {
                var categoryPath = '';
                var categoryIdentifier = '';
                hierarchyFields1.concat(hierarchyFields2).forEach(function(field) {
                    categoryPath += product[field.replace('Description', '')] + '<path>';
                });
                hierarchyFields.forEach(function(field) {
                    categoryIdentifier += product[field.replace('Description', '')] + ':';
                });
                categoryIdentifier = categoryIdentifier.substr(0, categoryIdentifier.length - 1);
                if((product[productIdentifier] == itemIdentifier || categoryIdentifier.startsWith(itemIdentifier)) && !productsInCategory[categoryPath]) {
                    productsInCategory[categoryPath] = {
                        name: product[displayField],
                        path: categoryPath,
                        productId: product.Id
                    };
                }
            });
            for(var key in productsInCategory) {
                var product = productsInCategory[key];
                var contained = false;
                for(var i = 0; i< draggedProducts.length; i++){
                    var draggedProduct = draggedProducts[i];
                    if(draggedProduct.productId === product.productId){
                        contained = true;
                    }
                }
                if(!contained){
                    draggedProducts.push(productsInCategory[key]);
                }
            }

            event.dataTransfer.setData("Text", JSON.stringify(draggedProducts));

        }
    },

    getHierarchyFields: function(cmp, checkBoxId, isChecked) {
        var
            hierarchyFields,
            checked = !$A.util.isUndefinedOrNull(isChecked) ? isChecked : cmp.find(checkBoxId).get('v.checked');

        if(checked) {
            hierarchyFields = [
                'MarketingLevel1Description',
                'MarketingLevel2Description',
                'MarketingLevel3Description',
                'MarketingLevel4Description'
            ];
        } else {
            hierarchyFields = [
                'ProductLevel1Description',
                'ProductLevel2Description',
                'ProductLevel3Description',
                'ProductLevel4Description',
                'ProductLevel5Description',
                'ProductLevel6Description'
            ];
        }
        return hierarchyFields;
    },

    buildHierarchy: function(products, productsMap, hierarchyFields, dynamicLowestSelectedLevel, nameField, collapsedItems,isListView) {
        var helper = this;
        products.forEach( function(product) {
            var requiredField = hierarchyFields[0];
            if(product[requiredField] || product[requiredField.replace('Description', '')]) {
                helper.addProductToHierarchy(product, productsMap, hierarchyFields, dynamicLowestSelectedLevel, nameField, collapsedItems,isListView);
            }
        });
    },

    addProductToHierarchy: function(product, productsMap, hierarchyFields, dynamicLowestSelectedLevel, nameField, collapsedItems, isListView) {
        var
            helper = this,
            hierarchyObjectIndex,
            productsMapSubLevel = productsMap,
            maxSelectionLevel = 99;

        if(dynamicLowestSelectedLevel && dynamicLowestSelectedLevel[product.Id]) {
            maxSelectionLevel = dynamicLowestSelectedLevel[product.Id];
        }
        if($A.util.isUndefinedOrNull(isListView) || isListView !== true){
            var categoryId = '';
            hierarchyFields.forEach( function(field, index) {
                var prodFieldCode = product[field.replace('Description', '')] || product[field];
                if($A.util.isUndefinedOrNull(prodFieldCode)){
                    // check
                    return;
                }
                categoryId += (index != 0 ? ':' : '') + prodFieldCode.split(' ').join('');
                hierarchyObjectIndex = helper.arrayObjectIndexOf(productsMapSubLevel, categoryId, 'Id');
                if (hierarchyObjectIndex == -1) {
                    var newHierarchyElement = {
                        LevelName : product[field] || product[field.replace('Description', '')],
                        checked : product.checked && maxSelectionLevel > index,
                        collapsed : collapsedItems.indexOf(categoryId) > -1 ? true : false,
                        Id : categoryId,
                        SubLevels : []
                    }
                    productsMapSubLevel.push(newHierarchyElement);
                    productsMapSubLevel.sort(helper.sortObjectsArray);
                    hierarchyObjectIndex = helper.arrayObjectIndexOf(productsMapSubLevel, categoryId, 'Id');
                    productsMapSubLevel = productsMapSubLevel[hierarchyObjectIndex].SubLevels;
                } else {
                    if(product.checked && maxSelectionLevel > index) {
                        productsMapSubLevel[hierarchyObjectIndex].checked = product.checked;
                    }
                    productsMapSubLevel = productsMapSubLevel[hierarchyObjectIndex].SubLevels;
                }
            });
        }

        productsMapSubLevel.push({
            LevelName : product[nameField] || product.Name,
            Id : product.Id,
            ProductSAPcode: product.ProductSAPcode,
            NationalCode: product.NationalCode,
            EAN: product.EAN,
            checked : product.checked
        });
    },

    arrayObjectIndexOf: function(array, searchTerm, property ) {
        for(var i = 0, len = array.length; i < len; i++) {
            if (array[i] && array[i][property] === searchTerm) return i;
        }
        return -1;
    },

    setSelectedItemsEventHandler: function(cmp, event) {
        var
            helper = this,
            eventData = event.getParam("eventData"),
            productIdentifier = cmp.get("v.treeConfig").itemIdentifier,
            hierarchyFields = helper.getHierarchyFields(cmp, "hierarchyView"),
            isDynamic = cmp.get("v.isDynamic"),
            products = cmp.get("v.products"),
            filteredProducts = [];

        if(!isDynamic) {
            filteredProducts = helper.filterProducts(cmp, products);
        } else {
            filteredProducts = products;
        }
        filteredProducts.forEach(function(product) {
            var productHierarchyPath = '';
            hierarchyFields.forEach(function(field, index) {
                // fall back to description field, if hierarchy is not populated
                var hierarchylvlVal = product[field.replace('Description', '')] ? product[field.replace('Description', '')] : product[field];
                productHierarchyPath += (index != 0 ? ':' : '') + hierarchylvlVal;
            });
            if((productHierarchyPath.startsWith(eventData.itemIdentifier) || product[productIdentifier] == eventData.itemIdentifier) &&
                (!isDynamic || eventData.checked || (!eventData.checked && eventData.itemIdentifier.split(':').length == 1))) {
                product.checked = eventData.checked;
            }
            if (product.ProductLevel1 === eventData.Id) {
                product.checked = eventData.checked;
            }
        });
        cmp.set("v.products", products);
    },

    selectProductsBySAPCodesHandler: function(cmp, helper) {
        var
            products = cmp.get("v.products"),
            productsImport = cmp.get("v.productsImport"),
            productField = 'ProductSAPcode',
            productDisplayData = cmp.get('v.productDisplayData'),
            productsInfo = cmp.find("productsInfo"),
            productsInfoValue = productsInfo.get("v.value"),
            isFound = false,
            productCodes = [];

        if(!productsInfoValue || !productsInfoValue.trim()) {
            productsInfo.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_CG_LoadProductsError") }]);
            return;
        }
        if(productsImport == 'prod-sap') {
            productField = 'ProductSAPcode';
        } else if(productsImport == 'prod-ean') {
            productField = 'EAN';
        }
        productCodes = productsInfoValue.trim().split('\r\n');
        products.forEach(function(product) {
            if(productCodes.indexOf(product[productField]) > -1) {
                product.checked = true;
                isFound = true;
                productCodes.splice(productCodes.indexOf(product[productField]), 1);
            }
        });
        if(isFound) {
            cmp.set("v.products", products);
            helper.changeProductDisplay(cmp, productDisplayData.productsCurrentPage, productDisplayData.productsCountToShow, true);
        }
        if(productCodes.length) {
            var
                sapCodesValues = '',
                maxDisplayValues = 30,
                maxCodeLength = 18;

            productCodes.slice(0, maxDisplayValues).forEach( function(code, index) {
                sapCodesValues += (code.length > maxCodeLength ? code.substr(0, maxCodeLength) + '...' : code) + ', ';
            });
            sapCodesValues = sapCodesValues.substr(0, sapCodesValues.length - 2);
            if(productCodes.length > maxDisplayValues) sapCodesValues += '...';
            cmp.set('v.errorMessage', { isError: true, title: $A.get("$Label.c.EUR_CRM_Error"), message: $A.get("$Label.c.EUR_CRM_CG_ProductsSAPCodesError").replace('{count}', productCodes.length) + sapCodesValues } );
        } else {
            helper.moveToTheNextStep(cmp, true);
        }
        helper.closeProductSelectionModalHandler(cmp);
    },

    changeProductsImportSourceHandler: function(cmp, event, helper, attrName) {
        var data = event.getSource().get('v.name');
        cmp.set('v.' + attrName, data);
        cmp.set('v.isError', false);
    },

    openProductSelectionModalHandler: function(cmp) {
        cmp.set('v.isOpenProductsPopup', true);
    },

    closeProductSelectionModalHandler: function(cmp) {
        var productsInfo = cmp.find("productsInfo");
        productsInfo.set("v.value", null);
        productsInfo.set("v.errors", null);
        cmp.set('v.isOpenProductsPopup', false);
    },

    /* Function to save selected products before and to switch hierarchy view between
    * product and marketing levels on Step 2
    *
    */
    switchViewHandler: function(cmp, event) {
        var productDisplayData = cmp.get('v.productDisplayData');
        this.changeProductDisplay(cmp, 1, productDisplayData.productsCountToShow);
    },

    /* Function to switch hierarchy view between product and marketing levels on Step 3
    *  from selected products excluding already dropped items
    */
    switchSelectedProductsView: function(cmp, event, checked, isNextStepAction, skipTreeRebuild) {
        console.log('switchSelectedProductsView => ');
        var
            helper = this,
            productsMap = [],
            currentStep = cmp.get('v.currentStep'),
            checked = (checked != null ? checked : event.getSource().get('v.checked')),
            hierarchyFields,
            displayField,
            isDynamic = cmp.get('v.isDynamic'),
            oneViewMode = cmp.get('v.oneViewMode'),
            hierarchyFields1 = cmp.get('v.hierarchyFields1'),
            hierarchyFields2 = cmp.get('v.hierarchyFields2'),
            products = isDynamic ? cmp.get("v.dynamicProductData") : cmp.get("v.products"),
            productDisplayData = cmp.get('v.productDisplayData'),
            dynamicLowestSelectedLevel = cmp.get("v.dynamicLowestSelectedLevel"),
            filteredProducts = [],
            selectedProducts = [],
            droppedItems = JSON.parse(JSON.stringify(cmp.get('v.droppedItems'))),
            //droppedItems = cmp.get('v.droppedItems'),
            productIdsInView = [],
            hierarchyViews = cmp.get('v.hierarchyViews'),
            isListView = cmp.get('v.isListView'),
            activeView = cmp.get('v.activeView');

        if(!products) return;
        if(isDynamic) {
            if(oneViewMode) {
                hierarchyFields = hierarchyFields1.length ? hierarchyFields1 : hierarchyFields2;
            } else {
                hierarchyFields = checked ? hierarchyFields2 : hierarchyFields1;
            }
            displayField = checked ? 'SecondaryName' : 'Name';
        } else {
            hierarchyFields = helper.getHierarchyFields(cmp, null, checked);
        }
        // get checked products
        var checkedProductIds = [];
        var toRemoveUnselected = false;
        products.forEach(function(product) {
            if(product.checked) {
                checkedProductIds.push(product.Id);
            }
        });
        // check for products already dropped in views
        // and remove from views unselected products
        hierarchyViews.forEach(function(view) {
            if(droppedItems[view]) {
                for(var i = droppedItems[view].length - 1; i >= 0; i--) {
                    if(checkedProductIds.indexOf(droppedItems[view][i].product.Id) == -1) {
                        droppedItems[view].splice(i, 1);
                        toRemoveUnselected = true;
                        continue;
                    } else if(view == activeView) {
                        productIdsInView.push(droppedItems[view][i].product.Id);
                    }
                }
            }
        });
        if(toRemoveUnselected) {
            cmp.set('v.droppedItems', droppedItems);
            var viewCmpList = [];
            var viewBuilderCmp = cmp.find('viewBuilderCmp');
            if(viewBuilderCmp) {
                viewCmpList.concat(viewBuilderCmp).forEach(function(viewBuilder) {
                    var cmpViewName = viewBuilder.get('v.viewName');
                    viewBuilder.setCategories(null, null, droppedItems[cmpViewName]);
                });
            }
        }

        if(!isDynamic) {
            filteredProducts = helper.filterProducts(cmp, products, isNextStepAction);
        } else {
            filteredProducts = products;
        }
        filteredProducts.forEach(function(product) {
            if(product.checked) selectedProducts.push(product);
        });
        var fromRange = productDisplayData.productsSelectedCurrentPage *
            productDisplayData.productsSelectedCountToShow - productDisplayData.productsSelectedCountToShow;
        var toRange = productDisplayData.productsSelectedCurrentPage * productDisplayData.productsSelectedCountToShow;
        if(productDisplayData.productsSelectedCurrentPage > 1 && fromRange + 1 > selectedProducts.length) {
            fromRange -= productDisplayData.productsSelectedCountToShow;
            toRange -= productDisplayData.productsSelectedCountToShow;
            productDisplayData.productsSelectedCurrentPage -= 1;
        }
        var productsToShow = selectedProducts.slice(fromRange, toRange);
        console.log('productsToShow', productsToShow);
        if(!skipTreeRebuild) {
            productDisplayData.productsSelectedCount = selectedProducts.length;
            productDisplayData.productsSelectedPagMessage = $A.get("$Label.c.EUR_CRM_CG_PagdisplayLabel")
                .replace('{1}', productDisplayData.productsSelectedCurrentPage * productDisplayData.productsSelectedCountToShow - productDisplayData.productsSelectedCountToShow + 1)
                .replace('{2}', (productDisplayData.productsSelectedCurrentPage * productDisplayData.productsSelectedCountToShow >= productDisplayData.productsSelectedCount) ? productDisplayData.productsSelectedCount : productDisplayData.productsSelectedCurrentPage * productDisplayData.productsSelectedCountToShow)
                .replace('{3}', productDisplayData.productsSelectedCount);
            cmp.set('v.productDisplayData', productDisplayData);
            helper.buildHierarchy(productsToShow, productsMap, hierarchyFields, dynamicLowestSelectedLevel, displayField, productDisplayData.collapsedItems,isListView);
            helper.showSpinner(cmp);
            window.setTimeout($A.getCallback(function() {
                cmp.set("v.selectedTreeItems", productsMap);
                if(isNextStepAction) {
                    // Move to the next step
                    cmp.set('v.currentStep', currentStep + 1);
                }
                helper.setAvailableCategories(cmp, productsToShow, productIdsInView, hierarchyFields);
                helper.hideSpinner(cmp);
            }), 1);
        } else {
            helper.setAvailableCategories(cmp, productsToShow, productIdsInView, hierarchyFields);
        }
    },

    addCollapsedItemHandler: function(cmp, event) {
        var
            productDisplayData = cmp.get('v.productDisplayData'),
            collapsedItems = productDisplayData.collapsedItems || [],
            itemId = event.getParam("itemId"),
            collapsedItemIndex = collapsedItems.indexOf(itemId);

        if(collapsedItemIndex == -1) {
            collapsedItems.push(itemId);
        } else {
            collapsedItems.splice(collapsedItemIndex, 1);
        }
        productDisplayData.collapsedItems = collapsedItems;
        cmp.set('v.productDisplayData', productDisplayData);
    },

    gotoURL: function (Id) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/" + Id
        });
        urlEvent.fire();
    },

    doCancel: function(cmp, helper) {
        var rId = cmp.get("v.recordId");
        if(! $A.util.isEmpty(rId)){
            // on cancel edit return to record page
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": rId
            });
            navEvt.fire();
        } else {
            // on cancel new return to object home
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
                "scope": cmp.get("v.sObjectName")
            });
            homeEvt.fire();
        }
    },

    sortObjectsArray: function (objA, objB) {
        if (objA.LevelName > objB.LevelName) {
            return 1;
        } else {
            return 0;
        }
    },

    showToast: function(title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": "dismissible",
            "duration": 5000,
            "type": "success",
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },

    alertMessageEventHandler: function(cmp, event) {
        var
            isError = event.getParam("isError"),
            message = event.getParam("message");

        cmp.set('v.errorMessage', { isError: isError, title: $A.get("$Label.c.EUR_CRM_Error"), message: message} );
    },

    findAncestor: function(el, cls) {
        while ((el = el.parentElement) && !el.classList.contains(cls));
        return el;
    },

    showSpinner: function(cmp) {
        var spinner = cmp.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function(cmp) {
        var spinner = cmp.find('spinner');
        $A.util.addClass(spinner, "slds-hide");
    },

    checkReturnReasonHandler: function(cmp) {
        var
            catalog = cmp.get('v.catalog'),
            isReturn = false;

        if(catalog.OrderType__c.indexOf('Credit_Note') != -1) {
            isReturn = true;
        } else {
            //cmp.find('catalogReturnReason').set('v.value', null);
        }
        cmp.set('v.isReturn', isReturn);
    },

    checkHasBegun: function(cmp, helper) {
        var validFrom = cmp.find('startDateField').get('v.value');
        var hasBegun = false;
        if(!$A.util.isEmpty(validFrom)){
            var today = cmp.get('v.today');
            var d1 = new Date(today);
            var d2 = new Date(validFrom);
            if(d1.getTime() >= d2.getTime()){
                hasBegun = true;
            }
        }
        cmp.set('v.hasBegun',hasBegun);
    },

    filterProductsByStatus: function(products, status) {
        var filteredProducts = [];
        products.forEach(function(product) {
            if(product.isActive == status) filteredProducts.push(product);
        });
        return filteredProducts;
    },

    saveCatalog: function (cmp, toConfigureItems) {
        console.log('toConfigureItems => ' , toConfigureItems);
        var
            helper = this,
            action = cmp.get('c.saveCatalog'),
            catalog = cmp.get('v.catalog'),
            catalogName = cmp.find('catalogName').get("v.value"),
            groupId = cmp.find('accountGroup') ? cmp.find('accountGroup').get("v.value") : null,
            availableForAll = false,
            startDate = cmp.find('startDateField').get("v.value"),
            endDate = cmp.find('endDateField').get("v.value"),
            isDynamic = false,
            viewName1 = cmp.find('viewName1').get('v.value').trim(),
            viewName2 = cmp.find('viewName2') ? cmp.find('viewName2').get('v.value') : '',
            isTransfer = cmp.get('v.isTransfer'),
            isTemplate = cmp.get('v.isTemplate'),
            catalogOrderType = cmp.find('catalogOrderType') ? cmp.find('catalogOrderType').get('v.value') : '',
            catalogReturnReason = cmp.find('catalogReturnReason') ? cmp.find('catalogReturnReason').get('v.value') : '',
            catalogFieldLabels = cmp.get('v.catalogFieldLabels'),
            catalogRecTypeId = cmp.get('v.recordTypeId'),
            //wholesalerId = isTransfer ? cmp.find('wholesaler').get('v.value') : null,
            pricingDate = cmp.find('pricingDateField') ? cmp.find('pricingDateField').get('v.value') : null,
            templDelDates = (isTemplate && cmp.get('v.templDelDates')) ? cmp.get('v.templDelDates') : [],
            settings = {};

        //console.log('In save after var init');

        if(!toConfigureItems) {
            try {
                helper.validateCatalogInputs(cmp);
                if(!catalog.ViewName2__c && viewName2 && viewName2.trim()) {
                    var fieldLabel = catalogFieldLabels.EUR_CRM_ProductCatalog__c.EUR_CRM_ViewName2__c;
                    throw new Error($A.get("$Label.c.EUR_CRM_CG_CatalogStep1SaveError").replace('{field}', fieldLabel));
                }
            } catch(e) {
                cmp.set('v.errorMessage', { isError: true, title: $A.get("$Label.c.EUR_CRM_Error"), message: e.message} );
                return;
            }
        }
        // check delivery dates
        /* TODO: remove
        try{
        	helper.validateDeliveryDates(cmp);
        } catch(e) {
             cmp.set('v.errorMessage', { isError: true, title: $A.get("$Label.c.EUR_CRM_Error"), message: e.message} );
             return;
        }
        */
        var stDate = new Date(startDate);
        var edDate = new Date(endDate);
        var sharing = helper.getSharing(cmp);
        settings = {
            catalogId: catalog.Id,
            //wholesalerId: wholesalerId,
            catalogName: catalogName,
            groupInfo: null,
            groupId : groupId,
            availableForAll: availableForAll,
            catalogOrderType: catalogOrderType,
            catalogReturnReason: catalogReturnReason,
            catalogRecTypeDName: cmp.get('v.recordTypeDevName'),
            startDate: [stDate.getFullYear(), stDate.getMonth()+1, stDate.getDate()],
            endDate: [edDate.getFullYear(), edDate.getMonth()+1, edDate.getDate()],
            isDynamic: isDynamic,
            viewName1: viewName1,
            viewName2: viewName2 ? viewName2.trim() : '',
            isTransfer: isTransfer,
            isTemplate: isTemplate,
            sharing: sharing,
            pricingDate: pricingDate,
            templDelDates: templDelDates,
            toConfigureItems: toConfigureItems,
            catalogRecTypeId : catalogRecTypeId || catalog.RecordTypeId,
            productsInfo: []
        };

        if(!availableForAll) {
            settings.groupInfo = helper.generateGroupInfos(cmp);
        }
        if(toConfigureItems) {
            try {
                console.log(' if(toConfigureItems) => ' , toConfigureItems);
                settings.productsInfo = helper.generateCatalogItemsToSave(cmp, helper);
                console.log('settings => ' , settings);
                console.log('JSON.serializePretty(settings) => ' , JSON.stringify(settings));
            } catch(e) {
                cmp.set('v.errorMessage', { isError: true, title: $A.get("$Label.c.EUR_CRM_Error"), message: e.message} );
                return;
            }
        }
        console.log('==> Save cat: '+JSON.stringify(settings));
        action.setParams({
            "settings": JSON.stringify(settings)
        });
        helper.showSpinner(cmp);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === 'SUCCESS') {
                var result = JSON.parse(response.getReturnValue());
                console.log('this => ' + JSON.stringify(this));
                console.log('this => ' , this);
                console.log('result => ' + JSON.stringify(result));
                try {
                    if(result.success) {
                        $A.get('e.force:refreshView').fire();
                        helper.gotoURL(result.record.Id);
                    } else {
                        throw new Error(result.message);
                    }
                } catch(e) {
                    cmp.set('v.errorMessage', { isError: true, title: $A.get("$Label.c.EUR_CRM_Error"), message: e.message} );
                    helper.hideSpinner(cmp);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getSharing: function(cmp) {
        var sharingCmp = cmp.find('sharing');
        if (sharingCmp) {
            let swap = function(obj) {
                var ret = {};
                for(var key in obj){
                    ret[obj[key]] = key;
                }
                return ret;
            }
            let isProperShareRecord = (record, reasonsTrans) => {
                return !record.Id && record.UserOrGroupId && record.RowCause
                    && (
                        (reasonsTrans[record.RowCause]
                            && (reasonsTrans[record.RowCause].toLowerCase() === 'manual'
                                || reasonsTrans[record.RowCause].endsWith('__c'))
                            || (record.RowCause
                                && (record.RowCause.toLowerCase() === 'manual'
                                    || record.RowCause.endsWith('__c'))))
                    );
            }
            let records = sharingCmp.get('v.records') || [];
            let sharing = [];
            let accessLevelsTrans = swap(sharingCmp.get('v.accessLevels'));
            let reasonsTrans = swap(sharingCmp.get('v.allReasons'));
            for (let i = 0; i < records.length; i++) {
                if (isProperShareRecord(records[i], reasonsTrans)) {
                    sharing.push({
                        'sobjectType': 'ProductCatalog__Share',
                        'UserOrGroupId': records[i].UserOrGroupId,
                        'RowCause' : reasonsTrans[records[i].RowCause],
                        'AccessLevel' : accessLevelsTrans[records[i].AccessLevel]
                    });
                }
            }
            if (!$A.util.isEmpty(sharing)) {
                return sharing;
            }
        }
        return null;
    },
    generateGroupInfos: function(cmp) {
        var
            helper = this,
            groupInfos = [],
            groups = cmp.find('accountGroup').get("v.value");

        if(!$A.util.isEmpty(groups)){
            var grps = groups.split(';');
            for(var i=0; i<grps.length; i++){
                var grpInfo = helper.generateGroupInfo(cmp,grps[i]);
                if(grpInfo){
                    console.log('Pushing group '+grpInfo);
                    groupInfos.push(grpInfo);
                }
            }
        }
        return groupInfos;
    },
    generateGroupInfo: function(cmp,group) {
        var
            groupInfo = {},
            //group = cmp.find('accountGroup').get("v.value"),
            newAccountGroupData = cmp.get('v.newAccountGroupData');

        if(group == 'custom') {
            groupInfo.groupName = newAccountGroupData.groupName;
            groupInfo.isDynamic = newAccountGroupData.isDynamic;
            if(!newAccountGroupData.isDynamic) {
                groupInfo.accIds = newAccountGroupData.accIds;
            }
            if(newAccountGroupData.isDynamic || newAccountGroupData.criteria) {
                groupInfo.criteria = newAccountGroupData.criteria;
            }
        } else {
            groupInfo.groupId = group;
        }
        return groupInfo;
    },

    generateCatalogItemsToSave: function(cmp, helper) {
        var
            productsInfo = [],
            checked = cmp.find('hierarchyView').get('v.checked'),
            isDynamic = cmp.get('v.isDynamic'),
            views = cmp.get('v.hierarchyViews'),
            hierarchyDepths = cmp.get('v.hierarchyDepths'),
            droppedItems = cmp.get('v.droppedItems'),
            hierarchyBuildingItems = cmp.get('v.hierarchyBuildingItems'),
            marketingFieldNames = cmp.get('v.hierarchyFields2'),
            productFieldNames = cmp.get('v.hierarchyFields1'),
            isReturn = cmp.get('v.isReturn'),
            isTemplate = cmp.get('v.isTemplate'),
            isTransfer = cmp.get('v.isTransfer'),
            viewFields1 = [
                'View1Level1',
                'View1Level2',
                'View1Level3',
                'View1Level4'
            ],
            viewFields2 = [
                'View2Level1',
                'View2Level2',
                'View2Level3',
                'View2Level4'
            ];

        helper.validateViews(cmp);
        helper.validateSelectedProducts(cmp);

        views.forEach( function(view, viewIndex) {
            console.log('Save data for ' + view + ' view');
            var viewDroppedItems = droppedItems[view];
            var viewHierarchyBuildingItems = hierarchyBuildingItems[view];
            viewDroppedItems.forEach(function(item, orderIndex) {
                var itemInfoPath = item.branchIndex.split('-');
                var obj = {};
                var branch = viewHierarchyBuildingItems[parseInt(itemInfoPath[1])];
                var fieldValues = [];
                var viewFieldsToSet = [];
                if($A.util.isEmpty(branch.LevelName.trim())) {
                    throw new Error($A.get("$Label.c.EUR_CRM_CG_EmptyHierarchyInputs").replace('{name}', view));
                }
                fieldValues.push(branch.LevelName + '__' + parseInt(itemInfoPath[1]));
                for(let i = 2; i < itemInfoPath.length; i++) {
                    branch = branch.SubLevels[parseInt(itemInfoPath[i])];
                    if($A.util.isEmpty(branch.LevelName.trim())) {
                        throw new Error($A.get("$Label.c.EUR_CRM_CG_EmptyHierarchyInputs").replace('{name}', view));
                    }
                    fieldValues.push(branch.LevelName  + '__' + parseInt(itemInfoPath[i]));
                }
                // Determine what view fields need to be filled
                viewFieldsToSet = (viewIndex == 0 ? viewFields1 : viewFields2);
                if(isDynamic) {
                    var productPath = item.product.Path.split('<path>');
                    productFieldNames.concat(marketingFieldNames).forEach(function(field, index){
                        obj[field.replace('Description', '')] = productPath[index];
                    });
                } else {
                    var sortOrderField = viewIndex == 0 ? 'OrderView1' : 'OrderView2';
                    obj[sortOrderField] = orderIndex;
                    obj.multiplication_factor = parseFloat(item.product.multiplication_factor);

                    // inject values from product
                    /* TODO: remove
                    obj.Pckg = null;
                    obj.MinQty = null;
                    obj.MaxQty = null;
                    obj.DelStart = null;
                    obj.DelEnd = null;
                    obj.PrStart = null;
                    obj.PrEnd = null;
                    obj.OOSStart = null;
                    obj.OOSEnd = null;

                    obj.templPBIs = item.product.templPBIs;

                    if(!$A.util.isEmpty(item.product.MinQty)
                    		&& !isNaN(item.product.MinQty)
                    		&& parseInt(item.product.MinQty) > 0
                    		&& parseInt(item.product.MinQty) != parseInt(item.product.MinQtyP)
                    ){
                    	obj.MinQty = item.product.MinQty;
                    }
                    if(!$A.util.isEmpty(item.product.MaxQty)
                    		&& !isNaN(item.product.MaxQty)
                    		&& parseInt(item.product.MaxQty) > 0
                    		&& parseInt(item.product.MaxQty) != parseInt(item.product.MaxQtyP)
                    ){
                    	obj.MaxQty = item.product.MaxQty;
                    }

                    if(isReturn === true){
                    	// return has packaging of 1
                    	obj.Pckg = 1;
                    } else {
                    	if(!$A.util.isEmpty(item.product.Pckg)
                    		&& !isNaN(item.product.Pckg)
                    		&& parseInt(item.product.Pckg) > 0
                    		&& parseInt(item.product.Pckg) != parseInt(item.product.PckgP)
	                    ){
	                    	obj.Pckg = item.product.Pckg;
	                    }
                    }

                    // inject delivery dates, if placeholders are overwritten
                    if( new Date(item.product.DelStart).getTime() !== new Date(item.product.DelStartP).getTime()){
                    	obj.DelStart = item.product.DelStart || null;
                    } else {
                    	obj.DelStart = null;
                    }
                    if(new Date(item.product.DelEnd).getTime() !== new Date(item.product.DelEndP).getTime()){
                    	obj.DelEnd = item.product.DelEnd || null;
                    } else {
                    	obj.DelEnd = null;
                    }

                    // inject product dates, if placeholders are overwritten
                    if( new Date(item.product.PrStart).getTime() !== new Date(item.product.PrStartP).getTime()){
                    	obj.PrStart = item.product.PrStart || null;
                    } else {
                    	obj.PrStart = null;
                    }
                    if(new Date(item.product.PrEnd).getTime() !== new Date(item.product.PrEndP).getTime()){
                    	obj.PrEnd = item.product.PrEnd || null;
                    } else {
                    	obj.PrEnd = null;
                    }
                    // inject out of stock dates
                    if(!$A.util.isEmpty(item.product.OOSStart) && !isNaN(new Date(item.product.OOSStart).getTime())){
                    	obj.OOSStart = item.product.OOSStart;
                    }
                    if(!$A.util.isEmpty(item.product.OOSEnd) && !isNaN(new Date(item.product.OOSEnd).getTime())){
                    	obj.OOSEnd = item.product.OOSEnd;
                    }

                    // inject template quantity and price depending on RT
                    if(isTemplate === true || isTransfer === true){
	                    if(!$A.util.isEmpty(item.product.TemplQty)
                    		&& !isNaN(item.product.TemplQty)
                    		&& parseInt(item.product.TemplQty) > 0
                    		&& parseInt(item.product.TemplQty) != parseInt(item.product.TemplQtyP)
	                    ){
	                    	obj.TemplQty = item.product.TemplQty;
	                    }
                    } else {
                    	obj.TemplQty = null;
                    }
                    // inject price for transfer only
                    if(isTransfer === true){
                    	obj.Price = item.product.Price || null;
                    } else {
                    	obj.Price = null;
                    }
                    // for return wipe unecessary fields
                    if(isReturn === true){
                    	obj.OOSStart = null;
                    	obj.OOSEnd = null;
                    	obj.MinQty = null;
                    	obj.MaxQty = null;
                    	obj.Pckg = null;
                    }
                    */

                }

                viewFieldsToSet.forEach(function(field, index){
                    obj[field] = fieldValues[index] ? fieldValues[index].trim() : null;
                });
                obj.productId = item.product.Id;
                obj.pbi = item.product.pbi;

                productsInfo.push(obj);
            });
        });

        return productsInfo;
    },

    getUrlParams: function (url) {
        var params = {};
        (url + '?').split('?')[1].split('&').forEach(function (pair) {
            pair = (pair + '=').split('=').map(decodeURIComponent);
            if (pair[0].length) {
                params[pair[0]] = pair[1];
            }
        });
        return params;
    },

    /*====================================================
    *                VALIDATION BLOCK
    *=====================================================*/
    /* TODO: remove
   validateDeliveryDates: function(cmp) {
	   var mdcmp = cmp.find('manageDeliveriesCmp');
	   if(mdcmp){
		   var isvalid = mdcmp.doValidate();
		   if(!isvalid){
			   throw new Error($A.get("$Label.c.CG_BadDeliveryDates"));
		   }
	   }
   },
     */
    /* Function to validate catalog entered data
    */
    validateCatalogInputs: function(cmp) {
        var
            catalogName = cmp.find('catalogName'),
            nameValue = catalogName.get("v.value"),
            group = cmp.find('accountGroup'),
            availableForAll = false,
            startDate = cmp.find('startDateField'),
            stValue = startDate.get('v.value'),
            endDate = cmp.find('endDateField'),
            edValue = endDate.get('v.value'),
            pricingDate = cmp.find('pricingDateField'),
            pricingDateValue = pricingDate ? pricingDate.get('v.value') : null,
            catalogOrderType = cmp.find('catalogOrderType'),
            catalogOrderTypeValue = catalogOrderType ? catalogOrderType.get('v.value') : '',
            isOrder = cmp.get('v.isOrder'),
            isReturn = cmp.get('v.isReturn'),
            isTransfer = cmp.get('v.isTransfer'),
            isTemplate = cmp.get('v.isTemplate'),
            catalogReturnReason = cmp.find('catalogReturnReason'),
            catalogReturnReasonValue = catalogReturnReason ? catalogReturnReason.get('v.value'): '',
            viewName1 = cmp.find('viewName1'),
            viewName1value = viewName1.get("v.value"),
            viewName2 = cmp.find('viewName2'),
            viewName2value = viewName2 ? viewName2.get("v.value") : '',
            catalogFieldLabels = cmp.get("v.catalogFieldLabels"),
            //wholesaler = isTransfer ? cmp.find("wholesaler") : null,
            //wholesalerVal = isTransfer ? wholesaler.get("v.value") : null,
            errorFields = [];

        viewName1.set("v.errors", null);

        if(viewName2){
            viewName2.set("v.errors", null);
        }


        if ($A.util.isUndefinedOrNull(nameValue) || $A.util.isEmpty(nameValue.trim())) {
            catalogName.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_EmptyFieldError") }]);
            errorFields.push(catalogFieldLabels.EUR_CRM_ProductCatalog__c.Name);
        } else {
            catalogName.set("v.errors", null);
        }

        if ($A.util.isUndefinedOrNull(viewName1value) || $A.util.isEmpty(viewName1value.trim())) {
            viewName1.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_EmptyFieldError") }]);
            errorFields.push(catalogFieldLabels.EUR_CRM_ProductCatalog__c.EUR_CRM_ViewName1__c);
        } else {
            viewName1.set("v.errors", null);
        }
        if ($A.util.isUndefinedOrNull(stValue) || $A.util.isEmpty(stValue.trim())) {
            startDate.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_EmptyFieldError") }]);
            errorFields.push(catalogFieldLabels.EUR_CRM_ProductCatalog__c.EUR_CRM_ValidFrom__c);
        } else {
            startDate.set("v.errors", null);
        }
        if ($A.util.isUndefinedOrNull(edValue) || $A.util.isEmpty(edValue.trim())) {
            endDate.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_EmptyFieldError") }]);
            errorFields.push(catalogFieldLabels.EUR_CRM_ProductCatalog__c.EUR_CRM_ValidTo__c);
        } else {
            endDate.set("v.errors", null);
        }
        /*
        if ((isOrder && catalogOrderTypeValue === 'Presales') && ($A.util.isUndefinedOrNull(pricingDateValue) || $A.util.isEmpty(pricingDateValue.trim()))) {
            pricingDate.set("v.errors", [{ message: $A.get("$Label.c.CG_EmptyFieldError") }]);
            errorFields.push(catalogFieldLabels.EUR_CRM_ProductCatalog__c.EUR_CRM_FuturePricingDate__c);
        } else if (isOrder && catalogOrderTypeValue === 'Presales') {
            pricingDate.set("v.errors", null);
        }
         */
        /* Order type should not be required
		* @edit 24.04.18 PZ - Order type brought back
		* @edit 26.06.18 PZ - Order type brought back only for Order RT
         */
        if (($A.util.isUndefinedOrNull(catalogOrderTypeValue) || $A.util.isEmpty(catalogOrderTypeValue.trim()))) {
            catalogOrderType.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_EmptyFieldError") }]);
            errorFields.push(catalogFieldLabels.EUR_CRM_ProductCatalog__c.EUR_CRM_OrderType__c);
            $A.util.addClass(catalogOrderType, 'has-error');
            cmp.set('v.fieldMessage', { OrderType__c : $A.get("$Label.c.EUR_CRM_EmptyFieldErrorr") });
        } else {
            catalogOrderType.set("v.errors", null);
            $A.util.removeClass(catalogOrderType, 'has-error');
            cmp.set('v.fieldMessage', {});
        }



        /*  Return reason should not be required
		*
		*	@edit 16.04.18 PZ - Return reason brought back
         */
        if (isReturn && ($A.util.isUndefinedOrNull(catalogReturnReasonValue) || $A.util.isEmpty(catalogReturnReasonValue.trim()))) {
            catalogOrderType.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_EmptyFieldError") }]);
            errorFields.push(catalogFieldLabels.EUR_CRM_ProductCatalog__c.EUR_CRM_ReturnReason__c);
            $A.util.addClass(catalogReturnReason, 'has-error');
            cmp.set('v.fieldMessage', { ReturnReason__c : $A.get("$Label.c.EUR_CRM_EmptyFieldError") });
        } else {
            catalogReturnReason.set("v.errors", null);
            $A.util.removeClass(catalogReturnReason, 'has-error');
            cmp.set('v.fieldMessage', {});
        }

        if(!availableForAll) {
            if ($A.util.isEmpty(group.get("v.value"))) {
                group.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_EmptyFieldError") }]);
                errorFields.push(catalogFieldLabels.EUR_CRM_ProductCatalog__c.EUR_CRM_AccountGroupId__c);
                //errorFields.push($A.get("$Label.c.CG_AccountGroup"));
            } else {
                group.set("v.errors", null);
            }
        }
        /*
        if(isTransfer){
        	if($A.util.isUndefinedOrNull(wholesalerVal) || $A.util.isEmpty(wholesalerVal.trim())){
        		// require wholesaler field populated for transfers
        		errorFields.push(catalogFieldLabels.EUR_CRM_ProductCatalog__c.EUR_CRM_Wholesaler__c);
        		// show error highlighting on lookup
        		wholesaler.doValidate();
        	}
        }
         */
        if(errorFields.length) {
            throw new Error($A.get("$Label.c.EUR_CRM_CG_RequiredFieldsError") + ': ' + errorFields.join(', '));
        }

        if (viewName2value && viewName1value.trim() == viewName2value.trim()) {
            viewName1.set("v.errors", [{message:""}]);
            viewName2.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_CG_EqualViewNamesFieldError") }]);
            throw new Error($A.get("$Label.c.EUR_CRM_CG_EqualViewNamesError"));
        }

        var
            stDate = new Date(stValue),
            edDate = new Date(edValue),
            pricingDt = new Date(pricingDateValue),
            currentDate = new Date().toISOString().split('T')[0];

        if(!isNaN(stValue) || !stDate instanceof Date || isNaN(stDate.valueOf())) {
            startDate.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_FieldError") }]);
            throw new Error($A.get("$Label.c.EUR_CRM_CG_SDateFieldError"));
        }
        if(!isNaN(edValue) || !edDate instanceof Date || isNaN(edDate.valueOf())) {
            endDate.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_FieldError") }]);
            throw new Error($A.get("$Label.c.EUR_CRM_CG_EDateFieldError"));
        }
        if(stDate >= edDate) {
            startDate.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_FieldError") }]);
            throw new Error($A.get("$Label.c.EUR_CRM_CG_StartDateError"));
        }
        // Comparing ISO strings below
        if(edValue <= currentDate) {
            endDate.set("v.errors", [{ message: $A.get("$Label.c.EUR_CRM_FieldError") }]);
            throw new Error($A.get("$Label.c.EUR_CRM_CG_EndDateError"));
        }
        // pricing date format validation
        /*
        if(( (isOrder || isTemplate) && catalogOrderTypeValue === 'Presales') && (!isNaN(pricingDateValue) || !(pricingDt instanceof Date) || isNaN(pricingDt.valueOf()))) {
            pricingDate.set("v.errors", [{ message: $A.get("$Label.c.CG_FieldError") }]);
            throw new Error($A.get("$Label.c.CG_SDateFieldError"));
        }
         */
    },
    /* Function to validate dropped products input data
    * Order and Multiplication Factor
    */
    validateSelectedProducts: function(cmp) {
        var
            droppedItems = cmp.get('v.droppedItems'),
            views = cmp.get('v.hierarchyViews'),
            isDynamic = cmp.get('v.isDynamic'),
            isTransfer = cmp.get('v.isTransfer'),
            isReturn = cmp.get('v.isReturn'),
            vbs = cmp.find('viewBuilderCmp'),
            catDelDates = cmp.get('v.templDelDates'),
            isValid = true;

        function countPrecision(a) {
            if (!isFinite(a) || isNaN(a) || typeof a != 'number') return 0;
            var e = 1, p = 0;
            while (Math.round(a * e) / e !== a) { e *= 10; p++; }
            return p;
        }

        [].concat(vbs).forEach(function(vb) {
            // force lightning input highlighting
            isValid = vb.validateItems();
        });
        if(!isValid){
            //throw new Error('Please check catalog item details');
        }

        views.forEach( function(view) {
            var viewDroppedItems = droppedItems[view];
            viewDroppedItems.forEach(function(item){
                /*
                var delEnd = null;
                var delStart = null;
                var maxQty = null;
                var minQty = null;
                var pckg = null;
                var pckgP = null;
                var tQty = null;
                var price = null;

                var OOSStart = null;
                var OOSEnd = null;
                var PrStart = null
                var PrEnd = null;

                var delDates = item.product.templPBIs ? item.product.templPBIs : [];

                if(item.product.DelEnd){
                    delEnd = new Date(item.product.DelEnd);
                } else if (item.product.DelEndP){
                    delEnd = new Date(item.product.DelEndP);
                }

                if(item.product.DelStart){
                    delStart = new Date(item.product.DelStart);
                } else if (item.product.DelStartP){
                    delStart = new Date(item.product.DelStartP);
                }

                if(item.product.MaxQty != null){
                    maxQty = parseInt(item.product.MaxQty);
                } else if (item.product.MaxQtyP != null){
                    maxQty = parseInt(item.product.MaxQtyP);
                }

                if(item.product.MinQty != null){
                    minQty = parseInt(item.product.MinQty);
                } else if (item.product.MinQtyP != null){
                    minQty = parseInt(item.product.MinQtyP);
                }
                if(item.product.Pckg != null){
                    pckg = parseInt(item.product.Pckg);
                } else if (item.product.PckgP != null){
                    //pckg = parseInt(item.product.PckgP);
                }
                if(item.product.PckgP != null){
                    pckgP = parseInt(item.product.PckgP);
                }
                if(item.product.TemplQty != null){
                    tQty = parseInt(item.product.TemplQty);
                } else if (item.product.TemplQtyP){
                    //tQty = parseInt(item.product.TemplQtyP);
                }
                if(item.product.Price != null){
                    price = parseFloat(item.product.Price);
                }
                if(item.product.OOSStart){
                    OOSStart = new Date(item.product.OOSStart);
                } else if (item.product.DelStartP){
                    OOSStart = new Date(item.product.OOSStartP);
                }
                if(item.product.OOSEnd){
                    OOSEnd = new Date(item.product.OOSEnd);
                } else if (item.product.DelStartP){
                    OOSEnd = new Date(item.product.OOSEndP);
                }
                if(item.product.PrStart){
                    PrStart = new Date(item.product.PrStart);
                } else if (item.product.DelStartP){
                    PrStart = new Date(item.product.PrStartP);
                }
                if(item.product.PrEnd){
                    PrEnd = new Date(item.product.PrEnd);
                } else if (item.product.DelStartP){
                    PrEnd = new Date(item.product.PrEndP);
                }
                if(delEnd && delStart && delEnd.getTime() < delStart.getTime()){
                    throw new Error($A.get("$Label.c.CG_CatItemBadDate"));
                }


                // return should have no min/max qty and packaging
                if(isReturn != true && (maxQty != null) && (minQty != null) && (isNaN(maxQty) || isNaN(minQty) || maxQty < 0 || minQty < 0 || maxQty < minQty)){
                    throw new Error($A.get("$Label.c.CG_CatItemBadQuantity"));
                }

                if(isReturn != true && (pckg != null) && !$A.util.isEmpty(pckg) && !isNaN(pckg)){ // allow empty input

                    if((isNaN(pckg) || pckg < 1)){
                        throw new Error($A.get("$Label.c.CG_CatItemBadPackaging"));
                    } else {
                        // packaging is provided
                        if( (pckgP != null) && !isNaN(pckgP) && pckgP != 0 && (pckg % pckgP !== 0)){
                            // check packaging is multiple of value on product (pckgP)
                            throw new Error($A.get("$Label.c.CG_CatItemBadPackaging"));
                        }
                        // check if maxQty and minQty are multiples of packaging
                        if(( (maxQty != null) && !isNaN(maxQty) && (maxQty % pckg !== 0)) || ( (minQty != null) && !isNaN(minQty) && (minQty % pckg !== 0)) ){
                            throw new Error($A.get("$Label.c.CG_CatItemBadQuantity"));
                        }
                        // check that packaging doesn't exceed maximum quantity
                        if( (maxQty != null) && pckg > maxQty){
                            throw new Error($A.get("$Label.c.CG_CatItemPckgNotInRange"));
                        }
                    }
                }

                if(tQty && (isNaN(tQty) || tQty < 0)){
                    throw new Error($A.get("$Label.c.CG_CatItemBadTQuantity"));
                }
                // template quantity should be > minQty and < maxQty
                if(tQty && minQty && tQty < minQty){
                    throw new Error($A.get("$Label.c.CG_CatItemTQtyNotInRange"));
                }
                if(tQty && maxQty && tQty > maxQty){
                    throw new Error($A.get("$Label.c.CG_CatItemTQtyNotInRange"));
                }

                if(isTransfer && (!price || isNaN(price) || price < 0 || countPrecision(price) > 2)){
                    throw new Error($A.get("$Label.c.CG_CatItemBadPrice"));
                }
                // return should have no oos start/stop
                if(isReturn != true && OOSStart && OOSEnd && !isNaN(OOSStart.getTime()) && !isNaN(OOSEnd.getTime()) && OOSEnd.getTime() < OOSStart.getTime()){
                    throw new Error($A.get("$Label.c.CG_CatItemBadOOSDate"));
                }
                if(PrStart && PrEnd && !isNaN(PrStart.getTime()) && !isNaN(PrEnd.getTime()) && PrEnd.getTime() < PrStart.getTime()){
                    throw new Error($A.get("$Label.c.CG_CatItemBadStartStopDate"));
                }

                // delivery quantity validation
                if(delDates && catDelDates && $A.util.isArray(catDelDates)){
                    for(var p=0; p< delDates.length; p++){
                        var thisQty = delDates[p].delQty;
                        if(catDelDates.indexOf(delDates[p].delDate) != -1){ // contained in delivery dates
                            if($A.util.isUndefinedOrNull(thisQty) || isNaN(thisQty) || thisQty < 0){
                                throw new Error('Check delivery quantities on product: '+item.product.Name);
                            }
                        }
                    }
                }

                 Do not validate multiplication factor

                if(!isDynamic) {
                    var multiplication_factor = parseFloat(item.product.multiplication_factor);
                    if(isNaN(multiplication_factor)) {
                        throw new Error($A.get("$Label.c.CG_NotNumberError")
                            .replace('{name}', view)
                            .replace('{field}', 'Multiplication Factor')
                        );
                    } else if(multiplication_factor < 0) {
                        throw new Error($A.get("$Label.c.CG_MFValueError").replace('{name}', view));
                    }
                }
                 */
            });
        });
    },

    /* Function to validate entered data
    *  1. Static catalog
    *   - View cannot be empty
    *   - Number of droppedItems in each view should be equal to selected products count
    *   - Number of droppedItems is calculated as a length of items in a view
    *  2. Dynamic catalog
    *   - View cannot be empty
    *   - Number of droppedItems in each view should be equal to dynamic product data length in appropriate view
    *   - Each view products have its own prefix before Id (Currently 'PV' and 'MV')
    *   - In case there is only one view, getting the value of view switcher to determine what view is used
    *       to work with PV or MV products
    *   - Number of droppedItems is calculated as a number of Id (separated with <id> tag) inserted in a view
    */
    validateViews: function(cmp) {
        var
            helper = this,
            droppedItems = cmp.get("v.droppedItems"),
            views = cmp.get('v.hierarchyViews'),
            checked = cmp.find('hierarchyView').get('v.checked'),
            isDynamic = cmp.get("v.isDynamic"),
            products = isDynamic ? cmp.get("v.dynamicProductData") : cmp.get("v.products");
        console.log('products', products);
        console.log('droppedItems', droppedItems);
        helper.isEmptyViews(droppedItems, views);
        helper.isIdenticalProductsInViews(droppedItems, views);
    },

    isIdenticalProductsInViews: function(droppedItems, views) {
        if(views && views.length == 2) {
            var productsIds = {};
            views.forEach(function(view) {
                if(!productsIds[view]) productsIds[view] = [];
                droppedItems[view].forEach(function(item) {
                    productsIds[view].push(item.product.Id);
                });
            });
            if(productsIds[views[0]].length != productsIds[views[1]].length ||
                !this.compareRecordsSet(productsIds[views[0]], productsIds[views[1]])) {
                throw new Error($A.get("$Label.c.EUR_CRM_CG_ViewCompletionError"));
            }
        }
    },
    compareRecordsSet: function(arr1, arr2) {
        var areEqual = true;
        arr1.forEach(function(el) {
            if(arr2.indexOf(el) == -1) areEqual = false;
        });
        return areEqual;
    },

    isEmptyViews: function(droppedItems, views) {
        views.forEach(function(view) {
            if(!droppedItems[view] || !droppedItems[view].length) {
                throw new Error($A.get("$Label.c.EUR_CRM_CG_EmptyViewError").replace('{name}', view));
            }
        });
    }
    /*====================================================
    *                END OF VALIDATION BLOCK
    *=====================================================*/
})