({
	doInit : function(component, event, helper) {
       var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        var paramMap = (component.get("v.pageReference").state.additionalParams);
        var paramMap1 = (component.get("v.pageReference").state.defaultFieldValues);
        var outletId ;
        console.log('@@@@'+paramMap);
        console.log('@@@@1'+paramMap1);
        if(paramMap){
            console.log('@@@@'+paramMap);
    		console.log('@@@@'+paramMap.split('=')[0]);
        	console.log('@@@@'+paramMap.split('=')[1]);
        	console.log('@@@@'+paramMap.split('=')[2]); 
            outletId = paramMap.split('=')[2].substring(0,15);
	   }
        var defltValues = '{';
        if(paramMap1){
            var defltMap = new Map();
            var s =  paramMap1.split(',');
            console.log('@#s.length'+s.length);
            for (var i=0; i< s.length; i++){
                defltMap[s[i].split('=')[0]]= s[i].split('=')[1];
                console.log('@#defltMap'+JSON.stringify(defltMap));
                console.log(s[i].split('=')[0]);
                console.log(s[i].split('=')[1]);
            }
          //  defltValues = JSON.stringify(defltMap).replace(new RegExp('\"', 'g'), '\''); ;
        //  defltValues = JSON.stringify(defltMap);
        defltValues = defltMap;
            
            console.log('@#defltValues'+defltValues);
        }
        
       var action = component.get("c.getRecordTypeName");
       action.setParams({
            "recordTypeId" : recordTypeId
        });
        action.setCallback(this, function(response){
            var data = response.getReturnValue();
                console.log('@#'+data);
            	console.log('@#outlet'+component.get("v.recordId"));
            if(data == 'ASI_TH_CRM_Payment_Request'){
                 var createPREvent = $A.get("e.force:createRecord");
                    createPREvent.setParams({
                        "entityApiName": "ASI_TH_CRM_PaymentRequest__c",
                        "recordTypeId" : recordTypeId,
                        "defaultFieldValues": {
                            'RecordTypeId' : recordTypeId
                        }
                         
                    });
               $A.get("e.force:closeQuickAction").fire();
					createPREvent.fire();
            }
            else if(data == 'ASI_CRM_CN_Payment_Request'){
                var retURL = component.get("v.pageReference").state.returl;
                var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/apex/ASI_CRM_CN_EditPayment_Header_Page?RecordType='+recordTypeId+'&retURL='+retURL
                        
                    });
                    urlEvent.fire();
            }else if(data == 'ASI_SG_CRM_Payment_Request' || data == 'ASI_CRM_SG_Payment_Request'){
                var createPREvent = $A.get("e.force:createRecord");
                if(paramMap1){
                    console.log('here'+defltValues);
                    createPREvent.setParams({
                        "entityApiName": "ASI_TH_CRM_PaymentRequest__c",
                        "recordTypeId" : recordTypeId,
                        "defaultFieldValues": defltValues
                         
                    });
                   
                  }else{
                    createPREvent.setParams({
                        "entityApiName": "ASI_TH_CRM_PaymentRequest__c",
                        "recordTypeId" : recordTypeId,
                        "defaultFieldValues": {
                            'RecordTypeId' : recordTypeId,
                            'Name' : '[Auto-generated]'
                        }
                         
                    });
                }    
                
					createPREvent.fire();
            }else if(data == 'ASI_CRM_PH_Payment_Request'){
                 var createPREvent = $A.get("e.force:createRecord");
                    createPREvent.setParams({
                        "entityApiName": "ASI_TH_CRM_PaymentRequest__c",
                        "recordTypeId" : recordTypeId,
                        "defaultFieldValues": {
                            'RecordTypeId' : recordTypeId,
                            'Name' : '[Auto-generated]'
                        }
                         
                    });
					createPREvent.fire();
            }else if(data == 'ASI_CRM_MY_Payment_Request'){
                 var createPREvent = $A.get("e.force:createRecord");
                    createPREvent.setParams({
                        "entityApiName": "ASI_TH_CRM_PaymentRequest__c",
                        "recordTypeId" : recordTypeId,
                        "defaultFieldValues": {
                            'RecordTypeId' : recordTypeId,
                            'Name' : 'Auto-generated Number'
                        }
                         
                    });
					createPREvent.fire();
            }else{
                	console.log('here1');
                    var createPREvent = $A.get("e.force:createRecord");
                    createPREvent.setParams({
                        "entityApiName": "ASI_TH_CRM_PaymentRequest__c",
                        "recordTypeId" : recordTypeId,
                        "defaultFieldValues": {
                            'RecordTypeId' : recordTypeId
                        }
                         
                    });
					createPREvent.fire();
            }
            
        });
        $A.enqueueAction(action);
	}
})