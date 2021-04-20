import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getCustomerProsSegmentation from '@salesforce/apex/ASI_CRM_VisitationStoreDetailsController.getCustomerProsSegmentation';
import resource from "@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource";

export default class Asi_CRM_VisitationStoreDetailsLWC extends NavigationMixin(LightningElement) {
	@track hasRendered = false;
	@track loading = false;
	@api customerID;
	@track customer;
	@track address;
	@track phone;

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
		// var param = JSON.parse(this.getQueryParameters());
		// this.customerID = param.attributes.id;
		this.getCustomer();
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
	
	get backgroundStyle()
	{
		return 'background-image: url(' + resource + '/img/dummy/shop.jpg' + ')';
	}

	get locationImgPath()
	{
		return resource + '/location.png';
	}

	get googleMapUrl()
	{
		return 'http://maps.google.com/maps?q=' + this.address;
	}

	get phoneImgPath()
	{
		return resource + '/img/common/phone.png';
	}

	get phoneUrl()
	{
		return 'Tel:' + this.phone;
	}

	getCustomer()
	{
		this.loading = true;
		getCustomerProsSegmentation({
			recordId: this.customerID
		}).then(result => {
			if (result)
			{
				console.log('result: ' + JSON.stringify(result.fields));
				this.customer = result;

				if (this.customer.custAddress)
				{
					this.address = this.customer.custAddress;
				}
				else if (this.customer.detail.ASI_CRM_CN_GPS_info__Latitude__s)
				{
					this.address = this.customer.detail.ASI_CRM_CN_GPS_info__Latitude__s + ',' + this.customer.detail.ASI_CRM_CN_GPS_info__Longitude__s;
				}
				else
				{
					this.address = null;
				}

				if (this.customer.custPhone)
				{
					this.phone = this.customer.custPhone;
				}
				else
				{
					this.phone = null;
				}
			}
		}).catch(error => {
			console.log('Error: '+ error.body.message);
		}).finally()
		{
			this.loading = false;
		};
	}

	navigateDetails()
	{
		this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
			attributes: {
				recordId: this.customerID,
				objectApiName: 'ASI_CRM_AccountsAdditionalField__c',
				actionName: 'view'
			}
		});
    }
}