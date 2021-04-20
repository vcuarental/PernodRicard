({
    // Initialization page function
    getMyBiddings : function(component, helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.getQuotationInfo');
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status == 'SUCCESS') {
                var data = response.getReturnValue();
                console.info(data);

                if (!this.isEmpty(data)) {
                    data.forEach(function(item, index) {
                        var itemGroup = item.ASI_CTY_CN_Vendor_Item_Group__r;
                        if (itemGroup == null || typeof(itemGroup) == 'undefined') {
                            item.ASI_CTY_CN_Vendor_Item_Group__r = {};
                        }

                        var itemGroupChineseName = item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Chinese_Name__c;
                        if (itemGroupChineseName == null || typeof(itemGroupChineseName) == 'undefined') {
                            item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Chinese_Name__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_No_ItemGroup_ChineseName');
                        }

                        var itemGroupEnglishName = item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Eng_Name__c;
                        if (itemGroupEnglishName == null || typeof(itemGroupEnglishName) == 'undefined') {
                            item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Eng_Name__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_No_ItemGroup_Code');
                        }

                        var itemGroupCode = item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c;
                        if (itemGroupCode == null || typeof(itemGroupCode) == 'undefined') {
                            item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_No_ItemGroup_EngName');
                        }

                        if (item.CreatedDate.indexOf('T') != -1) {
                            item.CreatedDate = item.CreatedDate.split('T')[0];
                        }
                    });
                    component.set('v.allPRs', data);
                    this.renderPage(component, '', '');
                    component.set('v.showSpinner', false);
                }
            }
        });
        $A.enqueueAction(action);
        
    },

    // Jump page function
    navigateToURL: function (url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/" + url
        });
        urlEvent.fire();
    },
    
    // field: sortName, flag: do you want to reload page when the record size changes
    sortBy: function (component, field, flag) {
        console.log('field:' + field);
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.allPRs");

        if (sortField != field || flag) {
            sortAsc = false;
        } else {
            sortAsc = !sortAsc;
        }
        console.info('sortAsc: ' + sortAsc);

        // Filter the data according to the search criteria
        records.sort(function(a,b){
            // var sortField = component.get("v.sortField")
            if (field.indexOf('.') != -1) {
                var itemGroup = field.split('.')[0];
                var fieldName = field.split('.')[1];
                var t3 = a[itemGroup];
                var t4 = b[itemGroup];
                var t1 = t3[fieldName] == t4[fieldName],
                    t2 = (!t3[fieldName] && t4[fieldName]) || (t3[fieldName] < t4[fieldName]);
                return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
            } else {
                var t1 = a[field] == b[field],
                    t2 = (!a[field] && b[field]) || (a[field] < b[field]);
                return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
            }
        });

        var startDate = component.find("startDate").get("v.value");
        var endDate = component.find("endDate").get("v.value");
        
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.allPRs", records);
        component.set("v.page", 1);
        component.set('v.showSpinner', false);
        this.renderPage(component, startDate, endDate);
    },

    // Reloaded PR List
    renderPage: function(component, startDate, endDate) {
        // Check whether the string contains Chinese
        var reg = new RegExp("[\\u4E00-\\u9FFF]+","g");

        var records = component.get("v.allPRs"),
            pageNumber = component.get("v.page"),
            size = component.get("v.recordToDisply"),
            term = component.get("v.term");

        // Search string length < 3, and do not reloaded
        if (term == null || (term.length < 3 && !reg.test(term))) {
            term = '';
        }

        term = term.trim();
        var lowerTerm = term.toLowerCase();

        if(term != null && term != '') {
            records = records.filter(item => {
                if (item) {
                    if ((term != null && term != '')) {
                        if (item.Name != null && typeof(item.Name) != 'undefined') {
                            if (item.Name.toLowerCase().includes(lowerTerm)) {
                                return true;
                            }
                        }
                        if (item.ASI_CTY_CN_Vendor_Status__c != null && typeof(item.ASI_CTY_CN_Vendor_Status__c) != 'undefined') {
                            if (item.ASI_CTY_CN_Vendor_Status__c.toLowerCase().includes(lowerTerm)) {
                                return true;
                            }
                        }
                        if (item.ASI_CTY_CN_Vendor_Result_Status__c != null && typeof(item.ASI_CTY_CN_Vendor_Result_Status__c) != 'undefined') {
                            if (item.ASI_CTY_CN_Vendor_Result_Status__c.toLowerCase().includes(lowerTerm)) {
                                return true;
                            }
                        }
                        
                        var flag = false;  
                        if (item.ASI_CTY_CN_Vendor_Item_Group__r != null && typeof(item.ASI_CTY_CN_Vendor_Item_Group__r) != 'undefined') {
                            if (item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Chinese_Name__c != null 
                                && typeof(item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Chinese_Name__c) != 'undefined') {
                                if (item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Chinese_Name__c.includes(term)) {
                                    return true;
                                }
                            }

                            if (item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Eng_Name__c != null 
                                && typeof(item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Eng_Name__c) != 'undefined') {
                                if (item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Eng_Name__c.includes(term)) {
                                    return true;
                                }
                            }

                            if (item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c != null 
                                && typeof(item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c) != 'undefined') {
                                if (item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c.includes(term)) {
                                    return true;
                                }
                            }
                        }
                    }
                }
            });
        }

        if((startDate != null && startDate != '') || (endDate != null && endDate != '')) {
            records = records.filter(item => {
                if (startDate != null && startDate != '') {
                    if (endDate != null && endDate != '') {
                        if (item.CreatedDate <= endDate && item.CreatedDate >= startDate) {
                            return true;
                        }
                    } else {
                        if (item.CreatedDate >= startDate) {
                            return true;
                        }
                    }
                } else {
                    if (endDate != null && endDate != '') {
                        if (item.CreatedDate <= endDate) {
                            return true;
                        }
                    }
                }
                return false;
            });
        }
        
        // Paging
        var pageRecords = records.slice((pageNumber-1)*size, pageNumber*size);
        console.info('pageRecords-------');
        console.info(pageRecords);

        component.set("v.PRs", pageRecords);
        component.set("v.total", records.length);

        // Computing Pagination
        var pages = Math.ceil(records.length * 1.0/size);
        if (pages == 0) {
            pages = 1;
        }
        component.set("v.pages", pages);
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
        component.set('v.showSpinner', false);
    },

    // download PR List according to start and end date
    downloadPRDetails: function (component, startDate, endDate) {
        console.log('startDate' + startDate);
        console.log('endDate' + endDate);

        var records = component.get('v.allPRs');
        if((startDate != null && startDate != '') || (endDate != null && endDate != '')) {
            records = records.filter(item => {
                if (startDate != null && startDate != '') {
                    if (endDate != null && endDate != '') {
                        if (item.CreatedDate <= endDate && item.CreatedDate >= startDate) {
                            return true;
                        }
                    } else {
                        if (item.CreatedDate >= startDate) {
                            return true;
                        }
                    }
                } else {
                    if (endDate != null && endDate != '') {
                        if (item.CreatedDate <= endDate) {
                            return true;
                        }
                    }
                }
                return false;
            });
        }

        var resultDetails = [];
        var initDetail = [$A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Number'), $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Start_Date'), 
        $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_ItemGroup_Name'), $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Total_Quantity'), 
        $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_End_Date'), $A.get('$Label.c.ASI_CTY_CN_Vendor_PO_Status'), 
        $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status')];
        resultDetails.push(initDetail);
        records.forEach(function(item) {
            var arr = [];
            arr.push(item.Name);
            arr.push(item.CreatedDate);  
            arr.push(item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Chinese_Name__c + '/' 
                + item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Eng_Name__c + ' - ' 
                + item.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c);
            arr.push(item.ASI_CTY_CN_Vendor_Total_Quantity__c);
            arr.push(item.ASI_CTY_CN_Vendor_Deadline_Date__c);
            arr.push(item.ASI_CTY_CN_Vendor_Status__c);
            arr.push(item.ASI_CTY_CN_Vendor_Result_Status__c);
            resultDetails.push(arr);
        });

        let csvContent = resultDetails.map(e => e.join(",")).join("\n");
        var encodedUri = encodeURI(csvContent);
        var universalBOM = "\uFEFF";
        var link = document.createElement("a");
        link.setAttribute('href', 'data:text/csv; charset=utf-8,' + encodeURIComponent(universalBOM+csvContent));
        link.setAttribute("download", $A.get('$Label.c.ASI_CTY_CN_Vendor_BiddingList_Download_BiddingList_CSVName'));
        document.body.appendChild(link); // Required for FF

        link.click();
    },

    // Tips public function
    show:function(title, type, Msg){
        //  'error', 'warning', 'success', or 'info'. The default is 'other'
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message":Msg
        });
        toastEvent.fire();
    },

    // Obj is null? public function
    isEmpty:function(obj){
        if (obj == null || typeof(obj) == 'undefined' || JSON.stringify(obj) === '{}') {
            return true;
        }

        return false;
    }
})