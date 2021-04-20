import { api, LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import scriptPapaParse from '@salesforce/resourceUrl/EUR_TR_PapaParse_5_0_2';

export default class Eur_tr_dataLoader extends LightningElement {

    @api label = "Seçiniz"
    @api acceptedFormats = ['.csv']
        

    renderedCallback() {
        loadScript(this, scriptPapaParse + '/papaparse.min.js')
            .then(function () {                
                console.log("script loaded:papaparse.min.js")
            }, function (error) {
                console.error(error);
            }); 
    } 

    handleFileSelected(event ){
        const uploadedFiles = event.detail.files[0]; //single file allowed

    }

    connectedCallback() {
        
    }
}