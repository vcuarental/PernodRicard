import { LightningElement, api, track } from 'lwc';

export default class Eur_doc_tile extends LightningElement {
    
    @api draggable;
    @api dlList;

    _account;

    @api
    get account() {
        return this._account;
    }

    set account(value) {
        this._account = value;
        //this.pictureUrl = '/sfc/servlet.shepherd/version/download/' + value.pictureUrl;
        this.pictureUrl = '/servlet/servlet.FileDownload?file=' + value.pictureUrl;
        this.name = value.accountName;
        this.accountAddress = value.accountAddress;
        this.module = value.module;
        this.salesName = value.salesName;
        this.region = value.region;
        this.territory = value.territory;
        this.createdDate = value.createdDate;
        this.dlCheckbox = value.dlCheckbox;
        this.debug = this.dlCheckbox;
    }

    /** account field values to display. */
    @track name;
    @track pictureUrl;
    @track accountAddress;
    @track module;
    @track salesName;
    @track region;
    @track territory;
    @track createdDate;
    @track dlCheckbox;
    @track debug;

    connectedCallback() {
         let splittedURL = this.pictureUrl.split("=");   
         if (this.dlList.includes(splittedURL[1])) {
            this.dlCheckbox = true;
        } 
    }

    handleClick() {
        const selectedEvent = new CustomEvent('selected', {
            detail:{
                id: this.account.Id,
                name: this.name,
                url: this.pictureUrl,
                address: this.accountAddress,
                module: this.module,
                salesName: this.salesName,
                region: this.region,
                territory: this.territory,
                date: this.createdDate
            } 
        });
        this.dispatchEvent(selectedEvent);
    }

    addOrRemoveToDLList(event) {
        this.dlCheckbox = event.target.checked;
        this.debug = this.dlCheckbox;
        let splittedURL = this.pictureUrl.split("=");
        let date = this.createdDate.replace(',','');
        const dlEvent = new CustomEvent('dlcheckboxcliked', {
            detail:{
                url: splittedURL[1],
                filename: this.name+' - '+this.module+' - '+this.salesName+' - '+date+' - '+splittedURL[1]
            } 
        });
        this.dispatchEvent(dlEvent);    
    }

    get isdlCheckboxAvailable() {
        return this.module==="SO" ? false : true;        
    }

    @api
    setDlCheckbox(value) {
        this.dlCheckbox = value;    
        this.debug = this.dlCheckbox;
    }

}