({
	init : function(component, event, helper) {
        component.set('v.showPlaceOrderPage', true);
        component.set('v.selectedDataList', []);
		helper.getSKUs(component, event, helper);
    },
    openModal: function(component, event, helper) {
        var searchMethod = component.get('v.searchMethod');
        var disabledSearchField = false;
        if (searchMethod === 'all') {
            disabledSearchField = true;
        }
        component.set('v.disabledSearchField', disabledSearchField);
        component.set("v.isModalOpen", true);
    },
    closeModal: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    getFilteredSKU: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        helper.getSKUs(component, event, helper);
    },
    handleFilterByClick: function(component, event, helper) {
        var searchMethod = event.getSource().get('v.name');
        var searchText = component.get('v.searchText');
        var filterButtonVariant = component.get('v.filterButtonVariant');
        var disabledSearchField = false;

        Object.keys(filterButtonVariant).forEach(key => {
            filterButtonVariant[key] = 'brand-outline';
        }); 
        filterButtonVariant[searchMethod] = 'brand';

        if (searchMethod === 'all') {
            searchText = '';
            disabledSearchField = true;
        }

        component.set('v.filterButtonVariant', filterButtonVariant);
        component.set('v.searchMethod', searchMethod);
        component.set('v.searchText', searchText);
        component.set('v.disabledSearchField', disabledSearchField);
    },
    handleAddClick: function(component, event, helper) {
        var recordId = event.getSource().get('v.name');
        var displayDataList = component.get('v.displayDataList');
        var selectedDataList = component.get('v.selectedDataList');

        var displayDataIndex = displayDataList.findIndex(data => data.sku.Id === recordId);
        var selectedDataIndex = selectedDataList.findIndex(data => data.sku.Id === recordId);

        if (displayDataIndex >= 0) {
            displayDataList[displayDataIndex].quantity += 1;

            if (selectedDataIndex < 0) {
                selectedDataList.push({
                    sku: displayDataList[displayDataIndex].sku,
                    quantity: displayDataList[displayDataIndex].quantity
                }); 
            } else {
                selectedDataList[selectedDataIndex].quantity = displayDataList[displayDataIndex].quantity;
            }
    
            component.set('v.selectedDataList', selectedDataList);
            component.set('v.displayDataList', displayDataList);
    
            var action = component.get('c.refreshTotalQuantity');
            $A.enqueueAction(action);
        }
    },
    handleMinusClick: function(component, event, helper) {
        var recordId = event.getSource().get('v.name');
        var displayDataList = component.get('v.displayDataList');
        var selectedDataList = component.get('v.selectedDataList');

        var displayDataIndex = displayDataList.findIndex(data => data.sku.Id === recordId);
        var selectedDataIndex = selectedDataList.findIndex(data => data.sku.Id === recordId);

        if (displayDataIndex >= 0) {
            if (displayDataList[displayDataIndex].quantity > 0) {
                displayDataList[displayDataIndex].quantity -= 1;

                if (selectedDataIndex >= 0) {
                    if (displayDataList[displayDataIndex].quantity > 0) {
                        selectedDataList[selectedDataIndex].quantity = displayDataList[displayDataIndex].quantity;
                    } else {
                        selectedDataList.splice(selectedDataIndex, 1);
                    }                   
                }
        
                component.set('v.selectedDataList', selectedDataList);
                component.set('v.displayDataList', displayDataList);
        
                var action = component.get('c.refreshTotalQuantity');
                $A.enqueueAction(action);
            }
        }
    },
    handleQuantityBlur: function(component, event, helper) {
        var source = event.getSource();
        var recordId = source.get('v.name');
        var value = parseInt(source.get('v.value'), 10);

        var selectedDataList = component.get('v.selectedDataList');
        var displayDataList = component.get('v.displayDataList');

        var displayDataIndex = displayDataList.findIndex(data => data.sku.Id === recordId);
        var selectedDataIndex = selectedDataList.findIndex(data => data.sku.Id === recordId);


        if (displayDataIndex >= 0) {
            displayDataList[displayDataIndex].quantity = value;

            if (selectedDataIndex < 0) {
                selectedDataList.push({
                    sku: displayDataList[displayDataIndex].sku,
                    quantity: displayDataList[displayDataIndex].quantity
                }); 
            } else {
                selectedDataList[selectedDataIndex].quantity = displayDataList[displayDataIndex].quantity;
            }
        }
        
        component.set('v.selectedDataList', selectedDataList);
        component.set('v.displayDataList', displayDataList);

        var action = component.get('c.refreshTotalQuantity');
        $A.enqueueAction(action);
    },
    refreshTotalQuantity: function(component, event, helper) {
        var selectedDataList = component.get('v.selectedDataList');

        var selectedDataQtyPrice = selectedDataList.map(data => ({ 
            quantity: data.quantity,
            price: data.sku.ASI_HK_CRM_Base_Price__c
         }));

        var totalQuantity = selectedDataQtyPrice.reduce((total, value) => total + value.quantity, 0);
        var totalPrice = selectedDataQtyPrice.reduce((total, value) => total + value.price || 0, 0);

        component.set('v.totalQuantity', totalQuantity);
        component.set('v.totalPrice', totalPrice);
        component.set('v.showTotalPrice', totalPrice > 0);
        component.set('v.disableCheckout', totalQuantity === 0);
    },
    handlePageBlur: function(component, event, helper) {
        var currentPage = component.get('v.currentPage');
		var totalPages = component.get('v.totalPages');

		if (currentPage >= 1 && currentPage <= totalPages) {
            helper.getSKUs(component, event, helper);
        }
    },
    handlePageClick: function(component, event, helper) {
        var source = event.getSource();
        var name = source.get('v.name');
        var currentPage = component.get('v.currentPage');
        var totalPages = component.get('v.totalPages');

        if (name === 'previous' && currentPage > 1) {
            currentPage -= 1;
        }
        if (name === 'next' && currentPage < totalPages) {
            currentPage += 1;
        }

        component.set("v.disabledPrevious", currentPage === 1);
        component.set("v.disabledNext", currentPage === totalPages);
        component.set('v.currentPage', currentPage);
        helper.getSKUs(component, event, helper);
    },
    navigateToCheckout: function(component, event, helper) {
        component.set('v.showPlaceOrderPage', false);
    },
    navigateBackToPlaceOrder: function(component, event, helper) {
        component.set('v.showPlaceOrderPage', true);
    },
    searchWholesalers: function(component, event, helper) {
        var searchStr = event.getSource().get('v.value');
        var checkWarehouseName = component.get('v.checkWarehouseName');

        if (checkWarehouseName != searchStr)
        {
            component.set('v.formWarehouseId', null);
        }

        if (searchStr != undefined && searchStr != null && searchStr != '' && searchStr.length >= 2)
        {
            component.set('v.searching', true);
            helper.searchWholesalers(component, event, helper, searchStr);
        }
        else
        {
            component.set('v.searching', false);
            component.set('v.wholesalers', []);
        }
    },
    selectWholesaler: function(component, event, helper) {
        var warehouseId = event.target.dataset.id;
        var warehouseName = event.target.dataset.name;
        component.set('v.formWarehouseId', warehouseId);
        component.set('v.formWarehouseName', warehouseName);
        component.set('v.checkWarehouseName', warehouseName);
        component.set('v.wholesalers', []);
    },
    submit: function(component, event, helper) {
        helper.submit(component, event, helper)
    }
})