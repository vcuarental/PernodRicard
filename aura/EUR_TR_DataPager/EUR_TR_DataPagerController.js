/**
 * Created by bsavcı on 8/27/2020.
 */

({
    doInit: function (component, event, helper) {
        component.set("v.filterObject", {
            filterModalOpen: false,
            pageSize: 5,
            childFilterObjects: [],
            //a childFilterObject structure
            // {
            //     fields: [
            //     {
            //         label: "",
            //         objectName: "",
            //         references: [""],
            //         type: "",
            //         value: "",
            //         showInTable: false
            //     },
            // ],
            //     field: "",
            //     type: "",
            //     label: ""
            //     value: if type is PICKLIST then [] else ""
            // }
            appliedFilters: [],
            searchTerm: ''
        });

        $A.enqueueAction(component.get("c.columnsChanged"));

        component.set("v.fieldsObject", {
            fieldLabel: '',
            fieldName: '',
            type: '',
            showInTable: false
        });
        $A.enqueueAction(component.get("c.handleGetAllFields"));
    },
    handleSaveInternal: function (component, event, helper) {
        let onSaveEvent = component.getEvent('onsave');
        let draftValues = event.getParam('draftValues');
        onSaveEvent.setParam('draftValues', draftValues);
        onSaveEvent.fire();
    },
    handlePageSizeChange: function (component, event, helper) {
        component.set("v.filterObject.pageSize", event.getParam("value"));
        component.set("v.currentPage", 1);
        component.set("v.prePages", []);
        component.set("v.pages", []);
        helper.reloadData(component);
    },
    reloadData: function (component, event, helper) {
        helper.reloadData(component, true);
    },
    columnsChanged: function (component, event, helper) {
        let columns = component.get("v.columns");
        if ($A.util.isEmpty(columns)) {
            component.set("v.internalColumns", []);
            return;
        }
        columns = JSON.parse(JSON.stringify(columns));
        for (const column of columns) {
            if (column.type === "action" || (!$A.util.isEmpty(column.filterable) && column.filterable === false)) {
                continue;
            }
            let fieldName = helper.getColumnFieldName(column);
            if (fieldName.indexOf(".") > -1) {
                const parts = fieldName.split(".");
                fieldName = parts.join("_");
                if (column.type === "url") {
                    parts.splice(parts.length - 1, 1);
                    parts.push("Id");
                    const urlLinkField = parts.join("_");
                    column.fieldName = urlLinkField;
                }
            }
            helper.setColumnFieldName(column, fieldName);
        }
        component.set("v.internalColumns", columns);
        $A.enqueueAction(component.get("c.reloadData"));
    },
    gotoPage: function (component, event, helper) {
        const index = event.target.id;
        const pages = component.get("v.pages");
        const item = pages[index];
        const currentPage = component.get("v.currentPage");
        if (currentPage === item.Index)
            return;
        component.set("v.currentPage", item.Index);
        helper.reloadData(component);
    },
    handleRowAction: function (component, event, helper) {
        const action = event.getParam('action');
        const row = event.getParam('row');
        let onRowActionEvent = component.getEvent('onrowaction');
        onRowActionEvent.setParam('row', row);
        onRowActionEvent.setParam('action', action);
        onRowActionEvent.fire();
    },
    handleRowSelection: function (component, event, helper) {
        const selectedRows = event.getParam('selectedRows');
        if (component.get('v.enableSingleSelect')) {
            const table = component.find("dataPagerTable");
            if (selectedRows.length === 1) {
                component.set("v.oldSelectedRow", selectedRows[0]);
                component.set('v.selectedRows', selectedRows);
            } else if (selectedRows.length === 2 && component.get('v.data').length !== 2) {
                const original = component.get("v.oldSelectedRow");
                for (let i = 0; i < selectedRows.length; i++) {
                    if (original.Id !== selectedRows[i].Id) {
                        const row = [];
                        row.push(selectedRows[i]);
                        const rowId = [];
                        rowId.push(selectedRows[i].Id);

                        table.set("v.selectedRows", rowId);
                        component.set("v.oldSelectedRow", selectedRows[i]);
                        component.set('v.selectedRows', row);
                    }
                }
            } else {
                table.set("v.selectedRows", []);
                component.set('v.selectedRows', []);
            }
        } else {
            component.set('v.selectedRows', selectedRows);
        }
    },
    doSearch: function (component, event, helper) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            helper.reloadDataWithoutState(component);
        }
    },

    //filterModal
    toggleFilterModal: function (component, event, helper) {
        component.set('v.filterObject.filterModalOpen', !component.get('v.filterObject.filterModalOpen'));
    },
    handleFilterFieldChanged: function (component, event, helper) {
        const level = parseInt(event.getSource().get('v.name').split('-')[1]);
        let childFilterObjects = component.get("v.filterObject.childFilterObjects");
        const filterObject = childFilterObjects[level - 1];//level is one-based indexing
        const fields = filterObject.fields;
        const filter = fields.find(x => x.value === filterObject.field);
        if (!filter) return;

        const utility = component.find("utility");
        if (filter.type === 'REFERENCE') {
            component.set("v.loading", true);

            utility.callAction(component, 'c.getAllFieldsOfLookup', {
                referenceObjectNames: filter.references,
                isNamePointing: filter.isNamePointing
            }).then(function (results) {
                childFilterObjects[childFilterObjects.length - 1] = filterObject;
                childFilterObjects.push({"fields": results});
                component.set("v.filterObject.childFilterObjects", childFilterObjects);
                component.set("v.loading", false);
            }, function (error) {
                component.set("v.loading", false);
                if (error && error.message) {
                    utility.showErrorToast("Hata!", error.message, 2000);
                } else {
                    utility.showErrorToast("Hata!", 'Bilinmeyen Hata', 2000);
                }
            });
        }
        if (level !== childFilterObjects.length) { //if selected filter line is the last one then prevent slice all childFilterObjects array
            childFilterObjects = childFilterObjects.slice(0, (level) - childFilterObjects.length);
            component.set("v.filterObject.childFilterObjects", childFilterObjects);
        }

        if (filter.type === "PICKLIST") {
            component.set("v.loading", true);
            if ($A.util.isEmpty(filter.objectName)) return;
            utility.callAction(component, 'c.getFieldOptions', {
                    objName: filter.objectName,
                    fieldName: filter.value
                }
            ).then(function (results) {
                filterObject.operator = "IN";
                filterObject.value = "";
                filterObject.operations = component.get("v.picklistOperations");
                filterObject.type = filter.type;
                filterObject.label = filter.label;
                filterObject.options = results;
                childFilterObjects[childFilterObjects.length - 1] = filterObject;
                component.set('v.filterObject.childFilterObjects', childFilterObjects);

                component.set("v.loading", false);
            }, function (error) {
                component.set("v.loading", false);
                if (error && error.message) {
                    utility.showErrorToast("Hata!", error.message, 2000);
                } else {
                    utility.showErrorToast("Hata!", 'Bilinmeyen Hata', 2000);
                }
            });
        } else {
            let operator;
            let value;
            let operations;
            if (helper.isStringTypeColumn(filter.type)) {
                operator = "like";
                value = "";
                operations = component.get("v.textOperations");
            } else if (filter.type === "number" || filter.type === 'DOUBLE' || filter.type === 'CURRENCY') {
                operator = "=";
                value = "0";
                operations = component.get("v.numberOperations");
            } else if (filter.type.toUpperCase() === "BOOLEAN") {
                operator = "=";
                value = "true";
                operations = component.get("v.booleanOperations");
            } else if (filter.type === "DATE" || filter.type === "DATETIME") {
                operator = "=";
                value = "";
                operations = component.get("v.numberOperations");
            }

            //To avoid error when changing dualListBox
            window.setTimeout($A.getCallback(function () {
                filterObject.value = value;
                childFilterObjects[childFilterObjects.length - 1] = filterObject;
                component.set("v.filterObject.childFilterObjects", childFilterObjects);
            }), 1);

            filterObject.operator = operator;
            filterObject.operations = operations;
            filterObject.type = filter.type;
            filterObject.label = filter.label;
            childFilterObjects[childFilterObjects.length - 1] = filterObject;
            component.set("v.filterObject.childFilterObjects", childFilterObjects);
        }
    },
    applyFilter: function (component, event, helper) {
        const filterObject = component.get("v.filterObject");

        const childFilterObjects = component.get("v.filterObject.childFilterObjects");
        const childFilterObject = childFilterObjects[childFilterObjects.length - 1];
        if (!childFilterObject.hasOwnProperty('field'))
            return;

        const allOperations = component.get("v.textOperations")
            .concat(component.get("v.booleanOperations"))
            .concat(component.get("v.numberOperations"))
            .concat(component.get("v.picklistOperations"));

        const currentOperation = allOperations.find(x => x.value === childFilterObject.operator);
        let valueLabel = childFilterObject.value;
        if (helper.isStringTypeColumn(childFilterObject.type) && $A.util.isEmpty(childFilterObject.value)) {
            return;
        } else if (childFilterObject.type === "boolean") {
            const booleanValues = component.get("v.booleanValues");
            const boolValueItem = booleanValues.find(x => x.value === childFilterObject.value);
            valueLabel = boolValueItem.label;
        }

        if (childFilterObject.type === "PICKLIST" && Array.isArray(childFilterObject.value)) {
            //Convert array to object by value field as key
            const options = childFilterObject.options.reduce((obj, item) => {
                obj[item['value']] = item;
                return obj
            }, {});

            childFilterObject.value.forEach((value) => filterObject.appliedFilters.push({
                field: helper.relateFilterFields(childFilterObjects),
                fieldLabel: helper.relateFilterLabels(childFilterObjects),
                operator: childFilterObject.operator,
                operatorLabel: currentOperation.label,
                value: value,
                valueLabel: options[value].label,
                type: childFilterObject.type
            }))
        } else {
            filterObject.appliedFilters.push({
                field: helper.relateFilterFields(childFilterObjects),
                fieldLabel: helper.relateFilterLabels(childFilterObjects),
                operator: childFilterObject.operator,
                operatorLabel: currentOperation.label,
                value: childFilterObject.value,
                valueLabel: valueLabel,
                type: childFilterObject.type
            });
        }
        component.set("v.filterObject.appliedFilters", filterObject.appliedFilters);
        helper.reloadDataWithoutState(component);
    },
    removeAllFilters: function (component, event, helper) {
        component.set("v.filterObject.appliedFilters", []);
        helper.reloadDataWithoutState(component);
    },
    removeFilterItem: function (component, event, helper) {
        const index = event.getSource().get("v.name");
        const appliedFilters = component.get("v.filterObject.appliedFilters");
        appliedFilters.splice(index, 1);
        component.set("v.filterObject.appliedFilters", appliedFilters);
        helper.reloadDataWithoutState(component);
    },

    //fieldModal
    toggleFieldPanel: function (component, event, helper) {
        component.set("v.fieldModalOpen", !component.get("v.fieldModalOpen"));
        component.find("searchKey").set("v.value", "");
        $A.enqueueAction(component.get("c.searchKeyChange"));
    },
    handleSelectedFieldsChange: function (component, event, helper) {
        // This will contain an array of the "value" attribute of the selected options
        const values = event.getParam("value");
        const options = event.getSource().get("v.options");
        const lookupOptions = options.filter(option => !$A.util.isEmpty(option.references) && values.includes(option.value));

        if (!$A.util.isEmpty(lookupOptions)) {
            component.set('v.lookupModalOpen', true);
            const utility = component.find("utility");
            component.set("v.loading", true);

            const alreadyExistFields = options.reduce((alreadyExistFields, option) => {
                if (option.value.includes('.')) {  //This will work for only one level lookup
                    const objectAndFields = option.value.split('.');
                    const object = objectAndFields[0];
                    const field = objectAndFields[1];
                    alreadyExistFields.hasOwnProperty(object) ? alreadyExistFields[object].push(field) : alreadyExistFields[object] = [field];
                }
                return alreadyExistFields;
            }, {});

            const getAllFieldsOfLookupPromises = lookupOptions.map(lookupOption => {
                return utility.callAction(component, 'c.getAllFieldsOfLookup', {
                    referenceObjectNames: lookupOption.references,
                    isNamePointing: lookupOption.isNamePointing
                });
            });

            Promise.all(getAllFieldsOfLookupPromises).then(function (results) {
                const selectedLookups = results.map((fields, i) => {
                    return {
                        "fields": fields.reduce((filteredFields, field) => {
                            const lookupField = lookupOptions[i].value.replace(/id/ig, '').replace('__c', '__r');
                            if (field.type !== 'REFERENCE' && //Just for one level lookup
                                (!alreadyExistFields.hasOwnProperty(lookupField) || !alreadyExistFields[lookupField].includes(field.value))) {
                                filteredFields.push(field);
                            }
                            return filteredFields;
                        }, []),
                        "label": lookupOptions[i].label,
                        "value": lookupOptions[i].value,
                        "type": lookupOptions[i].type
                    }
                });
                component.set('v.selectedLookups', selectedLookups);
                component.set("v.loading", false);
            }, function (error) {
                component.set("v.loading", false);
                if (error && error.message) {
                    utility.showErrorToast("Hata!", error.message, 2000);
                } else {
                    utility.showErrorToast("Hata!", 'Bilinmeyen Hata', 2000);
                }
            });
        } else {
            helper.setSelectedFields(component);
        }
    },
    searchKeyChange: function (component, event, helper) {
        const searchKey = component.find("searchKey").get("v.value");
        const selectedFields = component.get('v.selectedFields');
        component.set('v.filteredFields', component.get('v.fieldsObject').filter(x => x.label.toLowerCase().includes(searchKey.toLowerCase()) || selectedFields.includes(x.value)));
    },
    handleGetAllFields: function (component, event, helper) {
        component.set("v.fieldModalLoading", true);
        const utility = component.find("utility");
        utility.callAction(component, 'c.getAllFields', {
                objName: component.get("v.objectName")
            }
        ).then($A.getCallback(function (results) {
            let columns = component.get("v.columns");

            //concat SObject fields with predefined lookup fields by parent component
            const fieldsWithLookups = columns.reduce((lookupFields, column) => {
                if (column.lookup) lookupFields.push({label: column.label, type: column.type, value: column.typeAttributes.label.fieldName});
                return lookupFields;
            }, []).concat(results);

            component.set("v.filteredFields", fieldsWithLookups);
            component.set("v.filterObject.childFilterObjects", [{"fields": fieldsWithLookups}]);

            const selectedFields = fieldsWithLookups.reduce((selectedFields, field) => {
                field.showInTable = !$A.util.isEmpty(columns.find(column => column.typeAttributes.label.fieldName === field.value));
                selectedFields.push(field);
                return selectedFields;
            }, []);
            component.set("v.selectedFields", selectedFields.reduce((fieldsToShowInTable, selectedField) => {
                if (selectedField.showInTable)
                    fieldsToShowInTable.push(selectedField.value);
                return fieldsToShowInTable;
            }, []));
            component.set("v.fieldsObject", selectedFields);

            component.set("v.fieldModalLoading", false);
        })), function (error) {
            component.set("v.fieldModalLoading", false);
            if (error && error.message) {
                utility.showErrorToast("Hata!", error.message, 2000);
            } else {
                utility.showErrorToast("Hata!", 'Bilinmeyen Hata', 2000);
            }
        };
    },

    //lookupModal
    toggleLookupModal: function (component, event, helper) {
        helper.setFieldDualListBoxValues(component);
        component.set("v.lookupModalOpen", !component.get("v.lookupModalOpen"));
    },
    addLookupField: function (component, event, helper) {
        const values = component.get('v.selectedFields');
        const selectedLookups = component.get('v.selectedLookups').filter(x => x.hasOwnProperty('field'));
        const fieldsObject = component.get("v.fieldsObject");

        selectedLookups.forEach((option) => {
            const value = `${option.value.replace(/id/ig, '').replace('__c', '__r')}.${option.field}`;

            values[values.indexOf(option.value)] = value;
            const field = option.fields.find(x => x.value === option.field);
            fieldsObject.push({
                label: `${option.label}${field.label}`,
                value: value,
                type: field.type,
                showInTable: true
            });
        });

        component.set('v.selectedFields', values);
        component.set('v.filteredFields', fieldsObject);
        component.set('v.fieldsObject', fieldsObject);
        helper.setFieldDualListBoxValues(component);
        helper.setSelectedFields(component);
        component.set('v.lookupModalOpen', false);
    },

    //aura methods
    getSelectedRows: function (component, event, helper) {
        return component.get('v.selectedRows');
    },

    getDataQuery: function (component, event, helper) {
        return component.get('v.dataQuery');
    },

    getTotalDataCount: function (component, event, helper) {
        return component.get('v.totalDataCount');
    },
});