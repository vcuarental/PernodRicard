/**
 * Created by V. Kamenskyi on 27.09.2017.
 */
({
    handleVisibleChange : function(cmp, event, helper) {
        if (cmp.get('v.visible')) {
            helper.setDefaults(cmp, helper);
        }
    },
    
    formAvailables : function (cmp, event, helper) {
        helper.selectUserOrGroup(cmp, helper, cmp.get('v.searchSubject'));
    },
    handleUserOrGroupSelect : function (cmp, event, helper) {
        helper.selectUserOrGroup(cmp, helper, event.getSource().get('v.value'));
    },

    handleSearch : function (cmp, event, helper) {
        helper.search(cmp, helper, event.getSource().get('v.value'));
    },

    filterAvailable : function (cmp, event, helper) {
        cmp.find('duelingPicklist').set('v.itemsL', cmp.get('v.' + cmp.find('searchSubject').get('v.value')));
        cmp.find('input-search').set('v.value', '');
    },
    
    filerApexDelayed: function(cmp, event, helper) {
    	var timer = cmp.get('v.timer');	
        clearTimeout(timer);
        var timer = window.setTimeout($A.getCallback(function() {
	            helper.filerApexDelayed(cmp, event);
	            clearTimeout(timer);
	            cmp.set('v.timer', null);
	            
		    }), 700
		);
        
        cmp.set('v.timer', timer);
    }
})