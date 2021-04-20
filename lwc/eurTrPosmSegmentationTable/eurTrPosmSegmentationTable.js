/**
 * Created by osman on 30.10.2020.
 */

import {LightningElement, track, api} from 'lwc';
import getPOSMSegmentationDefinitions
    from '@salesforce/apex/EUR_TR_POSMDefinitionController.getPOSMSegmentationDefinitions';
import getPicklistValues from '@salesforce/apex/EUR_TR_POSMDefinitionController.getPicklistValues';
import {deleteRecord} from 'lightning/uiRecordApi';
import {reduceErrors, showToastMessage} from "c/eur_tr_util";
import downloadSegmentationDefinitions
    from '@salesforce/apex/EUR_TR_POSMDefinitionController.downloadSegmentationDefinitions';

const ERROR_VARIANT = "error";
const CSV_CONTENT_TYPE = 'data:text/csv;charset=utf-8';
const DOWNLOADED_FILE_NAME = 'Segmentasyon Tanımları';
const actions = [
    {label: 'Güncelle', name: 'update'},
    {label: 'Sil', name: 'delete'},
    {label: 'Kopyasını Oluştur', name: 'clone'},
];

const COLUMNS = [
    {label: 'Ürün Tipi', fieldName: 'EUR_TR_SegmentationPOSMTypes__c'},
    {label: 'Ürün Alt Tipi', fieldName: 'EUR_TR_SegmentationPOSMSubTypes__c'},
    {label: 'Kanal', fieldName: 'EUR_TR_Channel__c'},
    {label: 'Grup', fieldName: 'EUR_TR_Group__c'},
    {label: 'Sınıf', fieldName: 'EUR_TR_Class__c'},
    {label: 'Alt Tipi', fieldName: 'EUR_TR_SubType__c'},
    {label: 'Sponsorluk Durumu', fieldName: 'EUR_TR_SponsorshipStatus__c'},
    {label: 'Büyüklük', fieldName: 'EUR_TR_Range__c'},
    {label: 'Tipi', fieldName: 'EUR_TR_Type__c'},
    {label: 'OT Pros', fieldName: 'EUR_TR_OTPros__c'},
    {label: 'OT Tipi', fieldName: 'EUR_TR_OTType__c'},
    {label: 'ONTB', fieldName: 'EUR_TR_ONTB__c'},
    {label: 'Aktivite Puanı', fieldName: 'EUR_TR_ActivityPoints__c'},
    {label: 'OT Sponsorluk', fieldName: 'EUR_TR_OTSponsorship__c'},
    {
        type: 'action',
        typeAttributes: {rowActions: actions},
    },
];


export default class EurTrPosmSegmentationTable extends LightningElement {

    @track data = [];
    columns = COLUMNS;
    @track wiredSegmentationResult;
    selectedRow;
    isLoading = false;
    rowLimit = 10;
    _totalRow;
    rowOffSet = 1;
    @track
    selectedPOSMType = "All";
    POSMTypeOptions;
    @api recordId;
    isDisabled = false;
    visibility = '';
    isDownloadButtonVisible = true;


    connectedCallback() {
        if (this.recordId) {
            this.columns.splice(14, 1);
            this.visibility = 'slds-hide';
            this.isDownloadButtonVisible = false;
        }
        this.loadData();
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        this.selectedRow = event.detail.row;
        switch (actionName) {
            case 'update':
                this.sendUpdateRowEvent();
                break;
            case 'delete':
                this.deleteRow();
                break;
            case 'clone':
                this.sendCloneRowEvent();
                break;
            default:
        }
    }

    deleteRow() {
        const isDeleted = confirm('Kaydı silmek istediğiniz emin misiniz ?');
        if (isDeleted) {
            this.isLoading = true;
            deleteRecord(this.selectedRow.Id)
                .then(() => {
                    showToastMessage({
                        caller: this,
                        title: "Silme İşlemi Başarılı",
                        message: "Silme işlemi başarılı bir şekilde tamamlandı."
                    });
                    this.isLoading = false;
                    this.refreshTable();
                }).catch(error => {
                this.showError(error);
                this.isLoading = false;
            });
        }
    }

