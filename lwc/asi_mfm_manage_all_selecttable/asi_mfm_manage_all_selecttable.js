import { LightningElement, wire, api, track } from 'lwc';
import publish2SearchResults from '@salesforce/messageChannel/ASI_MFM_Manage_All_SearchResults__c';
import publishSelectTB2Main from '@salesforce/messageChannel/ASI_MFM_Manage_All_SelectTB2Main__c';
import publishMainTBDelete from '@salesforce/messageChannel/ASI_MFM_Manage_All_MainTBDelete__c';

import { subscribe, publish, MessageContext } from 'lightning/messageService';

export default class Asi_mfm_manage_all_selecttable extends LightningElement {

    @api applicationDeveloperName;
    @api objectRelationString;
    @api displaySettingString;
    @api functionSettingString;
    @api fieldConfigString;
    
    @track fieldUpdateCallback = this.onFieldUpdateCallback.bind(this);

    @track objectRelation;
    @track functionSetting;
    @track displaySetting;
    @track fieldConfigList
    @track recordList = [];  // list of sobject
    @track displayIcon = 'standard:logging';
    @track showSpinner = false;


    connectedCallback() {
 
        this.handleSubscribe();
        this.initialize();
    }

    renderedCallback() {
        
    }


    initialize() {

        this.objectRelation = JSON.parse(this.objectRelationString);
        this.functionSetting = JSON.parse(this.functionSettingString);
        this.displaySetting = JSON.parse(this.displaySettingString);

        var newJson = this.fieldConfigString.replace(/([a-zA-Z0-9]+?):/g, '"$1":');
        newJson = newJson.replace(/'/g, '"');
        var fieldConfigArray = JSON.parse(newJson);
        this.fieldConfigList = fieldConfigArray;

        if (this.displaySetting.iconName && this.displaySetting.iconName != null) {
            this.displayIcon = this.displaySetting.iconName.replaceAll("*", ":");
        }

    }

    // if result list is 0, then hide whole part
    get notEmptyResultList() {
        return this.recordList.length>0 && this.displaySetting.dynamicHidden;
    }


    //select new line to main display table
    onClickAdd(event) {
        var AddId = event.target.dataset.addid;
        console.log('AddId : ' + AddId);
        var selectedIndex = this.recordList.map(function (item) { return item.Id; }).indexOf(AddId);
        var NewRecord = this.recordList[selectedIndex];
        //let message = { messageText: 'This is a test from LMC 3 : ' + this.num.toString() };
        publish(this.messageContext, publishSelectTB2Main, NewRecord);


        this.recordList.splice(selectedIndex, 1);
    }



    onFieldUpdateCallback(recordId, field, value) {
        console.log('updated id :' + recordId + 'field : ' + field + 'field : ' + field);
        this.recordList.forEach(function (line) {
            if (line.Id === recordId) {
                line[field] = value;
            }
        });
    }


    //****************subscription ********************
    subscription = null;
    
    @wire(MessageContext)
    messageContext;

    handleSubscribe() {
        console.log('enter Subscribe');
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, publish2SearchResults, (message) => {
            console.log('enter publish2SearchResults Subscribe  ');
            var resultList = [];

            message.forEach(function (line) {
                console.log(line.Id);
                resultList.push(line);
            });
            this.recordList = resultList;
        });

        // handle deletion from main table
        this.subscription = subscribe(this.messageContext, publishMainTBDelete, (message) => {
            //console.log('enter publishMainTBDelete Subscribe  ');
            //console.log(message);

        });
        //publishMainTBDelete

    }



}