/**
 * Created by osman on 18.12.2020.
 */

({
    doInit: function (component, event, helper) {

        component.set("v.filter", {});
        component.set("v.isLoading", true);
        const utility = component.find("utility");
        const p0 = utility.callAction(component, 'c.getFilters', null);
        Promise.all([p0]).then(data => {
            component.set("v.filterDefinitions", data[0]);
            const filterOptions = data[0].map((item) => {
                return {
                    label: item.label,
                    value: item.value,
                    fieldType: item.fieldType
                }
            });
            component.set("v.filter.fieldOptions", filterOptions);
            component.set("v.filter.field", filterOptions[0].value);
            component.set("v.filter.fieldType", filterOptions[0].fieldType);

            helper.setOperatorOptions(component, event, helper);
            component.set("v.isLoading", false);

        }).catch(error => {
            const errorMessage = (error && error.message) ? error.message : 'Bilinmeyen Hata';
            utility.showErrorToast('Hata!', errorMessage);
            component.set("v.isLoading", false);
        })
    },

    addUserFilter: function (component, event, helper) {
        const newFilter = Object.assign({}, component.get("v.filter"));
        const appliedFilters = component.get("v.appliedFilters");
        const filterDefinitions = component.get("v.filterDefinitions");
        const filterDefinition = filterDefinitions.find((item) => {
            return item.value === newFilter.field
        });
        newFilter.fieldLabel = filterDefinition.label;
        if (Array.isArray(newFilter.value)) {
            const picklistOptions = filterDefinition.picklistOptions;
            const selectedPicklistOptionAPINames = [...newFilter.value];
            const selectedPicklistOptionLabelNames = [];
            selectedPicklistOptionAPINames.forEach(selectedOptionAPIName => {
                let selectedOption = picklistOptions.find(option => {
                    return option.value === selectedOptionAPIName;
                })
                selectedPicklistOptionLabelNames.push(selectedOption.label);
            });
            newFilter.values = [...selectedPicklistOptionLabelNames].join(',');
            newFilter.operator = 'Eşit';
        } else {
            newFilter.values = newFilter.value;
        }
        if (!newFilter.values) {
            return;
        }
        if (newFilter.values === '') {
            return;
        }
        helper.removeSameCriteriaFilter(component, newFilter);
        newFilter.isUserField = filterDefinition.isUserField;

        if (newFilter.isUserField) {
            helper.addUserFieldQuery(component, event, helper, newFilter);
        } else {
            helper.addUserRelationalFieldQuery(component, event, helper, newFilter);
        }


    },

    handleUserFilterFieldSelect: function (component, event, helper) {

        const selectedField = component.get("v.filter.field");
        const filterDefinitions = component.get("v.filterDefinitions");
        const selectedFieldModel = [...filterDefinitions].find(item => {
            return item.value === selectedField
        });
        component.set("v.filter.fieldType", selectedFieldModel.fieldType);
        if (selectedFieldModel.fieldType === 'PICKLIST') {
            component.set("v.isOperatorVisible", false);
            const picklistValueOptions = [...selectedFieldModel.picklistOptions];
            component.set("v.filter.fieldType", "PICKLIST");
            component.set("v.filter.value", []);
            component.set("v.filter.picklistValueOptions", picklistValueOptions);
        } else {
            component.set("v.filter.fieldType", selectedFieldModel.fieldType);
            component.set("v.isOperatorVisible", true);
        }
        helper.setOperatorOptions(component, event, helper);


    },

    toggleUserFilterDialog: function (component, event, helper) {
        component.set("v.isUserFilterDialogOpen", !component.get("v.isUserFilterDialogOpen"));
    },

    removeAllFilters: function (component, event, helper) {
        component.set("v.appliedFilters", []);
        helper.sendQueryEvent(component, event, helper);
    },

    reloadData: function (component, event, helper) {
        helper.sendQueryEvent(component, event, helper);
    },

    removeFilterItem: function (component, event, helper) {
        const index = event.getSource().get("v.name");
        const appliedFilters = component.get("v.appliedFilters");
        appliedFilters.splice(index, 1);
        component.set("v.appliedFilters", appliedFilters);
        helper.sendQueryEvent(component, event, helper);
    }


});