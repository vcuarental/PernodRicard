import { LightningElement, api, track, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";
import RunQuery from '@salesforce/apex/ASI_MFM_MY_POLineViewLWC_Cls.RunQuery';

const columns = [
    { label: 'PO ID', fieldName: 'POIDUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'POID' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'PO Line ID', fieldName: 'POLineIDUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'POLineID' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Plan ID', fieldName: 'PlanIDUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'PlanID' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Plan Name', fieldName: 'PlanName', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Fiscal Year', fieldName: 'FiscalYear', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Sub-Brand Name', fieldName: 'SubBrandNameUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'SubBrandName' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Supplier Number', fieldName: 'SupplierNumber', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Supplier', fieldName: 'SupplierUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'Supplier' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Original PO Amount', fieldName: 'OriginalPOAmount', type: 'number', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },typeAttributes: {minimumFractionDigits: 2, maximumFractionDigits: 2}},
    { label: 'Original Remaining Amount', fieldName: 'OriginalRemainingAmount', type: 'number', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },typeAttributes: {minimumFractionDigits: 2, maximumFractionDigits: 2}},
    { label: 'Currency', fieldName: 'Currency', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Exchange Rate', fieldName: 'ExchangeRate', type: 'number', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },typeAttributes: {minimumFractionDigits: 7, maximumFractionDigits: 7}},
    { label: 'PO Base Currency Amount', fieldName: 'POBaseCurrencyAmount', type: 'number', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },typeAttributes: {minimumFractionDigits: 2, maximumFractionDigits: 2}},
    { label: 'PO Base Currency Remaining Amount', fieldName: 'POBaseCurrencyRemainingAmount', type: 'number', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },typeAttributes: {minimumFractionDigits: 2, maximumFractionDigits: 2}},
    { label: 'A/C code', fieldName: 'ACcodeUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'ACcode' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'PO Line Description', fieldName: 'POLineDescription', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'G/L Date', fieldName: 'GLDate', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'PO Status', fieldName: 'POStatus', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
];

export default class ASI_MFM_MY_PlanViewPageLWC extends NavigationMixin(LightningElement)  {
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
    @track soqlpo = '';
    @track ALLPOAmount = 0;
    @track ALLPaymentAmount = 0;
    @track ALLPORemain = 0;
    @track TotalOriginalPO = 0;
    @track TotalRemainingPO = 0;
    @track Plan_ID = '';
    @track PO_ID = '';
    @track PlanName = '';
    @track Statu = '';
    @track PO_Line_ID = '';
    @track SubBrandCode = '';
    @track SubBrand = '';
    @track Supplier_Num = '';
    @track suppl = '';
    @track Fiscalyear = '';
    @track gl_fromDate = ''
    @track gl_toDate = ''
    @track ACcode = '';
    @track NowFY = '';
    @track display = false;
    @track FiscalyearList = [];
    @track StatusList = [];
    @track maxPageNum = 1;
    @track currentPageNum = 1;
    @track sortField = 'ASI_MFM_PO__r.Name';
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
        //this.Fiscalyear = 'FY1415'
        this.FiscalyearList = [];
        for (var i = 14; i <= parseInt(NowYear); i++) {
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
            {label: 'Final', value: 'Final'},
            {label: 'Complete', value: 'Complete'}];

