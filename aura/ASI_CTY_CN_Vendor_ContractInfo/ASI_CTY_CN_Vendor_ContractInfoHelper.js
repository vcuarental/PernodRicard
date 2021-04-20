({
	// Get address bar parameters
    getUrlParameter : function(sParam) {
    	var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    },
    
    // Returns the date after the number of days added
    dateAddDays :function(dateStr,dayCount) {
        var tempDate=new Date(dateStr.replace(/-/g,"/"));
        var resultDate=new Date((tempDate/1000+(86400*dayCount))*1000);
        var month = resultDate.getMonth() + 1;
        var date = resultDate.getDate();
        if (month < 10) {
            month = '0' + month;
        }
        if (date < 10) {
            date = '0' + date;
        }
        var resultDateStr=resultDate.getFullYear()+"-"+(month)+"-"+(date);
        return resultDateStr;
    },

    // PO info init data
    getInitDate : function(component) {
        var action = component.get('c.getPoInfo');
        action.setParams({
            'contractId' : component.get('v.recordId')
        });

        action.setCallback(this, function(response){
            var status = response.getState();
            if (status === 'SUCCESS') {
                var data = response.getReturnValue();
                var totalQty = 0;
                var actualQty = 0;
                console.info(data);
                console.info('-------');
                if (data.po) {
                    console.info(data.po);
                    data.po.ReceiveDate = '';

                    var ppls = data.po.PO_POSM_Lines__r;
                    var sirs = data.po.Stock_In_Requests__r;
                    var sirsApproval = data.sirs;

                    if (sirs != null && typeof(sirs) != 'undefined' && sirs.length > 0) {
                        for (var s of sirs) {
                            if (sirsApproval != null && typeof(sirsApproval) != 'undefined' && sirsApproval.length > 0) {
                                for (var sirAppr of sirsApproval) {
                                    if (s.Id == sirAppr.Id && typeof(sirAppr.ProcessSteps) != 'undefined') {
                                        s.ProcessSteps = sirAppr.ProcessSteps;
                                    }
                                }
                            }
                        }
                    }

                    if (ppls != null && ppls.length > 0 && typeof(ppls) != 'undefined') {
                        for (var ppl of ppls) {
                            if ( typeof(ppl.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Remark__c) == "undefined") {
                                ppl.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Remark__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_NoRemark');
                            }
                            if ( typeof(ppl.ASI_MFM_Delivery_Address_Warehouse__r) == "undefined") {
                                ppl.ASI_MFM_Delivery_Address_Warehouse__r = {
                                    'Name': $A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_NoDelivery_Address')
                                };
                            }
                            if ( typeof(ppl.ASI_MFM_Delivery_Address_Outlet__r) == "undefined") {
                                ppl.ASI_MFM_Delivery_Address_Outlet__r = {
                                    'Name': $A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_NoDelivery_Address')
                                };
                            }
                            
                            if ( typeof(ppl.ASI_MFM_Detail_Address__c) == "undefined") {
                                ppl.ASI_MFM_Detail_Address__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_NoDelivery_Address');
                            }

                            ppl.sirsInfo = [];
                            var PPLActualQty = 0;
                            if (sirs != null && sirs.length > 0 && typeof(sirs) != 'undefined') {
                                for (var sir of sirs) {
                                    if (sir != null && typeof(sir) != 'undefined') {
                                        if (sir.ASI_MFM_PO_POSM_Line_Number__c == ppl.Id) {
                                            if (typeof(sir.ASI_MFM_Lot_Quantity__c) != 'undefined') {
                                                PPLActualQty = PPLActualQty + parseInt(sir.ASI_MFM_Lot_Quantity__c);
                                                actualQty = actualQty + parseInt(sir.ASI_MFM_Lot_Quantity__c);
                                            }

                                            if (typeof(sir.ASI_MFM_Delivery_Address__c) == 'undefined') {
                                                if ( typeof(ppl.ASI_MFM_Delivery_Address_Warehouse__r.Id) != "undefined") {
                                                    sir.ASI_MFM_Delivery_Address__c = ppl.ASI_MFM_Delivery_Address_Warehouse__r.Name;
                                                }
                                                if ( typeof(ppl.ASI_MFM_Delivery_Address_Outlet__r.Id) != "undefined") {
                                                    sir.ASI_MFM_Delivery_Address__c = ppl.ASI_MFM_Delivery_Address_Outlet__r.Name;
                                                }
                                            }

                                            if (typeof(sir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c) == 'undefined') {
                                                sir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Comfirmed');
                                            }

                                            if (typeof(sir.ProcessSteps) != 'undefined' && sir.ProcessSteps != null && sir.ProcessSteps.length > 0) {
                                                var comments = sir.ProcessSteps[0].Comments;
                                                if (typeof(comments) == 'undefined' || comments == '') {
                                                    comments = '';
                                                }
                                                sir.comments = comments;
                                            }
                                            ppl.sirsInfo.push(sir);
                                        }
                                    }
                                }
                            }
                            ppl.ActualQty = PPLActualQty;
                            
                            ppl.ShowSIR = true;
                            data.po.MinimumQty = ppl.ASI_MFM_Minimum_Order_Qty__c;
                            totalQty = totalQty + ppl.ASI_MFM_Quantity__c;

                            var itemGroup = ppl.ASI_MFM_Item_Group__r;
                            itemGroup.ASI_MFM_Item_Group_Code__c = ppl.ASI_MFM_Item_Group_Code__c;
                            data.po.ItemGroup = itemGroup;
                        }
                    }
                    data.po.TotalQty = totalQty;
                    data.po.ActualQty = actualQty;

                    component.set('v.POInfo', data.po);
                    component.set('v.QuotationInfo', data.q);
                    component.set('v.showSpinner', false);
                }
            } else {
                helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_POList_Tips'), 
                    'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_Tips_Exception'));
            }
        });
        component.set('v.showSpinner', false);
        $A.enqueueAction(action);
    },

    // When creating SIR or modifying SIR information, refresh page data again
    loadingSIR: function(component) {
        var posms = component.get('v.POInfo');
        var ppls = posms.PO_POSM_Lines__r;
        var actualQty = 0;
        if (ppls != null && ppls.length > 0 && typeof(ppls) != 'undefined') {
            for (var ppl of ppls) {
                var sirs = ppl.sirsInfo;
                var PPLActualQty = 0;
                if (sirs != null && sirs.length > 0 && typeof(sirs) != 'undefined') {
                    for (var sir of sirs) {
                        if (sir != null && typeof(sir) != 'undefined') {
                            if (typeof(sir.ASI_MFM_Lot_Quantity__c) != 'undefined') {
                                PPLActualQty = PPLActualQty + parseInt(sir.ASI_MFM_Lot_Quantity__c);
                                actualQty = actualQty + parseInt(sir.ASI_MFM_Lot_Quantity__c);
                            }

                            if (typeof(sir.ASI_MFM_Delivery_Address__c) == 'undefined') {
                                sir.ASI_MFM_Delivery_Address__c = ppl.ASI_MFM_Delivery_Address_Warehouse__r.Name;
                            }

                            if (typeof(sir.ProcessSteps) != 'undefined' && sir.ProcessSteps != null && sir.ProcessSteps.length > 0) {
                                var comments = sir.ProcessSteps[0].Comments;
                                if (typeof(comments) == 'undefined' || comments == '') {
                                    comments = '';
                                }
                                sir.comments = comments;
                            }
                        }
                    }
                }
                ppl.ActualQty = PPLActualQty;
            }
        }
        posms.ActualQty = actualQty;

        component.set('v.POInfo', posms);
    },

    // Control the folding and shrinking as public function
    handleExpand : function(component, expandField) {
        if (expandField === 'poInfo') {
            component.set('v.poInfoExpanded', !component.get('v.poInfoExpanded'));
        } else if (expandField === 'itemGroupInfo') {
            component.set('v.itemGroupInfoExpanded', !component.get('v.itemGroupInfoExpanded'));
        } else if (expandField === 'polineItemPosm') {
            component.set('v.polineItemPosmExpanded', !component.get('v.polineItemPosmExpanded'));
        } else if (expandField === 'address') {
            component.set('v.addressExpanded', !component.get('v.addressExpanded'));
        } else if (expandField === 'polineItem') {
            component.set('v.polineItemExpanded', !component.get('v.polineItemExpanded'));
        }
    },

    // Clean SIR and reset
    cleanSIR : function(component) {
        var sirInfo = {
            'ASI_MFM_Net_Weight__c' : '', 
            'ASI_Delivery_Date__c' : '', 
            'ASI_MFM_Box_Size_M3__c' : '', 
            'ASI_MFM_Min_Unit_Price__c' : '', 
            'ASI_MFM_Qty_Per_Bag_Box__c': '', 
            'ASI_MFM_Total_Qty_Per_Bag_Box__c': '', 
            'ASI_MFM_Qty_Per_Box__c': '', 
            'ASI_MFM_Fraction_Qty__c': '', 
            'ASI_MFM_Total_Number_Of_Box__c': '', 
            'ASI_MFM_Lot_Number__c' : '',
            'ASI_MFM_Box_Net_Weight__c': '', 
            'ASI_MFM_Length__c' : '', 
            'ASI_MFM_Width__c' : '', 
            'ASI_MFM_Height__c' : '' 
        };
        component.set("v.SIRInfo", sirInfo);
    },
    
    // Page tips as public function
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

    // Get base data of SIR image
    getItemGroupImage : function(component, sirInfo) {
        var action = component.get('c.getSIRImage');
        var sirInfoId = sirInfo.Id;
        if (typeof(sirInfoId) === 'undefined') {
            sirInfoId = '';
        }
        action.setParams({
            'itemGroupId' : sirInfo.ItemGroupId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                if (data != null && JSON.stringify(data) != '{}') {
                    console.info(data);
                    var fileList = [];
                    var result = {};
                    result.Id = data.Id;
                    result.name =  data.Title;
                    result.size = data.Size;
                    component.set('v.file', result);
                    fileList.push(result);
                    component.set('v.fileList', fileList);
                } else {
                    component.set('v.fileList', []);
                }

                component.set('v.isShowModal', !component.get('v.isShowModal'));
                component.set("v.SIRInfo", JSON.parse(JSON.stringify(sirInfo)));
                component.set('v.showSpinner', false);
            } else{
                console.log('get SIR image error,please try again later...');
            }
        });
        
        $A.enqueueAction(action);
    },

    // Verify the validity of SIR data
    sirValidations : function(component) {
        var sir = component.get("v.SIRInfo");
        var r = /^\d+$/;

        var inputCmp;
        var flag = true;
        if (sir.ASI_MFM_Net_Weight__c === '' || (parseFloat(sir.ASI_MFM_Net_Weight__c).toString().indexOf('.') != -1 && parseFloat(sir.ASI_MFM_Net_Weight__c).toString().split(".")[1].length > 3)) {
            inputCmp = component.find('Net_Weight');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        }
        if (sir.ASI_MFM_Length__c === '' || (parseFloat(sir.ASI_MFM_Length__c).toString().indexOf('.') != -1 && parseFloat(sir.ASI_MFM_Length__c).toString().split(".")[1].length > 3)) {
            inputCmp = component.find('Length');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        }
        if (sir.ASI_MFM_Box_Net_Weight__c === '' || (parseFloat(sir.ASI_MFM_Box_Net_Weight__c).toString().indexOf('.') != -1 && parseFloat(sir.ASI_MFM_Box_Net_Weight__c).toString().split(".")[1].length > 3)) {
            inputCmp = component.find('Box_Net_Weight');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        }
        if (sir.ASI_MFM_Width__c === '' || (parseFloat(sir.ASI_MFM_Width__c).toString().indexOf('.') != -1 && parseFloat(sir.ASI_MFM_Width__c).toString().split(".")[1].length > 3)) {
            inputCmp = component.find('Width');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        }
        if (sir.ASI_MFM_Height__c === '' || (parseFloat(sir.ASI_MFM_Height__c).toString().indexOf('.') != -1 && parseFloat(sir.ASI_MFM_Height__c).toString().split(".")[1].length > 3)) {
            inputCmp = component.find('Height');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        }
        if (sir.ASI_MFM_Qty_Per_Bag_Box__c.toString() === '') {
            inputCmp = component.find('Qty_Per_Bag_Box');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        } else {
            if (!r.test(parseFloat(sir.ASI_MFM_Qty_Per_Bag_Box__c))) {
                inputCmp = component.find('Qty_Per_Bag_Box');
                inputCmp.set('v.validity', {valid:false});
                inputCmp.showHelpMessageIfInvalid();
                flag = false;
            }
        }
        if (sir.ASI_MFM_Total_Qty_Per_Bag_Box__c.toString() === '') {
            inputCmp = component.find('Total_Qty_Per_Bag_Box');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        } else {
            if (!r.test(parseFloat(sir.ASI_MFM_Total_Qty_Per_Bag_Box__c))) {
                inputCmp = component.find('Total_Qty_Per_Bag_Box');
                inputCmp.set('v.validity', {valid:false});
                inputCmp.showHelpMessageIfInvalid();
                flag = false;
            }
        }
        if (sir.ASI_MFM_Qty_Per_Box__c.toString() === '') {
            inputCmp = component.find('Qty_Per_Box');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        } else {
            if (!r.test(parseFloat(sir.ASI_MFM_Qty_Per_Box__c))) {
                inputCmp = component.find('Qty_Per_Box');
                inputCmp.set('v.validity', {valid:false});
                inputCmp.showHelpMessageIfInvalid();
                flag = false;
            }
        }
        if (sir.ASI_MFM_Fraction_Qty__c.toString() === '') {
            inputCmp = component.find('Fraction_Qty');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        } else {
            if (!r.test(parseFloat(sir.ASI_MFM_Fraction_Qty__c))) {
                inputCmp = component.find('Fraction_Qty');
                inputCmp.set('v.validity', {valid:false});
                inputCmp.showHelpMessageIfInvalid();
                flag = false;
            }
        }
        if (sir.ASI_MFM_Total_Number_Of_Box__c.toString() === '') {
            inputCmp = component.find('Total_Number_Of_Box');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        } else {
            if (!r.test(parseFloat(sir.ASI_MFM_Total_Number_Of_Box__c))) {
                inputCmp = component.find('Total_Number_Of_Box');
                inputCmp.set('v.validity', {valid:false});
                inputCmp.showHelpMessageIfInvalid();
                flag = false;
            }
        }
        if (sir.ASI_Delivery_Date__c == null || sir.ASI_Delivery_Date__c === '') {
            inputCmp = component.find('Delivery_Date');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        }
        return flag;
    }
})