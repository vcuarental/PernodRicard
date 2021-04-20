import { LightningElement, wire, track, api } from 'lwc';
import { registerListener, fireEvent, unregisterAllListeners } from 'c/eur_common_pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import createOrder from '@salesforce/apex/EUR_NIM_Service.createSalesOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import calculatePrice from '@salesforce/apex/EUR_NIM_Service.calculatePrice';
import calculateInventory from '@salesforce/apex/EUR_NIM_Service.calculateInventory';
//import getInvEndpoint from '@salesforce/apex/EUR_NIM_Service.getInvServiceEndpoint';
import getPicklistVals from '@salesforce/apex/EUR_NIM_Service.getPicklistVals';
import { getRecord } from 'lightning/uiRecordApi';
import salesOrderLines from '@salesforce/label/c.EUR_NIM_SalesOrderLines';
import calcPrice from '@salesforce/label/c.EUR_NIM_CalculatePrice';
import checkInvetory from '@salesforce/label/c.EUR_NIM_CheckInvetory';
import createSalesOrder from '@salesforce/label/c.EUR_NIM_CreateSalesOrder';
import createSalesOrderSendToERP from '@salesforce/label/c.EUR_NIM_CreateSalesOrderAndSendToERP';
import action from '@salesforce/label/c.EUR_NIM_Action';
import quantity from '@salesforce/label/c.EUR_NIM_Quantity';
import productName from '@salesforce/label/c.EUR_NIM_ProductName';
import unitType from '@salesforce/label/c.EUR_NIM_UnitType';
import freeQuantity from '@salesforce/label/c.EUR_NIM_FreeQuantity';
import price from '@salesforce/label/c.EUR_NIM_Price';
import totalPrice from '@salesforce/label/c.EUR_NIM_TotalPrice';
import stockInfo from '@salesforce/label/c.EUR_NIM_StockInfo';
import totalOrderPriceLabel from '@salesforce/label/c.EUR_NIM_TotalOrderPrice';
import errorLabel from '@salesforce/label/c.EUR_NIM_Variant_Error';
import successLabel from '@salesforce/label/c.EUR_NIM_Variant_Success';
import infoLabel from '@salesforce/label/c.EUR_NIM_Variant_Info';
import createSOTitleLabel from '@salesforce/label/c.EUR_NIM_CreateSalesOrderTitle';
import createSORequiredLabel from '@salesforce/label/c.EUR_NIM_CreateSORequiredFieldsMessage';
import createSODERequiredLabel from '@salesforce/label/c.EUR_NIM_CreateSODERequiredFieldsMessage';
import createSORequiredProductLabel from '@salesforce/label/c.EUR_NIM_CreateSORequiredProductMessage';
import quantityValidationLabel from '@salesforce/label/c.EUR_NIM_QuantityValidation';
import inventoryValidationLabel from '@salesforce/label/c.EUR_NIM_InventoryValidation';
import quantityStockValidationLabel from '@salesforce/label/c.EUR_NIM_QuantityStockValidation';
import createSOSuccessMessageLabel from '@salesforce/label/c.EUR_NIM_CreateSOSuccessMessage';
import createSOFailureMessageLabel from '@salesforce/label/c.EUR_NIM_CreateSOFailureMessage';
import calculatePriceErrorLabel from '@salesforce/label/c.EUR_NIM_CalculatePriceError';
import checkInvetoryErrorLabel from '@salesforce/label/c.EUR_NIM_CheckInvetoryError';
//import DeliveryTimeCode from '@salesforce/label/c.EUR_NIM_DeliveryTimeCode';
import palletTypeCode from '@salesforce/label/c.EUR_NIM_PalletTypeCode';

const FIELDS = [
    'EUR_CRM_Account__c.EUR_CRM_Order_Block__c',
    'EUR_CRM_Account__c.EUR_CRM_Country_Code__c',
];

export default class Eur_nim_productPickerSelectedProductList extends LightningElement {
    @api recordId;
    @track selectedItems = [];
    @track recordToInsert = [];
    @track transactionInProgress = true;
    @track totalOrderPrice = 0;
    @track freeQuantity = 0;
    @track quantity = 0;
    @track priceBookMap = new Map(); 
    @track productDealMap = new Map(); 

