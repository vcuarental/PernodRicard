({
    init : function(cmp, event, helper) {
        cmp.set("v.functionExecuteStartTime", new Date().getTime());
        var getVisitationPlanDetailCallback = function(response) {
            let state = response.getState();
            if(state =='SUCCESS') {
                let result = response.getReturnValue();
                
        		cmp.set("v.functionExecuteEndTime", new Date().getTime());
        		helper.printPerformanceLog(cmp, "Collect Visitation Plan Data From Apex Controll");
                
                helper.initVisitationPlanDetail(cmp, result);
            } else {
                var errors = response.getError();
                
                var errorMessage = '';
                
                if(errors[0] && errors[0].pageErrors && errors[0].pageErrors.length > 0)
                    errors[0].pageErrors.forEach(error => {
                        errorMessage += error.message + "\n";
                    })
                else 
                    errorMessage = 'Something went wrong!';
                
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
                });
            }
            
        	$A.util.addClass(cmp.find('customSpinner'), 'slds-hide');
        };
        
        var getCustomerCallback = function(response) {
            let state = response.getState();
            if(state =='SUCCESS') {
                let result = response.getReturnValue();

                cmp.set("v.titleList", result.titleList);
                cmp.set("v.customerList", result.customerList);
                cmp.set("v.filterLabel", result.filterLabel);
                cmp.set("v.filterList", result.filterList);
        		cmp.set("v.functionExecuteEndTime", new Date().getTime());
        		helper.printPerformanceLog(cmp, "Collect Customer Data From Apex Controll");
            } else {
                var errors = response.getError();
                
                var errorMessage = '';
                
                if(errors[0] && errors[0].message)    
                    errorMessage += errors[0].message;
                else if(errors[0] && errors[0].pageErrors && errors[0].pageErrors.length > 0)
                    errors[0].pageErrors.forEach(error => {
                        errorMessage += error.message + "\n";
                    })
                else 
                    errorMessage = 'Something went wrong!';
                
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
                });
            }
            
        	$A.util.addClass(cmp.find('filterSpinner'), 'slds-hide');
        };
        
        var getTotalCustomerCountCallback = function(response) {
            let state = response.getState();
            if(state =='SUCCESS') {
                let result = response.getReturnValue();

                var totalPageNo = Math.ceil(result / cmp.get("v.pageSize"));
                
                cmp.set("v.pageNo", 1);
                cmp.set("v.totalPageNo", totalPageNo);
            } else {
                var errors = response.getError();
                
                var errorMessage = '';
                
                if(errors[0] && errors[0].message)    
                    errorMessage += errors[0].message;
                else if(errors[0] && errors[0].pageErrors && errors[0].pageErrors.length > 0)
                    errors[0].pageErrors.forEach(error => {
                        errorMessage += error.message + "\n";
                    })
                else 
                    errorMessage = 'Something went wrong!';
                
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
                });
            }
            
        	$A.util.addClass(cmp.find('filterSpinner'), 'slds-hide');  
        };
        
        var getMonthlyPlanningCountCallback = function(response) {
            let state = response.getState();
            if(state =='SUCCESS') {
                let result = response.getReturnValue();
                
                var recordTypeMonthlyPlanningMap = {};
                Object.keys(result).forEach(recordType => {
                    recordTypeMonthlyPlanningMap[recordType] = {
                        'Name'     : recordType,
                        'Required' : result[recordType],
                        'Planned'  : 0,
                        'Diff'     : 0
                    };
                });
                
        		cmp.set("v.recordTypeMonthlyPlanningMap", recordTypeMonthlyPlanningMap);
        		cmp.set("v.recordTypeMonthlyPlanningList", Object.values(recordTypeMonthlyPlanningMap));
            } else {
                var errors = response.getError();
                
                var errorMessage = '';
                
                if(errors[0] && errors[0].message)    
                    errorMessage += errors[0].message;
                else if(errors[0] && errors[0].pageErrors && errors[0].pageErrors.length > 0)
                    errors[0].pageErrors.forEach(error => {
                        errorMessage += error.message + "\n";
                    })
                else 
                    errorMessage = 'Something went wrong!';
                
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
                });
            }
        };
        
        var saveVisitationPlanDetailCallback = $A.getCallback(function(response) {
            let state = response.getState();
            if(state =='SUCCESS') {
                let result = response.getReturnValue();
                Swal.fire({
                  type  : 'success',
                  title : 'Success',
                  text  : 'Records are saved!'
                }).then((result) => {
        			//$A.get('e.force:refreshView').fire();  
                    window.location.reload(true);
                });
                    
                cmp.set("v.functionExecuteEndTime", new Date().getTime());
        		helper.printPerformanceLog(cmp, "Save Record");    
            } else {
                var errors = response.getError();
                
                var errorMessage = '';
                
                console.log(errors);    
                
                if(errors[0] && errors[0].message)    
                    errorMessage += errors[0].message;
                else if(errors[0] && errors[0].pageErrors && errors[0].pageErrors.length > 0)
                    errors[0].pageErrors.forEach(error => {
                        errorMessage += error.message + "\n";
                    })
                else 
                    errorMessage = 'Something went wrong!';
                
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
                });
            }
            
        	$A.util.addClass(cmp.find('customSpinner'), 'slds-hide');
        });
        
        var clickVisitationPlanDetailCallback = function(event, jsEvent, view) {
            if(cmp.get("v.isEnabledDeleteMode")) {
                var fullCalendarEventList = cmp.get("v.fullCalendarEventList");
                var removeIndex = fullCalendarEventList.findIndex(tmpEvent => tmpEvent.id == event.id);
                
                if(removeIndex != -1) {
                    var removeVisitationPlanDetailIdList = cmp.get("v.removeVisitationPlanDetailIdList");
                    if(event.id.startsWith(cmp.get("v.newRecordPrefix")) == false)
                        removeVisitationPlanDetailIdList.push(event.id);
                            
                    cmp.get("v.fullCalendar").fullCalendar('removeEvents', event.id);
                    cmp.set("v.removeVisitationPlanDetailIdList", removeVisitationPlanDetailIdList);    
                   	
                    var newVisitationPlanDetailList = cmp.get("v.newVisitationPlanDetailList");
                    var newIndex = newVisitationPlanDetailList.findIndex(visitationPlanDetail => visitationPlanDetail.id == event.id);
         
                    if(newIndex != -1)
                        newVisitationPlanDetailList.splice(newIndex, 1);
                    
                    cmp.set("v.newVisitationPlanDetailList", newVisitationPlanDetailList);
                    
                    var recordTypeMonthlyPlanningMap = cmp.get("v.recordTypeMonthlyPlanningMap");
                    var monthlyPlanning = recordTypeMonthlyPlanningMap[event.recordType];
                    if(monthlyPlanning) {
                        monthlyPlanning.Planned = (monthlyPlanning.Planned ? monthlyPlanning.Planned : 0) - 1;
                        monthlyPlanning.Diff = (monthlyPlanning.Planned ? monthlyPlanning.Planned : 0)
                                             - (monthlyPlanning.Required ? monthlyPlanning.Required : 0);
                        recordTypeMonthlyPlanningMap[event.recordType] = monthlyPlanning;
                            
                        cmp.set("v.recordTypeMonthlyPlanningMap", recordTypeMonthlyPlanningMap);
                        cmp.set("v.recordTypeMonthlyPlanningList", Object.values(recordTypeMonthlyPlanningMap));
                    }
                        
                    fullCalendarEventList.splice(removeIndex, 1);
                    cmp.set("v.fullCalendarEventList", fullCalendarEventList);
                    
        			cmp.set("v.isRecordModified", true);
                }
            } else if(event.id && 
                      event.id.startsWith(cmp.get("v.newRecordPrefix")) == false) {
            	window.open('/lightning/r/ASI_HK_CRM_Visitation_Plan_Detail__c/' + event.id + '/view');
            }
        };
        
        var clickCalendarDateCallback = function(selectedDate) {
            selectedDate = selectedDate.format();
            
            if(cmp.get("v.selectedCustomerId")) {
                var selectCustomer = cmp.get("v.selectedCustomer");
                
                var fullCalendarEventList = cmp.get("v.fullCalendarEventList");
                var removeIndex = fullCalendarEventList.findIndex(event => event.start == selectedDate && 
                                             						event.customerId == selectCustomer.customerRecord.Id);
                
                if(removeIndex == -1) {
                    var newEvent = {
                        'id'         : cmp.get("v.newRecordPrefix") + cmp.get("v.newRecordIndex"),
                        'start'      : selectedDate,
                        'end'        : selectedDate,
                        'title'      : selectCustomer.customerRecord.Name, 
                        'customerId' : selectCustomer.customerRecord.Id,
                        'recordType' : selectCustomer.customerRecord.RecordType.Name,
                        'color'      : 'blueviolet'
                    };
                    
                    cmp.get("v.fullCalendar").fullCalendar('renderEvent', newEvent);
                    
                    var fullCalendarEventList = cmp.get("v.fullCalendarEventList");
                    fullCalendarEventList.push(newEvent);
                    cmp.set("v.fullCalendarEventList", fullCalendarEventList);
                    
                    var newVisitationPlanDetailList = cmp.get("v.newVisitationPlanDetailList");
                    var newVisitationPlanDetail = {
                        'id'                            : newEvent.id,
                        'ASI_HK_CRM_Visitation_Plan__c' : cmp.get("v.recordId"),
                        'ASI_CRM_MY_Customer__c'        : selectCustomer.customerRecord.Id,
                        'ASI_HK_CRM_Visit_Date__c'      : selectedDate,
                        'sobjectType'                   : 'ASI_HK_CRM_Visitation_Plan_Detail__c',
                        'ASI_HK_CRM_Status__c'          : 'Planned'
                    };
                    newVisitationPlanDetailList.push(newVisitationPlanDetail);
                    cmp.set("v.newVisitationPlanDetailList", newVisitationPlanDetailList);
                    
                    var recordTypeMonthlyPlanningMap = cmp.get("v.recordTypeMonthlyPlanningMap");
                    var monthlyPlanning = recordTypeMonthlyPlanningMap[selectCustomer.customerRecord.RecordType.Name];
                    if(monthlyPlanning) {
                        monthlyPlanning.Planned = (monthlyPlanning.Planned ? monthlyPlanning.Planned : 0) + 1;
                        monthlyPlanning.Diff = (monthlyPlanning.Planned ? monthlyPlanning.Planned : 0)
                                             - (monthlyPlanning.Required ? monthlyPlanning.Required : 0);
                    	recordTypeMonthlyPlanningMap[selectCustomer.customerRecord.RecordType.Name] = monthlyPlanning;
                    	cmp.set("v.recordTypeMonthlyPlanningMap", recordTypeMonthlyPlanningMap);
        				cmp.set("v.recordTypeMonthlyPlanningList", Object.values(recordTypeMonthlyPlanningMap));
                    }
                    
                    cmp.set("v.newRecordIndex", cmp.get("v.newRecordIndex") + 1);  
                    
        			cmp.set("v.isRecordModified", true);
                } else {
                    Swal.fire({
                      type : 'warning',
                      title: 'Oops...',
                      html : '<b>[' + selectCustomer.customerRecord.Name + ']</b> <br /> is already added to ' + selectedDate + ''
                    });
                }
            }
        };
        
        var calendarEventDragCallback = function(event, delta, revertFunc, jsEvent, ui, view) {
            var fullCalendarEventList = cmp.get("v.fullCalendarEventList");
            
            var newDate = event.start.format();
            
            var targetEventList = fullCalendarEventList.filter(tempEvent => event.id == tempEvent.id);
            targetEventList[0].start = newDate;
            targetEventList[0].end   = newDate;
            
            cmp.set("v.fullCalendarEventList", fullCalendarEventList);
            
            if(targetEventList[0].id.startsWith(cmp.get("v.newRecordPrefix"))) {
                var newVisitationPlanDetailList = cmp.get("v.newVisitationPlanDetailList");
                var newEventList = newVisitationPlanDetailList.filter(detail => targetEventList[0].id == detail.id);
                newEventList[0].ASI_HK_CRM_Visit_Date__c = newDate;
                cmp.set("v.newVisitationPlanDetailList", newVisitationPlanDetailList);
            } else {
                var updateVisitationPlanDetailList = cmp.get("v.updateVisitationPlanDetailList");
                var updateIndex = updateVisitationPlanDetailList.findIndex(detail => targetEventList[0].id == detail.id);
                
                var updatedVisitationPlanDetail = {};
                updatedVisitationPlanDetail.id = targetEventList[0].id;
                updatedVisitationPlanDetail.ASI_HK_CRM_Visit_Date__c = newDate;
                if(updateIndex == -1) {
                    updateVisitationPlanDetailList.push(updatedVisitationPlanDetail);
                } else {
                    updateVisitationPlanDetailList.splice(updateIndex, 1, updatedVisitationPlanDetail);
                }
                cmp.set("v.updateVisitationPlanDetailList", updateVisitationPlanDetailList);
            }
            
            cmp.set("v.isRecordModified", true);
        }
        
        var customerRecordTypeDeveloperNameMap = {
            'Outlet (MY)'           : 'ASI_CRM_MY_Outlet',
            'Potential Outlet (MY)' : 'ASI_CRM_MY_Potential_Outlet',
            'Wholesaler (MY)'       : 'ASI_CRM_MY_Wholesaler'
        };
        
        //Config Callback Attribute 
        cmp.set("v.getVisitationPlanDetailCallback", getVisitationPlanDetailCallback);
        cmp.set("v.getCustomerCallback", getCustomerCallback);
        cmp.set("v.getTotalCustomerCountCallback", getTotalCustomerCountCallback);
        cmp.set("v.getMonthlyPlanningCountCallback", getMonthlyPlanningCountCallback);
        cmp.set("v.saveVisitationPlanDetailCallback", saveVisitationPlanDetailCallback);
        cmp.set("v.clickVisitationPlanDetailCallback", clickVisitationPlanDetailCallback);
        cmp.set("v.clickCalendarDateCallback", clickCalendarDateCallback);
        cmp.set("v.calendarEventDragCallback", calendarEventDragCallback);
		
        //Config Filter Attribute
        cmp.set("v.customerRecordTypeDeveloperNameMap", customerRecordTypeDeveloperNameMap);
        
        cmp.set("v.functionExecuteEndTime", new Date().getTime());
        helper.printPerformanceLog(cmp, "Init Page Config");
    },
    
    scriptsLoaded : function(cmp, event, helper) {
        cmp.set("v.fullCalendar", $('.calendar'));
        
        if(!cmp.get("v.recordId")) {
        	var myPageRef = cmp.get("v.pageReference");
        	cmp.set("v.recordId", myPageRef.state.c__id);
        }
		
        cmp.set("v.functionExecuteStartTime", new Date().getTime());
            
        if(cmp.get("v.isEditable")) {
        	helper.getTotalCustomerCount(cmp);
        	helper.getCustomerDetail(cmp);
        }
        
        helper.getMonthlyPlanningCount(cmp);
     	helper.getVisitationPlanDetail(cmp);
	},
    
    openFilter : function(cmp, event, helper) {
        var filterLabel = cmp.get("v.filterLabel");
        var filterList = cmp.get("v.filterList");
        var html = '';

        for (var i = 0; i < filterLabel.length; i++)
        {
            var label = filterLabel[i];
            var filter = filterList[i];

            html += ('<label class="slds-form-element__label">Filter by ' + label + '</label>');
            html += ('<div class="slds-form-element__control slds-p-bottom_large"><input id="filter' + i + '" class="slds-input" value="' + filter + '" /></div>');
        }
        Swal.fire({
        	title : 'Filter Customer and Visitation Plan Detail',
          	html  : html,
          	focusConfirm       : false,
			showCancelButton   : true,
			confirmButtonColor : '#3085d6',
			cancelButtonColor  : '#d33',
			confirmButtonText  : 'Search',
          	preConfirm   : () => {
                var filterArr = [];

                for (var i = 0; i < filterList.length; i++)
                {
                    filterArr.push(document.getElementById('filter' + i).value);
                }

                return filterArr;
          	}
        }).then((result) => {
            if (result.value)
            {
        		cmp.set("v.functionExecuteStartTime", new Date().getTime());	
       	 		cmp.set("v.selectedCustomerId", "");
                cmp.set("v.selectedCustomer", {});
                cmp.set("v.filterList", result.value);
                cmp.set("v.pageNo", 1);
                
                if (cmp.get("v.isEditable"))
                {
            		cmp.set("v.customerList", []);
            		helper.getTotalCustomerCount(cmp);
        			helper.getCustomerDetail(cmp);
        		}
        	}
        });
    },
    
    refreshCalendar : function(cmp, event, helper) {
        cmp.set("v.isRecordModified", false);
        cmp.set("v.selectedCustomerId", "");
        cmp.set("v.selectedCustomer", {});
        cmp.set("v.filterLabel", []);
        cmp.set("v.filterList", []);
        
        cmp.set("v.pageNo", 1);
        cmp.get("v.fullCalendar").fullCalendar('destroy');
        
       	cmp.set("v.functionExecuteStartTime", new Date().getTime());
        
        if (cmp.get("v.isEditable")) {
            cmp.set("v.customerList", []);
            helper.getTotalCustomerCount(cmp);
        	helper.getCustomerDetail(cmp);
            helper.getMonthlyPlanningCount(cmp);
        }
        
     	helper.getVisitationPlanDetail(cmp);
    },

    saveRecord : function(cmp, event, helper) {
        Swal.fire({
              title               : "Save Record",
              text                : "Are you sure to save record?",
              type                : 'warning',
              showCancelButton    : true,
              confirmButtonColor  : '#3085d6',
              cancelButtonColor   : '#d33',
              confirmButtonText   : 'Confirm'
        }).then((result) => {
        	if (result.value) {
        		cmp.set("v.functionExecuteStartTime", new Date().getTime());
        		helper.saveVisitationPlanDetail(cmp);
          	}
        });
    },
    
    enableDeleteMode : function(cmp, event, helper) {
        cmp.set("v.selectedCustomerId", "");
        cmp.set("v.selectedCustomer", {});
        
        var fullCalendarEventList = cmp.get("v.fullCalendarEventList");
        fullCalendarEventList.forEach(eventData => {
        	delete eventData.color;     
        });
        
        cmp.set("v.fullCalendarEventList", fullCalendarEventList);
        
        cmp.get("v.fullCalendar").fullCalendar('destroy');
        helper.initCalendar(cmp, cmp.get("v.fullCalendarEventList"), cmp.get("v.visitationPlanDate"));
        $('.fc-center').replaceWith('<div class="fc-center">Just click and delete the visits desired</div>');
    	cmp.set("v.isEnabledDeleteMode", true);  
    },
    
    enableEditMode : function(cmp, event, helper) {
        $('.fc-center').replaceWith('<div class="fc-center">Please select a customer from the list first</div>');
        cmp.set("v.isEnabledDeleteMode", false);
    },
    
    backToVisitationPlan : function(cmp, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": cmp.get("v.recordId")
        });
        navEvt.fire();
    },
    
    selectCustomer : function(cmp, event, helper) {
        var targetId = event.currentTarget.dataset.value;
        var selectedCustomerId = cmp.get("v.selectedCustomerId");
        var fullCalendarEventList = cmp.get("v.fullCalendarEventList");
        
        if(selectedCustomerId == targetId) {
            cmp.set("v.selectedCustomerId", "");
            cmp.set("v.selectedCustomer", {});
            
            fullCalendarEventList.forEach(eventData => {
            	delete eventData.color;    
            });
            
            cmp.set("v.fullCalendarEventList", fullCalendarEventList);
            
        	cmp.get("v.fullCalendar").fullCalendar('destroy');
        	helper.initCalendar(cmp, cmp.get("v.fullCalendarEventList"), cmp.get("v.visitationPlanDate"));
            
            return;
        }
        
        fullCalendarEventList.forEach(eventData => {
            if(eventData.customerId == targetId) {
            	eventData.color = "blueviolet";
        	} else {
            	delete eventData.color;                           
            }
        });
        
        cmp.set("v.fullCalendarEventList", fullCalendarEventList);
        
        cmp.get("v.fullCalendar").fullCalendar('destroy');
        helper.initCalendar(cmp, cmp.get("v.fullCalendarEventList"), cmp.get("v.visitationPlanDate"));
        
        var customerList = cmp.get("v.customerList");
        var selectedCustomerList = customerList.filter(customer => customer.customerRecord.Id == targetId);
        cmp.set("v.selectedCustomerId", targetId);
        cmp.set("v.selectedCustomer", selectedCustomerList[0]);
        
        if(cmp.get("v.isFirstSelect") == false) {
            Swal.fire({
            	title             : 'Reminding!',
              	text              : 'Please click calendar date to add visitation!',
              	confirmButtonText : 'OK'
            });
            
            cmp.set("v.isFirstSelect", true);
        }
        
    },
    
    changePage : function(cmp, event, helper) {
        var action = '';
        if(event.currentTarget.dataset)
            action = event.currentTarget.dataset.key;
        
        var currentPageNo = parseInt(cmp.get("v.pageNo"));

        if (action && action == 'back')
        {
            if (currentPageNo <= 1)
            {
                return;
            }
                
            currentPageNo--;
        }
        else if(action && action == 'next')
        {
            if (currentPageNo >= cmp.get("v.totalPageNo"))
            {
                return;
            }
            
            currentPageNo++;
        }
        
        if (currentPageNo < 1 || currentPageNo > cmp.get("v.totalPageNo"))
        {
            return;
        }
        
        cmp.set("v.pageNo", currentPageNo);
        helper.getCustomerDetail(cmp);
    },
        
        howToUse : function(cmp,event,helper) {
            Swal.fire({
                title : 'How To Use',
                html  :
                `
                <div style="text-align: left;font-size: 15px;">
                Step 01 : Pick a customer from the left
                <br></br>
                Step 02 : Select the date to visit from the calendar on the right
                *Meanwhile, you can still click on the visit to see its details
                <br></br>
                You can select multiple dates on the calendar for multiple vistis
                
                </div>
                
                `,
                confirmButtonColor : '#3085d6',
                cancelButtonColor  : '#d33',
            })
        },

        ReloadPage : function(cmp){
            window.location.reload(true);
        }
})