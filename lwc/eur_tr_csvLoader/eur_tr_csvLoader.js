/**
 * Created by aliku on 9/21/2020.
 */

import {api, track, LightningElement} from 'lwc';
import {loadScript, loadStyle} from 'lightning/platformResourceLoader';
import scriptPapaParse from '@salesforce/resourceUrl/EUR_TR_PapaParse_5_0_2';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {updateRecord} from 'lightning/uiRecordApi';

export default class EurTrCsvLoader extends LightningElement {
    @api accept = ['.csv']
    @api header
    @api delimiter
    @api columns
    @api disabled
    @api chunkSize = 10
    @api ignoreErrorLine = false
    @api loadingMessage = "İşlem devam ediyor lütfen sekmeyi kapatmayın"
    @api abortedMessage = "İşlem sonlandırıldı."
    @api completedMessage = "İşlem başarılı şekilde tamamlandı"
    @api fileInputLabel = ""
    @track preview = 10
    @track previewLoading = false
    @track previewData = []
    @track previewErrorData = []
    @track previewErrorColumns = [
        {label: "Satır", fieldName: "row", fixedWidth: 80}
        , {label: "Tipi", fieldName: "type"}
        , {label: "Kodu", fieldName: "code"}
        , {label: "Mesaj", fieldName: "message"}
    ]
    @track showPreviewErrors
    @track showLoadingModal
    @track successCount = 0
    @track failedCount = 0
    @track jobState
    @track rowCount
    selectedFile
    scriptsLoaded = false
    currentParser
    JobStates = {
        Running: "Running",
        Aborted: "Aborted",
        Completed: "Completed",
    }

    @api get isRunning() {
        return this.jobState === this.JobStates.Running;
    }

    @api get isCompleted() {
        return this.jobState === this.JobStates.Completed;
    }

    @api get isAborted() {
        return this.jobState === this.JobStates.Aborted;
    }

    @api get abortButtonDisabled() {
        return this.jobState !== this.JobStates.Running;
    }

    @api get loadButtonDisabled() {
        return this.selectedFile == null || this.previewLoading;
    }

    @api get showPreviewErrorsButtonVisible() {
        return this.previewErrorData.length > 0;
    }

    @api get previewErrorsButtonText() {
        return `${this.previewErrorData.length} hatalı satır`;
    }

    @api get componentDisabled() {
        return this.scriptsLoaded === false || this.disabled === true;
    }

    renderedCallback() {
        const self = this;
        loadScript(this, scriptPapaParse + '/papaparse.js')
            .then(function () {
                self.scriptsLoaded = true;
            }, function (error) {
                console.error(error);
            });
    }

    abortCurrentParser() {
        let isAborted = confirm('İşlemi iptal etmek istediğinize emin misiniz?');

        if (this.currentParser != null && isAborted) {
            this.currentParser.abort();
            this.jobState = this.JobStates.Aborted;
            this.dispatchEvent(new ShowToastEvent({
                title: 'İptal Edildi',
                message: 'İşleminiz iptal edilmiştir.',
                variant: 'error',
                mode: 'dismissable'
            }));

            this.refreshView();
        }
    }

    handleLoadButtonClick(event) {
        if (this.selectedFile == null)
            return;

        const self = this;
        self.showLoadingModal = true;
        self.jobState = self.JobStates.Running;
        self.successCount = 0;
        self.failedCount = 0;
        let chunkData = [];
        let errorsData = [];
        let headerSkipped = false;
        const config = {
            skipEmptyLines: true,
            header: false,
            delimiter: self.delimiter,
            step: function (results, parser) {
                self.currentParser = parser;

                if (self.header === true && headerSkipped === false) {
                    headerSkipped = true
                    return
                }
                const errors = self.getRowErrorFromParserResult(results);
                if (errors.length > 0) {
                    if (self.ignoreErrorLine === true) {
                        return
                    }
                    errorsData.push(errors);
                }

                const rowData = self.getSingleRowObjectFromParserResult(self, results);

                if (rowData) {
                    chunkData.push(rowData);
                } else {
                    return;
                }

                if (chunkData.length >= self.chunkSize) {
                    parser.pause();
                    self.dispatchEvent(new CustomEvent('data', {
                        detail: {
                            data: chunkData,
                            errors: errorsData,
                            resume: function () {
                                self.currentParser.resume();
                            }, abort: function () {
                                self.currentParser.abort();
                                self.jobState = self.JobStates.Aborted;
                            }, reportSuccess: function (count) {
                                self.successCount += count;
                            }, reportError: function (count) {
                                self.failedCount += count;
                            }, successCount: function () {
                                return self.successCount;
                            }, failedCount: function () {
                                return self.failedCount;
                            }
                        }
                    }));
                    chunkData = [];
                    errorsData = [];
                }
            },
            complete: function (results, file) {
                if (chunkData.length > 0) {
                    self.dispatchEvent(new CustomEvent('data', {
                        detail: {
                            data: chunkData,
                            errors: errorsData,
                            resume: function () {
                                self.jobState = self.JobStates.Completed;
                            },
                            abort: function () {

                            }, reportSuccess: function (count) {
                                self.successCount += count;
                            }, reportError: function (count) {
                                self.failedCount += count;
                            }, successCount: function () {
                                return self.successCount;
                            }, failedCount: function () {
                                return self.failedCount;
                            }
                        }
                    }));
                }

                self.dispatchEvent(new CustomEvent('complete', {
                    detail: {
                        data: null,
                        errors: null,
                        resume: function () {
                            self.jobState = self.JobStates.Completed;
                        },
                        abort: function () {

                        }, reportSuccess: function (count) {
                            self.successCount += count;
                        }, reportError: function (count) {
                            self.failedCount += count;
                        }, successCount: function () {
                            return self.successCount;
                        }, failedCount: function () {
                            return self.failedCount;
                        }
                    }
                }));
            }
        }
        Papa.parse(this.selectedFile, config);
    }

