/**
 * Created by osman on 4.02.2021.
 */

({
    checkBatchProgress: function (component, event, helper) {
        const intervalId = setInterval(() => {
            const utility = component.find("utility");
            utility.callAction(component, 'c.checkDeleteStatus', {}).then(response => {
                const asyncApexResultItems = response;
                console.log("here interval");
                if (asyncApexResultItems.length === 0) {
                    clearInterval(intervalId);
                    component.set("v.isLoading", false);
                    component.set("v.isBulkProfitabilityDeleteDialogOpen", false);
                    utility.showSuccessToast("Başarı", 'Toplu silme işleminiz başarılı bir şekilde tamamlandı', 500);
                } else {
                    component.set("v.isLoading", true);
                    component.find("cancelButton").set("v.disabled", true);
                    component.find("approveButton").set("v.disabled", true);
                }
            }).catch(error => {
                this.showWarningMessage(component, error);
            });
        }, 5000);

    },

    showWarningMessage: function (component, error) {
        const utility = component.find("utility");
        let errorMessage = 'Bilinmeyen hata meydana geldi.Lütfen sistem yöneticiniz ile iletişime geçiniz';
        if (error) {
            if (error.message) {
                errorMessage = error.message;
            }
        }
        utility.showWarningToast("Uyarı", errorMessage);
        component.set("v.isLoading", false);
    },


});