import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import resource from "@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource";
import getCurrentVisitationPlanDetail from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.getCurrentVisitationPlanDetail';
import saveVisitationPlanDetail from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.saveVisitationPlanDetail';
export default class Asi_CRM_VisitationDetail_QVAPLWC extends NavigationMixin(LightningElement)  {

	parameters = {};
	@api visitID;
    @track VisitationPlanDetail;
    @track bottleLabel = [];
    @track custodyCondition = [];
    @track outletType = [];
    @track ownActivations = [];
    @track topOfStaffMind = [];
    @track familiarWithPRM = [];
    @track bottleLabelValue;
    @track custodyConditionValue;
    @track outletTypeValue;
    @track ownActivationsValue;
    @track topOfStaffMindValue;
    @track familiarWithPRMValue;
    @track FollowPlanValue;
    @track ImprovementsValue;
    @track OwnActivationBrandNameRemarksValue;
    @track BarDisplayValue;
    @track PlanogramValue;
    @track RecommendValue;
    @track NotRecommendReasonValue;
    @track IncentiveValue;
    isChanged = false;
    @api isStopped = false;
    secsionQ = true;
    secsionV = false;
    secsionA = false;
    secsionP = false;


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
		this.init();
    }
    
    locationHashChanged()
	{
		this.init();
    }

    init()
	{
        this.getCurrentVisitationPlanDetail(this.visitID);
        // this.isStopped = this.parameters.attributes.isStopped;
        this.secsionQ = true;

        console.log(this.secsionQ);
    }

    changeSection(event)
    {
        var targetId = event.target.dataset.id;
        //console.log(targetId);
        //console.log(event.target.dataset.id);
        
        this.template.querySelector(`[data-id="Q"]`).style.backgroundColor = 'white';
		this.template.querySelector(`[data-id="Q"]`).style.color = 'black';
		this.template.querySelector(`[data-id="V"]`).style.backgroundColor = 'white';
		this.template.querySelector(`[data-id="V"]`).style.color = 'black';
		this.template.querySelector(`[data-id="A"]`).style.backgroundColor = 'white';
		this.template.querySelector(`[data-id="A"]`).style.color = 'black';
		this.template.querySelector(`[data-id="P"]`).style.backgroundColor = 'white';
		this.template.querySelector(`[data-id="P"]`).style.color = 'black';
		this.template.querySelector(`[data-id="${targetId}"]`).style.backgroundColor = '#033466';
        this.template.querySelector(`[data-id="${targetId}"]`).style.color = 'white';

        if(targetId == 'Q')
        {
            this.secsionQ = true;
            this.secsionV = false;
            this.secsionA = false;
            this.secsionP = false;
        }
        if(targetId == 'V')
        {
            this.secsionQ = false;
            this.secsionV = true;
            this.secsionA = false;
            this.secsionP = false;
        }
        if(targetId == 'A')
        {
            this.secsionQ = false;
            this.secsionV = false;
            this.secsionA = true;
            this.secsionP = false;
        }
        if(targetId == 'P')
        {
            this.secsionQ = false;
            this.secsionV = false;
            this.secsionA = false;
            this.secsionP = true;
        }
        


    }

    getQueryParameters() {
        //test URL
        var params = {};
        var encodedCompDef = window.location.hash;
        if (encodedCompDef) {
            console.log(encodedCompDef.substring(1));
            var decodedstring = encodedCompDef.substring(1).replace(/%3D/g, '=');
            console.log(decodedstring);
            params = atob(decodedstring);
            console.log("get ID");
            console.log(params);
        }

        return params;
    }

    getCurrentVisitationPlanDetail(RecordId)
    {
        console.log(RecordId);
        var params = { "recordId" : RecordId };
        getCurrentVisitationPlanDetail(params)
            .then(result => {
                console.log('Get result');
                console.log(JSON.stringify(result));
                this.VisitationPlanDetail = result.currentVisitationPlanDetail;
                result.bottleLabel.forEach(element => this.bottleLabel.push({label: element, value: element}));
                this.bottleLabel = JSON.parse(JSON.stringify(this.bottleLabel));
                console.log(result.custodyCondition);
                result.custodyCondition.forEach(element => this.custodyCondition.push({label: element, value: element}));
                this.custodyCondition = JSON.parse(JSON.stringify(this.custodyCondition));
                result.outletType.forEach(element => this.outletType.push({label: element, value: element}));
                this.outletType = JSON.parse(JSON.stringify(this.outletType));
                result.ownActivations.forEach(element => this.ownActivations.push({label: element, value: element}));
                this.ownActivations = JSON.parse(JSON.stringify(this.ownActivations));
                result.topOfStaffMind.forEach(element => this.topOfStaffMind.push({label: element, value: element}));
                this.topOfStaffMind = JSON.parse(JSON.stringify(this.topOfStaffMind));
                result.familiarWithPRM.forEach(element => this.familiarWithPRM.push({label: element, value: element}));
                this.familiarWithPRM = JSON.parse(JSON.stringify(this.familiarWithPRM));
                this.bottleLabelValue = this.VisitationPlanDetail.ASI_MY_CRM_Bottle_Label__c;
                this.custodyConditionValue = this.VisitationPlanDetail.ASI_MY_CRM_Custody_Condition__c;
                this.outletTypeValue = this.VisitationPlanDetail.ASI_MY_CRM_Outlet_Type__c;
                this.ownActivationsValue = this.VisitationPlanDetail.ASI_CRM_MY_Own_Activations__c;
                this.topOfStaffMindValue = this.VisitationPlanDetail.ASI_MY_CRM_Top_Of_Staff_Mind__c;
                this.familiarWithPRMValue = this.VisitationPlanDetail.ASI_MY_CRM_Familiar_WITH_PRM__c;
                this.FollowPlanValue = this.VisitationPlanDetail.ASI_MY_CRM_Follow_Plan__c;
                this.ImprovementsValue = this.VisitationPlanDetail.ASI_MY_CRM_Improvements__c;
                this.OwnActivationBrandNameRemarksValue = this.VisitationPlanDetail.ASI_CRM_MY_OwnActivationRemark__c;
                this.BarDisplayValue = this.VisitationPlanDetail.ASI_CRM_MY_BarDisplay__c;
                this.PlanogramValue = this.VisitationPlanDetail.ASI_CRM_MY_Planogram__c;
                this.RecommendValue = this.VisitationPlanDetail.ASI_MY_CRM_Recommend__c;
                this.NotRecommendReasonValue = this.VisitationPlanDetail.ASI_MY_CRM_Not_Recommend_Reason__c;
                this.IncentiveValue = this.VisitationPlanDetail.ASI_MY_CRM_Incentive__c;

            }).catch(error => {
                console.log('Error: '+ error.body.message);
            });
    }

    handleChange(event)
    {
        var targetId = event.target.dataset.id;
        console.log(targetId);
        switch (targetId){
        case "BottleLabel":
            this.bottleLabelValue = event.detail.value;
            this.VisitationPlanDetail.ASI_MY_CRM_Bottle_Label__c = this.bottleLabelValue;
            console.log(this.VisitationPlanDetail.ASI_MY_CRM_Bottle_Label__c);
            break;
        case "CustodyCondition":
            this.custodyConditionValue = event.detail.value;
            this.VisitationPlanDetail.ASI_MY_CRM_Custody_Condition__c = this.custodyConditionValue;
            console.log(this.VisitationPlanDetail.ASI_MY_CRM_Custody_Condition__c);
            break
        case "OutletType":
            this.outletTypeValue = event.detail.value;
            this.VisitationPlanDetail.ASI_MY_CRM_Outlet_Type__c = this.outletTypeValue;
            console.log(this.VisitationPlanDetail.ASI_MY_CRM_Outlet_Type__c);
            break;
        case "FollowPlan":
            this.FollowPlanValue = event.target.value;
            this.VisitationPlanDetail.ASI_MY_CRM_Follow_Plan__c = this.FollowPlanValue;
            console.log(this.VisitationPlanDetail.ASI_MY_CRM_Follow_Plan__c);
            break;
        case "Improvements":
            this.ImprovementsValue = event.target.value;
            this.VisitationPlanDetail.ASI_MY_CRM_Improvements__c = this.ImprovementsValue;
            console.log(this.VisitationPlanDetail.ASI_MY_CRM_Improvements__c);
            break;
        case "BarDisplay":
            this.BarDisplayValue = event.detail.checked;
            this.VisitationPlanDetail.ASI_CRM_MY_BarDisplay__c = event.target.checked;
            console.log(this.VisitationPlanDetail.ASI_CRM_MY_BarDisplay__c);
            break;
        case "Planogram":
            this.PlanogramValue = event.detail.checked;
            this.VisitationPlanDetail.ASI_CRM_MY_Planogram__c = event.target.checked;
            console.log(this.VisitationPlanDetail.ASI_CRM_MY_Planogram__c);
            break;
        case "ownActivations":
            this.ownActivationsValue = event.detail.value;
            this.VisitationPlanDetail.ASI_CRM_MY_Own_Activations__c = this.ownActivationsValue;
            console.log(this.VisitationPlanDetail.ASI_CRM_MY_Own_Activations__c);
            break;
        case "OwnActivationBrandNameRemarks":
            this.OwnActivationBrandNameRemarksValue = event.target.value;
            this.VisitationPlanDetail.ASI_CRM_MY_OwnActivationRemark__c = this.OwnActivationBrandNameRemarksValue;
            console.log(this.VisitationPlanDetail.ASI_CRM_MY_OwnActivationRemark__c);
            break;
        case "topOfStaffMind":
            this.topOfStaffMindValue = event.detail.value;
            this.VisitationPlanDetail.ASI_MY_CRM_Top_Of_Staff_Mind__c = this.topOfStaffMindValue;
            console.log(this.VisitationPlanDetail.ASI_MY_CRM_Top_Of_Staff_Mind__c);
            break;
        case "familiarWithPRM":
            this.familiarWithPRMValue = event.detail.value;
            this.VisitationPlanDetail.ASI_MY_CRM_Familiar_WITH_PRM__c = this.familiarWithPRMValue;
            console.log(this.VisitationPlanDetail.ASI_MY_CRM_Familiar_WITH_PRM__c);
            break
        case "Recommend":
            this.RecommendValue  = event.detail.checked;
            this.VisitationPlanDetail.ASI_MY_CRM_Recommend__c = this.RecommendValue;
            console.log(this.VisitationPlanDetail.ASI_MY_CRM_Recommend__c);
            break;
        case "NotRecommendReason":
            this.NotRecommendReasonValue = event.target.value;
            this.VisitationPlanDetail.ASI_MY_CRM_Not_Recommend_Reason__c = this.NotRecommendReasonValue;
            console.log(this.VisitationPlanDetail.ASI_MY_CRM_Not_Recommend_Reason__c);
            break;
        case "Incentive":
            this.IncentiveValue = event.target.value;
            this.VisitationPlanDetail.ASI_MY_CRM_Incentive__c = this.IncentiveValue;
            console.log(this.VisitationPlanDetail.ASI_MY_CRM_Incentive__c);
            break;

        }
        this.isChanged = true;
    }

    updateVisitationDetail()
    {
        swal.fire({
            title: 'Save QVAP',
            text: "Are you sure?",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Confirm'
        }).then((result) => {
            if(result.value) {
                var params = { "updateVisitationDetailJson" : JSON.stringify(this.VisitationPlanDetail) };
                saveVisitationPlanDetail(params)
                    .then(result => {
                        swal.fire({
                            title: 'Save QVAP',
                            text: "QVAP Saved",
                            confirmButtonColor: '#3085d6',
                            cancelButtonColor: '#d33',
                            confirmButtonText: 'Confirm'
                        }).then((result) => {
                            if(result.value) {
                            }
                        });
                    }).catch(error => {
                                        swal.fire({
                                            title: 'Save QVAP',
                                            text: error.body.message,
                                            confirmButtonColor: '#3085d6',
                                            cancelButtonColor: '#d33',
                                            confirmButtonText: 'Confirm'
                                        }).then((result) => {
                                            if(result.value) {
                                            }
                                        });
                        console.log('Error: '+ error.body.message);
                    });
            }
        });

    }


}