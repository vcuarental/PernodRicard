({
    doInit: function(component, event, helper) {
        // this function call on the component load first time
        // call the helper function
        component.set('v.showSpinner', true);
        var Id = helper.getUrlParameter('Id');
        component.set('v.recordId', Id);
        helper.getMyPR(component);
    },

    // Jump to bidding detail page function
    submitBidding : function(component, event, helper) {
        var prId = event.target.id;
        console.info('prId = ' + prId);
        var url = 'biddingdetail?prId=' + prId;
        helper.navigateToURL(url);
    },

    // open writed quotation price dialog
    writeUnitPrice : function(component, event, helper) {
        var r = /^\d+$/;
        var quotation = component.get('v.Quotation');
        var value = quotation.ASI_CTY_CN_Vendor_Unitl_Price__c;
        var flag = false;

        // Initialization DeadLine and DeadLineHelpText value
        if (typeof(value) != 'undefined' && !helper.floatValidations(value, 2) && value != '0') {
            component.set('v.isNeedDeadLine', true);
            flag = true;
        } else {
            component.set('v.isNeedDeadLine', false);
        }

        if (typeof(quotation.ASI_CTY_CN_Vendor_DeadLine__c) == 'undefined' || !helper.integerValidations(quotation.ASI_CTY_CN_Vendor_DeadLine__c) || quotation.ASI_CTY_CN_Vendor_DeadLine__c === '') {
            component.set('v.deadLineHelpTextClassName', 'DeadLineHelpText');
        } else {
            component.set('v.deadLineHelpTextClassName', 'DeadLineHelpText1');
        }

        component.set('v.isShowModal', !component.get('v.isShowModal'));
    },

    // cancel writed quotation price and close dialog
    cancelWriteUnitPrice : function(component, event, helper) {
        component.set('v.isShowModal', !component.get('v.isShowModal'));
        component.set('v.Quotation', JSON.parse(JSON.stringify(component.get("v.PR.quotation"))));
        component.set('v.Address', JSON.parse(JSON.stringify(component.get("v.PR.quoteLineItem"))));

        // Restore data
        helper.initTempData(component);
    },

    // submit quotation price 
    submitWriteUnitPrice : function(component, event, helper) {
        var quotation = component.get("v.Quotation");
        var address = component.get("v.Address");

        // Do not fill in. The default value is 0
        if(quotation.ASI_CTY_CN_Vendor_Unitl_Price__c == '' || typeof(quotation.ASI_CTY_CN_Vendor_Unitl_Price__c) === 'undefined') {
            quotation.ASI_CTY_CN_Vendor_Unitl_Price__c = 0;
        }

        if(quotation.ASI_CTY_CN_Vendor_Sample__c == '' || typeof(quotation.ASI_CTY_CN_Vendor_Sample__c) === 'undefined') {
            quotation.ASI_CTY_CN_Vendor_Sample__c = 0;
        }

        if(quotation.ASI_CTY_CN_Vendor_Model__c == '' || typeof(quotation.ASI_CTY_CN_Vendor_Model__c) === 'undefined') {
            quotation.ASI_CTY_CN_Vendor_Model__c = 0;
        }

        address.forEach(function(item, index){
            var freight = item.ASI_CTY_CN_Vendor_Freight__c;
            if(freight == '' || typeof(freight) === 'undefined') {
                item.ASI_CTY_CN_Vendor_Freight__c = 0;
            }
        });

        component.set('v.Quotation', JSON.parse(JSON.stringify(quotation)));
        component.set('v.Address', JSON.parse(JSON.stringify(address)));

        if (helper.prValidations(component)) {
            component.set('v.isShowModal', !component.get('v.isShowModal'));
            component.set('v.PR.quotation', JSON.parse(JSON.stringify(component.get("v.Quotation"))));
            component.set('v.PR.quoteLineItem', JSON.parse(JSON.stringify(component.get("v.Address"))));
            helper.initTempData(component);
        } else {
            helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info'), 'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info_Tips6'));
        }
    },

    // Image dialog mouse dynamic effect
    mouseoverImageModel : function (component, event, helper) {
        component.set('v.outClass', 'mydiv1');
    },

    mouseoutImageModel : function (component, event, helper) {
        component.set('v.outClass', 'mydiv');
    },

    // When the price changes, recalculate the total price
    countItemGroupAmount : function(component, event, helper) {
        var singlePrice = event.getSource().get('v.value');
        console.info(singlePrice);
        helper.handleTotalPrice(component);
    },

    // open rejected dialog
    openRejectedDialog : function(component, event, helper) {
        var quotation = component.get('v.PR.quotation');
        var status = quotation.ASI_CTY_CN_Vendor_Status__c;
        var resultStatus = quotation.ASI_CTY_CN_Vendor_Result_Status__c;
        if (resultStatus == $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Abandon_Bid')) {
            helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info'), 'WARNING', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info_Tips1'));
        } else {
            component.set('v.Quotation', JSON.parse(JSON.stringify(component.get('v.PR.quotation'))));
            component.set('v.isShowRejectedModal', !component.get('v.isShowRejectedModal'));
        }
    },
    cancelRejectedDialog : function(component, event, helper) {
        component.set('v.isShowRejectedModal', !component.get('v.isShowRejectedModal'));
    },
    submitRejectedDialog : function(component, event, helper) {
        var quote = JSON.parse(JSON.stringify(component.get('v.Quotation')));
        if (helper.isEmpty(quote) || quote.ASI_CTY_CN_Vendor_Result_Status__c == $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Abandon_Bid')) {
            component.set('v.isShowRejectedModal', !component.get('v.isShowRejectedModal'));
            return;
        }

        if (quote.ASI_CTY_CN_Vendor_Reject_Reason__c == '') {
            helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info'), 'ERROR', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info_Tips2'));
            return;
        }

        if (quote.ASI_CTY_CN_Vendor_Status__c != $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Status_Rejected')) {
            var flag = window.confirm($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info_Confirm1'));
            if (flag) {
                if (!helper.isEmpty(quote)) {
                    delete quote.ASI_CTY_CN_Vendor_Total_Price__c;
                    delete quote.ASI_CTY_CN_Vendor_Total_Freight__c;
                    delete quote.Quotations_quotation__r;
                }

                component.set('v.showSpinner', true);

                var action = component.get('c.submitQuoteStatus');
                action.setParams({
                    'quotationJson' : JSON.stringify(quote),
                    'status' : 'Rejected'
                });
                action.setCallback(this, function(response) {
                    var status = response.getState();
                    if (status == 'SUCCESS') {
                        var data = response.getReturnValue();
                        console.info(data);
                        if (data.status == 1) {
                            helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info'), 'SUCCESS', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info_Tips3'));
                            var quote = component.get('v.Quotation');
                            quote.ASI_CTY_CN_Vendor_Status__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Status_Rejected');
                            component.set('v.PR.quotation', quote);
                            helper.initButtonIsPriv(component);
                            component.set('v.isShowRejectedModal', !component.get('v.isShowRejectedModal'));
                        } else {
                            helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info'), 'ERROR', data.message);
                        }
                        component.set('v.showSpinner', false);
                    }
                });
                $A.enqueueAction(action);
            }
        } else {
            component.set('v.isShowRejectedModal', !component.get('v.isShowRejectedModal'));
        }
    },
    deadLineInputBlur : function(component, event, helper) {
        helper.deadLineInputInit(component);
    },
    giveUpBidding : function(component, event, helper) {
        var flag = window.confirm($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info_Confirm2'));
        if (flag) {
            var quote = JSON.parse(JSON.stringify(component.get('v.Quotation')));
            if (!helper.isEmpty(quote)) {
                delete quote.ASI_CTY_CN_Vendor_Total_Price__c;
                delete quote.ASI_CTY_CN_Vendor_Total_Freight__c;
                delete quote.Quotations_quotation__r;
            }

            component.set('v.showSpinner', true);

            var action = component.get('c.submitQuoteStatus');
            action.setParams({
                'quotationJson' : JSON.stringify(quote),
                'status' : 'GiveUp'
            });
            action.setCallback(this, function(response) {
                var status = response.getState();
                if (status == 'SUCCESS') {
                    var data = response.getReturnValue();
                    console.info(data);
                    if (data.status == 1) {
                        helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info'), 'SUCCESS', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info_Tips4'));
                        var quote = component.get('v.Quotation');
                        quote.ASI_CTY_CN_Vendor_Result_Status__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Abandon_Bid');
                        quote.ASI_CTY_CN_Vendor_Reject_Reason__c = '';
                        component.set('v.PR.quotation', quote);
                        helper.initButtonIsPriv(component);
                    } else {
                        helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info'), 'ERROR', data.message);
                    }
                    component.set('v.showSpinner', false);
                }
            });
            $A.enqueueAction(action);
        }
    },
    submitQuotation : function(component, event, helper) {
        if (helper.prValidationsNoTips(component)) {
            var quotation = JSON.parse(JSON.stringify(component.get('v.PR.quotation')));
            var tips = component.get('v.status');

            var flag = window.confirm($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Current_Status') + ': ' + tips + ',' + $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info_Confirm3'));
            if (flag) {
                var address = JSON.parse(JSON.stringify(component.get('v.PR.quoteLineItem')));
                var mergeQuotation = JSON.parse(JSON.stringify(component.get('v.PR.quotation.Quotations_quotation__r')));
                var mergeQuotationIds = [];
                if (mergeQuotation != null && mergeQuotation.length > 0) {
                    for (var item of mergeQuotation) {
                        mergeQuotationIds.push(item.Id);
                    }
                }

                if (quotation != null) {
                    delete quotation.ASI_CTY_CN_Vendor_Total_Price__c;
                    delete quotation.ASI_CTY_CN_Vendor_Total_Freight__c;
                    delete quotation.Quotations_quotation__r;
                }

                component.set('v.showSpinner', true);
                var action = component.get('c.submitQuotationInfo');
                action.setParams({
                    'quotetionJson': JSON.stringify(quotation),
                    'addressJson': JSON.stringify(address),
                    'mergeQuotationIds' : JSON.stringify(mergeQuotationIds)
                });


                action.setCallback(this, function(response) {
                    var status = response.getState();
                    if (status === 'SUCCESS') {
                        var data = response.getReturnValue();
                        console.info(data);

                        if (data.status == 1) {
                            if (data.message != null && typeof(data.message) != 'undefined') {
                                var quotation = JSON.parse(JSON.stringify(component.get('v.PR.quotation')));
                                var address = JSON.parse(JSON.stringify(component.get('v.PR.quoteLineItem')));
                                
                                quotation.ASI_CTY_CN_Vendor_Status__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Status_Completed');
                                quotation.ASI_CTY_CN_Vendor_Result_Status__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Result_Status_Pending_Confirm');
                                component.set('v.PR.quotation', quotation);
                                component.set('v.PR.quoteLineItem', address);
                                helper.initButtonIsPriv(component);
                                component.set('v.showSpinner', false);
                                helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info'), 'SUCCESS', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info_Tips5'));
                            }
                        } else {
                            component.set('v.showSpinner', false);
                            helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info'), 'ERROR', data.message);
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        } else {
            helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info'), 'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_Bidding_Detail_Apply_Info_Tips6'));
        }
    },

    // Close Item Gorup image dialog
    closeSIRImageModel : function (component, event, helper) {
        component.set('v.isShowImageModal', !component.get('v.isShowImageModal'));
    },

    // download Item Group image
    downloadSIRImage : function (component, event, helper) {
        var fileList = component.get('v.fileList');
        if (fileList.length > 0) {
            const link = document.createElement('a');
            link.href = fileList[0].Content;
            link.download = fileList[0].Title;
            link.click();
            window.URL.revokeObjectURL(link.href);
        }
    },

    getIGImage : function(component, event, helper) {
        var quotation = component.get('v.Quotation');
        var itemGroupId = quotation.ASI_CTY_CN_Vendor_Item_Group__r.Id;
        var fileList = component.get('v.fileList');

        if (!helper.isEmpty(fileList) && fileList.length > 0) {
            if (helper.isEmpty(fileList[0].Content) || fileList[0].Content == '') {
                component.set('v.showSpinner', true);
                var action = component.get('c.getDocumentContent');
                action.setParams({
                    'warehousePhotoId': fileList[0].Id
                });

                action.setCallback(this, function(response) {
                    var status = response.getState();
                    if (status === 'SUCCESS') {
                        var data = response.getReturnValue();
                        console.info(data);

                        if (data) {
                            fileList[0].Content = data;
                            component.set('v.fileList', fileList);
                            component.set('v.showSpinner', false);
                            component.set('v.isShowImageModal', !component.get('v.isShowImageModal'));
                        }
                    }
                });
                $A.enqueueAction(action);
            } else {
                component.set('v.isShowImageModal', !component.get('v.isShowImageModal'));
            }
        }
    },

    isNeedDeadLine : function(component, event, helper) {
        var inputCmp = component.find('ASI_CTY_CN_Vendor_Unitl_Price__c');
        var value = inputCmp.get('v.value');

        if (!helper.floatValidations(value, 2) && value != '0' && value != '') {
            component.set('v.isNeedDeadLine', true);
        } else {
            component.set('v.isNeedDeadLine', false);
        }
    },

    // Jump to PO detail page
    toPODetail : function(component, event, helper) {
        var id = event.target.id;
        var url = 'ContractDetail?Id=' + id;
        helper.navigateToURL(url);
    }
})