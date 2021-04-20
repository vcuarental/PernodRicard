({
      /*
     * Display value component
     * Displays a value from a column name
     * Used for display the values in the table component
     * Formats the value depending on the value type(Link, number, Datetime)
     */
    doInit : function(component, helper) {
        var sObject = component.get('v.sobj');
        var fieldName = component.get('v.fieldName');
        var colType = component.get('v.colType');
        var outputText = component.find("outputTextId");

        if (fieldName.indexOf(".") >= 0) {
            var ParentSobject = sObject[fieldName.split(".")[0]];
            if(ParentSobject != undefined){
                outputText.set("v.value",ParentSobject[fieldName.split(".")[1]]);
            }
        }
        else{
        	if(colType == 'datetime'){
        		//component.find("outputTime").set("v.value",sObject[fieldName]);
        	}else if (fieldName == 'Name' || fieldName == 'CaseNumber'){
        		component.find("outputLink").set("v.value", "/" + sObject["Id"]);
        		component.find("outputLink").set("v.label",sObject[fieldName]);
        	}else{
            	outputText.set("v.value", sObject[fieldName]);
        	}

        }
    }
})