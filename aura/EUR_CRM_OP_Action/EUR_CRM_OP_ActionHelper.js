/**
 * Created by User on 6/1/2018.
 */
({
    fillAction: function (component, event, helper) {
        var hasTarget = component.get('v.hasTarget');
        var hasQuota = component.get('v.hasQuota');
        var isShow;
        if (hasQuota && hasTarget) {
            isShow = false;
        } else if (hasQuota && !hasTarget) {
            isShow = false;
        } else if (!hasQuota && !hasTarget) {
            isShow = true;
        }
        component.set('v.hideOPTarget', isShow);

        var actionGetRecordType = component.get("c.getRecordTypesForAction");
        var rec = component.get('v.actionChangedFields');
        if (rec == null) {
            rec = {
                'sobjectType': 'EUR_CRM_OP_Action__c',
                'Id': null,
                'EUR_CRM_OP_Template__c': component.get('v.recordTemplateId')
            };
        }

        component.set('v.valueSetSuccessfulStatus_PICKLIST', rec.EUR_CRM_Successful_Status__c);
        component.set('v.valueSuccess_PICKLIST', rec.EUR_CRM_Selected_Field_for_Success__c);
        component.set('v.valueUnsuccess_PICKLIST', rec.EUR_CRM_Selected_Field_for_Unsuccess__c);
        component.set('v.old_valueSuccess_PICKLIST', rec.EUR_CRM_Selected_Field_for_Success__c);
        component.set('v.old_valueUnsuccess_PICKLIST', rec.EUR_CRM_Selected_Field_for_Unsuccess__c);
        component.set('v.actionChangedFields', rec);
        var recId = rec.Id;

        actionGetRecordType.setParams({
            recordId: recId
        });
        actionGetRecordType.setCallback(this, function (resp) {
            var stateOfResp = resp.getState();
            if (component.isValid() && stateOfResp == 'SUCCESS') {
                var resultArr = JSON.parse(resp.getReturnValue());
                // console.log('c.getRecordTypesForAction resultArr => ', resultArr);
                if (rec.EUR_CRM_OP_Template__c == null && rec.RecordTypeId != null) {
                    for (var i = 0; i < resultArr.availableRecordTypes.length; i++) {
                        if (resultArr.availableRecordTypes[i].value == rec.RecordTypeId) {
                            component.set('v.selectedRecordType', [rec.RecordTypeId, resultArr.availableRecordTypes[i].label]);
                            break;
                        }
                    }
                    if (rec.EUR_CRM_MultiPLGeneralOrProductRT__c) {
                        component.set('v.selectedArrayGeneralPromo', rec.EUR_CRM_MultiPLGeneralOrProductRT__c.split(','))
                    }
                    if (rec.EUR_CRM_MultiPLOpTarget__c) {
                        component.set('v.selectedArrayPromoTarget', rec.EUR_CRM_MultiPLOpTarget__c.split(','))
                    }
                    if (rec.EUR_CRM_MultiPLPromoTargetSumm__c) {
                        component.set('v.selectedArrayPromoTargetSumm', rec.EUR_CRM_MultiPLPromoTargetSumm__c.split(','))
                    }
                } else {
                    component.set('v.selectedRecordType', resultArr.defaultOrUsedRecordType);
                }
                component.set('v.recordTypeList', resultArr.availableRecordTypes);
                if (component.get('v.selectedRecordType')[1] == 'General') {
                    component.set('v.isGeneralRecordType', true);
                }
                helper.getFields(component, event, helper);
            } else {
                console.log('Failed with state: ' + stateOfResp);
            }
        });
        $A.enqueueAction(actionGetRecordType);
    },

    getFields: function (component, event, helper) {
        // console.log('v.actionChangedFields => ', component.get('v.actionChangedFields'));
        var rec = component.get('v.actionChangedFields');

        var recId = rec.Id;

        var action = component.get("c.getActionFields");
        action.setParams({
            devName: 'Action',
            recordId: recId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state == 'SUCCESS') {
                var resultArray = JSON.parse(response.getReturnValue());
                // console.log('c.getActionFields resultArray => ', resultArray);
                for (var i = 0; i < resultArray.length; i++) {
                    if (resultArray[i].value != null) {
                        rec[resultArray[i].fieldApiName] = resultArray[i].value;
                    }

                    if (resultArray[i].fieldApiName == 'RecordTypeId' && resultArray[i].value == null) {
                        console.log('resultArray[i].fieldApiName == \'RecordTypeId\' => ', resultArray[i].fieldApiName == 'RecordTypeId');
                        rec[resultArray[i].fieldApiName] = component.get('v.selectedRecordType')[0];
                    }

                    if (rec[resultArray[i].fieldApiName] == null) {
                        helper.createField(component, event, helper, helper.createObj(resultArray[i]));
                    } else if (resultArray[i].fieldApiName == 'EUR_CRM_Successful_Status__c') {
                        // helper.getFieldsForSuccessStatus(component, event, helper,true);
                        helper.getRestrictedFieldsForSuccessStatus(component, event, helper,true);
                        component.set('v.valueSuccessfulStatus_PICKLIST', rec.EUR_CRM_Successful_Status__c);
                    } else {
                        helper.createField(component, event, helper, helper.createObjFromAction(rec, resultArray[i]));
                    }
                }
                component.set("v.actionChangedFields", rec);
                component.set("v.new_actionChangedFields", Object.assign({}, rec));
                // helper.getFieldsForSuccessStatus(component, event, helper,true);
                helper.getRestrictedFieldsForSuccessStatus(component, event, helper,true);
                component.set('v.isReady', true);
                helper.onChangeRecordType(component, helper);
            } else {
                console.log('Failed with state: ' + state);
            }
        });
        $A.enqueueAction(action);
        // }
    },

    onChangeRecordType: function(component, helper) {
        // let stageComponent;
        let parentActionComponent;
        let parentActionAnswerComponent;
        component.find('actionField').forEach(function(tempField) {
            let fieldApiName = tempField.get('v.fieldValue').fieldApiName;
            // if(fieldApiName == 'EUR_CRM_Stage__c') {
            //     stageComponent = tempField;
            // }
            if (fieldApiName == 'EUR_CRM_Parent_Action__c') {
                parentActionComponent = tempField;
            } else if (fieldApiName == 'EUR_CRM_Parent_Action_Answer__c') {
                parentActionAnswerComponent = tempField;
            }
        });

        var val = component.find('selectRecordType').get('v.value');
        var recordTypeList = component.get('v.recordTypeList');
        for (var i = 0; i < recordTypeList.length; i++) {
            if (recordTypeList[i].value == val) {
                let rtName = recordTypeList[i].label;
                var newRec = [val, rtName];
                component.set('v.selectedRecordType', newRec);
                helper.onActionFieldChanges(component, 'RecordTypeId', val);
                component.set('v.isGeneralRecordType', rtName == 'General');
                // if(rtName == 'General' && stageComponent) {
                //     component.set('v.isGeneralRecordType', true);
                //     $A.util.addClass(stageComponent, 'slds-hide');
                // } else if (stageComponent){
                //     component.set('v.isGeneralRecordType', false);
                //     $A.util.removeClass(stageComponent, 'slds-hide');
                // }
                if(rtName == 'Product') {
                    $A.util.addClass(parentActionComponent, 'slds-hide');
                    $A.util.addClass(parentActionAnswerComponent, 'slds-hide');
                } else {
                    $A.util.removeClass(parentActionComponent, 'slds-hide');
                    $A.util.removeClass(parentActionAnswerComponent, 'slds-hide');
                }
                return;
            }
        }
    },

    onActionFieldChanges: function (component, fieldName, fieldValue) {
        let actionChangedFields = component.get("v.new_actionChangedFields");
        actionChangedFields[fieldName] = fieldValue;
        component.set("v.new_actionChangedFields", actionChangedFields);
    },
    createField: function (component, event, helper, field) {
        field.templateId = component.get('v.recordTemplateId');
        $A.createComponent(
            "c:EUR_CRM_OP_DynamicFieldGeneration",
            {
                "aura:id" : "actionField",
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
    createObjFromAction: function (action, result) {
        var tempObjFromAction = {
            'fieldApiName': result.fieldApiName,
            'fieldType': result.fieldType,
            'fieldLabel': result.fieldLabel,
            'value': action[result.fieldApiName],
            'fieldIsRequired': result.fieldIsRequired,
            'fieldIsReadOnly': result.fieldIsReadOnly,
            'picklistValues': result.picklistValues
        };
        console.log('tempObjFromAction = ', tempObjFromAction);
        return tempObjFromAction;
    },

    saveAction: function (component, event, helper) {
        if(helper._validation(component, event, helper)) {
            var opAction = component.get('v.actionChangedFields');
            component.set('v.new_actionChangedFields', opAction);
            var recordTemplateId = component.get('v.recordTemplateId');
            var recordTypeId;
            if (component.get('v.selectedRecordType')) {
                recordTypeId = component.get('v.selectedRecordType')[0];
            }
            opAction.RecordTypeId = recordTypeId;
            helper._saveActionInDB(component, event, helper);
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

    getFieldsForSuccessStatus: function (component, event, helper, isInit) {
        var valSuc = component.get('v.valueSuccess_PICKLIST');
        console.log('valSuc=', valSuc);
        if (valSuc) {
            var actiongetFieldsSuccessStatus = component.get('c.getValuesForSuccessStatus');
            actiongetFieldsSuccessStatus.setParams({
                nameObj: 'EUR_CRM_OP_Visit_Action__c',
                nameField: valSuc
            });
            actiongetFieldsSuccessStatus.setCallback(this, function (resp) {
                var stateRespStatus = resp.getState();
                if (component.isValid() && stateRespStatus == 'SUCCESS') {
                    console.log('success', stateRespStatus);
                    var respStatus = JSON.parse(resp.getReturnValue());
                    console.log('respStatus = ', respStatus);
                    if (respStatus.length > 0 && respStatus[0].fieldType == 'PICKLIST') {
                        component.set('v.valueSetSuccessfulStatus_PICKLIST', respStatus[0].picklistValues);
                        if (isInit) {
                            component.set('v.valueSuccessfulStatus_PICKLIST', component.get('v.new_actionChangedFields').EUR_CRM_Successful_Status__c);
                        }else{
                            component.set('v.valueSuccessfulStatus_PICKLIST', null);
                        }
                    } else {
                        console.log('no PICKLIST');
                        component.set('v.valueSetSuccessfulStatus_PICKLIST', {});
                        component.set('v.valueSuccessfulStatus_PICKLIST', null);

                    }

                } else {
                    console.log('Failed with state: ' + stateRespStatus);
                    helper.fireToast('Error', 'Failed with state: ' + stateRespStatus);
                }
            });
            $A.enqueueAction(actiongetFieldsSuccessStatus);
        } else {
            component.set('v.valueSetSuccessfulStatus_PICKLIST', {});
            component.set('v.valueSuccessfulStatus_PICKLIST', null);

        }
    },

    getRestrictedFieldsForSuccessStatus: function (component, event, helper, isInit) {
        var valSuc = component.get('v.valueSuccess_PICKLIST');
        console.log('valSuc=', valSuc);
        if (valSuc) {
            var actiongetFieldsSuccessStatus = component.get('c.getRestrictedValuesForSuccessStatus');
            let recordTemplateId = component.get('v.recordTemplateId');
            actiongetFieldsSuccessStatus.setParams({
                nameObj: 'EUR_CRM_OP_Visit_Action__c',
                nameField: valSuc,
                templateId: recordTemplateId
            });
            actiongetFieldsSuccessStatus.setCallback(this, function (resp) {
                var stateRespStatus = resp.getState();
                if (component.isValid() && stateRespStatus == 'SUCCESS') {
                    console.log('success', stateRespStatus);
                    var respStatus = JSON.parse(resp.getReturnValue());
                    console.log('respStatus = ', respStatus);
                    if (respStatus.length > 0 && respStatus[0].fieldType == 'PICKLIST') {
                        component.set('v.valueSetSuccessfulStatus_PICKLIST', respStatus[0].picklistValues);
                        if (isInit) {
                            component.set('v.valueSuccessfulStatus_PICKLIST', component.get('v.new_actionChangedFields').EUR_CRM_Successful_Status__c);
                        }else{
                            component.set('v.valueSuccessfulStatus_PICKLIST', null);
                        }
                    } else {
                        console.log('no PICKLIST');
                        component.set('v.valueSetSuccessfulStatus_PICKLIST', {});
                        component.set('v.valueSuccessfulStatus_PICKLIST', null);

                    }

                } else {
                    console.log('Failed with state: ' + stateRespStatus);
                    helper.fireToast('Error', 'Failed with state: ' + stateRespStatus);
                }
            });
            $A.enqueueAction(actiongetFieldsSuccessStatus);
        } else {
            component.set('v.valueSetSuccessfulStatus_PICKLIST', {});
            component.set('v.valueSuccessfulStatus_PICKLIST', null);

        }
    },

    _validation : function(component, event, helper){
        let allTemplateFields = component.find('actionField');

        // console.log('temp find ',JSON.stringify(component.find('actionField')));
        // console.log('field find fieldIsRequired ',JSON.stringify(component.find('actionField')[0].find('idField').get('v.value')));
        // console.log('field find fieldIsRequired ',JSON.stringify(component.find('actionField')[0].find('idField').get('v.required')));

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
    },

    _saveActionInDB: function (component, event, helper) {
        var actionSave = component.get('c.saveActionInDB');
        var act = component.get('v.actionChangedFields');
        act.EUR_CRM_OP_Template__c = component.get('v.recordTemplateId');
        console.log('act = ', JSON.stringify(act));
        actionSave.setParams({
            actionObj: act
        });
        actionSave.setCallback(this, function (resp) {
            var stateResp = resp.getState();
            if (component.isValid() && stateResp == 'SUCCESS') {
                console.log('success', resp);
                var res = resp.getReturnValue();
                console.log('res = ', res);
                if (res == 'SUCCESS') {
                    helper.fireToast('Success', "Record was saved success.");
                    component.getEvent('closeOPActionTab').setParams({
                        "isNeedRefresh": true
                    }).fire();
                } else {
                    helper.fireToast('Error', res);
                }
            } else {
                console.log('Failed with state: ' + resp.getError());
                console.log(resp.getError()[0].pageErrors[0].message);
                helper.fireToast('Error', resp.getError()[0].pageErrors[0].message);
            }
        });
        $A.enqueueAction(actionSave);
    }



})