import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getRSP from '@salesforce/apex/ASI_CRM_VisitationController.getRSP';
import getSKUList from '@salesforce/apex/ASI_CRM_VisitationController.getSKUList';
import saveRSP from '@salesforce/apex/ASI_CRM_VisitationController.saveRSP';
import resource from "@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource";

export default class Asi_CRM_Visitation_RSP extends NavigationMixin(LightningElement) {

	@track hasRendered = false;
	@track loading = true;
	@track searching = false;
	@api visitID;
	@track disabled = false;
	@track vpd = {};
	@track rspHeader = {};
	@track rspDetails = [];
	@track deleteRspDetails = [];
	@track isSubmitted = false;
	@track resultObj = {};

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
		this.getRSPDetail();
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

	searchSKU(event)
    {
		var searchStr = event.target.value;
		var index = event.target.closest('[data-key]').dataset.key;
		this.rspDetails[index].skuName = searchStr;

 		if (this.rspDetails[index].ASI_CRM_SKU__c != null && this.rspDetails[index].skuName != searchStr)
		{
			this.rspDetails[index].ASI_CRM_SKU__c = null;
		}

        if (searchStr != undefined && searchStr != null && searchStr != '' && searchStr.length >= 2)
        {
            this.searching = true;
			getSKUList({
				name: searchStr
			}).then(result => {
				if (result)
				{
					this.rspDetails[index].skuList = result;
				}

				this.searching = false;
			}).catch(error => {
				this.searching = false;
			});
        }
        else
        {
			delete this.rspDetails[index].skuList;
        }
	}
	
	selectSKU(event)
    {
		var index = event.target.closest('[data-key]').dataset.key;
        var skuID = event.target.dataset.id;
        var skuName = event.target.dataset.name;

        this.rspDetails[index].ASI_CRM_SKU__c = skuID;
        this.rspDetails[index].skuName = skuName;
        delete this.rspDetails[index].skuList;
    }

	addItem(event)
    {
        this.rspDetails.push({
            ASI_CRM_RSPHeader__c: null,
            ASI_CRM_CN_Input_Date_Time__c: null,
            ASI_CRM_Price_to_Consumer__c: null,
			ASI_CRM_SKU__c: null,
		});
		
		this.updateIndex();
    }

    deleteItem(event)
    {
        var index = parseInt(event.target.closest('[data-key]').dataset.key, 10);
        if (this.rspDetails[index].hasOwnProperty('Id'))
        {
            this.deleteRspDetails.push(this.rspDetails[index]);
		}
		
		this.rspDetails.splice(index, 1);
		this.updateIndex();
	}

	updateIndex()
	{
		let index = 1;
		this.rspDetails.forEach(function(detail)
		{
			detail.index = index;
			index++;
		});
	}
	
	updateRemark(event)
	{
		this.rspHeader.ASI_CRM_Remark__c = event.target.value;
	}

	updatePrice(event)
	{
		var index = event.target.closest('[data-key]').dataset.key;
		this.rspDetails[index].ASI_CRM_Price_to_Consumer__c = event.target.value;
	}

	getRSPDetail()
	{
		this.loading = true;
		console.log('1: ' + this.visitID);
		getRSP({
			visitID: this.visitID
		}).then(result => {
			if (result)
			{
				result.rspDetails.forEach(function(item) {
					if (item.ASI_CRM_SKU__r != null)
					{
						item.skuName = item.ASI_CRM_SKU__r.Name;
					}

					delete item.ASI_CRM_SKU__r;
				});

				this.vpd = result.vpd;
				this.disabled = result.previousVisit;
				this.rspHeader = result.rspHeader;
				this.rspDetails = result.rspDetails;
				this.updateIndex();
				this.deleteRspDetails = [];

				this.loading = false;
			}
		}).catch(error => {
			this.loading = false;
		});
    }

	submitRSP()
    {
		this.loading = true;

		this.rspDetails.forEach(function(detail) {
			delete detail.skuList;
			delete detail.skuName;
			delete detail.index;
		});

		this.deleteRspDetails.forEach(function(detail) {
			delete detail.skuList;
			delete detail.skuName;
			delete detail.index;
		});

		for (var i = this.rspDetails.length - 1; i >= 0; i--)
		{
			if (this.rspDetails[i].ASI_CRM_SKU__c == null || this.rspDetails[i].ASI_CRM_Price_to_Consumer__c <= 0)
			{
				this.rspDetails.splice(i, 1);
			}
		}

		var param = {
			rspHeaderStr: JSON.stringify(this.rspHeader),
			rspDetailsStr: JSON.stringify(this.rspDetails),
			deleteRspDetailsStr: JSON.stringify(this.deleteRspDetails)
		};

		this.isSubmitted = true;

		saveRSP(param)
			.then(result => {
				if (result)
				{
					this.resultObj = result;
				}
			}).catch(error => {
				this.resultObj = {
					type: 'error',
					message: error.body.message
				};
			}).finally(() => {
				this.loading = false;

				swal.fire({
					type: this.resultObj.type,
					title: 'Submit RSP',
					text: this.resultObj.message,
					confirmButtonColor: '#3085d6',
					cancelButtonColor: '#d33',
					confirmButtonText: 'OK'
				})
				.then(() => {
					if (this.resultObj.type == 'success')
					{
						// this.toVisitation();
						window.history.back();
					}
					else
					{
						this.getRSPDetail();
						this.isSubmitted = false;
					}
				});
			});
	}

	toVisitation()
	{
		this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_VisitationPlanToday_Route"
            },
            state: {
				c__vid: this.visitID,
				c__dt: '2'
            }
        });
	}
}