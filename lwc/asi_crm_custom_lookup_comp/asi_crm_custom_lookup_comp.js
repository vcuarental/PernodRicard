import { LightningElement, api, track } from 'lwc';

import getRecordList from '@salesforce/apex/ASI_CRM_CustomLookupCtrl.getRecordList';

export default class ASI_CRM_CustomLookupComp extends LightningElement {

    @api configObj = {
        'label'                  : '',
        'iconName'               : '',
        'placeholder'            : '',
        'objectName'             : '',
        'labelField'             : '',
        'sublabelField'          : '',
        'filterFieldList'        : [],
        'additionalFilterString' : '',
        'recordCount'            : 5,
        'isTriggerEvent'         : false
    };

    @api selectedRecord;
    @api selectedRecordCallback;

    @track searchKey = "";
    @track errorMessage = "";

    @track lookupRecordList = [];

    @track showSpinner = false;

    hasRendered = false;

    renderedCallback() {
        if (this.hasRendered) return;
        this.hasRendered = true;
    
        const style = document.createElement('style');
        style.innerText = `
            .input-box input {
                padding-left : 30px;
            }
        `;

        this.template.querySelector('lightning-input').appendChild(style);
    }
    
    get isSelectedRecord() {
        return this.selectedRecord && 
            Object.entries(this.selectedRecord).length !== 0 && 
            this.selectedRecord.constructor === Object;
    }

    get hasError() {
        return this.errorMessage;
    }

    get pillContainerClass() {
        return 'slds-pill-container ' + (this.isSelectedRecord ? '' : 'slds-hide');
    }

    get searchInputFieldClass() {
        return this.isSelectedRecord ? 'slds-hide' : 'slds-show';
    }

    searchRecord(event) {
        var cmp = this.template.querySelector('[data-id="lookupPanel"]');

        this.searchKey = event.target.value;
        if(this.searchKey && this.searchKey.length > 1) {
            cmp.classList.add('slds-is-open');
            cmp.classList.remove('slds-is-close');
            this.getLookupRecord(this.searchKey);
        } else {
            cmp.classList.add('slds-is-close');
            cmp.classList.remove('slds-is-open');
        }
    }

    selectRecord(event) {
        var cmp = this.template.querySelector('[data-id="lookupPanel"]');

        var lookupRecordId = event.currentTarget.dataset.id;

        var index = this.lookupRecordList.findIndex(record => record.value === lookupRecordId);

        if(index === -1)
            return;

        this.selectedRecord = this.lookupRecordList[index];
        
        cmp.classList.add('slds-is-close');
        cmp.classList.remove('slds-is-open');

        if(this.configObj.isTriggerEvent)
            this.selectedRecordCallback(this.selectedRecord);
    }

    removeSelectedRecordHandler() {
        this.selectedRecord = {};
        this.searchKey = "";

        if(this.configObj.isTriggerEvent)
            this.selectedRecordCallback(this.selectedRecord);
    }

    getLookupRecord() {
        var params = {
            'objectName'             : this.configObj.objectName,
            'labelField'             : this.configObj.labelField, 
            'sublabelField'          : this.configObj.sublabelField, 
            'filterFieldList'        : this.configObj.filterFieldList, 
            'searchKey'              : this.searchKey, 
            'additionalFilterString' : this.configObj.additionalFilterString,
            'recordCount'            : this.configObj.recordCount
        };

        this.showSpinner = true;
        this.errorMessage = "";

        getRecordList(params)
            .then(result => {
                this.lookupRecordList = result;
                this.showSpinner = false;

                if(!this.lookupRecordList || this.lookupRecordList.length === 0)
                    this.errorMessage = "No Records Found for '" + this.searchKey + "'";
            })
            .catch(error => {
                this.errorMessage = error.body.message;
                this.showSpinner = false;
            });
    }

}