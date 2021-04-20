import { LightningElement, track, api } from 'lwc';

//Import Toast Library
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Import Apex Class Function
import getSubBrand from '@salesforce/apex/ASI_CRM_PH_VisitationPlanModifyCtrl.getSubBrand';
import getRecord from '@salesforce/apex/ASI_CRM_PH_VisitationPlanModifyCtrl.getRecord';
import saveRecord from '@salesforce/apex/ASI_CRM_PH_VisitationPlanModifyCtrl.saveRecord';

export default class ASI_CRM_PH_Visitation_Plan_Modification_Comp extends LightningElement {
    
    @api recordId;
    
    //Data Parameter
    @track visitationPlanDetail = null;

    //Sub Brand Parameter
    @track allMenuListing      = null;
    @track filteredMenuListing = [];
    @track selectedMenuListing = [];

    @track allPouring      = null;
    @track filteredPouring = [];
    @track selectedPouring = [];

    //Filter Parameter 
    @track inputhMenuListing = "";
    @track inputPouring     = "";

    //Display Control Parameter
    @track showSpinner = false;
    @track isEdit      = false;

    isInit = false;

    //DataTable Config Parameter
    @track mode = "VIEW";

    @track fieldList = [
        {
            'id'         : 'label',
            'title'      : 'Sub Brand Name',
            'type'       : 'text',
            'editable'   : false
        }
    ];
    @track componentConfig = {
        'allowView'       : false,
        'allowSelect'     : false,
        'allowEdit'       : false,
        'allowClone'      : false,
        'allowDelete'     : false,
        'allowPagination' : false,
        'allowResponsive' : false
    };

    @track menuListingComponentCallback = {
        'selectRecordCallback' : this.onSelectMenuListingCallback.bind(this)
    };

    @track pouringComponentCallback = {
        'selectRecordCallback' : this.onSelectPouringCallback.bind(this)
    };

    /*************
    LWC LifeCycle Function
    *************/
    connectedCallback() {
        this.getCustomVisitationPlanFromApex(this.recordId);
        this.getSubBrandFromApex();
    }

    initPage() {
        if(this.isInit)
            return;

        if(this.allMenuListing && 
            this.allPouring && 
            this.visitationPlanDetail) {
            this.isInit = true;

            this.allMenuListing = JSON.parse(JSON.stringify(this.allMenuListing));
            this.allPouring     = JSON.parse(JSON.stringify(this.allPouring));

            if(this.visitationPlanDetail.ASI_CRM_Menu_Listing__c)
                this.visitationPlanDetail.ASI_CRM_Menu_Listing__c.split(";").forEach(menuListing => {
                    var index = this.allMenuListing.findIndex(menuListingObj => menuListingObj.label.replace(/\s/g, '') === menuListing.replace(/\s/g, ''));

                    if(index !== -1) {
                        this.allMenuListing[index].isSelected = true;

                        this.filteredMenuListing.push(this.allMenuListing[index]);
                        this.selectedMenuListing.push(this.allMenuListing[index]);
                    }
                });

            if(this.visitationPlanDetail.ASI_CRM_Pouring__c)
                this.visitationPlanDetail.ASI_CRM_Pouring__c.split(";").forEach(pouring => {
                    var index = this.allPouring.findIndex(pouringObj => pouringObj.label.replace(/\s/g, '') === pouring.replace(/\s/g, ''));
    
                    if(index !== -1) {
                        this.allPouring[index].isSelected = true;

                        this.filteredPouring.push(this.allPouring[index]);
                        this.selectedPouring.push(this.allPouring[index]);
                    }
                });
        }
    }

    /*************
    Page Controle Function
    *************/
    enableEditMode() {
        this.filteredMenuListing = this.allMenuListing;
        this.filteredPouring     = this.allPouring;

        this.componentConfig.allowSelect = true;

        this.isEdit = true;
    }

