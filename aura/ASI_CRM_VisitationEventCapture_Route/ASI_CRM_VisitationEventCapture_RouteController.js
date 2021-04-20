({
    init: function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.visitID', pageReference.state.c__vid);
        cmp.set('v.customerId', pageReference.state.c__cid);
        cmp.set('v.isStopped', pageReference.state.c__isStopped);
    },

    reInit : function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.visitID', pageReference.state.c__vid);
        cmp.set('v.customerId', pageReference.state.c__cid);
        cmp.set('v.isStopped', pageReference.state.c__isStopped);
        $A.get('e.force:refreshView').fire();
    }
})