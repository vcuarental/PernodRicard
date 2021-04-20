import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getPlanLine from '@salesforce/apex/ASI_MFM_MY_BAVerifyLWCController.getPlanLine';
import savePlanLine from '@salesforce/apex/ASI_MFM_MY_BAVerifyLWCController.savePlanLine';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";

export default class asi_MFM_MY_BAVerifyLWC extends NavigationMixin(LightningElement)
{
	@track hasRendered = false;
	@track loading = true;
	@track baVerify;
	@track etlSync;
	@track etlDate;
	@track planID;
	@track planName;
	@track poID;
	@track poLineID;
	@track fy;
	@track subBrandCode;
	@track subBrandName;
	@track supplierNo;
	@track supplier;
	@track glDateFrom;
	@track glDateTo;
	@track planLines = [];
	@track summary = [];
	@track statistic = {};
	@track totalLine = 0;
	@track page = 1;
	@track pageSize = 50;
	@track totalPage = 0;
	@track isSubmitted = false;
	@track hasUpdate = false;
	@track selectedAll = false;
	@track sortBy = 'ASI_MFM_G_L_Date__c';
	@track sortDir = 'asc'
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

	get panelStyle()
	{
		if (this.panelShow)
		{
			return 'slds-panel slds-size_medium slds-panel_docked slds-panel_docked-right slds-is-open';
		}
		
		return 'slds-panel slds-size_medium slds-panel_docked slds-panel_docked-right slds-panel_drawer';
	}

	sort(event)
	{
		var newSort = event.target.dataset.sortby;

		if (this.sortBy == newSort)
		{
			this.sortDir = this.sortDir == 'asc' ? 'desc' : 'asc';
		}
		else
		{
			this.sortBy = newSort;
			this.sortDir = 'asc';
		}

		this.selectedAll = false;
		this.page = 1;
		this.getRecords();
	}

	showPanel(event)
	{
		this.panelShow = !this.panelShow;
		
		if (this.panelShow)
		{
			event.target.label = 'Hide Filter';
		}
		else
		{
			event.target.label = 'Show Filter';
		}
	}

	get fyOptions()
	{
		var options = [];
		for (var i = 12; i < 25; i++)
		{
			options.push({
				label: 'FY' + i.toString() + (i + 1).toString(),
				value: 'FY' + i.toString() + (i + 1).toString()
			});
		}
		
		return options;
	}

	get headers()
	{
		return [
			{ field: 'ETL Sync', sortBy: 'ASI_MFM_Synced__c', style: 'width:100px' },
			{ field: 'ETL Date', sortBy: 'ASI_MFM_ETL_Date__c', style: 'width:120px' },
			// { field: 'Finance Verify Date', sortBy: 'ASI_MFM_Finance_Verify_Date__c', style: 'width:170px' },
			{ field: 'Plan ID', sortBy: 'ASI_MFM_PO__r.ASI_MFM_Plan__c', style: 'width:150px' },
			{ field: 'Plan Name', sortBy: 'ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c', style: 'width:150px' },
			{ field: 'PO ID', sortBy: 'ASI_MFM_PO__c', style: 'width:150px' },
			// { field: 'PO Line ID', sortBy: 'Name', style: 'width:150px' },
			{ field: 'Fiscal Year', sortBy: 'ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c', style: 'width:100px' },
			{ field: 'Sub-Brand Name', sortBy: 'ASI_MFM_Sub_brand_Code__r.Name', style: 'width:200px' },
			// { field: 'Supplier Number', sortBy: 'ASI_MFM_PO_Supplier_Number__c', style: 'width:150px' },
			{ field: 'Supplier', sortBy: 'ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c', style: 'width:200px' },
			{ field: 'A/C Code', sortBy: 'ASI_MFM_A_C_Code__c', style: 'width:150px' },
			{ field: 'PO Line Description', sortBy: 'ASI_MFM_List_Item_Description__c', style: 'width:200px' },
			// { field: 'Original PO Amount', sortBy: 'ASI_MFM_Amount__c', style: 'width:170px' },
			// { field: 'Original Remaining Amount', sortBy: 'ASI_MFM_Remaining_Balance__c', style: 'width:220px' },
			{ field: 'Currency', sortBy: 'ASI_MFM_Currency__c', style: 'width:100px' },
			{ field: 'Exchange Rate', sortBy: 'ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c', style: 'width:150px' },
			{ field: 'PO Base Currency Amount', sortBy: 'ASI_MFM_Base_Currency_Amount__c', style: 'width:200px' },
			{ field: 'PO Base Currency Remaining Amount', sortBy: 'ASI_MFM_Base_Currency_Remaining_Balance__c', style: 'width:280px' },
			{ field: 'G/L Date', sortBy: 'ASI_MFM_G_L_Date__c', style: 'width:120px' },
			{ field: 'Post G/L Date', sortBy: 'ASI_MFM_Post_G_L_Date__c', style: 'width:200px' },
		];
	}

	init()
	{
		this.getRecords();
	}

