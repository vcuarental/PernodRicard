({
    getVisitationPlanDetail : function(cmp) {
        cmp.set("v.functionExecuteStartTime", new Date().getTime());
        
        $A.util.removeClass(cmp.find("customSpinner"), 'slds-hide');
        
        let action = cmp.get("c.getCustomVisitationPlan");	        
        action.setParams({
            "recordId" : cmp.get("v.recordId")
        });
        
        action.setCallback(this, cmp.get("v.getVisitationPlanDetailCallback"));
        
        $A.enqueueAction(action);
    },
    
    getTotalCustomerCount : function(cmp) {
        $A.util.removeClass(cmp.find("filterSpinner"), 'slds-hide');
        
        let action = cmp.get("c.getMyCustomCustomerCount");
        
        var params = {
            filter : Object.values(cmp.get("v.filterList"))
        };
        
        action.setParams(params);
        
        action.setCallback(this, cmp.get("v.getTotalCustomerCountCallback"));
        
        $A.getCallback(function() {
			$A.enqueueAction(action);
		})();
    },
    
    getCustomerDetail : function(cmp) {
        $A.util.removeClass(cmp.find("filterSpinner"), 'slds-hide');
        
        let action = cmp.get("c.getMYCustomCustomerList");

        var params = {
            pageSize : cmp.get("v.pageSize"),
            pageNo : cmp.get("v.pageNo"),
            filter : Object.values(cmp.get("v.filterList"))
        };
        
        action.setParams(params);
        action.setCallback(this, cmp.get("v.getCustomerCallback"));
        
        $A.getCallback(function() {
			$A.enqueueAction(action);
		})();
    },
    
    getMonthlyPlanningCount : function(cmp) {
        let action = cmp.get("c.getMYVisitationPlanRequirement");
        
        action.setParams({
            "recordTypeDeveloperNameList" : Object.values(cmp.get("v.customerRecordTypeDeveloperNameMap"))
        });
        
        action.setCallback(this, cmp.get("v.getMonthlyPlanningCountCallback"));
        
        $A.enqueueAction(action);
    },
    
    saveVisitationPlanDetail : function(cmp) {
        $A.util.removeClass(cmp.find("customSpinner"), 'slds-hide');
        
        let action = cmp.get("c.saveVisitationPlanDetail");
        
        var newVisitationPlanDetailList = JSON.parse(JSON.stringify(cmp.get("v.newVisitationPlanDetailList")));
        newVisitationPlanDetailList.forEach(visitationPlanDetailList => {
            delete visitationPlanDetailList.id;
        });
        action.setParams({
            "insertDetailListJson"   : JSON.stringify(newVisitationPlanDetailList),
            "updateDetailListJson"   : JSON.stringify(cmp.get("v.updateVisitationPlanDetailList")),
            "deleteDetailIdListJson" : JSON.stringify(cmp.get("v.removeVisitationPlanDetailIdList"))
        });
        
        action.setCallback(this, cmp.get("v.saveVisitationPlanDetailCallback"));
        
        $A.getCallback(function() {
			$A.enqueueAction(action);
		})();
    },
    
    printPerformanceLog : function(cmp, name) {
        var functionExecuteStartTime = cmp.get("v.functionExecuteStartTime");
        var functionExecuteEndTime = cmp.get("v.functionExecuteEndTime");
        
        var timeDiff = (functionExecuteEndTime - functionExecuteStartTime) / 1000;
        
        console.log("Performance of Action : \n [" + name + "] : \n " + timeDiff + " seconds");
    },
    
    initVisitationPlanDetail : function(cmp, result) {
        cmp.set("v.functionExecuteStartTime", new Date().getTime());
        
        var today       = new Date();
        var isSameMonth = result.visitationPlan.ASI_HK_CRM_Year__c == today.getFullYear() && 
                          result.visitationPlan.ASI_CRM_Month_Number__c == today.getMonth() + 1;
		
        var visitationPlanDate = moment(today);
        if(!isSameMonth) {
        	var year  = result.visitationPlan.ASI_HK_CRM_Year__c
        	var month = result.visitationPlan.ASI_CRM_Month_Number__c.length == 1 
                  ? '0' + result.visitationPlan.ASI_CRM_Month_Number__c
                  : result.visitationPlan.ASI_CRM_Month_Number__c;
        	var day   = '01';
        	visitationPlanDate = moment(year + '-' + month + '-' + day);
        }
        
        var eventData = [];
        
        var recordTypeMonthlyPlanningMap = cmp.get("v.recordTypeMonthlyPlanningMap");
        result.visitationPlanDetailList.forEach(detail => {
            eventData.push({
            	'id'         : detail.Id,
                'start'      : detail.ASI_HK_CRM_Visit_Date__c,
                'end'        : detail.ASI_HK_CRM_Visit_Date__c,
                'title'      : detail.ASI_CRM_MY_Customer__r.Name, 
            	'customerId' : detail.ASI_CRM_MY_Customer__c,
            	'recordType' : detail.ASI_CRM_MY_Customer__r.RecordType.Name
        	});
        	
        	var monthlyPlanning = recordTypeMonthlyPlanningMap[detail.ASI_CRM_MY_Customer__r.RecordType.Name];
        	if(monthlyPlanning) {
                monthlyPlanning.Planned = (monthlyPlanning.Planned ? monthlyPlanning.Planned : 0) + 1;
                monthlyPlanning.Diff = (monthlyPlanning.Planned ? monthlyPlanning.Planned : 0)
                                     - (monthlyPlanning.Required ? monthlyPlanning.Required : 0);
                recordTypeMonthlyPlanningMap[detail.ASI_CRM_MY_Customer__r.RecordType.Name] = monthlyPlanning;
            }
        });
        
    	cmp.set("v.fullCalendarEventList", eventData);
    	cmp.set("v.visitationPlanDate", visitationPlanDate);
        cmp.set("v.recordTypeMonthlyPlanningMap", recordTypeMonthlyPlanningMap);
        cmp.set("v.recordTypeMonthlyPlanningList", Object.values(recordTypeMonthlyPlanningMap));
		
    	this.initCalendar(cmp, eventData, visitationPlanDate);
    
        cmp.set("v.functionExecuteEndTime", new Date().getTime());
        this.printPerformanceLog(cmp, "Init Calendar Page");
	},
    
   	initCalendar : function(cmp, eventData, visitationPlanDate) {
        var fullCalendarOptions = {
        	header: {
                left   : 'title',
                center : 'customButton4Text',
      			right  : ''
            },
            height                : 550,
            contentHeight         : 550,
            editable              : false,
            navLinks              : false, 
            weekNumbers           : false,
            weekNumbersWithinDays : true,
            weekNumberCalculation : 'ISO',
 			showNonCurrentDates   : false,
 			fixedWeekCount        : false,
            editable              : false,
            droppable             : false,
            eventLimit            : true,
            eventClick            : cmp.get("v.clickVisitationPlanDetailCallback"),
            dayClick              : cmp.get("v.clickCalendarDateCallback"),
            events                : eventData
        };
         
        if(cmp.get("v.isMobileView"))
    		fullCalendarOptions.header.right = 'month,listDay';
    	
    	if(cmp.get("v.isEditable")) {
        	fullCalendarOptions.editable  = true;
            fullCalendarOptions.droppable = true;
            fullCalendarOptions.eventDrop = cmp.get("v.calendarEventDragCallback");
    	}
    	
      	cmp.get("v.fullCalendar").fullCalendar(fullCalendarOptions);
    	cmp.get("v.fullCalendar").fullCalendar('gotoDate', visitationPlanDate);
    $('.fc-center').replaceWith('<div class="fc-center">Please select a customer from the list first</div>');
   
    }
})