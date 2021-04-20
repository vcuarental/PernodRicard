import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getEventCapture from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.getEventCapture';
import getSubBrandList from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.getSubBrandList';
import getPhoto from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.getPhoto';
import deletePhoto from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.deletePhoto';
import updateEventCapture from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.updateEventCapture';
import createEventCapture from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.createEventCapture';
import resource from "@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource";

export default class ASI_CRM_VisitationEventCaptureEditLWC extends NavigationMixin(LightningElement) {
    @api visitID;
    @api custID;
    @api isStopped;
    @api eventID
    @api mode
    isCreated = true;
    event;
    subBrand=[];
    photoList;
    ActivityType;
    ActivityTypeValue = '';
    PRMorCompetitor;
    PRMorCompetitorValue = '';
    Name='';
    isLoading = false;
    ActivityTypeOther = '';
    subBrandName;
    subBrandList = [];
    SubbrandOther = '';
    StartDate;
    EndDate;
    StartTime;
    EndTime;
    PromotionMechanics;
    InitiatedbyOutlet = false;
    Remarks;
    SeeSameEvent = false;
    WhereActivation;
    MoreActivation;
    NumberBAs;
    @track photoStyle = [];
    @track isPreviewPhoto = false;
    @track Photo = '';
    @track PhotoId = '';
    @track ContentDocumentId = '';
    isLoaded = true;

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
        this.PRMorCompetitor = [
            { label: '', value: '' },
            { label: 'PR Activity', value: 'PR Activity' },
            { label: 'Competitor Activity', value: 'Competitor Activity' }
        ];

        this.ActivityType = [
            { label: '', value: '' },
            { label: 'Promotion', value: 'Promotion' },
            { label: 'Consumer Event', value: 'Consumer Event' },
            { label: 'Trade Event', value: 'Trade Event' },
            { label: 'Merchandising', value: 'Merchandising' },
            { label: 'Others', value: 'Others' }
        ];

