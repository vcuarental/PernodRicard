import { LightningElement, wire, track, api } from 'lwc';
import getBrands from '@salesforce/apex/EUR_NIM_Service.getBrandValues';
import getCategories from '@salesforce/apex/EUR_NIM_Service.getCategoryValues';
import getActiveDeals from '@salesforce/apex/EUR_NIM_DealService.getActiveDealsByAccount';
import addDealProducts from '@salesforce/apex/EUR_NIM_DealService.addDealProducts';
import { registerListener, fireEvent, unregisterAllListeners } from 'c/eur_common_pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import searchProducts from '@salesforce/label/c.EUR_NIM_SearchProducts';
import productNumber from '@salesforce/label/c.EUR_NIM_ProductNumber';
import productName from '@salesforce/label/c.EUR_NIM_ProductName';
import category from '@salesforce/label/c.EUR_NIM_Category';
import brand from '@salesforce/label/c.EUR_NIM_Brand';
import search from '@salesforce/label/c.EUR_NIM_Search';
import clear from '@salesforce/label/c.EUR_NIM_Clear';
import deals from '@salesforce/label/c.EUR_NIM_Deals';
import applyDeals from '@salesforce/label/c.EUR_NIM_ApplyDeals';
import cancel from '@salesforce/label/c.EUR_NIM_Cancel';
import activeDeals from '@salesforce/label/c.EUR_NIM_ActiveDeals';
import errorLabel from '@salesforce/label/c.EUR_NIM_Variant_Error';

export default class Eur_nim_productPickerProductFilter extends LightningElement 
{
    label = {
        errorLabel
    };

    @api recordId;
    @track value =[];
    @track accId;
    @track selectedDeals = [];
    @track selectedProduct = [];
    
    @wire(getBrands, { accountId: '$recordId' }) brandOptions;
    @wire(getCategories, { accountId: '$recordId' }) categoryOptions;
    @wire(getActiveDeals, { accountID: '$recordId' }) dealsOptions;
    @wire(CurrentPageReference) pageRef;

    @api
    refresh() {
            this.accId = this.recordId;
    }

    handleClear() {
        this.template.querySelectorAll('lightning-input, lightning-combobox').forEach(inputElement => {
            inputElement.value = '';
        });
        fireEvent(this.pageRef, 'cleanUpSearchResults', {});
    }

    connectedCallback() {
        // subscribe to searchKeyChange event
        console.log('connectedCallback');
        registerListener('setProductNumberFocus', this.handleSetProductNumberFocus, this);
        this.refresh();
    }

    disconnectedCallback() {
        // unsubscribe from searchKeyChange event
        unregisterAllListeners(this);
    }

    label = {
        searchProducts,
        productNumber,
        productName,
        category,
        brand,
        search,
        deals,
        clear,
        applyDeals,
        cancel,
        activeDeals
    };

    get showDeals()
    {
        return 'Deals';        
    }

    /*@track dealLabel = this.label.deals;
    get getDealLabel()
    {
        alert(this.label.deals);
        if(this.dealsOptions.data.length > 0)
        {
            alert(this.dealsOptions.data.length);
            this.dealLabel = this.label.deals; 
            return true;
        }
        return false;
    }*/

    @track bShowModal = false;
     openModal() {    
        // to open modal window set 'bShowModal' tarck value as true
        this.bShowModal = true;
    }

    handleDealSelection(event)
    {
        //var valueToCheck = event.target.value;
        this.selectedDeals = event.detail.value;        
    }
 
    closeModal() 
    {    
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
    }

    applyDeals()
    {
        //addDealProducts
        addDealProducts({dealId: JSON.stringify(this.selectedDeals)})
        .then(result => {
            this.selectedProduct = result; 
            fireEvent(this.pageRef, 'addProductsToSelection', this.selectedProduct);
            this.bShowModal = false;
        })
        .catch(error => {
            this.error = error;  
            this.showToastMessage('Error: ', this.error.body.message, this.label.errorLabel); 
        });          
    }

    handleFilter(event) 
    {
        //undefined added for picklist value changed
        if(event.which != 13 && event.which != 1 && event.which != undefined)
        {
            return;
        }
        // fire contactSelected event
        const filter = {};
        this.template.querySelectorAll('lightning-input, lightning-combobox').forEach(inputElement => {
            filter[inputElement.getAttribute("data-fieldapiname")] = JSON.stringify({Label: inputElement.value, operator: inputElement.getAttribute("data-compoperator")})
        });
        console.log(filter);
        fireEvent(this.pageRef, 'filterProducts', 
        {
            filter: filter
        });
    }   

    handleSetProductNumberFocus()
    {
        this.template.querySelectorAll('lightning-input').forEach(inputElement => {
            if(inputElement.getAttribute("data-fieldapiname") == 'EUR_CRM_SKU__r.EUR_CRM_Article_no__c')
            {
                inputElement.focus();
                inputElement.value = '';
            }            
        });
    }
}