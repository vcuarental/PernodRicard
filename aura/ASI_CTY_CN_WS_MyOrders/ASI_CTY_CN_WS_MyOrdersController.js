({
    doInit: function(component, event, helper) {
        // this function call on the component load first time
        // call the helper function
        component.set('v.showSpinner', true);
        helper.loadSelectedTabId(component);
        helper.getDefaultOrder(component);
        helper.getMyOrders(component, helper);
        helper.getRefundTOVs(component);
        helper.getHeldTOVs(component);
	},
    // this function call on the newOrder button clicked
    newOrder: function (component, event, helper){
        helper.newOrder(component, helper);
    },
    // this function call on the copyOrder button clicked
    copyOrder : function(component, event, helper) {
        var action = component.get('c.copySalesOrder');
        var sorId = event.target.id;
        console.log('sorId: ' + sorId);
        action.setParams({'sorId' : sorId});
        action.setCallback(this, $A.getCallback(function (response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               var orderInfo = response.getReturnValue();
               if (orderInfo === 'hasOpenSor') {
                  alert($A.get('$Label.c.ASI_CTY_CN_WS_Copy_Limit'));
                  return;
               } else {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "/shopping-cart?orderId=" + orderInfo
                    });
                    urlEvent.fire();
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
        }));
       $A.enqueueAction(action);
    },
    // this function call on the input date changed
    dateFilter: function(component, event, helper) {
        component.set('v.showSpinner', true);
        component.set('v.isLoading', true);
        
        var currentTab = component.get('v.selectedTabId');
        console.log('currentTab : ' + currentTab);

        if(currentTab === 'allSORs'){
            var startDate = component.find("startDate").get("v.value");
            var endDate = component.find("endDate").get("v.value");

            console.log('startDate : ', startDate);
            console.log('endDate : ', endDate);
            
            helper.getMyOrders(component, helper, startDate, endDate);

        }else if(currentTab === 'refundTOVs'){
            var refundStartDate = component.find("refundStartDate").get("v.value");
            var refundEndDate = component.find("refundEndDate").get("v.value");

            console.log('refundStartDate : ', refundStartDate);
            console.log('refundEndDate : ', refundEndDate);

            helper.renderPage(component, currentTab, refundStartDate, refundEndDate);

        }else if(currentTab === 'heldTOVs'){
            var heldStartDate = component.find("heldStartDate").get("v.value");
            var heldEndDate = component.find("heldEndDate").get("v.value");

            console.log('heldStartDate : ', heldStartDate);
            console.log('heldEndDate : ', heldEndDate);

            helper.renderPage(component, currentTab, heldStartDate, heldEndDate);

        }

        component.set('v.isLoading', false);

    },
    // this function call on the downloadSORDetails button clicked
    downloadSORDetails: function(component, event, helper) {
        var startDate = component.find("startDate").get("v.value");
        var endDate = component.find("endDate").get("v.value");

        helper.downloadSORDetails(component, startDate, endDate);
    },
    // this function call on the SOR Number clicked
    showRowDetails: function (component, event, helper){
        var Id = event.currentTarget.id;
        helper.navigateToURL('order-detail?orderId=' + Id);
    },
    // this function call on the TOV Number clicked
    showTOVDetails: function (component, event, helper){
        let tovId = event.currentTarget.id;
        console.log('tovId-->' + tovId);
        let _this = event.currentTarget;
        let orderId = _this.dataset.orderid;
        console.log('orderId-->' + orderId);
        helper.navigateToURL('order-detail?tovTabId=' + tovId + '&orderId=' + orderId);
    },
    /*
    * handleRowAction
    * open order dataTable
    */
    handleRowAction: function (component, event, helper){
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view_details':
                helper.submitSOR(row, helper);
                break;
            case 'submit_SOR':
                helper.submitSOR(row, helper);
                break;
            case 'delete_SOR':
                helper.deleteSOR(component, row);
                break;
        }
    },
    // this function call on the page change
    renderPage: function(component, event, helper) {
        var currentTab = component.get('v.selectedTabId');
        console.log('currentTab : ' + currentTab);
        helper.renderPage(component, currentTab);
    },
    sortBySORNo: function(component, event, helper) {
        helper.sortBy(component, "Name");
    },
    sortBySORDate: function(component, event, helper) {
        helper.sortBy(component, "ASI_CRM_SG_Order_Date__c");
    },
    sortBySORQty: function(component, event, helper) {
        helper.sortBy(component, "ASI_CTY_CN_WS_Total_Order_Qty_CA__c");
    },
    sortByUnmetQty: function(component, event, helper) {
        helper.sortBy(component, "UnmetQty");
    },
    sortByReleaseQty: function(component, event, helper) {
        helper.sortBy(component, "ReleaseQty");
    },
    sortByReleaseAmount: function(component, event, helper) {
        helper.sortBy(component, "ReleaseAmount");
    },
    sortByPromotion: function(component, event, helper) {
        helper.sortBy(component, "ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c");
    },
    sortByDiscount: function(component, event, helper) {
        helper.sortBy(component, "ASI_CTY_CN_WS_Discount_Amount_With_VAT__c");
    },
    sortByPayableAmount: function(component, event, helper) {
        helper.sortBy(component, "PayableAmount");
    },
    sortBySORStatus: function(component, event, helper) {
        helper.sortBy(component, "ASI_CTY_CN_WS_Status__c");
    },
    // this function call on the SOR expand icon clicked
    controlTOV: function(component, event, helper) {
        
        var _this = event.currentTarget;

        var row = _this.closest('tr');

        var rowIndex = _this.dataset.key;
            
        var sors = component.get('v.sors');

        var sor = sors[rowIndex];

        if(!sor.showtov){
            function append(parent, elStr) {

                // var parent = document.querySelector(parentEl);

                if (typeof elStr === 'string') {
                    var tempEl = document.createElement('tbody');
                    tempEl.innerHTML = elStr;
                    var docFrag = document.createDocumentFragment();
                    while (tempEl.firstChild) {
                        docFrag.appendChild(tempEl.firstChild);
                    }
                    parent.insertBefore(docFrag,row.nextSibling);
                } else {
                    parent.insertBefore(docFrag,row.nextSibling);
                }
            }

            var childTable = '';
            if(sor.TOVs__r == '' || sor.TOVs__r == undefined || sor.TOVs__r == null){
                childTable += '<tr class="tovs"><td colspan="11" class="noTOV">' + $A.get('$Label.c.ASI_CTY_CN_WS_SOR_without_TOV') + '</td></tr>';
            }else{
                childTable += '<tr class="tovs"><td colspan="11" style="padding: 0px;"><table class="slds-table slds-table_bordered slds-border_bottom slds-border_left slds-border_right slds-border_top subTable borderAliceblue">'+
                                '<thead>'+
                                    '<tr class="slds-line-height_reset">'+
                                        '<th class="bgAliceblue" scope="col"></th>'+
                                        '<th class="bgAliceblue" scope="col">' + $A.get('$Label.c.ASI_CTY_CN_WS_TOV_No') + '</th>'+
                                        '<th class="bgAliceblue" scope="col">' + $A.get('$Label.c.ASI_CTY_CN_WS_TOV_SubItems_Count') + '</th>'+
                                        '<th class="bgAliceblue" scope="col">' + $A.get('$Label.c.ASI_CTY_CN_WS_TOV_Total_Qty') + '</th>'+  
                                        '<th class="bgAliceblue" scope="col">' + $A.get('$Label.c.ASI_CTY_CN_WS_TOV_Status') + '</th>'+
                                        '<th class="bgAliceblue" scope="col">' + $A.get('$Label.c.ASI_CTY_CN_WS_TOV_Total_Amount_WithVAT') + '</th>'+
                                        '<th class="bgAliceblue" scope="col"></th>'+
                                    '</tr>'+
                                '</thead>'+
                                '<tbody>';

                var finalTOVNumbers = [];
                for (var i = 0; i < sor.TOVs__r.length; i++) {
                    var tov = sor.TOVs__r[i];
                    let recordType = tov.RecordType;
                    if(recordType.DeveloperName == 'ASI_CRM_CN_TOV_Final'){
                        finalTOVNumbers.push(tov.ASI_CRM_SO_Number__c);
                    }
                }
                
                for (var i = 0; i < sor.TOVs__r.length; i++) {
                    var tov = sor.TOVs__r[i];

                    let recordType = tov.RecordType;
                    if(recordType.DeveloperName == 'ASI_CRM_CN_TOV_Final' ||
                        (recordType.DeveloperName == 'ASI_CRM_CN_TOV'
                            && !finalTOVNumbers.includes(tov.ASI_CRM_SO_Number__c))){
                        //let tovAmount = helper.numToMoneyField('10000'); //String(tov.ASI_MFM_Total_Amount_wTax__c)
                        childTable += '<tr class="slds-hint-parent tovInfo">'+
                                    '<td width="32px">'+
                                    '<button id="' + tov.Id + '" name="downloadIcon" title="Download TOV" type="button" class="slds-button slds-button_icon slds-button_icon-border downloadTOV" >'+
                                    // '<img src="/sfsites/c/file-asset/ASI_CTY_CN_Wholesaler_Download_Icon" width="50%"/>'+
                                    '<img src="/ASICTYWholesalerCN/file-asset/ASI_CTY_CN_Wholesaler_Download_Icon" width="50%"/>'+
                                    '</button></td>';
                        childTable += '<td><a id="' + tov.Id + '&orderId=' + tov.ASI_CRM_SF_SO_Request_Number__c + '" class="tovDetails" >'+tov.ASI_CRM_SO_Number__c+'</a></td>';
                        childTable += '<td>'+tov.ASI_CRM_Total_Number_of_Line__c+'</td>';
                        childTable += '<td>'+tov.ASI_CTY_CN_WS_Total_Order_Qty_CA__c+'</td>';
                        childTable += '<td>'+tov.ASI_CTY_CN_WS_Status__c+'</td>';
                        childTable += '<td>￥' + tov.ASI_MFM_Total_Amount_wTax__c + '</td>';
                        childTable += '<td width="10%" class="action">'+
                                            '<div class="slds-button-group" role="group">'+
                                            '<input id="' + tov.Id + '&orderId=' + tov.ASI_CRM_SF_SO_Request_Number__c + '&deliveryTabId=delivInfos" type="button" class="slds-button slds-button--neutral slds-not-selected trickTOV" value="' + $A.get('$Label.c.ASI_CTY_CN_WS_Trick_Order') + '"/>'+
                                            '</div>'+
                                        '</td>'+
                                        '</tr>';
                    }

                }
                childTable += '</tbody>'+
                            '</table></td></tr>';
            }
            append(row.parentNode, childTable);

            // add click event on TOV download button
            var tovDetailsLinks = document.getElementsByClassName('downloadTOV');
            tovDetailsLinks.forEach(function(tovDetailsLink){
                tovDetailsLink.addEventListener("click", function() {
                    let tovId = this.id;
                    console.log('tovId' + this.id);
                    window.open("/ASICTYWholesalerCN/apex/ASI_CTY_CN_WS_TOVPDF?tovId=" + tovId, '_blank');
                });
            });
            
            // add click event on TOV SO Number link
            helper.addClickEvent(helper, 'tovDetails');
            
            // add click event on TOV trick button
            helper.addClickEvent(helper, 'trickTOV');

            sor.showtov = true;
        }else{
            row.nextSibling.innerHTML = '';
            sor.showtov = false;
        }
        component.set("v.sors",sors);
    },
})