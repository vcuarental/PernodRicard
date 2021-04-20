import {LightningElement} from 'lwc';
import runScript from '@salesforce/apex/EUR_CRM_MixedSyncController.runScript'
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {reduceErrors} from "c/eur_ldsUtils"

export default class EURMixedSyncPackageCreator extends LightningElement {

    //private variables
    _applicationSetups = [];
    _showSpinner = false;
    _showModal = false;


    //labels
    labels = {
        modal : {
            title : 'Confirmation',
            confirm : 'Yes',
            cancel : 'Cancel',
        },
        confirmationMessage: 'Are you sure you want to run the script and create the package?',
        picklist : {
            countryCode : 'Country Code',
            placeholder : 'Select country code'
        },
        button : {
            label : 'Create package'
        },
        errorMessage : {
            AssignCountryCode : 'Assign some country code to current User Affiliate Code Picklist',
            NoResponse : 'No response from getRecord'
        } ,
        tabs : {
            packageCreation : 'Package Creation'
        },
        toasts : {
            successRun : {
                title : 'Metadata retrieving' ,
                message : 'Package creation is started. You will receive an email when package will be finished.',
                variant : 'success'
            },
            alreadyLaunched: {
                title : 'Package is under creation',
                message : 'You will receive an email when package creation will be finished.',
                variant : 'warning',
            },
        }
    }


    showConfirmation() {
        this.showModal();
    }

    runScript() {
        this.hideModal();
        runScript()
            .then(response => {
                console.log('response ' , response);
                if (response == 'Success') {
                    this.showToast(this.labels.toasts.successRun)
                } else {
                    this.showToast(this.labels.toasts.alreadyLaunched)
                }
            })
            .catch(error => {
                this.showError(error);
                console.error('error ' , error);
            })
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

    showError(error) {
        this.showToast({title: 'Error', message: reduceErrors(error)[0], variant: 'error'});
    }

    showToast(data) {
        this.dispatchEvent(new ShowToastEvent(data));
    }
}