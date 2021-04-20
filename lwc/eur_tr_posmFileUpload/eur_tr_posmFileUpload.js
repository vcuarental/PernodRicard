/**
 * Created by osman on 13.10.2020.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
import getUploadedPOSMImage from '@salesforce/apex/EUR_TR_POSMDefinitionController.getUploadedPOSMImage';
import handleUploadFinished from '@salesforce/apex/EUR_TR_POSMDefinitionController.handleUploadFinished';
import deletePOSMImage from '@salesforce/apex/EUR_TR_POSMDefinitionController.deletePOSMImage';

const ERROR_TITLE = "Hata";
const ERROR_VARIANT = "error";
const SUCCESS_TITLE = "Başarılı"
const SUCCESS_VARIANT = "success";
const SUCCESS_PHOTO_INSERT_MESSAGE = "POSM ürünü için fotoğraf başarılı bir şekilde yüklendi";
const SUCCESS_PHOTO_DELETE_MESSAGE = "POSM ürün fotoğrafı başarılı bir şekilde silindi";
const UNKNOWN_ERROR_MESSAGE = "Bilinmeyen hata meydana geldi.Lütfen sistem yöneticisi ile iletişime geçiniz.";
const IMAGE_PREFIX_URL = "/sfc/servlet.shepherd/version/download/";
const ACCEPTED_FILE_FORMATS = [".png", ".jpg", ".jpeg"];

export default class POSMFileUpload extends LightningElement {

    @api
    recordId;
    @track
    imageURL;
    @track
    latestContentVersionId;
    isLoading = true;

    get acceptedFormats() {
        return ACCEPTED_FILE_FORMATS;
    }


    @wire(getUploadedPOSMImage, {recordId: '$recordId'})
    wiredImages({error, data}) {
        if (data) {
            this.setImageAttributes(data);
            this.isLoading = false;
        } else if (error) {
            let errorMessage = this.getErrorMessage(error);
            this.showMessage(ERROR_TITLE, ERROR_VARIANT, errorMessage);
            this.isLoading = false;
        }
    }


    handleUploadFinished(event) {

        this.isLoading = true;
        const uploadedFiles = event.detail.files;
        const uploadedContentDocumentId = uploadedFiles[0].documentId;

        handleUploadFinished({recordId: this.recordId, uploadedContentDocumentId: uploadedContentDocumentId})
            .then(data => {
                this.setImageAttributes(data);
                this.showMessage(SUCCESS_TITLE, SUCCESS_VARIANT, SUCCESS_PHOTO_INSERT_MESSAGE);
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                let errorMessage = this.getErrorMessage(error);
                this.showMessage(ERROR_TITLE, ERROR_VARIANT, errorMessage);
            });

    }

    deletePOSMImage() {

        this.isLoading = true;

        deletePOSMImage({recordId: this.recordId, latestContentVersionId: this.latestContentVersionId})
            .then(data => {
                this.setImageAttributes(data);
                this.showMessage(SUCCESS_TITLE, SUCCESS_VARIANT, SUCCESS_PHOTO_DELETE_MESSAGE);
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                let errorMessage = this.getErrorMessage(error);
                this.showMessage(ERROR_TITLE, ERROR_VARIANT, errorMessage);
            });

    }

    showMessage(title, variant, message) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    setImageAttributes(data) {
        if (data.length > 0) {
            this.imageURL = `${IMAGE_PREFIX_URL}/${data[0].LatestPublishedVersionId}`;
            this.latestContentVersionId = `${data[0].LatestPublishedVersionId}`;
        } else {
            this.imageURL = null;
            this.latestContentVersionId = null;
        }
    }

    getErrorMessage(error) {
        let errorMessage = UNKNOWN_ERROR_MESSAGE;
        if (error.message) {
            errorMessage = error.message;
        } else if (error.body.message) {
            errorMessage = error.body.message;
        }
        return errorMessage;
    }


}