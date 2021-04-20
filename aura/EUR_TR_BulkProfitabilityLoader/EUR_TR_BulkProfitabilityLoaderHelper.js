/**
 * Created by aliku on 12/26/2020.
 */

({
    parsePeriodText: function (component, value) {
        const result = {
            year: undefined,
            quarter: undefined
        }
        if (typeof value != "undefined") {
            let period = String(value);
            while (period.includes(" ")) {
                period = period.replace(" ", "").trim();
            }
            if (period.length === 6) {
                result.year = period.substr(2, 2);
                result.quarter = period.substr(4, 2);
            }
        }
        return result;
    },


    downloadCSVFileToFailedRecords: function (data) {

        const csvHeader = `Müşteri Kodu,Dönem,Brüt Ciro,Toplam kazanç,Hata Detayı\n`;
        const csvFile = `${'\uFEFF' + csvHeader + data}`;
        const CSVContent = encodeURI(csvFile);

        const hiddenDownloadCSVFileElement = document.createElement('a');
        hiddenDownloadCSVFileElement.href = ['data:text/csv;charset=utf-8', CSVContent].join(',');
        hiddenDownloadCSVFileElement.target = '_self';
        hiddenDownloadCSVFileElement.download = 'Hata Karlılık Kayıtları';
        document.body.appendChild(hiddenDownloadCSVFileElement);
        hiddenDownloadCSVFileElement.click();
        document.body.removeChild(hiddenDownloadCSVFileElement);

    }


});