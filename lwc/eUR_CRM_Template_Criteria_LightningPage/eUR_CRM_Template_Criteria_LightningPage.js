import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import loadData from '@salesforce/apex/EUR_CRM_Template_Criteria_Edition.loadData';
import getTemplates from '@salesforce/apex/EUR_CRM_Template_Criteria_Edition.getTemplates';
import saveTemplateCriterias from '@salesforce/apex/EUR_CRM_Template_Criteria_Edition.saveTemplateCriterias';

import TemplateCriteriaModel from './TemplateCriteriaModel';

export default class EUR_CRM_Template_Criteria_LightningPage extends LightningElement {
    @track loading = false;
    NbLoading = 0;

    @api recordId;

    /*
     * Each PROS is linked to a region, so far only RU use it but I will make the logic apply for all
     * => An empty region is the region "All region"
     */
    @track regionId = null;
    @track regionName = 'Apply for all other regions';
    @track hasMoreThanOneRegion = false;
    @track regions = [];

    /*
     * List of template for updating existing/non-existing template criteria
     */
    @track templates = [];
    /*
     * Keep in track the current ID selected
     */
    selectedTemplateId = null;

    /*
     * Check if all metadata is configured, we don't check if it is "properly configured"
     */
    @track hasAllRequiredMetadata = false;
    /*
     * Big variable that has the logic of this page
     */
    @track model;

    /*
     * All criterias even the one not existing (but templateCriteriaId will be empty)
     */
    criterias = [];
    /*
     * All selected criterias for update
     */
    selectedCriterias = [];

    /*
     *   Constructor
     */
    connectedCallback() {



        this.loadTemplateCriterias();

        this.startLoading();
        getTemplates({ templateId: this.recordId }).then(result => {
            this.stopLoading();
            //console.log(result);
            if (Array.isArray(result)) {
                result.sort(function(a, b) {
                    return (a.label > b.label ? 1 : (b.label > a.label ? -1 : 0));
                });
            }
            this.templates = result;

        }).catch(error => {
            this.stopLoading();
            this.displayError(error);

        });
    }

    onChangeRegion(event) {
        this.regionId = event.detail.value;

        this.loadTemplateCriterias();
    }

    loadTemplateCriterias() {
        this.model = new TemplateCriteriaModel();

        this.startLoading();
        loadData({ templateId: this.recordId, regionId: this.regionId }).then(result => {
            this.stopLoading();
            this.hasAllRequiredMetadata = result.hasAllRequiredMetadata;
            this.criterias = result.criterias;
            this.regions = result.regions;
            this.hasMoreThanOneRegion = (this.regions.length > 1);
            for (let i = 0; i < this.regions.length; i++) {
                if (this.regions[i].value == this.regionId) {
                    this.regionName = this.regions[i].label;
                }
            }
            //console.log(Object.assign({}, result));
            for (let i = 0; i < result.criterias.length; i++) {
                let c = result.criterias[i];
                //console.log('a');
                let IL = this.model.addIL(c);
                if (IL) {
                    let VP = this.model.addVP(IL, c);
                    //console.log('b');
                }

                let GOT = this.model.addGOT(c);
                //console.log('c');
                if (GOT) {
                    let OT = this.model.addOT(GOT, c);
                }

            }
            //console.log('d');
            this.model.attachCriterias(result.criterias);
            console.log('GOTS')
            console.log(this.model.GOTS)
                //console.log(this.model);


        }).catch(error => {
            this.stopLoading();
        });

    }
    onChangeTemplate(event) {
        this.selectedTemplateId = event.detail.value;
        //console.log('Template selected : ' + this.selectedTemplateId);
    }
    handleSaveTemplateCriteria() {
        /*console.log('Call JS: handleSaveTemplateCriteria');
        console.log('templateId', this.selectedTemplateId);
        console.log('criterias', this.selectedCriterias);*/

        if (this.selectedTemplateId && this.selectedCriterias.length > 0) {
            //console.log('Data is correct');

            this.startLoading();
            saveTemplateCriterias({ criterias_str: JSON.stringify(this.selectedCriterias), templateId: this.selectedTemplateId }).then(result => {
                this.stopLoading();
                //console.log('operation is finish');
                this.selectedCriterias = [];
                this.loadTemplateCriterias();

            }).catch(error => {
                this.stopLoading();
                this.displayError(error);
            });
        }
    }

    handleSelectCriteria(event) {
        //console.log('Call JS: handleSelectCriteria');

        let igot = event.currentTarget.dataset.got;
        let iot = event.currentTarget.dataset.ot;
        let ivp = event.currentTarget.dataset.vp;
        let iil = event.currentTarget.dataset.il;
        let classname = 'tplc-selected-element';

        //console.log(igot, iot, ivp, iil);
        for (let i = 0; i < this.criterias.length; i++) {
            let c = this.criterias[i];
            if (c.GOT_id == igot && c.OT_id == iot && c.VP_id == ivp && c.IL_id == iil) {
                let theCriteria = this.criterias[i];
                //Already selected then remove from selection
                if (event.currentTarget.className == classname) {
                    event.currentTarget.className = '';
                    for (let i = 0; i < this.selectedCriterias.length; i++) {
                        let c = this.selectedCriterias[i];
                        if (c.GOT_id == igot && c.OT_id == iot && c.VP_id == ivp && c.IL_id == iil) {

                            this.selectedCriterias.splice(i, 1);
                        }
                    }
                }
                //Not selected, then add to selection
                else {
                    event.currentTarget.className = classname;
                    this.selectedCriterias.push(theCriteria);

                }
            }

        }


        console.log(this.selectedCriterias);
    }

    startLoading() {

        this.loading = true;
        this.NbLoading = this.NbLoading + 1;

    }
    stopLoading() {

        this.NbLoading = this.NbLoading - 1;
        if (this.NbLoading == 0) {
            this.loading = false;
        }
    }
    log(message, variable) {
        console.log(message);
        console.log(variable);
    }
    displayError(error) {

        const evt = new ShowToastEvent({
            title: "Error",
            message: error.message || error.body.message,
            variant: "error",
            mode: "sticky"
        });
        this.dispatchEvent(evt);
    }

}