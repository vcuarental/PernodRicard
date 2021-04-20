import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getPaymentLine from '@salesforce/apex/ASI_MFM_SG_FVerifyLWCController.getPaymentLine';
import savePaymentLine from '@salesforce/apex/ASI_MFM_SG_FVerifyLWCController.savePaymentLine';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";

export default class asi_MFM_MY_FVerifyLWC extends NavigationMixin(LightningElement)
{
	@track hasRendered = false;
	@track loading = true;
	@track fVerify = false;
	@track poNo;
	@track poLineNo;
	@track paymentNo;
	@track paymentLineNo;
	@track department;
	@track supplier;
	@track acCode;
	@track glDateFrom;
	@track glDateTo;
	@track status;
	@track paymentLines = [];
	@track links;
	@track totalLine = 0;
	@track page = 1;
	@track pageSize = 30;
	@track totalPage = 0;
	@track isSubmitted = false;
	@track hasUpdate = false;
	@track selectedAll = false;
	@track sortBy = 'ASI_MFM_Payment__r.Name';
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

	get dpOptions()
	{
		return [
			{ label: 'SG Sales', value: 'SG Sales'},
			{ label: 'SG Brand Marketing', value: 'SG Brand Marketing'},
			{ label: 'SG Trade Marketing', value: 'SG Trade Marketing'},
			{ label: 'CA Brand Marketing', value: 'CA Brand Marketing'},
			{ label: 'CA Trade Marketing', value: 'CA Trade Marketing'},
			{ label: 'LA Brand Marketing', value: 'LA Brand Marketing'},
			{ label: 'MM Brand Marketing', value: 'MM Brand Marketing'}
		]
	}

	get statusOptions()
	{
		return [
			{ label: 'Submitted', value: 'Submitted'},
			{ label: 'Final', value: 'Final'}
		]
	}

	get headers()
	{
		return [
			{ field: 'PO Number', sortBy: 'ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c', style: 'width:150px' },
			{ field: 'PO Line Number', sortBy: 'ASI_MFM_PO_Line_Item__c', style: 'width:150px' },
			{ field: 'Payment Number', sortBy: 'ASI_MFM_Payment__c', style: 'width:150px' },
			{ field: 'Payment Line Number', sortBy: 'Name', style: 'width:150px' },
			{ field: 'Prefix', sortBy: 'ASI_MFM_Payment__r.ASI_MFM_Prefix__c', style: 'width:100px' },
			{ field: 'Department', sortBy: 'ASI_MFM_Payment__r.ASI_MFM_Prefix__r.ASI_MFM_Department__c', style: 'width:150px' },
			{ field: 'Payee', sortBy: 'ASI_MFM_Payee__c', style: 'width:150px' },
			{ field: 'A/C Code', sortBy: 'ASI_MFM_A_C_Code__c', style: 'width:250px' },
			{ field: 'Attachment', style: 'width:150px' },
			{ field: 'Currency', sortBy: 'ASI_MFM_Currency__c', style: 'width:100px' },
			{ field: 'POL Remaining Amount', sortBy: 'ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c', style: 'width:200px' },
			{ field: 'Payment Amount', sortBy: 'ASI_MFM_Payment_Amount__c', style: 'width:170px' },
			{ field: 'GST Amount', sortBy: 'ASI_MFM_GST_Amount__c', style: 'width:170px' },
			{ field: 'Invoice Total', sortBy: 'ASI_MFM_Invoice_Total__c', style: 'width:170px' },
			{ field: 'Invoice Number', sortBy: 'ASI_MFM_Invoice_Number__c', style: 'width:170px' },
			{ field: 'Invoice Date', sortBy: 'ASI_MFM_Due_Date__c', style: 'width:200px' },
			{ field: 'G/L Date', sortBy: 'ASI_MFM_G_L_Date__c', style: 'width:200px' },
			{ field: 'Invoice Due Date', sortBy: 'ASI_MFM_Invoice_Due_Date__c', style: 'width:150px' },
			{ field: 'Payment Line Description', sortBy: 'ASI_MFM_Payment_List_Item_Description__c', style: 'width:200px' },
			{ field: 'Status', sortBy: 'ASI_MFM_Payment__r.ASI_MFM_Status__c', style: 'width:100px' },
			{ field: 'Comments', sortBy: 'ASI_MFM_Comments__c', style: 'width:250px' }
		];
	}