    refreshView() {
        eval("$A.get('e.force:refreshView').fire()");
    }

    handleFileSelected(event) {
        const self = this;

        self.selectedFile = event.detail.files[0]; //single file allowed
        let rowCount = 0;
        const config = {
            skipEmptyLines: true,
            header: self.header,
            delimiter: self.delimiter,
            step: function (results, parser) {
                if (!self.checkIsRowEmpty(self, results)) {
                    rowCount++;
                }
            },
            complete: function (results) {
                self.rowCount = rowCount;
                self.dispatchEvent(new CustomEvent('csvfileloaded', {
                        detail: {
                            isLoaded: true,
                            rowCount: rowCount,
                            fileName: self.selectedFile.name
                        }
                    }
                ));
            }
        }

        Papa.parse(this.selectedFile, config); // to get row count
        self.reloadPreviewData();
    }

    handlePreviewChange(event) {
        const selectedItemValue = event.detail.value;
        switch (selectedItemValue) {
            case "Preview10":
                this.preview = 10;
                break;
            case "Preview20":
                this.preview = 20;
                break;
            case "Preview50":
                this.preview = 50;
                break;
            case "Preview100":
                this.preview = 100;
                break;
            case "Preview200":
                this.preview = 200;
                break;
            case "Preview500":
                this.preview = 500;
                break;
            case "Preview1000":
                this.preview = 1000;
                break;
        }
        this.reloadPreviewData();
    }

    @api reloadPreviewData() {
        if (this.selectedFile == null)
            return

        const self = this;
        self.previewLoading = true;
        const config = {
            skipEmptyLines: true,
            preview: self.preview,
            header: false,
            delimiter: self.delimiter,
            columns: self.columns.map(x => x.fieldName),
            complete: function (results, file) {
                if (self.header === true) {
                    results.data.splice(0, 1);
                }
                self.previewData = self.getRowObjectsFromParserResult(self, results);
                self.previewErrorData = self.getRowErrorFromParserResult(results);
                self.previewLoading = false;
            }, error: function () {
                self.previewLoading = false;
            }
        }
        Papa.parse(this.selectedFile, config);
    }

    @api enrichPreviewData(callback) {
        if (typeof callback === "function") {
            if (callback(this.previewData) === true) {
                this.previewData = [...this.previewData];
            }
        }
    }

    getRowObjectsFromParserResult(self, results) {
        const rows = [];
        for (let rawData of results.data) {
            const row = {};
            if (self.columns != null) {
                for (let i = 0; i < self.columns.length; i++) {
                    let column = self.columns[i];
                    if (rawData.length >= i) {
                        row[column.fieldName] = rawData[i];
                    }
                }
            }
            rows.push(row);
        }
        return rows
    }

    getSingleRowObjectFromParserResult(self, results) {
        const row = {};
        if (self.columns != null) {
            for (let i = 0; i < self.columns.length; i++) {
                let column = self.columns[i];

                if (self.checkIsRowEmpty(self, results)) {
                    return;
                } else if (results.data.length >= i) {
                    row[column.fieldName] = results.data[i];
                }
            }
        }
        return row;
    }

    getRowErrorFromParserResult(results) {
        const response = [];
        if (results.errors != null && results.errors.length > 0) {
            for (let item of results.errors) {
                response.push({
                    row: item.row,
                    code: item.code,
                    type: item.type,
                    message: item.message
                });
            }
        }
        return response;
    }

    checkIsRowEmpty(self, results) {
        const columnSize = self.columns.length;
        const keyLength = Object.keys(results.data).length;
        const constructor = results.data.constructor;

        if (keyLength !== columnSize && constructor !== Object) {
            return true;
        } else if (keyLength === 1 && constructor === Array && !results.data[0]) {
            return true;
        } else {
            return false;
        }
    }

    handleShowPreviewErrors() {
        this.showPreviewErrors = true;
    }

    handleHidePreviewErrors() {
        this.showPreviewErrors = false;
    }

    handleCloseLoadingModal() {
        this.showLoadingModal = false;
        this.refreshView();
    }

    handleToggleHeader() {
        this.header = !this.header;
    }

    handleToggleIgnoreErrorLine() {
        this.ignoreErrorLine = !this.ignoreErrorLine;
    }

    connectedCallback() {
        this.header = true;
    }
}