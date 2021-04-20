({
    init : function(cmp, event, helper) {
        document.title = 'Visitation Detail';
        $A.util.removeClass(cmp.find("customSpinner"), 'slds-hide');
        var myPage = cmp.get("v.pageReference");
        cmp.set("v.recordId",myPage.state.c__id);
        var recordid = cmp.get("v.recordId");
        console.log(recordid);
        var action = cmp.get("c.getVisitationPlanDetail");
        action.setParams({ "recordId" : recordid });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Ryan test');
                console.log(response.getReturnValue().conDocIdSet);
                cmp.set("v.visitationPlanDetail", response.getReturnValue().currentVisitationPlanDetail);
                cmp.set("v.noteList", response.getReturnValue().noteList);
                cmp.set("v.taskSetting", response.getReturnValue().taskSetting);
                cmp.set("v.isQVAP_Done",response.getReturnValue().isQVAP_Done);
                cmp.set("v.isRSP_Done",response.getReturnValue().isRSP_Done);
                cmp.set("v.isIOT_Done",response.getReturnValue().isIOT_Done);
                cmp.set("v.isEvent_Done",response.getReturnValue().isEvent_Done);
                cmp.set("v.isTodayVisit",response.getReturnValue().isToday);
                cmp.set("v.photoList",response.getReturnValue().conVList);
                if(response.getReturnValue().isToday == false 
                   || (response.getReturnValue().currentVisitationPlanDetail.ASI_HK_CRM_Status__c
                       && response.getReturnValue().currentVisitationPlanDetail.ASI_HK_CRM_Status__c != 'Planned'
                       && response.getReturnValue().currentVisitationPlanDetail.ASI_HK_CRM_Status__c != 'Ad-hoc'))
                {
                    cmp.set("v.isStopped",true);
                    if(cmp.get("v.intervalID"))
                    {
                        helper.stopTimer(cmp);
                        cmp.set("v.second", '00');
                        cmp.set("v.minutes", '00');
                        cmp.set("v.hours", '00');
                    }
                }
                else{
                    cmp.set("v.isStopped",false);
                }
                
                
                
                if(response.getReturnValue().currentVisitationPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c && cmp.get("v.isStopped") == false)
                {
                    cmp.set("v.isStarted",true);
                    var startDate = response.getReturnValue().currentVisitationPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c;
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
                    
                    
                    console.log(startDate);
                    console.log(startTotalSeconds);
                    console.log(today);
                    console.log(todayTotalSecond);
                    console.log(today.getTimezoneOffset());

                    if(cmp.get("v.intervalID")){
                        clearInterval(cmp.get("v.intervalID"));
                        cmp.set("v.intervalID",null);
                    }
                    helper.startTimer(cmp,todayTotalSecond - startTotalSeconds);
                    
                }
                else
                {
                    cmp.set("v.isStarted",false);
                    if(cmp.get("v.intervalID")){
                        clearInterval(cmp.get("v.intervalID"));
                        cmp.set("v.intervalID",null);
                    }
                    cmp.set("v.second", '00');
                    cmp.set("v.minutes", '00');
                    cmp.set("v.hours", '00');
                }
                
                
                
                var noteList = response.getReturnValue().noteList;
                
                if(response.getReturnValue().custAddress){
                    cmp.set("v.custAddress", response.getReturnValue().custAddress);
                    cmp.set("v.address", escape(response.getReturnValue().custAddress));
                }
                else if(cmp.get("v.visitationPlanDetail.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s")){
                    cmp.set("v.address",cmp.get("v.visitationPlanDetail.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s") 
                            + "," + cmp.get("v.visitationPlanDetail.ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Longitude__s"));
                }else{
                    cmp.set("v.address",null);
                }
                
                if(response.getReturnValue().custPhone){
                    cmp.set("v.phone",response.getReturnValue().custPhone);
                }else{
                    cmp.set("v.phone",null);
                }
                $A.util.addClass(cmp.find('customSpinner'), 'slds-hide');
                
                
                
            }
            else {
                console.log('Ryan test error');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                }
                swal.fire({
                    title: 'Vistation Detail Loading error',
                    text: errors && errors[0] && errors[0].message ? errors[0].message : "Please contact administrator for the issue.",
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Confirm'
                }).then((result) => {
                    if(result.value) {
                }
                        });
                $A.util.addClass(cmp.find('customSpinner'), 'slds-hide');
            }
        });
        $A.enqueueAction(action);
    },
    
    startVisit : function(cmp, event, helper) {
        swal.fire({
            title: 'Start Visit',
            text: "Are you sure?",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Confirm'
        }).then((result) => {
            if(result.value) {
            helper.updateVisitationTime(cmp,"StartVisit");
            $A.util.removeClass(cmp.find("customSpinner"), 'slds-hide');
        }
                });
        
    },
    
    endVisit : function(cmp, event, helper) {

        var missingTask = '';

        console.log(cmp.get("v.taskSetting").ASI_CRM_QVAP_Required__c );
        console.log(cmp.get("v.isQVAP_Done"));
        if(cmp.get("v.taskSetting").ASI_CRM_QVAP_Required__c == true && cmp.get("v.isQVAP_Done") == false)
        {
            console.log('QVAP');
            missingTask = 'QVAP, ';
        }

        if(cmp.get("v.taskSetting").ASI_CRM_RSP_Required__c == true && cmp.get("v.isRSP_Done") == false)
        {
            missingTask = missingTask + 'RSP,';
        }

        if(cmp.get("v.taskSetting").ASI_CRM_IOT_Required__c == true && cmp.get("v.isIOT_Done") == false)
        {
            missingTask = missingTask + 'Place an order, ';
        }

        if(cmp.get("v.taskSetting").ASI_CRM_Event_Required__c == true && cmp.get("v.isEvent_Done") == false)
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
                helper.updateVisitationTime(cmp,"EndVisit");
                $A.util.removeClass(cmp.find("customSpinner"), 'slds-hide');
            }
                    });
        }
    },
    
    cancelVisit : function(cmp, event, helper) {
        swal.fire({
            title: 'Cancel Visit',
            text: "Are you sure?",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Confirm'
        }).then((result) => {
            if(result.value) {
            helper.updateVisitationTime(cmp,"CancelVisit");
            $A.util.removeClass(cmp.find("customSpinner"), 'slds-hide');
        }
                });
        
    },
    
    showLock : function(cmp, event, helper) {
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
        
    },
    
    toVisitationPrevious : function(cmp, event, helper) {
        var nav = cmp.find("navService");
        var cid = cmp.get("v.visitationPlanDetail.ASI_CRM_MY_Customer__c");
        var vid = cmp.get("v.visitationPlanDetail.Id");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ASI_CRM_Visitation_Previous'
            }, 
            state: {
                c__cid: cid,
                c__vid: vid
            }
        };
        
        nav.navigate(pageReference);
    },
    
    showMap : function(cmp,event,helper){
        var modalBody;
        $A.createComponent("c:ASI_CRM_Visitation_Map",
                           {
                               markersTitle: cmp.get("v.visitationPlanDetail").ASI_CRM_MY_Customer__r.Name,
                               mapMarkers: [{
                                   title: cmp.get("v.visitationPlanDetail").ASI_CRM_MY_Customer__r.Name,
                                   location: {
                                       Latitude: cmp.get("v.visitationPlanDetail").ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s,
                                       Longitude: cmp.get("v.visitationPlanDetail").ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Longitude__s
                                   },
                                   description: cmp.get("v.visitationPlanDetail").ASI_CRM_MY_Customer__r.ASI_CRM_CN_Address__c
                               }],
                               zoomLevel: 15
                           },
                           function (content, status) {
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   var ol = cmp.find('overlayLib');
                                   
                                   cmp.find('overlayLib').showCustomModal({
                                       header: cmp.get("v.visitationPlanDetail").ASI_CRM_MY_Customer__r.Name,
                                       body: modalBody,
                                       showCloseButton: true,
                                       closeCallback: function () {
                                           
                                       }
                                   });
                               }
                           });
    },
    toStoreDetail : function(cmp, event, helper)
    {
        var id = cmp.get("v.visitationPlanDetail.ASI_CRM_MY_Customer__c");
        var nav = cmp.find("navService");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ASI_CRM_VisitationStoreDetails'
            }, 
            state: {
                c__id: id
            }
        };
        
        nav.navigate(pageReference);
    },
    toQVAP : function(cmp, event, helper) {
        var nav = cmp.find("navService");
        var id = cmp.get("v.recordId");
        var isStopped = cmp.get("v.isStopped");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ASI_CRM_VisitationDetail_QVAP'
            }, 
            state: {
                c__id: id,
                c__isStopped: isStopped
            }
        };
        
        nav.navigate(pageReference);
    },
    showPreviousWarning : function(cmp, event, helper) {
        swal.fire({
            html  :
            `
            <div style="margin-left:auto;margin-right:auto">
            <img src="/resource/ASI_CRM_VisitationPlan_Resource/img/common/icon_lock_d_l.png" style="width:100px;height:125px;"></img>
            </div>
            <div style="margin-left:auto;margin-right:auto;padding-top:20px">
            This is previous visitation record.
            </div>
            `,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Confirm'
        }).then((result) => {
            if(result.value) {
        }
                });
        
    },
    
    showEndWarning : function(cmp, event, helper) {
        swal.fire({
            html  :
            `
            <div style="margin-left:auto;margin-right:auto">
            <img src="/resource/ASI_CRM_VisitationPlan_Resource/img/common/icon_lock_d_l.png" style="width:100px;height:125px;"></img>
            </div>
            <div style="margin-left:auto;margin-right:auto;padding-top:20px">
            This visitation is Completeds.
            </div>
            `,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Confirm'
        }).then((result) => {
            if(result.value) {
        }
                });
    },
    toNote : function(cmp, event, helper) {
        
        var nav = cmp.find("navService");
        var vid = cmp.get("v.recordId");
        var nid = event.getSource().get("v.title");
        var isStopped = cmp.get("v.isStopped");
        console.log(vid);
        console.log(nid);
        console.log(isStopped);
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ASI_CRM_VisitationDetail_NewNote'
            }, 
            state: {
                c__vid: vid,
                c__nid: nid,
                c__isStopped: isStopped
            }
        };
        
        nav.navigate(pageReference);
    },
    toRSP : function(cmp, event, helper)
    {
        var id = cmp.get("v.recordId");
        var nav = cmp.find("navService");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ASI_CRM_Visitation_RSP'
            }, 
            state: {
                c__id: id
            }
        };
        
        nav.navigate(pageReference);
    },
    
    toPlaceOrder : function(cmp, event, helper) {
        var nav = cmp.find("navService");
        var cid = cmp.get("v.visitationPlanDetail.ASI_CRM_MY_Customer__c");
        var today = new Date();
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ASI_CRM_VisitationTaskPlaceOrder'
            }, 
            state: {
                c__id: cid,
                c__time: today.getTime()
            }
        }
        nav.navigate(pageReference);
    },
    handleUploadFinished: function (cmp, event,helper) {
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        
        alert("Files uploaded : " + uploadedFiles.length);
        helper.getPhoto(cmp);
        
    },
    toPreviousOrder : function(cmp, event, helper) {
        var nav = cmp.find("navService");
        var cid = cmp.get("v.visitationPlanDetail.ASI_CRM_MY_Customer__c");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ASI_CRM_VisitationPreviousOrders'
            }, 
            state: {
                c__id: cid
            }
        }
        nav.navigate(pageReference);
    },
    showQVAP : function(cmp,event,helper){
        var modalBody;
        $A.createComponent("c:ASI_CRM_VisitationDetail_QVAP",
                           {
                               recordId: cmp.get("v.recordId"),
                               isStopped: cmp.get("v.isStopped")
                           },
                           function (content, status) {
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   var ol = cmp.find('overlayLib');
                                   
                                   cmp.find('overlayLib').showCustomModal({
                                       header: 'QVAP',
                                       body: modalBody,
                                       showCloseButton: true,
                                       closeCallback: function () {
                                           
                                       }
                                   });
                               }
                           });
    },
    openPhoto : function(cmp,event){
        var contentDocumentIdList = []; 
        cmp.get("v.photoList").forEach(element => {
            console.log(element);
            contentDocumentIdList.push(element.ContentDocumentId);
        });
        console.log(contentDocumentIdList);
        console.log(event.getSource().get("v.title"));
        $A.get('e.lightning:openFiles').fire({
            recordIds: contentDocumentIdList,
            selectedRecordId: event.getSource().get("v.title")
		});
    },
    handleOpenFiles: function(cmp, event, helper) {
		alert('Opening files: ' + event.getParam('recordIds').join(', ')
			+ ', selected file is ' + event.getParam('selectedRecordId'));
    },
    toEvent : function(cmp, event, helper) {
        var nav = cmp.find("navService");
        var vid = cmp.get("v.recordId");
        var cid = cmp.get("v.visitationPlanDetail.ASI_CRM_MY_Customer__c");
        var isStopped = cmp.get("v.isStopped");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ASI_CRM_VisitationEventCapture'
            }, 
            state: {
                c__vid: vid,
                c__cid: cid,
                c__isStopped: isStopped
            }
        };
        
        nav.navigate(pageReference);
    }
})