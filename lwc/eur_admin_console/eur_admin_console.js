import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import countAccountsToForceEmptyPVA from '@salesforce/apex/EUR_CRM_AdminConsoleLwcController.countAccountsToForceEmptyPVA';
import runUpdateAccountsForceEmptyPVA from '@salesforce/apex/EUR_CRM_AdminConsoleLwcController.runUpdateAccountsForceEmptyPVA';

import USER_ID from '@salesforce/user/Id';
import USER_AFFILIATE_CODE_PICKLIST_FIELD from '@salesforce/schema/User.EUR_CRM_Affiliate_Code_Picklist__c';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class Eur_admin_console extends LightningElement {

    //private variables
    _error;
    _options;
    _countryCode;
    _showModal;
    _confirmationMessage;
    _showSpinner = false;

    //labels
    labels = {
        modal : {
            title : 'Confirmation',
            confirm : 'Yes',
            cancel : 'Cancel',
        },
        confirmationMessage: 'There are {0} Accounts (EU) of {1} country for which Force EmptyPVA field will be set to TRUE. Are you sure you want to proceed?',
        picklist : {
            countryCode : 'Country Code',
            placeholder : 'Select country code'
        },
        cleanButton : {
            label : 'Accounts Force EmptyPVA'
        },
        errorMessage : {
            AssignCountryCode : 'Assign some country code to current User Affiliate Code Picklist',
            NoResponse : 'No response from getRecord'
        } ,
        tabs : {
            EmptyPvaScreen : 'Empty PVA Screen'
        },
        toasts : {
            successRun : {
                title : 'Batch is started' ,
                message : 'Batch to update Accounts Force EmptyPVA is started. You will receive an email message after batch finish.',
                variant : 'success'
            },
            alreadyLaunched: {
                title : 'Already launched',
                message : 'Batch now proceeding records',
                variant : 'warning',
            },
            specifyCountry : {
                title : 'Choose country code',
                message : 'Please choose country code from picklist',
                variant : 'error'

            },
            nothingToUpdate : {
                title : 'No Records',
                message : 'No Account to update Force EmptyPVA for {0}',
                variant : 'warning'
            },
        }
    }


    //wires
    @wire(getRecord, { recordId: USER_ID , fields: USER_AFFILIATE_CODE_PICKLIST_FIELD})
    wiredUser({data, error}) {
        if (data) {
            this.setData(data);
            if (!this.options) {
                this.error = this.labels.errorMessage.AssignCountryCode;
            }
        } else if (error) {
            this.error = error;
        }
    }


    //event handlers
    showConfirmation() {
        if (!this._countryCode) {
            this.showSpecifyCountry();
            return;
        }
        this.showSpinner();
        countAccountsToForceEmptyPVA({countryCode: this._countryCode})
            .then(count => {
                this.hideSpinner();
                if (count == 0) {
                    this.showNothingToUpdate();
                    return;
                }
                this.confirmationMessage = count;
                this.showModal()
            })
            .catch(error => {
                this.showError(error);
                console.error(error);
            })
            .finally(() => { this.hideSpinner(); });
    }

    updateAccountsForceEmptyPVA() {
        if (!this._countryCode) {
            this.showSpecifyCountry();
            return;
        }
        runUpdateAccountsForceEmptyPVA({countryCode: this._countryCode})
            .then((response) => {
                if (response.includes('Launched')) {
                    this.showAlreadyLaunched();
                } else {
                    this.showSuccess();
                }
            })
            .catch(error => {console.error(error);})
            .finally(() => {this.hideModal();});
    }

    handleChange(event) {
        this._countryCode = event.detail.value;
    }


    //getters and setters
    get confirmationMessage() {
        if (!this._confirmationMessage) {
            return this.labels.confirmationMessage.replace(/\{0\}|\{1\}/g, '');
        }
        return this._confirmationMessage;
    }

    set confirmationMessage(message) {
        this._confirmationMessage = this.labels.confirmationMessage.replace('{0}', message).replace('{1}', this._countryCode);
    }

    get error() {
        return this._error;
    }

    set error(error) {
        this._error = this.getErrorMessage(error);
    }

    getErrorMessage(error) {
        let message = '';
        if (typeof error === 'string') {
            message = error;
        }
        else if (Array.isArray(error.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            message = error.body.message;
        }
        return message;
    }

    get options() {
        return this._options;
    }

    set options(data) {
        if (!data) { return []; }
        this._options = [];
        data.trim().split(/[,; ]/)
            .filter(item => { if(item) return item; })
            .forEach(item => { this._options.push({label: item, value: item})});
    }


    //helper methods
    showSpinner() {
        this._showSpinner = true;
    }

    hideSpinner() {
        this._showSpinner = false;
    }

    showModal() {
        this._showModal = true;
    }

    hideModal() {
        this._showModal = false;
    }

    setData(data) {
        this.options = getFieldValue(data, USER_AFFILIATE_CODE_PICKLIST_FIELD);
    }


    //toasts
    showSuccess() {
        this.showToast( this.labels.toasts.successRun );
    }

    showAlreadyLaunched() {
        this.showToast( this.labels.toasts.alreadyLaunched );
    }

    showSpecifyCountry() {
        this.showToast( this.labels.toasts.specifyCountry );
    }

    showNothingToUpdate() {
        const toast = {...this.labels.toasts.nothingToUpdate, message: this.labels.toasts.nothingToUpdate.message.replace('{0}', this._countryCode)};
        this.showToast( toast );
    }

    showError(error) {
        this.showToast({title: 'Error', message: this.getErrorMessage(error), variant: 'error'});
    }

    showToast(data) {
        this.dispatchEvent(new ShowToastEvent(data));
    }
}