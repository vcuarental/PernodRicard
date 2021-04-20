({
    init: function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.orderID', pageReference.state.c__oid);
    },

    reInit : function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.orderID', pageReference.state.c__oid);
        $A.get('e.force:refreshView').fire();
    }
})