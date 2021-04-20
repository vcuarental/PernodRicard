({
	redirectToCreateCredit : function(component) {
          var data = component.get("v.recordTypeName");
        	
           		 var createEvent = $A.get("e.force:createRecord");
                if(data.includes('ASI_CRM_SG_Manual')){
                   
                 createEvent.setParams({
                        "entityApiName": "ASI_CRM_Credit_Debit_Note__c",
                     	"recordTypeId" : component.get("v.recordTypeId"),
                        "defaultFieldValues": {
                            'RecordTypeId' : component.get("v.recordTypeId"),
                            'Name' : 'Auto-generated Number',
                            'ASI_CRM_Wholesaler__c' : component.get("v.customerId")
                        }
                         
                    });
					
                }
        else if(data.includes('FWO')){
             createEvent.setParams({
                        "entityApiName": "ASI_CRM_Credit_Debit_Note__c",
                     	"recordTypeId" : component.get("v.recordTypeId"),
                        "defaultFieldValues": {
                            'RecordTypeId' : component.get("v.recordTypeId"),
                            'Name' : 'New FWO',
                            'ASI_CRM_Wholesaler__c' : component.get("v.customerId")
                        }
                         
                    });
        }
        		else{
                    createEvent.setParams({
                        "entityApiName": "ASI_CRM_Credit_Debit_Note__c",
                     	"recordTypeId" : component.get("v.recordTypeId"),
                        "defaultFieldValues": {
                            'RecordTypeId' : component.get("v.recordTypeId"),
                            'ASI_CRM_Wholesaler__c' : component.get("v.customerId")
                        }
                         
                    });
                    
                }
                createEvent.fire();
		
	}
})