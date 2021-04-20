import { LightningElement, api, track, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";
import USER_ID from '@salesforce/user/Id';
import R_getPrefixes from '@salesforce/apex/ASI_MFM_SelectPaymentPrefixLWC_Cls.getPrefixes';
import R_getInitParam from '@salesforce/apex/ASI_MFM_SelectPaymentPrefixLWC_Cls.getInitParam';

const prefix_columns = [
    { label: 'Record Type Name', fieldName: 'label' },
    { label: 'Description', fieldName: 'description' },
];

export default class ASI_MFM_SelectPaymentPrefixPageLWC extends NavigationMixin(LightningElement) {

	@track recordTypeId = '';
	@track hasRendered = false;
	@track userId = '';
	
    @track available_prefix = [];
	@track selected_prefix = '';
	@track selected_prefix_Name = '';
	@track selected_prefix_location = '';
	
	@track showTable = false;
	@track checkSG = false; 
	@track prefix_columns = prefix_columns;
	@track prefix_data = [];
	@track selected_prefix_location = '';


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
		console.log('[init]this.recordTypeId:'+this.recordTypeId);

		this.userId = USER_ID;
		/* 	LOGIC
			step1: R_getPrefixes
			step2: R_getInitParam
		*/
		this.getPrefixes();
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
						this.selected_prefix_location = [];
						var listlength = result.length;
						this.available_prefix = [];
						this.prefix_data = [];
						for (var i = 0; i < listlength; i++) {
							var prefix = {
								label: result[i].selectionName,
								description: result[i].selectionDesc,
								value: result[i].selectionId,
								location: result[i].selectionLocation,
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
		console.log('[getInitParam]this.recordTypeId:'+this.recordTypeId);
		
		var param = {
			RecordTypeId: this.recordTypeId
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
						this.checkSG = result.checkSG;
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
			var currency = '';

			for (var i = 0; i < this.prefix_data.length; i++) {
				var oPrefix = this.prefix_data[i];
				var sLocation = oPrefix.location;
			
				if ((sLocation != 'Singapore') && (this.checkSG == true))
				{
					currency ='USD';
				}
			}
			if (currency!= '')
			{
				defaultValues = encodeDefaultFieldValues({
					ASI_MFM_Prefix__c: this.selected_prefix,
					Name: this.selected_prefix_Name,
					ASI_MFM_Currency__c: currency,
				});
				console.log('currency:'+this.currency);
			}
		
			console.log(defaultValues);
			console.log(this.recordTypeId);
			
			/*
			this[NavigationMixin.Navigate]({
				type: 'standard__objectPage',
				attributes: {
					objectApiName: 'ASI_MFM_Payment__c',
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
					objectApiName: 'ASI_MFM_Payment__c',
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
		console.log('check SG:' + this.checkSG );
		console.log('recordTypeId:' + this.recordTypeId);

		
			this[NavigationMixin.Navigate]({
				type: 'standard__objectPage',
				attributes: {
					objectApiName: 'ASI_MFM_Payment__c',
					actionName: 'list'
				},
				state: {
					filterName: 'Recent'
				},
			});
		
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
			console.log('checkSG:' + this.checkSG);
			console.log('recordTypeId:' + this.recordTypeId);
			console.log('prefix_data.length:'+this.prefix_data.length);
			console.log('description:' + this.prefix_data.description);
			if (this.prefix_data.length == 1) {
				var first_prefix = this.prefix_data[0];

				this.selected_prefix_location = first_prefix.location;
				this.selected_prefix = first_prefix.value;
				this.selected_prefix_Name = first_prefix.label;


				console.log('this.selected_prefix_location:' + this.selected_prefix_location);
				this.handleProceedClick();
				//window.setTimeout(function(){ this.handleProceedClick() }, 1000);
			
				/*
				var defaultValues = encodeDefaultFieldValues({
					ASI_MFM_Prefix__c: this.selected_prefix,
					Name: this.selected_prefix_Name,
				});

				var currency = '';
				for (var i = 0; i < this.prefix_data.length; i++) {
					var oPrefix = this.prefix_data[i];
					var sLocation = oPrefix.location;
				
					if ((sLocation != 'Singapore') && (this.checkSG == true))
					{
						currency ='USD';
					}
				}
				if (currency!= '')
				{
					defaultValues = encodeDefaultFieldValues({
						ASI_MFM_Prefix__c: this.selected_prefix,
						Name: this.selected_prefix_Name,
						ASI_MFM_Currency__c: currency,
					});
				}

				this[NavigationMixin.GenerateUrl]({
					type: 'standard__objectPage',
					attributes: {
						objectApiName: 'ASI_MFM_Payment__c',
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
				*/
			}

		}
	}

}