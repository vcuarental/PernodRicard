/**
 * Created by bsavcı on 8/27/2020.
 */

({
    doInit: function (component, event, helper) {

        component.set('v.loading', true);
        const utility = component.find("utility");
        const surveyAssignmentPermissionPromise = utility.callAction(component, 'c.getSurveyAssignmentPagePermission', null);
        surveyAssignmentPermissionPromise.then(hasPermissionToSurveyAssignment => {
            component.set("v.hasPermissionToSurveyAssignment", hasPermissionToSurveyAssignment);
            if (hasPermissionToSurveyAssignment) {
                component.set("v.surveyDataPagerFilter", `RecordType.DeveloperName = 'EUR_TR_TemplateTarget'
                                         AND EUR_TR_IsCompleted__c = FALSE
                                         AND EUR_TR_RelatedAccount__c != NULL`);
                $A.enqueueAction(component.get("c.loadData"));
            } else {
                helper.showPermissionWarningMessage(component);
                component.set('v.disableButtons', true);
                component.set('v.loading', false);
            }
        }).catch(error => {
            component.set('v.loading', false);
            helper.handleErrorResponse(component, utility, error);
            component.set("v.disableButtons", true);
        });


    },

    loadData: function (component, event, helper) {
        component.set('v.loading', true);
        component.set('v.disableButtons', true);

        const utility = component.find("utility");
        const p0 = utility.callAction(component, 'c.getSurveyOptions', null);
        const p1 = utility.callAction(component, 'c.getLatestBatchProcess', null);

        Promise.all([p0, p1]).then(function (results) {
            component.set('v.surveyOptions', results[0]);
            if ($A.util.isEmpty(component.get('v.assignSurveyRequest'))) component.set('v.assignSurveyRequest', {});
            if ($A.util.isEmpty(component.get('v.removeSurveyAssignmentRequest'))) component.set('v.removeSurveyAssignmentRequest', {});
            if (!$A.util.isEmpty(results[1])) {
                utility.showWarningToast("Uyarı", "İşlem yapmak için sürecin bitmesini bekleyiniz.")
                component.set('v.batchProcess', results[1][0]);
                $A.enqueueAction(component.get("c.updateBatchProcessStatus"));
            } else {
                component.set('v.disableButtons', false);
            }
            component.set('v.disableButtons', false);
            component.set('v.loading', false);
        }, function (error) {
            component.set('v.loading', false);
            helper.handleErrorResponse(component, utility, error);
        });
        $A.util.isEmpty(component.get('v.accountDataPagerColumns'))
            ? helper.setAccountDataPagerColumns(component)
            : component.set('v.accountDataPagerColumns', component.get('v.accountDataPagerColumns'));
        $A.util.isEmpty(component.get('v.surveyDataPagerColumns'))
            ? helper.setSurveyDataPagerColumns(component)
            : component.set('v.surveyDataPagerColumns', component.get('v.surveyDataPagerColumns'));
    },

    assignSurveys: function (component, event, helper) {
        component.set('v.disableButtons', true);
        const utility = component.find("utility");

        if (!helper.validateAssignSurveyRequest(component)) {
            component.set('v.disableButtons', false);
            return;
        }
        component.find('accountDataPager').set('v.loading', true);
        component.set('v.assignSurveyRequest.Accounts', component.find('accountDataPager').get('v.selectedRows').map(x => {
            return {
                Id: x.Id
            }
        }));

        utility.callAction(component, 'c.assignSurveyRequest', {request: component.get('v.assignSurveyRequest')})
            .then(function (response) {
                if (response.Success) {
                    helper.handleSuccessfulResponse(component, utility, response);
                    $A.enqueueAction(component.get("c.loadData"));
                } else {
                    helper.handleUnSuccessfulResponse(component, utility, response);
                }
            }, function (error) {
                helper.handleErrorResponse(component, utility, error);
            });
    },
    removeSurveyAssignments: function (component, event, helper) {
        component.set('v.disableButtons', true);
        const utility = component.find("utility");

        if (!helper.validateRemoveSurveyRequest(component)) {
            component.set('v.disableButtons', false);
            return;
        }
        component.find('surveyDataPager').set('v.loading', true);
        component.set('v.removeSurveyAssignmentRequest.TargetSurveys', component.find('surveyDataPager').get('v.selectedRows').map(x => {
            return {
                Id: x.Id
            }
        }));

        utility.callAction(component, 'c.removeSurveyAssignmentRequest', {request: component.get('v.removeSurveyAssignmentRequest')})
            .then(function (response) {
                if (response.Success) {
                    helper.handleSuccessfulResponse(component, utility, response);
                    $A.enqueueAction(component.get("c.loadData"));
                } else {
                    helper.handleUnSuccessfulResponse(component, utility, response);
                }
            }, function (error) {
                helper.handleErrorResponse(component, utility, error);
            });
    },

    bulkAssignSurveys: function (component, event, helper) {
        component.set('v.assignSurveyRequest.Query', component.find("accountDataPager").getDataQuery());
        if (!helper.validateBulkAssignSurveyRequest(component)) return;

        const utility = component.find("utility");
        component.set('v.disableButtons', true);
        component.set('v.batchProcessesLoading', true);
        utility.callAction(component, 'c.bulkAssignSurveyRequest',
            {request: component.get('v.assignSurveyRequest')})
            .then(function (response) {
                component.set('v.batchProcessesLoading', false);
                response.Success
                    ? helper.handleSuccessBulkResponse(component, response, helper)
                    : helper.handleUnSuccessfulResponse(component, utility, response);
            }, function (error) {
                component.set('v.batchProcessesLoading', false);
                helper.handleErrorResponse(component, utility, error);
            });
    },
    bulkRemoveSurveys: function (component, event, helper) {
        component.set('v.removeSurveyAssignmentRequest.Query', component.find("surveyDataPager").getDataQuery());
        if (!helper.validateBulkRemoveSurveyRequest(component)) return;

        const utility = component.find("utility");
        component.set('v.disableButtons', true);
        component.set('v.batchProcessesLoading', true);
        utility.callAction(component, 'c.bulkRemoveSurveyAssignmentRequest',
            {request: component.get('v.removeSurveyAssignmentRequest')})
            .then(function (response) {
                component.set('v.batchProcessesLoading', false);
                response.Success
                    ? helper.handleSuccessBulkResponse(component, response, helper)
                    : helper.handleUnSuccessfulResponse(component, utility, response);
            }, function (error) {
                component.set('v.batchProcessesLoading', false);
                helper.handleErrorResponse(component, utility, error);
            });
    },

    updateBatchProcessStatus: function (component, event, helper) {
        component.set('v.disableButtons', true);
        const updateFromRefreshButton = (!$A.util.isEmpty(event) && event.getSource().get('v.name') === 'refresh');
        if (updateFromRefreshButton) component.set('v.batchProcessesLoading', true);
        const utility = component.find("utility");
        const intervalId = window.setInterval(
            $A.getCallback(function () {
                if (!$A.util.isEmpty(component.get('v.batchProcess.Id'))) {
                    utility.callAction(component, 'c.getBatchProcessesStatus', {batchProcessesId: component.get('v.batchProcess.Id')})
                        .then(function (response) {
                            component.set('v.batchProcess', response);
                            if (updateFromRefreshButton) {
                                window.clearInterval(intervalId);//Refresh operation just for one callAction
                                component.set('v.batchProcessesLoading', false);
                            }
                            if (response.Status === 'Completed') {
                                window.clearInterval(intervalId);
                                //if operation completed then refresh dataPager
                                component.set('v.disableButtons', false);
                                component.set('v.batchProcess', null);
                                $A.enqueueAction(component.get("c.loadData"));
                            }
                        }, function (error) {
                            window.clearInterval(intervalId);
                            helper.handleErrorResponse(component, utility, error);
                        })
                } else {
                    window.clearInterval(intervalId);
                }
            }), 1000
        );
    },

    handleSelectedSurveyChange: function (component, event) {
        const templateSurveyId = event.getParam("value");
        const previousTemplateSurveyId = component.get('v.assignSurveyRequest.previousSelectedSurveyId');
        const filter = component.get('v.surveyDataPagerFilter');
        component.set('v.assignSurveyRequest.previousSelectedSurveyId', templateSurveyId);
        if ($A.util.isEmpty(previousTemplateSurveyId)) {
            component.set('v.surveyDataPagerFilter', filter + ` AND EUR_TR_TargetRelatedTemplate__c = '${templateSurveyId}'`);
        } else {
            const updatedFilter = filter.split(` AND EUR_TR_TargetRelatedTemplate__c = '${previousTemplateSurveyId}'`).join(` AND EUR_TR_TargetRelatedTemplate__c = '${templateSurveyId}'`);
            component.set('v.surveyDataPagerFilter', updatedFilter);
        }

        component.set('v.hideCheckboxColumn', false);
    },

    handlePageReferenceChange: function (component, event, helper) {
        const hasPermissionToSurveyAssignment = component.get("v.hasPermissionToSurveyAssignment");
        if (!hasPermissionToSurveyAssignment) {
            helper.showPermissionWarningMessage(component);
        }
    }

});