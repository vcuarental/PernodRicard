/**
 * Created by User on 6/1/2018.
 */
({
    init: function (cmp) {
        var temp = cmp.get('v.fieldValue');
        // console.log('temp = ', JSON.stringify(temp));

        cmp.set('v.fieldApiName', temp.fieldApiName);
        cmp.set('v.fieldType', temp.fieldType);
        cmp.set('v.fieldLabel', temp.fieldLabel);
        cmp.set('v.fieldIsReadOnly', temp.fieldIsReadOnly);
        cmp.set('v.recordId', temp.templateId);

        if ((temp.fieldIsReadOnly == true && temp.fieldIsRequired == true) || temp.fieldType == 'BOOLEAN' ) {
            cmp.set('v.fieldIsRequired', false);
        } else {
            cmp.set('v.fieldIsRequired', temp.fieldIsRequired);
        }

        if(temp.fieldApiName == 'Name'){
            cmp.set('v.fieldIsRequired', true);
        }
        if(temp.fieldType == 'PICKLIST' || temp.fieldType == 'MULTIPICKLIST'){
            cmp.set('v.valueSet_'+temp.fieldType, temp.picklistValues);
            if(temp.fieldType == 'MULTIPICKLIST' && temp.value != null){
                cmp.set('v.value_MULTIPICKLIST_str',temp.value);
                var items = [];
                var arr = temp.value.split(';');
                for (var y = 0; y < arr.length; y++) {
                    items.push(arr[y]);
                }
                temp.value = items;
            }
            if(temp.fieldType == 'PICKLIST') {
                for (var y = 0; y < temp.picklistValues.length; y++) {
                    if (temp.value != null && temp.picklistValues[y].value == temp.value) {
                        cmp.set('v.value_PICKLIST_label', temp.picklistValues[y].label);
                        break;
                    }
                }
            }
        }

        cmp.set('v.value_' + temp.fieldType, temp.value);

        //if chosen Has Quota or Has Target do not display OP Target in Promo and OP Target in Promo Summ
        if(temp.fieldApiName == 'EUR_CRM_Has_Quota__c' || temp.fieldApiName == 'EUR_CRM_Has_Target__c' ){
            cmp.getEvent('hideOPTarget').setParams({
                'hideOPTarget' : temp.value,
                'fieldName' : temp.fieldApiName,
                'isInit' : true
            }).fire();
        }

        cmp.set('v.isReady', true);


    },
    handleChange: function (cmp, event) {
        var selectedOptionValue = event.getParam("value");
        var fieldName = cmp.get('v.fieldApiName');
        cmp.getEvent('actionFieldChange').setParams({
            "fieldName" : fieldName
            ,"fieldValue" : selectedOptionValue
            ,"objName" : cmp.get('v.objName')
        }).fire();
    },

    doChange: function (cmp, event) {
        var fieldName = cmp.get('v.fieldApiName');
        var val = cmp.find('idField').get('v.value');
        cmp.getEvent('actionFieldChange').setParams({
            "fieldName" : fieldName
            ,"fieldValue" : val
            ,"objName" : cmp.get('v.objName')
        }).fire();

    //if chosen Has Quota or Has Target do not display OP Target in Promo and OP Target in Promo Summ
        if(fieldName == 'EUR_CRM_Has_Target__c' || fieldName == 'EUR_CRM_Has_Quota__c'){
            cmp.getEvent('hideOPTarget').setParams({
                'hideOPTarget' : val,
                'fieldName' : fieldName,
                'isInit' : false
            }).fire();
        }

    },
})