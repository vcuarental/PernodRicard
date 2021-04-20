/**
 * Created by Murat Can on 25/08/2020.
 */

({
    doInit: function(component, event, helper) {
        if (component.get("v.recordId")) {
            component.set("v.submitButtonLabel", "Değişiklikleri Kaydet");
            helper.getSurveyData(component, event, helper);
        }
    },

    handleNewQuestionButton: function (component, event, helper) {
        const details = component.get("v.details");
        let newQuestion = new Object();

        newQuestion["EUR_TR_QuestionOrder__c"] = details.length + 1;

        details.push(newQuestion);
        component.set("v.details", details);
    },

    handleDeleteQuestionButton: function (component, event, helper) {
        const detailIndex = event.getSource().get("v.name");
        let deleteList = component.get("v.deleteList");
        let details = component.get("v.details");

        deleteList.push(details[detailIndex]);
        details.splice(detailIndex, 1);

        component.set("v.deleteList", deleteList);
        component.set("v.details", details);
    },

    handleDeleteOptionButton: function (component, event, helper) {
        const indexes = event.getSource().get("v.name");
        const detailIndex = indexes.split('-')[0];
        const optionIndex = indexes.split('-')[1];
        let deleteList = component.get("v.deleteList");
        let details = component.get("v.details");

        deleteList.push(details[detailIndex]["Options__r"][optionIndex]);
        details[detailIndex]["Options__r"].splice(optionIndex, 1);

        component.set("v.deleteList", deleteList);
        component.set("v.details", details);
    },

    handleNewOptionButton: function (component, event, helper) {
        const detailIndex = event.getSource().get("v.name");
        const details = component.get("v.details");
        let newQuestion = new Object();

        if (details[detailIndex]["Options__r"]) {
            newQuestion["EUR_TR_QuestionOrder__c"] = details[detailIndex]["Options__r"].length + 1;
        } else {
            newQuestion["EUR_TR_QuestionOrder__c"] = 1;
            details[detailIndex]["Options__r"] = [];
        }

        details[detailIndex]["Options__r"].push(newQuestion);
        component.set("v.details", details);
    },

    handleCheckboxButton: function (component, event, helper) {
        const indexes = event.getSource().get("v.name");
        const detailIndex = indexes.split('-')[0];
        const optionIndex = indexes.split('-')[1];
        let details = component.get("v.details");

        if (details[detailIndex]["EUR_TR_QuestionType__c"] !== "Radio") {
            return;
        }

        for (let index = 0; index < details[detailIndex]["Options__r"].length; index++) {
            if (index != optionIndex) {
                details[detailIndex]["Options__r"][index]["EUR_TR_AnswerRadioToEarnPoints__c"] = false;
            }
        }

        component.set("v.details", details);
    },

    handleSaveButton: function (component, event, helper) {
        if (helper.validateInputs(component, event, helper)) {
            helper.saveSurveyData(component, event, helper);
        }
    },

    handleFileUploaded: function (component, event, helper) {
        const uploadedFiles = event.getParam("files");
        const detailId = event.getSource().get("v.name");
        let details = component.get("v.details");
        let detail;

        let documents = new Array();
        uploadedFiles.forEach(file => {
            let newFile = new Object();

            newFile["Title"] = file["name"];
            newFile["ContentDocumentId"] = file["documentId"];

            documents.push(newFile);
        });

        for (let index = 0; index < details.length; index++) {
            if (details[index]["Id"] === detailId) {
                detail = details[index];
                break;
            }
        }

        if (detail["AttachedContentDocuments"]) {
            detail["AttachedContentDocuments"].push(...documents);
        } else {
            detail["AttachedContentDocuments"] = documents;
        }

        component.set("v.details", details);

        helper.showToast("success", "Başarılı!", "Dosyalar başarılı bir şekilde yüklenmiştir.");
    },

    /*
    toggleModalOpen: function (component, event, helper) {
        component.set("v.isModalOpen", !component.get("v.isModalOpen"));
    },
    */

    handleMandatoryToggle: function (component, event, helper) {
        const detailIndex = event.getSource().get("v.name");
        let details = component.get("v.details");
        let detail = details[detailIndex];

        detail["EUR_TR_PictureRequired__c"] = detail["EUR_TR_PictureRequired__c"] && detail["EUR_TR_Mandatory__c"];

        component.set("v.details", details);
    },

    refreshSurveyForm: function (component, event, helper) {
        if (!component.get("v.recordId")) {
            $A.get('e.force:refreshView').fire();
        }
    },
});