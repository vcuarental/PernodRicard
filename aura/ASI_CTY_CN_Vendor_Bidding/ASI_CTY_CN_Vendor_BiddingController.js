({
    doInit: function(component, event, helper) {
        // this function call on the component load first time
        // call the helper function
        helper.getMyBiddings(component, helper);
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
            helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_BiddingList_Search_Info_Tips'), 'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_DateFilter_Tips'));
            component.find("endDate").set('v.value', '');
            endDate = '';
        }

        // Refresh page data
        helper.renderPage(component, startDate, endDate);
        component.set('v.isLoading', false);
    },
    // this function call on the downloadPRDetails button clicked
    downloadPRDetails: function(component, event, helper) {
        var startDate = component.find("startDate").get("v.value");
        var endDate = component.find("endDate").get("v.value");

        helper.downloadPRDetails(component, startDate, endDate);
    },
    sortByName: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'Name');
    },
    sortByStartDate: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'CreatedDate');
    },
    sortByItemGroup: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Chinese_Name__c');
    },
    sortByItemGroupTotalQty: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'ASI_CTY_CN_Vendor_Total_Quantity__c');
    },
    sortByDeadLine: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'ASI_CTY_CN_Vendor_Deadline_Date__c');
    },
    sortByStatus: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'ASI_CTY_CN_Vendor_Status__c');
    },
    sortByResultStatus: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.sortBy(component, 'ASI_CTY_CN_Vendor_Result_Status__c');
    },
    handlePage : function(component, event, helper) {
        component.set('v.showSpinner', true);
        console.info('handlePage----');
        var page = component.get('v.page');
        var pages = component.get('v.pages');
        var currentPage = event.getParam('currentPage');
        var isLoadingPage = event.getParam('isLoadingPage');
        
        console.info('v.page = ' + page);
        console.info('v.pages = ' + pages);
        console.info('v.isLoadingPage = ' + isLoadingPage);
        component.set('v.page', currentPage);
        if (isLoadingPage) {
            helper.renderPage(component, '', '');
        }
    },
    recordSize : function(component, event, helper) {
        component.set('v.page', 1);
        helper.getMyBiddings(component, helper);
        component.set('v.sortField', 'StartDate');
        helper.sortBy(component, component.get('v.sortField'), true);
    },
    submitBidding : function(component, event, helper) {
        var prId = event.target.id;
        console.info('prId = ' + prId);
        var url = 'biddingdetail?Id=' + prId;
        helper.navigateToURL(url);
    }
})