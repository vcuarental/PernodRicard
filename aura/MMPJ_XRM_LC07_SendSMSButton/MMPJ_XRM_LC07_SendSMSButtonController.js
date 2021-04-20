({
    openQuickSendSMS : function(component,event,helper){
        component.set('v.isQuickSendSMSOpen',true);
    },

    handleCloseSendSMSModal : function(component,event,helper){
        component.set('v.isQuickSendSMSOpen', false);
    }
})