    sendCloneRowEvent() {
        const cloneRowEvent = new CustomEvent('clone', {
            detail: {
                'selectedRow': this.selectedRow
            }
        });
        this.dispatchEvent(cloneRowEvent);
    }

    sendUpdateRowEvent() {
        const updateRowEvent = new CustomEvent('update', {
            detail: {
                'selectedRow': this.selectedRow
            }
        });
        this.dispatchEvent(updateRowEvent);
    }

    @api
    loadData() {

        this.isLoading = true;
        const picklistPromise = getPicklistValues();
        const segmentationDefinitionsPromise = getPOSMSegmentationDefinitions({
            "limitSize": this.rowLimit,
            "offset": this.rowOffSet,
            "selectedPOSMType": this.selectedPOSMType,
            "POSMRecordId": this.recordId
        });
        Promise.all([picklistPromise, segmentationDefinitionsPromise]).then(result => {

            const picklistData = result[0];
            const segmentationData = result[1];

            this.data = segmentationData.segmentations;
            this._totalRow = segmentationData.totalRow;

            const POSMTypePicklistField = picklistData.find(item => {
                return item.fieldName === 'EUR_TR_SegmentationPOSMTypes__c';
            })
            this.POSMTypeOptions = POSMTypePicklistField.items;

            this.isLoading = false;

        }).catch(error => {
            this.showError(error);
            this.isLoading = false;
        })


    }

    loadMoreData(event) {

        const {target} = event;
        if (this.data.length >= this._totalRow) {
            target.isLoading = false;
            return;
        } else {

            target.isLoading = true;
            getPOSMSegmentationDefinitions({
                "limitSize": this.rowLimit,
                "offset": this.rowOffSet,
                "selectedPOSMType": this.selectedPOSMType
            }).then(data => {
                const currentData = this.data;
                const newData = data.segmentations;
                if (Array.isArray(newData) && newData.length > 0) {
                    this.data = [...currentData, ...newData]
                }
                target.isLoading = false;
            }).catch(error => {
                target.isLoading = false;
                this.showError(error);
            });
        }


    }

    @api
    refreshTable() {
        const definitionTableElement = this.template.querySelector('lightning-datatable');
        definitionTableElement.isLoading = true;
        this.data = [];
        this.rowOffSet = 0;

        getPOSMSegmentationDefinitions({
            "limitSize": this.rowLimit,
            "offset": this.rowOffSet,
            "selectedPOSMType": this.selectedPOSMType
        }).then(data => {
            this.data = data.segmentations;
            this._totalRow = data.totalRow;
            definitionTableElement.isLoading = false;
        }).catch(error => {
            definitionTableElement.isLoading = false;
            this.showError(error);
        });
    }

    handlePOSMTypeChange(event) {
        this.selectedPOSMType = event.detail.value;
        this.refreshTable();
    }

    downloadSegmentationDefinitions() {

        this.isLoading = true;
        downloadSegmentationDefinitions({}).then(data => {

            const anchorElement = document.createElement('a');
            const CSVContent = encodeURI(data);
            anchorElement.href = [CSV_CONTENT_TYPE, CSVContent].join(',');
            anchorElement.target = '_self';
            anchorElement.download = DOWNLOADED_FILE_NAME;
            document.body.appendChild(anchorElement);
            anchorElement.click();
            document.body.removeChild(anchorElement);
            this.isLoading = false;

        }).catch(error => {
            this.showError(error);
            this.isLoading = false;
        })

    }

    get downloadButtonClass() {
        return this.data.length >= 1 ? '' : 'slds-hide';
    }

    showError(error) {
        const errorMessage = reduceErrors(error);
        showToastMessage({
            caller: this,
            title: "Hata",
            variant: ERROR_VARIANT,
            message: errorMessage.join('.')
        });
    }


}