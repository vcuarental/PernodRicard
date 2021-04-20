import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getPreviousOrders from '@salesforce/apex/ASI_CRM_VisitationPreviousOrdersCtr.getPreviousOrders';
import resource from "@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource";

export default class Asi_CRM_VisitationPreviousOrdersLWC extends NavigationMixin(LightningElement)
{
	@track hasRendered = false;
	@track loading = true;
	@api customerID;
	@track displayDataList;
    @track rowCount = 0
    @track limitPerPage = 10;
    @track totalPages = 1;
    @track currentPage = 1;
    @track disabledPrevious = true;
    @track disabledNext = true;

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
		this.loadPreviousOrders();
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
			this.loadPreviousOrders();
		}
	}

	handlePageClick(event)
	{
		var name = event.target.name;
			
		if (name === 'previous' && this.currentPage > 1)
		{
			this.currentPage--;
		}
		if (name === 'next' && this.currentPage < this.totalPages) {
			this.currentPage++;
		}

		this.disabledPrevious = this.currentPage === 1;
		this.disabledNext = this.currentPage === this.totalPages;
		this.loadPreviousOrders();
	}

	navigateToOrderDetails(event)
	{
		var orderID = event.currentTarget.dataset.id;
        // var compDefinition = {
        //     componentDef: 'c:asi_CRM_VisitationOrderDetailsLWC',
        //     attributes: {
		// 		orderID: orderID,
        //     }
        // };
        // // Base64 encode the compDefinition JS object
        // var encodedCompDef = btoa(JSON.stringify(compDefinition));
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef
        //     }
		// });

		this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_VisitationOrderDetails_Route"
            },
            state: {
                c__oid: orderID
            }
        });
	}

	loadPreviousOrders()
	{
		this.loading = true;
		var param = {
			customerId: this.customerID,
			limitPerPage: this.limitPerPage,
            offset: (this.currentPage - 1) * this.limitPerPage
		}

		getPreviousOrders(param)
			.then(result => {
				if (result)
				{
					this.totalPages = Math.ceil(result.total / this.limitPerPage);
					this.displayDataList = result.iotHeaders.map((iotHeader, index) => {
						var iotDetails = result.iotDetails.filter(d => d.ASI_CRM_IOTHeader__c === iotHeader.Id);
						var numOfItems = iotDetails.reduce((total, value) => total + value.ASI_CRM_Quantity__c, 0);
						var totalPrice = iotDetails.reduce((total, value) => total + value.ASI_CRM_SKU__r.ASI_HK_CRM_Base_Price__c || 0, 0);

						return {
							id: iotHeader.Id,
							numOfItems: numOfItems,
							totalPrice: totalPrice,
							showPrice: totalPrice > 0,
							createdDate: iotHeader.CreatedDate
						}
					});

					if (this.totalPages === 0) {
						this.totalPages = 1;
					}

					this.rowCount = this.displayDataList.length;
					this.disabledPrevious = this.currentPage <= 1 || this.currentPage > this.totalPages;
					this.disabledNext = this.currentPage >= this.totalPages || this.currentPage < 1;
					this.loading = false;
				}
			}).catch(error => {
				swal.fire({
					type: 'error',
					title: 'View Previous Orders',
					text: error.body.message,
					confirmButtonColor: '#3085d6',
					cancelButtonColor: '#d33',
					confirmButtonText: 'OK'
				});
				this.loading = false;
			});
    }
}