    @wire(CurrentPageReference) pageRef;
    //@wire(getInvEndpoint, { recordId: '$recordId' }) inventoryEndpoint;
    @wire(getPicklistVals, { objectName: 'EUR_CRM_Sales_Order_Items__c', fieldName: 'EUR_CRM_Unit_Type__c'}) unitTypeOptions;
    @wire(getPicklistVals, { objectName: 'EUR_CRM_Sales_Order_Items__c', fieldName: 'EUR_NIM_PalletTypeCode__c'}) palletTypeCodeOptions;
    //@wire(getPicklistVals, { objectName: 'EUR_CRM_Sales_Order_Items__c', fieldName: 'EUR_NIM_DeliveryTimeCode__c'}) deliveryTimeCodeOptions;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    account;
    inputElInd = 1;
    indOfEl = 0;
    recalculateInputFocus = true;

    label = {
        salesOrderLines,
        calcPrice,
        checkInvetory,
        createSalesOrder,
        action,
        quantity,
        productName,
        unitType,
        freeQuantity,
        price,
        totalPrice,
        stockInfo,
        totalOrderPriceLabel,
        createSalesOrderSendToERP,
        errorLabel, 
        successLabel,
        infoLabel,
        createSOTitleLabel,
        createSORequiredLabel,
		createSODERequiredLabel,
        createSORequiredProductLabel,
        quantityValidationLabel,
        inventoryValidationLabel,
        quantityStockValidationLabel,
        createSOSuccessMessageLabel,
        createSOFailureMessageLabel,
        calculatePriceErrorLabel,
        checkInvetoryErrorLabel,
        //DeliveryTimeCode,
        palletTypeCode
    }
    async connectedCallback() 
    {
        registerListener('addProductsToSelection', this.handleAddProductsToSelection, this);
        registerListener('shareOrderData', this.handleShareOrderData, this);
    }

    renderedCallback() {

        if (this.recalculateInputFocus) { 
            this.template.querySelectorAll('lightning-input').forEach(inputElement => {
                inputElement.focus();
            });
        }
        else {
            this.recalculateInputFocus = true;
        }
    }

    disconnectedCallback() {
        // unsubscribe from searchKeyChange event
        unregisterAllListeners(this);
    }

    handleAddProductsToSelection(selectedItems)
    {
        for( var i = 0; i < selectedItems.length; i++)
        {
            var flag = true;
            if(this.selectedItems.length> 0)
            {
                for(var j = 0; j < this.selectedItems.length; j++)
                {
                    if(selectedItems[i].productCodeIsDeal == this.selectedItems[j].productCodeIsDeal && 
                        !selectedItems[i].isDeal && !this.selectedItems[j].isDeal)
                    {
                        flag = false;
                        let inputElement = this.template.querySelector(`lightning-input[data-id="${selectedItems[i].productCodeIsDeal}"]`);
                        if (inputElement) {
                            inputElement.focus();
                        }
                    }            
                }
                if(flag)
                {
                    this.selectedItems.push(selectedItems[i]);
                }
            }
            else
            {
                this.selectedItems.push(selectedItems[i]);
            }   
        }

        for( var i = 0; i < selectedItems.length; i++)
        {
            if (selectedItems[i].isDeal == false) 
            {
                var productDealConts = selectedItems[i].productDealMap;
                for (var p in productDealConts) 
                {
                    this.productDealMap.set(p, productDealConts[p]);
                }

                var priceBookConts = selectedItems[i].priceBookMap;
                for (var p in priceBookConts) 
                {
                    this.priceBookMap.set(p, priceBookConts[p]);
                }   
            }
        }

        //console.log("test avi selectedItems: ", JSON.stringify(selectedItems));
        /*var ifDeal = selectedItems[0].productCodeIsDeal;
        console.log("test avi ifDeal: ", ifDeal);

        if(ifDeal.includes("true"))
        {
            var productDealConts = selectedItems[0].productDealMap;
            console.log('test avi productDealConts: ', JSON.stringify(productDealConts));
            for (var p in productDealConts) 
            {
                this.productDealMap.set(p, productDealConts[p]);
            }
        
            var priceBookConts = selectedItems[0].priceBookMap;
            for (var p in priceBookConts) 
            {
                this.priceBookMap.set(p, priceBookConts[p]);
            }            
            this.updateFreeQuantityWhenDealApplied();
        }*/
        this.updateFreeQuantityWhenDealApplied();
        
    }

