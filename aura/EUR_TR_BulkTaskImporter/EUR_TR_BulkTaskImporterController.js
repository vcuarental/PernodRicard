/**
 * Created by Murat Can on 10/09/2020.
 */

({
    doInit: function (component, event, helper) {
        component.set("v.columns", helper.fastTrackColumns);

        helper.getPredefinedTaskData(component, event, helper);
    },

    onDataPartLoad: function (component, event, helper) {
        const attachedFiles = component.get("v.attachedFiles") ? component.get("v.attachedFiles")[0] : undefined;
        const importType = component.get("v.importType");

        if (importType === 'fastTrack' && attachedFiles && attachedFiles.length > 0) {
            let readerFiles = [];

            for (let index = 0; index < attachedFiles.length; index++) {
                const attachedFile = attachedFiles[index];
                let reader = new FileReader();
                let file = {};

                reader.onloadend = function() {
                    const dataURL = reader.result;

                    file.base64Data = dataURL.match(/,(.*)$/)[1];
                    file.fileName = attachedFile.name;

                    readerFiles.push(file);

                    if (index === attachedFiles.length - 1) {
                        helper.onDataPartLoad(component, event, helper, readerFiles);
                    }
                }

                reader.readAsDataURL(attachedFile);
            }
        } else {
            helper.onDataPartLoad(component, event, helper);
        }
    },

    onDataLoadComplete: function (component, event, helper) {
        const completeEvent = event.getParams();
        //const successCount = completeEvent.successCount();
        //const failedCount = completeEvent.failedCount();
        //completeEvent.reportSuccess(0);
        //completeEvent.reportError(0);
        // alert("file processed")
    },
    handleChangePredefinedTask: function (component, event, helper) {
        const csvLoader = component.find("csvLoader");
        const selectedPredefinedTaskId = event.getSource().get("v.value");
        component.set("v.selectedPredefinedTaskId", selectedPredefinedTaskId);
        const predefinedTasks = component.get("v.predefinedTasks");
        const selectedPredefinedTask = predefinedTasks.find(x => x.Id === selectedPredefinedTaskId);

        if ($A.util.isEmpty(selectedPredefinedTask)) {
            csvLoader.reloadPreviewData();
        } else {
            csvLoader.enrichPreviewData(function (data) {
                if (!Array.isArray(data) || $A.util.isEmpty(data)) {
                    helper.showErrorToast({
                        message : 'Lütfen önce dosyayı yükleyiniz.'
                    }, 'pester');

                    component.set("v.selectedPredefinedTaskId", '');
                    return
                }

                for (let item of data) {
                    item.Cliente = selectedPredefinedTask.EUR_TR_TaskType__c;
                    item.Description = selectedPredefinedTask.EUR_TR_TaskDescription__c;
                    item.ActivityDate = selectedPredefinedTask.EUR_TR_ActivityDate__c;
                }
                return true
            });
        }
    },

    handleSwitchTaskType: function (component, event, helper) {
        const buttonType = event.getSource().get("v.name");
        let columns;

        if (buttonType === 'fastTrack') {
            columns = helper.fastTrackColumns;
        } else if (buttonType === 'preseller') {
            columns = helper.presellerColumns;
        }

        component.set("v.columns", columns);
        component.set("v.importType", buttonType);

        helper.getPredefinedTaskData(component, event, helper);
    },

    onCsvFileUploaded: function (component, event) {
        const csvFileInfo = event.getParams();
        component.set("v.csvFileInfo", csvFileInfo);
    },

    handleDownloadCSVSample: function (component, event) {
        const importType = component.get("v.importType");
        let fileName;

        if (importType === 'fastTrack') {
            fileName = '/BTI_Sample_Salesforce.csv';
        } else if (importType === 'preseller') {
            fileName = '/BTI_Sample_Preseller.csv';
        } else {
            return;
        }

        window.open($A.get('$Resource.EUR_TR_BTI_Samples') + fileName, '_blank');
    },

    handleFilesChange: function (component, event, helper) {
        const files = event.getParam("files");

        if (files) {
            if (files.length > 5 ) {
                helper.showErrorToast({
                    message : 'En fazla 5 dosya yükleyebilirsiniz.'
                }, 'pester');

                component.set("v.attachedFiles", []);
                return;
            }
        }
    }
});