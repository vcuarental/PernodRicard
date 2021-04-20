import { LightningElement, api, track, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";
import USER_ID from '@salesforce/user/Id';
import R_getPrefixes from '@salesforce/apex/ASI_MFM_SelectPOPrefixLWC_Cls.getPrefixes';
import R_getInitParam from '@salesforce/apex/ASI_MFM_SelectPOPrefixLWC_Cls.getInitParam';

const prefix_columns = [
    { label: 'Prefix Name', fieldName: 'label' },
    { label: 'Description', fieldName: 'description' },
];

export default class ASI_MFM_SelectPOPrefixPageLWC extends NavigationMixin(LightningElement) {

	@api planId;

	@track hasRendered = false;
	@track userId = '';
	@track recordTypeId = '';
    @track available_prefix = [];
	@track selected_prefix = '';
	@track selected_prefix_Name = '';
	@track showTable = false;
	@track planName = '';

	@track prefix_columns = prefix_columns;
	@track prefix_data = [];

	@wire(CurrentPageReference) currentPageReference; 
	get getRecordTypeId(){
        return this.currentPageReference &&
            this.currentPageReference.state.recordTypeId;
	}

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
		if (this.recordTypeId==='') {
			this.recordTypeId = this.getRecordTypeId;
		}
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
		/* 	LOGIC
			step1: R_getPrefixes
			step2: R_getInitParam
		*/
		this.getPrefixes();
		/*
		console.log('init start');
		var defaultValues = encodeDefaultFieldValues({
			ASI_MFM_Prefix__c: 'a9FL00000000Uo0MAE',
			ASI_MFM_Plan__c: 'a9EL00000004MKf',
			Name: '3318',
		});
		this[NavigationMixin.Navigate]({
			type: 'standard__objectPage',
			attributes: {
				objectApiName: 'ASI_MFM_PO__c',
				actionName: 'new'
			},
			state: {
				recordTypeId: this.recordTypeId,
				defaultFieldValues: defaultValues
			}
		});
		console.log('init end');
		*/
	}

	getPrefixes() {
		var param = {
			RecordTypeId: this.recordTypeId
		};
		R_getPrefixes(param)
            .then(result => {
				if (result)
				{
					console.log('R_getPrefixes');
					if (result[0].error == true)
					{
						console.log('R_getPrefixes failure');

						var sErrorMessage = result[0].errorMsg;
						this.showErrorMessage(sErrorMessage);
					}else{
						console.log('R_getPrefixes success');

						var listlength = result.length;
						this.available_prefix = [];
						this.prefix_data = [];
						for (var i = 0; i < listlength; i++) {
							var prefix = {
								label: result[i].selectionName,
								description: result[i].selectionDesc,
								value: result[i].selectionId
							};
							this.available_prefix.push(prefix);
							if (result[i].selectionId != '') {
								this.prefix_data.push(prefix);
							}
						}

						this.getInitParam();
					}
                }
            }).catch(error => {
				console.log('R_getPrefixes error');
				var sErrorMessage = (error.body ? error.body.message : error.message);
				this.showErrorMessage(sErrorMessage);
            });
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
						
						this.showTable = result.showTable;
						console.log('planId:'+this.planId);
						if (this.planId != '') {
							this.planName = result.planName;
							console.log('planName:'+this.planName);
						}
						console.log('recordTypeId:'+this.recordTypeId);
						if ((this.recordTypeId === '') || (this.recordTypeId == undefined)) {
							this.recordTypeId = result.defaultRecordTypeId;
							console.log('recordTypeId:'+this.recordTypeId);
						}

						this.checkSinglePrefix();
					}
                }
            }).catch(error => {
				console.log('R_getInitParam error');
				var sErrorMessage = (error.body ? error.body.message : error.message);
                this.showErrorMessage(sErrorMessage);
            });
	}

	handleChange(event) {
		this.selected_prefix = event.detail.value;
		this.selected_prefix_Name = event.target.options.find(opt => opt.value === event.detail.value).label;
	}

    handleProceedClick() {
		console.log('handleProceedClick');

		if(this.selected_prefix == '') {
			this.showErrorMessage('Please select prefix first');
		}
		else {
			var defaultValues = encodeDefaultFieldValues({
				ASI_MFM_Prefix__c: this.selected_prefix,
				Name: this.selected_prefix_Name,
			});
			if ((this.planId!='') && (this.planId != undefined)) {
				defaultValues = encodeDefaultFieldValues({
					ASI_MFM_Prefix__c: this.selected_prefix,
					ASI_MFM_Plan__c: this.planId,
					Name: this.selected_prefix_Name,
				});
			}

			console.log(defaultValues);
			console.log(this.recordTypeId);

			/*
			this[NavigationMixin.Navigate]({
				type: 'standard__objectPage',
				attributes: {
					objectApiName: 'ASI_MFM_PO__c',
					actionName: 'new'
				},
				state: {
					nooverride: true,
					recordTypeId: this.recordTypeId,
					defaultFieldValues: defaultValues
				}
			});
			*/
			this[NavigationMixin.GenerateUrl]({
				type: 'standard__objectPage',
				attributes: {
					objectApiName: 'ASI_MFM_PO__c',
					actionName: 'new'
				},
				state: {
					nooverride: true,
					recordTypeId: this.recordTypeId,
					defaultFieldValues: defaultValues
				}
			}).then(url => {
				//this.recordPageUrl = url;
				console.log('url:' + url);
				window.location.href = url;
			});

		}
	}

	handleCancelClick() {
		console.log('handleCancelClick');
		console.log('showTable:' + this.showTable);
		console.log('planId:' + this.planId);
		console.log('planName:' + this.planName);
		console.log('recordTypeId:' + this.recordTypeId);

		if ((this.planId=='') || (this.planId == undefined)) {
			this[NavigationMixin.Navigate]({
				type: 'standard__objectPage',
				attributes: {
					objectApiName: 'ASI_MFM_PO__c',
					actionName: 'list'
				},
				state: {
					filterName: 'Recent'
				},
			});
		} else {
			this[NavigationMixin.Navigate]({
				type: 'standard__recordPage',
				attributes: {
					objectApiName: 'ASI_MFM_Plan__c',
					recordId: this.planId,
					actionName: 'view'
				},
			});
		}
	}

	showErrorMessage(sErrorMessage) {
		Swal.fire({
			type  : 'error',
			title : 'Oops...',
			text  : sErrorMessage
		});
	}

	checkSinglePrefix() {
		if ((this.prefix_data) && 
			(!(this.recordTypeId === '') || (this.recordTypeId == undefined))) {

			console.log('checkSinglePrefix');
			console.log('showTable:' + this.showTable);
			console.log('planId:' + this.planId);
			console.log('planName:' + this.planName);
			console.log('recordTypeId:' + this.recordTypeId);
			console.log('prefix_data.length:'+this.prefix_data.length);
			if (this.prefix_data.length == 1) {
				var first_prefix = this.prefix_data[0];

				this.selected_prefix = first_prefix.value;
				this.selected_prefix_Name = first_prefix.label;
				this.handleProceedClick();
				//window.setTimeout(function(){ this.handleProceedClick() }, 1000);
			}
		}
	}

}