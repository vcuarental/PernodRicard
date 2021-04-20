import { LightningElement, api, track, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";
import USER_ID from '@salesforce/user/Id';
import R_getInitParam from '@salesforce/apex/ASI_MFM_MY_PO_SubmitForApprovalLWC_Cls.getInitParam';

export default class ASI_MFM_MY_PO_SubmitForApprovalLWC extends LightningElement {

    @api poId;

    @track hasRendered = false;
    @track userId = '';
    @track isCompleteLoading = false;
    @track isError = false;
    @track errorDesc = '';

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
		this.getInitParam();
    }

    getInitParam() {
		var param = {
			POID: (this.poId=='' ? undefined : this.poId)
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
						
                        //this.isCompleteLoading = true;
                        this.handleProceedClick();
					}
                }
            }).catch(error => {
				console.log('R_getInitParam error');
				var sErrorMessage = (error.body ? error.body.message : error.message);
                this.showErrorMessage(sErrorMessage);
            });
	}
    
    handleProceedClick() {
        window.location.href = '/' + this.poId;
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