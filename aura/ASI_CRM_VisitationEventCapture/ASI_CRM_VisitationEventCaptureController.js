({
    init : function(cmp, event, helper) {
        console.log('EventCapture');
        var myPage = cmp.get("v.pageReference");
        cmp.set("v.recordId",myPage.state.c__vid);
        cmp.set("v.customerId",myPage.state.c__cid);
        cmp.set("v.isStopped",myPage.state.c__isStopped);
        helper.getEventList(cmp);
    },

    toCreate : function(cmp, event, helper) {
        var nav = cmp.find("navService");
        var vid = cmp.get("v.recordId");
        var cid = cmp.get("v.customerId");
        var isStopped = cmp.get("v.isStopped");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ASI_CRM_VisitationEventCaptureEdit'
            }, 
            state: {
                c__vid: vid,
                c__cid: cid,
                c__isStopped: isStopped,
                c__mode: 'Create' 
            }
        };
        
        nav.navigate(pageReference);
    },
    toEdit : function(cmp, event, helper) {
        var nav = cmp.find("navService");
        var vid = cmp.get("v.recordId");
        var cid = cmp.get("v.customerId");
        var eid = event.currentTarget.id;
        var isStopped = cmp.get("v.isStopped");
        console.log(eid);
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ASI_CRM_VisitationEventCaptureEdit'
            }, 
            state: {
                c__vid: vid,
                c__cid: cid,
                c__eid: eid,
                c__isStopped: isStopped,
                c__mode: 'Edit' 
            }
        };
        
        nav.navigate(pageReference);
    }
})