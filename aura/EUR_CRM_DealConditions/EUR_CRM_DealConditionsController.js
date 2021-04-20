/**
 * Created by V. Kamenskyi on 11.07.2018.
 */
({
    onInit : function(cmp, event, helper) {
        helper.doInit(cmp);
    },

    addProduct : function (cmp, event, helper) {
        cmp.set('v.isReady', false);
        helper.addProductToDeal(cmp);
    },

    removeProduct : function (cmp, event, helper) {
        helper.removeProductFromDeal(cmp, event.getSource().get('v.name'));
        setTimeout($A.getCallback(() => {
            helper.validateInputFields(cmp, true);
        }));
    },

    reloadRelatedProducts : function (cmp, event, helper) {
        helper.reloadProducts(cmp);
    },

    onInputFieldChange : function(cmp, event, helper) {
        if (helper.validateInputField(cmp, event.getSource())) {
            helper.validateInputFields(cmp, true);
        }
    },

    validate : function (cmp, event, helper) {
        return helper.validateInputFields(cmp, true);
    }
})