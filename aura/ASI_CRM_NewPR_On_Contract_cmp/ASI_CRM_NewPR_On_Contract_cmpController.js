({
	doInit : function(component, event, helper) {
        var recordTypeId ;
        var action1 = component.get("c.getRecordType");
        action1.setCallback(this, function(response){
            recordTypeId = response.getReturnValue();
            console.log('@#'+recordTypeId)
            var action = component.get("c.getContract");
            action.setParams({
            "recordId" : component.get("v.recordId")
        	});
            action.setCallback(this, function(response){
                var contract = response.getReturnValue();
                var createPREvent = $A.get("e.force:createRecord");
                 createPREvent.setParams({
                        "entityApiName": "ASI_TH_CRM_PaymentRequest__c",
                     	"recordTypeId" : recordTypeId,
                        "defaultFieldValues": {
                            'RecordTypeId' : recordTypeId,
                            'ASI_TH_CRM_Contract__c' :  component.get("v.recordId"),
                            'ASI_CRM_CN_OutletWS__c' : contract.ASI_CRM_CN_Outlet_WS__c,
                            'Name' : 'Auto-generated Number'
                        }
                         
                    });
					createPREvent.fire();
            });$A.enqueueAction(action);
        });
        $A.enqueueAction(action1);
		
     
	}
})