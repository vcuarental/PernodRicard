import { LightningElement, api, track } from 'lwc';

/** Static Resources. */
import PERNODRICARD_URL from '@salesforce/resourceUrl/eur_doc_server_resource';

export default class Eur_doc_placeholder extends LightningElement {
    @api message;

    /** Url for bike logo. */
    @track logoUrl = PERNODRICARD_URL + '/placeholderLogo.png';
}