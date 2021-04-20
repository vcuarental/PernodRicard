import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getEventList from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.getEventList';
import resource from "@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource";


export default class ASI_CRM_VisitationEventCaptureLWC extends NavigationMixin(LightningElement) {

    @api visitID;
    @api custID;
    @api isStopped;
    eventList;
    @track imgURL = resource+ "/img/common/arrow_r_g.png";
    @track phototest ;
    @track photo0NotExist;
    @track photo1NotExist;
    @track photo2NotExist;
    @track Photo1;
    @track Photo2;
    @track Photo0;
    

    connectedCallback() {

        Promise.all([
			loadStyle(this, resource + '/sweetalert2.min.css'),
			loadScript(this, resource + '/sweetalert2.min.js')
		])
		.then(() => {
			window.addEventListener('onhashchange', this.locationHashChanged);
        });
        
        // this.parameters = JSON.parse(this.getQueryParameters());
        
    }

    renderedCallback()
	{
		if (this.hasRendered)
		{
			return;
		}
		
        this.hasRendered = true;
        console.log("Test");
        console.log(this.visitID);
        console.log(this.custID);
        console.log(this.isStopped);
        this.init();
    }
    
    init()
    {
        var params = { "recordId" : this.visitID };
        getEventList(params)
            .then(result => {
                console.log('Get result');
                
                this.eventList = result; 
                console.log(this.eventList);

            }).catch(error => {
                console.log('Error: '+ error.body.message);
            });
    }

    toCreate()
    {
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_VisitationEventCaptureEdit_Route"
            },
            state: {
                c__vid: this.visitID,
                c__cid: this.custID,
                c__eid: '',
                c__mode: 'Create',
                c__isStopped: false
            }
        });
    }

    toEdit(event)
    {
        var targetId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_VisitationEventCaptureEdit_Route"
            },
            state: {
                c__vid: this.visitID,
                c__cid: this.custID,
                c__eid: targetId,
                c__mode: 'Edit',
                c__isStopped: false
            }
        });
        
    }

}