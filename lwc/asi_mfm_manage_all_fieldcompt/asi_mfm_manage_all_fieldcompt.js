import { LightningElement, track, api } from 'lwc';

export default class Asi_mfm_manage_all_fieldcompt extends LightningElement {
    // API
    @api record = {};
    @api fieldconfig = {};
    @api displaySetting;
    @api fieldUpdateCallback;



    @track fieldValue = '';
    @track onSelectedRecordCallback = this.onSelectedRecord.bind(this);
    //lookup
    @track selectedName = ''; //Lookup field display name


    renderedCallback() {//console.log(typeof this.record );
        //assign to default value
        if (this.Initialized) {
            return;
        }
        this.Initialized = true;


        if (typeof this.record == 'object' && this.record.hasOwnProperty(this.fieldconfig.APIName)) {
            this.fieldValue = this.record[this.fieldconfig.APIName];
        } else if (typeof this.record === 'string') {
            this.fieldValue = this.record;
            this.selectedName = this.record;
        }

        // read only number field
        if(this.fieldconfig.type  ==='Number' && ! this.fieldconfig.editable){
            this.fieldValue = Number(this.fieldValue);
            if(this.fieldconfig.toFixed){
                this.fieldValue =  this.fieldValue.toFixed(this.fieldconfig.toFixed);
            }else{
                this.fieldValue =  this.fieldValue.toFixed(2);
            }
        }

        //lookup field assign to default value
        if (this.fieldconfig.type === "lookup" ) {

            var apikey = this.fieldconfig.APIName.substring(0, this.fieldconfig.APIName.length - 1) + 'r.' + this.fieldconfig.displayAPIName;

            if(this.fieldconfig.APIName.toLowerCase() =='ownerid'){
                this.selectedName = this.record['Owner.Name'];
            }else if (typeof this.record == 'object' && this.record.hasOwnProperty(this.fieldconfig.APIName.substring(0, this.fieldconfig.APIName.length - 1) + 'r')) {
                this.selectedName = this.record[this.fieldconfig.APIName.substring(0, this.fieldconfig.APIName.length - 1) + 'r'][this.fieldconfig.displayAPIName];
            } else if (typeof this.record == 'object' && this.record.hasOwnProperty(apikey)) {
                this.selectedName = this.record[apikey];
            }
        }



        if (this.fieldconfig.type === "lookup-pickList") {
            console.log('enter lookup-pickList 1');
            var apikey = this.fieldconfig.APIName.substring(0, this.fieldconfig.APIName.length - 1) + 'r.' + this.fieldconfig.displayAPIName;
            console.log('apikey :'+apikey);
            if (this.record.hasOwnProperty(this.fieldconfig.APIName.substring(0, this.fieldconfig.APIName.length - 1) + 'r') ) {
                console.log('found ' + this.record[this.fieldconfig.APIName.substring(0, this.fieldconfig.APIName.length - 1) + 'r'][this.fieldconfig.displayAPIName]);
                this.fieldValue =  this.record[this.fieldconfig.APIName.substring(0, this.fieldconfig.APIName.length - 1) + 'r'][this.fieldconfig.displayAPIName];
            }

        }

        if (this.fieldconfig.type === "checkbox") {
            if (typeof this.fieldValue !== 'boolean' && typeof this.fieldconfig.default === 'boolean') { // no value, then assign to default value
                this.fieldValue = this.fieldconfig.default;
            }
        }


    }



