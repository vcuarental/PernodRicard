/**
 * Created by User on 6/3/2018.
 */
({

    doInit: function (component,event,helper) {
        helper.fillTemplate(component,event,helper);
    },
    onActionFieldChange: function (component,event,helper) {
        var objName = event.getParam("objName");
        if(objName == 'EUR_CRM_OP_Template__c') {
            var fieldName = event.getParam("fieldName");
            var fieldValue = event.getParam("fieldValue");
            helper.onActionFieldChange(component,fieldName,fieldValue);
        }
    },
    saveOPTemplate : function (component,event,helper) {
        helper.saveOPTemplate(component,event,helper,false);
    },

    cancelOPTemplate : function (component,event,helper) {
        helper.cancelOPTemplate(component,event,helper);
    },

    openOPActionTab : function (component,event,helper) {
        component.set('v.isOpenOPActionTab',true);
    },

    saveAndOpenOPActionTab : function (component,event,helper) {
        helper.saveOPTemplate(component,event,helper,true);
    },

    onCloseOPActionTab : function (component,event,helper) {
        if(event.getParam("isNeedRefresh") == true) {
            helper.getActions(component, event, helper);
        }
        var newAction = {'sobjectType':'EUR_CRM_OP_Action__c','Id':null};
        component.set('v.recordAction', newAction);
        component.set('v.isOpenOPActionTab',false);
    },

    onOpenOPActionTab : function (component,event,helper) {
        var index = event.getParam("index");
        if(index) {
            var actionList = component.get('v.actionList');
            var recordRow = actionList[index];
            console.log('recordRow = ',recordRow);
            recordRow.EUR_CRM_OP_Template__c = component.get('v.recordTemplateId');
            component.set('v.recordAction', actionList[index]);
            component.set('v.indexRow', index);
        }
        component.set('v.isOpenOPActionTab',true);
    },

    onDeleteOPAction : function (component,event,helper) {
        helper.deleteOPAction(component,event,helper);
    },

     onHideOPTarget: function (component,event,helper) {
        var isHide = event.getParam('hideOPTarget');
        var fieldName = event.getParam('fieldName');

            if(fieldName == 'EUR_CRM_Has_Target__c') {
                component.set('v.hasTarget', isHide);
            }else if(fieldName == 'EUR_CRM_Has_Quota__c'){
                component.set('v.hasQuota', isHide);
            }
    },

    // this function automatic call by aura:waiting event
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner
        component.set("v.spinner", true);
    },

    // this function automatic call by aura:doneWaiting event
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner
        component.set("v.spinner", false);
    },

    onClickClone: function (component, event, helper) {
        component.set('v.showCloneWindow', true);
    },

    closeCloneWindowMethod: function (component, event, helper) {
        component.set('v.showCloneWindow', false);
    },

});