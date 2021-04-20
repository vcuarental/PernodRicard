import { LightningElement, wire, track, api } from 'lwc';
import fetchsObjectData from '@salesforce/apex/ASI_CRM_Function.fetchsObjectData';

export default class Asi_crm_map_compt extends LightningElement {
    //from Lightning Record Page
    @api recordId;
    @api objectApiName;
    record;

    //from Lightning App Builder Page
    @api SQLField; //eg:  id,ASI_CRM_JP_City_Ward__c,ASI_CRM_JP_Town__c,ASI_CRM_Street_Number__c
    @api TitleField;
    @api StreetField; //  format : API NAME;Hard Code String
    @api CityField;
    @api StateField;
    @api CountryField;
    @api zoomLevel;

    @track mapMarkers;

    connectedCallback() {
        console.log(' connectedCallback : record id', this.SQLField);
        this.initialize();
    }
    initialize() {
        fetchsObjectData({
            soqlStatement: "select " + this.SQLField + " from " + this.objectApiName + " where id = '" + this.recordId + "' "
        }).then(data => {
            this.record = data[0];
            console.log('*****record*****')
            console.log(this.record);
            this.GenMapMarkers();
        }).catch(error => {
            console.log(' ** error ** ');
            console.log(error);
        });
    }

    GenMapMarkers() {
        this.mapMarkers = [
            {
                location: {
                    Street: this.StreetField? this.GenLocationValue(this.StreetField):'',
                    City: this.CityField? this.GenLocationValue(this.CityField):'',
                    State: this.StateField? this.GenLocationValue(this.StateField):'',
                    Country: this.CountryField? this.GenLocationValue(this.CountryField):''
                },
                title: this.GenLocationValue(this.TitleField),
            },
        ];
        console.log('StreetField : ' + this.GenLocationValue(this.StreetField));
        console.log('CityField : ' + this.GenLocationValue(this.CityField));
        console.log('StateField : ' + this.GenLocationValue(this.StateField));
        console.log('CountryField : ' + this.GenLocationValue(this.CountryField));
    }

    GenLocationValue(Keystr) {
        console.log('***Keystr****');
        console.log(Keystr);
        var resultValue = '';
        var fieldList = Keystr.split(";");

        for (var i = 0; i < fieldList.length; i++) {
            var keyvalue = fieldList[i];

            if (keyvalue.includes("{") || keyvalue.includes("}")) {
                keyvalue = keyvalue.replace('{', '');
                keyvalue = keyvalue.replace('}', '');
                if (this.record.hasOwnProperty(keyvalue)) {
                    resultValue = this.record[keyvalue];
                    //console.log(resultValue + 'keyvalue : ' + keyvalue);
                }
            } else {
                resultValue += keyvalue;
            }
        }

        if (typeof resultValue === 'undefined') {
            resultValue = '';
        }
        return resultValue;
    }

    handleClick(event) {
        window.open('https://www.google.com/maps/search/?api=1&query=' + this.GenLocationValue(this.StreetField) + ',' + this.GenLocationValue(this.CityField) + ',' + this.GenLocationValue(this.StateField) + ',' + this.GenLocationValue(this.CountryField), '_blank');
    }
}