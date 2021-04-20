({
    // Loading all PO for the current supplier
    getMyPOs : function(component, helper) {
        var action = component.get('c.getPOInfo');
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === 'SUCCESS') {
                var data = response.getReturnValue();

                // handle po data, calculate the number of writed SIR number
                for (var po of data) {
                    var ppls = po.PO_POSM_Lines__r;
                    var sirs = po.Stock_In_Requests__r;
                    var totalQty = 0;
                    var actualQty = 0;
                    var unitPrice = 0.000;
                    var itemGroup;
                    if (ppls != null && ppls.length > 0) {
                        for (var ppl of ppls) {
                            if (typeof(ppl.ASI_MFM_Quantity__c) != 'undefined') {
                                totalQty = totalQty + ppl.ASI_MFM_Quantity__c;
                            }
                            if (sirs != null && sirs.length > 0) {
                                for (var sir of sirs) {
                                    var pplNum = sir.ASI_MFM_PO_POSM_Line_Number__c;
                                    if (pplNum != null && typeof(pplNum) != 'undefined') {
                                        if (sir.ASI_MFM_PO_POSM_Line_Number__c == ppl.Id && typeof(sir.ASI_MFM_Lot_Quantity__c) != 'undefined') {
                                            actualQty = actualQty + sir.ASI_MFM_Lot_Quantity__c;
                                        }
                                    } 
                                }
                            }
                            itemGroup = ppl.ASI_MFM_Item_Group__r;
                            unitPrice = ppl.ASI_MFM_Unit_Price__c;
                        } 
                    }
                    po.TotalQty = totalQty;
                    po.ActualQty = actualQty;
                    po.UnitPrice = unitPrice;
                    po.ItemGroup = itemGroup;
                    po.showItemGroup = false;

                    if (po.TotalQty == po.ActualQty) {
                        po.ASI_CTY_CN_Vendor_Fill_Sir_Str = $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_SIR_Status_Completed');
                    } else {
                        po.ASI_CTY_CN_Vendor_Fill_Sir_Str = $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_SIR_Status_No_Completed');
                    }

                    if (po.CreatedDate != null && po.CreatedDate != '' && typeof(po.CreatedDate) != 'undefined') {
                        po.CreatedDate = po.CreatedDate.split('T')[0];
                    }
                };
                console.info(data);
                component.set('v.showSpinner', false);
                component.set('v.allPOs', data);

                // Refresh page
                this.renderPage(component, '', '');
            }
        });
        $A.enqueueAction(action);
    },

    // Jump page public function
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
            records = component.get("v.allPOs");

        if (sortField != field || flag) {
            sortAsc = false;
        } else {
            sortAsc = !sortAsc;
        }
        console.info('sortAsc: ' + sortAsc);

        // Filter the data according to the search criteria
        records.sort(function(a,b){
            if (field.indexOf('.') != -1) {
                var itemGroup = field.split('.')[0];
                var fieldName = field.split('.')[1];
                var t3 = a[itemGroup];
                var t4 = b[itemGroup];
                if (typeof(t3) != 'undefined' && typeof(t4) != 'undefined') {
                    var t1 = t3[fieldName] == t4[fieldName],
                    t2 = (!t3[fieldName] && t4[fieldName]) || (t3[fieldName] < t4[fieldName]);
                    return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
                } else {
                    return 1;
                }
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
        component.set("v.allPOs", records);
        component.set("v.page", 1);
        component.set('v.showSpinner', false);
        this.renderPage(component, startDate, endDate);
    },

    // Reloaded PO List
    renderPage: function(component, startDate, endDate) {
        // Check whether the string contains Chinese
        var reg = new RegExp("[\\u4E00-\\u9FFF]+","g");

        var records = component.get("v.allPOs"),
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
                        if (item.ASI_MFM_Status__c != null && typeof(item.ASI_MFM_Status__c) != 'undefined') {
                            if (item.ASI_MFM_Status__c.toLowerCase().includes(lowerTerm)) {
                                return true;
                            }
                        }

                        if (item.ASI_CTY_CN_Vendor_Fill_Sir_Str != null && typeof(item.ASI_CTY_CN_Vendor_Fill_Sir_Str) != 'undefined') {
                            if (item.ASI_CTY_CN_Vendor_Fill_Sir_Str.toLowerCase().includes(lowerTerm)) {
                                return true;
                            }
                        }
                        
                        var flag = false;  
                        if (item.ItemGroup != null && typeof(item.ItemGroup) != 'undefined') {
                            if (item.ItemGroup.Name != null && typeof(item.ItemGroup.Name) != 'undefined') {
                                if (item.ItemGroup.Name.includes(term)) {
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

        // Item Group is not displayed in PO by default
        pageRecords.forEach(function(pageRecord){
            pageRecord.showItemGroup = false;
        });
        component.set("v.POs", pageRecords);
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

    // download PO List according to start and end date
    downloadPODetails : function (component, startDate, endDate) {
        var records = component.get("v.allPOs");
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
        var initDetail = [$A.get('$Label.c.ASI_CTY_CN_Vendor_PO_Number'), 
        $A.get('$Label.c.ASI_CTY_CN_Vendor_PO_Start_Date'), $A.get('$Label.c.ASI_CTY_CN_Vendor_PO_Status'), $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_SIR_Status'), $A.get('$Label.c.ASI_CTY_CN_Vendor_PO_Total_Qty'), 
        $A.get('$Label.c.ASI_CTY_CN_Vendor_PO_TOV_Total_Qty'), $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_WritedSIRQty'), $A.get('$Label.c.ASI_CTY_CN_Vendor_PO_Total_Amount'), 
        $A.get('$Label.c.ASI_CTY_CN_Vendor_PO_Paid_Amount'), $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_ItemGroup_Number'), 
        $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_ItemGroup_Name'), $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_ItemGroup_UnitPrice'), 
        $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_ItemGroup_Quantity'), $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_WritedSIRQty')];
        resultDetails.push(initDetail);
        records.forEach(function(item) {
            var arr = [];
            arr.push(item.Name);
            arr.push(item.CreatedDate);
            arr.push(item.ASI_MFM_Status__c);
            arr.push(item.ASI_CTY_CN_Vendor_Fill_Sir_Str);
            arr.push(item.ASI_MFM_Total_Quantity__c);
            arr.push(item.TotalQty);
            arr.push(item.ActualQty);
            arr.push(item.ASI_MFM_CN_PO_Amount_RMB__c);
            arr.push(item.ASI_MFM_Total_Paid_Amount__c);
            if (typeof(item.ItemGroup) == 'undefined') {
                item.ItemGroup = {};
            }
            if (typeof(item.ItemGroup.ASI_MFM_Item_Group_Code__c) == 'undefined') {
                item.ItemGroup.ASI_MFM_Item_Group_Code__c = '';
            }
            arr.push(item.ItemGroup.ASI_MFM_Item_Group_Code__c);
            if (typeof(item.ItemGroup.Name) == 'undefined') {
                item.ItemGroup.Name = '';
            }
            arr.push(item.ItemGroup.Name);
            arr.push(item.UnitPrice);
            arr.push(item.TotalQty);
            arr.push(item.ActualQty);
            resultDetails.push(arr);
        });

        let csvContent = resultDetails.map(e => e.join(",")).join("\n");
        var encodedUri = encodeURI(csvContent);
        var universalBOM = "\uFEFF";
        var link = document.createElement("a");
        link.setAttribute('href', 'data:text/csv; charset=utf-8,' + encodeURIComponent(universalBOM+csvContent));
        link.setAttribute('download', $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_Download_File_Name'));
        document.body.appendChild(link);

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
    }
})