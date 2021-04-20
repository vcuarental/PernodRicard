({
	init: function(cmp, event, helper) {
		helper.loadCustomerProsSegmentation(cmp, event, helper);
	},
    showMap: function(cmp, event, helper) {
        var modalBody;
        $A.createComponent("c:ASI_CRM_Visitation_Map",
                           {
                               markersTitle: cmp.get("v.customerProsSegmentation").customer.Name,
                               mapMarkers: [{
                                   title: cmp.get("v.customerProsSegmentation").customer.Name,
                                   location: {
                                       Latitude: cmp.get("v.customerProsSegmentation").customer.ASI_CRM_CN_GPS_info__Latitude__s,
                                       Longitude: cmp.get("v.customerProsSegmentation").customer.ASI_CRM_CN_GPS_info__Longitude__s
                                   },
                                   description: cmp.get("v.customerProsSegmentation").customer.ASI_CRM_CN_Address__c
                               }],
                               zoomLevel: 15
                           },
                           function (content, status) {
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   var ol = cmp.find('overlayLib');
                                   
                                   cmp.find('overlayLib').showCustomModal({
                                       header: cmp.get("v.customerProsSegmentation").customer.Name,
                                       body: modalBody,
                                       showCloseButton: true,
                                       closeCallback: function () {
                                           
                                       }
                                   });
                               }
                           });
    },
    navigateDetails: function(cmp, event, helper) {
		var pageReference = cmp.get("v.pageReference");
        var recordId = pageReference.state.c__id;
		var nav = cmp.find("navService");
		var pageReference = {
			type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'ASI_CRM_AccountsAdditionalField__c',
                actionName: 'view',
            }
        };

        nav.navigate(pageReference);
    },
    navigateBack: function() {
		window.history.back();
    }
})