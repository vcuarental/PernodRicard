({

    /* ========================================================= */
    /*     Initialization
    /* ========================================================= */
    onInit: function (component, event, helper) {
        helper.handleOnInit(component);
    },

    onLocationChange: function (component, event, helper) {
        helper.state.areProductsInitialized = false;
        helper.state.isConfirmed = false;
    },


    /* ========================================================= */
    /*     User's 'Manual' Event Handlers
    /* ========================================================= */
    onClickTopLevelTab: function (component, event, helper) {
        helper.handleOnClickTopLevelTab(component, event);
    },

    onChangeFieldOnGeneralLevel: function (component, event, helper) {
        helper.handleOnChangeFieldOnGeneralLevel(component, event);
    },

    onChangeFieldOnManagerLevel: function (component, event, helper) {
        helper.handleOnChangeFieldOnManagerLevel(component, event);
    },

    onChangeFieldOnSalesRepLevel: function (component, event, helper) {
        helper.handleOnChangeFieldOnSalesRepLevel(component, event);
    },

    onDeletePromoTarget: function (component, event, helper) {
        helper.handleOnDeletePromoTarget(component, event);
    },

    onDeleteTargetManager: function (component, event, helper) {
        helper.handleOnDeleteTargetManager(component, event);
    },

    onDeleteTargetRep: function (component, event, helper) {
        helper.handleOnDeleteTargetRep(component, event);
    },

    onClickUpdateFormulas: function (component, event, helper) {
        helper.handleOnClickUpdateFormulas(component);
    },

    onClickConfirm: function (component, event, helper) {
        helper.handleOnClickConfirm(component);
    },

    confirmationWithoutTargetMethod: function(component, event, helper) {
        const products = event.getParam('arguments').products;
        helper.setConfirmedProducts(helper.extractProductsForConfirmationPage(JSON.parse(JSON.stringify(products))));
    },


    /* ========================================================= */
    /*     System's 'Automatic' Event Handlers
    /* ========================================================= */
    onChangeProducts: function (component, event, helper) {
        helper.handleOnChangeProducts(component);
    },

    onChangeShowComponentBody: function (component, event, helper) {
        helper.onChangeShowComponentBodyHandler(component, event);
    },

});