        this.soql='select id, name,RecordType.DeveloperName,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_PO__r.Name,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Invoice_Number__c,ASI_MFM_PO__r.ASI_MFM_Status__c, ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Base_Currency_Remaining_Balance__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO__r.ASI_MFM_PO_Name__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Supplier_Number__c, ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_SG_BA_verify__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Name,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.Name,ASI_MFM_Currency__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_G_L_Date__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        this.soqlSubbrand='select ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Base_Currency_Amount__c) TotalOPO, sum(ASI_MFM_Base_Currency_Remaining_Balance__c) TotalRPO from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        this.soqlpo='select id,name,Owner.name,ASI_MFM_Supplier_Name__r.name ,ASI_MFM_Plan__r.name,ASI_MFM_BU_Code__r.name,ASI_MFM_PO_Name__c,ASI_MFM_BU_Code__c,ASI_MFM_Plan__c,ASI_MFM_Sys_Plan_Amount__c,ASI_MFM_Plan_Balance__c,ASI_MFM_Sys_Plan_Name__c,ASI_MFM_Supplier_Name__c,ASI_MFM_Supplier_Number__c,ASI_MFM_Currency__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_PO_Raised_Date__c,ASI_MFM_Remarks__c,ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c,ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_PO_Balance__c,ASI_MFM_Payment_Request_Amount__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_Base_Currency_Amount__c    from ASI_MFM_PO__c where ASI_MFM_PO_Amount__c>=0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        
        if (this.Fiscalyear){
            this.soql+= ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear+'%\'';
            this.soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear+'%\'';
            this.soqlpo += ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear+'%\'';
        }
        this.numOfRowInTable = 50;
        this.currentPageNua = 1;
        this.LimitFrom = 0;
        this.runQuery();
    }

    runQuery(){
        this.casesSpinner = true;
        var tempSoql = this.soql+ ' order by ' + this.sortField + ' ' + this.sortDir;
        var tempSoqlwithLimit = this.soql+ ' order by ' + this.sortField + ' ' + this.sortDir + ' Limit ' + this.numOfRowInTable + ' OFFSET ' + this.LimitFrom;
        /*console.log(this.soqlpo);
        console.log(tempSoql);
        console.log(this.soqlSubbrand);
        console.log(tempSoqlwithLimit);*/
        var param = {
            soql: tempSoql,
            soqlSubbrand: this.soqlSubbrand, 
            soqlpo: this.soqlpo,
            sqolwithLimit: tempSoqlwithLimit
		};
        RunQuery(param)
            .then(result => {
                if (result)
				{
                    //console.log(result);
                    if(result.error === true)
                    {
                        this.showMsg = true;
                        this.Message = result.errorMsg;
                        this.data = [];
                        this.showSummary=false;
                    }
                    else if (result.poLineItemList){
                        var poLineItemList = result.poLineItemList;
                        var listlength = poLineItemList.length;
                        const data = []  
                        for (var i = 0; i < listlength; i++) {
                            var lineitem = {
                                id: i,
                                POID: poLineItemList[i].ASI_MFM_PO__r.Name,
                                POIDUrl: '/'+poLineItemList[i].ASI_MFM_PO__c,
                                POLineID: poLineItemList[i].Name,
                                POLineIDUrl: '/'+poLineItemList[i].id,
                                PlanID: poLineItemList[i].ASI_MFM_PO__r.ASI_MFM_Plan__r.Name,
                                PlanIDUrl: '/'+poLineItemList[i].ASI_MFM_PO__r.ASI_MFM_Plan__c,
                                PlanName: poLineItemList[i].ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,
                                FiscalYear: poLineItemList[i].ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,
                                SupplierNumber: poLineItemList[i].ASI_MFM_PO_Supplier_Number__c,
                                OriginalPOAmount: poLineItemList[i].ASI_MFM_Amount__c,
                                OriginalRemainingAmount: poLineItemList[i].ASI_MFM_Remaining_Balance__c,
                                Currency: poLineItemList[i].ASI_MFM_Currency__c,
                                ExchangeRate: poLineItemList[i].ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c,
                                POBaseCurrencyAmount: poLineItemList[i].ASI_MFM_Base_Currency_Amount__c,
                                POBaseCurrencyRemainingAmount: poLineItemList[i].ASI_MFM_Base_Currency_Remaining_Balance__c,
                                POLineDescription: poLineItemList[i].ASI_MFM_List_Item_Description__c,
                                GLDate: poLineItemList[i].ASI_MFM_G_L_Date__c,
                                POStatus: poLineItemList[i].ASI_MFM_PO__r.ASI_MFM_Status__c
                            };  
                            
                            if(poLineItemList[i].ASI_MFM_Sub_brand_Code__r && poLineItemList[i].ASI_MFM_Sub_brand_Code__r.Name){
                                lineitem.SubBrandName = poLineItemList[i].ASI_MFM_Sub_brand_Code__r.Name;
                                lineitem.SubBrandNameUrl = '/'+poLineItemList[i].ASI_MFM_Sub_brand_Code__c;
                            }
                            if(poLineItemList[i].ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r && poLineItemList[i].ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Name){
                                lineitem.Supplier = poLineItemList[i].ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Name;
                                lineitem.SupplierUrl = '/'+poLineItemList[i].ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c;
                            }
                            if(poLineItemList[i].ASI_MFM_A_C_Code__r && poLineItemList[i].ASI_MFM_A_C_Code__r.Name){
                                lineitem.ACcode = poLineItemList[i].ASI_MFM_A_C_Code__r.Name;
                                lineitem.ACcodeUrl = '/'+poLineItemList[i].ASI_MFM_A_C_Code__c;
                            }
                            
                            data.push(lineitem);
                        }
                        this.data = data;
                        //console.log(this.data);
                        this.Summaries = result.Summaries;
                        this.ALLPOAmount = result.ALLPOAmount;
                        this.ALLPaymentAmount = result.ALLPaymentAmount;
                        this.ALLPORemain = result.ALLPORemain;
                        this.TotalOriginalPO = result.TotalOriginalPO;
                        this.TotalRemainingPO = result.TotalRemainingPO;
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
                    //console.log(this.totalNumOfRecord);
                    //console.log(this.numOfRowInTable);
                    if (this.totalNumOfRecord == 0 || this.numOfRowInTable == 0)
                        this.maxPageNum = 1;
                    else{
                        this.maxPageNum = Math.floor(((this.totalNumOfRecord - 1) / this.numOfRowInTable) + 1);
                    }
                    //console.log(this.maxPageNum);
                    //console.log(this.currentPageNum);
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
        if(this.sortedBy == 'POID')
        {
            this.sortField = 'ASI_MFM_PO__r.Name'
        }
        else if(this.sortedBy == 'POLineID')
        {
            this.sortField = 'Name'
        }
        else if(this.sortedBy == 'PlanID')
        {
            this.sortField = 'ASI_MFM_PO__r.ASI_MFM_Plan__r.Name'
        }
        else if(this.sortedBy == 'PlanName')
        {
            this.sortField = 'ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c'
        }
        else if(this.sortedBy == 'FiscalYear')
        {
            this.sortField = 'ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c'
        }
        else if(this.sortedBy == 'SupplierNumber')
        {
            this.sortField = 'ASI_MFM_PO_Supplier_Number__c'
        }
        else if(this.sortedBy == 'OriginalPOAmount')
        {
            this.sortField = 'ASI_MFM_Amount__c'
        }
        else if(this.sortedBy == 'OriginalRemainingAmount')
        {
            this.sortField = 'ASI_MFM_Remaining_Balance__c'
        }
        else if(this.sortedBy == 'Currency')
        {
            this.sortField = 'ASI_MFM_Currency__c'
        }
        else if(this.sortedBy == 'ExchangeRate')
        {
            this.sortField = 'ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c'
        }
        else if(this.sortedBy == 'POBaseCurrencyAmount')
        {
            this.sortField = 'ASI_MFM_Base_Currency_Remaining_Balance__c'
        }
        else if(this.sortedBy == 'POBaseCurrencyRemainingAmount')
        {
            this.sortField = 'ASI_MFM_Base_Currency_Remaining_Balance__c'
        }
        else if(this.sortedBy == 'POLineDescription')
        {
            this.sortField = 'ASI_MFM_List_Item_Description__c'
        }
        else if(this.sortedBy == 'GLDate')
        {
            this.sortField = 'ASI_MFM_G_L_Date__c'
        }
        else if(this.sortedBy == 'POStatus')
        {
            this.sortField = 'ASI_MFM_PO__r.ASI_MFM_Status__c'
        } 
        else if(this.sortedBy == 'SubBrandName')
        {
            this.sortField = 'ASI_MFM_Sub_brand_Code__r.Name'
        } 
        else if(this.sortedBy == 'Supplier')
        {
            this.sortField = 'ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Name'
        } 
        else if(this.sortedBy == 'ACcode')
        {
            this.sortField = 'ASI_MFM_A_C_Code__r.Name'
        }
        this.LimitFrom = 0;
        this.currentPageNum = 1;
        this.runQuery();
    }

    handleInputChange(event){
        if( event.target.name == 'PO ID' ){
            this.PO_ID = event.target.value;
        }
        else if( event.target.name == 'PO Line ID' ){
            this.PO_Line_ID = event.target.value;
        }
        else if( event.target.name == 'Plan ID' ){
            this.Plan_ID = event.target.value;
        }
        else if( event.target.name == 'Plan Name' ){
            this.PlanName = event.target.value;
        }
        else if( event.target.name == 'FiscalYear' ){
            this.Fiscalyear = event.target.value;
        }
        else if( event.target.name == 'A/C Code' ){
            this.ACcode = event.target.value;
        }
        else if( event.target.name == 'Sub-Brand Code' ){
            this.SubBrandCode = event.target.value;
        }
        else if( event.target.name == 'Sub-Brand Name' ){
            this.SubBrand = event.target.value;
        }
        else if( event.target.name == 'Supplier Number' ){
            this.Supplier_Num = event.target.value;
        }
        else if( event.target.name == 'Supplier' ){
            this.suppl = event.target.value;
        }
        else if( event.target.name == 'G/L Date From' ){
            //console.log(event.target.value);
            this.gl_fromDate = event.target.value;
        }
        else if( event.target.name == 'G/L Date To' ){
            this.gl_toDate = event.target.value;
        }
        else if( event.target.name == 'Status' ){
            this.Statu = event.target.value;
        }        
    }

    runSearch(){
        this.soql='select id, name,RecordType.DeveloperName,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_PO__r.Name,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Invoice_Number__c,ASI_MFM_PO__r.ASI_MFM_Status__c, ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Base_Currency_Remaining_Balance__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO__r.ASI_MFM_PO_Name__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Supplier_Number__c, ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_SG_BA_verify__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Name,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.Name,ASI_MFM_Currency__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_G_L_Date__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        this.soqlSubbrand='select ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Base_Currency_Amount__c) TotalOPO, sum(ASI_MFM_Base_Currency_Remaining_Balance__c) TotalRPO from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        this.soqlpo='select id,name,Owner.name,ASI_MFM_Supplier_Name__r.name ,ASI_MFM_Plan__r.name,ASI_MFM_BU_Code__r.name,ASI_MFM_PO_Name__c,ASI_MFM_BU_Code__c,ASI_MFM_Plan__c,ASI_MFM_Sys_Plan_Amount__c,ASI_MFM_Plan_Balance__c,ASI_MFM_Sys_Plan_Name__c,ASI_MFM_Supplier_Name__c,ASI_MFM_Supplier_Number__c,ASI_MFM_Currency__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_PO_Raised_Date__c,ASI_MFM_Remarks__c,ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c,ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_PO_Balance__c,ASI_MFM_Payment_Request_Amount__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_Base_Currency_Amount__c    from ASI_MFM_PO__c where ASI_MFM_PO_Amount__c>=0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        //console.log(this.soql);
        if(this.PO_ID){
            this.soql += ' and ASI_MFM_PO__r.Name LIKE \''+this.PO_ID.replace(/'/g, "\\'")+'%\'';
            this.soqlSubbrand+= ' and ASI_MFM_PO__r.Name LIKE \''+this.PO_ID.replace(/'/g, "\\'")+'%\'';
        }
        if (this.PO_Line_ID){ 
            this.soqlSubbrand+= ' and name LIKE \''+this.PO_Line_ID.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and name LIKE \''+this.PO_Line_ID.replace(/'/g, "\\'")+'%\'';
        }
        if (this.Plan_ID){
            this.soqlSubbrand+= ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.Name LIKE \'%'+this.Plan_ID.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.Name LIKE \'%'+this.Plan_ID.replace(/'/g, "\\'")+'%\'';
        }
        if (this.PlanName){
            this.soqlSubbrand+= ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \'%'+this.PlanName.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \'%'+this.PlanName.replace(/'/g, "\\'")+'%\'';
        }
        if (this.Fiscalyear && this.PO_Line_ID=='' && this.Plan_ID==''){
            this.soqlSubbrand+= ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear.replace(/'/g, "\\'")+'%\'';
            this.soqlpo += ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear.replace(/'/g, "\\'")+'%\'';
        }
        if (this.ACcode){
            this.soqlSubbrand+= ' and ASI_MFM_A_C_Code__r.Name LIKE \'%'+this.ACcode.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_A_C_Code__r.Name LIKE \'%'+this.ACcode.replace(/'/g, "\\'")+'%\'';
        }
        if (this.SubBrandCode){
            this.soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+this.SubBrandCode.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+this.SubBrandCode.replace(/'/g, "\\'")+'%\'';
        }
        if (this.SubBrand){
            this.soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.Name LIKE \'%'+this.SubBrand.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_Sub_brand_Code__r.Name LIKE \'%'+this.SubBrand.replace(/'/g, "\\'")+'%\'';
        }
        if (this.Supplier_Num){
            this.soqlSubbrand+= ' and ASI_MFM_PO_Supplier_Number__c LIKE \'%'+this.Supplier_Num.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_PO_Supplier_Number__c LIKE \'%'+this.Supplier_Num.replace(/'/g, "\\'")+'%\'';
        }
        /*if (this.Supplier){
            this.soqlSubbrand+= ' and ASI_MFM_PO_Supplier_Number__c LIKE \'%'+this.Supplier.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_PO_Supplier_Number__cLIKE \'%'+this.Supplier.replace(/'/g, "\\'")+'%\'';
        }*/
        if(this.suppl){
            this.soqlSubbrand +=  ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+this.suppl.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name LIKE \'%'+this.suppl.replace(/'/g, "\\'")+'%\'';
        }
        if(this.gl_fromDate){
            var fromDate = this.gl_fromDate;
            this.soql += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
            this.soqlSubbrand += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + '';
        }
        if(this.gl_toDate){
            var toDate = this.gl_toDate;
            this.soql += ' AND ASI_MFM_G_L_Date__c  <= ' + toDate + ''; 
            this.soqlSubbrand += ' AND ASI_MFM_G_L_Date__c  <= ' + toDate + '';
        }
        if (this.Statu){
            this.soqlSubbrand += ' and ASI_MFM_PO__r.ASI_MFM_Status__c LIKE \''+this.Statu.replace(/'/g, "\\'")+'%\''; 
            this.soql += ' and ASI_MFM_PO__r.ASI_MFM_Status__c LIKE \''+this.Statu.replace(/'/g, "\\'")+'%\''; 
        }
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