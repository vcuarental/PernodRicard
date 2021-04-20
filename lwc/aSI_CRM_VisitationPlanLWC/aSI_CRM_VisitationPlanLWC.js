import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import resource from "@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource";
import getMyCustomCustomerCount from '@salesforce/apex/ASI_CRM_VisitationPlanDetailCtr.getMyCustomCustomerCount';
import getMYCustomCustomerList from '@salesforce/apex/ASI_CRM_VisitationPlanDetailCtr.getMYCustomCustomerList';
import getCustomVisitationPlan from '@salesforce/apex/ASI_CRM_VisitationPlanDetailCtr.getCustomVisitationPlan';
import getMYVisitationPlanRequirement from '@salesforce/apex/ASI_CRM_VisitationPlanDetailCtr.getMYVisitationPlanRequirement';
import saveVisitationPlanDetail from '@salesforce/apex/ASI_CRM_VisitationPlanDetailCtr.saveVisitationPlanDetail';

export default class ASI_CRM_VisitationPlanLWC extends NavigationMixin(LightningElement)  {
	@track hasRendered = false;
	@api recordId;
	@track fullCalendar = {};
	@track functionExecuteStartTime = 0;
	@track functionExecuteEndTime = 0;
	@track isMobileView = false;
	@track isEditable = true;
	@track isFirstSelect = false;
	@track isEnabledDeleteMode = false;
	@track isRecordModified = false;
	@track newRecordPrefix = 'VPD-';
	@track newRecordIndex = 1;
	@track totalPageNo = 10;
	@track pageSize = 20;
	@track pageNo = 1;
	@track visitationPlanDate = '';
	@track visitatcustomerRecordTypeDeveloperNameMapionPlanDate = [];
	@track filterLabel = [];
	@track filterList = [];
	@track getVisitationPlanDetailCallback = {};
	@track getCustomerCallback = {};
	@track getMonthlyPlanningCountCallback = {};
	@track getTotalCustomerCountCallback = {};
	@track saveVisitationPlanDetailCallback = {};
	@track clickVisitationPlanDetailCallback = {};
	@track calendarEventDragCallback = {};
	@track fullCalendarEventList = [];
	@track recordTypeMonthlyPlanningMap = [];
	@track recordTypeMonthlyPlanningList = [];
	@track customerList = [];
	@track titleList = [];
	@track selectedCustomerId = '';
	@track selectedCustomer = {};
	@track newVisitationPlanDetailList = [];
	@track updateVisitationPlanDetailList = [];
	@track removeVisitationPlanDetailIdList = [];
	@track customerList2 = [];
	@track inputPage = 1;

	@api isLoaded = false;

	get isSaveDisable(){
        return (this.isRecordModified == false);
	}
	
	get FirstPageClass(){
		if(this.pageNo == 1)
			return '';
		else 
			return 'hoverable' 
	}

	get LastPageClass(){
		if(this.pageNo == this.totalPageNo)
			return '';
		else 
			return 'hoverable' 
	}

	get isFirstPage(){
		return (this.pageNo <= 1);
	}

	get isLastPage(){
		return (this.pageNo >= this.totalPageNo);
	}

	connectedCallback() {

        // Promise.all([
		// 	loadStyle(this, resource + '/sweetalert2.min.css'),
		// 	loadStyle(this, resource + '/jquery-ui.min.css'),
		// 	loadStyle(this, resource + '/dist/fullcalendar.css'),
		// 	loadScript(this, resource + '/jquery.min.js'),
		// 	loadScript(this, resource + '/jquery-ui.min.js'),
		// 	loadScript(this, resource + '/moment.js'),
		// 	loadScript(this, resource + '/dist/fullcalendar.js'),
		// 	loadScript(this, resource + '/sweetalert2.min.js')
		// ])
		// .then(() => {
		// 	window.addEventListener('onhashchange', this.locationHashChanged);
		// });
	}

	
	renderedCallback()
	{
		if (this.hasRendered)
		{
			return;
		}
		
		this.hasRendered = true;

		Promise.all([
			loadScript(this, resource + '/jquery.min.js'),
			loadScript(this, resource + '/jquery-ui.min.js'),
			loadScript(this, resource + '/moment.js'),
			loadScript(this, resource + '/sweetalert2.min.js'),
			loadScript(this, resource + '/dist/fullcalendar.js'),
			loadStyle(this, resource + '/jquery-ui.min.css'),
			loadStyle(this, resource + '/sweetalert2.min.css'),
			loadStyle(this, resource + '/dist/fullcalendar.css')
		])
		.then(() => {
			window.addEventListener('onhashchange', this.locationHashChanged);
			this.init();
		});
	}

