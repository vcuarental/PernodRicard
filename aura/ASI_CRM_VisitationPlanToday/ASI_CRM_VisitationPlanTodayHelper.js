({
    startTimer : function(cmp,secondDiff) {
        var totalSeconds = secondDiff;
        var timer = setInterval(function() {
            ++totalSeconds;
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
            cmp.set("v.second", secondString);
            cmp.set("v.minutes", minutesString);
            cmp.set("v.hours", hoursString);
        }, 1000);
        
        cmp.set("v.intervalID",timer);
    },
    
    stopTimer : function (cmp) {
        clearInterval(cmp.get("v.intervalID"));
        cmp.set("v.intervalID",null);
    },
    
    updateVisitationTime : function (cmp,actionType) {
        var recordid = cmp.get("v.recordId");
        
        var action = cmp.get("c.updateVisitationTime");
        action.setParams({ "recordId" : recordid,"action" : actionType});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(actionType == 'StartVisit')
                {
                    cmp.set("v.isStarted", true);
                    if(cmp.get("v.intervalID")){
                        clearInterval(cmp.get("v.intervalID"));
                        cmp.set("v.intervalID",null);
                    }
                    this.startTimer(cmp,0);
                }
                else
                {
                    if(actionType == 'CancelVisit')
                    {
                        cmp.set("v.visitationPlanDetail.ASI_HK_CRM_Status__c", 'Cancelled');
                    }
                    else{
                        cmp.set("v.visitationPlanDetail.ASI_HK_CRM_Status__c", 'Achieved');
                    }
                    cmp.set("v.isStopped", true);
                    this.stopTimer(cmp);
                }
                $A.util.addClass(cmp.find('customSpinner'), 'slds-hide');
                
            }
            else {
                console.log('Ryan test error');
                $A.util.addClass(cmp.find('customSpinner'), 'slds-hide');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                }
                
                swal.fire({
                    title: 'Start visit failed',
                    text: "Please contact administrator for the issue.",
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Confirm'
                }).then((result) => {
                    if(result.value) {
                }
                        });
            }
        });
        $A.getCallback(function() {
            $A.enqueueAction(action);
        })();
    },
    
    getPhoto : function(cmp) {		
        var action = cmp.get("c.getPhoto");
        console.log('In helper');
        console.log(cmp.get("v.recordId"));
        action.setParams({ "recordId" : cmp.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Ryan test');
                console.log(response.getReturnValue());
                cmp.set("v.photoList", response.getReturnValue());
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
                    title: 'Get QVAP failed',
                    text: "Please contact administrator for the issue.",
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Confirm'
                }).then((result) => {
                    if(result.value) {
                }
                        });
            }
        });
        $A.enqueueAction(action);
    }
})