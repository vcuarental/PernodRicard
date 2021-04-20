({
    // this function call on the component load first time
    doInit: function(component, event, helper) {
        component.set('v.showSpinner', true);

        // call the helper function
        helper.getMyPOs(component, helper);
    },
    // this function call on the input date changed
    dateFilter: function(component, event, helper) {
        var term = component.get("v.term");
        // Determine whether the search string contains Chinese  
        var reg = new RegExp("[\\u4E00-\\u9FFF]+","g");

        component.set("v.page", 1);
        component.set('v.showSpinner', true);
        component.set('v.isLoading', true);

        var startDate = component.find("startDate").get("v.value");
        var endDate = component.find("endDate").get("v.value");
        // Convert string format to date
        var startTime = new Date(Date.parse(startDate));
        var endTime = new Date(Date.parse(endDate));

        // Start and end date data verification
        if (startDate != '' && endDate != '' && startTime > endTime) {
            helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_POList_DateFilter'), 'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_DateFilter_Tips'));
            component.find("endDate").set('v.value', '');
            endDate = '';
        }

        // Refresh page data
        helper.renderPage(component, startDate, endDate);
        component.set('v.isLoading', false);
    },
    
    // Sort by PO Name
    sortByName: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'Name');
    },

    // Sort by Start Date
    sortByStartDate: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'CreatedDate');
    },

    // Sort by PO Total Qty
    sortByTotalQty: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'ASI_MFM_Total_Quantity__c');
    },

    // Sort by PO Item Group Total Qty
    sortByTOVTotalQty: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'TotalQty');
    },

    // Sort by Writed SIR Qty
    sortByActualQty: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'ActualQty');
    },

    // Sort by PO Status
    sortByStatus: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'ASI_MFM_Status__c');
    },

    // Sort by SIR Status
    sortBySIRStatus: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'ASI_CTY_CN_Vendor_Fill_Sir_Str');
    },

    // Sort by PO Amount
    sortByTotalAmount: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'ASI_MFM_CN_PO_Amount_RMB__c');
    },

    // Sort by PO Paid_Amount
    sortByActualAmount: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'ASI_MFM_Total_Paid_Amount__c');
    },

    // Sort by PR Number
    sortByPRId: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'ASI_CTY_CN_Vendor_Purchase_Request_Line__r.Name');
    },
    
    // Controls the display of itemgroup information
    controlItemGroup : function(component, event, helper) {
        var index = event.getSource().get('v.id');
        var prs = component.get('v.POs');
        var pr = prs[index];

        if (pr) {
            pr.showItemGroup = !pr.showItemGroup;
            prs[index] = pr;
            component.set('v.POs', prs);
        }
    },
    
    // Jump and Refresh page
    handlePage : function(component, event, helper) {
        console.info('handlePage----');
        var page = component.get('v.page');
        var pages = component.get('v.pages');
        var currentPage = event.getParam('currentPage');
        var isLoadingPage = event.getParam('isLoadingPage');
        var startDate = component.find("startDate").get("v.value");
        var endDate = component.find("endDate").get("v.value");
        
        console.info('v.page = ' + page);
        console.info('v.pages = ' + pages);
        console.info('v.isLoadingPage = ' + isLoadingPage);
        component.set('v.page', currentPage);

        // When the first page or the last page, click pagination and do not refresh the page
        if (isLoadingPage) {
            helper.renderPage(component, startDate, endDate);
        }
    },
    
    // Refresh the data when the record size of the page changes 
    recordSize : function(component, event, helper) {
        // The first page is displayed by default
        component.set('v.page', 1);

        // The startdate sort field is displayed by default
        component.set('v.sortField', 'ASI_MFM_PO_Start_Date__c');
        helper.sortBy(component, component.get('v.sortField'), true);
    },

    // Jump to PO detail page
    toPODetail : function(component, event, helper) {
        var id = event.target.id;
        var url = 'ContractDetail?Id=' + id;
        helper.navigateToURL(url);
    },

    // download POList according to PO start and end time
    downloadPODetails: function(component, event, helper) {
        var startDate = component.find("startDate").get("v.value");
        var endDate = component.find("endDate").get("v.value");
        helper.downloadPODetails(component, startDate, endDate);
    }
})