({
    init: function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.planId', pageReference.state.c__pid);
    },

    reInit : function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.planId', pageReference.state.c__pid);
		$A.get('e.force:refreshView').fire();
       
    }
})