    saveAndDisableEditMode() {
        var menuListing = "";
        var pouring     = "";

        this.allMenuListing.forEach(menuListingObj => {
            if(menuListingObj.isSelected)
                menuListing += menuListingObj.label + ";";
        });

        this.allPouring.forEach(pouringObj => {
            if(pouringObj.isSelected)
                pouring += pouringObj.label + ";";
        });

        this.saveCustomVisitationPlanFromApex(this.recordId, menuListing, pouring);
        this.disableEditMode();
    }

    disableEditMode() {
        this.filteredMenuListing = this.selectedMenuListing;
        this.filteredPouring = this.selectedPouring;
        
        this.allMenuListing.forEach(menuListing => {
            var index = this.selectedMenuListing.findIndex(menuListingObj => menuListingObj.value === menuListing.value);

            if(index === -1)
                menuListing.isSelected = false;
        });

        this.allPouring.forEach(pouring => {
            var index = this.selectedPouring.findIndex(pouringObj => pouringObj.value === pouring.value);

            if(index === -1)
                pouring.isSelected = false;
        });

        this.componentConfig.allowSelect = false;

        this.isEdit = false;
    }

    showToastMessage(title, message, type) {
        this.dispatchEvent(
            new ShowToastEvent({
                title   : title,
                message : message,
                variant : type
            })
        );
    }

    /*************
    Filter Function
    *************/
    searchMenuListing(event) {
        var target = event.target.value;

        if(!target) {
            this.filteredMenuListing = this.allMenuListing;
            return;
        }
        
        target = target.toLowerCase();

        this.filteredMenuListing = this.allMenuListing.filter(menuListing => {
            return menuListing.label.toLowerCase().includes(target);
        });
    }

    searchPouring(event) {
        var target = event.target.value;

        if(!target) {
            this.filteredPouring = this.allPouring;
            return;
        }
        
        target = target.toLowerCase();

        this.filteredPouring = this.allPouring.filter(pouring => {
            return pouring.label.toLowerCase().includes(target);
        });
    }

    /*************
    Data Table Event Callback Function
    *************/
    onSelectMenuListingCallback(record) {
        let index = this.allMenuListing.findIndex(menuListingObj => menuListingObj.value === record.value);

        if(index !== -1) 
            this.allMenuListing[index].isSelected = !this.allMenuListing[index].isSelected;
    }

    onSelectPouringCallback(record) {
        let index = this.allPouring.findIndex(pouringObj => pouringObj.value === record.value);

        if(index !== -1) 
            this.allPouring[index].isSelected = !this.allPouring[index].isSelected;
    }

    /*************
    Apex Control Function
    *************/
    getSubBrandFromApex() {
        this.showSpinner = true;

        getSubBrand()
            .then(result => {
                this.showSpinner = false;

                this.allMenuListing = [];
                this.allPouring     = [];

                this.filteredMenuListing = [];
                this.filteredPouring = [];

                Object.keys(result).forEach(name => {
                    this.allMenuListing.push({
                        'Id'    : result[name],
                        'label' : name,
                        'value' : result[name]
                    });

                    this.allPouring.push({
                        'Id'    : result[name],
                        'label' : name,
                        'value' : result[name]
                    });
                });

                this.initPage();
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToastMessage("Warning!", error.body.message, "error");
            });
    }

    getCustomVisitationPlanFromApex(recordId) {
        var params = {
            'recordId' : recordId
        };

        this.showSpinner = true;

        getRecord(params)
            .then(result => {
                this.showSpinner = false;
                this.visitationPlanDetail = result;

                this.initPage();
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToastMessage("Warning!", error.body.message, "error");
            });
    }

    saveCustomVisitationPlanFromApex(recordId, menuListing, pouring) {
        var params = {
            'recordId'    : recordId,
            'menuListing' : menuListing,
            'pouring'     : pouring
        };

        this.showSpinner = true;

        saveRecord(params)
            .then(() => {
                this.showSpinner = false;
                location.reload();
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToastMessage("Warning!", error.body.message, "error");
            });
    }

}