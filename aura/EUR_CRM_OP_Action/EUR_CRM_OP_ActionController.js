/**
 * Created by User on 6/1/2018.
 */
({
    doInit: function (component, event, helper) {
        helper.fillAction(component, event, helper);
    },

    onChangeRecordType: function (component, event, helper) {
        helper.onChangeRecordType(component, helper);
    },

    onActionFieldChange: function (component, event, helper) {
        var objName = event.getParam("objName");
        if (objName == 'EUR_CRM_OP_Action__c') {
            var fieldName = event.getParam("fieldName");
            var fieldValue = event.getParam("fieldValue");
            helper.onActionFieldChanges(component, fieldName, fieldValue);
        }
    },

    saveOPAction: function (component, event, helper) {
        console.log('save');
        var opAction = component.get('v.new_actionChangedFields');
        component.set('v.actionChangedFields',opAction);

        helper.saveAction(component, event, helper);
    },

    cancelOPAction: function (component, event, helper) {
        console.log('cancel');
        var opAction = component.get('v.actionChangedFields');
        component.set('v.new_actionChangedFields',opAction);

        component.getEvent('closeOPActionTab').setParams({
            "isNeedRefresh": false
        }).fire();
    },
    doChangeFieldSuccess: function (component, event, helper) {
        var valSuc = component.find('idFieldSuccess').get('v.value');
        component.set('v.valueSuccess_PICKLIST', valSuc);
        helper.onActionFieldChanges(component, 'EUR_CRM_Selected_Field_for_Success__c', valSuc);

        // helper.getFieldsForSuccessStatus(component, event, helper,false);
        helper.getRestrictedFieldsForSuccessStatus(component, event, helper,false);

        //add to multipicklist
        var mp = component.get('v.selectedArrayGeneralPromo');
        if(component.get('v.old_valueSuccess_PICKLIST')) {
            var index = mp.indexOf(component.get('v.old_valueSuccess_PICKLIST'));
            if(index != -1) {
                mp.splice(index, 1);
            }
        }

        mp.push(valSuc);
        component.set('v.selectedArrayGeneralPromo',mp);
        component.set('v.old_valueSuccess_PICKLIST',valSuc);
        helper.onActionFieldChanges(component, component.get('v.fieldNameForGeneralOrProduct'), mp.toString());
    },
    doChangeFieldUnsucess: function (component, event, helper) {
        var valUnsuc = component.find('idFieldUnsuccess').get('v.value');
        component.set('v.valueUnsuccess_PICKLIST', valUnsuc);
        helper.onActionFieldChanges(component, 'EUR_CRM_Selected_Field_for_Unsuccess__c', valUnsuc);

        //add to multipicklist
        var mp1 = component.get('v.selectedArrayGeneralPromo');
        if(component.get('v.old_valueUnsuccess_PICKLIST')) {
            var index1 = mp1.indexOf(component.get('v.old_valueUnsuccess_PICKLIST'));
            if(index1 != -1) {
                mp1.splice(index1, 1);
            } 
        }

        mp1.push(valUnsuc);
        component.set('v.selectedArrayGeneralPromo',mp1);
        component.set('v.old_valueUnsuccess_PICKLIST',valUnsuc);
        helper.onActionFieldChanges(component, component.get('v.fieldNameForGeneralOrProduct'), mp1.toString());
    },
    doChangeFieldSuccessfulStatus: function (component, event, helper) {
        var valSucStatus = component.find('idFieldSuccessfulStatus').get('v.value');
        component.set('v.valueSuccessfulStatus_PICKLIST', valSucStatus);
        helper.onActionFieldChanges(component, 'EUR_CRM_Successful_Status__c', valSucStatus);
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
    }
})