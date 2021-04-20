({
    init: function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.visitID', pageReference.state.c__vid);
        cmp.set('v.customerId', pageReference.state.c__cid);
        cmp.set('v.isStopped', pageReference.state.c__isStopped);
        cmp.set("v.mode",pageReference.state.c__mode);
        if(cmp.get("v.mode") == 'Create'){
            cmp.set("v.eventId",'');
        }
        else{
            cmp.set("v.eventId",pageReference.state.c__eid);
        }
    
    },

    reInit : function(cmp, event, helper) {
        var pageReference = cmp.get("v.pageReference");
        cmp.set('v.visitID', pageReference.state.c__vid);
        cmp.set('v.customerId', pageReference.state.c__cid);
        cmp.set('v.isStopped', pageReference.state.c__isStopped);
        cmp.set("v.mode",pageReference.state.c__mode);
        if(cmp.get("v.mode") == 'Create'){
            cmp.set("v.eventId",'');
        }
        else{
            cmp.set("v.eventId",pageReference.state.c__eid);
        }
        $A.get('e.force:refreshView').fire();
    }
})