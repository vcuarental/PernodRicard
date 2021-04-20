import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getVisitationPlanDetail from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.getVisitationPlanDetail';
import updateVisitationTime from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.updateVisitationTime';
import getPhoto from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.getPhoto';
import resource from "@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource";
import deletePhoto from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.deletePhoto';

export default class ASI_CRM_VisitationPlanTodayLWC extends NavigationMixin(LightningElement) {

    @api recordId;
    @track hasRendered = false;
	@track vpdList = [];
    @track vCount = 0;
    @track vCustomerName = '';
    @track vOutLetTypeName = '';
    @track vDate = new Date();
    @track customer = {};
    @track visitationPlanDetail = null;
    @track noteList = [];
    @track taskSetting = {};
    @api isStarted = false;
    @track isQVAP_Done = false;
    @track isRSP_Done = false;
    @track isIOT_Done = false;
    @track isEvent_Done = false;
    @track second = '00';
    @track minutes = '00';
    @track hours = '00';
    @track intervalID = null;
    @api isStopped = false;
    @track isTodayVisit = false;
    //@track isNotStartNotStop = false;
    //@track isOrStartStop = false;
    @track address = '';
    @track custAddress = '';
    @track phone = '';
    @track photoList;
    @track location_img = resource + '/location.png';
    @track phone_img = resource + '/img/common/phone.png';
    @track arrow_r_g = resource + '/img/common/arrow_r_g.png';
    @track icon_lock_d = resource + '/img/common/icon_lock_d.png';
    @track icon_check_l = resource + '/img/common/icon_check_l.png';
    @track icon_check_g = resource + '/img/common/icon_check_g.png';
    @track GoogleAddress = 'http://maps.google.com/maps?q=';
    @track TelNo = 'Tel:';
    //@track StatusBar = 'status-bar';
    @track vStatus = '';
    @track photoStyle = [];
    parameters = {};
    @track isPreviewPhoto = false;
    @track Photo = '';
    @track PhotoId = '';
    @track ContentDocumentId = '';
    @track countNo = 0;

    @api isLoaded = false;

    @api defaultTab = '1';

    get isNotStartNotStop(){
        return ((this.isStarted == false) && (this.isStopped == false));
    }

    get isOrStartStop(){
        return (this.isStarted || this.isStopped);
    }

    get StatusBar(){
        return 'status-bar '+this.visitationPlanDetail.ASI_HK_CRM_Status__c;
    }

    get backgroundStyle(){
        return 'z-index: 10;height: 170px;padding-bottom: 15px;color: white;background-repeat: no-repeat;background-position: center center;background-size: cover; background-image: url(' + resource + '/img/dummy/shop.jpg' + ');';
    } 

    get showsecond(){
        return this.second;
    }

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

    getQueryParameters() {
        //test URL
        var params = {};
        var encodedCompDef = window.location.hash;
        if (encodedCompDef) {
            console.log(encodedCompDef.substring(1));
            var decodedstring = encodedCompDef.substring(1).replace(/%3D/g, '=');
            console.log(decodedstring);
            params = atob(decodedstring);
            //console.log(params);
        }

        return params;
    }

    locationHashChanged()
	{
		this.init();
    }

    init()
	{
        this.getPlan();
        console.log("visitationPlanDetail"+this.visitationPlanDetail);
    }
    
