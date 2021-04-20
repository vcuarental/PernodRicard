import { LightningElement, api, track, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";
import USER_ID from '@salesforce/user/Id';
import R_getInitParam from '@salesforce/apex/ASI_MFM_MY_SubmitForApprovalLWC_Cls.getInitParam';

export default class ASI_MFM_MY_SubmitForApprovalLWC extends LightningElement {
    
    @api planId;

    @track hasRendered = false;
    @track userId = '';
    @track isCompleteLoading = false;
    @track isError = false;
    @track errorDesc = '';
    @track isOverBudget = false;
    @track isNoLine = false;

    connectedCallback() {
		Promise.all([
			loadStyle(this, resource + '/sweetalert2.min.css'),
			loadStyle(this, resource + '/jquery-ui.min.css'),
			loadScript(this, resource + '/jquery.min.js'),
			loadScript(this, resource + '/jquery-ui.min.js'),
			loadScript(this, resource + '/moment.js'),
			loadScript(this, resource + '/sweetalert2.min.js')
		])
		.then(() => {
			//this.init();
			window.addEventListener('onhashchange', this.locationHashChanged);
		});	
		//this.init();
    }

    renderedCallback()
	{
		if (this.hasRendered) {
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
        this.userId = USER_ID;
        this.isCompleteLoading = false;
        this.isError = false;
        this.isOverBudget = false;
        this.isNoLine = false;
		this.getInitParam();
    }

    getInitParam() {
		var param = {
			PlanID: (this.planId=='' ? undefined : this.planId)
		};
		R_getInitParam(param)
            .then(result => {
                if (result)
                {
                    console.log('R_getInitParam');
                    console.log(result);
					if (result.error == true) {
						console.log('R_getInitParam failure');

						var sErrorMessage = result.errorMsg;
						this.showErrorMessage(sErrorMessage);
					} else {
						console.log('R_getInitParam success');
						
						this.isNoLine = result.isNoLine;
                        this.isOverBudget = result.isOverBudget;
                        if (this.isNoLine) {
                            this.errorDesc = 'There is no plan line.';
                        }
                        if (this.isOverBudget) {
                            this.errorDesc = 'There is plan line(s) over the budget.';
                        }
                        this.isError = ((this.isNoLine) || (this.isOverBudget));
                        this.isCompleteLoading = true;
					}
                }
            }).catch(error => {
				console.log('R_getInitParam error');
				var sErrorMessage = (error.body ? error.body.message : error.message);
                this.showErrorMessage(sErrorMessage);
            });
	}
    
    handleProceedClick() {
        window.location.href = '/apex/ASI_SubmitApprovalPage?id=' + this.planId;
    }

    showErrorMessage(sErrorMessage) {
        /*
        Swal.fire({
			type  : 'error',
			title : 'Oops...',
			text  : sErrorMessage
        });
        */
       this.isError = true;
       this.errorDesc = sErrorMessage;
       this.isCompleteLoading = true;
    }
    
}