	init()
	{
		this.getRecords();
	}

	handleChange(event)
	{
		var input = event.target.name;

		if (input == 'poNo')
		{
			this.poNo = event.target.checked;
		}
		else if (input == 'poLineNo')
		{
			this.poLineNo = event.target.value;
		}
		else if (input == 'paymentNo')
		{
			this.paymentNo = event.target.value;
		}
		else if (input == 'paymentLineNo')
		{
			this.paymentLineNo = event.target.value;
		}
		else if (input == 'department')
		{
			this.department = event.target.value;
		}
		else if (input == 'supplier')
		{
			this.supplier = event.target.value;
		}
		else if (input == 'acCode')
		{
			this.acCode = event.target.value;
		}
		else if (input == 'glDateFrom')
		{
			this.glDateFrom = event.target.value;
		}
		else if (input == 'glDateTo')
		{
			this.glDateTo = event.target.value;
		}
		else if (input == 'status')
		{
			this.status = event.target.value;
		}
	}

	goLink(event)
	{
		var link = this.links[event.target.name];

		if (link)
		{
			window.open(link);
		}
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
		else if (input == 'acCode')
		{
			line.ASI_MFM_A_C_Code__c = event.target.value;
			this.hasUpdate = true;
		}
		else if (input == 'gstAmount')
		{
			line.ASI_MFM_GST_Amount__c = event.target.value;
			this.hasUpdate = true;
		}
		else if (input == 'invoiceTotal')
		{
			line.ASI_MFM_Invoice_Total__c = event.target.value;
			this.hasUpdate = true;
		}
		else if (input == 'invoiceNo')
		{
			line.ASI_MFM_Invoice_Number__c = event.target.value;
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
		else if (input == 'invoiceDueDate')
		{
			line.ASI_MFM_Invoice_Due_Date__c = event.target.value;
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
			poNo: this.poNo,
			poLineNo: this.poLineNo,
			paymentNo: this.paymentNo,
			paymentLineNo: this.paymentLineNo,
			department: this.department,
			supplier: this.supplier,
			acCode: this.acCode,
			glDateFrom: this.glDateFrom,
			glDateTo: this.glDateTo,
			status: this.status,
			page: this.page,
			pageSize: this.pageSize,
			sortBy: this.sortBy,
			sortDir: this.sortDir
		}).then(result => {
			if (result)
			{
				result.paymentLines.forEach(function(l) {
					l.attachments = [];
					var attachments = result.attachments[l.ASI_MFM_Payment__c];

					if (attachments != null)
					{
						attachments.forEach(function(a) {
							l.attachments.push({
								id: a.Id,
								name: a.Name,
								link: '/servlet/servlet.FileDownload?file=' + a.Id,
							});
						});
					}

					l.documents = [];
					var documents = result.documents[l.ASI_MFM_Payment__c];

					if (documents != null)
					{
						documents.forEach(function(a) {
							l.documents.push({
								id: a.ContentDocumentId,
								name: a.ContentDocument.Title
							});
						});
					}

					if (l.ASI_MFM_Payment__r.ASI_MFM_Status__c != 'Submitted')
					{
						l.editable = true;
					}
					else
					{
						l.editable = false;
					}

					if (l.ASI_MFM_A_C_Code__c != null && l.ASI_MFM_A_C_Code__r == null)
					{
						l.ASI_MFM_A_C_Code__r = l.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r;
					}
				});

				this.paymentLines = result.paymentLines;
				this.totalPage = result.totalPage;
				this.links = result.links;
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
				var updateLines = JSON.parse(JSON.stringify(this.paymentLines));
				updateLines.forEach(function(l) {
					delete l.attachments;
					delete l.documents;
					delete l.editable;
				});
				var param = {
					paymentLinesStr: JSON.stringify(updateLines)
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

	goToFile(event)
	{
		var id = event.target.dataset.id;
		this[NavigationMixin.Navigate]({
			type: "standard__namedPage",
			attributes: {
				pageName: "filePreview"
			},
			state: {
				selectedRecordId: id
			}
		});
	}
}