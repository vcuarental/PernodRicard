import { LightningElement, track } from 'lwc';

//Import Toast Library
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Import Apex Class Function
import getCustomerDataSet from '@salesforce/apex/ASI_CRM_PH_WorkInProgressReportCtrl.getCustomerDataSet';

export default class ASI_CRM_PH_WorkInProgress_Report_Comp extends LightningElement {

    //Data Parameter
    @track customCustomerList = [];
    @track filteredCustomCustomerList = [];

    //Filter Parameter
    @track ownerNameList      = [];
    @track customerNameList   = [];

    @track selectedOwnerNameList    = [];
    @track selectedCustomerNameList = [];

    @track isShowCustomerSelect = false;
    @track isShowOwnerSelect = false;

    //Display Control Parameter
    @track showSpinner = false;
    @track isMobile = false;

    //DataTable Config Parameter
    @track mode = "VIEW";

    @track fieldList = [
        {
            'id'         : 'outletName',
            'title'      : 'Outlet Name',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'area',
            'title'      : 'Area',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'lastVisitDate',
            'title'      : 'Last Visit Date',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'ownerName',
            'title'      : 'Account Executive',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'menuListing',
            'title'      : 'Menu Listing',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'promotion',
            'title'      : 'On-Going Promotion',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'pouring',
            'title'      : 'Pouring',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'status',
            'title'      : 'Status',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'nextStep',
            'title'      : 'Next Step',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'contact',
            'title'      : 'Contact Person',
            'type'       : 'text',
            'editable'   : false
        }
    ];

    /*************
    Getter Function
    *************/
    get customerSelectClass() {
        return this.isShowCustomerSelect ? "open" : "";
    }

    get ownerSelectClass() {
        return this.isShowOwnerSelect ? "open" : "";
    }

    /*************
    LWC LifeCycle Function
    *************/
    connectedCallback() {
        this.isMobile = this.checkMobileUserAgent();

        if(this.isMobile === false)
            this.getCustomCustomerFromApex(this.recordId);
    }

    /*************
    Filter Function
    *************/
    onOwnerSelected(event) {
        var ownerName = event.target.value;
        var index = this.selectedOwnerNameList.findIndex(selectedOwnerName => selectedOwnerName === ownerName);

        if(index === -1) {
            this.selectedOwnerNameList.push(ownerName);
        } else {
            this.selectedOwnerNameList.splice(index, 1);
        }

        this.filterRecordList();
    }

    onCustomerSelected(event) {
        var customerName = event.target.value;
        var index = this.selectedCustomerNameList.findIndex(selectedCustomerName => selectedCustomerName === customerName);

        if(index === -1) {
            this.selectedCustomerNameList.push(customerName);
        } else {
            this.selectedCustomerNameList.splice(index, 1);
        }

        this.filterRecordList();
    }

    filterRecordList() {
        if(this.selectedOwnerNameList.length === 0 && 
            this.selectedCustomerNameList.length === 0) {
            this.filteredCustomCustomerList = this.customCustomerList;
            return;
        }   
        
        this.filteredCustomCustomerList = this.customCustomerList.filter(customCustomer => {
            if(this.selectedOwnerNameList.length !== 0) {
                if(this.selectedOwnerNameList.includes(customCustomer.ownerName) === false) 
                    return false;
            }

            if(this.selectedCustomerNameList.length !== 0) {
                if(this.selectedCustomerNameList.includes(customCustomer.outletName) === false) 
                    return false;
            }

            return true;
        });
    }

    /*************
    Layout Function
    *************/
    showToastMessage(title, message, type) {
        this.dispatchEvent(
            new ShowToastEvent({
                title   : title,
                message : message,
                variant : type
            })
        );
    }

    checkMobileUserAgent() { 
        if( navigator.userAgent.match(/Android/i) || 
            navigator.userAgent.match(/webOS/i) || 
            navigator.userAgent.match(/iPhone/i) || 
            navigator.userAgent.match(/iPod/i) || 
            navigator.userAgent.match(/BlackBerry/i) || 
            navigator.userAgent.match(/Windows Phone/i)) {
            return true;
        }
        
        return false;
    }

    /*************
    Button Click Function
    *************/
    triggerOwnerSelectPanel() {
        this.isShowCustomerSelect = false;
        this.isShowOwnerSelect = !this.isShowOwnerSelect;
    }

    triggerCustomerSelectPanel() {
        this.isShowOwnerSelect = false;
        this.isShowCustomerSelect = !this.isShowCustomerSelect;
    }

    downloadCSV() {
        let rowEnd = '\n';
        let csvString = '';

        let headerRowData = [];
        this.fieldList.forEach(field => {
            headerRowData.push(field.title);
        });

        csvString += headerRowData.join(',');
        csvString += rowEnd;

        this.filteredCustomCustomerList.forEach(customCustomer => {

            this.fieldList.forEach(field => {
                let value = customCustomer[field.id] === undefined ? '' : customCustomer[field.id];
                csvString += '"' + value + '"';
                csvString += ',';
            });

            csvString += rowEnd;
        });

        let downloadElement      = document.createElement('a');
        downloadElement.href     = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target   = '_self';
        downloadElement.download = 'WorkInProgress.csv';

        document.body.appendChild(downloadElement);
        downloadElement.click(); 
    }

    /*************
    Apex Control Function
    *************/
    getCustomCustomerFromApex() {
        this.showSpinner = true;

        getCustomerDataSet()
            .then(result => {
                this.showSpinner = false;
                this.customCustomerList = []; 
                this.ownerNameList      = [];
                this.customerNameList   = [];

                result.forEach(row => {
                    let customCustomer = {};

                    if(row.customer) {
                        customCustomer.outletName = row.customer.Name;
                        customCustomer.area = row.customer.ASI_CRM_SG_Area__c;
                        customCustomer.lastVisitDate = row.customer.ASI_CRM_Last_Visit_Date__c;

                        if(row.customer.Owner) {
                            customCustomer.ownerName = row.customer.Owner.Name;

                            let index = this.ownerNameList.findIndex(ownerName => ownerName.label === row.customer.Owner.Name);
                            if(index === -1) 
                                this.ownerNameList.push({
                                    'label' : row.customer.Owner.Name,
                                    'value' : row.customer.Owner.Name
                                });
                        }

                        this.customerNameList.push({
                            'label' : row.customer.Name,
                            'value' : row.customer.Name
                        });
                    }

                    if(row.latestVisitationPlanDetail) {
                        customCustomer.menuListing = row.latestVisitationPlanDetail.ASI_CRM_Menu_Listing__c;
                        customCustomer.promotion = row.latestVisitationPlanDetail.ASI_CRM_On_Going_Promotion__c;
                        customCustomer.pouring = row.latestVisitationPlanDetail.ASI_CRM_Pouring__c;
                        customCustomer.nextStep = row.latestVisitationPlanDetail.ASI_CRM_Next_Step__c;
                    }

                    customCustomer.status = row.status;
                    customCustomer.contact = row.contact;

                    this.customCustomerList.push(customCustomer);
                });

                this.filteredCustomCustomerList = this.customCustomerList;
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToastMessage("Warning!", error.body.message, "error");
            });
    }
}