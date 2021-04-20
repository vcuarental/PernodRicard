({
    onInit : function (cmp, event, helper) {
        helper.CalloutService = cmp.find('calloutService');
    },

    handleChangeAttribute : function (cmp, event, helper) {
        var exp =  event.getParam('expression');
        var bypassParams = cmp.get('v.bypassChange') || [];
        function bypass(params) {
            if (bypassParams.includes(exp)) {
                cmp.set('v.bypassChange', []);
                return true;
            }
            return false;
        }

        switch (exp) {
            case 'v.header' :
                if (!bypass(bypassParams)) {
                    helper.processHeaderChange(cmp, event.getParam('oldValue'), event.getParam('value'));
                }
                break;
            case 'v.criteria' :
            case 'v.criteriaLogic' :
                if (!bypass(bypassParams)) {
                    let table = cmp.find('dataTable');
                    helper.updateDataTable(cmp, table.get('v.sortedBy'), table.get('v.sortedDirection'));
                }
                break;
            default : break;
        }
    },

    showMore : function (cmp, event, helper) {
        if (cmp.get('v.isDataTableReady')) {
            helper.showMore(cmp);
        }
    },

    setGroup : function (cmp, event, helper) {
        helper.setGroup(cmp, event.getParam('arguments').groupId);
    },

    initGroupList : function (cmp, event, helper) {
        var args = event.getParam('arguments');
        helper.initGroupList(cmp, [].concat(args.criteria), args.criteriaLogic);
    },

    setRecordsByIds : function (cmp, event, helper) {
        helper.setRecordsByIds(cmp, event.getParam('arguments').ids);
    },

    search : function (cmp, event, helper) {
        helper.doSearch(cmp, event.getParam('arguments').searchPhrase, event.getParam('arguments').searchField);
    },

    onSort : function (cmp, event, helper) {
        if (cmp.get('v.sortExclusion').includes(event.getParam('fieldName'))) {
            event.preventDefault();
            return;
        }
        helper.updateDataTable(cmp, event.getParam('fieldName'), event.getParam('sortDirection'));
    },

    onRowSelection : function (cmp, event, helper) {
        cmp.get('v.header').set('v.checkedRecordsSize', (cmp.find('dataTable').getSelectedRows() || []).length);
    },

    addSelectedToPreview : function (cmp, event, helper) {
        cmp.get('v.parent').addSelectedToPreview(cmp.find('dataTable').getSelectedRows());
    },

    addAllToPreview : function (cmp, event, helper) {
        helper.addAllToPreview(cmp);
    },

    executeQuery : function (cmp, event, helper) {
        helper.executeQuery(cmp, event.getParam('arguments').whereConditions);
    },

    setGroupLocked : function (cmp, event) {
        var isLocked = event.getParam('arguments').isLocked;
        cmp.set('v.disabled', isLocked);
        cmp.get('v.header').set('v.disabled', isLocked);
    },
});