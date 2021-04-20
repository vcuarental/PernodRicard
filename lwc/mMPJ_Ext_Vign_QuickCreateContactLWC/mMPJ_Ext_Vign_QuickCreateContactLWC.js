import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import getSalesforceConfiguration from '@salesforce/apex/MMPJ_Ext_Vign_Quick_Create_contact_ctrl.getSalesforceConfiguration';
import quickCreateContact from '@salesforce/apex/MMPJ_Ext_Vign_Quick_Create_contact_ctrl.quickCreateContact';
import searchForUser from '@salesforce/apex/MMPJ_Ext_Vign_Quick_Create_contact_ctrl.searchForUser';

import labelSave from '@salesforce/label/c.MMPJ_Ext_Vign_QCC_CreateContact';
import labelCancel from '@salesforce/label/c.MMPJ_Ext_Vign_QCC_Cancel';
import labelLoading from '@salesforce/label/c.MMPJ_Ext_Vign_QCC_LoadingTitle';
import labelSuccessTitle from '@salesforce/label/c.MMPJ_Ext_Vign_QCC_SuccessTitle';
import labelSuccess from '@salesforce/label/c.MMPJ_Ext_Vign_QCC_Success';
import labelErrorTitle from '@salesforce/label/c.MMPJ_Ext_Vign_QCC_ErrorTitle';
import labelError from '@salesforce/label/c.MMPJ_Ext_Vign_QCC_Error1';
import labelUserSearchPlaceholder from '@salesforce/label/c.MMPJ_Ext_Vign_QCC_UserSearchPlaceholder';
import labelNoUserSelected from '@salesforce/label/c.MMPJ_Ext_Vign_QCC_NoUserSelected';
import labelErrorMainContact from '@salesforce/label/c.MMPJ_Ext_Vign_QCC_ErrorMainContact';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import SEGMENTATION_FIELD from '@salesforce/schema/MMPJ_Ext_Vign_Societe__c.MMPJ_Ext_Vign_Societe_Segmentation__c';

const densityValues = {
    COMFY: 'comfy',
    COMPACT: 'compact',
    AUTO: 'auto',
};

export default class MMPJ_Ext_Vign_QuickCreateContactLWC extends NavigationMixin( LightningElement ) {
    /**
     * Specifies record Id (Id de Société)
     * @type {string}
     */
    @api recordId;

    @track _loading = true;
    @track recordTypeId;
    @track _density = densityValues.COMPACT;
    @track _innerHeight = 0;
    @track _displayTitle = false;
    @track _displayFunction = false;
    @track _selectedOwners = [];
    @track _ownerErrors = [];
    @track _societe = {};

    _contactLoaded = false;
    _societeContactLoaded = false;
    _firstLoad = true;
    _loadError = false;
    _labelSave = labelSave;
    _labelCancel = labelCancel;
    _labelLoading = labelLoading;
    _labelOwnerPlaceholder = labelUserSearchPlaceholder;
    _labelNoOwnerSelected = labelNoUserSelected;
    _labelErrorMainContact = labelErrorMainContact;
    _loadedPending = false;

    get computedContentStyles() {
        return `height: ${this._innerHeight}px; min-height: 480px; overflow-y: auto !important`;
    }

    get computedTitleDisabled() {
        return !this._displayTitle;
    }

    get computedFunctionDisabled() {
        return !this._displayFunction;
    }

    get computedLabelOwner() {
        return this.contactObjectInfo.data.fields.OwnerId.label || '-';
    }

    get computedSegmentation() {
        return getFieldValue(this.societe.data, SEGMENTATION_FIELD) || '';
    }

