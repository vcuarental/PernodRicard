({
    loadSelectedTabId: function (component) {
        var url = decodeURIComponent(window.location.search.substring(1));
        console.log('url' + url);
        var urlParams = url.split('&');
        var myOrdersParam;
        for (var i = 0; i < urlParams.length; i++) {
            myOrdersParam = urlParams[i].split('=');
            console.log('myOrdersParam' + myOrdersParam);
            if (myOrdersParam[0] === 'selectedTabId') {
                myOrdersParam[1] === undefined ? 0 : myOrdersParam[1];
                if (myOrdersParam[1] != 0) {
                    component.set("v.selectedTabId", myOrdersParam[1]);
                }
            }
        }
    },
    numToMoneyField: function (inputString) {
        regExpInfo = /(\d{1,3})(?=(\d{3})+(?:$|\.))/g;
        var ret = inputString.toString().replace(regExpInfo, "$1,");
        return ret;
    },

    getDefaultOrder : function(component) {
        component.set('v.openSORColumns', this.getOpenSORColumnDefinitions());
        var action = component.get("c.getOpenSOR");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if (state === "SUCCESS") {
                
                var record = response.getReturnValue();
                component.set("v.openSOR", record);

            } else if (state === "INCOMPLETE") {

                console.log('Status incomplete');

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        
                                        console.log('Internal server error: ' + errors[i].pageErrors[j].message);

                                    }
                                }
                            }
                            console.log(errors[i].message);
                        }
                    }
                }
                else {
                    console.log('Internal server error');
                }
            }
        });
        $A.enqueueAction(action);
    },
    getMyOrders : function(component, helper, startDate, endDate) {
        
        var action = component.get("c.fetchSORs");
        action.setParams({
            "startDate" : startDate,
            "endDate" : endDate
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                // console.log('records' + records);
                if(records != null){
                    records.forEach(function(record){
                        record.ReleaseQty = 0;
                        record.RelatedTOVSONumber = '';
                        record.Id = record.salesOrder.Id;
                        record.Name = record.salesOrder.Name;
                        record.ASI_CRM_SG_Order_Date__c = record.salesOrder.ASI_CRM_SG_Order_Date__c;
                        record.ASI_CTY_CN_WS_Total_Order_Qty_CA__c = record.salesOrder.ASI_CTY_CN_WS_Total_Order_Qty_CA__c;
                        record.ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c = record.salesOrder.ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c;
                        record.ASI_CTY_CN_WS_Discount_Amount_With_VAT__c = record.salesOrder.ASI_CTY_CN_WS_Discount_Amount_With_VAT__c;
                        record.ASI_CTY_CN_WS_Status__c = record.salesOrder.ASI_CTY_CN_WS_Status__c;
                        record.PayableAmount = 0;
                        var tovs = record.salesOrder.TOVs__r;
                        record.TOVs__r = tovs;
                        if(tovs != '' && tovs != undefined && tovs != null){
                            var finalTOVNumbers = [];
                            tovs.forEach(function(tov){
                                let recordType = tov.RecordType;
                                // console.log('recordType.DeveloperName' + recordType.DeveloperName)
                                if(recordType.DeveloperName == 'ASI_CRM_CN_TOV_Final'){
                                    finalTOVNumbers.push(tov.ASI_CRM_SO_Number__c);
                                }
                            });
                            // console.log('finalTOVNumbers' + finalTOVNumbers);
                            tovs.forEach(function(tov){ 
                                let recordType = tov.RecordType;
                                if(recordType.DeveloperName == 'ASI_CRM_CN_TOV_Final' ||
                                    (recordType.DeveloperName == 'ASI_CRM_CN_TOV'
                                        && !finalTOVNumbers.includes(tov.ASI_CRM_SO_Number__c))){
                                    record.ReleaseQty += tov.ASI_CTY_CN_WS_Total_Order_Qty_CA__c;
                                    record.PayableAmount += tov.ASI_MFM_Total_Amount_wTax__c;
                                    record.RelatedTOVSONumber += tov.ASI_CRM_SO_Number__c + ';';
                                }
                            });
                        }
                        var tovDetails = record.tovDetails;
                        record.promotionAmount = 0;
                        record.discountAmount = 0;

                        if (tovDetails != '' && tovDetails != undefined && tovDetails != null) {
                            var finalTOVNums = [];
                            tovDetails.forEach(tovd => {
                                let recordTypeName = tovd.ASI_CRM_TOV__r.RecordType.DeveloperName;
                                if(recordTypeName == 'ASI_CRM_CN_TOV_Final'){
                                    finalTOVNums.push(tovd.ASI_CRM_TOV__r.ASI_CRM_SO_Number__c);
                                }
                                
                            });
                            tovDetails.forEach(tovd => {
                                let recordTypeName = tovd.ASI_CRM_TOV__r.RecordType.DeveloperName;
                                if(recordTypeName == 'ASI_CRM_CN_TOV_Final' ||
                                    (recordTypeName == 'ASI_CRM_CN_TOV' && !finalTOVNums.includes(tovd.ASI_CRM_TOV__r.ASI_CRM_SO_Number__c))){
                                    if (tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Promotion_Rate__c != null 
                                        && tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Promotion_Rate__c != undefined) {
                                        record.promotionAmount += tovd.ASI_CTY_CN_WS_Order_Qty_BT__c * tovd.ASI_CRM_SF_SO_Price_BT__c * tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Promotion_Rate__c/100;
                                    }
                                    if (tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Disount_Rate__c != null 
                                        && tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Disount_Rate__c != undefined) {
                                        record.discountAmount += tovd.ASI_CTY_CN_WS_Order_Qty_BT__c * tovd.ASI_CRM_SF_SO_Price_BT__c * tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Disount_Rate__c/100;
                                    }
                                }
                                
                                
                            });

                        }
                        record.UnmetQty = record.salesOrder.ASI_CTY_CN_WS_Total_Order_Qty_CA__c - record.ReleaseQty;
                        record.ReleaseAmount = record.PayableAmount + record.promotionAmount + record.discountAmount;
                    });
                    component.set("v.allSORs", records);
                    component.set("v.sortField", 'Name');
                    component.set("v.sortAsc", true);
                    helper.sortBy(component, "Name");
                }
            } else if (state === "INCOMPLETE") {

                console.log('Status incomplete');

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        
                                        console.error('Internal server error: ' + errors[i].pageErrors[j].message);

                                    }
                                }
                            }
                            console.error(errors[i].message);
                        }
                    }
                }
                else {
                    console.error('Internal server error');
                }
            }
        });
        $A.enqueueAction(action);
    },
    getRefundTOVs : function(component) {
        var action = component.get("c.fetchRefundTOVs");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('state'+state);
            if (state === "SUCCESS") {
                
                var records = response.getReturnValue();
                // console.log('records' + records);
                if(records != null){
                    // console.log('refundTOVs' + records);
                    component.set("v.allRefundTOVs", records);
                    component.set("v.refundPage", 1);
                    this.renderPage(component, 'refundTOVs', '', '');
                }

            } else if (state === "INCOMPLETE") {

                console.log('Status incomplete');

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        
                                        console.log('Internal server error: ' + errors[i].pageErrors[j].message);

                                    }
                                }
                            }
                            console.log(errors[i].message);
                        }
                    }
                }
                else {
                    console.log('Internal server error');
                }
            }

        });
        $A.enqueueAction(action);
    },
    getHeldTOVs : function(component) {
        var action = component.get("c.fetchHeldTOVs");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('state'+state);
            if (state === "SUCCESS") {
                
                var records = response.getReturnValue();
                // console.log('records' + records);
                if(records != null){
                    // console.log('heldTOVs' + records);
                    component.set("v.allHeldTOVs", records);
                    component.set("v.heldPage", 1);
                    this.renderPage(component, 'heldTOVs', '', '');
                }

            } else if (state === "INCOMPLETE") {

                console.log('Status incomplete');

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        
                                        console.log('Internal server error: ' + errors[i].pageErrors[j].message);

                                    }
                                }
                            }
                            console.log(errors[i].message);
                        }
                    }
                }
                else {
                    console.log('Internal server error');
                }
            }

        });
        $A.enqueueAction(action);
    },
    sortBy: function(component, field) {
        console.log('field:' + field);
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.allSORs");
        sortAsc = sortField != field || !sortAsc;
        
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = (!a[field] && b[field]) || (a[field] < b[field]);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
        
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.allSORs", records);
        component.set("v.page", 1);
        this.renderPage(component, 'allSORs', '', '');
    },
	renderPage: function(component, TabId, startDate, endDate) {
        if( TabId === 'allSORs'){
            var tovs = document.querySelectorAll('.tovs');
            tovs.forEach(function(tov){
                tov.innerHTML = '';
            });
            var records = component.get("v.allSORs"),
                pageNumber = component.get("v.page"),
                size = component.get("v.recordToDisply"),
                term = component.get("v.term");
            if(term != null && term != '') {
                component.set("v.page", 1);
                records = records.filter(item => (item.Name.includes(term) || item.RelatedTOVSONumber.includes(term)));
            }
            var pageRecords = records.slice((pageNumber-1)*size, pageNumber*size);
            pageRecords.forEach(function(pageRecord){
                pageRecord.showtov = false;
            });
            component.set("v.sors", pageRecords);
            component.set("v.total", records.length);
            component.set("v.pages", Math.floor((records.length+(size-1))/size));
            if(pageRecords.length === 0){
                component.set("v.pageFirstIndex", 0);
            }else{
                component.set("v.pageFirstIndex", size * (pageNumber-1) + 1);
            }
            if(pageRecords.length === size){
                component.set("v.pageLastIndex", size * pageNumber);
            }else{
                component.set("v.pageLastIndex", size * (pageNumber-1) + pageRecords.length);
            }

        }else if( TabId === 'refundTOVs'){
            var records = component.get("v.allRefundTOVs"),
                pageNumber = component.get("v.refundPage"),
                size = component.get("v.refundRecordToDisply"),
                term = component.get("v.refundTerm");
            if(term != null && term != '') {
                component.set("v.refundPage", 1);
                records = records.filter(item => (item.tovNo.includes(term)));
            }
            if(startDate != null && startDate != ''){
                console.log('startDate' + startDate);
                records = records.filter(
                    function (item) {
                        // console.log('item.orderDate start'+item.orderDate);
                        if(item.orderDate > startDate){
                            return item;
                        }
                    }
                );
            }
            if(endDate != null && endDate != ''){
                console.log('endDate' + endDate);
                records = records.filter(
                    function (item) {
                        // console.log('item.orderDate end'+item.orderDate);
                        if(item.orderDate < endDate){
                            return item;
                        }
                    }
                );
            }
            var pageRecords = records.slice((pageNumber-1)*size, pageNumber*size);
            component.set("v.refundTOVs", pageRecords);
            component.set("v.refundTotal", records.length);
            component.set("v.refundPages", Math.floor((records.length+(size-1))/size));
            if(pageRecords.length === 0){
                component.set("v.refundPageFirstIndex", 0);
            }else{
                component.set("v.refundPageFirstIndex", size * (pageNumber-1) + 1);
            }
            if(pageRecords.length === size){
                component.set("v.refundPageLastIndex", size * pageNumber);
            }else{
                component.set("v.refundPageLastIndex", size * (pageNumber-1) + pageRecords.length);
            }
        }else if( TabId === 'heldTOVs'){
            var records = component.get("v.allHeldTOVs"),
                pageNumber = component.get("v.heldPage"),
                size = component.get("v.heldRecordToDisply"),
                term = component.get("v.heldTerm");
            if(term != null && term != '') {
                component.set("v.heldPage", 1);
                records = records.filter(item => (item.ASI_CRM_SO_Number__c.includes(term) || item.ASI_CRM_SF_SO_Request_Number__r.Name.includes(term)));
            }
            if(startDate != null && startDate != ''){
                console.log('startDate' + startDate);
                records = records.filter(
                    function (item) {
                        // console.log('item.ASI_CRM_Order_Date__c start'+item.ASI_CRM_Order_Date__c);
                        if(item.ASI_CRM_Order_Date__c > startDate){
                            return item;
                        }
                    }
                );
            }
            if(endDate != null && endDate != ''){
                console.log('endDate' + endDate);
                records = records.filter(
                    function (item) {
                        // console.log('item.ASI_CRM_Order_Date__c end'+item.ASI_CRM_Order_Date__c);
                        if(item.ASI_CRM_Order_Date__c < endDate){
                            return item;
                        }
                    }
                );
            }
            var pageRecords = records.slice((pageNumber-1)*size, pageNumber*size);
            component.set("v.heldTOVs", pageRecords);
            component.set("v.heldTotal", records.length);
            component.set("v.heldPages", Math.floor((records.length+(size-1))/size));
            if(pageRecords.length === 0){
                component.set("v.heldPageFirstIndex", 0);
            }else{
                component.set("v.heldPageFirstIndex", size * (pageNumber-1) + 1);
            }
            if(pageRecords.length === size){
                component.set("v.heldPageLastIndex", size * pageNumber);
            }else{
                component.set("v.heldPageLastIndex", size * (pageNumber-1) + pageRecords.length);
            }
        }
        component.set('v.showSpinner', false);
	},
    navigateToURL: function (url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/" + url
        });
        urlEvent.fire();
    },
    newOrder: function (component, helper) {
        component.set('v.showSpinner', true);
        this.getDefaultOrder(component);
        
        let openSOR = component.get("v.openSOR");
        if (openSOR.length > 0) {
            alert($A.get('$Label.c.ASI_CTY_CN_WS_New_Order_Limit'));
            component.set('v.showSpinner', false);
            return;
        } else {
            helper.navigateToURL('choose-order-type');
        }
    },
    /*
     * showRowDetails
     * TO DO: call the lightning page
     */
    showRowDetails: function (row, helper) {
        helper.navigateToURL('order-detail?orderId=' + row.Id);
    },
    /*
     * submitSOR
     * TO DO: call the lightning page
     */
    submitSOR: function (row, helper) {
        helper.navigateToURL('shopping-cart?orderId=' + row.Id);
    },
    /*
     * deleteSOR
     * TO DO: delete the row
     */
    deleteSOR: function (component, row) {
        component.set('v.showSpinner', true);
        console.log('delete sor start');
        var action = component.get("c.deleteOpenSOR");
        console.log('row.Id' + row.Id);
        action.setParams({
            "orderId" : row.Id
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('state' + state);
            if (state === "SUCCESS") {
                
                console.log('SUCCESS');
                this.getDefaultOrder(component);
                component.set('v.showSpinner', false);

            } else if (state === "INCOMPLETE") {

                console.log('Status incomplete');

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        
                                        console.log('Internal server error: ' + errors[i].pageErrors[j].message);

                                    }
                                }
                            }
                            console.log(errors[i].message);
                            alert(errors[i].message);
                            component.set('v.showSpinner', false);
                        }
                    }
                }
                else {
                    console.log('Internal server error');
                }
            }

        });
        $A.enqueueAction(action);
    },
    addClickEvent: function (helper, className) {
        var tovDetailsLinks = document.getElementsByClassName(className);
        tovDetailsLinks.forEach(function(tovDetailsLink){
            tovDetailsLink.addEventListener("click", function() {
                console.log('address' + this.id);
                let url = 'order-detail?tovTabId=' + this.id;
                console.log('url' + url);
                helper.navigateToURL(url);
            });
        });
    },
    /*
     * getOpenSORColumnDefinitions
     * Get the Open SOR columns to use on data table
     */
    getOpenSORColumnDefinitions: function () {
        var columns = [
            {
                label: $A.get('$Label.c.ASI_CTY_CN_WS_SORNo'),
                type: 'button',
                fieldName: 'Name',
                typeAttributes: {
                    variant: "base",
                    label: {
                        fieldName: 'Name'
                    },
                    name: 'view_details',
                    title: 'Click to View Details'
                }
            },
            {
                label: $A.get('$Label.c.ASI_CTY_CN_WS_SOR_CreatedDate'),
                type: 'date',
                fieldName: 'CreatedDate'
            },
            {
                label: $A.get('$Label.c.ASI_CTY_CN_WS_SORQty'),
                type: 'number',
                fieldName: 'ASI_CTY_CN_WS_Total_Order_Qty_CA__c'
            },
            {
                label: $A.get('$Label.c.ASI_CTY_CN_WS_SORAmount'),
                type: 'currency',
                fieldName: 'ASI_CTY_CN_WS_Total_Order_Amount__c'
            },
            {
                label: $A.get('$Label.c.ASI_CTY_CN_WS_SORStatus'),
                type: 'text',
                fieldName: 'ASI_CTY_CN_WS_Status__c'
            },
            {
                label: $A.get('$Label.c.ASI_CTY_CN_WS_View_Details'),
                type: 'button',
                typeAttributes: {
                    label: $A.get('$Label.c.ASI_CTY_CN_WS_View_Details'),
                    name: 'submit_SOR',
                    title: 'Click to Submit'
                }
            },
            {
                label: $A.get('$Label.c.ASI_CTY_CN_WS_Delete_Open_SOR'),
                type: 'button',
                typeAttributes: {
                    label: $A.get('$Label.c.ASI_CTY_CN_WS_Delete_Open_SOR'),
                    name: 'delete_SOR',
                    title: 'Click to Delete the SOR'
                }
            }
        ];

        return columns;
    },
    downloadSORDetails: function (component, startDate, endDate) {
        console.log('startDate' + startDate);
        console.log('endDate' + endDate);
        var action = component.get("c.getSORDetails");
        action.setParams({
            "startDate" : startDate,
            "endDate" : endDate
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if (state === "SUCCESS") {
                var sorDetails = response.getReturnValue();
                // console.log('sorDetails'+sorDetails);
                
                // let currentDate = new Date();
                // console.log('currentDate'+currentDate);

                let csvContent = sorDetails.map(e => e.join(",")).join("\n");
                var encodedUri = encodeURI(csvContent);
                var universalBOM = "\uFEFF";
                var link = document.createElement("a");
                link.setAttribute('href', 'data:text/csv; charset=utf-8,' + encodeURIComponent(universalBOM+csvContent));
                link.setAttribute("download", "SOR Details.csv");
                document.body.appendChild(link); // Required for FF

                link.click();

            } else if (state === "INCOMPLETE") {

                console.log('Status incomplete');

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        
                                        console.log('Internal server error: ' + errors[i].pageErrors[j].message);

                                    }
                                }
                            }
                            console.log(errors[i].message);
                        }
                    }
                }
                else {
                    console.log('Internal server error');
                }
            }
        });
        $A.enqueueAction(action);
    },
})