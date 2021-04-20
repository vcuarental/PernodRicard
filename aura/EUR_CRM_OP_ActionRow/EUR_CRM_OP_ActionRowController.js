/**
 * Created by User on 6/4/2018.
 */
({
    doInit: function (component,event,helper) {
        helper.fillAction(component,event,helper);
    },
    openOPAction : function(component, event, helper){
        component.getEvent('openOPActionTab').setParams({
            "record":component.get('v.action'),
            "index" : component.get('v.rowIndex')
        }).fire();
    },
    deleteAction : function(component, event, helper){
        component.getEvent("deleteOPAction").setParams({
            "action" : component.get('v.action'),
            "index" : component.get('v.rowIndex')
        }).fire();
    },
})