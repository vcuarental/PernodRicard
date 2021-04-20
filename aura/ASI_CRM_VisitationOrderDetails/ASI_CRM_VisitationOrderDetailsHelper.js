({
	getOrderDetails : function(component, event, helper) {
		$A.util.removeClass(component.find("spinner"), 'slds-hide');

		var pageReference = component.get("v.pageReference");
		var headerId = pageReference.state.c__id;
		var recordNum = pageReference.state.c__recordNum;
		var totalQuantity = 0;
		var totalPrice = 0.0;

		var action = component.get("c.getOrderDetails");
		action.setParams({
			headerId,
		});
		
		action.setCallback(this, function(response) {
				var state = response.getState();
				var resultData = response.getReturnValue();
				var errors = response.getError();

				if (state === "SUCCESS") {
					var iotHeader = resultData.iotHeaders.length > 0 ? resultData.iotHeaders[0] : {}
					var displayDataList = resultData.iotDetails.map((iotDetail) => {
						var sku = {
							ASI_MFM_SKU_Code__c: iotDetail.ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c,
							Name: iotDetail.ASI_CRM_SKU__r.Name,
							ASI_HK_CRM_Base_Price__c: iotDetail.ASI_CRM_SKU__r.ASI_HK_CRM_Base_Price__c
						};
						var quantity = iotDetail.ASI_CRM_Quantity__c;

						totalQuantity += quantity;
						totalPrice += iotDetail.ASI_CRM_SKU__r.ASI_HK_CRM_Base_Price__c;

						return {
							sku,
							quantity
						};
					});

					console.log("iotHeader", iotHeader);

					component.set("v.displayDataList", displayDataList);
					component.set("v.totalQuantity", totalQuantity);
					component.set("v.totalPrice", totalPrice);
					component.set("v.recordNum", recordNum);
					component.set("v.iotHeader", iotHeader);
					component.set("v.wholesalers", [{
						Id: iotHeader.ASI_CRM_Wholesaler__c,
						Name: iotHeader.ASI_CRM_Wholesaler__r.Name,
						selected: true
					}]);
					$A.util.addClass(component.find('spinner'), 'slds-hide');
				} else if (errors && errors[0] && errors[0].message) {
					swal.fire({
							title: 'View Order Details',
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