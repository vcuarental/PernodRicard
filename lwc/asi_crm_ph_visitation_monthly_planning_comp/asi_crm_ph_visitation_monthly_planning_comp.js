/* eslint-disable no-dupe-keys */
/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
import { LightningElement, track, api } from 'lwc';

//Import Toast Library
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Import Load Style Library
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

//Import Apex Class Function
import getCustomVisitationPlan from '@salesforce/apex/ASI_CRM_VisitationPlanCtrl.getCustomVisitationPlan';
import getCustomCustomerCount from '@salesforce/apex/ASI_CRM_VisitationPlanCtrl.getPHCustomCustomerCount';
import getCustomCustomerList from '@salesforce/apex/ASI_CRM_VisitationPlanCtrl.getPHCustomCustomerList';
import saveVisitationPlanDetail from '@salesforce/apex/ASI_CRM_VisitationPlanCtrl.savePHVisitationPlanDetail';

//Import Static Resource
import ASI_CRM_PH_FullCalendar from '@salesforce/resourceUrl/ASI_CRM_PH_FullCalendar';

export default class ASI_CRM_MY_Visitation_Monthly_Planning_Comp extends LightningElement {

    @api recordId;
    @api isReadOnly;

    //Data Parameter
    @track visitationPlanDate;
    @track fullCalendarEventList = [];
    @track customerList          = [];
    
    selectedCustomer;
    selectedCustomerId;

    //New Data Parameter
    newVisitationPlanDetailList      = [];
    updateVisitationPlanDetailList   = [];
    removeVisitationPlanDetailIdList = [];

    //Filter Parameter
    customerName = null;
    isOwned      = false;

    //Display Control Parameter
    @track isDeleteMode = false;
    @track showSpinner  = false;
    @track isOpenFilter = false;
    @track isMobile     = false;

    fullCalendarEle;
    libraryInitialized = false;

    @track message = "Loading...";

    //Customer Filter Parameter

    //Page Config Parameter
    newRecordPrefix = "VPD-";
    newRecordIndex  = 1;

    //DataTable Config Parameter
    @track mode = "VIEW";

    @track fieldList = [
        {
            'id'         : 'Name',
            'title'      : 'Name',
            'type'       : 'id',
            'editable'   : false,
            'configObj'  : {
                'objectName' : 'ASI_HK_CRM_Visitation_Plan_Detail__c'
            }
        },
        {
            'id'                    : 'OwnerId',
            'title'                 : 'Owner Name',
            'type'                  : 'lookup',
            'editable'              : false,
            'lookupFieldId'         : 'Owner',
            'lookupFieldLabelField' : 'Name',
            'configObj'             : {
                'label'                  : '',
                'iconName'               : 'standard:account',
                'placeholder'            : 'Input Owner Name',
                'objectName'             : 'User',
                'labelField'             : 'Name',
                'sublabelField'          : '',
                'filterFieldList'        : ['Name'],
                'additionalFilterString' : '',
                'recordCount'            : 5,
                'isTriggerEvent'         : true
            }
        },
        {
            'id'         : 'ASI_CRM_SG_Area__c',
            'title'      : 'Area',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'ASI_CRM_VN_Channel__c',
            'title'      : 'Channel',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'ASI_CRM_JP_City_Ward__c',
            'title'      : 'Address Line 1',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'ASI_CRM_JP_Town__c',
            'title'      : 'Address Line 2',
            'type'       : 'text',
            'editable'   : false
        },
        {
            'id'         : 'RecordType.Name',
            'title'      : 'Record Type',
            'type'       : 'text',
            'editable'   : false
        }
    ];

    @track paginationConfig = {
        'pageNo'    : 1,
        'pageSize'  : 10,
        'totalPage' : 10
    };

    @track componentConfig = {
        'allowView'       : false,
        'allowSelect'     : true,
        'allowEdit'       : false,
        'allowClone'      : false,
        'allowDelete'     : false,
        'allowPagination' : true,
        'allowResponsive' : true
    };

    @track componentStyleClass = {
        'tableStyleClass' : '',
        'theadStyleClass' : '',
        'tbodyStyleClass' : '',
        'tfootStyleClass' : '',
        'textStyleClass'  : ''
    };

