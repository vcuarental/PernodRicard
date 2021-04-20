import { LightningElement, api, wire, track } from 'lwc';

import fetchsObjectData from '@salesforce/apex/ASI_CRM_Function.fetchsObjectData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

import NAME_FIELD from '@salesforce/schema/User.Name';
//publish search result
import publish2SearchResults from '@salesforce/messageChannel/ASI_MFM_Manage_All_SearchResults__c';

// select line
import publishSelectTB2Main from '@salesforce/messageChannel/ASI_MFM_Manage_All_SelectTB2Main__c';

import publishMainTBDelete from '@salesforce/messageChannel/ASI_MFM_Manage_All_MainTBDelete__c';



import { publish, subscribe, MessageContext } from 'lightning/messageService'

import { storedSelectedID, ASI_MFM_MY_polinesearch } from './asi_mfm_my_helper';


export default class Asi_mfm_manage_all_searchpanel extends LightningElement {

    @api recordId;
    @api applicationDeveloperName;
    @api configurationstr;
    @api searchListstr;
    @api displaySettingString;

    @track configuration;
    @track displaySetting;
    @track searchConfigList;
    @track currenctRecord = {};
    @track displayIcon = 'standard:logging';
    @track fieldUpdateCallback = this.onFieldUpdateCallback.bind(this);
    @track showSpinner = false;
    // for other Affiliate used
    @track preReservedData;
    @track excludedList = [];



    @wire(MessageContext)
    messageContext;

    fieldConfigList = []

