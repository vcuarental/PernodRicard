import { LightningElement, track } from 'lwc';
import searchByAccountContact from '@salesforce/apex/EUR_NIM_SearchServiceController.searchByAccountContact';
import { NavigationMixin } from 'lightning/navigation';
import searchCompanyContact from '@salesforce/label/c.EUR_NIM_SearchCompanyContact';
import companyName from '@salesforce/label/c.EUR_NIM_CompanyName';
import customerNumber from '@salesforce/label/c.EUR_NIM_CustomerNumber';
import street from '@salesforce/label/c.EUR_NIM_Street';
import postalCode from '@salesforce/label/c.EUR_NIM_PostalCode';
import city from '@salesforce/label/c.EUR_NIM_City';
import firstName from '@salesforce/label/c.EUR_NIM_FirstName';
import lastName from '@salesforce/label/c.EUR_NIM_LastName';
import phone from '@salesforce/label/c.EUR_NIM_Phone';
import name from '@salesforce/label/c.EUR_NIM_Name';
import country from '@salesforce/label/c.EUR_NIM_Country';
import search from '@salesforce/label/c.EUR_NIM_Search';
import clear from '@salesforce/label/c.EUR_NIM_Clear';

export default class SearchComponent extends NavigationMixin(LightningElement)  
{
    @track companyName;
    @track customerNumberERP;
    @track street;
    @track postalCode;
    @track city;
    @track phone;
    @track firstName;
    @track lastName;
    @track resultCount;
    @track accountContactResult;
    @track error;

    label = {
        searchCompanyContact,
        companyName,
        customerNumber,
        street,
        postalCode,
        city,
        firstName,
        lastName,
        phone,
        name,
        country,
        search,
        clear
    }

    setFieldValue(event)
    {
        const field = event.target.name;

        if (field === 'companyName') 
        {
            this.companyName = event.target.value;
        }
        else if(field == 'customerNumberERP')
        {
            this.customerNumberERP = event.target.value;
        }
        else if (field === 'street') 
        {
            this.street = event.target.value;
        }
        else if (field === 'postalCode') 
        {
            this.postalCode = event.target.value;
        }
        else if (field === 'city') 
        {
            this.city = event.target.value;
        }
        else if (field === 'phone') 
        {
            this.phone = event.target.value;
        }
        else if (field === 'firstName') 
        {
            this.firstName = event.target.value;
        } 
        else if (field === 'lastName') 
        {
            this.lastName = event.target.value;
        }
    }
    getSearchResult(event)
    {
        if(event.which != 13 && event.which != 1)
        {
            return;
        }
        const companyName = this.companyName;
        const customerNumberERP = this.customerNumberERP;
        const street = this.street;
        const postalCode = this.postalCode;
        const city = this.city;
        const phone = this.phone;
        const firstName = this.firstName;
        const lastName = this.lastName;
        
        searchByAccountContact({companyName, customerNumberERP, street, postalCode, city, phone, firstName, lastName})
        .then(result => {
            this.accountContactResult = result; 
            this.resultCount = 'Search Result (' + result.length + ')';
            console.log(this.accountContactResult); 
        })
        .catch(error => {
            this.error = error;
        });
             
    }

    handleClearClick(event)
    {
        this.companyName = '';
        this.customerNumberERP = '';
        this.street = '';
        this.postalCode = '';
        this.city = '';
        this.phone = '';
        this.firstName = '';
        this.lastName = '';    
        this.template.querySelectorAll('lightning-input').forEach(inputElement => {
            inputElement.value = '';
        });           
    }

    handleAcountView(event)
    {
        // Navigate to account record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Account',
                actionName: 'view',
            },
        });
    }
}