	handleChange(event)
	{
		var input = event.target.name;

		if (input == 'baVerify')
		{
			this.baVerify = event.target.checked;
		}
		else if (input == 'etlSync')
		{
			this.etlSync = event.target.checked;
		}
		else if (input == 'etlDate')
		{
			this.etlDate = event.target.checked;
		}
		else if (input == 'planID')
		{
			this.planID = event.target.value;
		}
		else if (input == 'planName')
		{
			this.planName = event.target.value;
		}
		else if (input == 'poID')
		{
			this.poID = event.target.value;
		}
		else if (input == 'poLineID')
		{
			this.poLineID = event.target.value;
		}
		else if (input == 'fy')
		{
			this.fy = event.target.value;
		}
		else if (input == 'subBrandCode')
		{
			this.subBrandCode = event.target.value;
		}
		else if (input == 'subBrandName')
		{
			this.subBrandName = event.target.value;
		}
		else if (input == 'supplierNo')
		{
			this.supplierNo = event.target.value;
		}
		else if (input == 'supplier')
		{
			this.supplier = event.target.value;
		}
		else if (input == 'glDateFrom')
		{
			this.glDateFrom = event.target.value;
		}
		else if (input == 'glDateTo')
		{
			this.glDateTo = event.target.value;
		}
	}

	updateField(event)
	{
		var input = event.target.name;
		var index = event.target.closest('[data-key]').dataset.key;
		var line = this.planLines[index];

		if (input == 'baVerify')
		{
			line.ASI_MFM_SG_BA_verify__c = event.target.checked;
			this.hasUpdate = true;
		}
		else if (input == 'glPostDate')
		{
			line.ASI_MFM_Post_G_L_Date__c = event.target.value;
			this.hasUpdate = true;
		}
	}

	selectAll(event)
	{
		var checked = event.target.checked;
		this.selectedAll = checked;

		this.planLines.forEach(function(line) {
			line.ASI_MFM_SG_BA_verify__c = checked;
		});
		this.hasUpdate = true;
	}

	nextPage()
	{
		if (this.page >= this.totalPage)
		{
			return;
		}

		this.selectedAll = false;
		this.page++;
		this.getRecords();
	}

	lastPage()
	{
		if (this.page >= this.totalPage)
		{
			return;
		}

		this.selectedAll = false;
		this.page = this.totalPage;
		this.getRecords();
	}

	get hideNext()
	{
		return this.page >= this.totalPage;
	}

	previousPage()
	{
		if (this.page <= 1)
		{
			return;
		}

		this.selectedAll = false;
		this.page--;
		this.getRecords();
	}

	firstPage()
	{
		if (this.page <= 1)
		{
			return;
		}

		this.selectedAll = false;
		this.page = 1;
		this.getRecords();
	}

	get hidePrevious()
	{
		return this.page <= 1;
	}

	search(event)
    {
		this.selectedAll = false;
		this.page = 1;
		this.getRecords();
	}

	getRecords()
	{
		this.loading = true;

		getPlanLine({
			recordType: 'ASI_MFM_MY_PO',
			country: 'MY',
			settingName: 'MY_Cut_Off_Date',
			baVerify: this.baVerify,
			etlSync: this.etlSync,
			etlDate: this.etlDate,
			planID: this.planID,
			planName: this.planName,
			poID: this.poID,
			poLineID: this.poLineID,
			fy: this.fy,
			subBrandCode: this.subBrandCode,
			subBrandName: this.subBrandName,
			supplierNo: this.supplierNo,
			supplier: this.supplier,
			glDateFrom: this.glDateFrom,
			glDateTo: this.glDateTo,
			page: this.page,
			pageSize: this.pageSize,
			sortBy: this.sortBy,
			sortDir: this.sortDir
		}).then(result => {
			if (result)
			{
				this.planLines = result.planLines;
				this.summary = result.summary;
				this.statistic = result.statistic;
				this.totalPage = result.totalPage;
				this.fy = result.fy;
			}

			this.loading = false;
		}).catch(error => {
			this.loading = false;
		});
    }

	save()
    {
		swal.fire({
			title: 'BA Verify',
			text: "Do you want to proceed?",
			showCancelButton: true,
			confirmButtonColor: '#3085d6',
			cancelButtonColor: '#d33',
			confirmButtonText: 'Confirm'
		}).then((result) => {
			if (result.value)
			{
				this.loading = true;
				var updateLines = [];
				var poList = [];

				this.planLines.forEach(function(line) {
					updateLines.push({
						Id: line.Id,
						ASI_MFM_SG_BA_verify__c: line.ASI_MFM_SG_BA_verify__c,
						ASI_MFM_Post_G_L_Date__c: line.ASI_MFM_Post_G_L_Date__c
					});

					if (line.ASI_MFM_SG_BA_verify__c == true && poList.indexOf(line.ASI_MFM_PO__r.Name) == -1)
					{
						poList.push(line.ASI_MFM_PO__r.Name);
					}
				});

				var param = {
					planLinesStr: JSON.stringify(updateLines),
					country: 'MY',
					settingName: 'MY_Cut_Off_Date',
					poList: poList
				};

				this.isSubmitted = true;

				savePlanLine(param)
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
							title: 'Save Plan Line',
							text: this.resultObj.message,
							confirmButtonColor: '#3085d6',
							cancelButtonColor: '#d33',
							confirmButtonText: 'OK'
						})
						.then(() => {
							if (this.resultObj.type == 'success')
							{
								this.init();
								this.hasUpdate = false;
							}

							this.isSubmitted = false;
						});
					});
				}
			});
	}
}