    // return pick list value for select option field
    get picklistOptions() {

        if (this.fieldconfig.type === "picklist" || this.fieldconfig.type === "lookup-pickList"   ) {// console.log( 'picklist  Type of now : ' + typeof this.fieldconfig.values);
            var options = [];
            if(this.fieldconfig.values && typeof this.fieldconfig.values === 'string' && this.fieldconfig.values.includes(",")){
                var optionsList = this.fieldconfig.values.split(",");

                optionsList.forEach(function (line) {
                    options.push({ label: line, value: line });
                });
            }else if(this.fieldconfig.values && typeof this.fieldconfig.values === 'string' && this.fieldconfig.values.includes(";")){
                var optionsList = this.fieldconfig.values.split(";");

                optionsList.forEach(function (line) {
                    options.push({ label: line, value: line });
                });
            }else if (this.fieldconfig.values && Array.isArray(this.fieldconfig.values)) {
                this.fieldconfig.values.forEach(function (line) {  //console.log( line.label + line.value );
                    options.push({ label: line.label, value: line.value });
                })
                //options = this.fieldconfig.values;
            }


            return options;
        } else {
            return [];
        }
    }


    get InputCSSClass() {
        var inputClass = '';
        if (this.fieldconfig.required) {
            inputClass += ' bPageBlock ';
        }
        return inputClass;
    }




    //Lookup-picklist Editable
    get isLookupPicklistEditable() {
        return this.fieldconfig.type === "lookup-pickList" & this.fieldconfig.editable;
    }




    //Checkbox Editable
    get isCheckboxEditable() {
        return this.fieldconfig.type === "checkbox" && this.fieldconfig.editable;
    }
    //Checkbox read only
    get isCheckboxRO() {
        return this.fieldconfig.type === "checkbox" && !this.fieldconfig.editable;
    }


    //picklist Editable
    get isPicklistEditable() {
        return this.fieldconfig.type === "picklist" && this.fieldconfig.editable;
    }

    //Standard Field Editable
    get isStandardFieldType() {
        return this.fieldconfig.type !== "lookup-pickList" && this.fieldconfig.type !== "Number" && this.fieldconfig.type !== "picklist" && this.fieldconfig.type !== "checkbox" && this.fieldconfig.type !== "lookup" && this.fieldconfig.editable;
    }

    get isNumberFieldType() {
        return this.fieldconfig.type === "Number" && this.fieldconfig.editable;
    }

    //Standard Field Read Only
    get isStandardFieldTypeRO() {
        return this.fieldconfig.type !== "lookup-pickList" && this.fieldconfig.type !== "lookup" && this.fieldconfig.type !== "checkbox" && !this.fieldconfig.editable;
    }

    //check if this field is lookup field Read Only
    get isLookupFieldRO() {
        return this.fieldconfig.type === "lookup" & !this.fieldconfig.editable;
    }

    //Get Lookup field URL for displaying
    get lookupRecordUrl() {
        if (this.fieldconfig.type === "lookup") {
            return "/lightning/r/" + this.fieldconfig.sourceObject + "/" + this.record[this.fieldconfig.APIName] + "/view";
        }
        return null;
    }


    //lookup field Editable
    get isLookupFieldType() {
        return this.fieldconfig.type === "lookup" & this.fieldconfig.editable;
    }

    // picklist, input , checkbox field field changes
    onFieldUpdate(event) {
        var newValue, updatedId;
        if (event.target.type == 'checkbox') {
            newValue = event.target.checked;
        } else {
            newValue = event.target.value;
        }
        console.log('newValue : ' + newValue);
        if (this.record.Id) {
            updatedId = this.record.Id;
        } else if (this.fieldconfig.Id) {
            updatedId = this.fieldconfig.Id;
        }

        this.fieldUpdateCallback(updatedId, this.fieldconfig.APIName, newValue, '');
    }

    //lookup field select - on record changed
    onSelectedRecord(recordId, recordLabel) {
        console.log('onSelectedRecord!!! ' + recordId + ' label ' + recordLabel);
        var updatedId;
        if (this.record.Id) {
            updatedId = this.record.Id;
        } else if (this.fieldconfig.Id) {
            updatedId = this.fieldconfig.Id;

        }
        this.fieldUpdateCallback(updatedId, this.fieldconfig.APIName, recordId, recordLabel);
    }

}