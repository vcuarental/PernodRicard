import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


import getTemplateLines from '@salesforce/apex/EUR_CRM_Template_Edition.getTemplateLines';
import getProducts from '@salesforce/apex/EUR_CRM_Template_Edition.getProducts';
import cloneTemplateAndLines from '@salesforce/apex/EUR_CRM_Template_Edition.cloneTemplateAndLines';
import addToTemplate from '@salesforce/apex/EUR_CRM_Template_Edition.addToTemplate';
import deleteTemplateLine from '@salesforce/apex/EUR_CRM_Template_Edition.deleteTemplateLine';
import changeLineStatus from '@salesforce/apex/EUR_CRM_Template_Edition.changeLineStatus';
import checkRequiredMetadata from '@salesforce/apex/EUR_CRM_Template_Edition.checkRequiredMetadata';
import LineModel from './LineModel';



export default class EUR_CRM_Template_Edition extends NavigationMixin(LightningElement) {

    /*
     * @loading: if loading is true the spinner will be diplayed and no action would be available on the page
     * @NbLoading: Many loading can happen in the same time
     *      Each time a loading is asked the number increments
     *      Each time a loading is stopped the number decrements
     *      Each time a loading action is called we check if NbLoading = 0
     *              if yes @loading = false
     *              if no @loading = true
     */
    @track loading = false;
    NbLoading = 0;

    /*
     * @templates: [{label:..., value:...}, {...}]
     * Used for the lightning combobox to display the available templates for the current user
     */
    //@track
    //templates;


    @api recordId;


    /*
     *  @tplLine: JS Equivalent object of TemplateLine class 
     *      that contains the template line data of the current template
     *  @products: JS Equivalent object of TemplateLine class 
     *      that contains all the products that are not part of the template lines of the current template
     *  
     */
    @track tplLines;
    @track products_displayed;
    products; //No Tracking it is just a save point

    @track activeSections = []; //Used for accordeons in template lines
    @track activeSessionProducts = []; //Used for accordeons in products

    @track hasAllRequiredMetadata = false;
    /*
     *   Some kind of constructor
     */
    connectedCallback() {

        this.products = new LineModel();
        this.products_displayed = new LineModel();
        this.tplLines = [];


        this.activeSections = [];
        this.activeSessionProducts = [];

        this.loadProducts();
        this.loadTemplateLines();

        checkRequiredMetadata({ templateId: this.recordId }).then(result => {
            this.hasAllRequiredMetadata = result;
        }).catch(error => {
            console.log(error);
        });

    }


    searchProduct(event) {

        //Get search value
        let text = event.detail.value;


        this.showProductsAccordeons();


        if (text.length > 2) {
            this.products.removeIfNotMatch(text);
        } else {
            this.products.removeIfNotMatch(""); //Shoud put everything at false
        }

    }

    changeTemplateLineStatus(event) {
        this.startLoading();

        let tplLineId = event.currentTarget.dataset.lineid;
        let listing = event.currentTarget.dataset.listing;

        changeLineStatus({ tplLine: this.getLineByTemplateLineId(tplLineId), status: listing }).then(result => {
            this.stopLoading();

            result = this.assign(result);
            //this.log('changeLineStatus()', result);
            for (let i = 0; i < this.tplLines.length; i++) {
                if (tplLineId == this.tplLines[i].template_line_id) {
                    this.tplLines[i] = result;
                }
            }

        }).catch(error => {
            this.stopLoading();
            this.displayError(error);

        });
    }
    removeTemplateLineFromTemplate(event) {

        if (confirm("Are you sure you want to remove this product from the template?")) {
            this.startLoading();

            let tplLineId = event.currentTarget.dataset.lineid;

            deleteTemplateLine({ tplLine: this.getLineByTemplateLineId(tplLineId) }).then(result => {
                this.stopLoading();
                result = this.assign(result);

                this.removeLineFromTemplate(tplLineId);

                this.products.addLine(result);



            }).catch(error => {
                this.stopLoading();
                this.displayError(error);

            });
        }
    }

