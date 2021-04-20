({
	doInit : function(component, event, helper) {
        $A.createComponent("c:GDT_spinnerPolyfill",
            {}, 
            function(cmp, status, errorMessage){
                component.set("v.loading", cmp);
            }
        );
		var actionGetAuditTrails = component.get("c.getAuditTrails");
            actionGetAuditTrails.setParam("fromDate", helper.getFromDate());
            actionGetAuditTrails.setParam("toDate", helper.getToDate());
            actionGetAuditTrails.setParam("toControl",  true);
           // actionGetAuditTrails.setParam("action","ALL");
          //  actionGetAuditTrails.setParam("username","ALL");


            actionGetAuditTrails.setCallback(this, function(a) {
                if(actionGetAuditTrails.getState() ==='SUCCESS'){
                    var result = a.getReturnValue();
                    component.set("v.allRows" ,result);
                    component.set("v.rows" , result.slice(0,100));


                    $A.createComponent("c:GDT_Table",
    		            {  
                            "headers": [{"label": "Id", "fieldNameOrPath": "Id", "hidden": "True"},{"label": "Created Date", "fieldNameOrPath": "CreatedDate__c", "hidden": "False", "colType": "datetime"},{"label": "Created By", "fieldNameOrPath": "CreatedById__r.Username", "hidden": "False"},{"label": "Section", "fieldNameOrPath": "Section__c", "hidden": "False"},{"label": "Action", "fieldNameOrPath": "Action__c", "hidden": "False"},{"label": "Display", "fieldNameOrPath": "Display__c", "hidden": "False"},{"label": "DelegateUser", "fieldNameOrPath": "DelegateUser__c", "hidden": "False"}],
                        	"allRows" :  component.getReference("v.allRows"),
    		                "rows" :  component.getReference("v.rows"),
                        }, 
    		            function(cmp, status, errorMessage){
    		                component.set("v.auditTrailTable", cmp);
    		                //component.find("loadingViews").hide();
    		            }
    		        );
                     $A.createComponent("c:GDT_TableFilter",
                        {  
                            "allRows" :  component.getReference("v.allRows"),
                            "rows" :  component.getReference("v.rows"),
                            "loading" : component.getReference("v.loading")
                        }, 
                        function(cmp, status, errorMessage){
                            component.set("v.auditTrailFilter", cmp);
                            //component.find("loadingViews").hide();
                        }
                    );
                }else{ 
                    //component.find("loadingViews").hide();
                    var errors = a.getError();
                    var errorTxt = '';
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            errorTxt = errors[0].message
                        }
                    } else {
                        errorTxt = "Unknown error";
                    }
                   helper.toastIt(component, "Error", "There was an error retrieving the record list: \n" +  errorTxt, "error");
                }
            });
            $A.enqueueAction(actionGetAuditTrails);
	}
})