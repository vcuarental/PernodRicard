({
    init: function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.customerID', pageReference.state.c__cid);
        cmp.set('v.visitID', pageReference.state.c__vid);
    },

    reInit : function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.customerID', pageReference.state.c__cid);
        cmp.set('v.visitID', pageReference.state.c__vid);
        $A.get('e.force:refreshView').fire();
    }
})