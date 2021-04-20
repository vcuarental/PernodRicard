/**
 * Created by osman on 14.01.2021.
 */

import {LightningElement} from 'lwc';
import insertIncentiveRecords from '@salesforce/apex/EUR_TR_BulkIncentiveLoaderController.insertIncentiveRecords';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const TABLE_COLUMNS = [
    {label: 'Müşteri Kodu', fieldName: 'accountCode', type: 'text'},
    {label: 'Marka', fieldName: 'brand', type: 'text'},
    {label: 'Incentive Açıklaması', fieldName: 'description', type: 'text'},
    {label: 'Başlangıç Tarihi', fieldName: 'startDate', type: 'text'},
    {label: 'Bitiş Tarihi', fieldName: 'endDate', type: 'text'}
]
const DEFAULT_CHUNK_SIZE = 2000;
const IMPORT_TYPE = "fastTrack";
const ERROR_MESSAGE_TITLE = "Hata";

export default class EurTrBulkIncentiveLoader extends LightningElement {

    columns = TABLE_COLUMNS;
    errors;
    isLoading = false;
    chunkSize = DEFAULT_CHUNK_SIZE;
    importType = IMPORT_TYPE;
    totalRowCount = 0;
    processedRowCount = 0;
    totalErrorSize = 0;
    csvFileToFailedRecords = '';

    onDataPartLoad(event) {

        const loadEvent = event.detail;
        const data = loadEvent.data;
        this.isLoading = true;

        insertIncentiveRecords({
            incentiveRecords: data
        }).then(result => {

            this.processedRowCount += data.length; // calculated processed record count
            this.totalErrorSize += result.errorSize; // calculated total failed record size by every chunk

            // If chunk has failed records, added failed record info to csv file
            if (result.errorSize > 0) {
                this.csvFileToFailedRecords += result.CSVFileToFailedRecords;
            }

            // After all data is processed by the system , the system will download failed record CSV file
            if (this.totalRowCount === this.processedRowCount) {
                if (this.totalErrorSize > 0) {
                    this.downloadCSVFileToFailedRecords();
                }
            }

            loadEvent.reportSuccess(result.successSize);
            loadEvent.reportError(result.errorSize);
            loadEvent.resume();
            this.isLoading = false;

        }).catch(error => {
            let errorMessage = error.message || JSON.stringify(error) || '';
            console.log(errorMessage);
            this.showToastMessage(ERROR_MESSAGE_TITLE, errorMessage, 'error');
            loadEvent.reportError(data.length);
            loadEvent.resume();
            this.isLoading = false;
        })

    }

    onCsvFileUploaded(event) {
        const uploadEvent = event.detail;
        const totalRowCount = uploadEvent.rowCount || 0;
        this.totalRowCount = totalRowCount;
    }

    onDataLoadComplete(event) {
        const loadEvent = event.detail;
        loadEvent.resume(); // done signal
    }

    downloadSampleFile() {
        const sampleFileContent =
            `Müşteri Kodu,Marka,Incentive Açıklaması,Başlangıç Tarihi,Bitiş Tarihi
            68128,BALLANTINES,Noktaların %90’ına min noktaların %90’ına min 22.5 lt (~2.5 cs) satılması ve ekstra aktivasyon beklenmektedir.  ,1.11.2020,31.12.2020
            68128,BALLANTINES,BFW blok dizilimi + ürün anlatımı,1.11.2020,31.12.2020
            54168,BALLANTINES,Noktaların min. %60 ına  3.6 lt (~0.4 cs) satılmalıdır.,1.11.2020,31.12.2020
            148551,BALLANTINES,Aktivasyon noktalarında min. 60%’ına  7.5 lt (~0.83 cs) satılmalıdır.,1.11.2020,31.12.2020
            95693,JAMESON,SPV Bazında havuz listenin %60'ına satış gerçekleştirilmelidir.,1.11.2020,31.12.2020
            1175568,JAMESON,%100 volume hedefini gerçekleştirmek ,1.11.2020,31.12.2020
            1175568,JAMESON,Havuz Listenin %60'ında set kampanya kullanımı,1.11.2020,31.12.2020`;
        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURI(sampleFileContent);
        hiddenElement.target = '_self';
        hiddenElement.download = 'örnek_teşvik.csv';
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    }

    downloadCSVFileToFailedRecords() {

        const csvHeader = `Müşteri Kodu,Marka,Incentive Açıklaması,Başlangıç Tarihi,Bitiş Tarihi,Hata Detayı\n`;
        const csvFile = `${'\uFEFF' + csvHeader + this.csvFileToFailedRecords}`;
        const CSVContent = encodeURI(csvFile);

        const hiddenDownloadCSVFileElement = document.createElement('a');
        hiddenDownloadCSVFileElement.href = ['data:text/csv;charset=utf-8', CSVContent].join(',');
        hiddenDownloadCSVFileElement.target = '_self';
        hiddenDownloadCSVFileElement.download = 'Hatalı Incentive Kayıtları';
        document.body.appendChild(hiddenDownloadCSVFileElement);
        hiddenDownloadCSVFileElement.click();
        document.body.removeChild(hiddenDownloadCSVFileElement);

    }

    showToastMessage(title, message, variant) {
        const showToastEvent = new ShowToastEvent({
            title, message, variant
        });
        this.dispatchEvent(showToastEvent);
    }


}