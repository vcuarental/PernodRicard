({
    // this function call on the component load first time
    doInit : function(component, event, helper) {
        component.set('v.showSpinner', true);
        var Id = helper.getUrlParameter('Id');
        component.set('v.recordId', Id); 
        helper.getInitDate(component);
    },

    // Control the folding and shrinking of po info area
    handlePoInfoExpand : function(component, event, helper) {
		helper.handleExpand(component, 'poInfo');
	},

    // Control the folding and shrinking of itemgroup info area
    handleItemGroupInfoExpand : function(component, event, helper) {
        helper.handleExpand(component, 'itemGroupInfo');
    },

    // Control the folding and shrinking of po lineitem posm area
    handlePolineItemPosmExpand : function(component, event, helper) {
        helper.handleExpand(component, 'polineItemPosm');
    },

    // Control the folding and shrinking of po lineitem area
    handlePolineItemExpand : function(component, event, helper) {
        helper.handleExpand(component, 'polineItem');
    },

    // Control the folding and shrinking of address area
    handleAddressExpand : function(component, event, helper) {
        helper.handleExpand(component, 'address');
    },

    // write SIR info with default value and open write SIR dialog
    writeSIR : function(component, event, helper) {
        var index = event.target.id;
        var posms = component.get('v.POInfo');
        var posm = posms.PO_POSM_Lines__r[index];
        
        // Prepare the initial default data of sir
        var sirInfo = {
            'ASI_MFM_Net_Weight__c' : '', 
            'ASI_Delivery_Date__c' : '', 
            'ASI_MFM_Box_Size_M3__c' : '', 
            'ASI_MFM_Qty_Per_Bag_Box__c': '', 
            'ASI_MFM_Total_Qty_Per_Bag_Box__c': '', 
            'ASI_MFM_Qty_Per_Box__c': '', 
            'ASI_MFM_Fraction_Qty__c': '', 
            'ASI_MFM_Total_Number_Of_Box__c': '', 
            'ASI_MFM_Lot_Number__c' : '', 
            'ASI_MFM_Box_Net_Weight__c': '', 
            'ASI_MFM_Length__c' : '', 
            'ASI_MFM_Width__c' : '', 
            'ASI_MFM_Height__c' : '',
            'ASI_MFM_Lot_Quantity__c': ''
        };
        component.set('v.isInsert', true);
        sirInfo.Index = index;
        sirInfo.ItemGroupName = posm.ASI_MFM_Item_Group__r.Name;
        sirInfo.ItemGroupId = posm.ASI_MFM_Item_Group__r.Id;
        sirInfo.ASI_MFM_Total_Quantity__c = posm.ASI_MFM_Quantity__c;
        sirInfo.ActualQty = posm.ActualQty;

        sirInfo.UpdateActualQty = parseInt(posm.ASI_MFM_Quantity__c) - parseInt(posm.ActualQty);

        sirInfo.ASI_MFM_PO_Number__c = posms.Id;
        sirInfo.ASI_MFM_PO_POSM_Line_Number__c = posm.Id;
        sirInfo.ASI_CTY_CN_Vendor_SIR_ApprovalUser__c = posms.ASI_MFM_eMarket_Buyer__r.Id;

        var sirsInfos = posm.sirsInfo;

        // calculate SIR lot number
        var lotNum = 1;
        if (sirsInfos != null && sirsInfos.length > 0) {
            lotNum = sirsInfos.length + 1;
        }
        sirInfo.ASI_MFM_Lot_Number__c = lotNum;

        // Loading item group image
        helper.getItemGroupImage(component, sirInfo);
    },

    // Controls the display and hiding of SIR Line
    controlSIR : function(component, event, helper) {
        var index = event.getSource().get('v.id');
        var posms = component.get('v.POInfo');
        var posm = posms.PO_POSM_Lines__r[index];

        if (posm) {
            posm.ShowSIR = !posm.ShowSIR;
            posms.PO_POSM_Lines__r[index] = posm;
            component.set('v.POInfo', posms);
        }
    },

    // Cancel Sir creation
    cancelWriteSIR : function(component, event, helper) {
        var sir = component.get("v.SIRInfo");
        var file = component.get("v.file");
        var fileList = component.get("v.fileList");
        var id = '';
        var ids = [];

        if (file != null && typeof(file) != 'undefined') {
            id = file.Id;
        }

        // Keep the original image file, delete other image file according to file Id List 
        if (fileList.length > 0) {
            for (var f of fileList) {
                if (f.Id != id) {
                    ids.push(f.Id);
                } 
            }
        }
        fileList = fileList.slice(fileList.length - 1);

        component.set('v.showSpinner', true);
        // delete image file
        var action = component.get('c.deleteDocuments');
        action.setParams({
            'warehousePhotoId': id,
            'itemGroupId' : sir.ItemGroupId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.isUploadImage', false);
                component.set('v.isDisabled', false);
                helper.cleanSIR(component);
            }
            component.set('v.isShowModal', !component.get('v.isShowModal'));
            component.set('v.showSpinner', false);
        });
        
        $A.enqueueAction(action);
    },

    // Submit writed SIR info and save the latest pictures
    submitWriteSIR : function(component, event, helper) {
        var sir = component.get("v.SIRInfo");
        var posms = component.get("v.POInfo");
        var isDisabled = component.get("v.isDisabled");
        var isInsert = component.get('v.isInsert');

        // Calculate SIR lot quantity according to fraction quantity
        sir.ASI_MFM_Qty_Per_Bag_Box__c = parseInt(sir.ASI_MFM_Total_Qty_Per_Bag_Box__c) * parseInt(sir.ASI_MFM_Qty_Per_Box__c);
        component.set("v.SIRInfo", sir);
        sir = JSON.parse(JSON.stringify(component.get("v.SIRInfo")));
        var index = sir.Index;
        var posm = posms.PO_POSM_Lines__r[index];
        var noWritedSIRQty = parseInt(posm.ASI_MFM_Quantity__c) - posm.ActualQty;
        if (!isInsert) {
            noWritedSIRQty = parseInt(posm.ASI_MFM_Quantity__c) - posm.ActualQty + parseInt(sir.ASI_MFM_Lot_Quantity_Base__c);
        }
        if (sir.ASI_MFM_Status__c != 'Confirmed' || isDisabled) {
            // Check the validity of the SIR data
            if (helper.sirValidations(component)) {
                if (parseInt(sir.ASI_MFM_Lot_Quantity__c) <= noWritedSIRQty) {
                    if (sir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c == 'Rejected' || typeof(sir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c) === 'undefined' 
                        || sir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c == $A.get('$Label.c.ASI_CTY_CN_Vendor_Rejected')
                        || sir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c == 'Recall' || sir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c == $A.get('$Label.c.ASI_CTY_CN_Vendor_Recall')) {
                        var fileList = component.get('v.fileList');
                        if (fileList != null && typeof(fileList) != 'undefined' && fileList.length > 0) {
                            var flag = false;
                            if (parseInt(sir.ASI_MFM_Lot_Quantity__c) == noWritedSIRQty) {
                                flag = window.confirm($A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Quantity_Tips1'));
                            } else if (parseInt(sir.ASI_MFM_Lot_Quantity__c) < noWritedSIRQty) {
                                flag = window.confirm($A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Quantity_Tips2'));
                            }
                            if (flag) {
                                component.set('v.showSpinner', true);

                                // Save the latest image file, delete other image file
                                var ids = [];
                                var file = fileList.slice(0,1);
                                fileList = fileList.slice(1);
                                if (fileList.length > 0) {
                                    for (var f of fileList) {
                                        ids.push(f.Id);
                                    }
                                }

                                // Reset fileList
                                component.set('v.fileList', file);
                                component.set('v.file', file[0]);
                                delete sir.Index;
                                delete sir.ItemGroupName;
                                var itemGroupId = sir.ItemGroupId;
                                delete sir.ItemGroupId;
                                delete sir.IndexSIR;
                                delete sir.ASI_MFM_Lot_Quantity_Base__c;
                                delete sir.comments;
                                delete sir.ProcessSteps;
                                delete sir.ASI_MFM_Delivery_Address_Warehouse__c;
                                delete sir.ActualQty;
                                delete sir.UpdateActualQty;
                                if (sir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c === $A.get('$Label.c.ASI_CTY_CN_Vendor_Rejected')) {
                                    sir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c = 'Rejected';
                                }
                                if (sir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c === $A.get('$Label.c.ASI_CTY_CN_Vendor_Recall')) {
                                    sir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c = 'Recall';
                                }
                                var action = component.get('c.insertSIR');
                                action.setParams({
                                    'sirInfo' : JSON.stringify(sir),
                                    'warehousePhotoId' : file[0].Id,
                                    'itemGroupId' : itemGroupId
                                });

                                action.setCallback(this, function(response){
                                    var state = response.getState();
                                    if (state === 'SUCCESS') {
                                        var data = response.getReturnValue();
                                        console.info('sirinfo--------------');
                                        console.info(data);
                                        if(data != null) {
                                            var isInsert = component.get('v.isInsert');
                                            var sir = component.get("v.SIRInfo");
                                            var index = sir.Index;
                                            var indexSIR = sir.IndexSIR;
                                            var posms = component.get('v.POInfo');
                                            var posm = posms.PO_POSM_Lines__r[index];

                                            // Handle return data and reset PO data
                                            if (posm != null && typeof(posm) != 'undefined') {
                                                if (isInsert) {
                                                    data.ASI_MFM_Delivery_Address_Warehouse__c = posms.PO_POSM_Lines__r[index].ASI_MFM_Delivery_Address_Warehouse__r.Name;
                                                    var sirInfo = posms.PO_POSM_Lines__r[index].sirsInfo;
                                                    if (sirInfo == null && typeof(sirInfo) == 'undefined') {
                                                        posms.PO_POSM_Lines__r[index].sirsInfo = [];
                                                    }
                                                    posms.PO_POSM_Lines__r[index].sirsInfo.push(data);

                                                    if (posms.Stock_In_Requests__r == null &&  typeof(posms.Stock_In_Requests__r) == 'undefined') {
                                                        posms.Stock_In_Requests__r = [];
                                                    }
                                                    posms.Stock_In_Requests__r.push(data);
                                                } else {
                                                    posms.PO_POSM_Lines__r[index].sirsInfo[indexSIR] = data;
                                                }
                                                
                                                posms.PO_POSM_Lines__r[index].ShowSIR = true;
                                                component.set('v.isInsert', true);
                                                component.set('v.isDisabled', false);
                                                component.set('v.isUploadImage', false);
                                                component.set('v.POInfo', posms);

                                                // Calculate other filed data
                                                helper.loadingSIR(component);

                                                // Clean default SIR Info and image file
                                                helper.cleanSIR(component);
                                                component.set('v.isShowModal', !component.get('v.isShowModal'));
                                            }
                                        } else {
                                            component.set('v.showSpinner', false);
                                            helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Exception_Title'), 
                                                'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Exception_Tips1'));
                                        }
                                    } else{
                                        helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Exception_Title'), 
                                            'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_POList_Tips_Exception'));
                                    }
                                    component.set('v.showSpinner', false);
                                });
                                
                                $A.enqueueAction(action);
                            }
                        } else {
                            component.set('v.showSpinner', false);
                            helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Exception_Title'), 
                            'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Exception_Tips3'));
                        }
                    } else {
                        component.set('v.isShowModal', !component.get('v.isShowModal'));
                    }
                } else {
                    helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Exception_Title'), 
                        'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Exception_Tips4'));
                }
            } else {
                helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Exception_Title'), 
                    'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Exception_Tips5'));
            }
        } else {
            component.set('v.isShowModal', !component.get('v.isShowModal'));
        }
    },

    // The method of calling when uploaded file is loaded
    handleUploadFinished : function (component, event, helper) {
        component.set('v.showSpinner', true);
        var files = event.getSource().get("v.files");
        console.info('files------------');
        console.info(files);

        var fileList = component.get('v.fileList');

        if ((fileList.length == 0) || (fileList.length > 0)) {
            if (files[0].size <= 1048576) {
                // Add a file to the top of the file list
                fileList.unshift(files[0]);

                // read file data
                var reader = new FileReader();
                reader.readAsDataURL(files[0]);
                reader.onabort = function(e) {
                    console.log(e);
                };
                reader.onerror = function(e) {
                    console.log(e);
                };
                reader.onload = function(e) {
                    if(e.target.result) {
                        fileList[0].content = e.target.result;
                        var sir = component.get("v.SIRInfo");
                        var content = fileList[0].content;
                        if (content == null || typeof(content) == "undefined") {
                            content = ',';
                        }
                        var fileType = fileList[0].type;
                        if (fileType == null || typeof(fileType) == 'undefined') {
                            fileType = 'jpg';
                        } else {
                            fileType = fileType.split('/')[1];
                        }
                        var poInfo = component.get('v.POInfo');

                        setTimeout($A.getCallback(function(){
                            var action = component.get('c.insertDocument');
                            action.setParams({
                                'buyerId' : poInfo.ASI_MFM_eMarket_Buyer__c,
                                'itemGroupId' : sir.ItemGroupId,
                                'fileVal' : content.split(',')[1],
                                'fileName' : fileList[0].name,
                                'fileSize': Math.floor(parseInt(files[0].size) / 1024),
                                'fileType': fileType
                            });

                            action.setCallback(this, function(response){
                                var state = response.getState();
                                if (state === 'SUCCESS') {
                                    var data = response.getReturnValue();
                                    if (data) {
                                        fileList[0].Id = data;
                                    }
                                    console.log("image upload completed " + fileList[0].name);
                                    component.set('v.fileList', fileList);
                                    component.set('v.isUploadImage', true);
                                } else{
                                    helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Upload_Image_Exception_Title'), 
                                                'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Exception_Tips2'));
                                }
                                component.set('v.isUploadImage', true);
                                component.set('v.showSpinner', false);
                            });
                            
                            $A.enqueueAction(action);
                         }) ,20);
                    }
                };
            } else {
                 helper.show($A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Upload_Image_Exception_Title'), 
                    'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Submit_Exception_Tips6'));
                 component.set('v.showSpinner', false);
            }
        } else {
            component.set('v.showSpinner', false);
        }
    },

    // click SIR Number and open SIR dialog with init
    updateSIR : function (component, event, helper) {
        component.set('v.showSpinner', true);
        var indexSIR = event.target.id;
        var indexPOSM =  event.target.name;
        var posms = component.get('v.POInfo');
        var posm = posms.PO_POSM_Lines__r[indexPOSM]
        var sir = posm.sirsInfo[indexSIR];

        sir.Index = indexPOSM;
        sir.IndexSIR = indexSIR;
        sir.ItemGroupName = posm.ASI_MFM_Item_Group__r.Name;
        sir.ItemGroupId = posm.ASI_MFM_Item_Group__r.Id;
        sir.ASI_MFM_Lot_Quantity_Base__c = sir.ASI_MFM_Lot_Quantity__c;
        sir.ActualQty = posm.ActualQty;
        
        var approvalStatus = sir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c;
        if (typeof(approvalStatus) != 'undefined' && (approvalStatus == 'Rejected' || approvalStatus == $A.get('$Label.c.ASI_CTY_CN_Vendor_Rejected') 
            || approvalStatus == 'Recall' || approvalStatus == $A.get('$Label.c.ASI_CTY_CN_Vendor_Recall'))) {
            component.set('v.isDisabled', false);
            sir.UpdateActualQty = parseInt(sir.ASI_MFM_Total_Quantity__c) - parseInt(sir.ActualQty) + parseInt(sir.ASI_MFM_Lot_Quantity__c);
        } else {
            component.set('v.isDisabled', true);
            sir.UpdateActualQty = parseInt(sir.ASI_MFM_Total_Quantity__c) - parseInt(sir.ActualQty);
        }
        component.set('v.isInsert', false);
        helper.getItemGroupImage(component, sir);
    },

    recallSIRInfo : function (component, event, helper) {
        var indexSIR = event.target.id;
        var indexPOSM =  event.target.name;
        var posms = component.get('v.POInfo');
        var posm = posms.PO_POSM_Lines__r[indexPOSM];
        var sir = posm.sirsInfo[indexSIR];
        var flag = window.confirm($A.get('$Label.c.ASI_CTY_CN_Vendor_PPL_SIR_Recall_Tips1'));

        if (flag) {
            component.set('v.showSpinner', true);
            var action = component.get('c.recallSIR');
            action.setParams({
                'sirId' : sir.Id
            });

            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var data = response.getReturnValue();
                    if (data != null && parseInt(data.state) == 1) {
                        var indexSIR = event.target.id;
                        var indexPOSM =  event.target.name;
                        var posms = component.get('v.POInfo');
                        posms.PO_POSM_Lines__r[indexPOSM].sirsInfo[indexSIR].ASI_CTY_CN_Vendor_SIR_Approval_Status__c = $A.get('$Label.c.ASI_CTY_CN_Vendor_Recall');
                        component.set('v.POInfo', posms);
                    } else {
                        helper.show('SIR Info', 'error', data.message);
                    }
                } else{
                    helper.show('SIR Info', 'error', $A.get('$Label.c.ASI_CTY_CN_Vendor_SIR_Recall_Fail'));
                }
                component.set('v.showSpinner', false);
            });
            
            $A.enqueueAction(action);
        }
    },

    // click image file name and open image dialog with loading image content
    openImage : function (component, event, helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.getDocumentContent');
        var fileList = component.get('v.fileList');

        // Loaded file content only when content does not exist
        if ((fileList[0].content == '') || (typeof(fileList[0].content) == 'undefined')) {
            action.setParams({
                'warehousePhotoId' : fileList[0].Id
            });

            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var data = response.getReturnValue();
                    if (data) {
                        fileList[0].content = data;
                        component.set('v.fileList', fileList);
                        component.set('v.showSpinner', false);

                        component.set('v.isShowModal', !component.get('v.isShowModal'));
                        component.set('v.isShowImageModal', !component.get('v.isShowImageModal'));
                    }
                } else{
                    console.log('SIR image open fail...');
                }
            });
            
            $A.enqueueAction(action);
        } else {
            component.set('v.showSpinner', false);
            component.set('v.isShowModal', !component.get('v.isShowModal'));
            component.set('v.isShowImageModal', !component.get('v.isShowImageModal'));
        }
    },

    // Image dialog mouse dynamic effect
    mouseoverImageModel : function (component, event, helper) {
        component.set('v.outClass', 'mydiv1');
    },
    mouseoutImageModel : function (component, event, helper) {
         component.set('v.outClass', 'mydiv');
    },

    // Close SIR image dialog
    closeSIRImageModel : function (component, event, helper) {
        component.set('v.isShowImageModal', !component.get('v.isShowImageModal'));
        component.set('v.isShowModal', !component.get('v.isShowModal'));
    },

    // download SIR image
    downloadSIRImage : function (component, event, helper) {
        var fileList = component.get('v.fileList');
        if (fileList.length > 0) {
            const link = document.createElement('a');
            link.href = fileList[0].content;
            link.download = fileList[0].name;
            link.click();
            window.URL.revokeObjectURL(link.href);
        }
    },

    calculateBoxVolume : function (component, event, helper) {
        var sir = component.get("v.SIRInfo");
        var length = 0;
        var height = 0;
        var width = 0;
        var total = 0;

        if (sir.ASI_MFM_Length__c != null && sir.ASI_MFM_Length__c != '' && typeof(sir.ASI_MFM_Length__c) != 'undefined') {
            length = parseFloat(sir.ASI_MFM_Length__c);
        }

        if (sir.ASI_MFM_Width__c != null && sir.ASI_MFM_Width__c != '' && typeof(sir.ASI_MFM_Width__c) != 'undefined') {
            width = parseFloat(sir.ASI_MFM_Width__c);
        }

        if (sir.ASI_MFM_Height__c != null && sir.ASI_MFM_Height__c != '' && typeof(sir.ASI_MFM_Height__c) != 'undefined') {
            height = parseFloat(sir.ASI_MFM_Height__c);
        }
        total = length * height * width;
        if (total < 0) {
            total = 0;
        }
        sir.ASI_MFM_Box_Size_M3__c = total.toFixed(3);
        component.set("v.SIRInfo", sir);
    },

    calculateLotQuantity : function (component, event, helper) {
        var sir = component.get("v.SIRInfo");
        var total_qty_per_bag_box = 0;
        var qty_per_box__c = 0;
        var total_number_of_box__c = 0;
        var total = 0;

        var bag = sir.ASI_MFM_Total_Qty_Per_Bag_Box__c;
        var per_box = sir.ASI_MFM_Qty_Per_Box__c;
        var box = sir.ASI_MFM_Total_Number_Of_Box__c;
        var fraction = sir.ASI_MFM_Fraction_Qty__c;

        if (bag != null && bag != '' && typeof(bag) != 'undefined') {
            total_qty_per_bag_box = parseInt(bag);
        }

        if (per_box != null && per_box != '' && typeof(per_box) != 'undefined') {
            qty_per_box__c = parseInt(per_box);
        }

        if (box != null && box != '' && typeof(box) != 'undefined') {
            total_number_of_box__c = parseInt(box);
        }

        if (fraction != null && fraction != '' && typeof(fraction) != 'undefined' && parseInt(fraction) != 0) {
            total = (total_number_of_box__c - 1) * qty_per_box__c * total_qty_per_bag_box + parseInt(fraction);
        } else {
            total = total_number_of_box__c * qty_per_box__c * total_qty_per_bag_box;
        }

        if (total < 0) {
            total = 0;
        }
        
        sir.ASI_MFM_Lot_Quantity__c = total;
        component.set("v.SIRInfo", sir);
    },

    // click TIV number and open TIV PDF
    openTIVPDF : function (component, event, helper) {
        var indexPOSM =  event.target.name;
        var posms = component.get('v.POInfo');
        var posm = posms.PO_POSM_Lines__r[indexPOSM];
        var sirIndex = event.target.id;
        var sirNum = posm.sirsInfo[sirIndex].ASI_MFM_TIV_Number__c;
        window.open('/PRCVendor/apex/ASI_CTY_CN_Vendor_PosmPdf_Page?posm_line_id='+posm.Id +'&tivNum='+sirNum);
    },

    // open PO pdf
    openPDF : function(component, event, helper) {
        var po_id = event.target.id;
        window.open('/PRCVendor/apex/ASI_CTY_CN_Vendor_POPDF_Page?po_id='+po_id + '&is_pdf=true');
    }
})