        this.init();
    }

    init()
    {
        if(this.mode == 'Create'){
            this.isCreated = false;
            this.event = {
                'Id' : null,
                'Name' : null,
                'ASI_CRM_MY_ActivationEndDate__c' : null,
                'ASI_CRM_MY_ActivationEndTime__c' : null,
                'ASI_CRM_MY_ActivationStartDate__c' : null,
                'ASI_CRM_MY_ActivationStartTime__c' : null,
                'ASI_CRM_MY_Brand__c' : null,
                'ASI_CRM_MY_SeeSameEvent__c' : false,
                'ASI_CRM_MY_MoreActivation__c' : null,
                'ASI_CRM_MY_InitiatedOutlet__c' : false,
                'ASI_CRM_MY_PRMorCompetitor__c' : null,
                'ASI_CRM_MY_NumberBAs__c' : null,
                'ASI_CRM_MY_Outlet__c' : this.custID,
                'ASI_CRM_MY_PromotionMechanics__c' : null,
                'ASI_CRM_MY_Remarks__c' : null,
                'ASI_CRM_MY_Subbrand__c' : null,
                'ASI_CRM_MY_BrandOther__c' : null,
                'ASI_CRM_MY_TypeActivation__c' : null,
                'ASI_CRM_MY_TypeOther__c' : null,
                'ASI_CRM_MY_VisitationPlanDetail__c' : this.visitID,
                'ASI_CRM_MY_WhereActivation__c' : null,
            }
            this.subBrand = [];
            this.photoList = null;
        }
        else {
            this.isCreated = true;
            this.getCurrentEvent(this.eventID);
        }
    }

    getCurrentEvent(recordId)
        {
            var params = { "recordId" : recordId};
            getEventCapture(params)
                .then(result => {
                    console.log('Get result');
                    console.log(result);
                    this.event = result.currentEvent;
                    this.photoList = result.conVList;
                    console.log(this.event.ASI_CRM_MY_ActivationEndTime__c);
                    console.log(this.event.ASI_CRM_MY_ActivationStartTime__c);
                    if(this.event.ASI_CRM_MY_ActivationEndTime__c)
                    {
                        this.event.ASI_CRM_MY_ActivationEndTime__c = this.timeMaker(this.event.ASI_CRM_MY_ActivationEndTime__c/1000);
                    }
                    if(this.event.ASI_CRM_MY_ActivationStartTime__c)
                    {
                        this.event.ASI_CRM_MY_ActivationStartTime__c = this.timeMaker(this.event.ASI_CRM_MY_ActivationStartTime__c/1000);
                    }
                    this.PRMorCompetitorValue = this.event.ASI_CRM_MY_PRMorCompetitor__c;
                    this.Name = this.event.Name;
                    this.eventID = this.event.Id;
                    this.SubbrandOther = this.event.ASI_CRM_MY_BrandOther__c;
                    this.ActivityTypeValue = this.event.ASI_CRM_MY_TypeActivation__c;
                    this.StartDate = this.event.ASI_CRM_MY_ActivationStartDate__c;
                    this.EndDate = this.event.ASI_CRM_MY_ActivationEndDate__c;
                    this.StartTime = this.event.ASI_CRM_MY_ActivationStartTime__c;
                    this.EndTime = this.event.ASI_CRM_MY_ActivationEndTime__c;
                    this.PromotionMechanics = this.event.ASI_CRM_MY_PromotionMechanics__c;
                    this.InitiatedbyOutlet = this.event.ASI_CRM_MY_InitiatedOutlet__c;
                    this.Remarks = this.event.ASI_CRM_MY_Remarks__c;
                    this.SeeSameEvent = this.event.ASI_CRM_MY_SeeSameEvent__c;
                    this.WhereActivation = this.event.ASI_CRM_MY_WhereActivation__c;
                    this.MoreActivation  = this.event.ASI_CRM_MY_MoreActivation__c;
                    this.NumberBAs = this.event.ASI_CRM_MY_NumberBAs__c;
                    this.ActivityTypeOther = this.event.ASI_CRM_MY_TypeOther__c;
                    if(this.event.ASI_CRM_MY_Subbrand__c)
                    {
                        this.subBrand = {'Name': this.event.ASI_CRM_MY_Subbrand__r.Name,
                        'Id': this.event.ASI_CRM_MY_Subbrand__c};
                    }
                    if(this.photoList){
                        console.log('length');
                        console.log(this.photoList.length);
                        var listlength = this.photoList.length;
                        for (var i = 0; i < listlength; i++) {
                        var tempStyle = 'background-repeat: no-repeat;background-position: center center;background-size: cover; background-image: url(/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId='+this.photoList[i].Id+')';
                            var Style = {
                                        Id: this.photoList[i].Id, 
                                        Style: tempStyle,
                                        ContentDocumentId: this.photoList[i].ContentDocumentId,
                                        index: i+1,
                                        imgurl: '/sfc/servlet.shepherd/version/Download/'+this.photoList[i].Id
                                    };
                            this.photoStyle.push(Style);
                        }
                        console.log(this.photoStyle);
                    }
                    this.isCreated = true;
                    this.mode = 'Edit';

                }).catch(error => {
                    swal.fire({
                        title: 'Get Event failed',
                        text: "Please contact administrator for the issue.",
                        confirmButtonColor: '#3085d6',
                        cancelButtonColor: '#d33',
                        confirmButtonText: 'Confirm'
                    }).then((result) => {
                        if(result.value) {
                        }
                    });
                });
        }
        

    timeMaker(totalSeconds) {
        console.log(totalSeconds);
        var second = totalSeconds % 60;
            var minutes = parseInt(totalSeconds / 60);
            var hours = parseInt(totalSeconds / 3600);
            if(minutes > 59)
            {
                minutes = parseInt((totalSeconds % 3600) / 60);
            }
            var secondString = second + "";
            var minutesString = minutes + "";
            var hoursString = hours + "";
            if (secondString.length < 2) {
                secondString = "0" + secondString;
            } else {
                secondString =  secondString;
            }
            
            if (minutesString.length < 2) {
                minutesString = "0" + minutesString;
            } else {
                minutesString =  minutesString;
            }
            
            if (hoursString.length < 2) {
                hoursString = "0" + hoursString;
            } else {
                hoursString =  hoursString;
            }

            var time = hoursString + ':' + minutesString + ':00.000';

            return time
    }

    handleChange(event)
    {
        var targetId = event.target.dataset.id;
        switch (targetId){
            case "PRMorCompetitor":
                console.log( 'in PRMorCompetitor');
                this.PRMorCompetitorValue = event.detail.value;
                console.log(event.detail.value);
                this.event.ASI_CRM_MY_PRMorCompetitor__c = this.PRMorCompetitorValue;
                console.log(this.event.ASI_CRM_MY_PRMorCompetitor__c);
                break;
            case "Name":
                this.Name = event.target.value;
                this.event.Name = this.Name;
                console.log(this.event.Name);
                break;
            case "SubbrandOther":
                this.SubbrandOther = event.target.value;
                this.event.ASI_CRM_MY_BrandOther__c = this.SubbrandOther;
                console.log(this.event.ASI_CRM_MY_BrandOther__c);
                break;    
            case "ActivityType":
                this.ActivityTypeValue = event.detail.value;
                this.event.ASI_CRM_MY_TypeActivation__c = this.ActivityTypeValue;
                console.log(this.event.ASI_CRM_MY_TypeActivation__c);
                break;
            case "ActivityTypeOther":
                this.ActivityTypeOther = event.target.value;
                this.event.ASI_CRM_MY_TypeOther__c = this.ActivityTypeOther;
                console.log(this.event.ASI_CRM_MY_TypeOther__c);
                break;       
            case "StartDate":
                this.StartDate = event.detail.value;
                this.event.ASI_CRM_MY_ActivationStartDate__c = this.StartDate;
                console.log(this.event.ASI_CRM_MY_ActivationStartDate__c);
                break;
            case "EndDate":
                this.EndDate = event.detail.value;
                this.event.ASI_CRM_MY_ActivationEndDate__c = this.EndDate;
                console.log(this.event.ASI_CRM_MY_ActivationEndDate__c);
                break;
            case "StartTime":
                this.StartTime = event.detail.value;
                this.event.ASI_CRM_MY_ActivationStartTime__c = this.StartTime;
                console.log(this.event.ASI_CRM_MY_ActivationStartTime__c);
                break; 
            case "EndTime":
                this.EndTime = event.detail.value;
                this.event.ASI_CRM_MY_ActivationEndTime__c = this.EndTime;
                console.log(this.event.ASI_CRM_MY_ActivationEndTime__c);
                break;
            case 'PromotionMechanics':
                this.PromotionMechanics = event.target.value;
                this.event.ASI_CRM_MY_PromotionMechanics__c = this.PromotionMechanics;
                console.log(this.event.ASI_CRM_MY_PromotionMechanics__c);
                break;
            case 'InitiatedbyOutlet':
                this.InitiatedbyOutlet = event.detail.checked;
                this.event.ASI_CRM_MY_InitiatedOutlet__c = this.InitiatedbyOutlet;
                console.log(this.event.ASI_CRM_MY_InitiatedOutlet__c);
                break;
            case 'Remarks':
                this.Remarks = event.target.value;
                this.event.ASI_CRM_MY_Remarks__c = this.Remarks;    
                console.log(this.event.ASI_CRM_MY_Remarks__c);
                break;
            case 'SeeSameEvent':
                this.SeeSameEvent = event.detail.checked;
                this.event.ASI_CRM_MY_SeeSameEvent__c = this.SeeSameEvent;
                console.log(this.event.ASI_CRM_MY_SeeSameEvent__c);
                break;
            case 'WhereActivation':
                this.WhereActivation = event.target.value;
                this.event.ASI_CRM_MY_WhereActivation__c = this.WhereActivation;   
                console.log(this.event.ASI_CRM_MY_WhereActivation__c);
                break;
            case 'MoreActivation':
                this.MoreActivation = event.target.value;
                this.event.ASI_CRM_MY_MoreActivation__c = this.MoreActivation; 
                console.log(this.event.ASI_CRM_MY_MoreActivation__c);  
                break; 
            case 'NumberBAs':
                this.NumberBAs = event.target.value;
                this.event.ASI_CRM_MY_NumberBAs__c = this.NumberBAs;
                console.log(this.event.ASI_CRM_MY_NumberBAs__c);  
                break;
        }
        console.log(this.event)
    }
    

	searchSubBrand(event)
    {
		var searchStr = event.target.value;
		this.subBrandName = searchStr;

        if (this.subBrand != null && this.subBrand.Name != searchStr)
        {
            this.subBrand = null;
            this.event.ASI_CRM_MY_Subbrand__c = null;
        }

        if (searchStr != undefined && searchStr != null && searchStr != '' && searchStr.length >= 2)
        {
			this.isLoading = true;
			var param = {
				Name: searchStr
			};
			getSubBrandList(param)
				.then(result => {
					if (result && this.isLoading)
					{
						this.subBrandList = result;
						this.hasSubBrand = true;
					}

					this.isLoading = false;
				}).catch(error => {
					console.log('Error: '+ error.body.message);
					this.isLoading = false;
				});
        }
        else
        {
			this.subBrandList = [];
			this.subBrand = null;
			this.subBrandName = '';
			this.hasSubBrand = false;
            this.isLoading = false;
            this.event.ASI_CRM_MY_Subbrand__c = null;
		}
	}
	
	get getSearchStr()
	{
		if (this.subBrand != null)
		{
			return this.subBrand.Name;
		}

		return this.subBrandName;
	}

    selectSubBrand(event)
    {
		var sbID = event.target.dataset.id;
		var sbName = event.target.dataset.name;
		this.subBrand = { 'Id': sbID, 'Name': sbName };
		this.subBrandName = sbName;
		this.subBrandList = [];
        this.hasSubBrand = false;
        this.event.ASI_CRM_MY_Subbrand__c = sbID;
        console.log(this.event.ASI_CRM_MY_Subbrand__c);
    }

    refreshPhoto()
    {
        this.isLoaded = false;
        var param = {
            recordId: this.eventID,
        };
        getPhoto(param)
            .then(result => {
                if (result)
				{
                    console.log(result);
                    this.photoList = result;
                    this.photoStyle = [];
                    var listlength = this.photoList.length;
                    for (var i = 0; i < listlength; i++) {
                        var tempStyle = 'background-repeat: no-repeat;background-position: center center;background-size: cover; background-image: url(/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId='+this.photoList[i].Id+')';
                        var Style = {
                                    Id: this.photoList[i].Id, 
                                    ContentDocumentId: this.photoList[i].ContentDocumentId,
                                    Style: tempStyle,
                                    index: i+1,
                                    imgurl: '/sfc/servlet.shepherd/version/Download/'+this.photoList[i].Id
                                };
                        this.photoStyle.push(Style);
                    }
                    console.log(this.photoStyle);
                    this.isLoaded = true;
                }
            }).catch(error => {
                var errorMessage = 'Something went wrong!';
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
				});
            }); 
    }
    
    handleUploadFinished(event){
        // This will contain the List of File uploaded data and status        
        //alert("Files uploaded : " + uploadedFiles.length);
        this.refreshPhoto();
              
    }

    previewPhoto(event){
        this.isPreviewPhoto = true;
        this.PhotoId = event.currentTarget.dataset.id;
        this.Photo = '/sfc/servlet.shepherd/version/Download/'+this.PhotoId;
        this.ContentDocumentId = event.currentTarget.dataset.key;
        //<img src={arrow_r_g} class="lock" style="margin-top:0;"></img>

    }

    closePreview()
	{
        this.isPreviewPhoto = false;
        this.PhotoId = '';
        this.Photo = '';
        this.ContentDocumentId = '';
	}

    downloadPhoto(){
        let downloadElement = document.createElement('a');
        downloadElement.href = this.Photo;
        downloadElement.setAttribute("download","download");
        downloadElement.download = 'download.jpg';
        downloadElement.click(); 
    }
    
    photoDetail(){
        this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: this.ContentDocumentId,
				objectApiName: 'ContentDocument',
				actionName: 'view'
			}
		});
    }

    deleteDoc(){
        var ContentDocumentId = this.ContentDocumentId;
        var param = {
            recordId: ContentDocumentId,
        };
        Swal.fire({
            title               : "Delete Photo",
            text                : "Are you sure to delete Photo?",
            type                : 'warning',
            showCancelButton    : true,
            confirmButtonColor  : '#3085d6',
            cancelButtonColor   : '#d33',
            confirmButtonText   : 'Confirm'
        }).then((result) => {
          if (result.value) {
                deletePhoto(param)
                .then(result => {
                    console.log('to reload');
                    this.refreshPhoto();
                    this.isPreviewPhoto = false;

                }).catch(error => {
                    var errorMessage = 'Something went wrong!';
                    Swal.fire({
                    type  : 'error',
                    title : 'Oops...',
                    text  : errorMessage
                    });
                });
                }
        });
        
    }

    editEvent()
    {
        if(this.event.Name == null || this.event.Name == '')
        {
            alert("Please input Event Name");
        }
        else if(this.event.ASI_CRM_MY_TypeActivation__c == 'Others' && (this.event.ASI_CRM_MY_TypeOther__c == null ||this.event.ASI_CRM_MY_TypeOther__c =='' )){
            alert("Please input Type of Activatin (Other)");
        }
        else
        {
            if(this.event.ASI_CRM_MY_ActivationStartTime__c && this.event.ASI_CRM_MY_ActivationStartTime__c!='' && this.event.ASI_CRM_MY_ActivationStartTime__c !='00.000')
            {
                this.event.ASI_CRM_MY_ActivationStartTime__c = this.event.ASI_CRM_MY_ActivationStartTime__c + 'Z';
            }
            if(this.event.ASI_CRM_MY_ActivationEndTime__c && this.event.ASI_CRM_MY_ActivationEndTime__c!='' && this.event.ASI_CRM_MY_ActivationEndTime__c !='00.000')
            {
                this.event.ASI_CRM_MY_ActivationEndTime__c = this.event.ASI_CRM_MY_ActivationEndTime__c + 'Z';
            }
            swal.fire({
				title: 'Edit Event',
				text: "Are you sure?",
				showCancelButton: true,
				confirmButtonColor: '#3085d6',
				cancelButtonColor: '#d33',
				confirmButtonText: 'Confirm'
			}).then((result) => {
				if(result.value) {
					var params = { "eventCaptureJson" : JSON.stringify(this.event)};
                    updateEventCapture(params)
                        .then(result => {
                            console.log('Get result');
                            console.log(result);
                            swal.fire({
                                title: 'Save Event',
                                text: "Event Saved",
                                confirmButtonColor: '#3085d6',
                                cancelButtonColor: '#d33',
                                confirmButtonText: 'Confirm'
                            }).then((result) => {
                                if(result.value) {
                                }
                            });
                        }).catch(error => {
                            swal.fire({
                                title: 'Save Event',
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

    createEvent()
    {
        if(this.event.Name == null || this.event.Name == '')
        {
            alert("Please input Event Name");
        }
        else if(this.event.ASI_CRM_MY_TypeActivation__c == 'Others' && (this.event.ASI_CRM_MY_TypeOther__c == null ||this.event.ASI_CRM_MY_TypeOther__c =='' )){
            alert("Please input Type of Activatin (Other)");
        }
        else
        {
            if(this.event.ASI_CRM_MY_ActivationStartTime__c && this.event.ASI_CRM_MY_ActivationStartTime__c!='' && this.event.ASI_CRM_MY_ActivationStartTime__c !='00.000')
            {
                this.event.ASI_CRM_MY_ActivationStartTime__c = this.event.ASI_CRM_MY_ActivationStartTime__c + 'Z';
            }
            if(this.event.ASI_CRM_MY_ActivationEndTime__c && this.event.ASI_CRM_MY_ActivationEndTime__c!='' && this.event.ASI_CRM_MY_ActivationEndTime__c !='00.000')
            {
                this.event.ASI_CRM_MY_ActivationEndTime__c = this.event.ASI_CRM_MY_ActivationEndTime__c + 'Z';
            }
            swal.fire({
				title: 'Craete Event',
				text: "Are you sure?",
				showCancelButton: true,
				confirmButtonColor: '#3085d6',
				cancelButtonColor: '#d33',
				confirmButtonText: 'Confirm'
			}).then((result) => {
				if(result.value) {
					var params = { "eventCaptureJson" : JSON.stringify(this.event)};
                    createEventCapture(params)
                        .then(result => {
                            console.log('Get result');
                            console.log(result);
                            this.getCurrentEvent(result.Id);
                            swal.fire({
                                title: 'Save Event',
                                text: "Event Saved",
                                confirmButtonColor: '#3085d6',
                                cancelButtonColor: '#d33',
                                confirmButtonText: 'Confirm'
                            }).then((result) => {
                                if(result.value) {
                                }
                            });
                        }).catch(error => {
                            swal.fire({
                                title: 'Create Event',
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

}