import { LightningElement, api, track } from 'lwc';
import fetchsObjectData from '@salesforce/apex/ASI_CRM_Function.fetchsObjectData';


export default class Asi_mfm_manage_all_lookup extends LightningElement {

    @api selectedRecordValue = '';
    @api selectedRecordId = '';
    @api fieldconfig = {};


    @api selectedRecordCallback;

    @track searchKey = "";
    @track errorMessage = "";
    @track lookupRecordList = [];
    @track showSpinner = false;
    //@track iconName = 'standard:account';
    hasRendered = false;

    //init
    connectedCallback() {

    }
    renderedCallback() {
        if (this.hasRendered) return;
        this.hasRendered = true;
    }

    get isSelectedRecord() {
        return this.selectedRecordValue !== '' && this.selectedRecordId !== '';
    }

    get iconName() {
        var icon = this.fieldconfig.iconName;
        if(icon && icon.includes("*")){
            icon= icon.replaceAll("*", ":");
        }
        return icon;
    }

    get hasError() {
        return this.errorMessage;
    }

    get pillContainerClass() {
        return 'slds-pill-container ' + (this.isSelectedRecord ? '' : 'slds-hide');
    }

    get searchInputFieldClass() {
        return this.isSelectedRecord ? 'slds-hide' : 'slds-show';
    }

    // handle remove value case in input field
    removeSelectedRecordHandler() {
        this.selectedRecordValue = "";
        this.selectedRecordId = "";
        this.searchKey = "";
    }

    // search function
    searchRecord(event) {
        var cmp = this.template.querySelector('[data-id="lookupPanel"]');

        this.searchKey = event.target.value;
        if (this.searchKey && this.searchKey.length > 1) {
            cmp.classList.add('slds-is-open');
            cmp.classList.remove('slds-is-close');
            this.getLookupRecord(this.searchKey);
        } else {
            cmp.classList.add('slds-is-close');
            cmp.classList.remove('slds-is-open');
        }
    }

    // Query Lookup record by key
    getLookupRecord(Keyword) {
        var labelAPIName = this.fieldconfig.displayAPIName;
        var sublabelAPIName = '';

        var sqlfilterlist = this.fieldconfig.filterFieldList.split(",");
        var whereSqlList = [];
        sqlfilterlist.forEach(function (line) {
            whereSqlList.push(line + " like '%" + Keyword + "%' "); // \'
        });
        var querySQL = "select Id," + this.fieldconfig.displayAPIName;
        if (this.fieldconfig.sublabelAPIName != '') {
            querySQL += ' , ' + this.fieldconfig.sublabelAPIName;
            sublabelAPIName = this.fieldconfig.sublabelAPIName;
        }
        querySQL += " from " + this.fieldconfig.sourceObject + ' where ( ' + whereSqlList.join(' or ') + ' ) ';

        if (this.fieldconfig.additionalFilter != '') {
            // this is to replace &apos;--->'
            var addFilter = this.fieldconfig.additionalFilter;

            if (addFilter.indexOf("&apos;")) {
                addFilter = addFilter.replaceAll("&apos;", "'");
            }
            if (addFilter.indexOf("&#8217;")) {
                addFilter = addFilter.replaceAll('&#8217;', "'");
            }
            if (addFilter.indexOf("#8217;")) {
                addFilter = addFilter.replaceAll('#8217;', "'");
            }
            querySQL += ' and ' + addFilter;
        }
        querySQL += ' limit ' + this.fieldconfig.QueryLimit;
        console.log('lookup sql : ' + querySQL);


        this.showSpinner = true;
        this.errorMessage = "";
        this.lookupRecordList = [];

        // Query Data
        fetchsObjectData({
            soqlStatement: querySQL
        }).then(data => {
            var resultList = [];
            data.forEach(function (line) {
                var displayrecord = {
                    Id: line['Id'],
                    value: line['Id'],
                    label: line[labelAPIName]
                };
                if (sublabelAPIName != '') {
                    displayrecord.sublabel = line[sublabelAPIName];
                }
                resultList.push(displayrecord);
            });
            this.lookupRecordList = resultList;
            this.showSpinner = false;

            if (!this.lookupRecordList || this.lookupRecordList.length === 0) {
                this.errorMessage = "No Records Found for '" + this.searchKey + "'";
            }
        }).catch(error => {
            // this.errorMessage = error.body.message;
            this.showSpinner = false;
            console.log(' ** error ** ');
            console.log(error);
        });
    }


    get InputCSSClass() {
        var inputClass = '';
        if (this.fieldconfig.required) {
            inputClass += ' bPageBlock ';
        }
        return inputClass;
    }


    // selct record and update parent compt
    selectRecord(event) {

        var cmp = this.template.querySelector('[data-id="lookupPanel"]');
        var lookupRecordId = event.currentTarget.dataset.id;
        var index = this.lookupRecordList.findIndex(record => record.Id === lookupRecordId);
        if (index === -1)
            return;

        //set lookup label & lookup id
        this.selectedRecordId = this.lookupRecordList[index].Id;
        this.selectedRecordValue = this.lookupRecordList[index].label;

        console.log('lookupRecordId : ' + this.selectedRecordId + ' selectedRecordValue ' + this.selectedRecordValue);
        this.selectedRecordCallback(this.selectedRecordId, this.selectedRecordValue);

        //setup css
        cmp.classList.add('slds-is-close');
        cmp.classList.remove('slds-is-open');

    }



}