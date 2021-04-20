({
    doInit: function(component, event, helper) {    
        
        var action = component.get("c.getRecordTypes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.lstRecordTypes",response.getReturnValue());
                var res = response.getReturnValue();  
                // set default record type value to attribute    
                for(var i = 0; i < res.length; i++){
                    if (res[i].isDefault) {
                        component.set("v.selectedRecord", res[i]);
                    }
                }
                if(res.length == 0){
                    //var toastEvent = $A.get("e.force:showToast");
                    //toastEvent.setParams({
                    //    "title": "Error!",
                    //    "message": "Please contact your administrator (No reocrd type available)"
                    //});
                    //toastEvent.fire();
                    //$A.get("e.force:closeQuickAction").fire();
                    var test = {};
                    test.recordTypeDevName = '';
                    test.recordTypeId = '';
                    component.set("v.selectedRecord", test);
                    
                    var a = component.get("c.RedirectToOpp");
                    $A.enqueueAction(a);
                    
                } else if(res.length > 1){
                    component.set("v.isOpen", true);
                } else {
                    var a = component.get("c.RedirectToOpp");
                    $A.enqueueAction(a);
                }
                
            } else if (state == "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please contact your administrator"
                });
                toastEvent.fire();
            }    
        });
        $A.enqueueAction(action);
    },
    
    onRadio : function(component,event,helper){
        var recId = event.getSource().get("v.text");
        component.set("v.selectedRecord" , recId);
    } ,
    
    RedirectToOpp : function(component,event,helper){
        //  alert(component.get("v.selectedRecord").recordTypeDevName);
        var recordTypeDevName = component.get("v.selectedRecord").recordTypeDevName;
        var outletId = component.get("v.recordId");
        var recordTypeId = component.get("v.selectedRecord").recordTypeId;
        
        $A.get("e.force:closeQuickAction").fire();
        if(recordTypeDevName.includes('ASI_CRM_MY')){
            var createContractEvent = $A.get("e.force:createRecord");
            createContractEvent.setParams({
                "entityApiName": "ASI_TH_CRM_Contract__c",
                "recordTypeId" : recordTypeId,
                "defaultFieldValues": {
                    "RecordTypeId" : recordTypeId,
                    'Name' : 'Auto-generated Number',
                    'ASI_CRM_CN_Outlet_WS__c' : outletId
                }
                
            });
            createContractEvent.fire();
        } else if(recordTypeDevName.includes('ASI_CRM_KH')){
            var createContractEvent = $A.get("e.force:createRecord");
            createContractEvent.setParams({
                "entityApiName": "ASI_TH_CRM_Contract__c",
                "recordTypeId" : recordTypeId,
                "defaultFieldValues": {
                    "RecordTypeId" : recordTypeId,
                    'Name' : 'Auto-generated Number',
                    'ASI_CRM_CN_Outlet_WS__c' : outletId
                }
                
            });
            createContractEvent.fire();
            
            
        }else if(recordTypeDevName == 'ASI_CRM_CN_Contract'){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/apex/ASI_CRM_CN_EditContractPage?retURL=%2F'+outletId+'&RecordType='+recordTypeId+'&outletId='+outletId+'&save_new=1'
            });
            urlEvent.fire();
        }else if(recordTypeDevName.includes('ASI_CRM_PH_Contract')){
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
        }else if(recordTypeDevName.includes('ASI_CRM_MO')){
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
        }else if(recordTypeDevName.includes('ASI_CRM_SG') || recordTypeDevName.includes('ASI_SG_CRM')){
            if(recordTypeDevName.includes('ASI_CRM_SG_Proposal') || recordTypeDevName.includes('ASI_CRM_SG_Proposal_Read_Only')) {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url" : '/apex/asi_crm_sg_editcontractpage?retURL=%2F'+outletId+'&RecordType='+recordTypeId+'&outletId='+outletId+'&save_new=1'
                });
                //   urlEvent.fire();
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef: "c:ASI_CRM_SG_EditContractPage_Comp",
                    componentAttributes: {
                        // Attributes here.
                        "recordTypeId" : recordTypeId,
                        "recordTypeLabel" : component.get("v.selectedRecord").recordTypeLabel,
                        "outletId" : outletId
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
            
        }
        
    } ,
    
    closeModal : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
    
    
})