({
    doInit : function(component, event, helper) {
        console.log('@@'+component.get("v.recordTypeName"));
        if(component.get("v.recordTypeName") != null && component.get("v.recordTypeName") != ''){
             helper.redirectToCreateCredit(component);
        }else{
            var recordTypeId = component.get("v.pageReference").state.recordTypeId;
            console.log('@recordTypeId'+recordTypeId);
            component.set("v.recordTypeId",recordTypeId);
            var action = component.get("c.getRecordTypeName");
            action.setParams({
                "recordTypeId" : recordTypeId
            });
            action.setCallback(this, function(response){
                console.log('@recordTypeId'+JSON.stringify(response.getReturnValue())
                           );
                if(response.getReturnValue()){
                    component.set("v.recordTypeName", response.getReturnValue().DeveloperName);
               		 helper.redirectToCreateCredit(component);     
                }
               
    		
            }); $A.enqueueAction(action);
        }
    },

 })