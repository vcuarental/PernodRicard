/**
 * Created by Murat Can on 25/08/2020.
 */

({
    getSurveyData: function(component, event, helper) {
        component.set("v.isLoading", true);
        const commonUtility = component.find("commonUtility");

        const p0 = commonUtility.callAction(component, 'c.getSurvey', {
            recordId : component.get("v.recordId")
        });
        const p1 = commonUtility.callAction(component, 'c.getUsers', {});

        Promise.all([p0, p1]).then($A.getCallback(function (response) {
            const {details, master} = response[0];
            const allUsers = response[1];

            component.set("v.isLoading", false);
            component.set("v.master", master);
            component.set("v.details", details);
            component.set("v.deleteList", []);

            let assignedUsers = [];
            let users = [];

            if (allUsers) {
                allUsers.forEach(user => {
                    users.push({
                        label: user["Name"],
                        value: user["Id"]
                    });
                });
            }

            if (master["TargetedAccounts__r"]) {
                master["TargetedAccounts__r"].forEach(user => {
                    assignedUsers.push(user["Owner"]["Id"]);
                });
            }

            component.set("v.users", users);
            component.set("v.assignedUsers", assignedUsers);
        }), function (error) {
            component.set("v.isLoading", false);

            const errorMessage = (error && error.message) ? error.message : 'Bilinmeyen Hata';
            commonUtility.showErrorToast('Hata!', errorMessage);
        });
    },

    saveSurveyData: function (component, event, helper) {
        component.set("v.isLoading", true);
        let action = component.get("c.saveSurvey");

        let surveyWrapper = new Object();

        surveyWrapper["master"] = component.get("v.master");
        surveyWrapper["details"] = this.rewriteChildRecords(component.get("v.details"));
        surveyWrapper["deleteList"] = this.rewriteChildRecords(component.get("v.deleteList"));
        surveyWrapper["assignedUserIds"] = component.get("v.assignedUsers");

        // To Prevent error: QueryResult must start with '{'
        {
            for (let index = 0; index < surveyWrapper["details"].length; index++) {
                surveyWrapper["details"][index]["AttachedContentDocuments"] = undefined;
            }

            surveyWrapper["master"]["TargetedAccounts__r"] = undefined;
        }

        action.setParams({
            surveyWrapperAsString : JSON.stringify(surveyWrapper)
        });

        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === "SUCCESS") {
                const {details, master} = response.getReturnValue();
                this.showToast("success", "Başarılı!", "Anket başarılı bir şekilde kaydedilmiştir.");
                this.navigateRelatedPage(component, event, master.Id);
                component.set("v.isLoading", false);
            } else {
                this.showToast("error", "Hata!", "Kayıt işlemi başarısız oldu.");
            }
        });

        $A.enqueueAction(action);
    },

    rewriteChildRecords: function (masterArray) {
        if (masterArray) {
            for (let i = 0; i < masterArray.length; i++) {
                let array = masterArray[i]["Options__r"];

                if (array && !array.hasOwnProperty('records')) {
                    let tempArray = array;

                    array = {
                        totalSize: tempArray.length,
                        done: true,
                        records: tempArray
                    }

                    masterArray[i]["Options__r"] = array;
                }
            }
        }

        return masterArray;
    },

    showToast: function(type, title, message) {
        let toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
            "title" : title,
            "message" : message,
            "type" : type
        });
        toastEvent.fire();
    },

    validateInputs: function (component, event, helper) {
        const inputComps = component.find("inputComp");
        for (let i = 0; i < inputComps.length; i++) {
            const inputComp = inputComps[i];
            if (!inputComp.reportValidity()) {
                helper.showToast("error", "Eksik alanlar", "Lütfen tüm alanları doldurduğunuzdan emin olun.");

                return false;
            }
        }

        const {EUR_TR_ValidFrom__c, EUR_TR_ValidThru__c, EUR_TR_IsScored__c} = component.get("v.master");
        if (EUR_TR_ValidFrom__c > EUR_TR_ValidThru__c) {
            helper.showToast("error", "Hata", "Başlangıç tarihi, bitiş tarihinden ileride olamaz.");

            return false;
        }

        const details = component.get("v.details");
        for (let i = 0; i < details.length; i++) {
            const detail = details[i];

            if (detail["EUR_TR_QuestionType__c"] === "Radio" || detail["EUR_TR_QuestionType__c"] === "MultiSelect") {
                if (!detail["Options__r"] || !EUR_TR_IsScored__c) {
                    continue;
                }

                let checkedOptions = 0;
                for (let j = 0; j < detail["Options__r"].length; j++) {
                    const option = detail["Options__r"][j];

                    if (option["EUR_TR_AnswerRadioToEarnPoints__c"] === true) {
                        checkedOptions++;
                    }
                }

                if (checkedOptions === 0) {
                    helper.showToast("error", "Hata", "En az bir seçenek doğru olarak işaretlenmelidir.");

                    return false;
                }
            }
        }

        return true;
    },


    /**
     *
     * If the current page is record page , the system will not navigate any different page.
     * If the current page is not record page, and  EUR_TR_CaptureMoment__c is BeforeDayStart or  BeforeDayEnd, the system will  navigate EUR_TR_UserSurveyAssignment tab page.
     * If the current page is not record page, and  EUR_TR_CaptureMoment__c is BeforeVisitStart or  BeforeVisitEnd, the system will  navigate EUR_TR_SurveyAssignment tab page.
     *
     */
    navigateRelatedPage: function (component, event, createdMasterSurveyId) {

        const navService = component.find("navService");
        event.preventDefault();
        const recordId = component.get("v.recordId");

        if (recordId) {
            const pageReference = {
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": recordId,
                    "objectApiName": "EUR_TR_Survey__c",
                    "actionName": "view"
                }
            };
            navService.navigate(pageReference);
        } else {

            const captureMoment = component.get("v.master.EUR_TR_CaptureMoment__c");
            let tabName = '';
            if (captureMoment === "BeforeDayStart" || captureMoment === "BeforeDayEnd") {
                tabName = "EUR_TR_UserSurveyAssignment";
            } else if (captureMoment === "BeforeVisitStart" || captureMoment === "BeforeVisitEnd") {
                tabName = "EUR_TR_SurveyAssignment";
            } else {
                tabName = "unknown";
            }

            let pageReference = {};
            if (tabName === "unknown") {
                pageReference = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": createdMasterSurveyId,
                        "objectApiName": "EUR_TR_Survey__c",
                        "actionName": "view"
                    }
                };
            } else {
                pageReference = {
                    "type": "standard__navItemPage",
                    "attributes": {
                        "apiName": tabName
                    }
                };
            }
            navService.navigate(pageReference);


        }

    }

});