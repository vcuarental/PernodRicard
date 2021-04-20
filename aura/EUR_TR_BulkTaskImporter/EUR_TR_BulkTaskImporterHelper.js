/**
 * Created by Murat Can on 11/09/2020.
 */

({
    showErrorToast: function (error, mode) {
        const message = (error && error.message) ? error.message : JSON.stringify(error);
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: mode ? mode : 'sticky',
            type: "error",
            title: "Hata!",
            message: message
        });
        toastEvent.fire();
    },

    getPredefinedTaskData: function (component, event, helper) {
        component.set("v.isLoading", true);

        const utility = component.find("utility");
        const taskType = component.get("v.importType");
        let developerName;

        if (taskType === 'preseller') {
            developerName = 'EUR_TR_PredefinedTaskPreseller'
        } else if (taskType === 'fastTrack') {
            developerName = 'EUR_TR_PredefinedTaskSalesforce'
        }

        let definition = {
            sobjectType: 'EUR_TR_Definition__c',
            RecordType: {
                sobjectType: 'RecordType',
                DeveloperName: developerName
            }
        };

        utility.callAction(component, 'c.getPredefinedTasks', {
            request: definition
        }).then(function (response) {
            component.set("v.isLoading", false);
            component.set("v.predefinedTasks", response);
        }, function (error) {
            component.set("v.isLoading", false);
            helper.showErrorToast(error);
        });
    },


    onDataPartLoad: function (component, event, helper, readerFiles) {
        component.set("v.isLoading", true);

        const loadEvent = event.getParams();
        const data = loadEvent.data;
        const errors = loadEvent.errors;
        const selectedPredefinedTaskId = component.get("v.selectedPredefinedTaskId");
        const importType = component.get("v.importType");
        const utility = component.find("utility");

        for (let item of data) {
            let dateString;

            if (item.ActivityDate) {
                if (item.ActivityDate.includes('/')) {
                    dateString = item.ActivityDate.split('/').reverse().join('-');
                } else if (item.ActivityDate.includes('.')) {
                    dateString = item.ActivityDate.split('.').reverse().join('-');
                } else {
                    dateString = item.ActivityDate;
                }
            }

            const activityDate = new Date(dateString);
            if (activityDate.getTime()) {
                activityDate.setMinutes(-activityDate.getTimezoneOffset());
                item.ActivityDate = activityDate.toISOString().split("T")[0];
            }
        }

        utility.callAction(component, 'c.saveTasks', {
            taskWrapperChunk: data,
            predefinedTaskId: selectedPredefinedTaskId ? selectedPredefinedTaskId : '',
            importType: importType,
            files: readerFiles
        }).then(function (response) {
            helper.exportErrorDataAsCsv(component, data, response.errorRows);

            loadEvent.reportSuccess(response.successSize);
            loadEvent.reportError(response.errorSize);
            loadEvent.resume();
        }, function (error) {
            helper.exportErrorDataAsCsv(component, data);

            component.set("v.isLoading", false);
            helper.showErrorToast(error);
            loadEvent.reportError(data.length);
            loadEvent.resume();
        });
    },

    exportErrorDataAsCsv: function (component, data, errorRows) {
        let errorData;

        if (data) {
            if (errorRows && errorRows.length > 0) { // called from server success and has error rows
                errorData = errorRows.map(rowNumber => data[rowNumber]);
            } else if (!errorRows) { // called from server error and does not have error rows (all of the data has error)
                errorData = data;
            } else {
                return;
            }
        } else {
            return;
        }

        const csvFileInfo = component.get("v.csvFileInfo");
        const errorsCsvFile = Papa.unparse(errorData, {
            header: false,
            skipEmptyLines: 'greedy'
        });

        let hiddenElement = document.createElement('a');

        hiddenElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURI(errorsCsvFile);
        hiddenElement.target = '_self';
        hiddenElement.download = 'errors_' + Date.now() + '_' + csvFileInfo.fileName;

        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    },

    fastTrackColumns: [
        {label: 'Görev Tipi', fieldName: 'Cliente', type: 'text'},
        {label: 'Müşteri Kodu', fieldName: 'What_EUR_TR_AccountCode', type: 'text'},
        {label: 'Açıklama', fieldName: 'Description', type: 'text'},
        {label: 'Kullanıcı', fieldName: 'Username', type: 'text'},
        {label: 'Tarih', fieldName: 'ActivityDate', type: 'text'}
    ],

    presellerColumns: [
        {label: 'Görev Tipi', fieldName: 'Cliente', type: 'text'},
        {label: 'Müşteri Kodu', fieldName: 'What_EUR_TR_AccountCode', type: 'text'},
        {label: 'Açıklama', fieldName: 'Description', type: 'text'},
        {label: 'Tarih', fieldName: 'ActivityDate', type: 'text'}
    ]
});