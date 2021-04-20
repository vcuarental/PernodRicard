import { LightningElement, track } from 'lwc';
import fetchsObjectData from '@salesforce/apex/ASI_CRM_Function.fetchsObjectData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertsObjList from '@salesforce/apex/ASI_CRM_Function.upsertsObjList';



export default class Asi_crm_tw_periodcontrolcompt extends LightningElement {
    @track OpenPeriod = {};
    @track reOpenPeriod = {};
    @track confirmedPeriod = {};
    @track showSpinner = false;
    @track recordId;
    @track previousRecord={};
    @track setting;

    connectedCallback() {
        console.log('version 1.1');
        this.initialize();
    }

    renderedCallback() {
        console.log('enter renderedCallback ');
    }
    

    initialize() {
        this.showSpinner = true;
        fetchsObjectData({
            soqlStatement: "select Id,ASI_CRM_Offtake_From_Year_WS_Previous__c,ASI_CRM_Re_Open_WS__c,ASI_CRM_Re_Open_SWS__c,ASI_CRM_Offtake_From_Month_WS_Previous__c,ASI_CRM_Offtake_From_Year_SWS_Previous__c,ASI_CRM_Offtake_From_Month_SWS_Previous__c,ASI_CRM_Daily_Offtake_From_Year_WS__c,ASI_CRM_Daily_Offtake_From_Month_WS__c,ASI_CRM_Daily_Offtake_From_Year_SWS__c,ASI_CRM_Daily_Offtake_From_Month_SWS__c from  ASI_CRM_TW_Settings__c  "
        }).then(data => {
            this.recordId = data[0].Id;
            this.setting = data[0];
            this.confirmedPeriod.wsyy = data[0].ASI_CRM_Daily_Offtake_From_Year_WS__c;
            this.confirmedPeriod.wsmm = data[0].ASI_CRM_Daily_Offtake_From_Month_WS__c;
            this.confirmedPeriod.swsyy = data[0].ASI_CRM_Daily_Offtake_From_Year_SWS__c;
            this.confirmedPeriod.swsmm = data[0].ASI_CRM_Daily_Offtake_From_Month_SWS__c;

            this.previousRecord.wsyy = data[0].ASI_CRM_Offtake_From_Year_WS_Previous__c;
            this.previousRecord.wsmm = data[0].ASI_CRM_Offtake_From_Month_WS_Previous__c;
            this.previousRecord.swsyy = data[0].ASI_CRM_Offtake_From_Year_SWS_Previous__c;
            this.previousRecord.swsmm = data[0].ASI_CRM_Offtake_From_Month_SWS_Previous__c;

            // re-open period = open period
            this.reOpenPeriod.wsyy = data[0].ASI_CRM_Daily_Offtake_From_Year_WS__c;
            this.reOpenPeriod.wsmm = data[0].ASI_CRM_Daily_Offtake_From_Month_WS__c;
            this.reOpenPeriod.swsyy = data[0].ASI_CRM_Daily_Offtake_From_Year_SWS__c;
            this.reOpenPeriod.swsmm = data[0].ASI_CRM_Daily_Offtake_From_Month_SWS__c;

           

            if (data[0].ASI_CRM_Daily_Offtake_From_Month_WS__c == '12') {
                this.OpenPeriod.wsyy = (Number(data[0].ASI_CRM_Daily_Offtake_From_Year_WS__c) + 1).toString();
                this.OpenPeriod.wsmm = '1';
            } else {
                this.OpenPeriod.wsyy = data[0].ASI_CRM_Daily_Offtake_From_Year_WS__c;
                this.OpenPeriod.wsmm = (Number(data[0].ASI_CRM_Daily_Offtake_From_Month_WS__c) + 1).toString();
            }

            if (data[0].ASI_CRM_Daily_Offtake_From_Month_SWS__c == '12') {
                this.OpenPeriod.swsyy = (Number(data[0].ASI_CRM_Daily_Offtake_From_Year_SWS__c) + 1).toString();
                this.OpenPeriod.swsmm = '1';
            } else {
                this.OpenPeriod.swsyy = data[0].ASI_CRM_Daily_Offtake_From_Year_SWS__c;
                this.OpenPeriod.swsmm = (Number(data[0].ASI_CRM_Daily_Offtake_From_Month_SWS__c) + 1).toString();
            }

            this.showSpinner = false;
            console.log(' ** end **');
        }).catch(error => {
            this.showSpinner = false;
            console.log(' ** error ** ');
            console.log(error);
        });
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
        for (var i = 2019; i < 2043; i++) {
            returnOption.push({ label: i.toString(), value: i.toString() });
        }
        return returnOption;
    }

