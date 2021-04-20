({
	loadCustomerProsSegmentation : function(cmp, event, helper) {
		var pageReference = cmp.get("v.pageReference");
        var recordId = pageReference.state.c__id;

        var action = cmp.get("c.getCustomerProsSegmentation");
        action.setParams({ "recordId" : recordId });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resultData = response.getReturnValue();

            if (state === "SUCCESS") {
                cmp.set("v.customer", resultData);

                if (cmp.get("v.customer.custAddress")){
                    cmp.set("v.address", cmp.get("v.customer.custAddress"));
                } else if (cmp.get("v.customer.detail.ASI_CRM_CN_GPS_info__Latitude__s")){
                    cmp.set("v.address",cmp.get("v.customer.detail.ASI_CRM_CN_GPS_info__Latitude__s") 
                     + "," + cmp.get("v.customer.detail.ASI_CRM_CN_GPS_info__Longitude__s"));
                } else {
                    cmp.set("v.address",null);
                }

                if (cmp.get("v.customer.custPhone")){
                    cmp.set("v.phone", cmp.get("v.customer.custPhone"));
                } else {
                    cmp.set("v.phone", null);
                }
            }
        });
        $A.enqueueAction(action);
	}
})