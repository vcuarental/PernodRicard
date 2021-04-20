/**
 * Created by osman on 30.10.2020.
 */

import {LightningElement, track, api} from 'lwc';
import getPicklistValues from '@salesforce/apex/EUR_TR_POSMDefinitionController.getPicklistValues';
import upsertPOSMSegmentationDefinition
    from '@salesforce/apex/EUR_TR_POSMDefinitionController.upsertPOSMSegmentationDefinition';
import EUR_TR_DEFINITION_OBJECT from '@salesforce/schema/EUR_TR_Definition__c';
import {reduceErrors, showToastMessage} from "c/eur_tr_util";

const UPDATE_PROMPT_MESSAGE = "Güncelleme işlemini tamamlamak istediğine emin misiniz?";
const SUCCESS_UPDATE_MESSAGE = 'Güncelleme işleminiz başarılı bir şekilde tamamlandı.';
const SUCCESS_INSERT_MESSAGE = 'Segmentasyon tanımlama işleminiz başarılı bir şekilde tamamlandı';
const SUCCESS_TITLE = "İşlem Başarılı";
const ERROR_VARIANT = "error";
const WARNING_VARIANT = 'warning';

const ALL_FIELDS_EMPTY_VALIDATION_MESSAGE = 'Segmentasyon tanımı için seçim yapınız!';
const PRODUCT_TYPE_EMPTY_VALIDATION_MESSAGE = 'Ürün Tipi için seçim yapınız!';
const EXCEPT_PRODUCT_ALL_SEGMENTATION_FIELDS_EMPTY_VALIDATION_MESSAGE = 'Segmentasyon alanlarından en az biri dolu olmalıdır!';
const SELECTED_ALL_VALIDATION_MESSAGE = 'Tümü seçildiğinde başka değer seçilemez';

const CREATE_BUTTON_LABEL = 'Kaydet';
const UPDATE_BUTTON_LABEL = 'Güncelle';
const CREATE_SEGMENTATION_FORM_CARD_TITLE = 'Yeni Segmentasyon Tanımı';
const UPDATE_SEGMENTATION_FORM_CARD_TITLE = 'Segmentasyon Tanımı Güncelle';

export default class EurTrNewPosmSegmentationForm extends LightningElement {

    isNewPOSMDefinitionDialogOpen = false;
    isMultiPicklistDualBoxDialogVisible = false;
    @track
    dualBoxOptions = [];
    @track
    dualBoxSelectedOptions = [];
    isLoading = false;
    selectedPicklistField = undefined;
    picklists = [];
    segmentation = EUR_TR_DEFINITION_OBJECT;
    actionLabel = CREATE_BUTTON_LABEL;
    formCardTitle = CREATE_SEGMENTATION_FORM_CARD_TITLE;

    openNewDefinitionDialog() {
        this.isNewPOSMDefinitionDialogOpen = true;
        this.clearAllValues();
        this.segmentation = EUR_TR_DEFINITION_OBJECT;
    }

    clearAllValues() {
        this.segmentation["EUR_TR_SegmentationPOSMTypes__c"] = "";
        this.picklists.forEach(picklist => {
            if (picklist.fieldName !== "EUR_TR_SegmentationPOSMTypes__c") {
                this.segmentation[picklist.fieldName] = "All";
            }
        });
    }

    openDefinitionDialogBySelectedRow() {
        this.isNewPOSMDefinitionDialogOpen = true;
    }

    closeNewPOSMForm() {
        this.isNewPOSMDefinitionDialogOpen = false;
        this.actionLabel = CREATE_BUTTON_LABEL;
        this.formCardTitle = CREATE_SEGMENTATION_FORM_CARD_TITLE;
    }

    get POSMFormClass() {
        return this.isNewPOSMDefinitionDialogOpen ? 'slds-p-horizontal_small slds-p-bottom_xx-large' : 'slds-hide';
    }

    connectedCallback() {
        this.loadPicklists();
    }

    loadPicklists() {

        this.isLoading = true;
        getPicklistValues({}).then(result => {
            this.picklists = result;
            this.setDefaultAll(this.picklists);
            this.isLoading = false;
        }).catch(error => {
            const errorMessage = reduceErrors(error);
            showToastMessage({
                caller: this,
                message: errorMessage.join('.'),
                variant: ERROR_VARIANT
            });
            this.isLoading = false;
        })

    }

    setDefaultAll(picklists) {
        if (Array.isArray(picklists)) {
            picklists.forEach(picklist => {
                if (picklist.fieldName !== "EUR_TR_SegmentationPOSMTypes__c") {
                    this.segmentation[picklist.fieldName] = picklist.items[0].value;
                }
            });
        }
    }


    openMultiPicklistDualBoxDialog(event) {

        this.selectedPicklistField = event.target.value;
        this.isMultiPicklistDualBoxDialogVisible = true;

        const selectedPicklist = this.picklists.find(item => {
            return item.fieldName === this.selectedPicklistField
        });
        this.dualBoxOptions = selectedPicklist.items;
        this.dualBoxSelectedOptions = this.getSelectedOptionsBySelectedField();
    }

    getSelectedOptionsBySelectedField() {
        if (this.segmentation[this.selectedPicklistField]) {
            return this.segmentation[this.selectedPicklistField].split(';');
        }
    }

