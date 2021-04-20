import { LightningElement, track, api, wire } from 'lwc';
//Import Apex Class Function
import fetchsObjectData from '@salesforce/apex/ASI_CRM_Function.fetchsObjectData';
//import GetfieldTypeList from '@salesforce/apex/ASI_CRM_Function.GetfieldTypeList';
import upsertRecordListApex from '@salesforce/apex/ASI_CRM_Function.upsertObjectData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import publishSelectTB2Main from '@salesforce/messageChannel/ASI_MFM_Manage_All_SelectTB2Main__c';
import publishMainTBDelete from '@salesforce/messageChannel/ASI_MFM_Manage_All_MainTBDelete__c';
import { publish, subscribe, MessageContext } from 'lightning/messageService'

import { ASI_MFM_MY_PaymentLine_BeforeUpsert, ASI_MY_POLine_BeforeUpsert } from './asi_mfm_my_trigger';
import { LookupToPicklistQuery, ASI_SG_AssignfieldConfig } from './asi_mfm_sg_helper';




export default class Asi_mfm_manage_all_compt extends NavigationMixin(LightningElement) {

    @api recordId;

    @api objectRelationString; //Object Relationship
    @api displaySettingString; //display Setting
    @api functionSettingString; // function Setting
    @api applicationDeveloperName; // unqiue key for this compt
    @api fieldConfigString; // field Config List
    @api selectTB2MainTBMapStr; // select table to main table mapping field List

    @track functionSetting;
    @track objectRelation;
    @track displaySetting;
    @track fieldConfigList;
    @track NewLineMapping;
    @track recordList = [];  // list of sobject
    @track DeleteList = []; // list of string
    @track showSpinner = false;
    @track displayIcon = 'standard:logging';

    @track fieldUpdateCallback = this.onFieldUpdateCallback.bind(this);
    @track NewLineCount = 0;
    @track preReservedData = {};

    connectedCallback() {
        console.log('log 2021-02-03');
        this.initialize();
        this.handleSubscribe();
    }
    renderedCallback() {

    }

    //*****************************subscribe start ******************* */
    subscription = null;

