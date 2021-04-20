import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getSKUs from '@salesforce/apex/ASI_CRM_VisitationPlaceOrderController.getSKUs';
import getWholesalers from '@salesforce/apex/ASI_CRM_VisitationPlaceOrderController.getWholesalers';
import saveIOT from '@salesforce/apex/ASI_CRM_VisitationPlaceOrderController.saveIOT';
import resource from "@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource";

export default class Asi_CRM_VisitationTaskPlaceOrderLWC extends NavigationMixin(LightningElement)
{
	@track hasRendered = false;
	@track loading = true;
	@track searching = false;
	@api customerID;
	@track showPlaceOrderPage = true;
	@track customer;
	@track wholesalers = [];
    @track displayDataList = [];
    @track selectedDataList = [];
    @track totalQuantity = 0;
    @track totalPrice = 0;
    @track disableCheckout = false;
    @track isModalOpen = false;
    @track disabledSearchField = false;
    @track rowCount = 0;
    @track searchText;
    @track searchMethod = 'all';
    @track filterButtonVariant = {
		all: 'brand',
		sku: 'brand-outline',
		sku_code: 'brand-outline',
		brand: 'brand-outline',
		brand_code: 'brand-outline',
		sub_brand: 'brand-outline',
		sub_brand_code: 'brand-outline'
	};

    @track limitPerPage = 10;
    @track totalPages = 1;
    @track currentPage = 1;
    @track disabledPrevious = true;
    @track disabledNext = true;

    @track showTotalPrice = false;
	@track warehouse;
	@track warehouseName;
    @track formContactName;
    @track formContactTelephone;
    @track formExpectedDeliveryDate;
    @track formRemark;
	@track disabledSubmit = false;
	@track resultObj = {};

	locationHashChanged()
	{
		this.init();
	}

	connectedCallback()
	{
		Promise.all([
			loadStyle(this, resource + '/sweetalert2.min.css'),
			loadStyle(this, resource + '/jquery-ui.min.css'),
			loadScript(this, resource + '/jquery.min.js'),
			loadScript(this, resource + '/jquery-ui.min.js'),
			loadScript(this, resource + '/sweetalert2.min.js')
		])
		.then(() => {
			window.addEventListener('onhashchange', this.locationHashChanged);
		});
	  }

	renderedCallback()
	{
		if (this.hasRendered)
		{
			return;
		}
		
		this.hasRendered = true;
		this.init();
	}
	
	init()
	{
		// var param = JSON.parse(this.getQueryParameters());
		// this.customerID = param.attributes.customerID;
		this.showPlaceOrderPage = true;
		this.selectedDataList = [];
		this.loadSKUs();
	}

	getQueryParameters()
	{
        var params = '{}';
        var encodedCompDef = window.location.hash;
		if (encodedCompDef)
		{
            var decodedstring = encodedCompDef.substring(1).replace(/%3D/g, '=');
            params = atob(decodedstring);
        }

        return params;
	}
	
	openModal()
	{
		if (this.searchMethod === 'all')
		{
            this.disabledSearchField = true;
		}
		else
		{
			this.disabledSearchField = false;
		}

		this.isModalOpen = true;
	}
	
	closeModal()
	{
		this.isModalOpen = false;
	}

	getFilteredSKU()
	{
		this.isModalOpen = false;
		this.currentPage = 1;
		this.loadSKUs();
	}

    handleFilterByClick(event) {
        var sMethod = event.target.name;
        this.searchMethod = sMethod;

        Object.keys(this.filterButtonVariant).forEach(key => {
            this.filterButtonVariant[key] = 'brand-outline';
        });
        this.filterButtonVariant[this.searchMethod] = 'brand';

		if (this.searchMethod === 'all')
		{
            this.disabledSearchField = true;
		}
		else
		{
			this.disabledSearchField = false;
		}
	}
	
	handleAddClick(event)
	{
        var recordId = event.target.name;
        var displayDataIndex = this.displayDataList.findIndex(data => data.sku.Id === recordId);
        var selectedDataIndex = this.selectedDataList.findIndex(data => data.sku.Id === recordId);

		if (displayDataIndex >= 0)
		{
            this.displayDataList[displayDataIndex].quantity += 1;

			if (selectedDataIndex < 0)
			{
                this.selectedDataList.push({
                    sku: this.displayDataList[displayDataIndex].sku,
                    quantity: this.displayDataList[displayDataIndex].quantity
                }); 
			}
			else
			{
                this.selectedDataList[selectedDataIndex].quantity = this.displayDataList[displayDataIndex].quantity;
            }
    
            this.refreshTotalQuantity();
        }
	}
	
