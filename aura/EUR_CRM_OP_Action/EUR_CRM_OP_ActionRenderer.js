({
    // rerender: function (component, helper) {
    //     var rtName = component.get('v.selectedRecordType');
    //     if(rtName && rtName[1] == 'General') {
    //         let allTemplateFields = component.find('actionField');
    //         if (allTemplateFields) {
    //             allTemplateFields.forEach(function(templField) {
    //                 var fieldValue = templField.get('v.fieldValue');
    //                 if(fieldValue.fieldApiName == 'EUR_CRM_Stage__c') {
    //                     fieldValue.value = null;
    //                     templField.set('v.fieldValue', fieldValue);
    //                     templField.reInit();
    //                     helper.onActionFieldChanges(component, 'EUR_CRM_Stage__c', null);
    //                     $A.util.addClass(templField, 'slds-hide');
    //                 }
    //             });
    //         }
    //     }
    // }
});