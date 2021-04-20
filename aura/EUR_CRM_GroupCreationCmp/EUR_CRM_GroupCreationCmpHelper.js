({
    handleInit: function (component, helper) {
        helper.setFilterSObjectName(component);
        var recId = component.get('v.recordId');
        console.log('recId => ', recId);
        if (recId) {
            helper.loadGroupRecord(component, helper, recId);
        }
        else {
            helper.setRecord(component);
        }
    },
    setFilterSObjectName: function (component) {
        var groupApiName = component.get('v.sObjectName');
        if(groupApiName === 'EUR_CRM_Account_Target_Group__c') {
            component.set('v.filterSObjectName', 'EUR_CRM_Account__c');
        }
    },
    loadGroupRecord: function (component, helper, recId) {
        var loadGroup = component.get("c.loadGroup");
        loadGroup.setParams({
            "groupId": recId,
            "sObjectName": component.get('v.sObjectName')
        });
        console.log('loadGroup => ', loadGroup);
        loadGroup.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state => ', state);
            if (component.isValid() && state === "SUCCESS") {
                var record = JSON.parse(response.getReturnValue());
                console.log('record => ', record);
                component.set('v.record', record);
                component.set('v.isRecordLoaded', true);
                if(record.EUR_CRM_IsDynamic__c == true) {
                    component.set('v.groupTypeValue', 'isDynamic');
                }else if(record.EUR_CRM_IsDynamic__c == false && record.EUR_CRM_Criteria__c != null){
                    component.set('v.groupTypeValue', 'isStatic');
                }
                helper.populateFilter(component);
            }
        });
        $A.enqueueAction(loadGroup);
    },
    setRecord: function (component) {
        console.log('setRecord()');
        var group = {
            sobjectType: component.get('v.sObjectName')
        };
        console.log('group => ', group);
        component.set('v.record', group);
    },
    populateFilter: function (component) {
        var criteria = component.get('v.record.EUR_CRM_Criteria__c');
        if (criteria) {
            let criteriaObj = JSON.parse(criteria);
            if (criteriaObj.hasOwnProperty('objectName') && criteriaObj.hasOwnProperty('items') &&
                !$A.util.isEmpty(criteriaObj.items) && criteriaObj.objectName === component.get('v.filterSObjectName')) {
                component.find('parentFilterBuilder').setInitialItems(criteriaObj.items, criteriaObj.filterLogic);
            }
            if (criteriaObj.hasOwnProperty('childItems') && !$A.util.isEmpty(criteriaObj.childItems)) {
                component.find('childFilterBuilder').populateFilter(criteriaObj.childItems);
            }
        }
    },
    handleSave: function (component, event, helper) {
        if(component.get("v.groupTypeValue")) {
            event.getSource().set("v.disabled", true);
            component.set('v.filter', null);
            var isValidFields = helper.validateFields(component);
            if (isValidFields) {
                helper.buildParentFilter(component);
                helper.buildChildFilter(component);
            }
        } else {
            helper.showToast('error', "Save Error", "The Group is not assigned.");
        }
    },
    validateFields: function (component) {
        var recordFields = component.find('recordFields');
        var isValidFields = true;
        if(!$A.util.isEmpty(recordFields)) {
            if (recordFields instanceof Array) {
                isValidFields = recordFields.reduce(function (validFields, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validFields && inputCmp.get('v.validity').valid;
                }, true);
            }
            else {
                recordFields.showHelpMessageIfInvalid();
                isValidFields = recordFields.get('v.validity').valid;
            }
        }
        return isValidFields;
    },
    buildParentFilter: function (component) {
        var parentFilterBuilder = component.find('parentFilterBuilder');
        parentFilterBuilder.validate();
    },
    buildChildFilter: function (component) {
        var childFilterBuilder = component.find('childFilterBuilder');
        childFilterBuilder.buildFilter();
    },
    buildParentFilterHandler: function (component, event, helper) {
        var parentFilterResult = event.getParam("result");
        console.log('Parent FilterBuilder Component result:', JSON.parse(JSON.stringify(parentFilterResult)));
        if (!parentFilterResult.success) {
            helper.showToast('error', 'Filter Builder Error', parentFilterResult.message);
            component.find('svBtn').set("v.disabled", false);
        } else if ( ! parentFilterResult.filter || ! parentFilterResult.filter.filterLogic || ! parentFilterResult.filter.items || ! parentFilterResult.filter.items.length) {
            helper.showToast('error', 'Filter Builder Error', 'Please, choose Account field criteria.');
            component.find('svBtn').set("v.disabled", false);
        }
        else {
            var filter = component.get('v.filter');
            if (filter === null) {
                filter = {};
            }
            for (let attr in parentFilterResult.filter) {
                filter[attr] = parentFilterResult.filter[attr];
            }
            component.set('v.filter', filter);
        }
    },
    buildChildFilterHandler: function (component, event, helper) {
        var childFilterResult = event.getParam("result");
        console.log('ChildRelationshipFilterBuilder Component result: ', JSON.parse(JSON.stringify(childFilterResult)));
        if (!childFilterResult.success) {
            helper.showToast('error', 'Filter Builder Error', childFilterResult.message);
            component.find('svBtn').set("v.disabled", false);
        }
        else {
            var filter = component.get('v.filter');
            if (filter === null) {
                filter = {};
            }
            filter.childItems = childFilterResult.childFilters;
            component.set('v.filter', filter);
        }
    }, 
    saveGroupFilterHandler: function (component, event, helper) {
        var filter = event.getParam('value');
        console.log('filter', JSON.parse(JSON.stringify(filter)));
        if (filter !== null && filter.hasOwnProperty('objectName') && filter.hasOwnProperty('childItems')) {
            // filter.childItems = (!filter.hasOwnProperty('childItems')) ? [] : filter.childItems;
            filter.childItems.forEach(function (value, key, map) {
                if (value.parentRelationType === null) {
                    map.delete(key);
                }
            });
            if ( ! filter.items.length && ! filter.childItems.length) {
                helper.showToast('error', 'Filter Builder Error', 'No Filter is assigned!');
                component.find('svBtn').set("v.disabled", false);
            }
            else {
                var convertedChildItems = {};
                filter.childItems.forEach(function (childContainers) {
                    for (let childContainer in childContainers) {
                        const item = childContainers[childContainer];
                        for (let key in item) {
                            if (item['filterLogic'] &&
                                item['testQuery'] &&
                                item['items'] &&
                                item['items'].length) {
                                if ( ! convertedChildItems[childContainer]) { convertedChildItems[childContainer] = {}; }
                                convertedChildItems[childContainer][key] = item[key];
                            }
                        }
                    }
                });
                console.log('convertedChildItems => ', convertedChildItems);
                if (convertedChildItems) { filter.childItems = convertedChildItems; }

                helper.saveRecord(component, helper, filter);
            }
        }
    },
    saveRecord: function (component, helper, filter) {
        var record = component.get('v.record');
        var isDynamic = false;
        if(component.get('v.groupTypeValue') === 'isDynamic'){
            isDynamic = true;
        }

        var saveAction = component.get('c.saveGroup');
        console.log(record);
        var group = {
            Id: record.Id || null,
            sobjectType: component.get('v.sObjectName'),
            EUR_CRM_IsDynamic__c: isDynamic,
            EUR_CRM_Criteria__c: JSON.stringify(filter)
        };
        console.log(group);
        saveAction.setParams({
            "record": group
        });
        saveAction.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('response.getReturnValue() = ',response.getReturnValue());
                var result = JSON.parse(response.getReturnValue());
                console.log(result);
                if(result.success) {
                    helper.showToast('success', "Saved", "Filters have been saved");
                } else {
                    helper.showToast('error', "Save Error", JSON.stringify(result.message));
                }
                component.find('svBtn').set("v.disabled", false);
            }
        });
        $A.enqueueAction(saveAction);
    },
    showToast: function (type, title, message) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        resultsToast.fire();
    },
    handleCancel: function (component, helper) {
        var recId = component.get('v.recordId');
        if (!recId) {
            helper.navigateToSobjectHomePage(component.get('v.sObjectName'));
        }
        else {
            helper.navigateToRecordPage(recId);
        }
    },
    navigateToSobjectHomePage: function (sObjectName) {
        var navEvt = $A.get("e.force:navigateToObjectHome");
        navEvt.setParams({
            'scope': sObjectName
        });
        navEvt.fire();
    },
    navigateToRecordPage: function (recordId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    }
});