    handleShareOrderData(recordToInsert)
    {
        this.recordToInsert = recordToInsert; 
    }

    showToastMessage(title, message, variant)
    {
        const validation = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(validation);
    }
    
    getAllProductOfDealFromProductCode(productCode)
    {
        //var productCode = this.selectedItems[i].productCode;

        //return an empty map is there is no value 
        if (!this.productDealMap.has(productCode)) return new Map();

        var dealWrapper = this.productDealMap.get(productCode);
        var dealId = dealWrapper.dealId;

        var productsInDealMap = new Map();
        for(var ele of this.productDealMap.keys())
        {
            var productInDealAND =  this.productDealMap.get(ele);
            if(dealId == productInDealAND.dealId)
            {
                productsInDealMap.set(productInDealAND.productCode, productInDealAND.productCode);
            }
        }
        return productsInDealMap;
    }

    checkValidation()
    {
        if(Object.keys(this.recordToInsert).length == 0 && (this.account.data.fields.EUR_CRM_Country_Code__c.value === "IDL" || this.account.data.fields.EUR_CRM_Country_Code__c.value === "DB"))
        {
            this.showToastMessage(createSOTitleLabel, createSORequiredLabel, infoLabel);
            return false;
        }
		else if(Object.keys(this.recordToInsert).length == 0 && (this.account.data.fields.EUR_CRM_Country_Code__c.value === "DE"))
		{
			this.showToastMessage(createSOTitleLabel, createSODERequiredLabel, infoLabel);
            return false;
		}
        for (var k in this.recordToInsert)
        {
            if(this.account.data.fields.EUR_CRM_Country_Code__c.value === "IDL" || this.account.data.fields.EUR_CRM_Country_Code__c.value === "DB")
            {
                if(k == 'EUR_CRM_Delivery_Date__c' || k == 'EUR_CRM_Contact_Person__c' || k == 'EUR_NIM_POType__c')
                {
                    var value = this.recordToInsert[k].split(':')[1];
                    if(value.includes("null") || value.includes("undefined") || value.includes('""'))
                    {
                        this.showToastMessage(createSOTitleLabel, createSORequiredLabel, infoLabel);
                        return false;
                    }
                }
            }
            else
            {
                if(k == 'EUR_CRM_Delivery_Date__c' || k == 'EUR_CRM_Contact_Person__c')
                {
                    var value = this.recordToInsert[k].split(':')[1];
                    if(value.includes("null") || value.includes("undefined") || value.includes('""'))
                    {
                        this.showToastMessage(createSOTitleLabel, createSODERequiredLabel, infoLabel);
                        return false;
                    }
                }
            }
            
            if(value)
            {
                value = value.slice(1, value.length-2);
            }
        }

        if(this.selectedItems.length == 0)
        {
            this.showToastMessage(createSOTitleLabel, createSORequiredProductLabel, infoLabel);
            return false;
        }

        for (var i in this.selectedItems) 
        {
            if(this.selectedItems[i].isDeal == false)
            {
                var quantity = this.selectedItems[i].quantity;
                var inventoryAmount = this.selectedItems[i].productStockInfo;
                if (quantity == null || quantity == undefined || quantity == "" || quantity == 0 || quantity < 0) 
                {
                    this.showToastMessage(createSOTitleLabel, quantityValidationLabel, infoLabel);
                    return false;
                }                
            }
            
            /*if (this.inventoryEndpoint.data != window.undefined) 
            {
                if (inventoryAmount == null || inventoryAmount == window.undefined || inventoryAmount == "" || inventoryAmount == 0 || inventoryAmount < 0)
                {
                    this.showToastMessage(createSOTitleLabel, inventoryValidationLabel, infoLabel);
                    return false;   
                }
                else if (quantity > inventoryAmount)
                {
                    this.showToastMessage(createSOTitleLabel, quantityStockValidationLabel + inventoryAmount + '!', infoLabel);
                    return false;               
                }
            }*/
        }
        return true;
    }