    getPlan()
	{
        // this.recordId = this.parameters.attributes.id;
        this.isLoaded = false;
        var param = {
            recordId: this.recordId
        };
        console.log(param);
		getVisitationPlanDetail(param)
            .then(result => {
				if (result)
				{
                    console.log(result);
                    this.visitationPlanDetail = result.currentVisitationPlanDetail;
                    if(result.currentVisitationPlanDetail.hasOwnProperty('ASI_TH_CRM_OutletType__r'))
                    {
                        this.vOutLetTypeName = result.currentVisitationPlanDetail.ASI_CRM_MY_Customer__r.ASI_TH_CRM_OutletType__r.Name;
                    }
                    this.vCustomerName = result.currentVisitationPlanDetail.ASI_CRM_MY_Customer__r.Name;
                    this.noteList = result.noteList;
                    this.taskSetting = result.taskSetting;
                    this.isQVAP_Done = result.isQVAP_Done;
                    this.isRSP_Done = result.isRSP_Done;
                    this.isIOT_Done = result.isIOT_Done;
                    this.isEvent_Done = result.isEvent_Done;
                    this.isTodayVisit = result.isToday;
                    this.photoList = result.conVList;
                    if(this.photoList){
                        //this.photoStyle = [];
                        console.log('length');
                        console.log(this.photoList.length);
                        var listlength = this.photoList.length;
                        for (var i = 0; i < listlength; i++) {
                            var tempStyle = 'background-repeat: no-repeat;background-position: center center;background-size: cover; background-image: url(/sfc/servlet.shepherd/version/Download/'+this.photoList[i].Id+')';
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

                    if(result.isToday == false 
                        || (result.currentVisitationPlanDetail.ASI_HK_CRM_Status__c
                        && result.currentVisitationPlanDetail.ASI_HK_CRM_Status__c != 'Planned'
                        && result.currentVisitationPlanDetail.ASI_HK_CRM_Status__c != 'Ad-hoc')
                    ){
                        this.isStopped = true;
                        if(this.intervalID)
                        {
                            clearInterval(this.intervalID);
                            this.intervalID = null;
                            this.second = '00';
                            this.minutes = '00';
                            this.hours = '00';
                        }
                    }else{
                        this.isStopped = false;
                    }

                    if(result.currentVisitationPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c 
                        && this.isStopped == false)
                    {
                        this.isStarted = true;
                        var startDate = result.currentVisitationPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c;
                        var startedHours = parseInt(startDate.substring(11,13));
                        var startedMinutes = parseInt(startDate.substring(14,16));
                        var startedSeconds = parseInt(startDate.substring(17,19));

                        var today = new Date();
                        var time = today.getTime() + (today.getTimezoneOffset() * 60 * 1000);
                        today = new Date(time);
                        var todayHours = today.getHours();
                        var todayMinutes = today.getMinutes();
                        var todaySecond = today.getSeconds();
                        
                        var startTotalSeconds = startedHours * 3600 + startedMinutes * 60 + startedSeconds;
                        var todayTotalSecond = todayHours * 3600 + todayMinutes * 60 + todaySecond;
                        
                        
                        // console.log(startDate);
                        // console.log(startTotalSeconds);
                        // console.log(today);
                        // console.log(todayTotalSecond);
                        // console.log(today.getTimezoneOffset());

                        if(this.intervalID){
                            clearInterval(this.intervalID);
                            this.intervalID = null;
                        }
                        this.startTimer(todayTotalSecond - startTotalSeconds);
                    }
                    else
                    {
                        this.isStarted = false;
                        if(this.intervalID){
                            clearInterval(this.intervalID);
                            this.intervalID = null;
                        }
                        this.second = '00';
                        this.minutes = '00';
                        this.hours = '00';
                    }

                    var noteList = result.noteList;
                
                    if(result.custAddress){
                        this.custAddress = result.custAddress;
                        this.address = escape(result.custAddress);
                    }
                    else if(this.visitationPlanDetail.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s){
                        this.address = this.visitationPlanDetail.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s 
                                        +"," + this.visitationPlanDetail.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Longitude__s
                    }else{
                        this.address = null;
                    }
                    
                    if(this.custPhone){
                        this.phone = result.custPhone;
                    }else{
                        this.phone = null;
                    }
                }
                this.isLoaded = true;
            }).catch(error => {
                var errorMessage = (error.body ? error.body.message : error.message);
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
				});
            });

    }

    startVisit(){

        swal.fire({
            title: 'Start Visit',
            text: "Are you sure?",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Confirm'
        }).then((result) => {
            if(result.value) {
                console.log('Clicked Start');
                this.updateTime('StartVisit')
            }
        });
    }

    endVisit(){
        var missingTask = '';

        if(this.taskSetting.ASI_CRM_QVAP_Required__c == true && this.isQVAP_Done == false)
        {
            missingTask = 'QVAP, ';
        }

        if(this.taskSetting.ASI_CRM_RSP_Required__c == true && this.isRSP_Done == false)
        {
            missingTask = missingTask + 'RSP,';
        }

        if(this.taskSetting.ASI_CRM_IOT_Required__c == true && this.isIOT_Done == false)
        {
            missingTask = missingTask + 'Place an order,';
        }

        if(this.taskSetting.ASI_CRM_Event_Required__c == true && this.isEvent_Done == false)
        {
            missingTask = missingTask + 'Event Capture';
        }

        missingTask = missingTask.trimRight();
        missingTask = missingTask.replace(/(^,)|(,$)/g, "");

        if(missingTask != '')
        {
            swal.fire({
                title: 'End Visit',
                text: "Please complete the task: "+ missingTask,
                showCancelButton: false,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Confirm'
            }).then((result) => {
                if(result.value) {
            }
            });
        }
        else
        {
            swal.fire({
                title: 'End Visit',
                text: "Are you sure?",
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Confirm'
            }).then((result) => {
                if(result.value) {
                this.updateTime("EndVisit");
            }
            });
        }
    }

