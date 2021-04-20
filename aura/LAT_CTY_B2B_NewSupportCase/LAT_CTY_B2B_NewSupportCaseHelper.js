({
    validateCaseForm: function(component) {
        var validContact = true;
         // Show error messages if required fields are blank
        var allValid = component.find('caseField').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        if (allValid) {
            
        return(validContact);
            
        }  
	},
    getAccountIdFromUser : function(component) {
		var getAccountIdFromUser = component.get('c.getAccountIdFromUser');
	    getAccountIdFromUser.setCallback(this,function(response){
	      	var state = response.getState();
	      	if ( state === 'SUCCESS' ) {
                console.log('hay success : '+response.getReturnValue() );
	       	var objString = response.getReturnValue();
	       		if (objString) {
		       		
			       	component.set('v.accountId', objString);
		      	}
	      	}
	    });
        console.log('pasamos');
	    $A.enqueueAction(getAccountIdFromUser);
        console.log('pasamos2');
	}
       
})