    handleCreateOrder(event)
    {
        var validationResult = this.checkValidation();
        if(validationResult == false)
        {
            return;
        }

        this.transactionInProgress = false;
        createOrder({recInsert: this.recordToInsert, status:'Draft', accId: this.recordId, salesOrderLineItemList: this.selectedItems }) 
            .then(result => {
                this.showToastMessage(createSOTitleLabel, createSOSuccessMessageLabel, this.label.successLabel);
                this.transactionInProgress = true;
                location.reload();
            })
            .catch(error => {
                this.error = error;  
                this.showToastMessage(createSOFailureMessageLabel, this.error.body.message, this.label.errorLabel); 
                this.transactionInProgress = true;                
            });
    }

    handleCreateOrderSendToERP(event)
    {
        var validationResult = this.checkValidation();
        if(validationResult == false)
        {
            return;
        }

        this.transactionInProgress = false;
        createOrder({recInsert: this.recordToInsert, status:'Send To ERP', accId: this.recordId, salesOrderLineItemList: this.selectedItems }) 
            .then(result => {
                this.showToastMessage(createSOTitleLabel, createSOSuccessMessageLabel, this.label.successLabel);
                this.transactionInProgress = true;
                location.reload();
            })
            .catch(error => {
                this.error = error;  
                this.showToastMessage(createSOFailureMessageLabel, this.error.body.message, this.label.errorLabel); 
                this.transactionInProgress = true;
            });
    }

    handleRemove(event)
    {
        const productCodeIsDeal = event.target.value;
        const dealName = event.target.dataset.dealname;
        console.log('productCodeIsDeal: ', productCodeIsDeal);
        console.log('dealName: ', dealName);

        for( var i = 0; i < this.selectedItems.length; i++)
        { 
            if (productCodeIsDeal == this.selectedItems[i].productCodeIsDeal && 
                this.selectedItems[i].dealName == dealName) 
            {
                if(this.selectedItems[i].isDeal == false)
                {
                    var mainProdCode = this.selectedItems[i].productCode;
                    this.selectedItems.splice(i, 1);

                    var j = this.selectedItems.length - 1;
                    while (j > -1)
                    {
                        if(this.selectedItems[j].isDeal == true && 
                            this.selectedItems[j].productDealMap[mainProdCode] != undefined && 
                            this.selectedItems[j].dealName == dealName)
                        {
                            this.selectedItems.splice(j, 1);           
                        }
                        j--;
                    }
                }
                else
                {
                    this.selectedItems.splice(i, 1);                      
                }
            }
        }
    }
    
    setQuantity(event)
    {
        const productCodeIsDeal = event.target.name;
        const dealName = event.target.dataset.dealname;
        console.log('dealName: ', dealName);

        for (var i in this.selectedItems) 
        {
            if (this.selectedItems[i].productCodeIsDeal == productCodeIsDeal && this.selectedItems[i].dealName == dealName)
            {
                this.indOfEl = i;
            }
        }

        if (dealName) {
            this.recalculateInputFocus = false;
        }

        if(event.which == 13)
        {
            //if this is a last element - jump to the 'Search Products' section
            if (this.indOfEl == this.selectedItems.length - 1) 
            {
                fireEvent(this.pageRef, 'setProductNumberFocus');
                this.inputElInd = 1;
            }
            //if this is not the last element - jump to the next input
            else 
            {  
                console.log('inputElInd: ', this.inputElInd);
                var listOfInputs = this.template.querySelectorAll('lightning-input');
                var inp = listOfInputs[this.inputElInd];
                if (inp) {
                    inp.focus();
                    this.inputElInd++;
                }
            }
        }

        for (var i in this.selectedItems) 
        {            
            if (this.selectedItems[i].productCodeIsDeal == productCodeIsDeal && 
                this.selectedItems[i].dealName == dealName)
            {
                this.selectedItems[i].quantity = event.target.value;
                var productCode = this.selectedItems[i].productCode;
                var productQuantity = this.selectedItems[i].quantity;
                                
                if(this.productDealMap.size > 0 && this.productDealMap.has(productCode))
                {
                    var productInDeal = this.productDealMap.get(productCode);
                    if(productQuantity >= productInDeal.quantity)
                    {
                        //if(this.priceBookMap.size > 0 && this.priceBookMap.has(productCode))
                        if(this.priceBookMap.size > 0)
                        {
                            if(productInDeal.dealLogic == 'AND')
                            {                               
                                this.updateFreeQuantityWhenDealLogicAND(productCode, dealName);
                            }
                            else if(productInDeal.dealLogic == 'OR')
                            {
                                var freeDealQuantity = this.priceBookMap.get(productCode);
                                var freeQuantity = 0;
                                if(productInDeal.isMultiply)
                                {
                                    var multipleNumber = Math.floor(productQuantity/productInDeal.quantity);
                                    freeQuantity = freeDealQuantity.quantity * multipleNumber;                            
                                }
                                else
                                {
                                    freeQuantity = freeDealQuantity.quantity;
                                }
                                for (var i in this.selectedItems) 
                                {
                                    if(this.selectedItems[i].productCode == productCode && this.selectedItems[i].isDeal == true)
                                    {
                                        this.selectedItems[i].productFreeQuantity = freeQuantity;
                                        break;  
                                    }                                    
                                }                         
                            }
                        }
                    }
                    else
                    {
                        var productsInDealMap = this.getAllProductOfDealFromProductCode(productCode);
                        for (var i in this.selectedItems) 
                        {
                            if(this.selectedItems[i].isDeal == true && this.selectedItems[i].dealName == dealName)
                            //if(productsInDealMap.has(this.selectedItems[i].productCode) && this.selectedItems[i].isDeal == true)
                            {
                                if (this.selectedItems[i].productDealMap[productCode] === undefined) continue;
                                if (this.selectedItems[i].productDealMap[productCode].productCode == productCode) 
                                {
                                    this.selectedItems[i].productFreeQuantity = 0;
                                }
                            }
                        }
                    }
                }
                break; //Stop this loop, we found it!
            }
        } 
    }

