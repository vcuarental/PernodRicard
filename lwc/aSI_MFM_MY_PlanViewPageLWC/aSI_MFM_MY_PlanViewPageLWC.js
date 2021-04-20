import { LightningElement, api, track, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";
import RunQuery from '@salesforce/apex/ASI_MFM_MY_PlanViewLWC_Cls.RunQuery';

const columns = [
    { label: 'Plan ID', fieldName: 'PlanIDUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'PlanID' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Plan Line ID', fieldName: 'PlanLineIDUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'PlanLineID' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Plan Name', fieldName: 'PlanNameUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'PlanName' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Fiscal Year', fieldName: 'FiscalYear', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'A/C code', fieldName: 'ACcodeUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'ACcode' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'BU code', fieldName: 'BUcodeUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'BUcode' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Sub-Brand Name', fieldName: 'SubBrandNameUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'SubBrandName' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Customer Name', fieldName: 'CustomerNameUrl', type:'url', minColumnWidth:200, typeAttributes: {label: { fieldName: 'CustomerName' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Plan Line Description', fieldName: 'PlanLineDescription', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Plan Line Amount', fieldName: 'PlanLineAmount', type: 'number', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },typeAttributes: {minimumFractionDigits: 2, maximumFractionDigits: 2}},
    { label: 'No. of Outlets', fieldName: 'NumOfOutlets', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Exp. Vol.', fieldName: 'Vol', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Size', fieldName: 'Size', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
    { label: 'Plan Status', fieldName: 'PlanStatus', minColumnWidth:200, sortable: true, cellAttributes: { alignment: 'left' },},
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
    @track soqlSubbrandplan = '';
    @track ALLPlanAmount = 0;
    @track ALLTotalPOAmount = 0;
    @track ALLPlanBalance = 0;
    @track TotalSubBrand = 0;
    @track Plan_ID = '';
    @track PlanName = '';
    @track Fiscalyear = '';
    @track Statu = '';
    @track PlanLine_ID = '';
    @track ACcode = '';
    @track BUCode = '';
    @track SubBrandCode = '';
    @track SubBrand = '';
    @track CustomerName = '';
    @track NowFY = '';
    @track display = false;
    @track FiscalyearList = [];
    @track StatusList = [];
    @track maxPageNum = 1;
    @track currentPageNum = 1;
    @track sortField = 'ASI_MFM_Plan__r.name';
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
            {label: 'Final', value: 'Final'}];
 
        this.soqlSubbrandplan='select id, name,Owner.name,ASI_MFM_Plan_Name__c,ASI_MFM_Plan_Description__c,ASI_MFM_End_Date__c,ASI_MFM_Start_Date__c,ASI_MFM_Fiscal_year__c,ASI_MFM_Status__c,ASI_MFM_Plan_Raised_Date__c,ASI_MFM_Plan_Amount__c,ASI_MFM_Total_PO_Amount__c,ASI_MFM_Plan_Balance__c  from ASI_MFM_Plan__c where ASI_MFM_Plan_Amount__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        this.soql='select id,name,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c,ASI_MFM_Plan__r.name,ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Plan__r.ASI_MFM_Status__c,ASI_MFM_Plan_id_sys__c,ASI_MFM_Plan_Name_sys__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_Customer_Name__c,ASI_MFM_Total_Cost__c,ASI_MFM_Number_of_Outlets__c,ASI_MFM_Expected_Volume__c,ASI_MFM_Size__c,ASI_MFM_BU_Code__c from ASI_MFM_Plan_Line_Item__c where  ASI_MFM_Total_Cost__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        this.soqlSubbrand='select ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Total_Cost__c) TotalPLI from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Total_Cost__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        if (this.Fiscalyear){
            this.soqlSubbrand+= ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear+'%\'';
            this.soql += ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear+'%\'';
            this.soqlSubbrandplan += ' and ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear+'%\'';
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
        //console.log(this.soqlSubbrandplan);
        //console.log(tempSoql);
        //console.log(this.soqlSubbrand);
        var param = {
            soqlSubbrand: this.soqlSubbrand, 
            soql: tempSoql,
            sqolwithLimit: tempSoqlwithLimit,
            soqlSubbrandplan: this.soqlSubbrandplan
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
                    else if (result.planLineItemList){
                        var planLineItemList = result.planLineItemList;
                        var listlength = planLineItemList.length;
                        const data = []  
                        for (var i = 0; i < listlength; i++) {
                            var lineitem = {
                                id: i,
                                PlanID: planLineItemList[i].ASI_MFM_Plan__r.Name,
                                PlanIDUrl: '/'+planLineItemList[i].ASI_MFM_Plan__c,
                                PlanLineID: planLineItemList[i].Name,
                                PlanLineIDUrl: '/'+planLineItemList[i].Id,
                                PlanName: planLineItemList[i].ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,
                                PlanNameUrl: '/'+planLineItemList[i].ASI_MFM_Plan__c,
                                FiscalYear: planLineItemList[i].ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,
                                PlanLineDescription: planLineItemList[i].ASI_MFM_List_Item_Description__c,
                                PlanLineAmount: planLineItemList[i].ASI_MFM_Total_Cost__c,
                                NumOfOutlets: planLineItemList[i].ASI_MFM_Number_of_Outlets__c,
                                Vol: planLineItemList[i].ASI_MFM_Expected_Volume__c,
                                Size: planLineItemList[i].ASI_MFM_Size__c,
                                PlanStatus: planLineItemList[i].ASI_MFM_Plan__r.ASI_MFM_Status__c
                            };  
                            
                            if(planLineItemList[i].ASI_MFM_A_C_Code__r && planLineItemList[i].ASI_MFM_A_C_Code__r.Name){
                                lineitem.ACcode = planLineItemList[i].ASI_MFM_A_C_Code__r.Name;
                                lineitem.ACcodeUrl = '/'+planLineItemList[i].ASI_MFM_A_C_Code__c;
                            }
                            if(planLineItemList[i].ASI_MFM_BU_Code__r && planLineItemList[i].ASI_MFM_BU_Code__r.Name){
                                lineitem.BUcode = planLineItemList[i].ASI_MFM_BU_Code__r.Name;
                                lineitem.BUcodeUrl = '/'+planLineItemList[i].ASI_MFM_BU_Code__c;
                            }
                            if(planLineItemList[i].ASI_MFM_Sub_brand_Code__r && planLineItemList[i].ASI_MFM_Sub_brand_Code__r.Name){
                                lineitem.SubBrandName = planLineItemList[i].ASI_MFM_Sub_brand_Code__r.Name;
                                lineitem.SubBrandNameUrl = '/'+planLineItemList[i].ASI_MFM_Sub_brand_Code__c;
                            }
                            if(planLineItemList[i].ASI_MFM_Customer_Name__r && planLineItemList[i].ASI_MFM_Customer_Name__r.Name){
                                lineitem.CustomerName = planLineItemList[i].ASI_MFM_Customer_Name__r.Name;
                                lineitem.CustomerNameUrl = '/'+planLineItemList[i].ASI_MFM_Customer_Name__c;
                            }
                            data.push(lineitem);
                        }
                        this.data = data;
                        console.log(this.data);
                        this.Summaries = result.Summaries;
                        this.ALLPlanAmount = result.ALLPlanAmount;
                        this.ALLTotalPOAmount = result.ALLTotalPOAmount;
                        this.ALLPlanBalance = result.ALLPlanBalance;
                        this.TotalSubBrand = result.TotalSubBrand;
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
        if(this.sortedBy == 'PlanID')
        {
            this.sortField = 'ASI_MFM_Plan__r.name'
        }
        else if(this.sortedBy == 'PlanLineID')
        {
            this.sortField = 'name'
        }
        else if(this.sortedBy == 'PlanName')
        {
            this.sortField = 'ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c'
        }
        else if(this.sortedBy == 'FiscalYear')
        {
            this.sortField = 'ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c'
        }
        else if(this.sortedBy == 'ACcode')
        {
            this.sortField = 'ASI_MFM_A_C_Code__r.name'
        }
        else if(this.sortedBy == 'BUcode')
        {
            this.sortField = 'ASI_MFM_BU_Code__c'
        }
        else if(this.sortedBy == 'SubBrandName')
        {
            this.sortField = 'ASI_MFM_Sub_brand_Code__r.name'
        }
        else if(this.sortedBy == 'CustomerName')
        {
            this.sortField = 'ASI_MFM_Customer_Name__c'
        }
        else if(this.sortedBy == 'PlanLineDescription')
        {
            this.sortField = 'ASI_MFM_List_Item_Description__c'
        }
        else if(this.sortedBy == 'PlanLineAmount')
        {
            this.sortField = 'ASI_MFM_Total_Cost__c'
        }
        else if(this.sortedBy == 'NumOfOutlets')
        {
            this.sortField = 'ASI_MFM_Number_of_Outlets__c'
        }
        else if(this.sortedBy == 'Vol')
        {
            this.sortField = 'ASI_MFM_Expected_Volume__c'
        }
        else if(this.sortedBy == 'Size')
        {
            this.sortField = 'ASI_MFM_Size__c'
        }
        else if(this.sortedBy == 'PlanStatus')
        {
            this.sortField = 'ASI_MFM_Plan__r.ASI_MFM_Status__c'
        }
        this.LimitFrom = 0;
        this.currentPageNum = 1;
        this.runQuery();
    }

    handleInputChange(event){
        if( event.target.name == 'Plan ID' ){
            this.Plan_ID = event.target.value;
        }
        else if( event.target.name == 'Plan Line ID' ){
            this.PlanLine_ID = event.target.value;
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
        else if( event.target.name == 'BU Code' ){
            this.BUCode = event.target.value;
        }
        else if( event.target.name == 'Sub-Brand Code' ){
            this.SubBrandCode = event.target.value;
        }
        else if( event.target.name == 'Sub-Brand Name' ){
            this.SubBrand = event.target.value;
        }
        else if( event.target.name == 'Customer Name' ){
            this.CustomerName = event.target.value;
        }else if( event.target.name == 'Status' ){
            this.Statu = event.target.value;
        }
        
    }

    runSearch(){
        this.soqlSubbrandplan='select id, name,Owner.name,ASI_MFM_Plan_Name__c,ASI_MFM_Plan_Description__c,ASI_MFM_End_Date__c,ASI_MFM_Start_Date__c,ASI_MFM_Fiscal_year__c,ASI_MFM_Status__c,ASI_MFM_Plan_Raised_Date__c,ASI_MFM_Plan_Amount__c,ASI_MFM_Total_PO_Amount__c,ASI_MFM_Plan_Balance__c  from ASI_MFM_Plan__c where ASI_MFM_Plan_Amount__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        this.soql='select id,name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_Customer_Name__r.name,ASI_MFM_BU_Code__r.name,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c,ASI_MFM_Plan__r.name,ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Plan__r.ASI_MFM_Status__c,ASI_MFM_Plan_id_sys__c,ASI_MFM_Plan_Name_sys__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_Customer_Name__c,ASI_MFM_Total_Cost__c,ASI_MFM_Number_of_Outlets__c,ASI_MFM_Expected_Volume__c,ASI_MFM_Size__c,ASI_MFM_BU_Code__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Total_Cost__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        this.soqlSubbrand='select ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Total_Cost__c) TotalPLI from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Total_Cost__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        if(this.Plan_ID){
            this.soql += ' and ASI_MFM_Plan__r.name LIKE \''+this.Plan_ID.replace(/'/g, "\\'")+'%\'';
            this.soqlSubbrand+= ' and ASI_MFM_Plan__r.name LIKE \''+this.Plan_ID.replace(/'/g, "\\'")+'%\'';
        }
        if (this.PlanLine_ID){ 
            this.soqlSubbrand+= ' and name LIKE \''+this.PlanLine_ID.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and name LIKE \''+this.PlanLine_ID.replace(/'/g, "\\'")+'%\'';
        }
        if (this.PlanName){
            this.soqlSubbrand+= ' and ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \'%'+this.PlanName.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c LIKE \'%'+this.PlanName.replace(/'/g, "\\'")+'%\'';
        }
        if (this.Fiscalyear && this.PlanLine_ID=='' && this.Plan_ID==''){
            this.soqlSubbrand+= ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear.replace(/'/g, "\\'")+'%\'';
            this.soqlSubbrandplan += ' and ASI_MFM_Fiscal_year__c LIKE \''+this.Fiscalyear.replace(/'/g, "\\'")+'%\'';
        }
        if (this.ACcode){
            this.soqlSubbrand+= ' and ASI_MFM_A_C_Code__r.name LIKE \'%'+this.ACcode.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_A_C_Code__r.name LIKE \'%'+this.ACcode.replace(/'/g, "\\'")+'%\'';
        }
        if (this.BUCode){
            //20201104:AM@introv - change from BU Code to Plan Line Description
            //this.soqlSubbrand += ' and ASI_MFM_BU_Code__r.name LIKE \'%'+this.BUCode.replace(/'/g, "\\'")+'%\'';
            //this.soql += ' and ASI_MFM_BU_Code__r.name LIKE \'%'+this.BUCode.replace(/'/g, "\\'")+'%\'';
            this.soqlSubbrand += ' and ASI_MFM_List_Item_Description__c LIKE \'%'+this.BUCode.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_List_Item_Description__c LIKE \'%'+this.BUCode.replace(/'/g, "\\'")+'%\'';
        }
        if (this.SubBrandCode){
            this.soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+this.SubBrandCode.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \''+this.SubBrandCode.replace(/'/g, "\\'")+'%\'';
        }
        if (this.SubBrand){
            this.soqlSubbrand += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+this.SubBrand.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_Sub_brand_Code__r.name LIKE \'%'+this.SubBrand.replace(/'/g, "\\'")+'%\'';
        }
        if (this.CustomerName){
            this.soqlSubbrand+= ' and ASI_MFM_Customer_Name__r.name LIKE \'%'+this.CustomerName.replace(/'/g, "\\'")+'%\'';
            this.soql += ' and ASI_MFM_Customer_Name__r.name LIKE \'%'+this.CustomerName.replace(/'/g, "\\'")+'%\'';
        }
        if (this.Statu){
            this.soqlSubbrand += ' and ASI_MFM_Plan__r.ASI_MFM_Status__c LIKE \''+this.Statu.replace(/'/g, "\\'")+'%\''; 
            this.soql += ' and ASI_MFM_Plan__r.ASI_MFM_Status__c LIKE \''+this.Statu.replace(/'/g, "\\'")+'%\''; 
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
/*
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
<script>
    $(document).on('mousemove', function(e){
        $('#loadtext').css({
           left:  e.pageX,
           top:   e.pageY
        });
    });
function checkApproveDelete(obj,opposeId){
    if($(obj).is(':checked')){
        $(obj).parent().parent().find("[id*="+opposeId+"]").attr('checked', !$(obj).is(':checked'));
    }
}

function checkAll(obj,opposeObjId,checkAllId,opposeId){    
    $("[id*="+checkAllId+"]").each(function(){
        $(this).attr('checked', $(obj).is(':checked'));
    });
    
    $("#"+opposeObjId).attr('checked', false);

    $("[id*="+opposeId+"]").each(function(){
        $(this).attr('checked', false);
    });        
}

function openAccountWin(id){
    window.open("/"+id);
}

</script>*/