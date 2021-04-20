({
    init: function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.customerID', pageReference.state.c__cid);
    },

    reInit : function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.customerID', pageReference.state.c__cid);
        $A.get('e.force:refreshView').fire();
    }
})