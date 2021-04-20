/**
 * Created by User on 6/1/2018.
 */
({
    doInit: function (component, event, helper) {
       helper.fillMultyPiclist(component, event, helper);
    },
    handleChange: function (component, event) {
        var selectedOptionValue = event.getParam("value");
        var fieldName = component.get('v.fieldName');
        component.getEvent('actionFieldChange').setParams({
            "fieldName" : fieldName
            ,"fieldValue" : selectedOptionValue.toString()
            ,"objName" : "EUR_CRM_OP_Action__c"
        }).fire();
    }
})