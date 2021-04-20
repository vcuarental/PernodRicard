({
	validateRegistrationForm: function(component) {
        const requiredFields = component.find('formField') || [];
        console.log('requiredFields: '+JSON.stringify(requiredFields));
        var isValid = true;
        requiredFields.forEach(e => {
            console.log('e: '+ JSON.stringify(e));
            if (e.get('v.value')=='' || e.get('v.value').trim().length==0 ) {
            	isValid = false;
        	}
        });
        var validContact = true;
         // Show error messages if required fields are blank
        var allValid = component.find('formField').reduce(function (validFields, inputCmp) {
            
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        if (allValid) {
            
        return(validContact);
            
        }  
	},
    getAccountRegistrationRecordtypeId: function(component) {
        console.log('entramos en el helper');
        var getRtID = component.get('c.getCaseAccountRegistrationRTId');
        getRtID.setCallback(this,function(response){
            
          var state = response.getState();
          if ( state === 'SUCCESS' ) {
           var rt = response.getReturnValue();
           console.log('el rt obtenido es :' + rt);
           component.set('v.caseRecordType', rt);
          }
        });
        $A.enqueueAction(getRtID);
    },
    validateCaseForm: function(component) {
        console.log('en h.validateCaseForm');
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
})