import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DeleteOfftakeData from '@salesforce/apex/ASI_CRM_TW_Function.DeleteOfftakeData';

export default class Asi_crm_tw_purgeofftakecompt extends LightningElement {

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
        additionalFilter: ' (RecordType.DeveloperName =&apos;ASI_CRM_TW_Outlet&apos;  or RecordType.DeveloperName =&apos;ASI_CRM_TW_Key_Account&apos; or RecordType.DeveloperName =&apos;ASI_CRM_TW_Wholesaler&apos; ) ',
        iconName: 'standard*client',
        QueryLimit: '100',
        style: '  '
    }

    @track selectedName = '';
    @track LookupValue = '';
    @track onSelectedRecordCallback = this.onSelectedRecord.bind(this);

    @track fromDateInput;

    @track toDateInput;
    @track message;
    @track showSpinner = false;
    @track visible;
    @track variant = 'error';
    @track setting;


    connectedCallback() {

    }

    renderedCallback() {
    }




    onSelectedRecord(recordId, recordLabel) {
        console.log('recordLabel : ' + recordLabel);
        console.log('recordId : ' + recordId);

        this.selectedName = recordLabel;
        this.LookupValue = recordId;
    }


    onFieldUpdate(event) {
        var fieldname = event.currentTarget.dataset.field;
        console.log('fieldname : ' + fieldname);
        console.log('fieldname : ' + event.target.value);
        console.log('generateDate : ' + this.generateDate(event.target.value) );
        
        if (fieldname == 'fromDateInput') {
            this.fromDateInput = event.target.value;
        } else {
            this.toDateInput = event.target.value;
        }
        // event.target.value
        //event.target.value;
    }

    closeModel(event) {
        this.visible = false;
    }

    onClickPurge(event) {
        this.visible = false;
        this.showSpinner = true;
        console.log('onClickPurge 1.0');

        var checkingResult = { passValidation: true, Msg: '' };
        checkingResult = this.basicChecking();
        if (checkingResult.passValidation) {
            var sqlstr = "select id,OwnerId,ASI_TH_CRM_Outlet__r.RecordType.DeveloperName,ASI_TH_CRM_Outlet__c,ASI_TH_CRM_From_Wholesaler__c,ASI_TH_CRM_From_Wholesaler__r.RecordType.DeveloperName ,ASI_CRM_Channel__c,ASI_TH_CRM_Offtake_G_L_Date__c,ASI_CRM_Action_Type__c from ASI_TH_CRM_Actual_Offtake__c where  ASI_TH_CRM_From_Wholesaler__c = '" + this.LookupValue +
                 "'  and  ASI_TH_CRM_Offtake_G_L_Date__c >= " + this.generateDate(this.fromDateInput) + ' and ASI_TH_CRM_Offtake_G_L_Date__c<=' + this.generateDate(this.toDateInput);
            console.log(' sqlstr :' + sqlstr);
            DeleteOfftakeData({
                soqlStatement: sqlstr
            }).then(data => {
                console.log('finished');
                console.log(data);
                this.showSpinner = false;
                if (data.includes('Success')) {
                    this.message = data;
                    this.variant = 'success';
                    this.visible = true;
                   
                } else {
                    this.message = data;
                    this.variant = 'error';
                    this.visible = true;
                      
                }
            }).catch(error => {
                this.showSpinner = false;
                this.message = error;
                this.visible = true;
                this.variant = 'error';
                
            });
        } else {// failed
            this.showSpinner = false;
            this.message = checkingResult.Msg;
            this.visible = true;
            this.variant = 'error';
           
        }

    }

    get mainDivClass() {
        return 'slds-notify slds-notify_toast slds-box slds-box_small slds-theme_' + this.variant;
    }


    generateDate(InputDatestr) {
        var InputDate = new Date(InputDatestr);
        var mm = InputDate.getMonth() + 1;
        var dd = InputDate.getDate();
        var yy = InputDate.getFullYear();

        if (dd < 10) {
            dd = dd.toString();
            dd = '0' + dd;
        } else {
            dd = dd.toString();
        }

        if (mm < 10) {
            mm = mm.toString();
            mm = '0' + mm;
        } else {
            mm = mm.toString();
        }


        return yy.toString() + '-' + mm + '-' + dd;
    }

    basicChecking() {
        var checkingResult = { passValidation: true, Msg: '  ' };
        if (!this.fromDateInput) {
            checkingResult.passValidation = false;
            checkingResult.Msg = 'Please input From Date.';
        }
        if (!this.toDateInput) {
            checkingResult.passValidation = false;
            checkingResult.Msg = 'Please input To Date.';
        }

        if (!this.LookupValue) {
            checkingResult.passValidation = false;
            checkingResult.Msg = 'Please input Customer.';
        }

        return checkingResult;
    }



    showToastMessage(title, message, type, mode) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: type,
                mode: mode
            })
        );
    }


}