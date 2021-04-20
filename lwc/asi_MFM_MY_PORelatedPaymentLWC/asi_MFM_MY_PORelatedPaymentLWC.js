import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getPayment from '@salesforce/apex/ASI_MFM_MY_PORelatedPaymentLWCController.getPayment';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";

const columns = [
	{ label: 'Payment Number', fieldName: 'paymentUrl', type: 'url', typeAttributes: { label: { fieldName: 'paymentID' }, target: '_blank'}, cellAttributes: { alignment: 'left' } },
    { label: 'Status', fieldName: 'status', cellAttributes: { alignment: 'left' } },
    { label: 'Owner', fieldName: 'owner', cellAttributes: { alignment: 'left' } },
    { label: 'Currency', fieldName: 'currency', cellAttributes: { alignment: 'left' } },
	{ label: 'Supplier Name', fieldName: 'supplier', cellAttributes: { alignment: 'left' } },
	{ label: 'Payment Amount', fieldName: 'paymentAmount', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 }, cellAttributes: { alignment: 'left' } }
]

export default class Asi_MFM_MY_PORelatedPaymentLWC extends NavigationMixin(LightningElement)
{
	data = [];
	columns = columns;
	defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
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
						id: r.py.Id,
						paymentID: r.py.Name,
						paymentUrl: '/' + r.py.Id,
						status: r.py.ASI_MFM_Status__c,
						owner: r.py.Owner.Name,
						currency: r.py.ASI_MFM_Currency__c,
						supplier: r.py.ASI_MFM_Supplier_Name__r.Name,
						paymentAmount: r.amount
					});
				});

				this.data = data;
			}

			this.loading = false;
		}).catch(error => {
			this.loading = false;
		});
	}
	
	sortBy(field, reverse, primer)
	{
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

	onHandleSort(event)
	{
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}