    closeMultiPicklistDualBoxDialog() {
        this.isMultiPicklistDualBoxDialogVisible = false;
    }

    handleChange(event) {

        const selectedValues = event.detail.value.join(';');
        if (selectedValues) {
            const totalSelectedLength = event.detail.value.length;
            const dualBoxElem = event.currentTarget;
            if (totalSelectedLength > 1 && selectedValues.includes('All')) {
                this.dualBoxSelectedOptions = ["All"];
                this.segmentation[this.selectedPicklistField] = "All";
                this.showWarningMessage(SELECTED_ALL_VALIDATION_MESSAGE);
                return;
            }
            if (selectedValues.length > 220) {
                dualBoxElem.setCustomValidity('250 karakterden fazla seçil yapılamaz!');
                this.dualBoxSelectedOptions = this.segmentation[this.selectedPicklistField].split(';');
                return;
            } else {
                dualBoxElem.setCustomValidity('');
            }
        }
        this.segmentation[this.selectedPicklistField] = selectedValues;

    }

    @api openFormByClonedRecord(selectedRow) {
        selectedRow.Id = null;
        this.segmentation = selectedRow;
        this.actionLabel = CREATE_BUTTON_LABEL;
        this.formCardTitle = CREATE_SEGMENTATION_FORM_CARD_TITLE;
        this.openDefinitionDialogBySelectedRow();
    }

    @api openFormToUpdate(selectedRow) {
        this.segmentation = selectedRow;
        this.actionLabel = UPDATE_BUTTON_LABEL;
        this.formCardTitle = UPDATE_SEGMENTATION_FORM_CARD_TITLE;
        this.openDefinitionDialogBySelectedRow();
    }

    upsertPOSMSegmentationDefinition() {

        this.isLoading = true;

        // update confirmation
        let isUpdateApproved = true;
        if (this.segmentation["Id"]) {
            isUpdateApproved = confirm(UPDATE_PROMPT_MESSAGE);
            if (!isUpdateApproved) {
                this.isLoading = false;
                return;
            }
        }


        const isValid = this.validatePOSMSegmentationDefinitionRecord(this.segmentation);
        if (isValid) {
            const successMessage = (!this.segmentation["Id"]) ? SUCCESS_INSERT_MESSAGE : SUCCESS_UPDATE_MESSAGE;
            upsertPOSMSegmentationDefinition({"segmentationDefinition": this.segmentation}).then(() => {
                this.closeNewPOSMForm();
                showToastMessage({
                    caller: this,
                    message: successMessage,
                    title: SUCCESS_TITLE
                });
                this.isLoading = false;
                const refreshEvent = new CustomEvent('success', {});
                this.dispatchEvent(refreshEvent);
            }).catch(error => {
                const errorMessage = reduceErrors(error);
                showToastMessage({
                    caller: this,
                    variant: ERROR_VARIANT,
                    message: errorMessage.join('.')
                });
                this.isLoading = false;
            })
        }

    }

    validatePOSMSegmentationDefinitionRecord(segmentation) {

        const fieldNames = this.picklists.map(item => {
            return item.fieldName;
        });

        let emptyFieldSize = 0;
        fieldNames.forEach(fieldName => {
            if (!segmentation[fieldName]) {
                emptyFieldSize++;
            }
        });

        let isValid = true;
        let errorMessage = '';
        if (emptyFieldSize === 14) {
            errorMessage = ALL_FIELDS_EMPTY_VALIDATION_MESSAGE;
            isValid = false;
        } else if (!segmentation["EUR_TR_SegmentationPOSMTypes__c"]) {
            errorMessage = PRODUCT_TYPE_EMPTY_VALIDATION_MESSAGE;
            isValid = false;
        } else if (
            !segmentation["EUR_TR_Channel__c"] && !segmentation["EUR_TR_Group__c"] && !segmentation["EUR_TR_Class__c"] &&
            !segmentation["EUR_TR_SubType__c"] && !segmentation["EUR_TR_SponsorshipStatus__c"] && !segmentation["EUR_TR_Range__c"] &&
            !segmentation["EUR_TR_Type__c"] && !segmentation["EUR_TR_OTPros__c"] && !segmentation["EUR_TR_OTType__c"] &&
            !segmentation["EUR_TR_ONTB__c"] && !segmentation["EUR_TR_ActivityPoints__c"] && !segmentation["EUR_TR_OTSponsorship__c"]
        ) {
            errorMessage = EXCEPT_PRODUCT_ALL_SEGMENTATION_FIELDS_EMPTY_VALIDATION_MESSAGE;
            isValid = false;
        }
        if (!isValid) {
            window.setTimeout(() => {
                this.isLoading = false;
                this.showWarningMessage(errorMessage);
            }, 500);
        }

        return isValid;
    }

    refreshSegmentationTable() {
        const definitionTableLWC = this.template.querySelector('c-eur-tr-posm-segmentation-table');
        definitionTableLWC.refreshTable();
    }

    showWarningMessage(validationMessage) {
        showToastMessage({
            caller: this,
            variant: WARNING_VARIANT,
            message: validationMessage
        })
    }

}