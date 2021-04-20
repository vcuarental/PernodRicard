({
    doInit : function(component, event, helper) {
        helper.getLastImage(component, event, helper, component.get("v.recordId"));
    },
    
    handleRefreshImageEvent : function(component, event, helper){
        console.log('handleRefreshImageEvent');
        helper.getLastImage(component, event, helper, component.get("v.recordId"));
    }
    
})