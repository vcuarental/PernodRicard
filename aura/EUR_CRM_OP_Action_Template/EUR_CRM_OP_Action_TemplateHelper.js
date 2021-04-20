/**
 * Created by User on 6/3/2018.
 */
({
    fillTemplate: function (component, event, helper) {
        helper.fillMultiPicklistTargetQuotaLevel(component, event, helper);
        helper.getActions(component, event, helper);
    },

    getActions: function (component, event, helper) {
        var actionGetOPActions = component.get('c.getOPActionRecords');
        actionGetOPActions.setParams({
            recordTemplateId: component.get('v.recordTemplateId')
        });
        actionGetOPActions.setCallback(this, function (actionResponse) {
            var actionGetOPActionsState = actionResponse.getState();
            if (component.isValid() && actionGetOPActionsState == 'SUCCESS') {
                component.set('v.actionList', actionResponse.getReturnValue());
            } else {
                console.log('Failed with state: ' + actionGetOPActionsState);
            }
        });
        $A.enqueueAction(actionGetOPActions);
    },

    fillMultiPicklistTargetQuotaLevel: function (component, event, helper) {
        var actionTargetQuotaLevel = component.get('c.getTargetQuotaLevels');
        actionTargetQuotaLevel.setParams({
            recordTemplateId: component.get('v.recordTemplateId')
        });
        actionTargetQuotaLevel.setCallback(this, function (respTargetQuotaLevel) {
            var stateTargetQuotaLevel = respTargetQuotaLevel.getState();
            if (component.isValid() && stateTargetQuotaLevel == 'SUCCESS') {
                var resultTargetQuotaLevel = JSON.parse(respTargetQuotaLevel.getReturnValue());
                var newObj = helper.createObj(resultTargetQuotaLevel);
                component.set('v.multiPiclistForLevel', newObj);
                var actionChangedFields = {
                    'Id': component.get('v.recordTemplateId'),
                    'EUR_CRM_Target_Quota_Levels__c': resultTargetQuotaLevel.value
                };
                component.set("v.actionChangedFields", actionChangedFields);
                helper.getFields(component, event, helper);
            } else {
                console.log('Failed with state: ' + stateTargetQuotaLevel);
            }
        });
        $A.enqueueAction(actionTargetQuotaLevel);

    },
    getFields: function (component, event, helper) {
        var actionChangedFields =  component.get("v.actionChangedFields");
        var action = component.get("c.getActionFields");
        action.setParams({
            devName: 'Template',
            recordId: component.get('v.recordTemplateId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state == 'SUCCESS') {
                var resultArray = JSON.parse(response.getReturnValue());

                for (var i = 0; i < resultArray.length; i++) {
                    console.log('resultArray[i].fieldApiName',resultArray[i].fieldApiName);
                    actionChangedFields[resultArray[i].fieldApiName] = resultArray[i].value;
                    helper.createField(component, event, helper, helper.createObj(resultArray[i]));
                }
                component.set("v.actionChangedFields", actionChangedFields);

                component.set('v.isReady', true);
            } else {
                console.log('Failed with state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    onActionFieldChange: function (component, fieldName, fieldValue) {
        var actionChangedFields = component.get("v.actionChangedFields");
        actionChangedFields[fieldName] = fieldValue;
        component.set("v.actionChangedFields", actionChangedFields);
    },
    createField: function (component, event, helper, field) {
        $A.createComponent(
            "c:EUR_CRM_OP_DynamicFieldGeneration",
            {
                "aura:id" : "templateField",
                "fieldValue": field,
                "objName": "EUR_CRM_OP_Template__c"
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

    saveOPTemplate: function (component, event, helper,isOpenAction) {
        if(helper._validation(component,event,helper)) {

            var opTemplate = component.get('v.actionChangedFields');
            var actionSave = component.get('c.saveTemplateInDB');
            console.log('opTemplate = ', JSON.stringify(opTemplate));
            var actionListForInsert;
            if (opTemplate.Id == null) {
                var actionList = component.get('v.actionList');
                if (actionList.length > 0) {
                    actionList.splice(0, 1);
                    actionListForInsert = actionList;
                }
                if(component.get("v.pageReference") && component.get("v.pageReference").state && component.get("v.pageReference").state.recordTypeId) {
                    var rtId = component.get("v.pageReference").state.recordTypeId;
                    opTemplate.RecordTypeId = rtId;
                }
            }
            actionSave.setParams({
                opTemplate: opTemplate,
                actionList: actionListForInsert
            });
            actionSave.setCallback(this, function (resp) {
                var stateResp = resp.getState();
                if (component.isValid() && stateResp == 'SUCCESS') {
                    var res = resp.getReturnValue();
                    let arrRes = res.split(':::');
                    if (arrRes[0] == 'SUCCESS') {
                        // if (res == 'SUCCESS') {
                        helper.fireToast('Success', "Record was saved success.");
                        if (opTemplate.Id == null && isOpenAction == true) {
                            opTemplate.Id = arrRes[1];
                            component.set('v.actionChangedFields', opTemplate);
                            component.set('v.recordTemplateId', opTemplate.Id);
                            console.log('opTemplate with Id = ' + JSON.stringify(opTemplate));
                            component.set('v.isOpenOPActionTab', true);
                        } else {
                            helper.cancelOPTemplate(component, event, helper);
                        }
                    } else {
                        helper.fireToast('Error', res);
                    }
                } else {
                    console.log('Failed with state: ' + stateResp);
                    helper.fireToast('Error', 'Failed with state: ' + stateResp);
                }
            });
            $A.enqueueAction(actionSave);
        }
    },

    deleteOPAction: function (component, event, helper) {
        var actionRec = event.getParam("action");
        if(actionRec.Id != null) {
            var actionSave = component.get('c.deleteAction');
            actionSave.setParams({
                actionId: actionRec.Id
            });
            actionSave.setCallback(this, function (resp) {
                var stateResp = resp.getState();
                if (component.isValid() && stateResp == 'SUCCESS') {
                    var res = resp.getReturnValue();
                    if (res == 'SUCCESS') {
                        helper.fireToast('SUCCESS', 'Record was deleted success.');
                        component.set('v.recordAction', null);
                        helper.getActions(component, event, helper);
                    } else {
                        helper.fireToast('Error', res);
                    }
                } else {
                    console.log('Failed with state: ' + stateResp);
                    helper.fireToast('Error', 'Failed with state: ' + stateResp);
                }
            });
            $A.enqueueAction(actionSave);
        }else{
            var actionList = component.get('v.actionList');
            var indexRec = event.getParam("index");
            actionList.splice(indexRec,1);
            component.set('v.actionList',actionList);
        }
    },
    fireToast: function (state, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": state,
            "message": message,
            "type": state.toLowerCase()
        });
        toastEvent.fire();
    },
    cancelOPTemplate: function (component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "EUR_CRM_OP_Template__c"
        });
        homeEvent.fire();
    },

    _validation : function(component, event, helper){
        let allTemplateFields = component.find('templateField');

        function isRequired(element, index, array) {
            if(element.find('idField') && element.find('idField').get('v.required')){
                if(element.find('idField').get('v.value')){
                    return true;
                }else return false;
            }else return true;
        }
        var passed = allTemplateFields.every(isRequired);
        if(passed == false){
            helper.fireToast('Error', 'Fill all required fields, please');
        }
        return passed;
    }
})