/**
 * Created by osman on 29.12.2020.
 */

({
    doInit: function (component, event, helper) {
        component.set("v.columns", [
            {label: 'Müşteri Kodu', fieldName: 'AccountCode', type: 'text'},
            {label: 'Müşteri İsmi', fieldName: 'AccountName', type: 'text'},
            {label: 'CR12-JD', fieldName: 'CR12JD', type: 'String'},
            {label: 'BFW-JWRL', fieldName: 'BFWJWRL', type: 'String'},
            {label: 'Pass-Bells', fieldName: 'PassBells', type: 'String'},
            {label: 'Wybo Çapraz', fieldName: 'Wybo', type: 'String'},
            {label: 'Abs Çapraz', fieldName: 'Abs', type: 'String'}
        ]);
    },


    onDataPartLoad: function (component, event, helper) {

        const loadEvent = event.getParams();
        const data = loadEvent.data;
        const errors = loadEvent.errors;
        const utility = component.find("utility");

        const crossComplianceRecordsToUpsert = data;
        crossComplianceRecordsToUpsert.forEach(item => {
            item.CR12JD = item.CR12JD === "1";
            item.BFWJWRL = item.BFWJWRL === "1";
            item.PassBells = item.PassBells === "1";
            item.Wybo = item.Wybo === "1";
            item.Abs = item.Abs === "1";
        });

        component.set("v.isLoading", true);
        utility.callAction(component, 'c.upsertCrossComplianceItems', {
            crossComplianceRecords: crossComplianceRecordsToUpsert
        }).then(data => {

            component.set("v.isLoading", false);
            const totalRowCount = component.get("v.totalRowCount");

            // calculated processed count
            let processedRowCount = component.get("v.processedRowCount");
            processedRowCount += crossComplianceRecordsToUpsert.length;
            component.set("v.processedRowCount", processedRowCount);

            // calculated total error size by every chunk
            let totalErrorSize = component.get("v.totalErrorSize");
            totalErrorSize += data.errorSize;
            component.set("v.totalErrorSize", totalErrorSize);

            // If chunk has failed records, added failed record info to csv file
            if (data.errorSize > 0) {
                let csvFileToFailedRecords = component.get("v.csvFileToFailedRecords");
                csvFileToFailedRecords += data.CSVFileToFailedRecords;
                component.set("v.csvFileToFailedRecords", csvFileToFailedRecords);
            }

            // After all data is processed by the system , the system will download failed record CSV file
            if (totalRowCount === processedRowCount) {
                if (totalErrorSize > 0) {
                    helper.downloadCSVFileToFailedRecords(component.get("v.csvFileToFailedRecords"));
                }
            }

            loadEvent.reportSuccess(data.successSize);
            loadEvent.reportError(data.errorSize);
            loadEvent.resume();

        }).catch(error => {
            let errorMessage = error.message || JSON.stringify(error) || '';
            utility.showErrorToast("Hata!", errorMessage, 2000);
            component.set("v.isLoading", false);
            loadEvent.reportError(data.length);
            loadEvent.resume();
        })

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
            `Müşteri Kodu,Musteri Adi,CR12-JD,BFW-JWRL,Pass-Bells,Wybo Çapraz,Abs Çapraz
            2772,ÇAĞDAŞ BÜFE / ÇAĞDAŞ SENEK,1,1,1,1,1
            12061,ÇAĞIN SÜPERMARKET / HASAN TAVŞAN,1,1,1,1,1
            38011,SEKER MARKET VE IHTIYAÇ MAD.TIC.LTD.STI. - ŞEKER MARKET GIDA ŞTİ,1,1,1,1,1
            38033,ONUR İNAN STOP BÜFE,1,1,1,1,1
            38034,ESER KURUYEMIS GID.INS.TAS.PEY.BIL.TEM.LTD.STI. - ESER KURUYEMİŞ ŞTİ,1,1,1,1,1
            38049,CEYHAN ŞEN ŞEN MARKET,1,1,1,1,1
            38062,MUSTAFA SERDAR HAKTAR AYTAÇ ÇEREZ TEKEL BAYİİ,1,1,1,1,1`;
        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURI(sampleFileContent);
        hiddenElement.target = '_self';
        hiddenElement.download = 'örnek_çapraz_bulunurluk.csv';
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    },

});