	handleMinusClick(event)
	{
        var recordId = event.target.name;
        var displayDataIndex = this.displayDataList.findIndex(data => data.sku.Id === recordId);
        var selectedDataIndex = this.selectedDataList.findIndex(data => data.sku.Id === recordId);

		if (displayDataIndex >= 0)
		{
			if (this.displayDataList[displayDataIndex].quantity > 0)
			{
                this.displayDataList[displayDataIndex].quantity -= 1;

				if (selectedDataIndex >= 0)
				{
					if (this.displayDataList[displayDataIndex].quantity > 0)
					{
                        this.selectedDataList[selectedDataIndex].quantity = this.displayDataList[displayDataIndex].quantity;
					}
					else
					{
                        this.selectedDataList.splice(selectedDataIndex, 1);
                    }                   
                }
        
                this.refreshTotalQuantity();
            }
        }
	}

	handleQuantityBlur(event)
	{
        var recordId = event.target.name;
        var value = parseInt(event.target.value, 10);

        var displayDataIndex = this.displayDataList.findIndex(data => data.sku.Id === recordId);
        var selectedDataIndex = this.selectedDataList.findIndex(data => data.sku.Id === recordId);

		if (displayDataIndex >= 0)
		{
            this.displayDataList[displayDataIndex].quantity = value;

            if (selectedDataIndex < 0) {
                this.selectedDataList.push({
                    sku: this.displayDataList[displayDataIndex].sku,
                    quantity: this.displayDataList[displayDataIndex].quantity
                }); 
			}
			else
			{
                this.selectedDataList[selectedDataIndex].quantity = this.displayDataList[displayDataIndex].quantity;
            }
        }
        
        this.refreshTotalQuantity();
	}

	refreshTotalQuantity()
	{
        var selectedDataQtyPrice = this.selectedDataList.map(data => ({ 
            quantity: data.quantity,
            price: data.sku.ASI_HK_CRM_Base_Price__c
        }));

        this.totalQuantity = selectedDataQtyPrice.reduce((total, value) => total + value.quantity, 0);
		this.totalPrice = selectedDataQtyPrice.reduce((total, value) => total + value.price || 0, 0);
		this.showTotalPrice = this.totalPrice > 0;
		this.disableCheckout = this.totalQuantity === 0;
	}
	
	handlePageBlur(event)
	{
		var reload = false;
		var oldPage = this.currentPage;
		var iPage = parseInt(event.target.value, 10);
		this.currentPage = iPage;

		if (isNaN(iPage) || iPage <= 1)
		{
			if (oldPage != 1)
			{
				reload = true;
			}

			this.currentPage = 1;
		}
		else if (iPage > this.totalPages)
		{
			if (oldPage != this.totalPages)
			{
				reload = true;
			}

			this.currentPage = this.totalPages;
		}
		else
		{
			if (oldPage != this.currentPage)
			{
				reload = true;
			}

			this.currentPage = iPage;
		}

		if (reload)
		{
			this.loadSKUs();
		}
	}
	
	handlePageClick(event)
	{
        var name = event.target.name;
		
		if (name === 'previous' && this.currentPage > 1)
		{
            this.currentPage--;
		}

		if (name === 'next' && this.currentPage < this.totalPages)
		{
            this.currentPage++;
        }

		this.disabledPrevious = this.currentPage <= 1 || this.currentPage > this.totalPages;
		this.disabledNext = this.currentPage >= this.totalPages || this.currentPage < 1;
		this.loadSKUs();
	}

	navigateToCheckout()
	{
		this.showPlaceOrderPage = false;
		this.toTop();
	}

	toTop(event)
	{
		window.scroll({ top: 0});
	}
	
	searchWholesalers(event)
    {
		var searchStr = event.target.value;
		this.warehouseName = searchStr;

        if (this.warehouse != null && this.warehouse.name != searchStr)
        {
			this.warehouse = null;
        }

        if (searchStr != undefined && searchStr != null && searchStr != '' && searchStr.length >= 2)
        {
			this.searching = true;
			var param = {
				name: searchStr
			};
			getWholesalers(param)
				.then(result => {
					if (result && this.searching)
					{
						this.wholesalers = result;
					}

					this.searching = false;
				}).catch(error => {
					console.log('Error: '+ error.body.message);
					this.searching = false;
				});
        }
        else
        {
			this.wholesalers = [];
			this.searching = false;
		}
	}
	
