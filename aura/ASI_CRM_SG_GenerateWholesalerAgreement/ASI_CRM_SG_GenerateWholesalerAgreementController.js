({
    init : function(cmp, event, helper) {
        var myPage = cmp.get("v.pageReference");
        cmp.set("v.recordId",myPage.state.c__id);
        console.log('record id in component: ' + cmp.get("v.recordId"));
    }
})