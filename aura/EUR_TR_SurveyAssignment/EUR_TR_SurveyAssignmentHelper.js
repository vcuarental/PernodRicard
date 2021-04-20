/**
 * Created by bsavcı on 8/27/2020.
 */

({
    setAccountDataPagerColumns: function (component) {
        component.set("v.accountDataPagerColumns", [
            {
                label: 'Account Name',
                fieldName: '__RecordLink',
                type: 'url',
                typeAttributes: {label: {fieldName: 'Name'}, target: '_self'}
            },
            {
                label: 'EUR_TR_Channel',
                fieldName: 'EUR_TR_Channel__c',
                type: 'PICKLIST',
                typeAttributes: {label: {fieldName: 'EUR_TR_Channel__c'}, target: '_blank'}
            },
            {
                label: 'EUR_TR_Group',
                fieldName: 'EUR_TR_Group__c',
                type: 'PICKLIST',
                typeAttributes: {label: {fieldName: 'EUR_TR_Group__c'}, target: '_blank'}
            }
        ]);
    },
    setSurveyDataPagerColumns: function (component) {
        component.set("v.surveyDataPagerColumns", [
            {
                label: 'Related Account Name',
                fieldName: '__RecordLink',
                type: 'url',
                typeAttributes: {label: {fieldName: 'EUR_TR_RelatedAccount__r.Name'}, target: '_self'},
                lookup: true
            },
            {
                label: 'Related Template Description',
                fieldName: 'EUR_TR_TargetRelatedTemplate__r.EUR_TR_Description__c',
                type: 'text',
                typeAttributes: {
                    label: {fieldName: 'EUR_TR_TargetRelatedTemplate__r.EUR_TR_Description__c'},
                    target: '_blank'
                },
                lookup: true
            },
            {
                label: 'EUR_TR_Mandatory',
                fieldName: 'EUR_TR_Mandatory__c',
                type: 'boolean',
                typeAttributes: {label: {fieldName: 'EUR_TR_Mandatory__c'}, target: '_blank'}
            }
        ]);
    },
    handleSuccessBulkResponse: function (component, response, helper) {
        const utility = component.find('utility');
        if ($A.util.isEmpty(component.get('v.batchProcess'))) component.set('v.batchProcess', {});
        component.set('v.batchProcess.Id', response.BatchProcessId);
        helper.handleSuccessfulResponse(component, utility, response);
        $A.enqueueAction(component.get("c.updateBatchProcessStatus"));
    },

    validateAssignSurveyRequest: function (component) {
        const utility = component.find('utility');
        if ($A.util.isEmpty(component.get('v.assignSurveyRequest.SelectedSurveyId'))) {
            utility.showErrorToast("Hata", "Lütfen bir anket seçiniz seçiniz.");
            return false;
        }
        if ($A.util.isEmpty(component.find('accountDataPager').get('v.selectedRows'))) {
            utility.showErrorToast("Hata", "Lütfen tablodan en az bir satır seçiniz.");
            return false;
        }
        return true;
    },
    validateRemoveSurveyRequest: function (component) {
        const utility = component.find('utility');
        if ($A.util.isEmpty(component.get('v.assignSurveyRequest.SelectedSurveyId'))) {
            utility.showErrorToast("Hata", "Lütfen bir anket seçiniz seçiniz.");
            return false;
        }
        if ($A.util.isEmpty(component.find('surveyDataPager').get('v.selectedRows'))) {
            utility.showErrorToast("Hata", "Lütfen tablodan en az bir satır seçiniz.");
            return false;
        }
        return true;
    },
    validateBulkAssignSurveyRequest: function (component) {
        const utility = component.find('utility');
        if ($A.util.isEmpty(component.get('v.assignSurveyRequest.SelectedSurveyId'))) {
            utility.showErrorToast("Hata", "Lütfen bir anket seçiniz seçiniz.");
            return false;
        }
        if ($A.util.isEmpty(component.get('v.assignSurveyRequest.Query'))) {
            utility.showErrorToast("Hata", "İşlemi gerçekleştirmek için lütfen filtre seçiniz.");
            return false;
        }
        return true;
    },
    validateBulkRemoveSurveyRequest: function (component) {
        const utility = component.find('utility');
        if ($A.util.isEmpty(component.get('v.assignSurveyRequest.SelectedSurveyId'))) {
            utility.showErrorToast("Hata", "Lütfen bir anket seçiniz seçiniz.");
            return false;
        }
        if ($A.util.isEmpty(component.get('v.removeSurveyAssignmentRequest.Query'))) {
            utility.showErrorToast("Hata", "İşlemi gerçekleştirmek için lütfen filtre seçiniz.");
            return false;
        }
        return true;
    },

    handleSuccessfulResponse: function (component, utility, response) {
        component.set('v.disableButtons', false);
        utility.showSuccessToast("Başarı", response.Message, 500);
    },
    handleUnSuccessfulResponse: function (component, utility, response) {
        component.set('v.disableButtons', false);
        utility.showErrorToast("Hata!", response.Message);
        if (response.MessageCode === 'E3' || response.MessageCode === 'E6') {
            $A.enqueueAction(component.get("c.loadData"));
        }
    },
    handleErrorResponse: function (component, utility, error) {
        component.set('v.disableButtons', false);
        if (error.message) {
            utility.showErrorToast("Hata!", error.message, 2000);
        } else {
            utility.showErrorToast("Hata!", error, 2000);
        }
    },

    showPermissionWarningMessage: function (component) {
        const notificationLibrary = component.find("notifLib");
        notificationLibrary.showNotice({
            "variant": "warning",
            "header": "Yetki Sorunu",
            "message": "Anket atama işlemi için yetkiniz bulunmamaktadır. Lütfen sistem yöneticiniz ile iletişime geçiniz.",
            closeCallback: () => {
                const URLEvent = $A.get("e.force:navigateToURL");
                URLEvent.setParams({
                    "url": "/lightning/page/home"
                });
                URLEvent.fire();
            }
        });
    }

});