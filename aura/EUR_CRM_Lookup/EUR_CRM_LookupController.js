/**
 * @author: PZ CustomerTimes Corp.
 * @created: 10.01.18
 */
({
	doInit : function(component, event, helper) {
		var rId = component.get("v.value");
		var sObjAPINm = component.get("v.objectAPIName");		
		if(rId){
			var action = component.get("c.getInitial");
            action.setParams({
            	"objectAPIName": sObjAPINm
                ,"rId": rId                
            });
            
            action.setCallback(this, function(a){
                var state = a.getState();               
                if(component.isValid() && state === "SUCCESS") {                    
                    var result = a.getReturnValue();
                    if(result && result.length>0){
                    	//component.set("v.value", result[0].Id);                    	
                    	//component.set("v.chosenRecordLabel", result[0].Name);
                    	var oldVal = component.get("v.value");
                    	var newVal = result[0].Id;
                    	var lbl = component.get("v.chosenRecordLabel");
                    	if(oldVal && oldVal != newVal || !lbl){
	                    	var chooseEvent = component.getEvent("lookupSelect");
					        chooseEvent.setParams({
					            "recordId" : result[0].Id,
					            "recordLabel": result[0].Name
					        });
					        chooseEvent.fire();
				        }
                    }
                    
                }else if(state === "ERROR") {
                    console.log('Error on lookup initialization');
                }
            });            
            $A.enqueueAction(action);
		}
	},
    //Function to handle the LookupChooseEvent. Sets the chosen record Id and Name
    handleLookupChooseEvent : function (component,event,helper) {
    	
    	var oldVal = component.get("v.value");
    	var newVal = event.getParam("recordId");
		component.set("v.value", newVal);
        component.set("v.chosenRecordLabel",event.getParam("recordLabel"));
        helper.toggleLookupList(component,
            false,
            'slds-combobox-lookup',
            'slds-is-open');
        // force validation recalculation
        helper.doValidateLInput(component,"searchinput");
    },

    //Function for finding the records as for given search input
    searchRecords : function (component,event,helper) {    
        var searchText = component.find("searchinput").get("v.value");
        if(searchText){
            helper.searchSOSLHelper(component,searchText);
        } else {        	
            helper.searchSOQLHelper(component);            
        }
    },

    //function to hide the list on onblur event.
    hideList : function (component,event,helper) {
        var searchText = component.find("searchinput").get("v.value");
        if($A.util.isEmpty(searchText)){
        	// clear selection
	        var chooseEvent = component.getEvent("lookupSelect");
	        chooseEvent.setParams({
	            "recordId" : null,
	            "recordLabel": null
	        });
	        chooseEvent.fire();				        
        }
        helper.toggleLookupList(component,
            false,
            'slds-combobox-lookup',
            'slds-is-open'
        );
    },
    
    doValidate : function (component,event,helper) {
    	helper.doValidateLInput(component,"searchinput");
    },
    
    doShowInvalid : function (component,event,helper) {
    	helper.doShowInvalid(component,"searchinput");
    }
    
})