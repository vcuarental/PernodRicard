import {LightningElement, api} from 'lwc';

export default class Eur_modal extends LightningElement {
    @api visible; //used to hide/show dialog
    @api title; //modal title
    @api name; //reference name of the component
    @api message; //modal message
    @api confirmLabel; //confirm button label
    @api cancelLabel; //cancel button label


    //private methods
    _closeModal() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    _submit() {
        this.dispatchEvent(new CustomEvent('submit'));
    }


}