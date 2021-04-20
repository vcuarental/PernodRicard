import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getOrderDetails from '@salesforce/apex/ASI_CRM_VisitationPreviousOrdersCtr.getOrderDetails';
import resource from "@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource";

export default class Asi_CRM_VisitationOrderDetailsLWC extends NavigationMixin(LightningElement) {
	@track hasRendered = false;
	@track loading = false;
	@api orderID;
	@track iotHeader = {};
    @track displayDataList = [];
    @track totalQuantity = 0;
    @track totalPrice = 0;
    @track recordNum = 0;
	@track wholesalers = [];
	@track wholesalerID;

	locationHashChanged()
	{
		this.init();
	}

	connectedCallback()
	{
		Promise.all([
			loadStyle(this, resource + '/sweetalert2.min.css'),
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
		this.getOrder();
	}

	getOrder()
	{
		this.loading = true;
		this.totalQuantity = 0;
		this.totalPrice = 0.0;

		getOrderDetails({
			headerId: this.orderID
		}).then(result => {
			if (result)
			{console.log('result: ' + JSON.stringify(result));
				this.iotHeader = result.iotHeaders.length > 0 ? result.iotHeaders[0] : {}
				this.displayDataList = result.iotDetails.map((iotDetail) => {
					var sku = {
						ASI_MFM_SKU_Code__c: iotDetail.ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c,
						Name: iotDetail.ASI_CRM_SKU__r.Name,
						ASI_HK_CRM_Base_Price__c: iotDetail.ASI_CRM_SKU__r.ASI_HK_CRM_Base_Price__c
					};
					var quantity = iotDetail.ASI_CRM_Quantity__c;

					this.totalQuantity += quantity;
					this.totalPrice += iotDetail.ASI_CRM_SKU__r.ASI_HK_CRM_Base_Price__c;

					return {
						sku,
						quantity
					};
				});

				this.wholesalers = [{
					value: this.iotHeader.ASI_CRM_Wholesaler__c,
					label: this.iotHeader.ASI_CRM_Wholesaler__r.Name,
					selected: true
				}];
				this.wholesalerID = this.iotHeader.ASI_CRM_Wholesaler__c;
			}
		}).catch(error => {
			console.log('Error: '+ error.body.message);
		}).finally()
		{
			this.loading = false;
		};
	}
}