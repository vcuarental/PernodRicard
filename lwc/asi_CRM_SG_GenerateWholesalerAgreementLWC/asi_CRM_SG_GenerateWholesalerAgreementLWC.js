import { LightningElement, api, track } from 'lwc';
import myResource from '@salesforce/resourceUrl/ASI_CRM_SG_Logo';
import getCustomerInfo from '@salesforce/apex/ASI_CRM_SG_WholesalerAgreementCtr.getCustomerInfo';
export default class asi_CRM_SG_GenerateWholesalerAgreementLWC extends LightningElement {
    pr_Logo = myResource + '/ASI_CRM_SG_Logo.jpeg';
    Today = '';
    CurrentDay = '';
    CurrentP60Days = '';
    Name = '';
    PaymentTerms30 = false;
    PaymentTerms60 = false;
    PaymentTerms0 = false;
    CreditLimit = '';
    ASI_CRM_Wholesaler_Type__c = '';
    ASI_CRM_Business_Registration_Number__c = '';
    @track customDate;
    @track customMonth;
    @track money1;
    @track money2;
    @track money3;//9.2
    @track money4;
    @track money5; //9.1

    @track TnC_Chx9 = true;
    parameters = {};
    RecordId = '';

    renderedCallback() {
        if (this.hasRendered) return;
        this.hasRendered = true;
        var currentDate = new Date();
        this.Today = this.getWeekday(currentDate) + ' ' + this.ordinal_suffix_ofday(currentDate) + ' of ' + this.getMonth(currentDate) + ' ' + this.getYear(currentDate);
        this.CurrentDay = this.ordinal_suffix_ofday(currentDate) + ' of ' + this.getMonth(currentDate) + ' ' + this.getYear(currentDate);
        currentDate.setDate(currentDate.getDate() + 60);
        this.CurrentP60Days = this.ordinal_suffix_ofday(currentDate) + ' of ' + this.getMonth(currentDate) + ' ' + this.getYear(currentDate);
        this.parameters = this.getQueryParameters();
        this.RecordId = this.parameters.c__id;
        console.log(this.RecordId);
        this.getCustomer(this.RecordId);
        this.customDate = '';
        this.customMonth = '';
        this.money1 = '';
        this.money2 = '';
        this.money3 = '';
        this.money4 = '';
        this.money5 = '';
    }

    getCustomer(RecordId) {
        var params = {
            'recordId': RecordId
        };
        getCustomerInfo(params)
            .then(result => {
                this.ASI_CRM_Business_Registration_Number__c = result.registrationNo;
                this.Name = result.Name;
                this.CreditLimit = result.CreditLimit;
                this.ASI_CRM_Wholesaler_Type__c = result.wholeSalerType;

                if (result.PaymentTerms == '030') {
                    this.PaymentTerms30 = true;
                } else if (result.PaymentTerms == '060') {
                    this.PaymentTerms60 = true;
                } else {
                    this.PaymentTerms0 = true;
                }
                console.log('Get result');
                console.log(result);
                console.log(result.PaymentTerms );
                console.log(this.ASI_CRM_Wholesaler_Type__c);
                console.log(this.ASI_CRM_Business_Registration_Number__c);
                this.TnC_Chx9=true;
                if (this.ASI_CRM_Business_Registration_Number__c == null || this.ASI_CRM_Business_Registration_Number__c == ''
                    || this.ASI_CRM_Wholesaler_Type__c == null || this.ASI_CRM_Wholesaler_Type__c == '') {
                    alert('Please note that Business Registration Number or Wholesaler Type is missed');
                }
            }).catch(error => {
                console.log('Error: ' + error.body.message);
            });
    }

    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

    customDateChange(event) {
        this.customDate = event.target.value;
        console.log(this.customDate);
    }
    customMonthChange(event) {
        this.customMonth = event.target.value;
        console.log(this.customMonth);
    }
    money1Change(event) {
        this.money1 = event.target.value;
        console.log(this.money1);
    }
    money2Change(event) {
        this.money2 = event.target.value;
        console.log(this.money2);
    }
    money3Change(event) {
        this.money3 = event.target.value;
        console.log(this.money3);
    }
    money4Change(event) {
        this.money4 = event.target.value;
        console.log(this.money4);
    }
    money5Change(event) {
        this.money5 = event.target.value;
        console.log(this.money5);
    }
    handleCheckBoxChange(event) { // T & C checobox change

        if (event.target.name == 'TnC_Chx92') {
            this.TnC_Chx9 = event.target.checked;
        }
        console.log('TnC_Chx9 : '+this.TnC_Chx9);
    }

    GeneratePDF(evnet) {



        var url = '/apex/ASI_CRM_SG_GenWholesalerAgreementPDF?recordId=' + this.RecordId + '&Today=' + this.Today +
         '&CurrentDay=' + this.CurrentDay + '&CurrentP60Days=' + this.CurrentP60Days + '&customDate=' + this.customDate +
          '&customMonth=' + this.customMonth + '&money1=' + this.money1 + '&money2=' + this.money2 + '&money3=' + this.money3 + '&money4=' + this.money4 + '&money5=' + this.money5  
          +'&TnC_Chx9='+this.TnC_Chx9;
        console.log(url);

        if (this.customDate == null || this.customDate == ''
            || this.customMonth == null || this.customMonth == ''
            || this.money1 == null || this.money1 == ''
            || this.money2 == null || this.money2 == ''
            || this.money3 == null || this.money3 == ''
            || this.money4 == null || this.money4 == '' 
            || this.money5 == null || this.money5 == '') {
            alert('Please note that there is missed input');
        } else {
            window.open(url);
        }
    }

    getWeekday(d) {
        var weekday = new Array(7);
        weekday[0] = "Sunday";
        weekday[1] = "Monday";
        weekday[2] = "Tuesday";
        weekday[3] = "Wednesday";
        weekday[4] = "Thursday";
        weekday[5] = "Friday";
        weekday[6] = "Saturday";

        var n = weekday[d.getDay()];
        return n;
    }

    ordinal_suffix_ofday(d) {
        var i = d.getDate();
        var j = i % 10;
        var k = i % 100;
        var n = i + "th";
        if (j == 1 && k != 11) {
            n = i + "st";
        }
        if (j == 2 && k != 12) {
            n = i + "nd";
        }
        if (j == 3 && k != 13) {
            n = i + "rd";
        }

        return n;
    }

    getMonth(d) {
        const monthNames = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];

        return monthNames[d.getMonth()];
    }

    getYear(d) {
        return d.getFullYear();
    }
}