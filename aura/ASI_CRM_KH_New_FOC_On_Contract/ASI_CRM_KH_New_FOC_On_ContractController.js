({
	doInit : function(component, event, helper) {
		var action = component.get("c.getRecord");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var wrapperObj = response.getReturnValue();
            console.log(JSON.stringify(wrapperObj));
            if(wrapperObj.contractRec != null && wrapperObj.contractRec.ASI_TH_CRM_Contract_Status__c == 'Contract Approved'){
                 var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
   		"url": "/lightning/o/ASI_FOC_Free_Goods_Request__c/new?recordTypeId="+wrapperObj.focKHRTypeId+"&defaultFieldValues=RecordTypeId="+wrapperObj.focKHRTypeId+",ASI_CRM_Contract__c="+wrapperObj.contractRec.Id+",ASI_CRM_Outlet__c="+wrapperObj.contractRec.ASI_CRM_SG_OutletId__c
    });
    urlEvent.fire();
            }else{
                $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Warning!",
        "message": "Only approved Contract can create Free Goods Request."
    });
    toastEvent.fire();
            }
        });$A.enqueueAction(action);
	}
})