	getQueryParameters() {
        //test URL
		var params = '{}';
		console.log('window: ' + window.location);
        var encodedCompDef = window.location.hash;
        if (encodedCompDef) {
			var decodedstring = encodedCompDef.substring(1).replace(/%3D/g, '=');
            params = atob(decodedstring);
        }
		console.log('param: ' + params);
        return params;
	}
	
	locationHashChanged()
	{
		console.log('hashed change;');
		this.init();
	}
	
	init()
	{
		const ele = this.template.querySelector('div.fullcalendarjs');
		this.fullCalendar = ele;

		var customerRecordTypeMap = {
            'Outlet (MY)'           : 'ASI_CRM_MY_Outlet',
            'Potential Outlet (MY)' : 'ASI_CRM_MY_Potential_Outlet',
            'Wholesaler (MY)'       : 'ASI_CRM_MY_Wholesaler'
        };

		this.customerRecordTypeDeveloperNameMap = customerRecordTypeMap;

		// if(!this.recordId){
		// 	this.parameters = JSON.parse(this.getQueryParameters());
		// 	this.recordId = this.parameters.attributes.id;
		// }
		this.functionExecuteStartTime = new Date().getTime();
		this.getVisitationPlanDetail();
		this.getMonthlyPlanningCount();

		if(this.isEditable) {
        	this.getTotalCustomerCount();
        	this.getCustomerDetail();
		}		
		
        this.functionExecuteEndTime = new Date().getTime();
		this.printPerformanceLog('Init Page Config');
	}