    clickAddProduct(event) {

        this.startLoading();


        let productId = event.currentTarget.dataset.product;
        let templateId = event.currentTarget.dataset.template;

        addToTemplate({ tplLine: this.products.getLineByProductId(productId) }).then(result => {
            this.stopLoading();

            result = this.assign(result);
            //this.log('addToTemplate()', result);
            this.activeSections.push(result.category);
            this.activeSections.push(result.brand);
            this.tplLines.push(result);
            this.products.removeLine(result);

            this.sortByProductName();

        }).catch(error => {
            this.stopLoading();
            this.displayError(error);
        });
    }

    displayError(error) {

        const evt = new ShowToastEvent({
            title: "Error",
            message: error.message || error.body.message,
            variant: "error",
            mode: "sticky"
        });
        this.dispatchEvent(evt);
    }
    displaySuccess(title, message, data) {

        const event = new ShowToastEvent({
            title: title,
            message: message,
            messageData: data,
            mode: "sticky"
        });
        this.dispatchEvent(event);
    }


    showProductsAccordeons() {
        this.activeSessionProducts = this.products.getAllCategories().concat(this.products.getAllBrands());
    }


    hideProductsAccordeons() {
        this.activeSessionProducts = [];
    }


    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

    }

    handleSectionToggleProducts(event) {
        const openSectionsProducts = event.detail.openSections;
    }


    loadTemplateLines() {
        this.startLoading()

        this.tplLines = [];

        this.activeSections = [];

        getTemplateLines({ template_id: this.recordId }).then(response => {
            this.stopLoading();
            response = this.assign(response);
            //this.log('getTemplateLines()', response);
            this.tplLines = response;


        }).catch(error => {
            this.stopLoading();
            this.displayError(error);

        });

    }

    loadProducts() {
        this.startLoading();
        this.products_displayed = new LineModel();
        this.products = new LineModel();
        //let categories = [];
        this.activeSectionsProducts = [];

        getProducts({ template_id: this.recordId }).then(response => {
            this.stopLoading();

            response = this.assign(response);
            //this.log('getProducts()', response);
            this.products.addAllLines(response);
            this.products_displayed.cloneData(this.products);
        }).catch(error => {
            this.stopLoading();

            this.displayError(error);

        });

    }


    clickClone() {
        if (confirm("Are you sure you want to clone this template?")) {
            this.startLoading();
            cloneTemplateAndLines({ template_id: this.recordId }).then(result => {
                this.stopLoading();



                //this.log('cloneTemplateAndLines()', result);
                this.displaySuccess('Success', "{0} See it {1}!", [
                    'Template created!',
                    {
                        url: '/' + result,
                        label: 'here'
                    }
                ]);

            }).catch(error => {
                this.stopLoading();

                this.displayError(error);
            });
        }
    }

    startLoading() {

        this.loading = true;
        this.NbLoading = this.NbLoading + 1;

    }
    stopLoading() {

        this.NbLoading = this.NbLoading - 1;
        if (this.NbLoading == 0) {
            this.loading = false;
        }
    }

    assign(response) {
        if (Array.isArray(response)) {
            let newArray = [];
            response.forEach(r => {
                newArray.push(Object.assign({}, r));
            });
            return newArray;
        } else {
            return Object.assign({}, response);
        }
    }

    log(message, variable) {
        console.log(message);
        console.log(variable);
    }

    removeLineFromTemplate(templateLineId) {
        let index = -1;
        for (let i = 0; i < this.tplLines.length && i != -1; i++) {
            if (this.tplLines[i].template_line_id == templateLineId) {
                index = i;
            }
        }
        console.log('Index for remove is : ' + index)
        if (index != -1) {
            this.tplLines.splice(index, 1);
        }
    }
    getLineByTemplateLineId(tplLineId) {

        for (let i = 0; i < this.tplLines.length; i++) {
            if (this.tplLines[i].template_line_id == tplLineId) {
                return this.tplLines[i];
            }
        }
        return null;
    }

    sortByProductName() {
        this.tplLines.sort(function(a, b) {
            return a.product.localeCompare(b.product);
        });

        this.tplLines.sort();
    }
}