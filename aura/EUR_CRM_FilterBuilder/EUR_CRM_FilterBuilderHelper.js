({
    initHandler: function (cmp, helper) {
        var sObjectName = cmp.get('v.sObjectName');
        if (sObjectName) {
            helper.setSObjectFieldsOptionsHandler(cmp, helper);
            helper.initSObjectFilterItems(cmp, helper);
        }
    },

    setSObjectFieldsOptionsHandler: function(cmp, helper) {
        var sObjectName = cmp.get('v.sObjectName');
        var restrictFieldsFromSelect = cmp.get('v.restrictFieldsFromSelect');
        var getSObjectFields = cmp.get("c.getSObjectFieldsSelectOptions");
        var parentRelationsToFilter = cmp.get("v.parentRelationsToFilter");
        getSObjectFields.setParams({
            "sObjectName": sObjectName
        });
        getSObjectFields.setStorable(true);
        getSObjectFields.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var sObjectFields = response.getReturnValue();
                var fieldNames = helper.getFieldNames(sObjectFields, restrictFieldsFromSelect);
                cmp.set("v.sObjectFields", fieldNames);
            }
        });
        $A.enqueueAction(getSObjectFields);
    },

    addParentObjectFiltersHandler: function(cmp, event, helper) {
        var getSObjectFields = cmp.get("c.getSObjectFieldsSelectOptions");
        var params = event.getParam('arguments');
        if (!params) return;
        var parentRelationsToFilter = params.parentRelationsToFilter;
        if(!$A.util.isUndefinedOrNull(parentRelationsToFilter) && !$A.util.isEmpty(parentRelationsToFilter)) {
            var parentFieldNames = [];
            parentRelationsToFilter.forEach(function(relation) {
                getSObjectFields.setParams({
                    "sObjectName": relation.sObjectName
                });
                getSObjectFields.setCallback(this, function(response) {
                    var state = response.getState();
                    if (cmp.isValid() && state === "SUCCESS") {
                        var fieldNames = cmp.get("v.sObjectFields");
                        var sObjectFields = response.getReturnValue();
                        var parentFieldNames = helper.getFieldNames(sObjectFields);
                        parentFieldNames.forEach(function(field) {
                            field.label = field.label.replace(field.label.split(':', 1), relation.label);
                            field.name = relation.fieldName + '.' + field.name;
                        });
                        fieldNames = fieldNames.concat(parentFieldNames);
                        cmp.set("v.sObjectFields", fieldNames);
                    }
                });
                $A.enqueueAction(getSObjectFields);
            });
        }
    },

    getFieldNames: function(sObjectFields, restrictFieldsFromSelect) {
        var fieldNamesSorted = JSON.parse(sObjectFields.fieldNames);
        var fieldNames = [];
        fieldNamesSorted.forEach(function(label) {
            for(var key in sObjectFields) {
                if(sObjectFields[key] == label) {
                    if(!restrictFieldsFromSelect || restrictFieldsFromSelect.indexOf(key) == -1) {
                        fieldNames.push({
                            label: sObjectFields[key],
                            name: key
                        });
                    }
                    delete sObjectFields[key];
                }
            }
        });
        return fieldNames;
    },

    initSObjectFilterItems: function(cmp, helper) {
        var filterItemsRangeCount = cmp.get('v.filterItemsRangeCount');
        var filterConditionItems = cmp.get('v.filterConditionItems');
        for(let i = filterConditionItems.length; i < filterItemsRangeCount.min; i++) {
            filterConditionItems.push({
                field : '',
                operator : 'equals',
                value : ''
            });
        }
        var operatorOptions = cmp.get('v.operatorOptions');
        filterConditionItems.forEach(function(item) {
            item.operatorOptions = operatorOptions;
        console.log('item.operatorOptions', item.operatorOptions);
        });
        // console.log('item.operatorOptions', item.operatorOptions);
        console.log('filterConditionItems', filterConditionItems);
        cmp.set('v.filterConditionItems', filterConditionItems);
        helper.describeFields(cmp, helper);
    },

    setInitialItemsHandler: function(cmp, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var conditionItems = params.conditionItems;
            if(conditionItems) {
                console.log('conditionItems', conditionItems);
                cmp.set('v.filterConditionItems', conditionItems);
            }
            var filterLogic = params.filterLogic;
            console.log('filterLogic', filterLogic);
            if(filterLogic) {
                /* Edited logic how default
                 * filter logic is differentiated
                 *
                 * @edit: PZ 10.01.18
                 */
                // remove dupe and leading/trailing spaces
                filterLogic = filterLogic.replace(/\s+/g,' ').trim();
                cmp.set('v.filterLogic', filterLogic);

                var isCustomFilter = true;
                // default filter logic is condition items
                // separated by AND operators
                var matches = filterLogic.match(/\d{1,2}(?= ?(?=AND|$))/gi);
                if(matches && conditionItems && matches.length == conditionItems.length){
                    isCustomFilter = false;
                }
                cmp.set('v.isCustomFilterLogic', isCustomFilter);
            }
            helper.initSObjectFilterItems(cmp, helper);
        }
    },

    describeFields: function(cmp, helper) {
        var filterConditionItems = cmp.get('v.filterConditionItems');
        var sObjectName = cmp.get('v.sObjectName');
        var describeFieldsAction = cmp.get('c.describeFields');
        var fieldNames = [];
        filterConditionItems.forEach(function(item, index) {
            if(item.field) {
                var fieldName = item.field;
                if(fieldNames.indexOf(fieldName) == -1) {
                    console.log('if(fieldNames.indexOf(fieldName) == -1) : ' + fieldNames.indexOf(fieldName));
                    fieldNames.push(fieldName);
                }
            }
        });
        console.log('fieldNames', fieldNames);
        if (!sObjectName) return;

        describeFieldsAction.setParams({
            "sObjectName": sObjectName,
            "fieldApiNames": fieldNames
        });
        describeFieldsAction.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var fieldsDescribe = JSON.parse(response.getReturnValue());
                console.log('fieldsDescribe' , fieldsDescribe);
                fieldsDescribe.forEach(function(field) {
                    filterConditionItems.forEach(function(item, index) {
                        if(item.field == field.name) {
                            item.fieldDescribe = {
                                name: field.name,
                                fieldType: field.fieldType,
                                picklistOptions: []
                            };
                            if(field.fieldType == 'PICKLIST' || field.fieldType == 'MULTIPICKLIST') {
                                item.fieldDescribe.inputType = 'options';
                            }
//                            else if(field.fieldType == 'DATE') {
//                                item.fieldDescribe.inputType = 'date';
//                            } else if(field.fieldType == 'DATETIME') {
//                                item.fieldDescribe.inputType = 'datetime';
//                            }
                            else {
                                item.fieldDescribe.inputType = 'text';
                            }
                            if(field.picklistOptions && field.picklistOptions.length) {
                                item.fieldDescribe.picklistOptions = [];
                                var selectedValues = [];
                                if(item.value) {
                                    selectedValues = item.value.split(',').map(item => item.trim());
                                }
                                field.picklistOptions.forEach(function(option) {
                                    item.fieldDescribe.picklistOptions.push({
                                        label: option,
                                        selected: selectedValues.indexOf(option) > -1 ? true : false
                                    });
                                });
                            }
                            item.operatorOptions = field.operatorOptions;
                            if(item.operatorOptions.indexOf(item.operator) == -1) item.operator = 'equals';
                            if(field.fieldType == 'REFERENCE') {
                                item.fieldDescribe.parentSObject = field.parentSObjectName;
                            }
                            if(field.fieldType == 'BOOLEAN') {
                                item.fieldDescribe.inputType = 'options';
                                item.fieldDescribe.picklistOptions = [];
                                item.fieldDescribe.picklistOptions.push({
                                    label: 'TRUE',
                                    selected: false
                                });
                                item.fieldDescribe.picklistOptions.push({
                                    label: 'FALSE',
                                    selected: false
                                });
                            }
                        }
                    });
                });
                console.log('filterConditionItems', filterConditionItems);
                cmp.set('v.filterConditionItems', filterConditionItems);
                // Renew picklist cmp value if another picklist is selected
                var picklistCmpList = cmp.find('picklistCmp');
                if(picklistCmpList) {
                    [].concat(picklistCmpList).forEach(function(picklistCmp) {
                        picklistCmp.resetLabel();
                    });
                }

                var filterItemsRangeCount = cmp.get('v.filterItemsRangeCount');
                if(filterConditionItems.length <= filterItemsRangeCount.min) {
                    cmp.find('removeRowBtn').getElement().setAttribute('disabled', 'disabled');
                } else {
                    cmp.find('removeRowBtn').getElement().removeAttribute('disabled');
                }
            }
            helper.hideSpinner(cmp);
        });
        $A.enqueueAction(describeFieldsAction);
    },

    onItemFieldValueChangeHandler: function(cmp, event, helper) {
        helper.showSpinner(cmp);
        var filterConditionItems = cmp.get('v.filterConditionItems');
        var rowIndex = event.getSource().get('v.name');
        filterConditionItems[rowIndex].value = '';
        cmp.set('v.filterConditionItems', filterConditionItems);
        helper.describeFields(cmp, helper);
    },
 
    addItemHandler: function(cmp, event) {
        var
            filterConditionItems = cmp.get('v.filterConditionItems'),
            filterItemsRangeCount = cmp.get('v.filterItemsRangeCount'),
            target = event.srcElement || event.target;

        cmp.find('removeRowBtn').getElement().removeAttribute('disabled');
        var operatorOptions = cmp.get('v.operatorOptions');
        filterConditionItems.push({
            index : filterConditionItems.length + 1,
            field : '',
            operator : 'equals',
            value : '',
            operatorOptions : operatorOptions
        });
        if(filterConditionItems.length >= filterItemsRangeCount.max) {
            target.setAttribute('disabled', 'disabled');
        }
        cmp.set('v.filterConditionItems', filterConditionItems);
    },

    removeItemHandler: function(cmp, event) {
        var
            filterConditionItems = cmp.get('v.filterConditionItems'),
            filterItemsRangeCount = cmp.get('v.filterItemsRangeCount'),
            target = event.srcElement || event.target;

        cmp.find('addRowBtn').getElement().removeAttribute('disabled');
        if(filterConditionItems.length > filterItemsRangeCount.min) {
            filterConditionItems.splice(filterConditionItems.length - 1, 1);
        }
        if(filterConditionItems.length <= filterItemsRangeCount.min) {
            //event.srcElement.setAttribute('disabled', 'disabled');
            target.setAttribute('disabled', 'disabled');
        }
        cmp.set('v.filterConditionItems', filterConditionItems);
    },

    populateValuesHandler: function(cmp, event, helper) {
        var
            filterConditionItems = cmp.get('v.filterConditionItems'),
            values = event.getParam("values"),
            index = event.getParam("index");

        filterConditionItems[index].value = values.join(', ');
        cmp.set('v.filterConditionItems', filterConditionItems);
    },

    validateHandler: function(cmp, event, helper) {
        try {
            if(helper.validateHeaderInfo(cmp)) return;
            helper.validateFilterConditionItems(cmp);
            helper.validateFilterLogicInput(cmp);
            helper.buildQueryAndValidate(cmp, helper);
        } catch(e) {
            helper.sendResult(cmp, JSON.parse(e.message));
        }
    },

    sendResult: function(cmp, result) {
        var filtersValidationEvent = cmp.getEvent("filtersValidationEvent");
        filtersValidationEvent.setParams({
            result: result
        });
        filtersValidationEvent.fire();
    },

    showSpinner: function(cmp) {
        var spinner = cmp.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function(cmp) {
        var spinner = cmp.find('spinner');
        $A.util.addClass(spinner, "slds-hide");
    },

    /*====================================================
    *                VALIDATION BLOCK
    *=====================================================*/
    genDefaultFilterLogic: function(cmp,conditionItems){
        var defFilterLogic = '';
        if(conditionItems){
            // build default filter logic
            for( var i=0, len = conditionItems.length; i< len; i++){
                if(i == 0){
                    defFilterLogic = defFilterLogic + (i+1);
                } else {
                    defFilterLogic = defFilterLogic +' AND '+ (i+1);
                }
            }
        }
        return defFilterLogic;
    },
    validateHeaderInfo: function(cmp) {
        var
            filterLogic = cmp.get('v.filterLogic'),
            filterLogicCmp = cmp.find('filterLogic'),
            isCustomFilterLogic = cmp.get('v.isCustomFilterLogic'),
            errorFields = [];

        if(isCustomFilterLogic && ($A.util.isUndefinedOrNull(filterLogic) || $A.util.isEmpty(filterLogic.trim()))) {
            filterLogicCmp.set("v.errors", [{ message: "Please, enter a value" }]);
            errorFields.push("Filter Logic");
        } else {
            filterLogicCmp.set("v.errors", null);
        }

        if(errorFields.length) {
            return true;
           throw new Error(JSON.stringify({
               success : false,
               message : "These required fields must be completed" + ': ' + errorFields.join(', ')
           }));
        }
        return false
    }, 

    validateFilterConditionItems: function(cmp) {
        var
            filterConditionItems = cmp.get('v.filterConditionItems'),
            lastConditionIndex = 0,
            firstEmptyLineIndex = 99;

        console.log('filterConditionItems', filterConditionItems);
        filterConditionItems.forEach(function(item, index) {
            if(item.field && !item.operator) {
                throw new Error("Required fields are missing: [Operation]");
            }
            if(item.field && item.operator) {
                lastConditionIndex = index;
            }
            if(!item.field && firstEmptyLineIndex > index) {
                firstEmptyLineIndex = index;
            }
        });
        if(firstEmptyLineIndex < lastConditionIndex) {
            throw new Error(JSON.stringify({
                success : false,
                message : "Error On Line {index}: You must enter a value".replace('{index}', firstEmptyLineIndex + 1)
            }));
        }
    },

    validateFilterLogicInput: function(cmp) {
        var
            filterLogic = cmp.get('v.filterLogic'),
            filterLogicPrefix = cmp.get('v.filterLogicPrefix'),
            filterLogicEnd = cmp.get('v.filterLogicEnd'),
            filterLogicCmp = cmp.find('filterLogic'),
            isCustomFilterLogic = cmp.get('v.isCustomFilterLogic'),
            filterConditionItems = cmp.get('v.filterConditionItems'),
            filterNumbersInLogic;

        if(!isCustomFilterLogic) return;

        var finalFilterLogic = filterLogic;
        if(filterLogic && filterLogicPrefix && filterLogicEnd) {
            finalFilterLogic = filterLogicPrefix + finalFilterLogic + filterLogicEnd;
        }

        filterNumbersInLogic = finalFilterLogic.match(/\d+/g) || [];
        console.log('filterNumbersInLogic', filterNumbersInLogic);

        filterNumbersInLogic.forEach(function(number) {
            if(!filterConditionItems[number-1] || !filterConditionItems[number-1].field || !filterConditionItems[number-1].operator) {
                throw new Error(JSON.stringify({
                    success : false,
                    message : "The filter logic references an undefined filter: {index}.".replace('{index}', number)
                }));
            }
        });
        filterConditionItems.forEach(function(rule, index) {
            if(rule.field && rule.operator && filterNumbersInLogic.indexOf(index+1+"") == -1) {
                throw new Error(JSON.stringify({
                    success : false,
                    message : "Some filter conditions are defined but not referenced in your filter logic."
                }));
            }
        });
    },

    buildQueryAndValidate: function(cmp, helper) {
        var
            sObjectName = cmp.get('v.sObjectName'),
            filterLogic = cmp.get('v.filterLogic'),
            filterLogicPrefix = cmp.get('v.filterLogicPrefix'),
            filterLogicEnd = cmp.get('v.filterLogicEnd'),
            validateFilterItems = cmp.get('c.validateFilterItems'),
            filterConditionItems = cmp.get('v.filterConditionItems'),
            isCustomFilterLogic = cmp.get('v.isCustomFilterLogic'),
            ruleItemsToValidate = [];

        filterConditionItems.forEach(function(item) {
            if(item.field && item.operator) {
                ruleItemsToValidate.push({
                    field: item.field,
                    operator: item.operator,
                    value: item.value
                });
            }
        });

        console.log('ruleItemsToValidate', ruleItemsToValidate);

        /* Edited logic how
         * custom filter logic is saved
         *
         * @edit: PZ - 10.01.18
         */
        /*
        var finalFilterLogic = filterLogic;
        if(filterLogicPrefix && filterLogicEnd) {
            finalFilterLogic = filterLogicPrefix + finalFilterLogic + filterLogicEnd;
        }
		*/

        var finalFilterLogic = '';
        if(isCustomFilterLogic){
            // custom filter logic, append prefix and suffix
            if(!$A.util.isEmpty(filterLogic)){
                finalFilterLogic = filterLogic;
                // remove duplicate spaces, leading and trailing spaces
                finalFilterLogic.replace(/\s+/g,' ').trim();
            }

        } else {
            // default filter logic with simple AND conditions
            finalFilterLogic = helper.genDefaultFilterLogic(cmp,ruleItemsToValidate);
        }
        if(filterLogicPrefix && filterLogicEnd) {
            finalFilterLogic = filterLogicPrefix + finalFilterLogic + filterLogicEnd;
        }

        validateFilterItems.setParams({
            "sObjectName": sObjectName,
            "filterLogic": finalFilterLogic,
            "filtersInfo": JSON.stringify(ruleItemsToValidate)
        });
        validateFilterItems.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS") {
                var response = JSON.parse(response.getReturnValue());
                helper.sendResult(cmp, response);
            }
        });
        $A.enqueueAction(validateFilterItems);
    }
    /*====================================================
    *                END OF VALIDATION BLOCK
    *=====================================================*/
});