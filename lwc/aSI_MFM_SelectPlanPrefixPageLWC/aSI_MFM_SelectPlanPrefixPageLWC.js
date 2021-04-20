import { LightningElement, api, track, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import resource from "@salesforce/resourceUrl/ASI_MFM_MY_LWC";
import USER_ID from '@salesforce/user/Id';
import getPrefixes from '@salesforce/apex/ASI_MFM_SelectPlanPrefixLWC_Cls.getPrefixes';

export default class ASI_MFM_SelectPlanPrefixPageLWC extends NavigationMixin(LightningElement)  {
	@track available_prefix = [];
	@track prefix_data = [];
	@track selected_prefix = '';
	@track showTable = false;
	@track userId = '';
	@track recordTypeId = '';
	@track hasRendered = false;
	@track selected_prefix_Name = '';

	@wire(CurrentPageReference) currentPageReference; 
	get getrecordTypeId(){
        return this.currentPageReference &&
            this.currentPageReference.state.recordTypeId; 
	}
	/*
	@wire(getPrefixes, {RecordTypeId:'$recordTypeId'})
    wiredContacts({data, error}){
        if(data){
			console.log('wire');
            var listlength = data.length;
			if (data[0].error == true)
			{
				var errorMessage = data[0].errorMsg;
				Swal.fire({
				type  : 'error',
				title : 'Oops...',
				text  : errorMessage
				});
				console.log('getPrefixes');
				console.log(error);
			}else{
				this.available_prefix = [];
				for (var i = 0; i < listlength; i++) {
					var prefix = {
						label: data[i].selectionName, 
						value: data[i].selectionId
					};
					this.available_prefix.push(prefix);
				}
			}
        }
        else if (error) {
			var errorMessage = (error.body ? error.body.message : error.message);
			Swal.fire({
				type  : 'error',
				title : 'Oops...',
				text  : errorMessage
			});
			console.log('getPrefixes');
			console.log(error);
		}
    }*/


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
			window.addEventListener('onhashchange', this.locationHashChanged);
		});	
		//this.init();
    }

    renderedCallback()
	{
		if(this.recordTypeId==='')
		{
			this.recordTypeId = this.getrecordTypeId;
		}

		console.log(this.hasRendered);
		if (this.hasRendered)
		{
			return;
		}
		
		this.hasRendered = true;
		this.init();
	}
	
	locationHashChanged(){
		this.init();
	}

    init()
	{
		if(this.recordTypeId==='')
		{
			this.recordTypeId = this.getrecordTypeId;
		}
		this.userId = USER_ID;
		var param = {
			RecordTypeId: this.recordTypeId
		};
		getPrefixes(param)
            .then(result => {
				if (result)
				{
					var listlength = result.length;
					if (result[0].error == true)
					{
						var errorMessage = result[0].errorMsg;
						Swal.fire({
						type  : 'error',
						title : 'Oops...',
						text  : errorMessage
						});
						console.log('getPrefixes');
						console.log(error);
					}else{
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

						this.checkSinglePrefix();
					}
                }
            }).catch(error => {
                var errorMessage = (error.body ? error.body.message : error.message);
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
				});
				console.log('getPrefixes');
				console.log(error);
			});
	}

	
	auto(){
		if(this.available_prefix.length > 1){
		console.log('auto');
		const defaultValues = encodeDefaultFieldValues({
			ASI_MFM_Prefix__c: this.available_prefix[1].value,
			Name: this.available_prefix[1].label,
		});
		console.log(defaultValues);
		this[NavigationMixin.Navigate]({
			type: 'standard__objectPage',
			attributes: {
				objectApiName: 'ASI_MFM_Plan__c',
				actionName: 'new'
			},
			state: {
				nooverride: true,
				recordTypeId: this.recordTypeId,
				Rendered: true,
				defaultFieldValues: defaultValues
			}
		});
		}
	}

	handleChange(event){
		this.selected_prefix = event.detail.value;
		this.selected_prefix_Name = event.target.options.find(opt => opt.value === event.detail.value).label;
	}

    handleProceedClick(){
		if(this.selected_prefix == '')
		{
			Swal.fire({
				type  : 'error',
				title : 'Oops...',
				text  : 'Please select prefix first'
			});
		}
		else{
			const defaultValues = encodeDefaultFieldValues({
				ASI_MFM_Prefix__c: this.selected_prefix,
				Name: this.selected_prefix_Name,
			});
			console.log(defaultValues);

			/*
			this[NavigationMixin.Navigate]({
				type: 'standard__objectPage',
				attributes: {
					objectApiName: 'ASI_MFM_Plan__c',
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
					objectApiName: 'ASI_MFM_Plan__c',
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

	handleCancelClick(){
		//this.auto();
		this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'ASI_MFM_Plan__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
	}

	checkSinglePrefix() {
		if ((this.prefix_data) && 
			(!(this.recordTypeId === '') || (this.recordTypeId == undefined))) {

			console.log('checkSinglePrefix');
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