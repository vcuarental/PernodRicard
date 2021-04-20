({
    loadCatalog: function(cmp, helper, catalogId) {
        var action = cmp.get('c.getCatalogData');
        action.setParams({ 'catalogId' : catalogId , 'recordTypeId' : null });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === 'SUCCESS') {
                var result = JSON.parse(response.getReturnValue());
                console.log(result);
                // loading catalog info
                var catalog = cmp.get('v.catalog');
                catalog.Id = catalogId;
                catalog.ViewName1__c = result.viewName1;
                catalog.ViewName2__c = result.viewName2;
                catalog.IsDynamic__c = result.isDynamic;
                catalog.EUR_CRM_IsStandard__c = result.isStandard;
                
                console.log('catalog', catalog);
                cmp.set('v.catalog', catalog);
                if(catalog.EUR_CRM_IsStandard__c == true) return;
                cmp.set('v.isDynamic', catalog.IsDynamic__c);
                cmp.set('v.recordTypeDevName', result.catalogRecTypeDName);
                // set hierarchy views
                var hierarchyViews = [];
                if(catalog.ViewName1__c) hierarchyViews.push(catalog.ViewName1__c);
                if(catalog.ViewName2__c) hierarchyViews.push(catalog.ViewName2__c);
                cmp.set('v.hierarchyViews', hierarchyViews);
                cmp.set('v.activeView', hierarchyViews[0]);
                // loading catalog items info
                var catalogProductData = [];
                result.productsInfo.forEach(function(data) {
                    if(catalog.IsDynamic__c) {
                        catalogProductData.push({
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
                            View2Level4: data.View2Level4
                        });
                    } else {
                        catalogProductData.push({
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
                            View2Level4: data.View2Level4
                        });
                    }
                });
                console.log('catalogProductData', catalogProductData);
                cmp.set("v.catalogProductData", catalogProductData);
                helper.getProductList(cmp, helper);
            }
        });
        $A.enqueueAction(action);
    },

    getProductList: function(cmp, helper) {
        var
            productsMap = [],
            productBrands = [],
            isDynamic = cmp.get('v.isDynamic'),
            action = cmp.get("c.getProductList");
            
        action.setParams({ "catalogRecordTypeDevName" : cmp.get("v.recordTypeDevName") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                var products = [];
                result.forEach(function(item) {
                     var product = item;
                     product.Id = item.productId;
                     product.checked = false;
                     products.push(product);
                });
                if(isDynamic) {
                    var dynamicProducts = [];
                    products.forEach(function(product){
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
                             checked: false
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
                             checked: false
                         });
                    });
                    dynamicProducts = helper.getSelectedFromLoadedProducts(cmp, dynamicProducts);
                } else {
                    products = helper.getSelectedFromLoadedProducts(cmp, products);
                }
                helper.generateCatalogHierarchy(cmp, helper);
            } else if (cmp.isValid() && state === "INCOMPLETE") {
                alert('The server didn\'t return a response.');
            } else if (cmp.isValid() && state === "ERROR") {
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
        $A.enqueueAction(action);
    },

    getSelectedFromLoadedProducts: function(cmp, products) {
        var
            helper = this,
            catalogProductData = cmp.get('v.catalogProductData'),
            isDynamic = cmp.get('v.isDynamic'),
            productFields = { name: 'ProductLevel', count: 5 },
            marketingFields = { name: 'MarketingLevel', count: 4 },
            dynamicLowestSelectedLevel = {};

        if(catalogProductData && catalogProductData.length) {
            products.forEach(function(product) {
                product.checked = false;
            });
            products.forEach(function(product) {
                catalogProductData.forEach(function(data) {
                    if(!isDynamic && data.Id == product.Id) {
                        data.isFound = true;
                        product.checked = true;
                    } else if(isDynamic) {
                        var currentProdSelectLevel = dynamicLowestSelectedLevel[product.Id] || 0;
                        var fieldsToCompare = product.Id.startsWith('PV') ? productFields : marketingFields;
                        var productIdentifier = '';
                        var loadedCategoryIdentifier = '';
                        var categoryDepth = 0;
                        for(var i = 1; i <= fieldsToCompare.count; i++) {
                            var loadedValue = data[fieldsToCompare.name + i];
                            if(loadedValue) {
                                categoryDepth++;
                                loadedCategoryIdentifier += loadedValue;
                                productIdentifier += product[fieldsToCompare.name + i];
                            }
                        }
                        if(loadedCategoryIdentifier && productIdentifier.startsWith(loadedCategoryIdentifier)) {
                            data.isFound = true;
                            product.checked = true;
                            dynamicLowestSelectedLevel[product.Id] = categoryDepth;
                        }
                    }
                });
            });
            console.log('dynamicLowestSelectedLevel', dynamicLowestSelectedLevel);
            cmp.set("v.dynamicLowestSelectedLevel", dynamicLowestSelectedLevel);
            var availableLoadedData = [];
            catalogProductData.forEach(function(data) {
                if(data.isFound) {
                    availableLoadedData.push(data);
                }
            });
            cmp.set("v.catalogProductData", availableLoadedData);
        }
        console.log('products', products);
        cmp.set("v.products", products);
    },

    generateCatalogHierarchy: function(cmp, helper) {
        var catalogProductData = cmp.get('v.catalogProductData');
        console.log('catalogProductData', catalogProductData);
        if(!catalogProductData || !catalogProductData.length) return;

        var isDynamic = cmp.get('v.isDynamic');
        if(isDynamic) helper.initSelectedProductsDynamicData(cmp, helper);
        helper.buildViewsFromLoadedProducts(cmp, helper);
    },

    initSelectedProductsDynamicData: function(cmp, helper) {
        var
            products = cmp.get("v.products"),
            selectedProducts = [],
            activeView,
            hierarchyViews = cmp.get('v.hierarchyViews'),
            checked = false,
            dynamicLowestSelectedLevel = cmp.get("v.dynamicLowestSelectedLevel"),
            view1hierarchyFields = helper.getHierarchyFields(cmp, false),
            view2hierarchyFields = helper.getHierarchyFields(cmp, true),
            maxLevelPV = 0,
            maxLevelMV = 0;

        products.forEach(function(product) {
            if(product.checked) selectedProducts.push(product);
        });
        // define what lower level will be used for each view
        for(var key in dynamicLowestSelectedLevel) {
            if(key.startsWith('PV') && maxLevelPV < dynamicLowestSelectedLevel[key]) {
                maxLevelPV = dynamicLowestSelectedLevel[key];
            } else if(key.startsWith('MV') && maxLevelMV < dynamicLowestSelectedLevel[key]) {
                maxLevelMV = dynamicLowestSelectedLevel[key];
            }
        }
        // cut hierarchy field with the lowest depths selected
        console.log('maxLevelPV', maxLevelPV);
        view1hierarchyFields.length = maxLevelPV;
        console.log('maxLevelMV', maxLevelMV);
        view2hierarchyFields.length = maxLevelMV;
        console.log('view1hierarchyFields', view1hierarchyFields);
        console.log('view2hierarchyFields', view2hierarchyFields);
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
            //var categoryPath = '';
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
                    obj[fieldsPosition[0]] = labelDynamicPath[index];
                    obj[fieldsPosition[1]] = labelDynamicPath[index];
                } else if(mainHierarchyFields.length && secondaryHierarchyFields.length && mainHierarchyFields.length + secondaryHierarchyFields.length == index + 1) {
                    obj[fieldsPosition[0]] += ' - ' + labelDynamicPath[index];
                    obj[fieldsPosition[1]] = labelDynamicPath[index] + ' - ' + obj[fieldsPosition[1]];
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
        console.log('productData', productData);
        cmp.set('v.dynamicProductData', productData);
    },

    buildViewsFromLoadedProducts: function(cmp, helper) {
        var
            products = cmp.get('v.products'),
            catalogProductData = cmp.get('v.catalogProductData'),
            droppedItems = cmp.get('v.droppedItems'),
            isDynamic = cmp.get('v.isDynamic'),
            dynamicProductData = cmp.get('v.dynamicProductData'),
            dynamicLowestSelectedLevel = cmp.get("v.dynamicLowestSelectedLevel"),
            views = cmp.get('v.hierarchyViews'),
            hierarchyBuildingItems = {},
            hierarchyDepths = {},
            hierarchyFields1 = helper.getHierarchyFields(cmp, false),
            hierarchyFields2 = helper.getHierarchyFields(cmp, true),
            view1Fields = ['View1Level1', 'View1Level2', 'View1Level3', 'View1Level4'],
            view2Fields = ['View2Level1', 'View2Level2', 'View2Level3', 'View2Level4'],
            viewStartFields = ['View1Level1', 'View2Level1'];

        catalogProductData.forEach(function(productData) {
        // set hierarchyDepths on each view and set views
            var view1HierarchyDepth = 0;
            var view2HierarchyDepth = 0;
            var hierarchyView1Path = [];
            var hierarchyView2Path = [];
            view1Fields.forEach(function(field) {
                if(productData[field]) {
                    view1HierarchyDepth++;
                    hierarchyView1Path.push(productData[field]);
                }
            });
            view2Fields.forEach(function(field) {
                if(productData[field]) {
                    view2HierarchyDepth++;
                    hierarchyView2Path.push(productData[field]);
                }
            });
            console.log('hierarchyView1Path', hierarchyView1Path);
            if(hierarchyView1Path.length && views[0]) {
                hierarchyBuildingItems = helper.addLoadedCategory(helper, hierarchyBuildingItems, hierarchyView1Path, views[0]);
            }
            console.log('hierarchyView2Path', hierarchyView2Path);
            if(hierarchyView2Path.length && views[1]) {
                hierarchyBuildingItems = helper.addLoadedCategory(helper, hierarchyBuildingItems, hierarchyView2Path, views[1]);
            }
            if(!hierarchyDepths[views[0]] || hierarchyDepths[views[0]] < view1HierarchyDepth) hierarchyDepths[views[0]] = view1HierarchyDepth;
            if(!hierarchyDepths[views[1]] || hierarchyDepths[views[1]] < view2HierarchyDepth) hierarchyDepths[views[1]] = view2HierarchyDepth;
        });
        views.forEach(function(viewName) {
            if(!hierarchyBuildingItems[viewName] || !hierarchyBuildingItems[viewName].length) {
                hierarchyBuildingItems[viewName] = [{
                    LevelName: $A.get("$Label.c.EUR_CRM_CG_Branch"),
                    SubLevels: [],
                    collapsed: false
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
        catalogProductData.forEach(function(productData) {
            var matchedProduct;
            var sequenceInViews = [productData.OrderView1, productData.OrderView2];
            if(!isDynamic) {
                products.forEach(function(product) {
                    if(productData.Id == product.Id && product.checked) {
                        console.log('product found');
                        matchedProduct = product;
                    }
                });
            } else {
                var separator = '<cat>';
                var loadedProductIdentifier = '';
                var productHierarchyPath = '';
                hierarchyFields1.concat(hierarchyFields2).forEach(function(field) {
                    var loadedValue = productData[field.replace('Description', '')];
                    if(loadedValue) {
                        loadedProductIdentifier += loadedValue + separator;
                        productHierarchyPath += loadedValue + '<path>';
                    }
                });
                console.log('loadedProductIdentifier', loadedProductIdentifier);
                loadedProductIdentifier = loadedProductIdentifier.substr(0, loadedProductIdentifier.length - separator.length);
                dynamicProductData.forEach(function(dynamicProduct) {
                    console.log('dynamicProduct.Id', dynamicProduct.Id);
                    if(dynamicProduct.Id == loadedProductIdentifier && dynamicProduct.checked) {
                        console.log('dynamic product found');
                        matchedProduct = {
                            Id: dynamicProduct.Id,
                            Name: dynamicProduct.Name,
                            Path: productHierarchyPath
                        };
                    }
                });
            }
            if(matchedProduct) {
                viewStartFields.forEach(function(initField, index) {
                    if(views[index] && productData[initField]) {
                        var droppedProduct = { product : matchedProduct };
                        if(!droppedItems[views[index]]) droppedItems[views[index]] = [];
                        droppedProduct.branchIndex = 'branch';
                        var branches = hierarchyBuildingItems[views[index]];
                        var fieldsToCompare = index == 0 ? view1Fields : view2Fields;
                        var indexSeparator = '__';
                        fieldsToCompare.forEach(function(field) {
                            if(productData[field]) {
                                var separatorLocation = productData[field].lastIndexOf(indexSeparator);
                                //var branchNameWithoutIndex = separatorLocation > -1 ? productData[field].substr(0, separatorLocation) : productData[field];
                                var hierarchyObjectIndex = helper.arrayObjectIndexOf(branches, productData[field], 'Id');
                                if(hierarchyObjectIndex != -1) {
                                    droppedProduct.branchIndex += '-' + hierarchyObjectIndex;
                                    branches = branches[hierarchyObjectIndex].SubLevels;
                                }
                            }
                        });
                        if(sequenceInViews[index]) {
                            droppedItems[views[index]][sequenceInViews[index]] = droppedProduct
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
        viewCmpList = viewCmpList.concat(cmp.find('viewBuilderCmp'));
        viewCmpList.forEach(function(viewBuilder) {
            var cmpViewName = viewBuilder.get('v.viewName');
            viewBuilder.setCategories(hierarchyDepths, hierarchyBuildingItems, droppedItems[cmpViewName]);
        });
        cmp.set('v.catalogProductData', null);
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

    addLoadedCategory: function(helper, hierarchyBuildingItems, hierarchyPath, viewName) {
        var
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

    selectTabActionHandler: function(cmp, event) {
        var viewTitle = event.target.getAttribute('title');
        var activeView = cmp.get('v.activeView');
        if(activeView != viewTitle) cmp.set('v.activeView', viewTitle);
    },

    getHierarchyFields: function(cmp, checked) {
        var hierarchyFields;
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
                'ProductLevel5Description'
            ];
        }
        return hierarchyFields;
    },

    arrayObjectIndexOf: function(array, searchTerm, property) {
        for(var i = 0, len = array.length; i < len; i++) {
            if (array[i] && array[i][property] === searchTerm) return i;
        }
        return -1;
    },
})