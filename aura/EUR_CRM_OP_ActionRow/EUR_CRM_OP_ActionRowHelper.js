/**
 * Created by User on 6/4/2018.
 */
({
    fillAction: function (component, event, helper) {
        helper.getFields(component, event, helper);

    },

    getFields: function (component, event, helper) {
        var actionId;
        var opAction = component.get('v.action');
        if (opAction != null) {
            actionId = opAction.Id;
        }
        var action = component.get("c.getActionFields");
        action.setParams({
            devName: 'ActionColumn',
            recordId: actionId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state == 'SUCCESS') {
                var resultArray = JSON.parse(response.getReturnValue());
                if (component.get('v.rowIndex') === 0) {
                    for (var i = 0; i < resultArray.length; i++) {
                        helper.createField(component, event, helper, helper.createTitleObj(resultArray[i]));
                    }
                } else {
                    for (var i = 0; i < resultArray.length; i++) {
                        if (opAction.EUR_CRM_OP_Template__c == null) {
                            helper.createField(component, event, helper, helper.createObjFromAction(opAction,resultArray[i]));
                        }else {
                            helper.createField(component, event, helper, helper.createObj(resultArray[i]));
                        }
                    }
                }
            } else {
                console.log('Failed with state: ' + state);
            }
        });
        $A.enqueueAction(action);

    },
    createField: function (component, event, helper, field) {
        $A.createComponent(
            "c:EUR_CRM_OP_DynamicFieldGenerationForTab",
            {
                "fieldValue": field,
                "objName": "EUR_CRM_OP_Action__c"
            },
            function (newCaseList) {
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newCaseList);
                    component.set("v.body", body);
                }
            });
    },
    createObj: function (result) {
        var temp = {
            'fieldApiName': result.fieldApiName,
            'fieldType': result.fieldType,
            'fieldLabel': result.fieldLabel,
            'value': result.value,
            'fieldIsRequired': result.fieldIsRequired,
            'fieldIsReadOnly': result.fieldIsReadOnly,
            'picklistValues': result.picklistValues
        };
        return temp;
    },
    createTitleObj: function (result) {
        var tempTitle = {
            'fieldApiName': result.fieldApiName,
            'fieldType': 'STRING',
            'fieldLabel': result.fieldLabel,
            'value': result.fieldLabel,
            'fieldIsRequired': result.fieldIsRequired,
            'fieldIsReadOnly': result.fieldIsReadOnly,
            'picklistValues': result.picklistValues
        };
        return tempTitle;
    },
    createObjFromAction: function (action,result) {
        var tempObjFromAction = {
            'fieldApiName': result.fieldApiName,
            'fieldType': result.fieldType,
            'fieldLabel': result.fieldLabel,
            'value': action[result.fieldApiName],
            'fieldIsRequired': result.fieldIsRequired,
            'fieldIsReadOnly': result.fieldIsReadOnly,
            'picklistValues': result.picklistValues
        };
        return tempObjFromAction;
    },
})