	getTotalCustomerCount(){
		this.isLoaded = false;
        var param = {
            filter: this.filterList
		};
		
        getMyCustomCustomerCount(param)
            .then(result => {
				if (result)
				{
					var totalPageNo = Math.ceil(result / this.pageSize);
                	this.pageNo = 1;
                	this.totalPageNo = totalPageNo;
					//this.getTotalCustomerCountCallback = result;
					this.isLoaded = true;
                }
            }).catch(error => {
                var errorMessage = (error.body ? error.body.message : error.message);
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
				});
				console.log('getMyCustomCustomerCount');
				console.log(error);
			});
	}

	getCustomerDetail(){
		this.isLoaded = false;
		var param = {
			pageSize : this.pageSize,
            pageNo : this.pageNo,
            filter : this.filterList
		};
		
        getMYCustomCustomerList(param)
            .then(result => {
				if (result)
				{
                	this.titleList = result.titleList;
					this.customerList = result.customerList;
					this.customerList2 = [];
					if(this.customerList){
						var listlength = this.customerList.length;
                        for (var i = 0; i < listlength; i++) {
                        var tempClass = 'slds-hint-parent';
                            var tempCustomer = {
                                        customer: this.customerList[i], 
										class: tempClass,
										selected: false
									};
							var cols = tempCustomer.customer.columns;
							var col_length = cols.length;
							for (var j = 0; j < col_length; j++) {
								if(cols[j].objName){
									cols[j].href = '/lightning/r/'+cols[j].objName + '/' + cols[j].value + '/view';
								}
							}
							this.customerList2.push(tempCustomer);
                        }
					}
                	this.filterLabel = result.filterLabel;
                	this.filterList = result.filterList;
        			this.functionExecuteEndTime = new Date().getTime();
        			this.printPerformanceLog('Collect Customer Data From Apex Controll');
                    //this.getCustomerCallback = result;
				}
				this.isLoaded = true;
            }).catch(error => {
				var errorMessage = (error.body ? error.body.message : error.message);
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
				});
				console.log('getMYCustomCustomerList');
				console.log(error);
            });
	}

	getMonthlyPlanningCount(){
		this.isLoaded = false;
		var param = {
			recordTypeDeveloperNameList : Object.values(this.customerRecordTypeDeveloperNameMap)
		};
		
        getMYVisitationPlanRequirement(param)
            .then(result => {
				if (result)
				{                
					var recordTypeMonthlyPlanningMap = {};
					Object.keys(result).forEach(recordType => {
						recordTypeMonthlyPlanningMap[recordType] = {
							'Name'     : recordType,
							'Required' : result[recordType],
							'Planned'  : 0,
							'Diff'     : 0
						};
					});
					this.recordTypeMonthlyPlanningMap = recordTypeMonthlyPlanningMap;
					this.recordTypeMonthlyPlanningList = Object.values(recordTypeMonthlyPlanningMap);
                    //this.getMonthlyPlanningCountCallback = result;
				}
				this.isLoaded = true;
            }).catch(error => {
				var errorMessage = (error.body ? error.body.message : error.message);
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
				});
				console.log('getMYVisitationPlanRequirement');
				console.log(error);
            });
	}

	getVisitationPlanDetail(){
		this.isLoaded = false;
		this.functionExecuteStartTime = new Date().getTime();
		console.log(this.recordId);
		var param = {
			recordId : this.recordId
		};
		
        getCustomVisitationPlan(param)
            .then(result => {
				if (result)
				{   
					this.functionExecuteEndTime = new Date().getTime();
					this.printPerformanceLog("Collect Visitation Plan Data From Apex Controll");
					this.initVisitationPlanDetail(result);
                    //this.getVisitationPlanDetailCallback = result;
				}
				this.isLoaded = true;
            }).catch(error => {
				var errorMessage = (error.body ? error.body.message : error.message);
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
				});
				console.log('getCustomVisitationPlan');
				console.log(error);
            });
	}

	printPerformanceLog(name){
		var functionExecuteStartTime = this.functionExecuteStartTime;
        var functionExecuteEndTime = this.functionExecuteEndTime;
        var timeDiff = (functionExecuteEndTime - functionExecuteStartTime) / 1000;
	}

	initVisitationPlanDetail(result){
		this.functionExecuteStartTime = new Date().getTime();
        
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
        
        var recordTypeMonthlyPlanningMap = this.recordTypeMonthlyPlanningMap;
        result.visitationPlanDetailList.forEach(detail => {
            eventData.push({
            	'id'         : detail.Id,
                'start'      : detail.ASI_HK_CRM_Visit_Date__c,
                'end'        : detail.ASI_HK_CRM_Visit_Date__c,
                'title'      : detail.ASI_CRM_MY_Customer__r.Name, 
            	'customerId' : detail.ASI_CRM_MY_Customer__c,
				'recordType' : detail.ASI_CRM_MY_Customer__r.RecordType.Name,
				'status'     : detail.ASI_HK_CRM_Status__c,
				'color'      : detail.ASI_HK_CRM_Status__c == 'Planned' ? '' : 'grey',
				'editable'   : detail.ASI_HK_CRM_Status__c == 'Planned' ? true : false,
				//'backgroundColor': "rgb(" + Math.floor(Math.random() * 256) + "," + Math.floor(Math.random() * 256) + "," + Math.floor(Math.random() * 256) + ")",
				//'borderColor': "rgb(" + Math.floor(Math.random() * 256) + "," + Math.floor(Math.random() * 256) + "," + Math.floor(Math.random() * 256) + ")"
        	});
        	
        	var monthlyPlanning = recordTypeMonthlyPlanningMap[detail.ASI_CRM_MY_Customer__r.RecordType.Name];
        	if(monthlyPlanning) {
                monthlyPlanning.Planned = (monthlyPlanning.Planned ? monthlyPlanning.Planned : 0) + 1;
                monthlyPlanning.Diff = (monthlyPlanning.Planned ? monthlyPlanning.Planned : 0)
                                     - (monthlyPlanning.Required ? monthlyPlanning.Required : 0);
                recordTypeMonthlyPlanningMap[detail.ASI_CRM_MY_Customer__r.RecordType.Name] = monthlyPlanning;
            }
        });
        
    	this.fullCalendarEventList = eventData;
    	this.visitationPlanDate = visitationPlanDate;
        this.recordTypeMonthlyPlanningMap = recordTypeMonthlyPlanningMap;
        this.recordTypeMonthlyPlanningList = Object.values(recordTypeMonthlyPlanningMap);
		
    	this.initCalendar(eventData, visitationPlanDate);
    
        this.functionExecuteEndTime = new Date().getTime();
        this.printPerformanceLog("Init Calendar Page");
	}

	initCalendar(eventData, visitationPlanDate){
		const ele = this.template.querySelector('div.fullcalendarjs');
		var parent_this = this;
		var toDate = new Date(new Date().toDateString());

		var fullCalendarOptions = {
			header: {
                left   : 'title',
                center : 'customButton4Text',
      			right  : ''
			},
			height                : 550,
            //contentHeight         : 550,
            navLinks              : false, 
            weekNumbers           : false,
            weekNumbersWithinDays : true,
            weekNumberCalculation : 'ISO',
 			showNonCurrentDates   : false,
 			fixedWeekCount        : false,
            editable              : false,
            droppable             : false,
			eventLimit            : true,
			
			eventClick            : function(event, jsEvent, view){
				if(parent_this.isEnabledDeleteMode) {
					var fullCalendarEventList = parent_this.fullCalendarEventList;
					var removeIndex = fullCalendarEventList.findIndex(tmpEvent => tmpEvent.id == event.id);
					
					if(removeIndex != -1) {
						var removeVisitationPlanDetailIdList = parent_this.removeVisitationPlanDetailIdList;
						if(event.id.startsWith(parent_this.newRecordPrefix) == false)
							removeVisitationPlanDetailIdList.push(event.id);
								
						$(ele).fullCalendar('removeEvents', event.id);
						parent_this.removeVisitationPlanDetailIdList = removeVisitationPlanDetailIdList;    
						   
						var newVisitationPlanDetailList = parent_this.newVisitationPlanDetailList;
						var newIndex = newVisitationPlanDetailList.findIndex(visitationPlanDetail => visitationPlanDetail.id == event.id);
			 
						if(newIndex != -1)
							newVisitationPlanDetailList.splice(newIndex, 1);
						
						parent_this.newVisitationPlanDetailList = newVisitationPlanDetailList;
						
						var recordTypeMonthlyPlanningMap = parent_this.recordTypeMonthlyPlanningMap;
						var monthlyPlanning = recordTypeMonthlyPlanningMap[event.recordType];
						if(monthlyPlanning) {
							monthlyPlanning.Planned = (monthlyPlanning.Planned ? monthlyPlanning.Planned : 0) - 1;
							monthlyPlanning.Diff = (monthlyPlanning.Planned ? monthlyPlanning.Planned : 0)
												 - (monthlyPlanning.Required ? monthlyPlanning.Required : 0);
							recordTypeMonthlyPlanningMap[event.recordType] = monthlyPlanning;
								
							parent_this.recordTypeMonthlyPlanningMap = recordTypeMonthlyPlanningMap;
							parent_this.recordTypeMonthlyPlanningList = Object.values(recordTypeMonthlyPlanningMap);
						}
							
						fullCalendarEventList.splice(removeIndex, 1);
						parent_this.fullCalendarEventList = fullCalendarEventList;
						parent_this.isRecordModified = true;
					}
				} else if(event.id && 
						  event.id.startsWith(parent_this.newRecordPrefix) == false) {
					window.open('/lightning/r/ASI_HK_CRM_Visitation_Plan_Detail__c/' + event.id + '/view');
				}
			},
            dayClick : function(selectedDate) {
				selectedDate = selectedDate.format();
				var checkDate = new Date(selectedDate);
				if (parent_this.selectedCustomerId) {
					var selectCustomer = parent_this.selectedCustomer;
					
					var fullCalendarEventList = parent_this.fullCalendarEventList;
					var removeIndex = fullCalendarEventList.findIndex(event => event.start == selectedDate && 
																		event.customerId == selectCustomer.customerRecord.Id);

					if (checkDate < toDate)
					{
						Swal.fire({
							type : 'warning',
							title: 'Oops...',
							html : 'You can only create a visit from today onward.'
						});
					}
					else if (removeIndex == -1) {
						var newEvent = {
							'id'         : parent_this.newRecordPrefix + parent_this.newRecordIndex,
							'start'      : selectedDate,
							'end'        : selectedDate,
							'title'      : selectCustomer.customerRecord.Name, 
							'customerId' : selectCustomer.customerRecord.Id,
							'recordType' : selectCustomer.customerRecord.RecordType.Name,
							'color'      : 'blueviolet',
							'status'     : 'Planned'
						};
						
						$(ele).fullCalendar('renderEvent', newEvent);
						
						var fullCalendarEventList = parent_this.fullCalendarEventList;
						fullCalendarEventList.push(newEvent);
						parent_this.fullCalendarEventList = fullCalendarEventList;
						
						var newVisitationPlanDetailList = parent_this.newVisitationPlanDetailList;
						var newVisitationPlanDetail = {
							'id'                            : newEvent.id,
							'ASI_HK_CRM_Visitation_Plan__c' : parent_this.recordId,
							'ASI_CRM_MY_Customer__c'        : selectCustomer.customerRecord.Id,
							'ASI_HK_CRM_Visit_Date__c'      : selectedDate,
							'sobjectType'                   : 'ASI_HK_CRM_Visitation_Plan_Detail__c',
							'ASI_HK_CRM_Status__c'          : 'Planned'
						};
						newVisitationPlanDetailList.push(newVisitationPlanDetail);
						parent_this.newVisitationPlanDetailList = newVisitationPlanDetailList;
						
						var recordTypeMonthlyPlanningMap = parent_this.recordTypeMonthlyPlanningMap;
						var monthlyPlanning = recordTypeMonthlyPlanningMap[selectCustomer.customerRecord.RecordType.Name];
						if(monthlyPlanning) {
							monthlyPlanning.Planned = (monthlyPlanning.Planned ? monthlyPlanning.Planned : 0) + 1;
							monthlyPlanning.Diff = (monthlyPlanning.Planned ? monthlyPlanning.Planned : 0)
												- (monthlyPlanning.Required ? monthlyPlanning.Required : 0);
							recordTypeMonthlyPlanningMap[selectCustomer.customerRecord.RecordType.Name] = monthlyPlanning;
							parent_this.recordTypeMonthlyPlanningMap = recordTypeMonthlyPlanningMap;
							parent_this.recordTypeMonthlyPlanningList = Object.values(recordTypeMonthlyPlanningMap);
						}
						
						parent_this.newRecordIndex = parent_this.newRecordIndex + 1;  

						parent_this.isRecordModified = true;
					} else {
						Swal.fire({
						type : 'warning',
						title: 'Oops...',
						html : '<b>[' + selectCustomer.customerRecord.Name + ']</b> <br /> is already added to ' + selectedDate + ''
						});
					}
				}
			},
            events                : eventData
		  };
		if (this.isMobileView)
			fullCalendarOptions.header.right = 'month,listDay';
		
			if (this.isEditable) {
			fullCalendarOptions.editable  = true;
            fullCalendarOptions.droppable = true;
			//fullCalendarOptions.eventDrop = this.calendarEventDrag();
			fullCalendarOptions.eventDrop =  function(event, delta, revertFunc, jsEvent, ui, view) {
				var fullCalendarEventList = parent_this.fullCalendarEventList;
				var newDate = event.start.format();

				var removeIndex = fullCalendarEventList.findIndex(ev => 
					ev.id != event.id &&
					ev.start == newDate && 
					ev.customerId == event.customerId);

				if (removeIndex != -1)
				{
					Swal.fire({
						type : 'warning',
						title: 'Oops...',
						html : '<b>[' + event.title + ']</b> <br /> is already added to ' + newDate + ''
					});

					revertFunc();
				}
				else if (event.start < toDate)
				{
					Swal.fire({
						type : 'warning',
						title: 'Oops...',
						html : 'You cannot change the visit\'s start date before today.'
					});

					revertFunc();
				}
				else
				{
					var targetEventList = fullCalendarEventList.filter(tempEvent => event.id == tempEvent.id);
					targetEventList[0].start = newDate;
					targetEventList[0].end   = newDate;
					
					parent_this.fullCalendarEventList = fullCalendarEventList;
					
					if(targetEventList[0].id.startsWith(parent_this.newRecordPrefix)) {
						var newVisitationPlanDetailList = parent_this.newVisitationPlanDetailList;
						var newEventList = newVisitationPlanDetailList.filter(detail => targetEventList[0].id == detail.id);
						newEventList[0].ASI_HK_CRM_Visit_Date__c = newDate;
						parent_this.newVisitationPlanDetailList = newVisitationPlanDetailList;
					} else {
						var updateVisitationPlanDetailList = parent_this.updateVisitationPlanDetailList;
						var updateIndex = updateVisitationPlanDetailList.findIndex(detail => targetEventList[0].id == detail.id);
						
						var updatedVisitationPlanDetail = {};
						updatedVisitationPlanDetail.id = targetEventList[0].id;
						updatedVisitationPlanDetail.ASI_HK_CRM_Visit_Date__c = newDate;
						if(updateIndex == -1) {
							updateVisitationPlanDetailList.push(updatedVisitationPlanDetail);
						} else {
							updateVisitationPlanDetailList.splice(updateIndex, 1, updatedVisitationPlanDetail);
						}
						parent_this.updateVisitationPlanDetailList = updateVisitationPlanDetailList;
					}
					parent_this.isRecordModified = true;
				}
			}
		}
		$(ele).fullCalendar(fullCalendarOptions);
		$(ele).fullCalendar('gotoDate', visitationPlanDate);
		const fcCenter = this.template.querySelector('div.fc-center');
		if(this.isEnabledDeleteMode)
			$(fcCenter).replaceWith('<div class="fc-center">Click on the visit to remove it from the plan</div>');
		else
			$(fcCenter).replaceWith('<div class="fc-center">Please select a customer from the list and click on the calendar to create visit</div>');

      	//this.fullCalendar.fullCalendar(ele);
    	//this.fullCalendar.fullCalendar('gotoDate', visitationPlanDate);
	}

	enableEditMode(){
		var fullCalendarEventList = this.fullCalendarEventList;
        fullCalendarEventList.forEach(eventData => {
			eventData.color = eventData.color == 'grey' ? 'grey' : '';
        });
		this.fullCalendarEventList = fullCalendarEventList;
		$(this.fullCalendar).fullCalendar('destroy');
		this.isEnabledDeleteMode = false;
		//const fcCenter = this.template.querySelector('div.fc-center');
		//$(fcCenter).replaceWith('<div class="fc-center">Please select a customer from the list first</div>');
		this.initCalendar(this.fullCalendarEventList, this.visitationPlanDate);
	}

	enableDeleteMode(){
		this.selectedCustomerId = '';
		this.selectedCustomer = {};
		var listlength = this.customerList2.length;
			for (var i = 0; i < listlength; i++) {
				this.customerList2[i].selected = false;
				this.customerList2[i].class = 'slds-hint-parent';
			}
		var fullCalendarEventList = this.fullCalendarEventList;
        fullCalendarEventList.forEach(eventData => {
			eventData.color = eventData.color == 'grey' ? 'grey' : 'red';
        });
		this.fullCalendarEventList = fullCalendarEventList;
		$(this.fullCalendar).fullCalendar('destroy');
		this.isEnabledDeleteMode = true;
		//const fcCenter = this.template.querySelector('div.fc-center');
        //$(fcCenter).replaceWith('<div class="fc-center">Just click and delete the visits desired</div>');
		this.initCalendar(this.fullCalendarEventList, this.visitationPlanDate);
	}

	backToVisitationPlan(){
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: this.recordId,
				objectApiName: 'ASI_HK_CRM_Visitation_Plan__c',
				actionName: 'view'
			}
		});
	}

	refreshCalendar(){
		this.isRecordModified = false;
        this.selectedCustomer = {};
        this.filterLabel = [];
        this.filterList = [];
		this.pageNo = 1;
		$(this.fullCalendar).fullCalendar('destroy');
        this.functionExecuteStartTime = new Date().getTime();        
        if (this.isEditable) {
			this.customerList = [];
			this.customerList2 = [];
			this.newVisitationPlanDetailList = [];
			this.updateVisitationPlanDetailList = [];
			this.removeVisitationPlanDetailIdList = [];
            this.getTotalCustomerCount();
        	this.getCustomerDetail();
            this.getMonthlyPlanningCount();
        }  
		this.getVisitationPlanDetail();
	}

	howToUse(){
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
	}

	openFilter(){
		var filterLabel = this.filterLabel;
        var filterList = this.filterList;
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
				this.functionExecuteStartTime = new Date().getTime();
				this.selectedCustomerId = '';
				this.selectedCustomer = {};
				this.filterList = result.value;
				this.pageNo = 1;
       	 		
                if (this.isEditable)
                {
					this.customerList = [];
					this.customerList2 = [];
            		this.getTotalCustomerCount();
        			this.getCustomerDetail();
        		}
        	}
		});
	}

	saveRecord() {
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
        		this.functionExecuteStartTime = new Date().getTime();
        		this.saveVisitationPlanDetail();
          	}
        });
	}
	
	saveVisitationPlanDetail(){
		this.isLoaded = false;
		var newVisitationPlanDetailList = JSON.parse(JSON.stringify(this.newVisitationPlanDetailList));
        newVisitationPlanDetailList.forEach(visitationPlanDetailList => {
            delete visitationPlanDetailList.id;
        });

		var param = {
			insertDetailListJson   : JSON.stringify(newVisitationPlanDetailList),
            updateDetailListJson   : JSON.stringify(this.updateVisitationPlanDetailList),
            deleteDetailIdListJson : JSON.stringify(this.removeVisitationPlanDetailIdList)
		};

		saveVisitationPlanDetail(param)
            .then(result => {
				this.functionExecuteEndTime = new Date().getTime();
				this.printPerformanceLog("Save Record");
				Swal.fire({
					type  : 'success',
					title : 'Success',
					text  : 'Records are saved!'
				  }).then((result) => {
					  //$A.get('e.force:refreshView').fire();  
					  this.refreshCalendar();
				  });
				  this.isLoaded = true;
            }).catch(error => {
				var errorMessage = (error.body ? error.body.message : error.message);
                Swal.fire({
                  type  : 'error',
                  title : 'Oops...',
                  text  : errorMessage
				});
				console.log('saveVisitationPlanDetail');
				console.log(error);
            });
	}

	selectCustomer(event){
		var targetId = event.currentTarget.dataset.id;
        var selectedCustomerId = this.selectedCustomerId;
        var fullCalendarEventList = this.fullCalendarEventList;
        
        if(selectedCustomerId == targetId) {
            this.selectedCustomerId = '';
            this.selectedCustomer = {};
            // fullCalendarEventList.forEach(eventData => {
            // 	delete eventData.color;    
            // });
            this.fullCalendarEventList = fullCalendarEventList;
			$(this.fullCalendar).fullCalendar('destroy');
			this.initCalendar(this.fullCalendarEventList, this.visitationPlanDate);

			var listlength = this.customerList2.length;
			for (var i = 0; i < listlength; i++) {
				if(targetId == this.customerList2[i].customer.customerRecord.Id)
				{					
					this.customerList2[i].selected = false;
					this.customerList2[i].class = 'slds-hint-parent';
				}
			}
            return;
		}

        fullCalendarEventList.forEach(eventData => {
			if (eventData.color != 'grey')
			{
				if (eventData.customerId == targetId) {
					eventData.color = "blueviolet";
				} else {
					delete eventData.color;                           
				}
			}
		});
		
        this.fullCalendarEventList = fullCalendarEventList;       
        var customerList = this.customerList;
        var selectedCustomerList = customerList.filter(customer => customer.customerRecord.Id == targetId);
        this.selectedCustomerId = targetId;
		this.selectedCustomer = selectedCustomerList[0];
		$(this.fullCalendar).fullCalendar('destroy');
		this.initCalendar(this.fullCalendarEventList, this.visitationPlanDate); 
		var listlength = this.customerList2.length;
        for (var i = 0; i < listlength; i++) {
			if(targetId == this.customerList2[i].customer.customerRecord.Id)
			{					
				this.customerList2[i].selected = true;
				this.customerList2[i].class = 'selected-row slds-hint-parent';
			}else
			{
				this.customerList2[i].selected = false;
				this.customerList2[i].class = 'slds-hint-parent';
			}
		}
        if(this.isFirstSelect == false) {
            Swal.fire({
            	title             : 'Reminding!',
              	text              : 'Please click calendar date to add visitation!',
              	confirmButtonText : 'OK'
            });
            this.isFirstSelect = true;
        }
	}

	changePage(event){
		//console.log(event.currentTarget.dataset);
		var action = '';
        if(event.currentTarget.dataset)
            action = event.currentTarget.dataset.key;
        
        var currentPageNo = parseInt(this.pageNo);

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
            if (currentPageNo >= this.totalPageNo)
            {
                return;
            }
            
            currentPageNo++;
		}
		else
		{
			currentPageNo = this.inputPage;
		}
        
        if (currentPageNo < 1 || currentPageNo > this.totalPageNo)
        {
            return;
        }
		
		this.pageNo = currentPageNo;
		//console.log(this.pageNo);
        this.getCustomerDetail();
	}

	inputPageNo(event){
		this.inputPage = event.target.value;
	}
}