    handleChange(event) {
        var fieldname = event.currentTarget.dataset.field;
        console.log('value : ' + event.detail.value);
        console.log('fieldname : ' + fieldname);
        if (fieldname == 'OpenPeriod.wsyy') {
            this.OpenPeriod.wsyy = event.detail.value;
        }

        if (fieldname == 'OpenPeriod.wsmm') {
            this.OpenPeriod.wsmm = event.detail.value;
        }

        if (fieldname == 'reOpenPeriod.wsyy') {
            this.reOpenPeriod.wsyy = event.detail.value;
        }
        if (fieldname == 'reOpenPeriod.wsmm') {
            this.reOpenPeriod.wsmm = event.detail.value;
        }
        if (fieldname == 'OpenPeriod.swsyy') {
            this.OpenPeriod.swsyy = event.detail.value;
        }
        if (fieldname == 'OpenPeriod.swsmm') {
            this.OpenPeriod.swsmm = event.detail.value;
        }
        if (fieldname == 'reOpenPeriod.swsyy') {
            this.reOpenPeriod.swsyy = event.detail.value;
        }
        if (fieldname == 'reOpenPeriod.swsmm') {
            this.reOpenPeriod.swsmm = event.detail.value;
        }

    }


    handleSave(event) {
        var fieldname = event.currentTarget.dataset.field;
        this.showSpinner = true;
        console.log('fieldname handleSave : ' + fieldname);
        if (fieldname == 'OpenPeriodws') {
            var mm, yy;
            if (this.previousRecord.wsmm == '12') {
                yy = (Number(this.previousRecord.wsyy) + 1).toString();
                mm = '1';
            }else{
                yy = this.previousRecord.wsyy;
                mm = (Number(this.previousRecord.wsmm) + 1).toString();
            }

            if(this.setting.ASI_CRM_Re_Open_WS__c){
                yy=this.previousRecord.wsyy;
                mm=this.previousRecord.wsmm;
            }

            this.processSave('ASI_CRM_Daily_Offtake_From_Year_WS__c', 'ASI_CRM_Daily_Offtake_From_Month_WS__c', yy, mm,
            'ASI_CRM_Offtake_From_Year_WS_Previous__c','ASI_CRM_Offtake_From_Month_WS_Previous__c' ,yy , mm,'ASI_CRM_Re_Open_WS__c',false);
        }


        if (fieldname == 'reOpenPeriodws') { // (Number(data[0].ASI_CRM_Daily_Offtake_From_Month_SWS__c) - 1).toString();
            var mm, yy;
            if (this.reOpenPeriod.wsmm == '1') {
                yy = (Number(this.reOpenPeriod.wsyy) - 1).toString();
                mm = '12';
            } else {
                yy = this.reOpenPeriod.wsyy;
                mm = (Number(this.reOpenPeriod.wsmm) - 1).toString();
            }
            this.processSave('ASI_CRM_Daily_Offtake_From_Year_WS__c', 'ASI_CRM_Daily_Offtake_From_Month_WS__c', yy, mm,
            '' ,'' , '','' ,'ASI_CRM_Re_Open_WS__c',true );
        }


        if (fieldname == 'OpenPeriodsws') {
            var mm, yy;
            if (this.previousRecord.swsmm == '12') {
                yy = (Number(this.previousRecord.swsyy) + 1).toString();
                mm = '1';
            }else{
                yy = this.previousRecord.swsyy;
                mm = (Number(this.previousRecord.swsmm) + 1).toString();
            }

            if(this.setting.ASI_CRM_Re_Open_SWS__c){
                yy=this.previousRecord.swsyy;
                mm=this.previousRecord.swsmm;
            }

            this.processSave('ASI_CRM_Daily_Offtake_From_Year_SWS__c', 'ASI_CRM_Daily_Offtake_From_Month_SWS__c', yy, mm,
            'ASI_CRM_Offtake_From_Year_SWS_Previous__c','ASI_CRM_Offtake_From_Month_SWS_Previous__c' ,yy , mm,'ASI_CRM_Re_Open_SWS__c',false);
        }


        if (fieldname == 'reOpenPeriodsws') { // (Number(data[0].ASI_CRM_Daily_Offtake_From_Month_SWS__c) - 1).toString();
            var mm, yy;
            if (this.reOpenPeriod.swsmm == '1') {
                yy = (Number(this.reOpenPeriod.swsyy) - 1).toString();
                mm = '12';
            } else {
                yy = this.reOpenPeriod.swsyy;
                mm = (Number(this.reOpenPeriod.swsmm) - 1).toString();
            }
            this.processSave('ASI_CRM_Daily_Offtake_From_Year_SWS__c', 'ASI_CRM_Daily_Offtake_From_Month_SWS__c', yy, mm,
            '' ,'' , '','' ,'ASI_CRM_Re_Open_SWS__c',true );
        }
/*
        if (fieldname == 'OpenPeriodsws') {
            this.processSave('ASI_CRM_Daily_Offtake_From_Year_SWS__c', 'ASI_CRM_Daily_Offtake_From_Month_SWS__c', this.OpenPeriod.swsyy, this.OpenPeriod.swsmm,
            'ASI_CRM_Offtake_From_Year_SWS_Previous__c' ,this.OpenPeriod.swsyy , 'ASI_CRM_Offtake_From_Month_SWS_Previous__c',this.OpenPeriod.swsmm );
        }
        if (fieldname == 'reOpenPeriodsws') {
            var mm, yy;
            if (this.reOpenPeriod.swsmm == '1') {
                yy = (Number(this.reOpenPeriod.swsyy) - 1).toString();
                mm = '12';
            } else {
                yy = this.reOpenPeriod.swsyy;
                mm = (Number(this.reOpenPeriod.swsmm) - 1).toString();
            }
            this.processSave('ASI_CRM_Daily_Offtake_From_Year_SWS__c', 'ASI_CRM_Daily_Offtake_From_Month_SWS__c', yy, mm,
            'ASI_CRM_Offtake_From_Year_SWS_Previous__c' ,this.confirmedPeriod.swsyy , 'ASI_CRM_Offtake_From_Month_SWS_Previous__c',this.confirmedPeriod.swsmm);
        }
        */
    }


