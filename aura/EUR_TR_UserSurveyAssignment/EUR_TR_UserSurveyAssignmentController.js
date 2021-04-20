/**
 * Created by osman on 15.12.2020.
 */

({
    doInit: function (component, event, helper) {
        component.set("v.userSurveyAssignmentRequest", {});
        helper.setUserColumns(component);
        const userDataPagerCmp = component.find("userDataPager");
        const defaultUserFilter = userDataPagerCmp.get("v.filter");
        component.set("v.defaultUserFilterQuery", defaultUserFilter);
        helper.loadData(component, event, helper);
    },


    handleSelectedSurveyChange: function (component, event, helper) {

        const templateMasterSurveyId = event.getParam("value");
        const currentSurveyDataPagerFilterQuery = component.get('v.surveyDataPagerFilter');
        const previousTemplateSurveyId = component.get('v.userSurveyAssignmentRequest.previousSelectedSurveyId');
        component.set('v.userSurveyAssignmentRequest.previousSelectedSurveyId', templateMasterSurveyId);

        if ($A.util.isEmpty(previousTemplateSurveyId)) {
            const surveyDataPagerFilterQuery = currentSurveyDataPagerFilterQuery + ` AND EUR_TR_TargetRelatedTemplate__c = '${templateMasterSurveyId}'`;
            component.set('v.surveyDataPagerFilter', surveyDataPagerFilterQuery);
        } else {
            const updatedSurveyDataPagerFilterQuery = currentSurveyDataPagerFilterQuery
                .split(` AND EUR_TR_TargetRelatedTemplate__c = '${previousTemplateSurveyId}'`)
                .join(` AND EUR_TR_TargetRelatedTemplate__c = '${templateMasterSurveyId}'`);
            component.set('v.surveyDataPagerFilter', updatedSurveyDataPagerFilterQuery);
        }

        component.set('v.hideCheckboxColumn', false);
    },

    assignSurveysToUsers: function (component, event, helper) {

        component.set("v.isLoading", true);
        const utility = component.find("utility");
        const dataQuery = component.find("userDataPager").getDataQuery();
        const clickedButtonActionType = event.getSource().get("v.value");
        const isAllSelected = (clickedButtonActionType === "allUsers");
        component.set("v.userSurveyAssignmentRequest.isAllSelected", isAllSelected);
        component.set("v.userSurveyAssignmentRequest.surveyAssignmentQueryToAllUserAssignment", dataQuery);
        component.set("v.isLoading", false);

        const isValid = helper.checkUserAssignmentAttributesValid(isAllSelected, component, event, helper);

        if (!isValid) {
            return;
        }

        const isApprovedAssigmentAction = confirm('Atama işlemi gerçekleşecek , onaylıyor musunuz ?');
        if (isApprovedAssigmentAction) {
            component.set("v.isLoading", true);
            utility.callAction(component, 'c.assignSurveyToUsers', {
                userSurveyAssignmentRequest: component.get("v.userSurveyAssignmentRequest")
            }).then(data => {
                utility.showSuccessToast("Başarı", "Anket atama işlemi başarılı bir şekilde tamamlandı.", 500);
                const surveyPagerCmp = component.find("surveyPager");
                surveyPagerCmp.reloadData();
                component.set("v.isLoading", false);
            }).catch(error => {
                const errorMessage = (error && error.message) ? error.message : 'Bilinmeyen Hata';
                utility.showErrorToast('Hata!', errorMessage);
                component.set("v.isLoading", false);
            });
        }


    },

    removeSurveyAssignments: function (component, event, helper) {

        component.set("v.isLoading", true);
        const utility = component.find("utility");
        const dataQuery = component.find("surveyPager").getDataQuery();
        const clickedButtonActionType = event.getSource().get("v.value");
        const isAllSelected = (clickedButtonActionType === "allUsers");
        component.set("v.userSurveyAssignmentRequest.isAllSelected", isAllSelected);
        component.set("v.userSurveyAssignmentRequest.surveyAssignmentQueryToRemoveAllAssignment", dataQuery);
        component.set("v.isLoading", false);

        const isValid = helper.checkUserAssignmentAttributesValidToRemove(isAllSelected, component, event, helper);
        if (!isValid) {
            return;
        }

        const isApprovedRemoveAssigmentAction = confirm('Anket ataması silinecek , onaylıyor musunuz ?');
        if (isApprovedRemoveAssigmentAction) {
            component.set("v.isLoading", true);
            utility.callAction(component, 'c.removeAssignedSurveysToUsers', {
                userSurveyAssignmentRequest: component.get("v.userSurveyAssignmentRequest")
            }).then(data => {
                utility.showSuccessToast("Başarı", "Atama silme işlemi başarılı bir şekilde tamamlandı.", 500);
                const surveyPagerCmp = component.find("surveyPager");
                surveyPagerCmp.reloadData();
                component.set("v.isLoading", false);
            }).catch(error => {
                const errorMessage = (error && error.message) ? error.message : 'Bilinmeyen Hata';
                utility.showErrorToast('Hata!', errorMessage);
                component.set("v.isLoading", false);
            });
        }


    },

    updatePicklistItemWithLabelOnDataChange: function (component, event, helper) {

        const userDataPager = component.find("userDataPager");
        const data = userDataPager.get("v.data");
        const picklistFieldsWrappers = component.get("v.userPicklistWrapperModels");
        const fieldMap = new Map();
        picklistFieldsWrappers.forEach(item => {
            fieldMap.set(item.fieldName, item.labelValueMap);
        });
        [...fieldMap.keys()].forEach(key => {
            const labelValueMap = new Map(Object.entries(fieldMap.get(key)));
            data.forEach(item => {
                if (key in item) {
                    item[key] = labelValueMap.get(item[key]);
                }
            })
        })
    },

    openUserFilterDialog: function (component, event, helper) {
        component.set("v.isUserFilterDialogOpen", true);
    },

    refreshUserTable: function (component, event, helper) {
        const eventUserFilterQuery = event.getParam("filterQuery");
        const defaultUserFilterQuery = component.get("v.defaultUserFilterQuery");
        const newFilter = `${defaultUserFilterQuery} ${eventUserFilterQuery} `;

        const userDataPagerCmp = component.find("userDataPager");
        userDataPagerCmp.set("v.filter", newFilter);
        userDataPagerCmp.reloadData();

        console.log("data query : ", component.get("v.userSurveyAssignmentRequest.surveyAssignmentQueryToAllUserAssignment"));
        console.log("newFilter  :", newFilter);

    }


});