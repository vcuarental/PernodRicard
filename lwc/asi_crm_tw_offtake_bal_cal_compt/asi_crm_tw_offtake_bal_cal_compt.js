import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OfftakeBALCalulationBatch from '@salesforce/apex/ASI_CRM_TW_Function.OfftakeBALCalulationBatch';
import fetchsObjectData from '@salesforce/apex/ASI_CRM_Function.fetchsObjectData';

export default class Asi_crm_tw_offtake_bal_cal_compt extends LightningElement {


    @track fieldconfig = {
        APIName: 'Account',
        Label: 'Account Name',
        type: 'lookup',
        editable: true,
        required: false,
        displayAPIName: 'Name',
        sublabelAPIName: 'ASI_HK_CRM_JDE_Account_Number__c',
        sourceObject: 'Account',
        filterFieldList: 'Name,ASI_HK_CRM_JDE_Account_Number__c',
        additionalFilter: ' (RecordType.DeveloperName =&apos;ASI_CRM_TW_Outlet&apos; or RecordType.DeveloperName =&apos;ASI_MFM_TW_Customer&apos; or RecordType.DeveloperName =&apos;ASI_CRM_TW_Wholesaler&apos; ) ',
        iconName: 'standard*client',
        QueryLimit: '100',
        style: '  '
    }


    @track SelectYear = '';
    @track SelectMonth = '';

    @track batchId = '';
    @track selectedName = '';
    @track LookupValue = '';
    @track onSelectedRecordCallback = this.onSelectedRecord.bind(this);
    @track visible;
    @track variant = 'error';
    @track message;
    @track progress = 5000;  
    @track includestk=false;


    connectedCallback() {
        this._interval = setInterval(() => { 
            if(this.batchId!=''){
                console.log('have batch ID');
                this.QueryBatchJobStatus();
            }
            
            /*
            this.progress = this.progress + 3000; 

            console.log( this.progress );  
            if ( this.progress === 60000 ) {  
                clearInterval(this._interval);  
            }  */
        }, 10000);  //every3 seconds
    }

    renderedCallback() {
    }

    QueryBatchJobStatus(){
        fetchsObjectData({
            soqlStatement: "SELECT Id, ExtendedStatus,Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = '"+this.batchId+"'"
        }).then(data => {
            var result = data[0];
            if( result.Status=='Completed' && !result.ExtendedStatus){
                
                this.batchId = '';

                this.message = 'Job Completed';
                this.variant = 'success';
                this.visible = true;

            }else if( result.Status=='Completed'){
                this.message = result.ExtendedStatus;
                this.variant = 'error';
                this.visible = true;
                this.batchId = '';
                console.log('error');
            }else{
                this.message = result.Status;
                this.variant = 'success';
                this.visible = true;
                console.log('running');
            }
        }).catch(error => {
            this.showSpinner = false;
            console.log(' ** error ** ');
            console.log(error);
        });
    }


    get mainDivClass() {
        return 'slds-notify slds-notify_toast slds-box slds-box_small slds-theme_' + this.variant;
    }

    closeModel(event) {
        this.visible = false;
    }


    handleCheckBoxChange(event) {
        this.includestk = event.target.checked;
        console.log(' include stk '+ this.includestk);
    }

    handleChange(event) {
        var fieldname = event.currentTarget.dataset.field;
        if (fieldname == 'SelectYear') {
            this.SelectYear = event.detail.value;
        }

        if (fieldname == 'SelectMonth') {
            this.SelectMonth = event.detail.value;
        }
    }


    onClickCalculate(event) {
        var checkingResult = { passValidation: true, Msg: '' };

        if (!this.LookupValue) {
            checkingResult.passValidation = false;
            checkingResult.Msg = 'Please input Customer.';
        } else if (!this.SelectYear) {
            checkingResult.passValidation = false;
            checkingResult.Msg = 'Please select Year.';
        } else if (!this.SelectMonth) {
            checkingResult.passValidation = false;
            checkingResult.Msg = 'Please select Month.';
        }

        if (checkingResult.passValidation) {
            var mm = Number(this.SelectMonth);
            var mmstr = this.SelectMonth;
            if (mm < 10) {
                mmstr = '0' + mmstr;
            }
            console.log(' include stk '+ this.includestk);
            var customerstr = this.LookupValue + '_' + this.SelectYear + '_' + mmstr + '_' +  this.includestk;
            console.log(customerstr);

            OfftakeBALCalulationBatch({
                customerstr: customerstr
            }).then(data => {
                console.log('finished');
                console.log(data);
                this.batchId = data;
                this.showSpinner = false;

                this.message = 'Job Submitted';
                this.variant = 'success';
                this.visible = true;

            }).catch(error => {
                this.showSpinner = false;
                this.message = error;
                this.visible = true;
                this.variant = 'error';

            });
        } else {
            this.showSpinner = false;
            this.message = checkingResult.Msg;
            this.visible = true;
            this.variant = 'error';
        }
    }

    onSelectedRecord(recordId, recordLabel) {
        console.log('recordLabel : ' + recordLabel);
        console.log('recordId : ' + recordId);

        this.selectedName = recordLabel;
        this.LookupValue = recordId;
    }



    get monthOptions() {
        var returnOption = [];
        for (var i = 1; i < 13; i++) {
            returnOption.push({ label: i.toString(), value: i.toString() });
        }
        return returnOption;
    }

    get yearOptions() {
        var returnOption = [];
        for (var i = 2020; i < 2043; i++) {
            returnOption.push({ label: i.toString(), value: i.toString() });
        }
        return returnOption;
    }

}