({
    init: function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.visitID', pageReference.state.c__vid);

        if (pageReference.state.c__dt)
        {
            cmp.set('v.defaultTab', pageReference.state.c__dt);
        }
    },

    reInit : function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.visitID', pageReference.state.c__vid);

        if (pageReference.state.c__dt)
        {
            cmp.set('v.defaultTab', pageReference.state.c__dt);
        }

        $A.get('e.force:refreshView').fire();
    }
})