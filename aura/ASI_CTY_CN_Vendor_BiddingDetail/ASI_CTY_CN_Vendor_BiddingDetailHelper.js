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

    getMyPR : function(component, helper) {
        var action = component.get('c.getQuotationInfo');
        action.setParams({
            'quotationId': component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === 'SUCCESS') {
                var data = response.getReturnValue();
                
                if (data != null && typeof(data) != 'undefined') {
                    var itemGroup = data.quotation.ASI_CTY_CN_Vendor_Item_Group__r;
                    if (this.isEmpty(itemGroup)) {
                        data.quotation.ASI_CTY_CN_Vendor_Item_Group__r = {};
                    }

                    var itemGroupCode = data.quotation.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c;
                    if (this.isEmpty(itemGroupCode)) {
                        data.quotation.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_NoItemGroupCode');
                    }

                    var itemGroupChineseName = data.quotation.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Chinese_Name__c;
                    if (this.isEmpty(itemGroupChineseName)) {
                        data.quotation.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Chinese_Name__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_No_ItemGroup_ChineseName');
                    }

                    var itemGroupEnglishName = data.quotation.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Eng_Name__c;
                    if (this.isEmpty(itemGroupEnglishName)) {
                        data.quotation.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Eng_Name__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_No_ItemGroup_EngName');
                    }

                    var itemGroupRemark = data.quotation.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Remark__c;
                    if (this.isEmpty(itemGroupRemark)) {
                        data.quotation.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Remark__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_NoItemGroupRemark');
                    }

                    var quotationRemark = data.quotation.ASI_CTY_CN_Vendor_Remark__c;
                    if (this.isEmpty(quotationRemark)) {
                        data.quotation.ASI_CTY_CN_Vendor_Remark__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_NoRemark');
                    }

                    var quotationRejectReason = data.quotation.ASI_CTY_CN_Vendor_Reject_Reason__c;
                    if (this.isEmpty(quotationRejectReason)) {
                        data.quotation.ASI_CTY_CN_Vendor_Reject_Reason__c = '';
                    }

                    var samplePrice = data.quotation.ASI_CTY_CN_Vendor_Sample__c;
                    if (this.isEmpty(samplePrice)) {
                        data.quotation.ASI_CTY_CN_Vendor_Sample__c = '';
                    }

                    var modelPrice = data.quotation.ASI_CTY_CN_Vendor_Model__c;
                    if (this.isEmpty(samplePrice)) {
                        data.quotation.ASI_CTY_CN_Vendor_Model__c = '';
                    }

                    var address = data.quoteLineItem;
                    var totalFreight  = 0;
                    if (!this.isEmpty(address) && address.length > 0) {
                        for (var item of address) {
                            if (typeof(item.ASI_CTY_CN_Vendor_Freight__c) != 'undefined') {
                                totalFreight = totalFreight + parseFloat(item.ASI_CTY_CN_Vendor_Freight__c);
                            }
                        }
                    }
                    data.quotation.ASI_CTY_CN_Vendor_Total_Freight__c = totalFreight;

                    data.itemGroup = data.quotation.ASI_CTY_CN_Vendor_Item_Group__r;

                    if (!this.isEmpty(data.quotation.ASI_CTY_CN_Vendor_Deadline_Date__c)) {
                        if (data.quotation.ASI_CTY_CN_Vendor_Deadline_Date__c < $A.localizationService.formatDate(new Date(), "yyyy-MM-dd")) {
                            component.set('v.isExpired', true);
                        }
                    }

                    // handle po data, calculate the number of writed SIR number
                    if (data.poList != null && typeof(data.poList) != 'undefined' && data.poList.length > 0) {
                        for (var po of data.poList) {
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
                                    unitPrice = ppl.ASI_MFM_Unit_Price__c;
                                } 
                            }
                            po.TotalQty = totalQty;
                            po.ActualQty = actualQty;
                            po.UnitPrice = unitPrice;
                        };

                        component.set('v.poList', JSON.parse(JSON.stringify(data.poList)));
                    }
                    
                    console.info(data);
                    component.set('v.PR', data);
                    component.set('v.Quotation', JSON.parse(JSON.stringify(component.get("v.PR.quotation"))));
                    component.set('v.Buyer', JSON.parse(JSON.stringify(component.get("v.PR.quotation.Quotations_quotation__r[0].ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Approval_Buyer__r"))));
                    component.set('v.Address', JSON.parse(JSON.stringify(component.get("v.PR.quoteLineItem"))));

                    var temp = [];
                    var fileList = data.fileList;
                    if (!this.isEmpty(fileList)) {
                        temp.push(JSON.parse(JSON.stringify(fileList)));
                    }
                    console.info('---temp---')
                    console.info(temp);
                    component.set('v.fileList', temp);
                    this.initButtonIsPriv(component);
                    // The background data will be processed, and the number 0 of the backup object will be replaced by the "" string
                    this.initTempData(component);  
                    component.set('v.showSpinner', false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    initButtonIsPriv : function(component) {
        var quotation = component.get('v.PR.quotation');
        var status = quotation.ASI_CTY_CN_Vendor_Status__c;
        var resultStatus = quotation.ASI_CTY_CN_Vendor_Result_Status__c;
        var confirm = quotation.ASI_CTY_CN_Vendor_IsConfirmed__c;
        if (resultStatus == $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Win_Bid')) {
            component.set('v.editButtonPriv', false);
        } else if (confirm) {
            component.set('v.editButtonPriv', false);
        } else {
            component.set('v.editButtonPriv', true);
        }

        if (status == $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Status_Completed')) {
            component.set('v.status', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Status_Completed'));
            component.set('v.isApply', true);
        } else {
            component.set('v.isApply', false);
        }

        if (status == $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Status_Rejected')) {
            component.set('v.status', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Status_Rejected'));
        } else if (status == $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Status_Pending')) {
            component.set('v.status', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Status_Pending'));
        }

        if (resultStatus == $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Win_Bid')) {
            component.set('v.status', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Win_Bid'));
            component.set('v.isApply', false);
        } else if (resultStatus == $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Fail_Bid')) {
            component.set('v.isApply', false);
            component.set('v.status', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Fail_Bid'));
        } else if (resultStatus == $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Abandon_Bid')) {
            component.set('v.status', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Abandon_Bid'));
        } else if (resultStatus == $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Sample_Bid')) {
            component.set('v.isApply', false);
            component.set('v.status', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Sample_Bid'));
        }

        var buyer = component.get('v.Buyer');
        if (component.get('v.isExpired')) {
            component.set('v.isApply', false);
            component.set('v.status', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_OverQuotationDeadLineTime_Tips') + buyer.Name);
        }

        if (confirm && resultStatus != $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Win_Bid')) {
            component.set('v.isApply', false);
            component.set('v.status', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_SampleModelPriceConfrim_Tips'));
        }

        var poList = component.get('v.poList');
        if (poList.length > 0) {
            component.set('v.status', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_GeneratePO'));
        }

    },

    initTempData : function(component) {
        var quotationTemp = component.get('v.Quotation');

        var remark = quotationTemp.ASI_CTY_CN_Vendor_Remark__c;
        if (this.isEmpty(remark) || remark === $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_NoRemark')) {
            quotationTemp.ASI_CTY_CN_Vendor_Remark__c = '';
        }

        component.set('v.Quotation', quotationTemp);
    },

    navigateToURL: function (url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/" + url
        });
        urlEvent.fire();
    },
    
    /*
     * submitPR
     * TO DO: call the lightning page
     */
    submitPR: function (row, helper) {
        helper.navigateToURL('shopping-cart?orderId=' + row.Id);
    },

    handleTotalPrice: function (component) {
        var quotation = component.get('v.Quotation');
        var address = component.get('v.Address');
        var quotationine = component.get('v.PR.quotation');
        var totalAmount = 0;
        var totalQty = parseInt(quotationine.ASI_CTY_CN_Vendor_Total_Quantity__c);
        var singlePrice = parseFloat(quotation.ASI_CTY_CN_Vendor_Unitl_Price__c);
        var sampleFee = parseFloat(quotation.ASI_CTY_CN_Vendor_Sample__c);
        var modelFee = parseFloat(quotation.ASI_CTY_CN_Vendor_Model__c);
        var delivery = 0;

        for (var addr of address) {
            if (this.isEmpty(addr.ASI_CTY_CN_Vendor_Freight__c) || addr.ASI_CTY_CN_Vendor_Freight__c === '') {
                addr.ASI_CTY_CN_Vendor_Freight__c = 0;
            }
            delivery = delivery + parseFloat(addr.ASI_CTY_CN_Vendor_Freight__c);
        }

        if (singlePrice == null || singlePrice === '' || isNaN(singlePrice)) {
            singlePrice = 0;
        }
        if (sampleFee == null || sampleFee === '' || isNaN(sampleFee)) {
            sampleFee = 0;
        }
        if (modelFee == null || modelFee === '' || isNaN(modelFee)) {
            modelFee = 0;
        }

        var r = /^\d+$/;
        if (totalAmount.toString().indexOf('.') != -1 && r.test(parseFloat(totalAmount))) {
            totalAmount =  (singlePrice * totalQty + sampleFee + modelFee + delivery)
        } else {
            totalAmount =  (singlePrice * totalQty + sampleFee + modelFee + delivery).toFixed(2);
        }
        console.info('totalAmount =' + totalAmount);
        component.set('v.Quotation.ASI_CTY_CN_Vendor_Total_Freight__c', delivery.toFixed(2));
        component.set('v.Quotation.ASI_CTY_CN_Vendor_Total_Price__c', totalAmount);
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

    prValidations : function(component) {
        var quotation = component.get("v.Quotation");
        var isNeedDeadLine = component.get('v.isNeedDeadLine');
        var r = /^\d+$/;

        var inputCmp;
        var flag = true;

        if (this.floatValidations(quotation.ASI_CTY_CN_Vendor_Unitl_Price__c, 2)) {
            inputCmp = component.find('ASI_CTY_CN_Vendor_Unitl_Price__c');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid(); 
            flag = false;
        }
        if (this.floatValidations(quotation.ASI_CTY_CN_Vendor_Sample__c, 2) && quotation.ASI_CTY_CN_Vendor_Is_Need_Sample__c) {
            inputCmp = component.find('ASI_CTY_CN_Vendor_Sample__c');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        }
        if (isNeedDeadLine && typeof(quotation.ASI_CTY_CN_Vendor_DeadLine__c) === 'undefined') {
            quotation.ASI_CTY_CN_Vendor_DeadLine__c = '';
        }
        if ((typeof(quotation.ASI_CTY_CN_Vendor_DeadLine__c) != 'undefined' && (this.integerValidations(quotation.ASI_CTY_CN_Vendor_DeadLine__c) || parseInt(quotation.ASI_CTY_CN_Vendor_DeadLine__c) === 0 || quotation.ASI_CTY_CN_Vendor_DeadLine__c === '')) && isNeedDeadLine) {
            inputCmp = component.find('ASI_CTY_CN_Vendor_DeadLine__c');
            if (isNeedDeadLine && parseInt(quotation.ASI_CTY_CN_Vendor_DeadLine__c) === 0) {
                inputCmp.set('v.value', '');
            }
            
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            component.set('v.deadLineHelpTextClassName', 'DeadLineHelpText1');
            flag = false;
        }
        if (this.floatValidations(quotation.ASI_CTY_CN_Vendor_Model__c, 2) && quotation.ASI_CTY_CN_Vendor_Is_Need_Model__c) {
            inputCmp = component.find('ASI_CTY_CN_Vendor_Model__c');
            inputCmp.set('v.validity', {valid:false});
            inputCmp.showHelpMessageIfInvalid();
            flag = false;
        }
        
        var address = component.get("v.Address");
        if (address != null && typeof(address) != 'undefined' && address.length > 0) {
            for (var i = 0; i < address.length; i++) {
                if (this.floatValidations(address[i].ASI_CTY_CN_Vendor_Freight__c, 2)) {
                    var inputCmp = component.find('ASI_CTY_CN_Vendor_Freight__c');
                    if (this.isArray(inputCmp)) {
                        inputCmp[i].set('v.validity', {valid:false});
                        inputCmp[i].showHelpMessageIfInvalid();
                    } else {
                        inputCmp.set('v.validity', {valid:false});
                        inputCmp.showHelpMessageIfInvalid();
                    }
                    flag = false;
                }
            }
        }

        return flag;
    },

    prValidationsNoTips : function(component) {
        var quotation = component.get("v.Quotation");
        var isNeedDeadLine = component.get('v.isNeedDeadLine');
        var r = /^\d+$/;
        var flag = true;

        var unitPrice = quotation.ASI_CTY_CN_Vendor_Unitl_Price__c;
        if (unitPrice === '' || typeof(unitPrice) === 'undefined') {
            flag = false;
        } else if (this.floatValidations(unitPrice, 2)) {
            flag = false;
        }

        var samplePrice = quotation.ASI_CTY_CN_Vendor_Sample__c;
        if (samplePrice === '' || typeof(samplePrice) === 'undefined') {
            flag = false;
        } else if (this.floatValidations(samplePrice, 2) && quotation.ASI_CTY_CN_Vendor_Is_Need_Sample__c) {
            flag = false;
        }

        var deadLine = quotation.ASI_CTY_CN_Vendor_DeadLine__c;
        if (isNeedDeadLine) {
            if (typeof(deadLine) === 'undefined') {
                deadLine = '';
            }
            
            if ((deadLine === '' || typeof(deadLine) === 'undefined')) {
                flag = false;
            } else if (this.integerValidations(deadLine)) {
                flag = false;
            }
        }

        var modelPrice = quotation.ASI_CTY_CN_Vendor_Model__c;
        if (modelPrice === '' || typeof(modelPrice) === 'undefined') {
            flag = false;
        } else if (this.floatValidations(modelPrice, 2) && quotation.ASI_CTY_CN_Vendor_Is_Need_Model__c) {
            flag = false;
        }
        
        var address = component.get("v.Address");
        if (address != null && typeof(address) != 'undefined' && address.length > 0) {
            for (var i = 0; i < address.length; i++) {
                var freight = address[i].ASI_CTY_CN_Vendor_Freight__c;
                if (freight === '' || typeof(freight) === 'undefined') {
                    flag = false;
                } else if (this.floatValidations(freight, 2)) {
                    flag = false;
                }
            }
        }

        return flag;
    },

    integerValidations : function(target) {
        var r = /^\d+$/;
        target = target.toString().trim();
        if (target != '') {
            if (target.toString().indexOf('.') != -1) {
                if (parseFloat(target).toString().indexOf('.') != -1) {
                    if (parseFloat(target).toString().split('.')[1].length > 0
                        || !r.test(parseFloat(target))) {
                        return true;
                    }
                } else {
                    if (target.toString().split('.')[1].length == 0) {
                        return true;
                    }
                }
            }
        }

        return false;
    },

    floatValidations : function(target, index) {
        target = target.toString().trim();
        if (target != '') {
            if (target.toString().indexOf('.') != -1) {
                if (parseFloat(target).toString().indexOf('.') != -1) {
                    if (parseFloat(target).toString().split('.')[1].length > parseInt(index)) {
                        return true;
                    }
                } else {
                    if (target.toString().split('.')[1].length == 0) {
                        return true;
                    }
                }
            }
        }

        return false;
    },

    // Obj is null? public function
    isEmpty:function(obj){
        if (obj == null || typeof(obj) == 'undefined' || JSON.stringify(obj) === '{}') {
            return true;
        }

        return false;
    },

    deadLineInputInit : function(component) {
        var r = /^\d+$/;
        var quotation = component.get('v.Quotation');
        var isNeedDeadLine = component.get('v.isNeedDeadLine');

        if (isNeedDeadLine && typeof(quotation.ASI_CTY_CN_Vendor_DeadLine__c) === 'undefined') {
            quotation.ASI_CTY_CN_Vendor_DeadLine__c = '';
        }
        if (!this.integerValidations(quotation.ASI_CTY_CN_Vendor_DeadLine__c) && (quotation.ASI_CTY_CN_Vendor_DeadLine__c != '' && isNeedDeadLine)) {
            component.set('v.deadLineHelpTextClassName', 'DeadLineHelpText');
        } else {
            component.set('v.deadLineHelpTextClassName', 'DeadLineHelpText1');
        }
    },

    isArray : function(o) {
        return Object.prototype.toString.call(o) === '[object Array]';
    }
})