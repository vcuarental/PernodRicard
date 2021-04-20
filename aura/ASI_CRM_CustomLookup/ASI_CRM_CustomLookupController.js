({
	init : function(cmp, event, helper) {
	},

	searchRecords : function(cmp, event, helper) {
        if(cmp.get('v.searchKey') && cmp.get('v.searchKey').length > 1) {
            $A.util.addClass(cmp.find('lookupPanel'), 'slds-is-open');
            $A.util.removeClass(cmp.find('lookupPanel'), 'slds-is-close');
		    helper.getRecordList(cmp);
        } else {
            $A.util.addClass(cmp.find('lookupPanel'), 'slds-is-close');
            $A.util.removeClass(cmp.find('lookupPanel'), 'slds-is-open');
        }
	},

	selectItem : function(cmp, event, helper) {
        if(event.currentTarget.id) {
    		var recordsList = cmp.get('v.lookupRecordList');
    		var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            
            if(index == -1)
                return;
 
            var selectedRecord = recordsList[index];
            cmp.set('v.selectedRecord', selectedRecord);
            
            $A.util.addClass(cmp.find('lookupPanel'), 'slds-is-close');
            $A.util.removeClass(cmp.find('lookupPanel'), 'slds-is-open');
            
            if(cmp.get("v.isTriggerEvent")) {
                var selectRecordEvent = cmp.getEvent("selectRecordEvent");
                selectRecordEvent.setParams({
                    "selectedRecord" : selectedRecord
                });
                selectRecordEvent.fire();
            }
        }
	},
    
	removeItem : function(cmp, event, helper) {
        cmp.set('v.selectedRecord', {});
        cmp.set('v.searchKey', '');
        setTimeout(function() {
            cmp.find('inputLookup').focus();
        }, 250);
    },

})