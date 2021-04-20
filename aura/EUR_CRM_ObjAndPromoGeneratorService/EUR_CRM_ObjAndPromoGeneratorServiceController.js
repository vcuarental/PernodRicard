({
    doInit : function (cmp, event, helper) {
        helper.setCallbacks(cmp, helper);
    },

    getPriceBookEntryGrouping : function (cmp, event, helper) {
        var args = event.getParam('arguments');
        var pbegList  = args.pbEntryGrouping || [];
        var pbeg = pbegList.find(item => item.PriceBookEntryID__r.ProductID__c === args.productId);
        if (!$A.util.isEmpty(pbeg)) {
            pbeg['sobjectType'] = 'PriceBookEntryGrouping__c';
            if (!$A.util.isEmpty(pbeg['Price_Book_Entry_Grouping_Items__r'])) {
                pbeg['Price_Book_Entry_Grouping_Items__r'].map(function (item) {
                    return item['sobjectType'] = 'PriceBookEntryGroupingItem__c';
                });
            }
        }
        return pbeg;
    },

    showToast : function (cmp, event, helper) {
        var args = event.getParam('arguments');
        if (!$A.util.isEmpty(args.params)) {
            let toast = $A.get('e.force:showToast');
            toast.setParams(args.params);
            toast.fire();
        }
    },

    showModalDialog : function (cmp, event, helper) {
        var args = event.getParam('arguments');
        if (!$A.util.isEmpty(args.params) && args.params.attrName) {
            helper.showModalDialog(cmp, helper, args.params.attrName, args.params.modalParams, args.params.onsave, args.params.oncancel);
        }
    }
});