    processSave(yyAPI, mmAPI, yy, mm, previousYYAPI, previousMMAPI, YYnum, MMnum, ReOpenAPI, reOpenFlag) {
        var upsertRecord = {
            Id: this.recordId,
            sobjectType: 'ASI_CRM_TW_Settings__c'
        };
        upsertRecord[yyAPI] = yy;
        upsertRecord[mmAPI] = mm;
        upsertRecord[ReOpenAPI] = reOpenFlag;

        if(previousYYAPI!=''){
            upsertRecord[previousYYAPI] = YYnum;
            upsertRecord[previousMMAPI] = MMnum;
        }

        console.log('** upsertRecord **');
        console.log(upsertRecord);
        var upsertList = [];
        upsertList.push(upsertRecord);

        upsertsObjList({ sObjList: upsertList })
            .then(result => {
                if (result === 'Success') {
                    console.log('Success');
                    this.initialize();
                    this.showToastMessage("Success!", "Records are saved!", "success", "sticky");
                    
                } else {
                    this.showToastMessage("Failed!", result, "error", "sticky");
                    console.log(result);
                }
                this.showSpinner = false;
            })
            .catch(error => {
                console.log(' ** error ** ');
                console.log(error);
                this.showToastMessage("Failed!", error, "error", "sticky");
                this.showSpinner = false;
            });
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