    @track componentCallback = {
        'recordFieldUpdateCallback' : null,
        'viewRecordCallback'        : null,
        'selectRecordCallback'      : this.onSelectRecordCallback.bind(this),
        'cloneRecordCallback'       : null,
        'deleteRecordCallback'      : null,
        'pageChangeCallback'        : this.onPageChange.bind(this)
    };

    /*************
    Getter Function
    *************/
    get isEditable() {
        return !this.isMobile && !this.isReadOnly;
    }

    /*************
    Standard Function
    *************/
    connectedCallback() {
        this.isMobile = this.checkMobileUserAgent();

        if(this.isMobile === true)
            this.isReadOnly = true;
    }

    renderedCallback() {
        if (this.libraryInitialized)
            return;
            
        this.libraryInitialized = true;

        Promise.all([
            loadScript(this, ASI_CRM_PH_FullCalendar + '/jquery.min.js'),
            loadScript(this, ASI_CRM_PH_FullCalendar + '/jquery-ui.min.js'),
            loadScript(this, ASI_CRM_PH_FullCalendar + '/moment.js'),
            loadScript(this, ASI_CRM_PH_FullCalendar + '/dist/fullcalendar.js'),
    
            loadStyle(this, ASI_CRM_PH_FullCalendar + '/jquery-ui.min.css'),
            loadStyle(this, ASI_CRM_PH_FullCalendar + '/dist/fullcalendar.css'),
        ]).then(() => {
            this.initializeLibrary();
        }).catch(error => {
            this.showToastMessage('Error loading Library', 'Please wait for system refresh the page and try again!', 'warning');
            location.reload();
        });
    }
    
    initializeLibrary() {
        if(!this.recordId && this.isMobile === true) {
            this.isReadOnly = false;
            this.message = "Edit Visitation Monthly Planning does not support mobile view. ";
            return;
        } 

        this.isMobile = false;

        if(!this.recordId && this.getQueryParameters().c__id)
            this.recordId = this.getQueryParameters().c__id;

        this.getCustomVisitationPlanFromApex(this.recordId);

        if(!this.isReadOnly) {
            this.getTotalCustomerCountFromApex();
            this.getCustomCustomerListFromApex();
        }
    }

    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

    /*************
    Data Control Function
    *************/
    processVisitationPlanDetail(customVisitationPlan) {
        let today       = new Date();
        let isSameMonth = customVisitationPlan.visitationPlan.ASI_HK_CRM_Year__c === today.getFullYear() && 
                          customVisitationPlan.visitationPlan.ASI_CRM_Month_Number__c === today.getMonth() + 1;
		
        let visitationPlanDate = moment(today);
        if(!isSameMonth) {
            let year  = customVisitationPlan.visitationPlan.ASI_HK_CRM_Year__c
            let month = customVisitationPlan.visitationPlan.ASI_CRM_Month_Number__c.length === 1 
                      ? '0' + customVisitationPlan.visitationPlan.ASI_CRM_Month_Number__c
                      : customVisitationPlan.visitationPlan.ASI_CRM_Month_Number__c;
            let day   = '01';
            visitationPlanDate = moment(year + '-' + month + '-' + day);
        }

        let eventData = [];

        customVisitationPlan.visitationPlanDetailList.forEach(detail => {
            eventData.push({
                'id'         : detail.Id,
                'start'      : detail.ASI_HK_CRM_Visit_Date__c,
                'end'        : detail.ASI_HK_CRM_Visit_Date__c,
                'title'      : detail.ASI_CRM_MY_Customer__r.Name, 
                'status'     : detail.ASI_HK_CRM_Status__c,
                'locked'     : detail.ASI_CRM_Locked__c,
                'customerId' : detail.ASI_CRM_MY_Customer__c,
                'recordType' : detail.ASI_CRM_MY_Customer__r.RecordType.Name
            });
        });

        this.visitationPlanDate    = visitationPlanDate;
        this.fullCalendarEventList = eventData;

        this.initCalendar(this.fullCalendarEventList, this.visitationPlanDate)
    }

