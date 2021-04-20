({
    doInit : function(cmp, event, helper) {
        var recordId = cmp.get('v.recordId');
        if(!$A.util.isEmpty(recordId)) {
            helper.loadCatalog(cmp, helper, recordId);
        }
    },

    selectTab: function(cmp, event, helper) {
        helper.selectTabActionHandler(cmp, event);
    }
})