    //get user name 
    @track username;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.username = data.fields.Name.value;
        }
    }




    connectedCallback() {
        console.log(' v1.0 ');
        this.initialize();
        this.handleSubscribe();
    }
    renderedCallback() {

    }

    initialize() {
        this.showSpinner = true;
        this.configuration = JSON.parse(this.configurationstr);
        this.displaySetting = JSON.parse(this.displaySettingString);
        if (this.displaySetting.iconName && this.displaySetting.iconName != null) {
            this.displayIcon = this.displaySetting.iconName.replaceAll("*", ":");
        }

        var newJson = this.searchListstr.replace(/([a-zA-Z0-9]+?):/g, '"$1":');
        newJson = newJson.replace(/'/g, '"');
        this.fieldConfigList = JSON.parse(newJson);

        var sqlfields = [];

        this.fieldConfigList.forEach(function (fieldItem) {
            if (fieldItem.default && !fieldItem.default.includes("$")) {
                sqlfields.push(fieldItem.default);
            }
            fieldItem.record = '';
        });

        if (sqlfields.length > 0) {
            this.QuerycurrenctRecord(sqlfields.join());
        } else {
            this.assignDefaultValue();
        }

    }

    QuerycurrenctRecord(soqlFields) {
        console.log("SQL: select Id," + soqlFields + " from " + this.configuration.currentObject + "  where Id = '" + this.recordId + "'    ");
        fetchsObjectData({
            soqlStatement: "select Id," + soqlFields + " from " + this.configuration.currentObject + "  where Id = '" + this.recordId + "'    "
        }).then(data => {//console.log('QuerycurrenctRecord' + data[0].Id);
            this.currenctRecord = data[0];
            this.assignDefaultValue();
        }).catch(error => {
            console.log(' ** error ** ');
            console.log(error);
            this.showSpinner = false;
            this.showToastMessage("Failed!", error, "error", "sticky");
        });
    }


    assignDefaultValue() {
        console.log('*** assignDefaultValue ***');
        //convert current record to JS Object
        var currenctData = this.currenctRecord;
        var currenctSobject = {};
        for (var property in currenctData) {
            if (typeof currenctData[property] == 'object') {
                //level 2
                for (var key in currenctData[property]) {
                    if (typeof currenctData[property][key] == 'object') {
                        //level 3
                        for (var pkey in currenctData[property][key]) {
                            if (typeof currenctData[property][key][pkey] != 'object') {//assign value
                                currenctSobject[property + key + pkey] = currenctData[property][key][pkey];
                            }
                        }
                    } else {//assign value
                        currenctSobject[property + key] = currenctData[property][key];
                    }
                }
            } else {//assign value
                currenctSobject[property] = currenctData[property];
            }
        }

        var currentUserName = this.username;
        var fieldConfigs = [];
        var num = 0;// assign ID to list
        var globalClassName = this.displaySetting.GridColClass;
        this.fieldConfigList.forEach(function (fieldItem) {
            fieldItem.APIkey = fieldItem.APIName.replaceAll('.', '');
            fieldItem.Id = num.toString(); //Convert a number to a string:
            num++;
            if (fieldItem.default && !fieldItem.default.includes("$")) { //console.log(' **** ' + fieldItem.default);
                var defaultAPI = fieldItem.default.replaceAll('.', '');
                if (currenctSobject.hasOwnProperty(defaultAPI)) { //console.log(currenctData[fieldItem.default]);
                    fieldItem.record = currenctSobject[defaultAPI];
                    fieldItem.searchvalue = currenctSobject[defaultAPI];
                }
            } else if (fieldItem.default && fieldItem.default.includes("$currentUser.Name")) { // user case
                fieldItem.record = currentUserName;
                fieldItem.searchvalue = currentUserName;
            }
            fieldItem.className = globalClassName;
            //check if this field is read only 
            if (!fieldItem.editable) { //read oly
                fieldItem.className += ' readonlyMode ';
            }
            fieldConfigs.push(fieldItem);
        });

        this.searchConfigList = fieldConfigs;
        this.showSpinner = false;
        
        // init run search function
        if (this.configuration.initRunSearch) {
            this.onClickSearch();
        }
    }

    onFieldUpdateCallback(recordId, field, value) {
        console.log('1.0updated id :' + recordId + 'field : ' + field + 'value : ' + value);
        var selectedIndex = this.searchConfigList.map(function (item) { return item.Id; }).indexOf(recordId);
        console.log(selectedIndex);
        this.searchConfigList[selectedIndex].searchvalue = value;
    }

    onClickSearch() {
        this.showSpinner = true;
        console.log('enter onClickSearch ****');
        var sqlstr = 'select id,' + this.configuration.searchfields;
        //generate SQL
        var filterList = [];
        this.searchConfigList.forEach(function (line) {
            if (line.searchvalue) {
                console.log(' ' + line.APIName + line.operator + line.searchvalue);
                var whereStatm = ' ';
                if (line.operator == '=' || line.operator == '!=') {
                    whereStatm += line.APIName + " " + line.operator + " '" + line.searchvalue + "' ";
                } else if (line.operator == 'like') {
                    whereStatm += line.APIName + " " + line.operator + " '%" + line.searchvalue + "%' ";
                }
                filterList.push(whereStatm);
            }
        });
        var addFilter = this.configuration.searchAddFilter;
        if (addFilter.indexOf("&apos;")) {
            addFilter = addFilter.replaceAll("&apos;", "'");
        }
        if (addFilter.indexOf("&#8217;")) {
            addFilter = addFilter.replaceAll('&#8217;', "'");
        }
        if (addFilter.indexOf("#8217;")) {
            addFilter = addFilter.replaceAll('#8217;', "'");
        }

        sqlstr += ' from ' + this.configuration.searchObject + ' where ' + filterList.join(" and ") +addFilter;// this.configuration.searchAddFilter.replaceAll("&apos;", "'");


        if (this.excludedList.length > 0) {
            sqlstr += ' and id not in (' + this.excludedList.join(',') + ')';
        }


        console.log('search panel SQL : ' + sqlstr);
        this.searchProcess(sqlstr);
    }


    searchProcess(sqlstr) {
        //search in DB
        fetchsObjectData({
            soqlStatement: sqlstr
        }).then(data => { 
            this.publish2selectResultsTB(data);
            this.afterSearch(data);
            this.showSpinner = false;
        }).catch(error => {
            console.log(' ** error ** ');
            console.log(error);
            this.showSpinner = false;
            this.showToastMessage("Failed!", error, "error", "sticky");
        });
    }

    //*********Affiliate logic after search*************************

    afterSearch(resultList) {
        //if (this.applicationDeveloperName === 'ASI_MFM_MY_POline_SearchPanel_In_PaymentPage') {
        // }
    }



    //*****************************subscribe the select list  ******************* */
    subscription = null;
    handleSubscribe() {
        if (this.subscription) {
            return;
        }

        // subscribe adding line from select table
        this.subscription = subscribe(this.messageContext, publishSelectTB2Main, (message) => {
            console.log('enter Subscribe publishSelectTB2Main in search pannel' + message.Id);
            if (message.Id) {
                this.excludedList.push("'" + message.Id + "'");
            }
        });

        // subscribe delete line from main table
        var searchIdAPIName = this.configuration.searchIDfield; // the field in main object which is lookup field (id) in search object
        this.subscription = subscribe(this.messageContext, publishMainTBDelete, (message) => {
            console.log('enter Subscribe publishMainTBDelete in search pannel' + message[searchIdAPIName]);

            //remove from excludedList for this id
            var removedId = "'" + message[searchIdAPIName]+ "'" ;
            if (this.excludedList && this.excludedList.length > 0 && this.excludedList.includes(removedId)) {
                this.excludedList = this.excludedList.filter(item => item !== removedId)
            } 
        });
        //publishMainTBDelete
    }


    //publish to select Results table 
    publish2selectResultsTB(message) {
        publish(this.messageContext, publish2SearchResults, message);
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