    cancelVisit(){
        swal.fire({
            title: 'Cancel Visit',
            text: "Are you sure?",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Confirm'
        }).then((result) => {
            if(result.value) {
                this.updateTime("CancelVisit");
            }
        });
    }

    updateTime(actionType){
        this.isLoaded = false;
        var param = {
            recordId: this.recordId,
            action : actionType
        };
        updateVisitationTime(param)
            .then(result => {
                    if(actionType == 'StartVisit')
                    {
                        console.log('StartVisit');
                        this.isStarted = true;
                        if(this.intervalID){
                            clearInterval(this.intervalID);
                            this.intervalID = null;
                        }
                        this.startTimer(0);
                    }else
                    {
                        if(actionType == 'CancelVisit')
                        {
                            this.visitationPlanDetail.ASI_HK_CRM_Status__c = 'Cancelled';
                        }
                        else{
                            this.visitationPlanDetail.ASI_HK_CRM_Status__c = 'Achieved';
                        }
                        this.isStopped = true;
                        this.stopTimer();
                    }
                    this.isLoaded = true;
            }).catch(error => {
                var errorMessage = (error.body ? error.body.message : error.message);
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
				});
            });
    }

    startTimer(secondDiff){
        var totalSeconds = secondDiff;
        var parentThis = this;
        var timer = setInterval(function() {
            ++totalSeconds;
            var second = totalSeconds % 60;
            var minutes = parseInt(totalSeconds / 60);
            var hours = parseInt(totalSeconds / 3600);
            //var parentThis = this;
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
            // console.log(hoursString + ":" + minutesString + ":" + secondString);
            parentThis.second = secondString;
            parentThis.minutes = minutesString;
            parentThis.hours = hoursString;
        }, 1000);
        
        this.intervalID = timer;
    }

    stopTimer(){
        clearInterval(this.intervalID);
        this.intervalID = null;
    }
    
    toStoreDetail(){
        var customerid = this.visitationPlanDetail.ASI_CRM_MY_Customer__c;
        // var compDefinition = {
        //     componentDef: 'c:asi_CRM_VisitationStoreDetailsLWC',
        //     attributes: {
        //         id: customerid
        //     }
        // };
        // // Base64 encode the compDefinition JS object
        // var encodedCompDef = btoa(JSON.stringify(compDefinition));
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef
        //     }
        // });
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_VisitationStoreDetails_Route"
            },
            state: {
				c__cid: customerid
            }
        });
    }

    toVisitationPrevious(){
        var customerID = this.visitationPlanDetail.ASI_CRM_MY_Customer__c;
        var visitID = this.visitationPlanDetail.Id;
        // var compDefinition = {
        //     componentDef: 'c:asi_CRM_Visitation_PreviousLWC',
        //     attributes: {
        //         customerID: customerID,
        //         visitID: visitID
        //     }
        // };
        // // Base64 encode the compDefinition JS object
        // var encodedCompDef = btoa(JSON.stringify(compDefinition));
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef
        //     }
        // });
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_Visitation_Previous_Route"
            },
            state: {
                c__cid: customerID,
                c__vid: visitID
            }
        });
    }

    toPreviousOrder(){
        var customerID = this.visitationPlanDetail.ASI_CRM_MY_Customer__c;
        // var compDefinition = {
        //     componentDef: 'c:asi_CRM_VisitationPreviousOrdersLWC',
        //     attributes: {
        //         customerID: customerID,
        //     }
        // };
        // // Base64 encode the compDefinition JS object
        // var encodedCompDef = btoa(JSON.stringify(compDefinition));
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef
        //     }
        // });
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_VisitationPreviousOrders_Route"
            },
            state: {
                c__cid: customerID,
            }
        });
    }

    showLock(){
        swal.fire({
            html  :
            `
            <div style="margin-left:auto;margin-right:auto">
            <img src="/resource/ASI_CRM_VisitationPlan_Resource/img/common/icon_lock_d_l.png" style="width:100px;height:125px;"></img>
            </div>
            <div style="margin-left:auto;margin-right:auto;padding-top:20px">
            You may unlock these tasks by tapping "Start Visit".
            </div>
            `,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Confirm'
        }).then((result) => {
            if(result.value) {
            }
        });
    }

    toQVAP(){
        var visitID = this.visitationPlanDetail.Id;
        var StopBool = this.isStopped;
        // var compDefinition = {
        //     componentDef: 'c:asi_CRM_VisitationDetail_QVAPLWC',
        //     attributes: {
        //         visitID: visitID,
        //         isStopped: StopBool
        //     }
        // };
        // // Base64 encode the compDefinition JS object
        // var encodedCompDef = btoa(JSON.stringify(compDefinition));
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef
        //     }
        // });
        
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_VisitationDetail_QVAP_Route"
            },
            state: {
                c__vid: visitID,
                c__is: StopBool
            }
        });
    }

    toRSP(){
        var visitID = this.visitationPlanDetail.Id;
        // var compDefinition = {
        //     componentDef: 'c:asi_CRM_Visitation_RSPLWC',
        //     attributes: {
        //         visitID: visitID
        //     }
        // };
        // // Base64 encode the compDefinition JS object
        // var encodedCompDef = btoa(JSON.stringify(compDefinition));
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef
        //     }
        // });
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_Visitation_RSP_Route"
            },
            state: {
                c__vid: visitID,
            }
        });
    }

    toPlaceOrder(){
        var customerID = this.visitationPlanDetail.ASI_CRM_MY_Customer__c;
        var today = new Date();
        // var compDefinition = {
        //     componentDef: 'c:asi_CRM_VisitationTaskPlaceOrderLWC',
        //     attributes: {
        //         customerID: customerID,
        //         time: today.getTime()
        //     }
        // };
        // // Base64 encode the compDefinition JS object
        // var encodedCompDef = btoa(JSON.stringify(compDefinition));
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef
        //     }
        // });

        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_VisitationTaskPlaceOrder_Route"
            },
            state: {
                c__cid: customerID,
            }
        });
    }

    toEvent(){
        var visitID = this.visitationPlanDetail.Id;
        var custID = this.visitationPlanDetail.ASI_CRM_MY_Customer__c;
        // var compDefinition = {
        //     componentDef: 'c:asi_CRM_VisitationPlanTodayLWC',
        //     attributes: {
        //         visitID: visitID
        //     }
        // };
        // // Base64 encode the compDefinition JS object
        // var encodedCompDef = btoa(JSON.stringify(compDefinition));
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef
        //     }
        // });
        
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_VisitationEventCapture_Route"
            },
            state: {
                c__vid: visitID,
                c__cid: custID,
                c__isStopped: false
            }
        });
    }

    toNote(event){
        //pernod-ricard--asisb10dev.lightning.force.com/lightning/cmp/c__ASI_CRM_VisitationDetail_NewNote_Containner?c__vid=a8k5E0000008bgDQAQ&c__nid=Create%20Note&c__isStopped=false
        var visitID = this.visitationPlanDetail.Id;
        var Node_Id = event.currentTarget.dataset.id;
        var StopBool = this.isStopped;

        // var compDefinition = {
        //     componentDef: 'c:asi_CRM_VisitationDetail_NewNoteLWC',
        //     attributes: {
        //         visitID: visitID,
        //         nodeID: Node_Id,
        //         isStopped: StopBool
        //     }
        // };
        // // Base64 encode the compDefinition JS object
        // var encodedCompDef = btoa(JSON.stringify(compDefinition));
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: '/one/one.app#' + encodedCompDef
        //     }
        // });
        
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ASI_CRM_VisitationDetail_NewNote_Route"
            },
            state: {
                c__vid: visitID,
                c__nid: Node_Id,
            }
        });
    }

    handleUploadFinished(event){
        // This will contain the List of File uploaded data and status        
        //alert("Files uploaded : " + uploadedFiles.length);
        this.refreshPhoto();
              
    }

    refreshPhoto()
    {
        this.isLoaded = false;
        var param = {
            recordId: this.recordId,
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
                        var tempStyle = 'background-repeat: no-repeat;background-position: center center;background-size: cover; background-image: url(/sfc/servlet.shepherd/version/Download/'+this.photoList[i].Id+')';
                        var Style = {
                                    Id: this.photoList[i].Id, 
                                    ContentDocumentId: this.photoList[i].ContentDocumentId,
                                    Style: tempStyle,
                                    index: i+1,
                                    imgurl: '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+this.photoList[i].Id
                                };
                        this.photoStyle.push(Style);
                    }
                    console.log(this.photoStyle);
                }
                
                this.template.querySelector('lightning-tabset').activeTabValue = '4';
                this.isLoaded = true;
            }).catch(error => {
                var errorMessage = (error.body ? error.body.message : error.message);
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
				});
            }); 
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

    deleteDoc()
    {
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
                this.isLoaded = false;
                this.closePreview();

                deletePhoto(param)
                .then(result => {
                    //window.location.reload(true);
                    this.refreshPhoto();
                }).catch(error => {
                    var errorMessage = (error.body ? error.body.message : error.message);
                    Swal.fire({
                    type  : 'error',
                    title : 'Oops...',
                    text  : errorMessage
                    });
                });
                }
        });
        
    }

    Count(){
        this.countNo = this.countNo+1;
    }

}