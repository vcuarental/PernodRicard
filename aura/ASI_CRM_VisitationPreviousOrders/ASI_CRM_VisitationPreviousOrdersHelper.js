({
	getPreviousOrders : function(component, event, helper) {
		$A.util.removeClass(component.find("spinner"), 'slds-hide');

		var pageReference = component.get("v.pageReference");
		var customerId = pageReference.state.c__id;

		var limitPerPage = component.get("v.limitPerPage");
		var currentPage = component.get("v.currentPage");
		var offset = (currentPage - 1) * limitPerPage;

		var action = component.get("c.getPreviousOrders");
		action.setParams({
				customerId,
				limitPerPage,
				offset
		});
		
		action.setCallback(this, function(response) {
				var state = response.getState();
				var resultData = response.getReturnValue();
				var errors = response.getError();

				if (state === "SUCCESS") {
					var totalPages = Math.ceil(resultData.total / limitPerPage);
					var displayDataList = resultData.iotHeaders.map((iotHeader, index) => {
						var iotDetails = resultData.iotDetails.filter(d => d.ASI_CRM_IOTHeader__c === iotHeader.Id);
						var numOfItems = iotDetails.reduce((total, value) => total + value.ASI_CRM_Quantity__c, 0);
						var totalPrice = iotDetails.reduce((total, value) => total + value.ASI_CRM_SKU__r.ASI_HK_CRM_Base_Price__c || 0, 0);

						return {
							id: iotHeader.Id,
							recordNum: offset + index + 1,
							numOfItems,
							totalPrice,
							showPrice: totalPrice > 0,
							createdDate: iotHeader.CreatedDate
						}
					});

					if (totalPages === 0) {
						totalPages = 1;
					}

					component.set("v.displayDataList", displayDataList);
					component.set("v.rowCount", displayDataList.length);
					component.set("v.totalPages", totalPages);
					component.set("v.disabledPrevious", currentPage <= 1 || currentPage > totalPages);
					component.set("v.disabledNext", currentPage >= totalPages || currentPage < 1);

					$A.util.addClass(component.find('spinner'), 'slds-hide');
				} else if (errors && errors[0] && errors[0].message) {
					swal.fire({
							title: 'View Previous Orders',
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
	}
})