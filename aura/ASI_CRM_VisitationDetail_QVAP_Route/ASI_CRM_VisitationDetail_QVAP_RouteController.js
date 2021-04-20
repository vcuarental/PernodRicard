({
    init: function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.visitID', pageReference.state.c__vid);
        cmp.set('v.isStopped', pageReference.state.c__is);
    },

    reInit : function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.visitID', pageReference.state.c__vid);
        cmp.set('v.isStopped', pageReference.state.c__is);
        $A.get('e.force:refreshView').fire();
    }
})