    @wire(MessageContext)
    messageContext;
    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, publishSelectTB2Main, (message) => {
            console.log('main Subscribe');

            this.AddSelectedLinetodisplayList(message);
        });
    }
    //*****************************subscribe end ******************* */



    initialize() {
        this.showSpinner = true;
        this.objectRelation = JSON.parse(this.objectRelationString);
        if (this.selectTB2MainTBMapStr) {
            this.NewLineMapping = JSON.parse(this.selectTB2MainTBMapStr);
        }

        this.functionSetting = JSON.parse(this.functionSettingString);
        this.displaySetting = JSON.parse(this.displaySettingString);

        if (this.displaySetting.iconName && this.displaySetting.iconName != null) {
            this.displayIcon = this.displaySetting.iconName.replaceAll("*", ":");
        }
        if (this.displaySetting.tableStyle && this.displaySetting.tableStyle != null) {
            this.displaySetting.tableStyle = this.displaySetting.tableStyle.replaceAll("*", ":");
        } else {
            this.displaySetting.tableStyle = '';
        }

        var LookupQueryList = []; // based on this query list to get all lookup values

        //prepare configuration file
        //convert list of object in string format to list of object
        var newJson = this.fieldConfigString.replace(/([a-zA-Z0-9]+?):/g, '"$1":');
        newJson = newJson.replace(/'/g, '"');
        var fieldConfigArray = JSON.parse(newJson); //this.fieldConfigList = fieldConfigArray;


        //generate SQL string
        var sqlfields = [];
        fieldConfigArray.forEach(function (fieldItem) {
            sqlfields.push(fieldItem.APIName);
            if (fieldItem.type == 'lookup' || fieldItem.type == "lookup-pickList") {
                var relationship = fieldItem.APIName.substring(0, fieldItem.APIName.length - 1) + 'r';
                sqlfields.push(relationship + '.' + fieldItem.displayAPIName);
            }
            if (fieldItem.style) {
                fieldItem.style = fieldItem.style.replaceAll("*", ":");
            } else {// td or th style
                fieldItem.style = ' ';
            }

            //this field need to convert from lookup field to picklist
            if (fieldItem.type == "lookup-pickList") {
                var addFilter = fieldItem.additionalFilter;//.replaceAll("&apos;", "'");
                if (addFilter.indexOf("&apos;")) {
                    addFilter = addFilter.replaceAll("&apos;", "'");
                }

                if (addFilter.indexOf("&#8217;")) {
                    addFilter = addFilter.replaceAll('&#8217;', "'");
                }
                if (addFilter.indexOf("#8217;")) {
                    addFilter = addFilter.replaceAll('#8217;', "'");
                }//addFilter = addFilter.replaceAll("&#8217;", "'");

                var querySQL = "select Id," + fieldItem.displayAPIName;
                querySQL += fieldItem.sublabelAPIName != '' ? ' ,' + fieldItem.sublabelAPIName : '';
                querySQL += " from " + fieldItem.sourceObject + ' where ' + addFilter;
                console.log('lookup-pickList : ' + querySQL);
                LookupQueryList.push({ APIName: fieldItem.APIName, querySQL: querySQL });
            }
        });


        // Query header
        if (this.objectRelation.QueryHeader) {

            var querySQL = "select Id";
            querySQL += this.objectRelation.HeaderSQLfields != '' ? ','+this.objectRelation.HeaderSQLfields : '';
            querySQL += " from " + this.objectRelation.parentObjectAPIName + " where id = '" + this.recordId + "' ";
            LookupQueryList.push({ APIName: 'Header', querySQL: querySQL });
        }

        var detailObjectAPIName = this.objectRelation.childObjectAPIName;
        var headerId = this.recordId;
        var headerAPI = this.objectRelation.parentObjectAPIName;

        //generate SQL for detail lines
        var sqlstr = "select Id," + sqlfields.join();
        sqlstr += " from " + detailObjectAPIName + "  where " + this.objectRelation.parentObjectAPIName + " = '" + this.recordId + "'    ";
        console.log('Main  SQL : ' + sqlstr);

        fetchsObjectData({
            soqlStatement: sqlstr
        }).then(data => {
            var resultList = [];
            data.forEach(function (line) {
                line['sobjectType'] = detailObjectAPIName;
                line[headerAPI] = headerId;
                resultList.push(line);
            });
            this.recordList = resultList;
            if (LookupQueryList.length > 0) {
                this.LookupQueryProcess(LookupQueryList, fieldConfigArray);
            } else {
                this.initloadingData(fieldConfigArray);
            }
            console.log(resultList.length + ' **   end of fetchsObjectData ** ');



            /* TODOList
            return GetfieldTypeList({ objType: detailObjectAPIName });
        }).then(data => {
            data.forEach(function (line) { });
            */

        }).catch(error => {
            console.log(' ** error initialize ** ');
            console.log(error);
            this.showSpinner = false;
            this.showToastMessage("Failed!", error, "error", "sticky");
        });
    }



    // query for lookup field
    LookupQueryProcess(LookupQueryList, fieldConfigArray) {
        var queryObj = LookupQueryList.pop();//
        console.log('LookupQueryProcess:' + queryObj.APIName + ':' + queryObj.querySQL);
        queryObj.querySQL = this.LookupQueryAffiliateLogic(queryObj.APIName, queryObj.querySQL);

        fetchsObjectData({
            soqlStatement: queryObj.querySQL
        }).then(data => {
            var isLookup2Picklist = false;
            var options = [];
            var displayAPIName;
            if (queryObj.APIName == 'Header') {
                //store header info
                this.preReservedData.header = data;

            } else {
                // convert lookup-pickList
                fieldConfigArray.forEach(function (fieldItem) {
                    if (fieldItem.APIName == queryObj.APIName && fieldItem.type === "lookup-pickList") {
                        isLookup2Picklist = true;
                        displayAPIName = fieldItem.displayAPIName;
                    }
                });

                if (isLookup2Picklist) {
                    data.forEach(function (line) { //console.log(line.Id  + line[displayAPIName]);
                        options.push({ label: line[displayAPIName], value: line.Id });
                    });
                }

                fieldConfigArray.forEach(function (fieldItem) {
                    if (fieldItem.APIName == queryObj.APIName && fieldItem.type === "lookup-pickList") {
                        fieldItem.values = options;
                    }
                });
            }


            if (LookupQueryList.length > 0) {
                this.LookupQueryProcess(LookupQueryList, fieldConfigArray);
            } else {
                this.initloadingData(fieldConfigArray);
            }
        }).catch(error => {
            console.log(' ** error ** ');
            console.log(error);
            this.showSpinner = false;
            this.showToastMessage("Failed!", error, "error", "sticky");
        });


    }

    onFieldUpdateCallback(recordId, field, value, recordLabel) {
        console.log('updated id :' + recordId + 'field : ' + field + 'field : ' + field);

        // check if this field is lookup field, lookup field need to assign field id and related lookup object
        var islookupfield = false;
        var lookupObj = {};
        this.fieldConfigList.forEach(function (fieldItem) {
            if (fieldItem.APIName && fieldItem.APIName === field && fieldItem.type === 'lookup') {
                islookupfield = true;
                lookupObj = { Id: value };
                lookupObj[fieldItem.displayAPIName] = recordLabel;
            }
        });

        // assign new value to the list
        this.recordList.forEach(function (line) {
            if (line.Id === recordId) {
                line[field] = value;
            }
            if (islookupfield) {
                line[field.substring(0, field.length - 1) + 'r'] = lookupObj;
            }
        });
    }


    // save process
    onClickSave(event) {//console.log('Start Save Process');
        var checkingResult = { passValidation: true, Msg: '' };
        this.showSpinner = true;
        //converting data
        var upsertList = this.preparingList();
        //Basic checking for upsertList
        checkingResult = this.basicChecking();

        //*********Affiliate logic  **********
        if (checkingResult.passValidation && this.applicationDeveloperName == 'ASI_MFM_PO_MY_ManageAll_Edit') {
            checkingResult = ASI_MY_POLine_BeforeUpsert(this.recordId, upsertList, this.preReservedData);
        } else if (checkingResult.passValidation && this.applicationDeveloperName === 'ASI_MFM_Paymentline_MY_ManageAll_Edit') {
            checkingResult = ASI_MFM_MY_PaymentLine_BeforeUpsert(upsertList);
        }
        console.log('** SavingRecordsProcess **');
        console.log(upsertList);
        this.SavingRecordsProcess(checkingResult, upsertList);

    }

    SavingRecordsProcess(checkingResult, upsertList) {

        if (checkingResult.passValidation) {
            //pass validation
            upsertRecordListApex({ sObjList: upsertList, DeletedIdList: this.DeleteList, recordTypeId: this.objectRelation.childObjRecordTypeId })
                .then(result => {
                    if (result === 'Success') {
                        console.log('Success');
                        this.showToastMessage("Success!", "Records are saved!", "success", "dismissable");
                        this.redirect2RecordPage();
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
        } else {// have error
            this.showToastMessage("Failed!", checkingResult.Msg, "error", "sticky");
            this.showSpinner = false;
        }
    }

    preparingList() {//console.log('****** preparingList ! ****');
        var returnList = [];
        this.recordList.forEach(function (line) {
            var record = {};
            for (var property in line) {
                //console.log('save assign  - property : '+ property +' value : ' + line[property] );
                if (typeof line[property] !== 'object') {
                    record[property] = line[property];
                }
            }
            //remove Id for new records
            if (record.Id.length != 15 && record.Id.length != 18) {
                delete record.Id;
            }
            returnList.push(record);
        });
        return returnList;
    }


    basicChecking() {
        var checkingResult = { passValidation: true, Msg: '  ' };
        //var passValidation = true;
        //var errorMsg = ' ';

        var fieldsettingList = this.fieldConfigList;
        this.recordList.forEach(function (line) {
            fieldsettingList.forEach(function (fieldItem) {
                // check required field
                if (fieldItem.required && !line[fieldItem.APIName]) {
                    checkingResult.passValidation = false;
                    checkingResult.Msg += 'Please input ' + fieldItem.Label + '\n';

                }
            });
        });

        return checkingResult;
    }


    // handle Cancel Case - redirect to record Page
    onClickCancel(event) {
        console.log('cancel');
        this.redirect2RecordPage();
    }

    redirect2RecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objectRelation.parentObjectAPIName,
                actionName: 'view'
            }
        });
    }

    // handle clone case, copy record and then insert into List
    onClickClone(event) {
        var cloneid = event.target.dataset.cloneid;
        var NewRecord = {};
        this.recordList.forEach(function (lineitem) {
            if (lineitem.Id === cloneid) {
                // assign new value to new record
                for (var property in lineitem) {
                    NewRecord[property] = lineitem[property];
                }
            }
        });

        NewRecord.Id = this.NewLineCount.toString();
        this.NewLineCount++;
        this.recordList.push(NewRecord);
    }


    // handle delete case, 1) add in deleted List  2) then publish  the deleted Information 3) remove from display list
    onClickDelete(event) {
        var DeleteId = event.target.dataset.deleteid;
        console.log('Delete : ' + DeleteId + ' length : ' + DeleteId.length);

        //remove from list
        var selectedIndex = this.recordList.map(function (item) { return item.Id; }).indexOf(DeleteId);

        //add in DeleteList
        if (DeleteId.length === 15 || DeleteId.length === 18) {
            console.log('add in deleted List');
            this.DeleteList.push(DeleteId);
        }

        // publish to channel
        publish(this.messageContext, publishMainTBDelete, this.recordList[selectedIndex]);

        //remove from display list
        this.recordList.splice(selectedIndex, 1);
    }


    // create new line
    onClickNew(event) {
        console.log('Add NewRecord 1 ');
        var NewRecord = {
            Id: this.NewLineCount.toString(),
            sobjectType: this.objectRelation.childObjectAPIName
        };
        //, recordTypeId: this.objectRelation.childObjRecordTypeId
        NewRecord[this.objectRelation.parentAPINameInDetailObject] = this.recordId;
        this.recordList.push(NewRecord);
        this.NewLineCount++;
    }


    // add new line from selected table
    AddSelectedLinetodisplayList(selectedLine) {
        console.log('enter AddSelectedLinetodisplayList 2.0 ');
        console.log(selectedLine);
        var NewRecord = {
            Id: this.NewLineCount.toString(),
            sobjectType: this.objectRelation.childObjectAPIName
        };
        //,recordTypeId: this.objectRelation.childObjRecordTypeId
        var ObjMapping = this.NewLineMapping;
        for (var property in ObjMapping) {// console.log(property + ObjMapping[property] );

            //level 1 assignment
            if (typeof selectedLine[ObjMapping[property]] !== 'undefined') {
                NewRecord[property] = selectedLine[ObjMapping[property]];
            }

            //level 2 assignment
            if (property.includes(".")) {
                var tofieldList = property.split(".");
                var tofield = tofieldList[0];

                var fromfield;
                if (ObjMapping[property].includes(".")) {
                    var fromfieldList = ObjMapping[property].split(".");
                    fromfield = fromfieldList[0];
                    if (typeof selectedLine[fromfield] !== 'undefined') {
                        NewRecord[tofield] = selectedLine[fromfield];
                    }
                } else { // ObjMapping[property] is string , like Name
                    if (typeof selectedLine[fromfield] !== 'undefined') { // no sure if it works
                        var sobject = { [fromfield]: selectedLine[fromfield] };
                        NewRecord[tofield] = sobject;
                        //sobject[fromfield] = selectedLine[fromfield];
                    }
                    //NewRecord[tofield] =sobject;
                }
            }

        }

        NewRecord[this.objectRelation.parentAPINameInDetailObject] = this.recordId;


        //assign default value
        var headerObj = {};
        if(this.preReservedData.header){
            headerObj = this.preReservedData.header[0];
        }
        this.fieldConfigList.forEach(function (fieldItem) {
            console.log('**fieldItem**');
            console.log(fieldItem);
            if (fieldItem.default && !fieldItem.default.includes("$")) {
                var defaultAPI = fieldItem.default.replaceAll('.', ''); // from header
                console.log('defaultAPI : '+defaultAPI);
                console.log(headerObj.hasOwnProperty(defaultAPI));
                if (headerObj.hasOwnProperty(defaultAPI)) {
                    NewRecord[fieldItem.APIName] =  headerObj[defaultAPI];
                    if(fieldItem.type=='lookup'){
                        if(headerObj[defaultAPI.substring(0, defaultAPI.length - 1) + 'r'][fieldItem.displayAPIName]){
                            NewRecord[fieldItem.APIName.substring(0, fieldItem.APIName.length - 1) + 'r'] = {};
                            NewRecord[fieldItem.APIName.substring(0, fieldItem.APIName.length - 1) + 'r'][fieldItem.displayAPIName] = headerObj[defaultAPI.substring(0, defaultAPI.length - 1) + 'r'][fieldItem.displayAPIName];
                        }
                    }
                }

            }
        });

        console.log(NewRecord);

        this.recordList.push(NewRecord);
        this.NewLineCount++;
        //NewLineMapping
    }

    showToastMessage(title, message, type, mode) { // refer : https://developer.salesforce.com/docs/component-library/documentation/en/lwc/use_toast
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: type,
                mode: mode
            })
        );
    }

    //*********Affiliate logic*************************
    LookupQueryAffiliateLogic(APIName, querySQL) {
        console.log('** LookupQueryAffiliateLogic 1.0**');
        if (this.applicationDeveloperName === 'ASI_MFM_Plan_SG_ManageAll_Edit' || this.applicationDeveloperName === 'ASI_MFM_PO_SG_ManageAll_Edit' || this.applicationDeveloperName === 'ASI_MFM_PO_SG_ManageAll_EditFOC') {
            if (APIName == 'ASI_MFM_Customer_Name__c' || APIName == 'ASI_MFM_A_C_Code__c') {
                querySQL = LookupToPicklistQuery(APIName, querySQL, this.preReservedData);
            }

        }
        console.log(APIName + ' : ' + querySQL);
        return querySQL;
    }


    initloadingData(fieldConfigArray) {

        //Value Assignment
        this.fieldConfigList = fieldConfigArray;

        if (this.applicationDeveloperName == 'ASI_MFM_PO_MY_ManageAll_Edit') {
            //get plan id from PO header
            var planid = this.preReservedData.header[0].ASI_MFM_Plan__c;

            fetchsObjectData({
                soqlStatement: "select ASI_MFM_Currency__c,ASI_MFM_Plan_Amount__c , (select Id,ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c, ASI_MFM_GF_Total_PO_Amount_PR_Gulf__c,ASI_MFM_Status__c,ASI_MFM_Accrual_PO__c  from POs__r where ASI_MFM_Accrual_PO__c=false), RecordTypeID from ASI_MFM_Plan__c where id = '" + planid + "' "
            }).then(data => {
                this.preReservedData.plan = data;
                this.showSpinner = false
            }).catch(error => {
                console.log(' ** error ** ');
                console.log(error);
                this.showSpinner = false;
                this.showToastMessage("Failed!", error, "error", "sticky");
            });

        } else if (this.applicationDeveloperName === 'ASI_MFM_Paymentline_MY_ManageAll_Edit') {

            this.showSpinner = false;
        } else if (this.applicationDeveloperName === 'ASI_MFM_Plan_SG_ManageAll_Edit' || this.applicationDeveloperName === 'ASI_MFM_PO_SG_ManageAll_Edit' || this.applicationDeveloperName === 'ASI_MFM_PO_SG_ManageAll_EditFOC') {
            var preloadData = this.preReservedData;
            //console.log('**preloadData **');
            //console.log(preloadData);
            this.fieldConfigList.forEach(function (fieldItem) {
                fieldItem = ASI_SG_AssignfieldConfig(fieldItem, preloadData);
            });
            this.showSpinner = false;
        } else {
            this.showSpinner = false;
        }

    }

}