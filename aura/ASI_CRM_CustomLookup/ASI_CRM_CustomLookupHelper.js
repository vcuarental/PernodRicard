({
	getRecordList : function(cmp) {
		$A.util.removeClass(cmp.find("customSpinner"), 'slds-hide');
        
        cmp.set('v.message', '');
        cmp.set('v.lookupRecordList', []);
        
    	var action = cmp.get('c.getRecordList');
        
        action.setParams({
            'objectName'             : cmp.get('v.objectName'),
            'labelField'             : cmp.get('v.labelField'),
            'sublabelField'          : cmp.get('v.sublabelField'),
            'filterFieldList'        : cmp.get('v.filterFieldList'),
            'searchKey'              : cmp.get('v.searchKey'),
            'additionalFilterString' : cmp.get('v.additionalFilterString'),
            'recordCount'            : cmp.get('v.recordCount')
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
        	if(state === 'SUCCESS') {
                
        		var result = response.getReturnValue();
    			if(result.length > 0) {
                	cmp.set('v.lookupRecordList', result);
    			} else {
    				cmp.set('v.message', "No Records Found for '" + cmp.get('v.searchKey') + "'");
    			}
                
        	} else {
                
                var errors = response.getError();
                if (errors && 
                    errors[0] && 
                    errors[0].message) {
                    cmp.set('v.message', errors[0].message);
                }
                
            }
            
        	$A.util.addClass(cmp.find('customSpinner'), 'slds-hide');
        });
        
        $A.enqueueAction(action);
	}
})