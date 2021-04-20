/**
 * Created by aliku on 12/26/2020.
 */

({
    doInit: function (component, event, helper) {
        component.set("v.columns", [
            {label: 'Müşteri Kodu', fieldName: 'AccountCode', type: 'text'},
            {label: 'Dönem', fieldName: 'Period', type: 'text'},
            {label: 'Brüt Ciro', fieldName: 'ProfitAmount', type: 'text'},
            {label: 'Toplam kazanç', fieldName: 'TotalAmount', type: 'text'}
        ]);
    },
    onDataPartLoad: function (component, event, helper) {
        const loadEvent = event.getParams();
        const data = loadEvent.data;
        const errors = loadEvent.errors;
        const utility = component.find("utility");
        const itemsToUpsert = data.map(function (item) {
            const period = helper.parsePeriodText(component, item.Period);
            return {
                AccountCode: item.AccountCode,
                Year: period.year,
                Quarter: period.quarter,
                ProfitAmount: parseFloat(item.ProfitAmount.replace(',', '.')),
                TotalAmount: parseFloat(item.TotalAmount.replace(',', '.')),
            }
        }).filter(function (item) {
            return !$A.util.isEmpty(item.AccountCode) &&
                !$A.util.isEmpty(item.Year) &&
                !$A.util.isEmpty(item.Quarter) &&
                !$A.util.isEmpty(item.ProfitAmount) &&
                !$A.util.isEmpty(item.TotalAmount);
        })

        loadEvent.reportError(data.length - itemsToUpsert.length);

        component.set("v.isLoading", true);
        utility.callAction(component, 'c.upsertProfitabilityItems', {
            items: itemsToUpsert
        }).then(function (response) {


            component.set("v.isLoading", false);
            const totalRowCount = component.get("v.totalRowCount");

            // calculated processed count
            let processedRowCount = component.get("v.processedRowCount");
            processedRowCount += itemsToUpsert.length;
            component.set("v.processedRowCount", processedRowCount);

            // calculated total error size by every chunk
            let totalErrorSize = component.get("v.totalErrorSize");
            totalErrorSize += response.errorSize;
            component.set("v.totalErrorSize", totalErrorSize);

            // If chunk has failed records, added failed record info to csv file
            if (response.errorSize > 0) {
                let csvFileToFailedRecords = component.get("v.csvFileToFailedRecords");
                csvFileToFailedRecords += response.CSVFileToFailedRecords;
                component.set("v.csvFileToFailedRecords", csvFileToFailedRecords);
            }

            // After all data is processed by the system , the system will download failed record CSV file
            if (totalRowCount === processedRowCount) {
                if (totalErrorSize > 0) {
                    console.log(component.get("v.csvFileToFailedRecords"));
                    helper.downloadCSVFileToFailedRecords(component.get("v.csvFileToFailedRecords"));
                }
            }

            loadEvent.reportSuccess(response.successSize);
            loadEvent.reportError(response.errorSize);
            loadEvent.resume();
        }, function (error) {
            console.log(JSON.stringify(error));
            component.set("v.isLoading", false);
            loadEvent.reportError(data.length);
            loadEvent.resume();
        });
    },
    onDataLoadComplete: function (component, event, helper) {
        const loadEvent = event.getParams();
        loadEvent.resume(); // done signal
    },

    onCsvFileUploaded: function (component, event, helper) {
        const fileInfo = event.getParams();
        const totalRowCount = fileInfo.rowCount || 0;
        component.set("v.totalRowCount", totalRowCount);
    },

    downloadSampleFile: function (component, event, helper) {
        const sampleFileContent =
            `Müşteri Kodu;Dönem;Brüt Ciro;Toplam kazanç
38231;FY20Q1;1000,34;2000,56
85228;FY20Q1;1018,45;2018,34
85274;FY20Q1;1019,45;2019,34
85299;FY20Q1;1020,67;2020,32
85388;FY20Q1;1021,23;2021,0
86078;FY20Q1;1022,1;2022,12
86664;FY20Q1;1023,2;2023,12
86695;FY20Q1;1024,4;2024,2
86721;FY20Q1;1025,67;2025,3
86753;FY20Q1;1026,67;2026,6`;
        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURI(sampleFileContent);
        hiddenElement.target = '_self';
        hiddenElement.download = 'örnek_karlılık.csv';
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    },

    openBulkDeleteDialog: function (component, event, helper) {
        component.set("v.isBulkProfitabilityDeleteDialogOpen", true);
    }

});