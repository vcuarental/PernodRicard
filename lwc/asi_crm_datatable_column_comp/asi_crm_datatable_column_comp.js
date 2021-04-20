import { LightningElement, api, track } from 'lwc';

export default class ASI_CRM_DataTable_Column_Comp extends LightningElement {

    @api mode   = "VIEW";
    @api field  = {
        'id'                    : '',
        'title'                 : '',
        'type'                  : '',
        'editable'              : false,
        'lookupFieldId'         : '',
        'lookupFieldLabelField' : '',
        'objectName'            : '',
        'picklist'              : [],
        'configObj'             : {}
    };
    @api record = {};

    @api fieldUpdateCallback;

    @track onSelectedRecordCallback = this.onSelectedRecord.bind(this);

    hasRendered = false;

    renderedCallback() {
        if(this.field.type === 'date' || this.field.type === 'datetime') {
            if(this.template.querySelector('lightning-input')) {
                if(this.hasRendered) return;
                this.hasRendered = true;
                const style = document.createElement('style');
                style.innerText = `
                    lightning-calendar .slds-dropdown {
                        max-width : fit-content
                    }
                `;
                this.template.querySelector('lightning-input').appendChild(style);
            }
        }
    }

    get isEditable() {
        return this.mode === "EDIT" && this.field.editable === true;
    }

    get isViewOnly() {
        return this.mode === "VIEW" || this.field.editable === false;
    }

    get isPicklistFieldType() {
        return this.field.type === "picklist";
    }

    get isLookupFieldType() {
        return this.field.type === "lookup";
    }

    get isStandardFieldType() {
        return this.field.type !== "picklist" && this.field.type !== "lookup";
    }

    get isStandardDisplayFieldType() {
        return this.field.type !== "lookup" && this.field.type !== "id";
    }

    get lookupRecordUrl() {
        if(this.field.type === "lookup")
            return "/lightning/r/" + this.field.configObj.objectName + "/" + this.record[this.field.id] + "/view";
        else if(this.field.type === "id")
            return "/lightning/r/" + this.field.configObj.objectName + "/" + this.record.Id + "/view";

        return null;
    }

    get fieldValue() {
        if(this.isLookupFieldType)
            return this.record[this.field.lookupFieldId][this.field.lookupFieldLabelField];
        
        if(this.field.id.includes('.')) {
            let fieldList = this.field.id.split('.');
            
            let obj = this.record;
            fieldList.forEach(field => {
                obj = obj[field];
            })

            return obj;
        }

        return this.record[this.field.id];
    }

    get lookupFieldValue() {
        var obj = {};

        if(this.record[this.field.id]) {
            obj.label = this.record[this.field.lookupFieldId][this.field.lookupFieldLabelField];
            obj.value = this.record[this.field.id];
        }
        
        return obj;
    }

    onSelectedRecord(record) {
        this.fieldUpdateCallback(this.record.id, this.field, record);
    }

    onFieldUpdate(event) {
        var newValue = event.target.value;
        this.fieldUpdateCallback(this.record.id, this.field, newValue);
    }
}