    updateFreeQuantityWhenDealLogicAND(productCode, dealName)
    {
        //Search for other products of same deal in this.productDealMap
        var productsInDealMap = this.getAllProductOfDealFromProductCode(productCode);
                                        
        //Check if all products from deal are selected
        var selectedItemsQuantity = new Map();
        for(var key of productsInDealMap.keys())
        {
            var dealMapProductCode =  productsInDealMap.get(key);
            for (var lineItemWrapper in this.selectedItems) 
            {
                if(this.selectedItems[lineItemWrapper].productCode == dealMapProductCode && this.selectedItems[lineItemWrapper].isDeal == false)
                {
                    selectedItemsQuantity.set(this.selectedItems[lineItemWrapper].productCode, this.selectedItems[lineItemWrapper].quantity);
                }
            }
        }

        //Check if all products from deals are selected by checking size
        if(selectedItemsQuantity.size == productsInDealMap.size)
        {
            var isAllFound = false;
            var selectedItemsCopy = JSON.parse(JSON.stringify(this.selectedItems));
            //Check if all products satisfies quantity condition

            for(var key of productsInDealMap.keys())
            {
                if(this.productDealMap.has(productsInDealMap.get(key)))
                {
                    //DealWrapper productInDeal =  this.productDealMap.get(key);
                    isAllFound = false;
                    
                    for(var lineItemWrapper in selectedItemsCopy)
                    {                        
                        if(selectedItemsCopy[lineItemWrapper].productCode == productsInDealMap.get(key) && 
                            selectedItemsCopy[lineItemWrapper].isDeal == false &&
                            selectedItemsCopy[lineItemWrapper].quantity >= this.productDealMap.get(key).quantity &&
                            selectedItemsCopy[lineItemWrapper].dealName == dealName)
                        {
                            var multipleNumber = 1;
                            var perProductInDeal = this.productDealMap.get(selectedItemsCopy[lineItemWrapper].productCode);

                            if(perProductInDeal.isMultiply)
                            {
                                multipleNumber = Math.floor(selectedItemsCopy[lineItemWrapper].quantity/perProductInDeal.quantity);                          
                            }
                            for (var i in selectedItemsCopy) 
                            {
                                //if(selectedItemsCopy[lineItemWrapper].productCode == productsInDealMap.get(key) && selectedItemsCopy[i].isDeal == true)
                                if(productsInDealMap.get(key) && selectedItemsCopy[i].isDeal == true && selectedItemsCopy[i].dealName == dealName)
                                {
                
                                    if (selectedItemsCopy[i].productDealMap[productCode] === undefined) continue;
            
                                    var prodCode = selectedItemsCopy[i].productCode;
                                    var freeQty = selectedItemsCopy[i].priceBookMap[prodCode].quantity;
                                    selectedItemsCopy[i].productFreeQuantity = multipleNumber * freeQty;
                                    
                                }                                    
                            }
                            isAllFound = true;                                        
                        }
                    }
                    if(isAllFound == false)
                    {
                        break;
                    }                                    
                }
            }
            if(isAllFound == true)
            {
                this.selectedItems = selectedItemsCopy;
            }
        }        
    }
    updateFreeQuantityWhenDealApplied()
    {
        for(var product of this.productDealMap.keys())
        {
            var productInDeal =  this.productDealMap.get(product);
            if(productInDeal.dealLogic == 'AND')
            {
                this.updateFreeQuantityWhenDealLogicAND(productInDeal, productCode);
            }
            else if(productInDeal.dealLogic == 'OR')
            {
                for (var i in this.selectedItems) 
                {
                    if(this.selectedItems[i].productCodeIsDeal == productInDeal.productCode + 'false'
                        && this.selectedItems[i].quantity > 0)
                    {
                        var freeDealQuantity =  this.priceBookMap.get(productInDeal.productCode);
						var freeQuantity = 0;
                        if(productInDeal.isMultiply)
						{
                            var multipleNumber = Math.floor(this.selectedItems[i].quantity/productInDeal.quantity);
                            freeQuantity = freeDealQuantity.quantity * multipleNumber;  
                        }
                        else
                        {
                            freeQuantity = freeDealQuantity.quantity;
                        }
                        for (var i in this.selectedItems) 
                        {
                            if(this.selectedItems[i].productCode == productInDeal.productCode && 
                                this.selectedItems[i].isDeal == true && 
                                this.selectedItems[i].dealName == dealName)
                            {
                                this.selectedItems[i].productFreeQuantity = freeQuantity;
                            }                                    
                        }
                        return;
                    }
                }
            }
        }
    }

