import { LightningElement, api, track, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";
import RunQuery from '@salesforce/apex/ASI_MFM_MY_Payment_SummaryLWC_Cls.RunQuery';

const columns = [
    { label: 'Payment ID', fieldName: 'PaymentIDUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'PaymentID' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Payment Line ID', fieldName: 'PaymentLineIDUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'PaymentLineID' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'PO ID', fieldName: 'POIDUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'POID' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'PO Line ID', fieldName: 'POLineIDUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'POLineID' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Fiscal Year', fieldName: 'FiscalYear', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Invoice Number', fieldName: 'InvoiceNumber', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Sub-Brand Name', fieldName: 'SubBrandNameUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'SubBrandName' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Payee', fieldName: 'PayeeUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'Payee' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'A/C code', fieldName: 'ACcodeUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'ACcode' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'POL Remaining Amount', fieldName: 'POLRemainingAmount', type: 'number', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },typeAttributes: {minimumFractionDigits: 2, maximumFractionDigits: 2}},
    { label: 'Payment Amount', fieldName: 'PaymentAmount', type: 'number', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },typeAttributes: {minimumFractionDigits: 2, maximumFractionDigits: 2}},
    { label: 'Currency', fieldName: 'Currency', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Exchange Rate', fieldName: 'ExchangeRate', type: 'number', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },typeAttributes: {minimumFractionDigits: 7, maximumFractionDigits: 7}},
    { label: 'Payment Base Currency Amount', fieldName: 'PaymentBaseCurrencyAmount', type: 'number', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },typeAttributes: {minimumFractionDigits: 2, maximumFractionDigits: 2}},
    { label: 'Invoice Date', fieldName: 'InvoiceDate', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'G/L Date', fieldName: 'GLDate', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Description', fieldName: 'Description', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'A/C Remark', fieldName: 'ACRemark', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Finance Comments', fieldName: 'FinanceComments', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Finance Verify', fieldName: 'FinanceVerify', type: 'boolean', sortable: true},
    { label: 'Verify Save Date', fieldName: 'VerifySaveDate', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Complete POL', fieldName: 'CompletePOL', type: 'boolean', sortable: true},
    { label: 'Voucher Created', fieldName: 'VoucherCreated', type: 'boolean', sortable: true},
    { label: 'ETL', fieldName: 'ETL', type: 'boolean', sortable: true},
    { label: 'ETL Date', fieldName: 'ETLDate', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'No. of Outlets', fieldName: 'NumOfOutlets', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Status', fieldName: 'Status', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
];

export default class ASI_MFM_MY_Payment_SummaryLWC extends NavigationMixin(LightningElement)  {
    //data = data;
    data = [];
    columns = columns;
    defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;
    @track totalNumOfRecord = 0;
    @track numOfRowInTable = 50;
    @track LimitFrom = 0;
    @track soql = '';
    @track soqlSubbrand = '';
    @track soqlSubbrandplan = '';
    @track TotalRemainingPO = 0;
    @track TotalPayment = 0;
    @track VerifiedPY = 0;
    @track UnverifiedPY = 0;
    @track PO_ID = '';
    @track Payment_ID = '';
    @track Fiscalyear = '';
    @track Statu = '';
    @track Supplier = '';
    @track FinVerify = '';
    @track VoucherCreat = '';
    @track SubBrandCode = '';
    @track SubBrand = '';
    @track InvoiceNumber = '';
    @track InvoiceDateFrom = '';
    @track InvoiceDateTo = '';
    @track NowFY = '';
    @track display = false;
    @track FiscalyearList = [];
    @track StatusList = [];
    @track VoucherCreatedList=[];
    @track FinanceVerifyList=[];
    @track maxPageNum = 1;
    @track currentPageNum = 1;
    @track sortField = 'ASI_MFM_Invoice_Date__c';
    @track sortDir = 'DESC';
    @track casesSpinner = true;
    @track showSummary = false;
    @track Summaries = [];
    @track showTable = true;
    @track showSummary_buyclick = true;
    @track Message = '';
    @track showMsg = true;

    connectedCallback() {
		Promise.all([
			loadStyle(this, resource + '/sweetalert2.min.css'),
			loadStyle(this, resource + '/jquery-ui.min.css'),
			loadScript(this, resource + '/jquery.min.js'),
			loadScript(this, resource + '/jquery-ui.min.js'),
			loadScript(this, resource + '/moment.js'),
			loadScript(this, resource + '/sweetalert2.min.js')
		])
		.then(() => {
			window.addEventListener('onhashchange', this.locationHashChanged);
		});	
		//this.init();
    }

    get isfirstPageDisabled(){
        return (this.currentPageNum==1);
    }
    
    get isprevPageDisabled(){
        return (this.currentPageNum==1);
    }
    
    get isnextPageDisabled(){
        return (this.currentPageNum==this.maxPageNum);
    }
    
    get islastPageDisabled(){
        return (this.currentPageNum==this.maxPageNum);

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
    
    locationHashChanged(){
		this.init();
	}

    init()
	{
        this.NowFY = 'FY';
        var NowYear = 0;
        var Today_date = new Date();
        if(Today_date.getMonth()>0 && Today_date.getMonth()<7){  // If today's month is Jan-Jun 
            this.NowFY=this.NowFY+(Today_date.getFullYear()-1).toString().substring(2,4)+(Today_date.getFullYear()).toString().substring(2,4);
            NowYear = (Today_date.getFullYear()-1).toString().substring(2,4);
        }else{ //else If today's month is July to DEC
            this.NowFY=this.NowFY+(Today_date.getFullYear()).toString().substring(2,4)+(Today_date.getFullYear()+1).toString().substring(2,4);
            NowYear = (Today_date.getFullYear()).toString().substring(2,4);
        }
        this.Fiscalyear=this.NowFY;  
        //this.Fiscalyear = 'FY1415';

        this.FiscalyearList = [];
        for (var i = 12; i <= parseInt(NowYear); i++) {
            var FY = 'FY'+i.toString()+(i+1).toString();
            var FYselections = {
                label: FY,
                value: FY
            };
            this.FiscalyearList.push(FYselections);
        }
   
        this.StatusList = [
            {label: '', value: ''},
            {label: 'Draft', value: 'Draft'},
            {label: 'Submitted', value: 'Submitted'},
            {label: 'Final', value: 'Final'}];
 
        this.StatusList = [
            {label: '', value: ''},
            {label: 'Draft', value: 'Draft'},
            {label: 'Submitted', value: 'Submitted'}];

        this.FinanceVerifyList = [
            {label: '', value: ''},
            {label: 'Checked', value: 'Checked'},
            {label: 'Unchecked', value: 'Unchecked'}];

        this.soql='select id, Name,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c,ASI_MFM_AC_Remark__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Voucher_Created__c,ASI_MFM_G_L_Date__c,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c,ASI_MFM_Complete_POL__c,ASI_MFM_Finance_Verify_Save_Date__c,ASI_MFM_A_C_Code__c, ASI_MFM_A_C_Code__r.Name, ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Comments__c,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_Payment_Date__c,ASI_MFM_Invoice_Date__c, ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Status_Invalid__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name, ASI_MFM_PO_Line_Item__c, ASI_MFM_PO_Line_Item__r.Name, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Payee__r.Name, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\' ';
        this.soqlSubbrand='select ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name Name, sum(ASI_MFM_Payment_Amount__c) TPA, sum(ASI_MFM_Paid_Amount_in_Base_Currency__c) TPABC from ASI_MFM_Payment_Line_Item__c where (ASI_MFM_Due_Date__c >= TODAY OR ASI_MFM_Due_Date__c = NULL) AND  ASI_MFM_Payment__r.ASI_MFM_ETL__c = false AND ASI_MFM_Payment__r.ASI_MFM_Status__c != \'Draft\' AND  ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\'  ';
        
        if (this.Fiscalyear){
            this.soqlSubbrand+= ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear+'%\'';
            this.soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear+'%\'';
        }
        this.numOfRowInTable = 50;
        this.currentPageNum = 1;
        this.LimitFrom = 0;
        this.runQuery();
    }

    runQuery(){
        this.casesSpinner = true;
        var tempSoql = this.soql+ ' order by ' + this.sortField + ' ' + this.sortDir;
        var tempSoqlwithLimit = this.soql+ ' order by ' + this.sortField + ' ' + this.sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + this.LimitFrom;
        var param = {
            soqlSubbrand: this.soqlSubbrand, 
            soql: tempSoql,
            sqolwithLimit: tempSoqlwithLimit,
		};
        RunQuery(param)
            .then(result => {
                if (result)
				{
                    console.log(result);
                    //console.log(result);
                    if(result.error === true)
                    {
                        this.showMsg = true;
                        this.Message = result.errorMsg;
                        this.data = [];
                        this.showSummary=false;
                    }
                    else if (result.paymentLineItemList){
                        var paymentLineItemList = result.paymentLineItemList;
                        var listlength = paymentLineItemList.length;
                        const data = []  
                        for (var i = 0; i < listlength; i++) {
                            var lineitem = {
                                id: i,
                                PaymentID: paymentLineItemList[i].ASI_MFM_Payment__r.Name,
                                PaymentIDUrl: '/'+paymentLineItemList[i].ASI_MFM_Payment__c,
                                PaymentLineID: paymentLineItemList[i].Name,
                                PaymentLineIDUrl: '/'+paymentLineItemList[i].Id,
                                POID: paymentLineItemList[i].ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name,
                                POIDUrl: '/'+paymentLineItemList[i].ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c,
                                POLineID: paymentLineItemList[i].ASI_MFM_PO_Line_Item__r.Name,
                                POLineIDUrl: '/'+paymentLineItemList[i].ASI_MFM_PO_Line_Item__c,
                                FiscalYear: paymentLineItemList[i].ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,
                                InvoiceNumber: paymentLineItemList[i].ASI_MFM_Invoice_Number__c,
                                Payee: paymentLineItemList[i].ASI_MFM_Payee__r.Name,
                                PayeeUrl: paymentLineItemList[i].ASI_MFM_Payee__c,
                                POLRemainingAmount: paymentLineItemList[i].ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,
                                PaymentAmount: paymentLineItemList[i].ASI_MFM_Payment_Amount__c,
                                Currency: paymentLineItemList[i].ASI_MFM_Currency__c,
                                ExchangeRate: paymentLineItemList[i].ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,
                                PaymentBaseCurrencyAmount: paymentLineItemList[i].ASI_MFM_Paid_Amount_in_Base_Currency__c,
                                InvoiceDate: paymentLineItemList[i].ASI_MFM_Invoice_Date__c,
                                GLDate: paymentLineItemList[i].ASI_MFM_G_L_Date__c,
                                Description: paymentLineItemList[i].ASI_MFM_Payment_List_Item_Description__c,
                                ACRemark: paymentLineItemList[i].ASI_MFM_AC_Remark__c,
                                FinanceComments: paymentLineItemList[i].ASI_MFM_Comments__c,
                                FinanceVerify: paymentLineItemList[i].ASI_MFM_Payment_Line_Item_Finance_Verify__c,
                                //FinanceVerify: true,
                                VerifySaveDate: paymentLineItemList[i].ASI_MFM_Finance_Verify_Save_Date__c,
                                CompletePOL: paymentLineItemList[i].ASI_MFM_Complete_POL__c,
                                VoucherCreated: paymentLineItemList[i].ASI_MFM_Voucher_Created__c,
                                ETL: paymentLineItemList[i].ASI_MFM_ETL__c,
                                ETLDate: paymentLineItemList[i].ASI_MFM_ETL_Date__c,
                                Status: paymentLineItemList[i].ASI_MFM_Payment__r.ASI_MFM_Status__c
                            };  
                            
                            if(paymentLineItemList[i].ASI_MFM_Sub_brand_Code__r && paymentLineItemList[i].ASI_MFM_Sub_brand_Code__r.Name){
                                lineitem.SubBrandName = paymentLineItemList[i].ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name;
                                lineitem.SubBrandNameUrl = '/'+paymentLineItemList[i].ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c;
                            }
                            if(paymentLineItemList[i].ASI_MFM_A_C_Code__r && paymentLineItemList[i].ASI_MFM_A_C_Code__r.Name){
                                lineitem.ACcode = paymentLineItemList[i].ASI_MFM_A_C_Code__r.Name;
                                lineitem.ACcodeUrl = '/'+paymentLineItemList[i].ASI_MFM_A_C_Code__c;
                            }
                            data.push(lineitem);
                        }
                        this.data = data;
                        console.log(this.data);
                        this.Summaries = result.Summaries;
                        this.TotalRemainingPO = result.TotalRemainingPO;
                        this.TotalPayment = result.TotalPayment;
                        this.VerifiedPY = result.VerifiedPY;
                        this.UnverifiedPY = result.UnverifiedPY;
                        this.showSummary=true;
                        this.showMsg = false;
                    }
                    else{
                        this.Message = 'No Records Found, Please Check your search input';
                        this.showMsg = true;
                        this.data = [];
                        this.showSummary=false;
                    }
                    
                    this.totalNumOfRecord = result.totalNumOfRecord;
                    console.log(this.totalNumOfRecord);
                    console.log(this.numOfRowInTable);
                    if (this.totalNumOfRecord == 0 || this.numOfRowInTable == 0)
                        this.maxPageNum = 1;
                    else{
                        this.maxPageNum = Math.floor(((this.totalNumOfRecord - 1) / this.numOfRowInTable) + 1);
                    }
                    console.log(this.maxPageNum);
                    console.log(this.currentPageNum);
                    this.casesSpinner = false;
                    //console.log(this.data);
                }
        }).catch(error => {
            this.casesSpinner = false;
            this.showMsg = true;
            this.Message = error.body ? error.body.message : error.message;
        });

    }

    onHandleSort(event) {
        //const { fieldName: sortedBy, sortDirection } = event.detail;
        //console.log(event.detail.fieldName +''+ event.detail.sortDirection);

        this.sortDirection = event.detail.sortDirection;
        this.sortedBy = event.detail.fieldName;
        //console.log(this.sortDirection);
        //console.log(this.sortedBy);        
        this.sortDir = this.sortDirection;
        if(this.sortedBy == 'PaymentID')
        {
            this.sortField = 'ASI_MFM_Payment__r.Name'
        }
        else if(this.sortedBy == 'PaymentLineID')
        {
            this.sortField = 'Name'
        }
        else if(this.sortedBy == 'POID')
        {
            this.sortField = 'ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name'
        }
        else if(this.sortedBy == 'POLineID')
        {
            this.sortField = 'ASI_MFM_PO_Line_Item__r.Name'
        }
        else if(this.sortedBy == 'FiscalYear')
        {
            this.sortField = 'ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c'
        }
        else if(this.sortedBy == 'InvoiceNumber')
        {
            this.sortField = 'ASI_MFM_Invoice_Number__c'
        }
        else if(this.sortedBy == 'Payee')
        {
            this.sortField = 'ASI_MFM_Payee__r.Name'
        }
        else if(this.sortedBy == 'POLRemainingAmount')
        {
            this.sortField = 'ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c'
        }
        else if(this.sortedBy == 'PaymentAmount')
        {
            this.sortField = 'ASI_MFM_Payment_Amount__c'
        }
        else if(this.sortedBy == 'Currency')
        {
            this.sortField = 'ASI_MFM_Currency__c'
        }
        else if(this.sortedBy == 'ExchangeRate')
        {
            this.sortField = 'ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c'
        }
        else if(this.sortedBy == 'PaymentBaseCurrencyAmount')
        {
            this.sortField = 'ASI_MFM_Paid_Amount_in_Base_Currency__c'
        }
        else if(this.sortedBy == 'InvoiceDate')
        {
            this.sortField = 'ASI_MFM_Invoice_Date__c'
        }
        else if(this.sortedBy == 'GLDate')
        {
            this.sortField = 'ASI_MFM_G_L_Date__c'
        }
        else if(this.sortedBy == 'Description')
        {
            this.sortField = 'ASI_MFM_Payment_List_Item_Description__c'
        }
        else if(this.sortedBy == 'ACRemark')
        {
            this.sortField = 'ASI_MFM_AC_Remark__c'
        }
        else if(this.sortedBy == 'FinanceComments')
        {
            this.sortField = 'ASI_MFM_Comments__c'
        }
        else if(this.sortedBy == 'FinanceVerify')
        {
            this.sortField = 'ASI_MFM_Payment_Line_Item_Finance_Verify__c'
        }
        else if(this.sortedBy == 'VerifySaveDate')
        {
            this.sortField = 'ASI_MFM_Finance_Verify_Save_Date__c'
        }
        else if(this.sortedBy == 'CompletePOL')
        {
            this.sortField = 'ASI_MFM_Complete_POL__c'
        }
        else if(this.sortedBy == 'VoucherCreated')
        {
            this.sortField = 'ASI_MFM_Voucher_Created__c'
        }
        else if(this.sortedBy == 'ETL')
        {
            this.sortField = 'ASI_MFM_ETL__c'
        }
        else if(this.sortedBy == 'ETLDate')
        {
            this.sortField = 'ASI_MFM_ETL_Date__c'
        }
        else if(this.sortedBy == 'Status')
        {
            this.sortField = 'ASI_MFM_Payment__r.ASI_MFM_Status__c'
        }
        else if(this.sortedBy == 'ACcode')
        {
            this.sortField = 'ASI_MFM_A_C_Code__r.name'
        }
        else if(this.sortedBy == 'SubBrandName')
        {
            this.sortField = 'ASI_MFM_Sub_brand_Code__r.name'
        }
        this.LimitFrom = 0;
        this.currentPageNum = 1;
        this.runQuery();
    }

    handleInputChange(event){
        if( event.target.name == 'Payment ID' ){
            this.Payment_ID = event.target.value;
        }
        else if( event.target.name == 'PO ID' ){
            this.PO_ID = event.target.value;
        }
        else if( event.target.name == 'FiscalYear' ){
            this.Fiscalyear = event.target.value;
        }
        else if( event.target.name == 'Invoice Number' ){
            this.InvoiceNumber = event.target.value;
        }
        else if( event.target.name == 'Sub-Brand Code' ){
            this.SubBrandCode = event.target.value;
        }
        else if( event.target.name == 'Sub-Brand Name' ){
            this.SubBrand = event.target.value;
        }
        else if( event.target.name == 'Supplier' ){
            this.Supplier = event.target.value;
        }
        else if( event.target.name == 'Invoice Date From' ){
            this.InvoiceDateFrom = event.target.value;
        }
        else if( event.target.name == 'Invoice Date To' ){
            this.InvoiceDateTo = event.target.value;
        }
        else if( event.target.name == 'Finance Verify' ){
            this.FinVerify = event.target.value;
        }
        else if( event.target.name == 'Voucher Created' ){
            this.VoucherCreat = event.target.value;
        }
        else if( event.target.name == 'Status' ){
            this.Statu = event.target.value;
        }
        
    }

    runSearch(){
        this.soql='select id, name,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c,ASI_MFM_AC_Remark__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Voucher_Created__c,ASI_MFM_G_L_Date__c,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c,ASI_MFM_Complete_POL__c,ASI_MFM_Finance_Verify_Save_Date__c,ASI_MFM_A_C_Code__c, ASI_MFM_A_C_Code__r.Name, ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Comments__c,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_Payment_Date__c,ASI_MFM_Invoice_Date__c, ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Status_Invalid__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name, ASI_MFM_PO_Line_Item__c, ASI_MFM_PO_Line_Item__r.Name, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Payee__r.Name, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\' ';
        this.soqlSubbrand='select ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name Name, sum(ASI_MFM_Payment_Amount__c) TPA, sum(ASI_MFM_Paid_Amount_in_Base_Currency__c) TPABC from ASI_MFM_Payment_Line_Item__c where (ASI_MFM_Due_Date__c >= TODAY OR ASI_MFM_Due_Date__c = NULL) AND  ASI_MFM_Payment__r.ASI_MFM_ETL__c = false AND ASI_MFM_Payment__r.ASI_MFM_Status__c != \'Draft\' AND  ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\'  ';
        if (this.FinVerify){
            if(this.FinVerify=='Unchecked'){
                this.soqlSubbrand +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =false ';
                this.soql +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =false ';
            }
            if(this.FinVerify=='Checked'){
                this.soqlSubbrand +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =true ';
                this.soql +=  ' and ASI_MFM_Payment_Line_Item_Finance_Verify__c =true ';
            }
        }
        if (this.VoucherCreat){
            if(this.VoucherCreat=='Unchecked'){
                this.soqlSubbrand +=  ' and ASI_MFM_Voucher_Created__c =false ';
                this.soql +=  ' and ASI_MFM_Voucher_Created__c =false ';
            }
            if(this.VoucherCreat=='Checked'){
                this.soqlSubbrand +=  ' and ASI_MFM_Voucher_Created__c =true ';
                this.soql +=  ' and ASI_MFM_Voucher_Created__c =true ';
            }
        }
        if (this.Fiscalyear && this.PO_ID=='' && this.Payment_ID==''){
            this.soqlSubbrand+= ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear.replace(/'/g, "\\'")+'%\'';
        }
        if(this.PO_ID){
            this.soql += ' and ASI_MFM_PO__r.name LIKE \''+this.PO_ID.replace(/'/g, "\\'")+'%\'';
            this.soqlSubbrand+= ' and ASI_MFM_PO__r.name LIKE \''+this.PO_ID.replace(/'/g, "\\'")+'%\'';
        }
        if(this.Payment_ID){
            this.soql += ' and ASI_MFM_Payment__r.name LIKE \''+this.Payment_ID.replace(/'/g, "\\'")+'%\'';
            this.soqlSubbrand+= ' and ASI_MFM_Payment__r.name LIKE \''+this.Payment_ID.replace(/'/g, "\\'")+'%\'';
        }
        if (this.Statu){
            this.soqlSubbrand += ' and ASI_MFM_Payment__r.ASI_MFM_Status__c LIKE \''+this.Statu.replace(/'/g, "\\'")+'%\''; 
            this.soql += ' and ASI_MFM_Payment__r.ASI_MFM_Status__c LIKE \''+this.Statu.replace(/'/g, "\\'")+'%\''; 
        }
        if (this.InvoiceNumber){ 
            this.soqlSubbrand+= ' and ASI_MFM_Invoice_Number__c LIKE \''+this.InvoiceNumber.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_Invoice_Number__c LIKE \''+this.InvoiceNumber.replace(/'/g, "\\'")+'%\'';
        }
        if (this.SubBrandCode){
            this.soqlSubbrand += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+this.SubBrandCode.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+this.SubBrandCode.replace(/'/g, "\\'")+'%\'';
        }
        if (this.SubBrand){
            this.soqlSubbrand += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+this.SubBrand.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+this.SubBrand.replace(/'/g, "\\'")+'%\'';
        }
        if (this.Supplier){
            this.soqlSubbrand+= ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+this.Supplier.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+this.Supplier.replace(/'/g, "\\'")+'%\'';
        }
        if (this.InvoiceDateFrom){
            this.soql += ' AND ASI_MFM_Invoice_Date__c  >= ' + this.InvoiceDateFrom + ''; 
            this.soqlSubbrand += ' AND ASI_MFM_Invoice_Date__c  >= ' + this.InvoiceDateFrom + ''; 
        }
        if (this.InvoiceDateTo){
            this.soql += ' AND ASI_MFM_Invoice_Date__c  >= ' + this.InvoiceDateTo + ''; 
            this.soqlSubbrand += ' AND ASI_MFM_Invoice_Date__c  >= ' + this.InvoiceDateTo + ''; 
        }
        /*
        if (this.InvoiceDateTo=='' && this.InvoiceDateFrom==''){
            this.soql += ' AND (ASI_MFM_Due_Date__c >= TODAY OR ASI_MFM_Due_Date__c = NULL)  ';
            this.soqlSubbrand += ' AND (ASI_MFM_Due_Date__c >= TODAY OR ASI_MFM_Due_Date__c = NULL)  ';
        }*/
        this.LimitFrom = 0;
        this.currentPageNum = 1;
        this.runQuery();
    }

    implChangePage(pageNum) {
        if (this.totalNumOfRecord == 0 || this.numOfRowInTable == 0)
            var maxPNum = 1;
        else
            var maxPNum = Math.floor(((this.totalNumOfRecord - 1) / this.numOfRowInTable) + 1);
        if (pageNum <= 0) this.currentPageNum = 1;
        else if (pageNum > maxPNum) this.currentPageNum = maxPNum;
    }

    firstPage(){
        this.currentPageNum=1;
        this.implChangePage(1);
        this.LimitFrom = 0;
        this.runQuery();
    }

    lastPage(){
        if (this.totalNumOfRecord == 0 || this.numOfRowInTable == 0)
            var maxPNum = 1;
        else
            var maxPNum = Math.floor(((this.totalNumOfRecord - 1) / this.numOfRowInTable) + 1);
        this.currentPageNum = maxPNum;
        this.implChangePage(maxPNum);
        this.LimitFrom = this.maxPageNum*this.numOfRowInTable-this.numOfRowInTable;
        this.runQuery();
    }

    prevPage() {
        if(this.currentPageNum>0){
            this.currentPageNum = this.currentPageNum -1;
            this.implChangePage(this.currentPageNum);
            this.LimitFrom=this.LimitFrom-this.numOfRowInTable;
            this.runQuery();
        }
    }

    nextPage() {
        if(this.currentPageNum<this.maxPageNum){
            this.currentPageNum=this.currentPageNum + 1;
            this.implChangePage(this.currentPageNum);
            this.LimitFrom=this.LimitFrom+this.numOfRowInTable;
            this.runQuery();
        }

    }

    showHideTable(){
        this.showTable = !this.showTable;
    }
    showHideSummary(){
        this.showSummary_buyclick = !this.showSummary_buyclick;
    }

}