import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getPaymentLine from '@salesforce/apex/ASI_MFM_MY_FVerifyLWCController.getPaymentLine';
import savePaymentLine from '@salesforce/apex/ASI_MFM_MY_FVerifyLWCController.savePaymentLine';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";

export default class asi_MFM_MY_FVerifyLWC extends NavigationMixin(LightningElement)
{
	@track hasRendered = false;
	@track loading = true;
	@track fVerify = false;
	@track paymentID;
	@track poID;
	@track fy;
	@track invoiceID;
	@track subBrandCode;
	@track subBrandName;
	@track supplierNo;
	@track supplier;
	@track invoiceDateFrom;
	@track invoiceDateTo;
	@track paymentLines = [];
	@track paymentMap;
	@track rid;
	@track pid;
	@track eid;
	@track summary = [];
	@track statistic = {};
	@track totalLine = 0;
	@track page = 1;
	@track pageSize = 50;
	@track totalPage = 0;
	@track isSubmitted = false;
	@track hasUpdate = false;
	@track selectedAll = false;
	@track sortBy = 'ASI_MFM_Payment__r.ASI_MFM_Status__c';
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
			// { field: 'Verify Save Date', sortBy: 'ASI_MFM_Finance_Verify_Save_Date__c', style: 'width:170px' },
			{ field: 'Payment ID', sortBy: 'ASI_MFM_Payment__c', style: 'width:150px' },
			{ field: 'Payment Line ID', sortBy: 'Name', style: 'width:150px' },
			{ field: 'PO ID', sortBy: 'ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c', style: 'width:150px' },
			// { field: 'PO Line ID', sortBy: 'ASI_MFM_PO_Line_Item__c', style: 'width:150px' },
			{ field: 'Fiscal Year', sortBy: 'ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c', style: 'width:100px' },
			{ field: 'Invoice Number', sortBy: 'ASI_MFM_Invoice_Number__c', style: 'width:200px' },
			{ field: 'Sub-Brand Name', sortBy: 'ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name', style: 'width:200px' },
			{ field: 'Payee', sortBy: 'ASI_MFM_Payee__c', style: 'width:150px' },
			{ field: 'A/C Code', sortBy: 'ASI_MFM_A_C_Code__c', style: 'width:250px' },
			// { field: 'POL Remaining Amount', sortBy: 'ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c', style: 'width:200px' },
			{ field: 'Payment Amount', sortBy: 'ASI_MFM_Payment_Amount__c', style: 'width:170px' },
			{ field: 'Currency', sortBy: 'ASI_MFM_Currency__c', style: 'width:100px' },
			{ field: 'Exchange Rate', sortBy: 'ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c', style: 'width:150px' },
			{ field: 'Payment Base Currency Amount', sortBy: 'ASI_MFM_Paid_Amount_in_Base_Currency__c', style: 'width:200px' },
			{ field: 'Invoice Date', sortBy: 'ASI_MFM_Invoice_Date__c', style: 'width:200px' },
			{ field: 'Invoice Due Date', sortBy: 'ASI_MFM_Payment__r.ASI_MFM_Invoice_Due_Date__c', style: 'width:150px' },
			{ field: 'G/L Date', sortBy: 'ASI_MFM_G_L_Date__c', style: 'width:200px' },
			{ field: 'Payment Line Description', sortBy: 'ASI_MFM_Payment_List_Item_Description__c', style: 'width:200px' },
			// { field: 'ETL', sortBy: 'ASI_MFM_ETL__c', style: 'width:100px' },
			// { field: 'ETL Date', sortBy: 'ASI_MFM_ETL_Date__c', style: 'width:120px' },
			{ field: 'Comments', sortBy: 'ASI_MFM_Comments__c', style: 'width:250px' },
		];
	}

	init()
	{
		this.getRecords();
	}

	handleChange(event)
	{
		var input = event.target.name;

		if (input == 'fVerify')
		{
			this.fVerify = event.target.checked;
		}
		else if (input == 'paymentID')
		{
			this.paymentID = event.target.value;
		}
		else if (input == 'poID')
		{
			this.poID = event.target.value;
		}
		else if (input == 'fy')
		{
			this.fy = event.target.value;
		}
		else if (input == 'invoiceNo')
		{
			this.invoiceNo = event.target.value;
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
		else if (input == 'invoiceDateFrom')
		{
			this.invoiceDateFrom = event.target.value;
		}
		else if (input == 'invoiceDateTo')
		{
			this.invoiceDateTo = event.target.value;
		}
	}

	faReport(event)
	{
		window.open('/' + this.pid);
	}

	etlReport(event)
	{
		window.open('/' + this.eid);
	}

	updateField(event)
	{
		var input = event.target.name;
		var index = event.target.closest('[data-key]').dataset.key;
		var line = this.paymentLines[index];

		if (input == 'fVerify')
		{
			line.ASI_MFM_Payment_Line_Item_Finance_Verify__c = event.target.checked;
			this.hasUpdate = true;
		}
		else if (input == 'invoiceNo')
		{
			line.ASI_MFM_Invoice_Number__c = event.target.value;
			this.hasUpdate = true;
		}
		else if (input == 'acCode')
		{
			line.ASI_MFM_A_C_Code__c = event.target.value;
			this.hasUpdate = true;
		}
		else if (input == 'invoiceDate')
		{
			line.ASI_MFM_Invoice_Date__c = event.target.value;
			this.hasUpdate = true;
		}
		else if (input == 'glDate')
		{
			line.ASI_MFM_G_L_Date__c = event.target.value;
			this.hasUpdate = true;
		}
		else if (input == 'comments')
		{
			line.ASI_MFM_Comments__c = event.target.value;
			this.hasUpdate = true;
		}
	}

	selectAll(event)
	{
		var checked = event.target.checked;
		this.selectedAll = checked;

		this.paymentLines.forEach(function(line) {
			line.ASI_MFM_Payment_Line_Item_Finance_Verify__c = checked;
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

		getPaymentLine({
			fVerify: this.fVerify,
			paymentID: this.paymentID,
			poID: this.poID,
			fy: this.fy,
			invoiceNo: this.invoiceNo,
			subBrandCode: this.subBrandCode,
			subBrandName: this.subBrandName,
			supplierNo: this.supplierNo,
			supplier: this.supplier,
			invoiceDateFrom: this.invoiceDateFrom,
			invoiceDateTo: this.invoiceDateTo,
			page: this.page,
			pageSize: this.pageSize,
			sortBy: this.sortBy,
			sortDir: this.sortDir
		}).then(result => {
			if (result)
			{
				this.paymentLines = result.paymentLines;
				this.summary = result.summary;
				this.statistic = result.statistic;
				this.totalPage = result.totalPage;
				this.fy = result.fy;
				this.fVerify = result.fVerify;
				this.paymentMap = result.paymentMap;
				this.pid = result.pid;
				this.rid = result.rid;
				this.eid = result.eid;
			}

			this.loading = false;
		}).catch(error => {
			this.loading = false;
		});
    }

	save()
    {
		swal.fire({
			title: 'Finance Verify',
			text: "Do you want to proceed?",
			showCancelButton: true,
			confirmButtonColor: '#3085d6',
			cancelButtonColor: '#d33',
			confirmButtonText: 'Confirm'
		}).then((result) => {
			if (result.value)
			{
				this.loading = true;
				
				var param = {
					paymentLinesStr: JSON.stringify(this.paymentLines),
					paymentMap: this.paymentMap
				};

				this.isSubmitted = true;

				savePaymentLine(param)
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
							title: 'Save Payment Line',
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