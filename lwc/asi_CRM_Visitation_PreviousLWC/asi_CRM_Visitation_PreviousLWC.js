import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getPreviousVisit from '@salesforce/apex/ASI_CRM_VisitationController.getPreviousVisit';
import resource from "@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource";

export default class Asi_CRM_Visitation_Previous extends NavigationMixin(LightningElement) {
	@track hasRendered = false;
	@track loading = false;
	@track vpdList = [];
	@track vCount = 0;
	@track page = 1;
	@track pageSize = 10;
	@track totalPage = 0;
	@track inputPage = 1;
	@api customerID;
	@api visitID;

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
		// this.visitID = param.attributes.visitID;
		// this.customerID = param.attributes.customerID;
		this.vpdList = [];
		this.vCount = 0;
		this.page = 1;
		this.totalPage = 0;
		this.inputPage = 1;
		this.getRecords();
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

	nextPage()
	{
		if (this.page >= this.totalPage)
		{
			return;
		}

		this.page++;
		this.getRecords();
	}

	get showNext()
	{
		return this.page < this.totalPage;
	}

	previousPage()
	{
		if (this.page <= 1)
		{
			return;
		}

		this.page--;
		this.getRecords();
	}

	get showPrevious()
	{
		return this.page > 1;
	}

	goPage(event)
	{
		var reload = false;
		var iPage = parseInt(event.target.value, 10);
		this.inputPage = iPage;

		if (isNaN(iPage) || iPage <= 1)
		{
			if (this.page != 1)
			{
				reload = true;
			}

			this.page = 1;
			this.inputPage = 1;
		}
		else if (iPage > this.totalPage)
		{
			if (this.page != this.totalPage)
			{
				reload = true;
			}

			this.page = this.totalPage;
			this.inputPage = this.totalPage;
		}
		else
		{
			if (this.page != iPage)
			{
				reload = true;
			}

			this.page = iPage;
			this.inputPage = iPage;
		}

		if (reload)
		{
			this.getRecords();
		}
	}

	toVisitation(event)
	{
		var id = event.currentTarget.dataset.id;
		var compDefinition = {
            componentDef: 'c:asi_CRM_VisitationPlanTodayLWC',
            attributes: {
                id: id
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
		});
	}

	getRecords()
	{
		this.loading = true;
		getPreviousVisit({
			customerID: this.customerID,
			visitID: this.visitID,
			page: this.page,
			pSize: this.pageSize
		})
		.then(result => {
			if (result)
			{
				this.vpdList = result.vpdList;
				this.vCount = result.vpdList.length;
				this.page = result.page;
				this.inputPage = result.page;
				this.totalPage = result.totalPage;
			}
		})
		.catch(error => {
			console.log(error.body.message);
		})
		.finally(() => {
			this.loading = false;
		});
	}
}