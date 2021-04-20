({

    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    onInit: function (component, event, helper) {
        helper.handleOnInit(component);
    },

    onRecordLoaded: function (component, event, helper) {
        helper.onRecordLoadedHandler(component);
    },


    /* ========================================================= */
    /*     Event Handlers
    /* ========================================================= */
    onClickTopLevelTab: function (component, event, helper) {
        helper.handleOnClickTopLevelTab(event);
    },


    /* ========================================================= */
    /*     Method Handlers
    /* ========================================================= */
    setAccountTargetGroupMethod: function (component, event, helper) {
        const accountTargetGroup = event.getParam('arguments').accountTargetGroup;
        component.find(helper._constants.childComponents.ObjAndPromoConfirmationCmp.auraId)
            .set(helper._constants.childComponents.ObjAndPromoConfirmationCmp.params.accountTargetGroup, accountTargetGroup);
    },

    setConfirmedProductsMethod: function (component, event, helper) {
        const confirmedProducts = event.getParam('arguments').confirmedProducts;
        component.find(helper._constants.childComponents.ObjAndPromoConfirmationCmp.auraId)
            .set(helper._constants.childComponents.ObjAndPromoConfirmationCmp.params.products, confirmedProducts);
    },

    confirmationSaveMethod: function (component, event, helper) {
        const data = event.getParam('arguments').data;
        helper.saveData(data);
    },

    populateProductsWithManagersAndSalesRepsMethod: function (component, event, helper) {
        helper.getProductsWithManagersAndSalesReps(component, event);
    },

    showSpinnerMethod: function (component, event, helper) {
        helper.showSpinner();
    },

    hideSpinnerMethod: function (component, event, helper) {
        helper.hideSpinner();
    },

    showToastMethod: function(component, event, helper) {
        const { type, title, message } = event.getParam('arguments');

        const showToastEvent = $A.get('e.force:showToast');
        showToastEvent.setParams({
            type: type,
            title : title,
            message: message,
        });
        showToastEvent.fire();
    },

});