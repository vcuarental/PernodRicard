import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/eur_doc_pubsub';

export default class Eur_doc_modal extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('pictureSelected', this.openModal, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
    
    @track openmodel = false;
    @track name;
    @track pictureUrl;
    @track accountAddress;
    @track accountRegion;
    @track accountTerritory;
    @track createdDate;
    @track module;


    openModal(account) {
        this.openmodel = true;
        this.name = account.name+' • '+account.module+' • '+account.salesName+' ';
        this.pictureUrl = account.url;
        this.accountAddress = account.address;
        this.accountRegion = account.region;
        this.accountTerritory = account.territory;
        this.createdDate = account.date;
        this.module = account.module;
    }  

    closeModal() {
        this.openmodel = false;
    } 

    get isSOMudule(){
        return this.module === 'SO' ? true : false;
    }
}