	get getSearchStr()
	{
		if (this.warehouse != null)
		{
			return this.warehouse.name;
		}

		return this.warehouseName;
	}

	get wholeSalerCount()
	{
		return this.wholesalers.length;
	}

    selectWholesaler(event)
    {
		var vID = event.target.dataset.id;
		var vName = event.target.dataset.name;
		this.warehouse = { id: vID, name: vName };
		this.warehouseName = vName;
		this.wholesalers = [];
	}

	updateSearchText(event)
	{
		this.searchText = event.target.value;
	}

	updateName(event)
	{
		this.formContactName = event.target.value;
	}

	updateTelephone(event)
	{
		this.formContactTelephone = event.target.value;
	}

	updateDeliveryDate(event)
	{
		this.formExpectedDeliveryDate = event.target.value;
	}

	updateRemark(event)
	{
		this.formRemark = event.target.value;
	}

	submit()
	{
		this.disabledSubmit = true;
		this.loading = true;
		var param = {
            iotHeaderStr: JSON.stringify({
                ASI_CRM_ContactNumber__c: this.formContactTelephone,
                ASI_CRM_ContactPerson__c: this.formContactName,
                ASI_CRM_Customer__c: this.customer.Id,
                ASI_CRM_Wholesaler__c: this.warehouse ? this.warehouse.id : null,
                ASI_CRM_ExpectedDeliveryDate__c: this.formExpectedDeliveryDate,
                ASI_CRM_Remarks__c: this.formRemark
            }),
            iotDetailsStr: JSON.stringify(this.selectedDataList.map(data => ({
                ASI_CRM_Quantity__c: data.quantity,
                ASI_CRM_SKU__c: data.sku.Id
            }))),
        }

		saveIOT(param)
			.then(result => {
				if (result)
				{
					if (result == 'success')
					{
						this.resultObj = {
							type: 'success',
							message: 'Order Saved'
						};
					}
					else
					{
						this.resultObj = {
							type: 'error',
							message: result
						};		
					}
				}
			}).catch(error => {
				this.resultObj = {
					type: 'error',
					message: error.body.message
				};
			}).finally(() => {
				swal.fire({
					type: this.resultObj.type,
					title: 'Submit Order',
					text: this.resultObj.message,
					confirmButtonColor: '#3085d6',
					cancelButtonColor: '#d33',
					confirmButtonText: 'OK'
				})
				.then(() => {
					if (this.resultObj.type == 'success')
					{
						// this.warehouse = null;
						// this.warehouseName = null;
                        // this.formContactName = null;
                        // this.formContactTelephone = null;
                        // this.formExpectedDeliveryDate = null;
						// this.formRemark = null;
						// this.selectedDataList = [];
						// this.showPlaceOrderPage = true;
						// this.loadSKUs();
						window.history.back();
					}
					
					this.loading = false;
					this.disabledSubmit = false;
				});
			});
	}
	
	loadSKUs()
	{
		this.loading = true;
		var param = {
			customerId: this.customerID,
			searchText: this.searchText,
            searchMethod: this.searchMethod,
            limitPerPage: this.limitPerPage,
            offset: (this.currentPage - 1) * this.limitPerPage
		}

		getSKUs(param)
			.then(result => {
				if (result)
				{
					this.totalPages = Math.ceil(result.total / this.limitPerPage);
                	var displayDataList = result.skuList.map(sku => {
                    var selectedDataIndex = this.selectedDataList.findIndex(data => data.sku.Id === sku.Id);
						return {
							sku,
							quantity: selectedDataIndex >= 0 ? this.selectedDataList[selectedDataIndex].quantity : 0
						}
					});

					if (this.totalPages === 0)
					{
						this.totalPages = 1;
					}

					this.customer = result.customer;
					this.displayDataList = displayDataList;
					this.rowCount = displayDataList.length;
					this.disabledPrevious = this.currentPage <= 1 || this.currentPage > this.totalPages;
					this.disabledNext = this.currentPage >= this.totalPages || this.currentPage < 1;
					this.formContactName = result.customer.ASI_CRM_CN_Contact_Person__c;
					this.formContactTelephone = result.customer.ASI_CRM_CN_Phone_Number__c;
					this.loading = false;
					this.refreshTotalQuantity();
				}
			}).catch(error => {
				swal.fire({
					type: 'error',
					title: 'Filter SKU',
					text: error.body.message,
					confirmButtonColor: '#3085d6',
					cancelButtonColor: '#d33',
					confirmButtonText: 'OK'
				});
				this.loading = false;
			});
    }
}