    setUnitType(event)
    {
        const productCodeIsDeal = event.target.name;
        for (var i in this.selectedItems) 
        {
            if (this.selectedItems[i].productCodeIsDeal == productCodeIsDeal) {
                this.selectedItems[i].productUnitType = event.target.value;                
            break; //Stop this loop, we found it!
            }
        }            
    }

    setpalletTypeCode(event)
    {
        const productCodeIsDeal = event.target.name;
        for (var i in this.selectedItems) 
        {
            if (this.selectedItems[i].productCodeIsDeal == productCodeIsDeal) {
                this.selectedItems[i].palletTypeCode = event.target.value;
            break; //Stop this loop, we found it!
            }
        }            
    }

    handleCalculatePrice(event)
    {
        this.transactionInProgress = false;
        calculatePrice({recordId: this.recordId, salesOrderLineItemList: this.selectedItems})
        .then(result => {
            this.selectedItems = result;
            this.totalOrderPrice = 0;
            //Form Total order price
            for( var i = 0; i < this.selectedItems.length; i++)
            {
                this.totalOrderPrice = this.totalOrderPrice + this.selectedItems[i].productTotalPrice;
            }
            this.transactionInProgress = true;
        })
        .catch(error => {
            this.error = error;  
            this.showToastMessage(calculatePriceErrorLabel, this.error.body.message, this.label.errorLabel); 
            this.transactionInProgress = true;
        });
    }

    handleInventory()
    {
        this.transactionInProgress = false;
        calculateInventory({recordId: this.recordId, salesOrderLineItemList: this.selectedItems})
        .then(result => {
            this.selectedItems = result;   
            this.transactionInProgress = true;         
        })
        .catch(error => {
            this.error = error;  
            this.showToastMessage(checkInvetoryErrorLabel, this.error.body.message, this.label.errorLabel); 
            this.transactionInProgress = true;
        });
    }

    get isAccountSAP() 
    {
       if (this.account && this.account.data && this.account.data.fields)
       {
           return(this.account.data.fields.EUR_CRM_Country_Code__c.value === "IDL" || this.account.data.fields.EUR_CRM_Country_Code__c.value === "DB");            
       }
       return false;
   }

   get isAccountJDE() 
   {
       if (this.account && this.account.data && this.account.data.fields)
       {
           return this.account.data.fields.EUR_CRM_Country_Code__c.value === "DE";
       }
       return false;
   }
}