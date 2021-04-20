({
    doInit : function(component, event, helper) {
    	console.log("doInit is called.");
        component.set('v.showSpinner', true);
        // helper.loadSalesOrder(component, event, helper);
        helper.loadOrderTOV(component, event, helper);
        // helper.loadOrderItems(component, event, helper);

    },

    downloadTOV : function(component, event, helper) {
        console.log('download click');
        let tovId = event.getSource().get('v.value');
        window.open("/ASICTYWholesalerCN/apex/ASI_CTY_CN_WS_TOVPDF?tovId=" + tovId, '_blank');
    },

    downloadSORDetail: function(component, event, helper) {
        
        helper.downloadSORDetail(component);
    },

})