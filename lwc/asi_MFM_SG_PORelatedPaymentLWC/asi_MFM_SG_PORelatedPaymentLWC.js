import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getPayment from '@salesforce/apex/ASI_MFM_SG_PORelatedPaymentLWCController.getPayment';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";

const columns = [
	{ label: 'Payment Number', fieldName: 'paymentUrl', type: 'url', typeAttributes: { label: { fieldName: 'paymentID' }, target: '_blank'}, cellAttributes: { alignment: 'left' } },
    { label: 'Status', fieldName: 'status', cellAttributes: { alignment: 'left' } },
    { label: 'Owner', fieldName: 'owner', cellAttributes: { alignment: 'left' } },
    { label: 'Currency', fieldName: 'currency', cellAttributes: { alignment: 'left' } },
	{ label: 'Supplier Name', fieldName: 'supplier', cellAttributes: { alignment: 'left' } },
	{ label: 'Payment Amount', fieldName: 'paymentAmount', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 }, cellAttributes: { alignment: 'left' } }
]

export default class Asi_MFM_SG_PORelatedPaymentLWC extends NavigationMixin(LightningElement)
{
	data = [];
    columns = columns;
	@api recordId;
	@track hasRendered = false;
	@track loading = true;

	locationHashChanged()
	{
		this.init();
	}

	connectedCallback()
	{
		window.addEventListener('onhashchange', this.locationHashChanged);
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
		this.getRecords();
	}

	getRecords()
	{
		this.loading = true;

		getPayment({
			poID: this.recordId
		}).then(result => {
			if (result)
			{
				var data = [];
				result.forEach(function(r) {
					data.push({
						id: r.PaymentId,
						paymentID: r.Name,
						paymentUrl: '/' + r.PaymentId,
						status: r.ASI_MFM_Status,
						owner: r.ASI_MFM_PaymentOwner,
						currency: r.ASI_MFM_Currency,
						supplier: r.ASI_MFM_Supplier_Name,
						paymentAmount: r.ASI_MFM_Payment_Amount
					});
				});

				this.data = data;
			}

			this.loading = false;
		}).catch(error => {
			this.loading = false;
		});
    }
}