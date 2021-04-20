/**
 * Created by osman on 8.01.2021.
 */

({
    doInit: function (component, event, helper) {

        component.set("v.isLoading", true);
        const utility = component.find("utility");
        const recordId = component.get("v.recordId");
        const actionName = component.get("v.actionName");

        utility.callAction(component, 'c.handleAction', {
            approvalId: recordId,
            actionName: actionName
        }).then(data => {
            component.set("v.isLoading", false);
            component.set("v.statusMessage", `İşleminiz başarılı bir şekilde tamamlandı`);
            component.set("v.statusTheme", component.get("v.successTheme"));
            $A.get('e.force:refreshView').fire();
        }).catch(error => {
            let errorMessage = 'Bilinmeyen hata meydana geldi.Lütfen sistem yöneticisi ile iletişime geçiniz';
            if (error.message) {
                errorMessage = `Hata meydana geldi.Hata detayı : '${error.message}'`;
            }
            component.set("v.isLoading", false);
            component.set("v.statusMessage", errorMessage);
            component.set("v.statusTheme", component.get("v.errorTheme"));
        });

    }
});