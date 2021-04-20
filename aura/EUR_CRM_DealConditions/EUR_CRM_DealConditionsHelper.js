/**
 * Created by V. Kamenskyi on 11.07.2018.
 */
({
    doInit : function(cmp) {
        this._persistRelatedProducts(cmp);
    },

    addProductToDeal : function (cmp) {
        var items = cmp.get('v.conditionItems') || [];
        var newItem = this.getItemTemplate(cmp.get('v.discountType'));
        cmp.set('v.conditionItems', [newItem].concat(items));
    },

    removeProductFromDeal : function(cmp, pos) {
        var arr = cmp.get('v.conditionItems');
        arr.splice(pos, 1);
        cmp.set('v.conditionItems', arr);
    },

    reloadProducts : function(cmp) {
        var relatedProducts = cmp.get('v.initConditionItems');
        if (!$A.util.isEmpty(relatedProducts)) {
            cmp.set('v.conditionItems', relatedProducts);
        }
    },

    getItemTemplate : function(discountType) {
        return {
            'sobjectType' : discountType === 'Discount'
                ? 'EUR_CRM_Product_in_Deal__c'
                : 'EUR_CRM_ProductCatalogItemGrouping__c'
        }
    },

    validateInputField : function(cmp, src, suppressWarning) {
        var result = true;
        var value = src.get('v.value');
        if (src) {
            if (!value || value < 0) {
                if (!suppressWarning) {
                    cmp.get('v.parent').find('notificationsLib').showToast({
                        'title' : $A.get('$Label.c.EUR_CRM_Warning') + '!',
                        'message' : $A.get('$Label.c.EUR_CRM_failOnValidityCheck'),
                        'variant' : 'warning'
                    });
                }
                src.set('v.class', 'slds-has-error');
                result = false;
                cmp.set('v.isReady', result);
            } else {
                src.set('v.class', '');
            }
        }
        return result;
    },

    validateInputFields : function(cmp, suppressWarning) {
        var isValid = true;
        if (cmp.get('v.visited')) {
            var inputs = []
                .concat(cmp.find('sku') || [])
                .concat(cmp.find('quantity') || [])
                .concat(cmp.find('discount') || [])
                .concat(cmp.find('posm') || []);
            for (let i = 0; i < inputs.length; i++) {
                isValid = this.validateInputField(cmp, inputs[i], suppressWarning);
                if (!isValid) break;
            }
        }
        cmp.set('v.isReady', isValid);
        if (isValid) {
            cmp.get('v.parent').validate();
        }
        return isValid;
    },

    _persistRelatedProducts : function(cmp) {
        var initConditionItems = cmp.get('v.conditionItems');
        if (!$A.util.isEmpty(initConditionItems)) {
            cmp.set('v.initConditionItems', initConditionItems);
        }
    },
})