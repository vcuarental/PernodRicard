/**
 * Created by osman on 4.02.2021.
 */

({
    toggleUserFilterDialog: function (component, event, helper) {
        component.set("v.isBulkProfitabilityDeleteDialogOpen", !component.get("v.isBulkProfitabilityDeleteDialogOpen"));
    },

    handleButtonVisibility: function (component, event, helper) {
        if (component.get("v.isBulkProfitabilityDeleteDialogOpen")) {
            component.find("cancelButton").set("v.disabled", false);
            component.find("approveButton").set("v.disabled", false);
        }
    },

    deleteProfitabilityRecords: function (component, event, helper) {
        component.set("v.isLoading", true);
        component.find("cancelButton").set("v.disabled", true);
        component.find("approveButton").set("v.disabled", true);
        const utility = component.find("utility");
        utility.callAction(component, 'c.deleteRecords', {
            batchSize: component.get("v.batchSize")
        }).then(response => {
            helper.checkBatchProgress(component, event, helper);
        }).catch(error => {
            const errorMessage = (error && error.message) ? error.message : 'Bilinmeyen hata lütfen sistem yöneciniz ile iletişime geçiniz';
            utility.showErrorToast('Hata!', errorMessage);
            component.find("cancelButton").set("v.disabled", false);
            component.find("approveButton").set("v.disabled", false);
            component.set("v.isLoading", false);
        });
    },

});