    /*************
    Layout Element Control Function
    *************/
    initCalendar(eventData,visitationPlanDate) {
        var fullCalendarOptions = {
            header: {
                left   : 'title',
                center : '',
                right  : 'month,listMonth'
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
            eventClick            : this.onClickVisitationPlanDetail.bind(this),
            dayClick              : this.onClickCalendarDate.bind(this),
            events                : eventData
        };
        
        if(!this.isReadOnly) {
            fullCalendarOptions.editable  = true;
            fullCalendarOptions.droppable = true;
            fullCalendarOptions.eventDrop = this.onCalendarEventDrag.bind(this);
        }

        let calendarEl = this.template.querySelector('div.calendar');
        this.fullCalendarEle = $(calendarEl);
        this.fullCalendarEle.fullCalendar(fullCalendarOptions);
        this.fullCalendarEle.fullCalendar('gotoDate', visitationPlanDate);

        if(this.checkMobileUserAgent()) {
            if(this.template.querySelector('div.calendar-container')) {
                const bodyStyle = document.createElement('style');
                bodyStyle.innerText = `
                        .fc-scroller {
                            overflow       : hidden !important;
                            height         : 100% !important;
                            padding-bottom : 50px !important;
                        }
                    `;
                this.template.querySelector('div.calendar-container').appendChild(bodyStyle);
            }
        }

        if(this.template.querySelector('div.custom-panel')) {
            const navTitleSpanHideStyle = document.createElement('style');
            navTitleSpanHideStyle.innerText = `
                a[title='undefined'] > span {
                    display : none;
                }
            `;
            this.template.querySelector('div.custom-panel').appendChild(navTitleSpanHideStyle);

            const navTitleStyle = document.createElement('style');
            navTitleStyle.innerText = `
                a[title='undefined']:after {
                    max-width     : 100%;
                    overflow      : hidden;
                    text-overflow : ellipsis;
                    white-space   : nowrap;
                    content       : 'Visitation Monthly Planning';
                }
            `;
            this.template.querySelector('div.custom-panel').appendChild(navTitleStyle);
        }
        
        if(this.template.querySelector('div.fc-left')) {
            const titleStyle = document.createElement('style');
            titleStyle.innerText = `
                .fc-header-toolbar .fc-left {
                    font-size   : 18px;
                    margin-top  : 5px;
                    font-weight : 700;
                }
            `;
            this.template.querySelector('div.fc-left').appendChild(titleStyle);
        }

        if(this.template.querySelector('div.fc-view-container')) {
            const eventStyle = document.createElement('style');
            eventStyle.innerText = `
                .fc-event,
                .fc-event-dot {
                    background-color : #3788d8;
                    border           : 1px solid #3788d8;
                }
            `;

            const buttonStyle = document.createElement('style');
            buttonStyle.innerText = `
                .fc-button {
                    padding-top    : 0.4em !important;
                    padding-right  : 0.65em !important;
                    padding-bottom : 0.4em !important;
                    padding-left   : 0.65em !important;

                    color            : #0070d2;
                    background-color : #fff;
                    background-image : none;
                    border           : 1px solid #dddbda;
                }
            `;

            const buttonHoverStyle = document.createElement('style');
            buttonHoverStyle.innerText = `
                .fc-button:hover {
                    background-color : #F4F6F7;
                }
            `;

            const buttonActiveStyle = document.createElement('style');
            buttonActiveStyle.innerText = `
                .fc-state-active {
                    color            : #fff;
                    background-color : #0070d2;
                    border-color     : #0070d2;
                }
            `;

            const buttonActiveHoverStyle = document.createElement('style');
            buttonActiveHoverStyle.innerText = `
                .fc-state-active:hover {
                    color            : #fff;
                    background-color : #005fb2;
                    border-color     : #005fb2;
                }
            `;

            const listTitleStyle = document.createElement('style');
            listTitleStyle.innerText = `
                .fc-list-heading .fc-widget-header {
                    background-color: lightgray !important;
                    color: #000;
                }
            `;
            
            this.template.querySelector('div.fc-view-container').appendChild(eventStyle);
            this.template.querySelector('div.fc-view-container').appendChild(buttonStyle);
            this.template.querySelector('div.fc-view-container').appendChild(buttonHoverStyle);
            this.template.querySelector('div.fc-view-container').appendChild(buttonActiveStyle);
            this.template.querySelector('div.fc-view-container').appendChild(buttonActiveHoverStyle);
            this.template.querySelector('div.fc-view-container').appendChild(listTitleStyle);
        }
        
    }

    showToastMessage(title, message, type) {
        this.dispatchEvent(
            new ShowToastEvent({
                title   : title,
                message : message,
                variant : type
            })
        );
    }

    handleTouchMove(event) {
        event.stopPropagation();
    }

    checkMobileUserAgent() { 
        if( navigator.userAgent.match(/Android/i) || 
            navigator.userAgent.match(/webOS/i) || 
            navigator.userAgent.match(/iPhone/i) || 
            navigator.userAgent.match(/iPod/i) || 
            navigator.userAgent.match(/BlackBerry/i) || 
            navigator.userAgent.match(/Windows Phone/i)) {
            return true;
        }
        
        return false;
    }

    /*************
    Button Click Function
    *************/
    openFilter() {
        this.isOpenFilter = !this.isOpenFilter;
    }

    refreshCalendar() {
        let index = this.customerList.findIndex(customer => customer.Id === this.selectedCustomerId);

        if(index !== -1) 
            this.customerList[index].isSelected = false;
        
        this.isDeleteMode = false;

        this.selectedCustomerId = null;
        this.selectedCustomer   = null;

        this.componentConfig.allowSelect = true;
        
        this.paginationConfig.pageNo = 1;
        this.fullCalendarEle.fullCalendar('destroy');

        if(!this.isReadOnly) {
            this.customerList = [];
            this.getTotalCustomerCountFromApex();
            this.getCustomCustomerListFromApex();
        }

        this.getCustomVisitationPlanFromApex(this.recordId);
    }

    enableDeleteMode() {
        this.isDeleteMode = true;

        if(this.selectedCustomerId) {
            let selectedIndex = this.customerList.findIndex(customer => customer.Id === this.selectedCustomerId);
            this.customerList[selectedIndex].isSelected = false;

            this.selectedCustomerId = null;
            this.selectedCustomer = null;
        }

        this.fullCalendarEventList.forEach(event => {
            event.color = 'orangered';
        });

        this.componentConfig.allowSelect = false;
        this.fullCalendarEle.fullCalendar('destroy');
        this.initCalendar(this.fullCalendarEventList, this.visitationPlanDate);
    }

    enableEditMode() {
        this.isDeleteMode = false;

        if(this.selectedCustomerId) {
            let selectedIndex = this.customerList.findIndex(customer => customer.Id === this.selectedCustomerId);
            this.customerList[selectedIndex].isSelected = false;

            this.selectedCustomerId = null;
            this.selectedCustomer = null;
        }

        this.fullCalendarEventList.forEach(event => {
            event.color = '#3788d8';
        });

        this.componentConfig.allowSelect = true;
        this.fullCalendarEle.fullCalendar('destroy');
        this.initCalendar(this.fullCalendarEventList, this.visitationPlanDate);
    }

    saveRecord() {
        this.saveVisitationPlanDetailFromApex();
    }

    backToVisitationPlan() {
        window.location.replace("/lightning/r/ASI_HK_CRM_Visitation_Plan__c/" + this.recordId + "/view");
    }

    /*************
    Filter Function
    *************/
    searchCustomerByName(event) {
        this.customerName = event.target.value;
        
        this.paginationConfig.pageNo = 1;

        this.getTotalCustomerCountFromApex();
        this.getCustomCustomerListFromApex();
    }
    
    searchCustomerByOwner(event) {
        this.isOwned = event.target.checked;

        this.paginationConfig.pageNo = 1;

        this.getTotalCustomerCountFromApex();
        this.getCustomCustomerListFromApex();
    }

    /*************
    Data Table Event Callback Function
    *************/
    onSelectRecordCallback(record) {
        if(this.selectedCustomerId) {
            let selectedIndex = this.customerList.findIndex(customer => customer.Id === this.selectedCustomerId);
            this.customerList[selectedIndex].isSelected = false;
        }

        if(record.Id === this.selectedCustomerId) {
            this.selectedCustomerId = null;
            this.selectCustomer = null;

            this.fullCalendarEventList.forEach(event => {
                delete event.color;
            });

        } else {
            let index = this.customerList.findIndex(customer => customer.Id === record.Id);

            if(index !== -1) {
                this.customerList[index].isSelected = true;

                if(this.customerList[index].isSelected) {
                    this.selectedCustomerId = record.Id;
                    this.selectCustomer = record;

                    this.fullCalendarEventList.forEach(event => {
                        if(event.customerId === record.Id) {
                            event.color = 'blueviolet';
                        } else {
                            delete event.color;
                        }
                    });
                }
            }
        }

        this.fullCalendarEle.fullCalendar('destroy');
        this.initCalendar(this.fullCalendarEventList, this.visitationPlanDate);
    }

    onPageChange(pageNo) {
        this.paginationConfig.pageNo = pageNo;
        this.getCustomCustomerListFromApex();
    }

    /*************
    Full Calendar Control Function
    *************/
    onClickVisitationPlanDetail(event) {
        if(this.isDeleteMode) {
            let removeIndex = this.fullCalendarEventList.findIndex(tmpEvent => tmpEvent.id === event.id);

            if(removeIndex !== -1) {
                if(this.fullCalendarEventList[removeIndex].status && 
                    (this.fullCalendarEventList[removeIndex].status === 'Achieved' || 
                    this.fullCalendarEventList[removeIndex].status === 'Cancelled')) {
                    this.showToastMessage('Oops...', 'You cannot delete a visit with status (' + this.fullCalendarEventList[removeIndex].status + ')', 'warning');
                    return;
                }

                if(this.fullCalendarEventList[removeIndex].locked) {
                    this.showToastMessage('Oops...', 'You cannot delete a locked visit', 'warning');
                    return;
                }

                this.fullCalendarEventList.splice(removeIndex, 1);

                if(event.id.startsWith(this.newRecordPrefix) === false)
                    this.removeVisitationPlanDetailIdList.push(event.id);
                   
                let newIndex = this.newVisitationPlanDetailList.findIndex(visitationPlanDetail => visitationPlanDetail.id === event.id);
     
                if(newIndex !== -1)
                    this.newVisitationPlanDetailList.splice(newIndex, 1);

                this.fullCalendarEle.fullCalendar('removeEvents', event.id);  
            }
        } else if(event.id && 
            event.id.startsWith(this.newRecordPrefix) === false) {
            window.open('/lightning/r/ASI_HK_CRM_Visitation_Plan_Detail__c/' + event.id + '/view');
        }
    }

    onClickCalendarDate(selectedDate) {
        selectedDate = selectedDate.format();

        if(this.selectedCustomerId) {
            let removeIndex = this.fullCalendarEventList.findIndex(event => event.start === selectedDate && 
                                                                 event.customerId === this.selectCustomer.Id);
            
            if(removeIndex === -1) {
                let newEvent = {
                    'id'         : this.newRecordPrefix + this.newRecordIndex,
                    'start'      : selectedDate,
                    'end'        : selectedDate,
                    'title'      : this.selectCustomer.Name, 
                    'customerId' : this.selectCustomer.Id,
                    'recordType' : this.selectCustomer.RecordType.Name,
                    'color'      : 'blueviolet'
                };
                
                let newVisitationPlanDetail = {
                    'id'                            : newEvent.id,
                    'ASI_HK_CRM_Visitation_Plan__c' : this.recordId,
                    'ASI_CRM_MY_Customer__c'        : this.selectCustomer.Id,
                    'ASI_HK_CRM_Visit_Date__c'      : selectedDate,
                    'sobjectType'                   : 'ASI_HK_CRM_Visitation_Plan_Detail__c'
                };

                this.newRecordIndex += 1;

                this.fullCalendarEventList.push(newEvent);
                this.newVisitationPlanDetailList.push(newVisitationPlanDetail);

                this.fullCalendarEle.fullCalendar('renderEvent', newEvent);
            } else {
                this.showToastMessage('Oops...', 
                    this.selectCustomer.Name + ' is already added to ' + selectedDate + '',
                    'warning');
            }
        }
    }

    onCalendarEventDrag(event, delta, revertFunc) {
        let newDate = event.start.format();

        let existingIndex = this.fullCalendarEventList.findIndex(tempEvent => event.customerId === tempEvent.customerId 
            && newDate === tempEvent.start);

        if(existingIndex !== -1) {
            this.showToastMessage('Oops...', 
                    event.title + ' is already added to ' + newDate + '',
                    'warning');

            revertFunc();

            return;
        }

        let index = this.fullCalendarEventList.findIndex(tempEvent => event.id === tempEvent.id);

        if(index === -1) 
            return;
        
        let targetEvent = this.fullCalendarEventList[index];

        if(targetEvent.status && 
            (targetEvent.status === 'Achieved' || targetEvent.status === 'Cancelled')) {
            this.showToastMessage('Oops...', 
                    'You cannot update a visit with status (' + targetEvent.status + ')',
                    'warning');

            revertFunc();

            return;
        }

        if(targetEvent.locked) {
            this.showToastMessage('Oops...', 'You cannot update a locked visit', 'warning');

            revertFunc();

            return;
        }
        
        targetEvent.start = newDate;
        targetEvent.end   = newDate;

        if(targetEvent.id.startsWith(this.newRecordPrefix)) {
            let newEventList = this.newVisitationPlanDetailList.filter(detail => targetEvent.id === detail.id);
            newEventList[0].ASI_HK_CRM_Visit_Date__c = newDate;
        } else {
            let updateIndex = this.updateVisitationPlanDetailList.findIndex(detail => targetEvent.id === detail.id);
                
            let updatedVisitationPlanDetail = {};
            updatedVisitationPlanDetail.id = targetEvent.id;
            updatedVisitationPlanDetail.ASI_HK_CRM_Visit_Date__c = newDate;

            if(updateIndex === -1) {
                this.updateVisitationPlanDetailList.push(updatedVisitationPlanDetail);
            } else {
                this.updateVisitationPlanDetailList.splice(updateIndex, 1, updatedVisitationPlanDetail);
            }
        }
    }

    /*************
    Apex Control Function
    *************/
    getCustomVisitationPlanFromApex(recordId) {
        var params = {
            'recordId' : recordId
        };

        this.showSpinner = true;

        getCustomVisitationPlan(params)
            .then(result => {
                this.showSpinner = false;
                this.processVisitationPlanDetail(result);
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToastMessage("Warning!", error.body.message, "error");
            });
    }

    getTotalCustomerCountFromApex() {
        var params = {
            "isOwned" : this.isOwned
        };

        if(this.customerName)
            params.customerName = this.customerName;

        getCustomCustomerCount(params)
            .then(result => {
                this.paginationConfig.pageNo = 1;
                this.paginationConfig.totalPage = Math.floor(result / this.paginationConfig.pageSize) + 1;
            })
            .catch(error => {
                this.showToastMessage("Warning!", error.body.message, "error");
            });
    }

    getCustomCustomerListFromApex() {
        var params = {
            "pageSize" : this.paginationConfig.pageSize,
            "pageNo"   : this.paginationConfig.pageNo,
            "isOwned"  : this.isOwned
        };

        if(this.customerName)
            params.customerName = this.customerName;

        getCustomCustomerList(params)
            .then(result => {
                this.customerList = [];

                result.forEach(row => {
                    let cloneRow = Object.assign({}, row);
                    cloneRow.isSelected = false;
                    this.customerList.push(cloneRow);
                })

                this.selectedCustomerId = null;
                this.selectedCustomer = null;
            })
            .catch(error => {
                this.showToastMessage("Warning!", error.body.message, "error");
            });
    }

    saveVisitationPlanDetailFromApex() {
        let newVisitationPlanDetailList = JSON.parse(JSON.stringify(this.newVisitationPlanDetailList));
        newVisitationPlanDetailList.forEach(visitationPlanDetail => {
            visitationPlanDetail.ASI_HK_CRM_Status__c = 'Planned';
            delete visitationPlanDetail.id;
        });

        let params = {
            "insertDetailListJson"   : JSON.stringify(newVisitationPlanDetailList),
            "updateDetailListJson"   : JSON.stringify(this.updateVisitationPlanDetailList),
            "deleteDetailIdListJson" : JSON.stringify(this.removeVisitationPlanDetailIdList)
        };

        this.showSpinner = true;
        
        saveVisitationPlanDetail(params)
            .then(result => {
                this.showSpinner  = false;
                this.showToastMessage("Success!", "Records are saved!", "success");

                location.reload();
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToastMessage("Warning!", error.body.message, "error");
            });
    }
}