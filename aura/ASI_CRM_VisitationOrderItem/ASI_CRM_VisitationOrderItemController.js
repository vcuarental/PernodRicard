({
	init : function(component, event, helper) {
		var sku = component.get("v.sku");

		component.set("v.showPrice", sku.ASI_HK_CRM_Base_Price__c > 0)
	}
})