import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getFilteredProducts from '@salesforce/apex/EUR_NIM_ProductPickerController.getFilteredProducts';
import { registerListener, fireEvent, unregisterAllListeners } from 'c/eur_common_pubsub';
import searchResults from '@salesforce/label/c.EUR_NIM_SearchResults';
import action from '@salesforce/label/c.EUR_NIM_Action';
import productName from '@salesforce/label/c.EUR_NIM_ProductName';
import productCode from '@salesforce/label/c.EUR_NIM_ProductCode';
import description from '@salesforce/label/c.EUR_NIM_Description';

export default class Eur_nim_productPickerProductList extends LightningElement 
{
    @api recordId; 
    @api objectApiName;
    @track items;
    @track productFilter = {};
    @track selectedProduct = [];
    @api
    refresh() {
        this.error = undefined;
        this.items = [];
    }
    
    @wire(CurrentPageReference) pageRef;
    
    label = {
        searchResults,
        action,
        productName,
        productCode,
        description
    }
   
    async connectedCallback() {
        console.log('connectedCallback');
        registerListener('filterProducts', this.handleFilterProducts, this);
        registerListener('cleanUpSearchResults', this.handleCleanUpSearchResults, this);
    }

    disconnectedCallback (){
        unregisterAllListeners();
    }

    handleFilterProducts(productFilter) 
    {
        console.log('handleFilterProducts');
        this.productFilter = productFilter;
        this.filter();
    }

    handleCleanUpSearchResults() 
    {
        this.items = [];
    }

    handleAdd(event) 
    {
        //alert(event.target.value);
        const productCode = event.target.value;
        this.selectedProduct = [];
        for( var i = 0; i < this.items.length; i++)
        { 
            //alert(this.items[i].productCode);
            if(productCode == this.items[i].productCode)
            {
                this.selectedProduct.push(this.items[i]); 
            }
        }
        fireEvent(this.pageRef, 'addProductsToSelection', this.selectedProduct);         
    }

    filter() 
    {
        console.log('filter');
        this.items = [];
        //getFilteredProducts(JSON.stringify(this.productFilter))
        getFilteredProducts({ filter: JSON.stringify(this.productFilter), accId: this.recordId })
            .then(result => {
                this.items = result;
                this.error = undefined;
                
                if(result.length == 1)
                {
                    this.selectedProduct = [];
                    for( var i = 0; i < this.items.length; i++)
                    { 
                        this.selectedProduct.push(this.items[i]); 
                    }
                    fireEvent(this.pageRef, 'addProductsToSelection', this.selectedProduct);
                }
            })
            .catch(error => {
                this.error = error;
                this.items = undefined;
            });
    }

    onitemchange(event)
    {
        const changeditem = event.detail.me;    

        this.selectedItem = this.items.find(
            item => item.product.Id === changeditem.product.Id
        );

        this.selectedItem.quantity = event.detail.quantity;
    }
}