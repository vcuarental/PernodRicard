({
    init: function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.visitID', pageReference.state.c__vid);
        cmp.set('v.noteID', pageReference.state.c__nid);
    },

    reInit : function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.visitID', pageReference.state.c__vid);
        cmp.set('v.noteID', pageReference.state.c__nid);
        $A.get('e.force:refreshView').fire();
    }
})