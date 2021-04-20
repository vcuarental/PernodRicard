/**
 * Created by osman on 15.12.2020.
 */

({
    setUserColumns: function (component) {
        const userTableColumns = [
            {
                label: 'Kullanıcı',
                fieldName: '__RecordLink',
                type: 'url',
                typeAttributes: {label: {fieldName: 'Name'}, target: '_self'}
            },
            {
                label: 'Profil',
                fieldName: 'Profile.Name',
                type: 'String',
                typeAttributes: {label: {fieldName: 'Profile.Name'}, target: '_self'}
            },
            {
                label: 'Kullanıcı Rolü',
                fieldName: 'UserRole.Name',
                type: 'String',
                typeAttributes: {label: {fieldName: 'UserRole.Name'}, target: '_self'}
            },
            {
                label: 'Ünvan',
                fieldName: 'Title',
                type: 'String',
                typeAttributes: {label: {fieldName: 'Title'}, target: '_self'}
            },
            {
                label: 'Yöneticisi',
                fieldName: 'Manager.Name',
                type: 'String',
                typeAttributes: {label: {fieldName: 'Manager.Name'}, target: '_self'}
            }


        ];
        const surveyTableColumns = [
            {
                label: 'Atanan Kullanıcı',
                fieldName: '__RecordLink',
                type: 'url',
                typeAttributes: {label: {fieldName: 'Owner.Name'}, target: '_self'},
                lookup: true
            },
            {
                label: 'Anket Açıklaması',
                fieldName: 'EUR_TR_TargetRelatedTemplate__r.EUR_TR_Description__c',
                type: 'text',
                typeAttributes: {
                    label: {fieldName: 'EUR_TR_TargetRelatedTemplate__r.EUR_TR_Description__c'},
                    target: '_blank'
                },
                lookup: true
            },
            {
                label: 'Zorunlu Anket mi ?',
                fieldName: 'EUR_TR_Mandatory__c',
                type: 'boolean',
                typeAttributes: {label: {fieldName: 'EUR_TR_Mandatory__c'}, target: '_blank'}
            }
        ];

        component.set("v.userTableColumns", userTableColumns);
        component.set("v.surveyTableColumns", surveyTableColumns);
    },

    loadData: function (component, event, helper) {

        component.set('v.isLoading', true);

        const surveyDataPagerFilterQuery = `RecordType.DeveloperName = 'EUR_TR_TemplateTarget' AND
                                         EUR_TR_IsCompleted__c = FALSE AND 
                                         EUR_TR_RelatedAccount__c = NULL AND 
                                         EUR_TR_TargetRelatedTemplate__c!=NULL AND 
                                         EUR_TR_TargetRelatedTemplate__r.EUR_TR_CaptureMoment__c!=NULL AND  
                                         EUR_TR_TargetRelatedTemplate__r.EUR_TR_CaptureMoment__c IN ('BeforeDayEnd','BeforeDayStart') `;
        component.set("v.surveyDataPagerFilter", surveyDataPagerFilterQuery);

        const utility = component.find("utility");
        const p0 = utility.callAction(component, 'c.getSurveyOptions', null);
        const p1 = utility.callAction(component, 'c.getUserPicklistFieldsWithValues', null);
        Promise.all([p0, p1]).then(data => {
            component.set("v.surveyOptions", data[0]);
            component.set("v.userPicklistWrapperModels", data[1]);
            if (data[0].length === 0) {
                component.set("v.disableButtons", true);
            }
            component.set("v.isLoading", false);
            component.set("v.loadingEnabled", true);
        }).catch(error => {
            component.set("v.isLoading", false);
            const errorMessage = (error && error.message) ? error.message : 'Bilinmeyen Hata';
            utility.showErrorToast('Hata!', errorMessage);
        })
    },

    checkUserAssignmentAttributesValid: function (isAllSelected, component, event, helper) {

        const utility = component.find("utility");
        const templateMasterSurveyId = component.get("v.userSurveyAssignmentRequest.selectedMasterSurveyTemplateId");
        if (!templateMasterSurveyId) {
            utility.showErrorToast('Hata!', "Lütfen anket seçimi yapınız");
            return false;
        }

        if (!isAllSelected) {
            const selectedUsers = component.get("v.userSurveyAssignmentRequest.users");
            if (!selectedUsers) {
                utility.showErrorToast('Hata!', "Lütfen anket atanacak en az bir kullanıcı seçiniz.");
                return false;
            } else if (!Array.isArray(selectedUsers)) {
                utility.showErrorToast('Hata!', "Lütfen anket atanacak en az bir kullanıcı seçiniz.");
                return false;
            } else if (Array.isArray(selectedUsers) && selectedUsers.length === 0) {
                utility.showErrorToast('Hata!', "Lütfen anket atanacak en az bir kullanıcı seçiniz.");
                return false;
            } else {
                return true;
            }
        }
        return true;
    },

    checkUserAssignmentAttributesValidToRemove: function (isAllSelected, component, event, helper) {

        const utility = component.find("utility");
        const templateMasterSurveyId = component.get("v.userSurveyAssignmentRequest.selectedMasterSurveyTemplateId");
        if (!templateMasterSurveyId) {
            utility.showErrorToast('Hata!', "Lütfen anket seçimi yapınız");
            return false;
        }

        if (!isAllSelected) {
            const targetSurveys = component.get("v.userSurveyAssignmentRequest.targetSurveys");
            if (!targetSurveys) {
                utility.showErrorToast('Hata!', "Anket ataması silmek için ez az 1 adet seçim yapmalısınız");
                return false;
            } else if (!Array.isArray(targetSurveys)) {
                utility.showErrorToast('Hata!', "Anket ataması silmek için ez az 1 adet seçim yapmalısınız");
                return false;
            } else if (Array.isArray(targetSurveys) && targetSurveys.length === 0) {
                utility.showErrorToast('Hata!', "Anket ataması silmek için ez az 1 adet seçim yapmalısınız");
                return false;
            } else {
                return true;
            }
        }
        return true;
    }


});