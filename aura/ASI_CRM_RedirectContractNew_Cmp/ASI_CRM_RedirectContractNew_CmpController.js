({
	doInit : function(component, event, helper) {
       var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        var paramMap = (component.get("v.pageReference").state.additionalParams);
        console.log('@@@@'+paramMap+'@#'+recordTypeId);
        console.log('@state'+JSON.stringify(component.get("v.pageReference").state));
        console.log('@state1'+component.get("v.pageReference").ASI_CRM_AccountsAdditionalField__c);
        var outletId ;
        if(paramMap){
    		console.log('@@@@'+paramMap.split('=')[0]);
        	console.log('@@@@'+paramMap.split('=')[1]);
        	console.log('@@@@'+paramMap.split('=')[2]); 
            
            outletId = paramMap.split('=')[2].substring(0,15);
            console.log('@out'+outletId);
	   }
        
       var action = component.get("c.getRecordTypeName");
       action.setParams({
            "recordTypeId" : recordTypeId
        });
        action.setCallback(this, function(response){
            var RecordType1 = response.getReturnValue();
                console.log('@#'+RecordType1);
            	console.log('@#outlet'+component.get("v.recordId"));
            	var data = RecordType1.DeveloperName;
            	recordTypeId = RecordType1.Id;
                if(data.includes('ASI_CRM_MY') ){
                    console.log('@#2'+data);
                    var createAcountContactEvent = $A.get("e.force:createRecord");
                    var windowHash = window.location.hash;
                    createAcountContactEvent.setParams({
                        "entityApiName": "ASI_TH_CRM_Contract__c",
                        "recordTypeId" : recordTypeId,
                        "defaultFieldValues": {
                            "RecordTypeId" : recordTypeId,
                            'Name' : 'Auto-generated Number',
                            'ASI_CRM_CN_Outlet_WS__c' : outletId
                        }
                         
                    });
					createAcountContactEvent.fire();
                }else if(data == 'ASI_CRM_CN_Contract') 
                {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/apex/ASI_CRM_CN_EditContractPage?retURL=%2FaBt%2Fo&RecordType='+recordTypeId+'&save_new=1'
                    });
                    urlEvent.fire();
                }else if(data.includes('ASI_CRM_PH_Contract')){
                    console.log('@#2'+data);
                    var createAcountContactEvent = $A.get("e.force:createRecord");
                    createAcountContactEvent.setParams({
                        "entityApiName": "ASI_TH_CRM_Contract__c",
                        "recordTypeId" : recordTypeId,
                        "defaultFieldValues": {
                            "RecordTypeId" : recordTypeId,
                            'Name' : 'Auto-generated Number',
                            'ASI_CRM_CN_Outlet_WS__c' : outletId
                        }
                    });
					createAcountContactEvent.fire();
                }else if(data.includes('ASI_CRM_MO')){
                    var action1= component.get("c.getExchangeRet");
                    action1.setCallback(this, function(response){
                        var data = response.getReturnValue();
                        var createAcountContactEvent = $A.get("e.force:createRecord");
                    createAcountContactEvent.setParams({
                        "entityApiName": "ASI_TH_CRM_Contract__c",
                        "recordTypeId" : recordTypeId,
                        "defaultFieldValues": {
                            "RecordTypeId" : recordTypeId,
                            'Name' : 'Auto-generated Number',
                            'ASI_CRM_CN_Exchange_Rate__c' : '',
                            'ASI_CRM_CN_Outlet_WS__c' : outletId
                        }
                    });
					createAcountContactEvent.fire();
                    });$A.enqueueAction(action1);
                }else if(data.includes('ASI_CRM_SG') || data.includes('ASI_SG_CRM')){
                    if(data.includes('ASI_CRM_SG_Proposal') || data.includes('ASI_CRM_SG_Proposal_Read_Only')) {
                       
                     var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:ASI_CRM_SG_EditContractPage_Comp",
                        componentAttributes: {
                            // Attributes here.
                            "recordTypeId" : recordTypeId,
                            "recordTypeLabel" :  RecordType1.Name                            
                        }
                    });
                evt.fire();
                    }else{
                        var createAcountContactEvent = $A.get("e.force:createRecord");
                        createAcountContactEvent.setParams({
                            "entityApiName": "ASI_TH_CRM_Contract__c",
                            "recordTypeId" : recordTypeId,
                            "defaultFieldValues": {
                                "RecordTypeId" : recordTypeId,
                                'Name' : '[Auto-generated]',
                                'ASI_CRM_CN_Outlet_WS__c' : outletId
                            }
                        });
                        createAcountContactEvent.fire();
                    }

                }else{
                    console.log('here');
                    if(data){
                        console.log('here1'+data+recordTypeId);
                         var createAcountContactEvent = $A.get("e.force:createRecord");
                    createAcountContactEvent.setParams({
                        "entityApiName": "ASI_TH_CRM_Contract__c",
                        "recordTypeId" : recordTypeId,
                        "defaultFieldValues": {
                            'RecordTypeId' : recordTypeId,
                            'name' : 'test',
                            'ASI_CRM_CN_Outlet_WS__c' : outletId
                        }
                    });
					createAcountContactEvent.fire();
                    
                    }else{
                        console.log('here2');
                         var createAcountContactEvent = $A.get("e.force:createRecord");
                    createAcountContactEvent.setParams({
                        "entityApiName": "ASI_TH_CRM_Contract__c",
                        'ASI_CRM_CN_Outlet_WS__c' : outletId
                    });
					createAcountContactEvent.fire();
                    
                    }
                }
        });
        $A.enqueueAction(action);
	}
})