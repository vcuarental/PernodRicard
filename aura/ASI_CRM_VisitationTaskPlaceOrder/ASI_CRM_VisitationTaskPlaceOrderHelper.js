({
	getSKUs : function(component, event, helper) {
        $A.util.removeClass(component.find("spinner"), 'slds-hide');

        var pageReference = component.get("v.pageReference");
        var customerId = pageReference.state.c__id;

        var selectedDataList = component.get("v.selectedDataList");
        var searchText = component.get("v.searchText");
        var searchMethod = component.get("v.searchMethod");
        var limitPerPage = component.get("v.limitPerPage");
        var currentPage = component.get("v.currentPage");
        var totalPages = component.get("v.totalPages");

        var action = component.get("c.getSKUs");
        action.setParams({
            customerId,
            searchText: searchText,
            searchMethod: searchMethod,
            limitPerPage: limitPerPage,
            offset: (currentPage - 1) * limitPerPage
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resultData = response.getReturnValue();
            var errors = response.getError();

            if (state === "SUCCESS") {
                totalPages = Math.ceil(resultData.total / limitPerPage);
                var displayDataList = resultData.skuList.map(sku => {
                    var selectedDataIndex = selectedDataList.findIndex(data => data.sku.Id === sku.Id);
                    return {
                        sku,
                        quantity: selectedDataIndex >= 0 ? selectedDataList[selectedDataIndex].quantity : 0
                    }
                });

                if (totalPages === 0) {
                    totalPages = 1;
                }

                component.set("v.customer", resultData.customer);
                component.set("v.displayDataList", displayDataList);
                component.set("v.rowCount", displayDataList.length);
                component.set("v.totalPages", totalPages);
                component.set("v.disabledPrevious", currentPage <= 1 || currentPage > totalPages);
                component.set("v.disabledNext", currentPage >= totalPages || currentPage < 1);

                component.set("v.formContactName", resultData.customer.ASI_CRM_CN_Contact_Person__c);
                component.set("v.formContactTelephone", resultData.customer.ASI_CRM_CN_Phone_Number__c);

                $A.util.addClass(component.find('spinner'), 'slds-hide');

                var action2 = component.get('c.refreshTotalQuantity');
                $A.enqueueAction(action2);
            } else if (errors && errors[0] && errors[0].message) {
                swal.fire({
                    title: 'Filter SKU',
                    text: errors[0].message,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'OK'
                }).then((result) => {
                    if (result.value) {
                        $A.util.addClass(component.find('spinner'), 'slds-hide');
                    }
                });
            } else {
                $A.util.addClass(component.find('spinner'), 'slds-hide');
            }
        });
        $A.enqueueAction(action);
    },
    searchWholesalers: function(component, event, helper, searchStr) {
        var action = component.get("c.getWholesalers");
        action.setParams({
            name: searchStr
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resultData = response.getReturnValue();
            var errors = response.getError();

            var searching = component.get('v.searching');

            if (searching)
            {
                if (state === "SUCCESS") {
                    component.set("v.wholesalers", resultData);
                } else if (errors && errors[0] && errors[0].message) {
                    swal.fire({
                        title: 'Search Wholesaler',
                        text: errors[0].message,
                        confirmButtonColor: '#3085d6',
                        cancelButtonColor: '#d33',
                        confirmButtonText: 'OK'
                    });
                }
            }
        });
        $A.enqueueAction(action);
    },
    submit: function(component, event, helper) {
        component.set('v.disabledSubmit', true);
        
        $A.util.removeClass(component.find("spinner"), 'slds-hide');

        var selectedDataList = component.get("v.selectedDataList");
        var customer = component.get("v.customer");
        var formWarehouseId = component.get("v.formWarehouseId");
        var formContactName = component.get("v.formContactName");
        var formContactTelephone = component.get("v.formContactTelephone");
        var formExpectedDeliveryDate = component.get("v.formExpectedDeliveryDate");
        var formRemark = component.get("v.formRemark");

        var action = component.get("c.saveIOT");
        var params = {
            iotHeaderStr: JSON.stringify({
                ASI_CRM_ContactNumber__c: formContactTelephone,
                ASI_CRM_ContactPerson__c: formContactName,
                ASI_CRM_Customer__c: customer.Id,
                ASI_CRM_Wholesaler__c: formWarehouseId,
                ASI_CRM_ExpectedDeliveryDate__c: formExpectedDeliveryDate,
                ASI_CRM_Remarks__c: formRemark
            }),
            iotDetailsStr: JSON.stringify(selectedDataList.map(data => ({
                ASI_CRM_Quantity__c: data.quantity,
                ASI_CRM_SKU__c: data.sku.Id
            }))),
        }

        action.setParams(params);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resultData = response.getReturnValue();
            var errors = response.getError();

            if (component.isValid() && state === "SUCCESS")
            {
                var isSuccess = resultData === 'success';
                swal.fire({
                    title: 'Submit Order',
                    text: isSuccess ? 'Order Saved' : resultData,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'OK'
                }).then((result) => {
                    // if (result.value) {}
                    $A.util.addClass(component.find('spinner'), 'slds-hide');
                    component.set('v.disabledSubmit', false);
                    if (isSuccess) {
                        component.set('v.formWarehouseId', null);
                        component.set('v.formWarehouseName', null);
                        component.set("v.formContactName", null);
                        component.set("v.formContactTelephone", null);
                        component.set("v.formExpectedDeliveryDate", null);
                        component.set("v.formRemark", null);
                        component.set('v.checkWarehouseName', null);
                        component.set('v.searchWarehouseText', null);

                        $A.get('e.force:refreshView').fire();
                    }
                });
            }
            else if (errors && errors[0] && errors[0].message) {
                swal.fire({
                    title: 'Save Order',
                    text: errors[0].message,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'OK'
                }).then((result) => {
                    // if (result.value) {}
                    $A.util.addClass(component.find('spinner'), 'slds-hide');
                    component.set('v.disabledSubmit', false);
                });
            } else {
                $A.util.addClass(component.find('spinner'), 'slds-hide');
                component.set('v.disabledSubmit', false);
            }
        });
        $A.enqueueAction(action);
    },
})