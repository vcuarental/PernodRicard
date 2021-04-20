/**
 * Created by osman on 29.12.2020.
 */

({
    downloadCSVFileToFailedRecords: function (data) {

        const csvHeader = `Müşteri Kodu,Müşteri İsmi,CR12-JD,BFW-JWRL,Pass-Bells,Wybo Çapraz,Abs Çapraz,Hata Detayı\n`;
        const csvFile = `${'\uFEFF' + csvHeader + data}`;
        const CSVContent = encodeURI(csvFile);

        const hiddenDownloadCSVFileElement = document.createElement('a');
        hiddenDownloadCSVFileElement.href = ['data:text/csv;charset=utf-8', CSVContent].join(',');
        hiddenDownloadCSVFileElement.target = '_self';
        hiddenDownloadCSVFileElement.download = 'Hatalı Çapraz Bulunurluk Kayıtları';
        document.body.appendChild(hiddenDownloadCSVFileElement);
        hiddenDownloadCSVFileElement.click();
        document.body.removeChild(hiddenDownloadCSVFileElement);

    }
});