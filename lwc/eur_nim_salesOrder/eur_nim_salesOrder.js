import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/eur_common_pubsub';
import { getRecord } from 'lightning/uiRecordApi';
import getPicklistVals from '@salesforce/apex/EUR_NIM_Service.getPicklistVals';
import getContactPersonIs from '@salesforce/apex/EUR_NIM_Service.getContactPersonIs';
import salesOrder from '@salesforce/label/c.EUR_NIM_SalesOrder';
import contactPerson from '@salesforce/label/c.EUR_NIM_ContactPerson';
import deliveryDate from '@salesforce/label/c.EUR_NIM_DeliveryDate';
import deliveryStreet from '@salesforce/label/c.EUR_NIM_DeliveryStreet';
import deliveryCity from '@salesforce/label/c.EUR_NIM_DeliveryCity';
import deliveryPostalCode from '@salesforce/label/c.EUR_NIM_DeliveryPostalCode';
import accountIsBlockedForSalesOrder from '@salesforce/label/c.EUR_NIM_AccountIsBlocked';
import accountMissingMasterdata from '@salesforce/label/c.EUR_NIM_MissingMasterdata'; 
import poType from '@salesforce/label/c.EUR_NIM_POType';
import deliveryTimeCode from '@salesforce/label/c.EUR_NIM_DeliveryTimeCode';

const FIELDS = [
    'EUR_CRM_Account__c.EUR_CRM_Order_Block__c',
    'EUR_CRM_Account__c.EUR_CRM_Country_Code__c',
    'EUR_CRM_Account__c.EUR_CRM_Delivery_details_Street__c',
    'EUR_CRM_Account__c.EUR_CRM_Delivery_details_City__c',
    'EUR_CRM_Account__c.EUR_CRM_Delivery_details_Postal_code__c',
    'EUR_CRM_Account__c.EUR_CRM_Address__c'
];
const JDEFIELDS = [
    'EUR_CRM_Account__c.EUR_CRM_ERPSoldToAccount__c'
];
export default class Eur_nim_salesOrder extends LightningElement {
    @api recordId;
    @track error;
    @wire(CurrentPageReference) pageRef;
    @wire(getPicklistVals, { objectName: 'EUR_CRM_Sales_Order__c', fieldName: 'EUR_NIM_DeliveryTimeCode__c'}) deliveryTimeCodeOptions;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS, optionalFields:JDEFIELDS }) account;

    contactPersonId;
    renderedCallback() {

        //prepopulate contact person
        this.getContactPersonIs();
    }
    
    getContactPersonIs() {
        getContactPersonIs({
            accId: this.recordId
        })
        .then((result) => {
            if (result) {
                this.contactPersonId = result;
                console.log('contactPersonId: ', this.contactPersonId);

                const inputFields = this.template.querySelectorAll(
                    'lightning-input-field'
                );
                //prepopulate Contact Person field
                if (inputFields) {
                    inputFields.forEach(field => {
                        if(field.fieldName == 'EUR_CRM_Contact_Person__c') {
                            if (this.contactPersonId != undefined) 
                            {
                                field.value = this.contactPersonId;
                            }
                        }
                    });
                }
            }
        })
        .catch(error => {
            if (error.body) 
            {
                console.error('getContactPersonIs error: ', JSON.stringify(error.body));
            } 
        })
        .finally(() => {
        })
    }

    isS7selected;

    @api
    refresh() 
    {
        this.accId = this.recordId;
    }

    get S7class()
    {
        return this.isS7selected ? 'slds-grid' : 'slds-hide';
    }

    get EUR_NIM_ERP_OrderType__c_default_value()
    {
        if (this.isInterfaceJDE)
        {
            return 'SO';
        }

        return '';
    }

    get isInterfaceSAP() 
    {
        console.log('account: ', JSON.stringify(this.account));
        console.log('account.data: ', JSON.stringify(this.account.data));
        //console.log('account.data.fields: ', JSON.stringify(this.account.data.fields));

        if (this.account && this.account.data && this.account.data.fields)
        {
            console.log('COUNTRY CODE: ', this.account.data.fields.EUR_CRM_Country_Code__c.value);
            return this.account.data.fields.EUR_CRM_Order_Block__c.value === null && (this.account.data.fields.EUR_CRM_Country_Code__c.value === "IDL" || this.account.data.fields.EUR_CRM_Country_Code__c.value === "DB");
        }
        return false;
    }

    get isBlockedAccount() 
    {
        if (this.account && this.account.data && this.account.data.fields && this.account.data.fields.EUR_CRM_Order_Block__c.value)
        {
            return this.account.data.fields.EUR_CRM_Order_Block__c.value.length !== 0 && (this.account.data.fields.EUR_CRM_Country_Code__c.value === "IDL" || this.account.data.fields.EUR_CRM_Country_Code__c.value === "DB" ) ;
        }
        return false;
    }

    get isMasterDataMissing() 
    {   
        if (this.account && this.account.data && this.account.data.fields && this.account.data.fields.EUR_CRM_Country_Code__c.value === "DE")
        {
            return this.account.data.fields.EUR_CRM_ERPSoldToAccount__c.value;
        }
        return true;
    }

    get isInterfaceJDE() 
    {
        if (this.account && this.account.data && this.account.data.fields)
        {
            return this.account.data.fields.EUR_CRM_Country_Code__c.value === "DE";
        }
        return false;
    }

    label = {
        salesOrder,
        contactPerson,
        deliveryDate,
        deliveryStreet,
        deliveryCity,
        deliveryPostalCode,
        accountIsBlockedForSalesOrder,
        poType,
        deliveryTimeCode,
        accountMissingMasterdata
    };

    get deliveryDetailsStreet() 
    {
        return this.account.data.fields.EUR_CRM_Delivery_details_Street__c.value;
    }

    get deliveryDetailsCity() 
    {
        return this.account.data.fields.EUR_CRM_Delivery_details_City__c.value;
    }

    get deliveryDetailsPostalCode() 
    {
        return this.account.data.fields.EUR_CRM_Delivery_details_Postal_code__c.value;
    }

    get deliveryDetailsAddress() 
    {
        return (this.account.data.fields.EUR_CRM_Address__c.value === null ? "" : this.account.data.fields.EUR_CRM_Address__c.value.substring(0, 255));
    }

    handleShareOrderData(event)
    {
        const recordToInsert = {};

        this.template.querySelectorAll('lightning-input, lightning-input-field, lightning-output-field, lightning-combobox').forEach(inputElement => {
            //console.log(inputElement.getAttribute("data-fieldapiname") + ':' + inputElement.value);
            
            if (inputElement.getAttribute("data-fieldapiname") == 'EUR_NIM_ERP_OrderType__c')
            {
                this.isS7selected = inputElement.value == 'S7';
            }

            recordToInsert[inputElement.getAttribute("data-fieldapiname")] = JSON.stringify({Value: inputElement.value})
        });

        fireEvent(this.pageRef, 'shareOrderData', recordToInsert);        
    }
}