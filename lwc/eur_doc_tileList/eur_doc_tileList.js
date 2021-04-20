import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import triggerSearch from '@salesforce/apex/EUR_DOC_DocServerController.triggerSearch';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/eur_doc_pubsub';
import { loadScript } from 'lightning/platformResourceLoader';
import jszip from '@salesforce/resourceUrl/eur_doc_jszip';
import filesaver from '@salesforce/resourceUrl/eur_doc_filesaver';
import getPictureBody from '@salesforce/apex/EUR_DOC_DocServerController.getPictureBody';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Eur_doc_tileList extends LightningElement {

    @api tilesAreDraggable = false;
    @track loading = false;
    @track accounts = [];
    @track pageNumber = 1;
    @track pageSize;
    @track totalItemCount = 0;
    filters = '{}';
    @track dlList = [];
    @track dlFilename = [];
    @track debug = 'dlList: '+this.dlList;

    @wire(CurrentPageReference) pageRef
    @wire(triggerSearch, { filters: '$filters', pageNumber: '$pageNumber' })
    wiredAccount({ error, data }) {
        if (data) {
            this.accounts = data;
        } else if (error) {
            const toastEvent = new ShowToastEvent({ 
                title: 'Search Error', 
                message: 'An error occured while searching for records, try to filter more.', 
                variant: 'error' });
            this.dispatchEvent(toastEvent);
        }
        this.loading= false;
    }

    connectedCallback() {
        registerListener('triggerSearch', this.handleFilterChange, this);
        //this.debug = JSON.stringify(this.accounts);
    }

    handlePictureSelected(event) {
        fireEvent(this.pageRef, 'pictureSelected', event.detail);
    }

    addRemoveOnDLLIst(event) {
        if (this.dlList.includes(event.detail.url)) {
            const index = this.dlList.indexOf(event.detail.url);
            this.dlList.splice(index, 1);
            this.dlFilename.splice(index,1);
        } else {
            this.dlList.push(event.detail.url);
            this.dlFilename.push(event.detail.filename);
        }
        this.debug = 'dlList after change: '+JSON.stringify(this.dlList)+' - '+JSON.stringify(this.dlFilename);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleFilterChange(filters) {
        this.dlList = [];
        this.dlFilename = [];
        this.loading= true;
        this.filters = JSON.stringify(filters);
        this.pageNumber = 1;        
    }

    get hasRecordsToShow() {
        return this.accounts != null && this.accounts.records != null && this.accounts.records.length>0 ? true : false;
    }

    handlePreviousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.loading = true;
    }

    handleNextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.loading = true;
    }

    get isDLListEmpty() {
        return this.dlList.length===0 ? true : false;
    }

    dlPictures() {
        Promise.all([
            loadScript(this, jszip),
            loadScript(this, filesaver)
        ]).then(() => { 
            // eslint-disable-next-line no-undef
            var zip = new JSZip();

            getPictureBody({ listIds : this.dlList })
            .then(result => {

                for (let i=0; i<result.length; i++) {
                    const index = this.dlList.indexOf(result[i].id);
                    zip.file(this.dlFilename[index]+result[i].extension, result[i].data, {base64: true});
                }

                zip.generateAsync({type:"blob"})
                .then(function(content) {
                    // eslint-disable-next-line no-undef
                    saveAs(content, "DocServerPictures.zip");
                }); 
            });           
        });
    }

    resetDLCheckBoxes() {
        this.dlList = [];
        this.dlFilename = [];
        this.debug = 'dlList after clear: '+this.dlList;
        const lookups = this.template.querySelectorAll('c-eur_doc_tile');
        for (let i=0; i<lookups.length; i++) {
            lookups[i].setDlCheckbox(false);
        }    
    }
    

}