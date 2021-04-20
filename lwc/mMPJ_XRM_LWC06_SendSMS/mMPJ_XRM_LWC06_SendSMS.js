import { LightningElement, wire, track,api } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CAMPAIGN_MEMBER_OBJECT from '@salesforce/schema/CampaignMember';
import getNumberOfContacts from '@salesforce/apex/MMPJ_XRM_LWCC06_SendSMS.getNumberOfContacts';
import handleSendSMS from '@salesforce/apex/MMPJ_XRM_LWCC06_SendSMS.handleSendSMS';
import MMPJ_XRM_Segmentation_CampaignMember_Status from '@salesforce/label/c.MMPJ_XRM_Segmentation_CampaignMember_Status'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class mMPJ_XRM_LWC06_SendSMS extends LightningElement {
    @api recordId;
    @track errorMessage='';
    @track picklists;
    @track statutPickList;
    @track nextLabel = 'Suivant';
    @track messageLength=0;

    @track contactsNumber;
    @track step = {
        filters : true,
        message : false,
        confirm : false
    }
    @track message ='';
    @track messageName ='';

     @track filtersValues ={
        status :'',
        participation:'',
        presence : ''
    }

    @track loaded = true;

    @wire (getPicklistValuesByRecordType,{objectApiName : CAMPAIGN_MEMBER_OBJECT,recordTypeId : '012D0000000t1MjIAI'})
    reqpicklists({error,data}){
        console.log('getPicklist');
        if(data){
            //data.picklistFieldValues.MMPJ_Ext_Vign_Presence__c.values.unshift({label:'Tous',value:''});
            //data.picklistFieldValues.MMPJ_Ext_Vign_Participation__c.values.unshift({label:'Tous',value:''});
            console.log(JSON.stringify(data));
            this.picklists = data.picklistFieldValues;
        }
        if(error){
            console.log(error);
        }
    }

    connectedCallback() {
        console.log(MMPJ_XRM_Segmentation_CampaignMember_Status);
        let values = MMPJ_XRM_Segmentation_CampaignMember_Status.split(';');
        console.log(values);
        let statutPickList = [];
        for(let ii=0;ii<values.length;ii++){
            statutPickList.push({
                label : values[ii],
                value : values[ii]
            });
        }
        this.statutPickList = statutPickList;
    }

    handleChangePicklistValue(event){
        let picklistType = event.target.dataset.id;
        switch(picklistType){
            case 'statusPicklist':
                this.filtersValues.status = event.detail.value;
                break;
            case 'presencePicklist':
                this.filtersValues.presence = event.detail.value;
                break;
            case 'participationPicklist':
                this.filtersValues.participation = event.detail.value;
                break;
            default :
        }
    }

    handleNextClick(event){
        if(this.step.filters){
            this.step.filters = false;
            this.step.message = true;
            let params = this.filtersValues;
            params.campaignId = this.recordId;
            console.log(params);
            getNumberOfContacts(params)
            .then(resp => {  
                console.log(resp);
                if(resp || resp ===0){
                    this.contactsNumber = resp;
                }    
                
            })
            .catch(error => {
                console.log(error);
            });
        }else if(this.step.message){
            console.log('Message');
            if(!this.messageName || this.messageName===''){
                this.errorMessage = 'Le nom de message est obligatoire';
                return;
            }
            if(!this.message || this.message ===''){
                this.errorMessage = 'Le message est obligatoire';
                return;
            }
            this.errorMessage ='';
            this.step.message = false;
            this.step.confirm= true;
            this.nextLabel = "Valider l'envoi";
        }else if(this.step.confirm){
            console.log('validation finale')
            //this.confirm = false;
            let parameters = this.filtersValues;
            parameters.message = this.message;
            parameters.campaignId = this.recordId;
            parameters.messageName=this.messageName;
            if(!this.contactsNumber || this.contactsNumber===0){
                this.errorMessage = 'Aucun contact n\'est sélectionné, veuillez changer les filtres.';
                return;
            }
            this.loaded = false;
            handleSendSMS(parameters)
            .then(resp =>{
                JSON.stringify(resp);
                if(resp && resp !==''){
                    this.errorMessage = resp;
                }else{
                    let ev = new ShowToastEvent({
                        title: 'Succès',
                        type : 'SUCCESS',
                        message: 'L\'envoi des messages est programmé pour '+this.contactsNumber + ' contact(s)',
                    });
                    this.dispatchEvent(ev);
                    this.handleCloseModal();
                }
                this.loaded = true;
                
            })
            .catch(error =>{
                JSON.stringify(error);
            });
        }
    }

    handlePreviousClick(event){
        if(this.step.message){
            this.step.message = false;
            this.step.filters= true;
        }else if(this.step.confirm){
            this.step.message = true;
            this.step.confirm = false;
            this.nextLabel = "Suivant";
        }
    }
    handleCountLength(event){
        console.log(event.detail.value.length);
        this.messageLength = event.detail.value.length;
        this.message = event.detail.value;
        //this.messageName = 'TODO';
    }

    handleCloseModal(event){
        const successEvent = new CustomEvent("success", {
            detail: { }
        });
        this.dispatchEvent(successEvent);
    }

    handleChangeMessageName(event){
        this.messageName=event.detail.value;
    }
}