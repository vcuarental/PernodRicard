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
        var recordTypeDevName = component.get("v.selectedRecord").recordTypeDevName;
        var outletId = component.get("v.recordId");
        var recordTypeId = component.get("v.selectedRecord").recordTypeId;
        
        $A.get("e.force:closeQuickAction").fire();
        if(recordTypeDevName.includes('ASI_CRM_KH')){
            var createSalesOrderEvent = $A.get("e.force:createRecord");
            createSalesOrderEvent.setParams({
                "entityApiName": "ASI_KOR_Sales_Order_Request__c",
                "recordTypeId" : recordTypeId,
                "defaultFieldValues": {
                    "RecordTypeId" : recordTypeId,
                    'Name' : 'Auto-generated Number',
                    'ASI_CRM_SG_Customer__c' : outletId,
                    'ASI_KOR_Order_Status__c' : 'Draft'
                    
                }
                
            });
            createSalesOrderEvent.fire();
        }         
    } ,
    
    closeModal : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
    
    
})