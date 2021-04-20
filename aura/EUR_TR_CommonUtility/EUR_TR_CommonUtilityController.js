/**
 * Created by bsavcı on 8/27/2020.
 */

({
    callAction: function (component, event, helper) {
        const params = event.getParam('arguments');
        console.log(params.actionName)
        return new Promise(function (resolve, reject) {
            if (!params) {
                reject('parameters are not provided');
                return;
            }
            if (!params.component) {
                reject('component parameter is not provided');
                return;
            }
            if (!params.actionName) {
                reject('actionName parameter is not provided');
                return;
            }

            let action = params.component.get(params.actionName);
            if (params.parameters) {
                action.setParams(params.parameters);
            }
            action.setCallback(this, $A.getCallback(function (actionResult) {
                if (actionResult.getState() === 'SUCCESS') {
                    resolve(actionResult.getReturnValue());
                } else {
                    let errors = actionResult.getError();
                    const errorMessageExtract = function (e) {
                        let singleErrorMessage = "";
                        if (typeof e != "undefined") {
                            if (typeof e.message != "undefined") {
                                singleErrorMessage += e.message;
                            }
                            if (typeof e.pageErrors != "undefined" && Array.isArray(e.pageErrors)) {
                                for (let pageError of e.pageErrors) {
                                    singleErrorMessage += errorMessageExtract(pageError);
                                }
                            }
                        }
                        return singleErrorMessage;
                    }
                    console.log(errors);
                    let allMessages = "";
                    if (Array.isArray(errors)) {
                        for (let e of errors) {
                            allMessages += errorMessageExtract(e);
                        }
                    } else {
                        allMessages = JSON.stringify(errors);
                    }
                    let error = new Error(allMessages);

                    reject(error);
                }
            }));
            $A.enqueueAction(action);
        });
    },
    handleShowErrorToast: function (component, event, helper) {
        const params = event.getParam('arguments');
        const title = params.title;
        const message = params.message;
        let duration = params.duration;
        if (!duration) {
            duration = ' 3000';
        }
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            messageTemplate: 'Mode is pester ,duration is 4sec and Message is overrriden',
            duration: duration,
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    handleShowSuccessToast: function (component, event, helper) {
        const params = event.getParam('arguments');
        const title = params.title;
        const message = params.message;
        let duration = params.duration;
        if (!duration) {
            duration = ' 3000';
        }
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: duration,
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    handleShowWarningToast: function (component, event) {
        const params = event.getParam('arguments');
        const title = params.title;
        const message = params.message;
        let duration = params.duration;
        if (!duration) {
            duration = ' 3000';
        }
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: duration,
            key: 'info_alt',
            type: 'warning',
            mode: 'pester'
        });
        toastEvent.fire();
    },


});