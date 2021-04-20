/**
 * Created by V. Kamenskyi on 19.07.2018.
 */
({
    doInit: function (cmp, event, helper) {
        window.ActualCmp = cmp;
        helper.handleInitActions(cmp, helper);
    },

    handleControlButtonClick: function (cmp, event, helper) {
        const
            validity = cmp.get('v.validity'),
            who = event.getSource().get('v.name');
        if (!cmp.get('v.isPerformingSaveAction')) {
            cmp.set('v.isPerformingSaveAction', (who == 'save') || cmp.get('v.isPerformingSaveAction'));
            helper.handleControlAction(cmp, helper, who, validity);
        }
    },

    onConditionsTabActive: function (cmp, event, helper) {
        helper.setConditionsTabVisited(cmp, event.getSource().get('v.id'));
    },

    onInputFieldChange: function (cmp, event, helper) {
        if (helper.validateInputField(cmp, event.getSource())) {
            helper.validateInputFields(cmp, true);
        }
    },

    validate: function (cmp, event, helper) {
        helper.validateInputFields(cmp, true);
    },

    onOrderTypeSelect: function (cmp, event, helper) {
        var val = event.getSource().get('v.value');
        cmp.set('v.record.EUR_CRM_OrderType__c', val);
        cmp.set('v.isOrderTypeEmpty', !val);
    },

    onRecordEditFormLoad: function (cmp, event) {
        console.log('...edit form loaded...');
    }
})