    @wire(getSalesforceConfiguration)
    wiredSalesforceConfiguration(value) {
        this.handleSalesforceLoadConfig(value);
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ SEGMENTATION_FIELD ] }) societe;

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT }) contactObjectInfo;

    connectedCallback() {
        const availableHeight = window.innerHeight || 1080;
        if (availableHeight < 640) {
            this._innerHeight = (availableHeight * 75 / 100).toFixed(0);
        } else {
            this._innerHeight = (availableHeight * 60 / 100).toFixed(0);
        }
    }

    handleSalesforceLoadConfig(value) {
        if(!value.data) {
            return;
        }
        const { displayTitle, displayFunction, contactRecordTypeId, owner } = JSON.parse(value.data);
        this.recordTypeId = contactRecordTypeId;
        this._displayTitle = displayTitle;
        this._displayFunction = displayFunction;
        this._selectedOwners.push(owner);
    }

    handleCreateContact() {
        const contactRecordEditForm = this.template.querySelector('lightning-record-edit-form.contact-form');
        if (!contactRecordEditForm) {
            return;
        }
        this.validateOwnerInput();
        if ( this._ownerErrors.length ) {
            return;
        }
        this._loading = true;
        contactRecordEditForm.submit();
    }

    handleOnLoadContact(event) {
        event.stopPropagation();
        this._contactLoaded = true;
        this.handleLoad();
        // console.log(event.detail.record);
        // console.log(event.detail.objectInfos);

        // const lookup = this.template.querySelector('lightning-lookup');
        // lookup.record = event.detail.record;
        // lookup.objectInfos = event.detail.objectInfos;
    }

    handleOnLoadSocieteContact(event) {
        event.stopPropagation();
        this._societeContactLoaded = true;
        this.handleLoad();
    }

    handleLoad() {
        if (!this._contactLoaded || !this._societeContactLoaded) {
            return;
        }

        if (this._firstLoad) {
            this._loading = false;
            this._firstLoad = false;
        }
    }

    handleOnErrorContact(event) {
        event.stopPropagation();
        this._loading = false;
        if (this._firstLoad) {
            this._loadError = true;
        } else {
            this.handleShowError();
        }
    }

    handleOnSuccessContact(event) {
        event.stopPropagation();

        this.template.querySelectorAll('lightning-messages').forEach(lMsg => {
            lMsg.setError(null);
        });

        this._loadedPending = true;
        const inputTitre = this.template.querySelector('lightning-input-field.inputSocieteContactTitre');
        const inputFonction = this.template.querySelector('lightning-input-field.inputSocieteContactFonction');
        const inputEspacePerso = this.template.querySelector('lightning-input-field.inputSocieteContactEspacePerso');
        const inputIsPrincipal = this.template.querySelector('lightning-input-field.inputSocieteContactIsPrincipal');
        const selectedOwnerId = this._selectedOwners.length > 0 ? this._selectedOwners[0].id : '';
        quickCreateContact({
            contactId: event.detail.id,
            societeId: this.recordId,
            fonction: inputFonction.value,
            titre: inputTitre.value,
            espacePerso: inputEspacePerso.value,
            contactPrincipal: inputIsPrincipal.value,
            ownerId: selectedOwnerId
        }).then((result) => {
            this._loading = false;
            if (result && result.indexOf('OK:') > -1) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        "title": labelSuccessTitle,
                        "message": labelSuccess,
                        "variant": "success"
                    })
                );
                const _self = this;
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    // then redirect
                    _self[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: _self.recordId,
                            actionName: 'view',
                        },
                    });
                }, 250);
            } else {
                if (result.indexOf('FAILED:') === 0) {
                    const rawMessage = result.substring(7);
                    const messages = rawMessage.split(':');
                    if (messages.length === 6) {
                        // console.log('-->1');
                        // console.log('-->1.5 : ' + messages[2].startsWith(' DUPLICATE_VALUE') + '-' + messages[3].startsWith(' MMPJ_Ext_Vign_Unicite__c'));
                        if (messages[2].startsWith(' DUPLICATE_VALUE') && messages[3].startsWith(' MMPJ_Ext_Vign_Unicite__c')) {
                            this.handleShowError(this._labelErrorMainContact);
                            return;
                        }
                    }
                }
                this.handleShowError();
            }
        }).catch(() => {
            this._loading = false;
            this.handleShowError();
        });
    }

    handleShowError(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                "title": labelErrorTitle,
                "message": message || labelError,
                "variant": "error"
            })
        );
    }

    handleSelectUser(event) {
        const selection = event.target.getSelection();
        this._selectedOwners = selection;
        this.validateOwnerInput();
    }

    handleSearchUser(event) {
        const target = event.target;
        searchForUser(event.detail)
        .then(results => {
            target.setSearchResults(results);
        })
        .catch(error => {
            this.handleShowError();
        });
    }

    validateOwnerInput () {
        const ownerErrors = [];
        if ( this._selectedOwners.length === 0 ) {
            ownerErrors.push( {
                id: 'owner-err-1',
                message: this._labelNoOwnerSelected
            } )
        }
        this._ownerErrors = ownerErrors;
    }
}