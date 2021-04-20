import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getTodayVisit from '@salesforce/apex/ASI_CRM_VisitationController.getTodayVisit';
import getCustomerList from '@salesforce/apex/ASI_CRM_VisitationController.getCustomerList';
import saveAdhoc from '@salesforce/apex/ASI_CRM_VisitationController.saveAdhoc';
import resource from "@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource";

export default class ASI_CRM_Visitation_TodayLWC extends NavigationMixin(LightningElement) {
	@track hasRendered = false;
	@track vpdList = [];
	@track vCount = 0;
	@track vDate = new Date();
	@track mapMarkers = [];
	@track markersTitle = '';
	@track zoomLevel;
	@track isModalOpen = false;
	@track customerList = [];
	@track hasCustomer = false;
	@track customer = null;
	@track customerName = '';
	@track isSubmitted = false;
	@track resultObj = {};
	@track isLoading = false;

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
		this.vpdList = [];
		this.vCount = 0;
		this.vDate = new Date();
		this.mapMarkers = [];
		this.markersTitle = '';
		this.getVisit();
	}

	getVisit()
	{
		getTodayVisit()
            .then(result => {
				if (result)
				{
					var mapMarkers = [];

					result.forEach(function(r)
					{
						// if (r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s != undefined
						// 	&& r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Longitude__s != undefined)
						// {
						if (r.custAddress != undefined)
						{
							mapMarkers.push({
								// location: {
								// 	Latitude: r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s,
								// 	Longitude: r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Longitude__s
								// },
								location: {
									Street: r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_JP_City_Ward__c + ' ' + r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_JP_Town__c,
									City: r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_Street_Number__c,
									State: r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_Building_Floor_Number__c,
									Country: r.vpd.ASI_CRM_MY_Customer__r.ASI_CRM_Country__c
								},
								title: r.vpd.ASI_CRM_MY_Customer__r.Name,
								description: r.custAddress
							});
						}
					});

					this.vpdList = result;
					this.vDate = new Date();
					this.vCount = result.length;
					this.mapMarkers = mapMarkers;
					
					if (mapMarkers.length == 1)
					{
						this.zoomLevel = 15;
					}
					else
					{
						this.zoomLevel = null;
					}
				}
            }).catch(error => {
                console.log('Error: '+ error.body.message);
            });
    }

	toVisitation(event)
	{
		var id = event.currentTarget.dataset.id;
		this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_VisitationPlanToday_Route"
            },
            state: {
				c__vid: id
            }
        });
	}

	openModal()
	{
        this.isModalOpen = true;
    }
	
	closeModal()
	{
		this.isModalOpen = false;
		this.customer = null;
		this.customerName = '';
		this.customerList = [];
		this.hasCustomer = false;
	}
	
	searchCustomer(event)
    {
		var searchStr = event.target.value;
		this.customerName = searchStr;

        if (this.customer != null && this.customer.name != searchStr)
        {
			this.customer = null;
        }

        if (searchStr != undefined && searchStr != null && searchStr != '' && searchStr.length >= 2)
        {
			this.isLoading = true;
			var param = {
				name: searchStr
			};
			getCustomerList(param)
				.then(result => {
					if (result && this.isLoading)
					{
						this.customerList = result;
						this.hasCustomer = true;
					}

					this.isLoading = false;
				}).catch(error => {
					console.log('Error: '+ error.body.message);
					this.isLoading = false;
				});
        }
        else
        {
			this.customerList = [];
			this.customer = null;
			this.customerName = '';
			this.hasCustomer = false;
			this.isLoading = false;
		}
	}
	
	get getSearchStr()
	{
		if (this.customer != null)
		{
			return this.customer.name;
		}

		return this.customerName;
	}

    selectCustomer(event)
    {
		var cID = event.target.dataset.id;
		var cName = event.target.dataset.name;
		this.customer = { id: cID, name: cName };
		this.customerName = cName;
		this.customerList = [];
		this.hasCustomer = false;
	}
	
	get showSubmit()
	{
		return this.customer != null && this.isSubmitted == false;
	}
	
    submitAdhoc()
    {
		this.isSubmitted = true;

		var param = {
			customerID: this.customer.id
		};

		saveAdhoc(param)
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
				swal.fire({
					type: this.resultObj.type,
					title: 'Ad-hoc Visitation',
					text: this.resultObj.message,
					confirmButtonColor: '#3085d6',
					cancelButtonColor: '#d33',
					confirmButtonText: 'OK'
				})
				.then(() => {
					if (this.resultObj.type == 'success')
					{
						this.isModalOpen = false;
						this.customerID = null;
						this.customerName = null;
						this.checkName = null;
						this.customerList = [];
						this.hasCustomer = false;
						this.getVisit();
					}
					
					this.isSubmitted = false;
				});
			});
	}
}