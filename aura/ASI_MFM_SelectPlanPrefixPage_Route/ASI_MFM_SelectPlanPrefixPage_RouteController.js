({
    init: function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.recordId', pageReference.state.c__vid);
    },

    reInit : function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.recordId', pageReference.state.c__vid);
		$A.get('e.force:refreshView').fire();
       
    }
})