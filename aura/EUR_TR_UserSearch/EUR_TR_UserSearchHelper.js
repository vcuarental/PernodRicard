/**
 * Created by osman on 18.12.2020.
 */

({
    setOperatorOptions: function (component, event, helper) {
        let operatorOptions = [];
        const selectedFieldType = component.get("v.filter.fieldType");
        if (selectedFieldType === "STRING") {
            operatorOptions = [
                {label: "Benzer", value: "Benzer"},
                {label: "Farklı", value: "Farklı"},
                {label: "Eşit", value: "Eşit"}
            ];
        } else if (selectedFieldType === "NUMBER") {
            operatorOptions = [
                {label: "Eşit", value: "Eşit"},
                {label: "Büyük", value: "Büyük"},
                {label: "Küçük", value: "Küçük"},
                {label: "Büyük", value: "Büyük"},
                {label: "Büyük Eşit", value: "Büyük Eşit"},
                {label: "Küçük", value: "Küçük"},
                {label: "Küçük Eşit", value: "Küçük Eşit"},
            ];
        } else if (selectedFieldType === "PICKLIST") {

        }
        component.set("v.filter.operatorOptions", operatorOptions);
        if (operatorOptions.length > 0) {
            component.set("v.filter.operator", operatorOptions[0].value);
        }

    },

    setUserFieldQuery: function (component, event, helper, filter) {
        let query = '';
        if (filter.fieldType === "PICKLIST" && filter.isUserField) {
            const selectedPicklistItems = filter.value;
            let queryPicklistItems = "(";
            selectedPicklistItems.forEach(item => {
                if (queryPicklistItems.length > 1) {
                    queryPicklistItems += ",";
                }
                queryPicklistItems += `'${item}'`;
            })
            queryPicklistItems += ") ";

            query += `${filter.field} IN ${queryPicklistItems} `;

        } else if (filter.fieldType === "STRING") {
            if (filter.operator === "Benzer") {
                query += ` ${filter.field} LIKE '%${filter.value}%' `;
            } else if (filter.operator === "Farklı") {
                query += ` ${filter.field}!='${filter.value}' `;
            } else if (filter.operator === "Eşit") {
                query += ` ${filter.field}='${filter.value}' `;
            }
        } else if (filter.fieldType === "BOOLEAN") {
            // TODO
        }
        filter.query = query;
        console.log("query : ", query);
    },

    sendQueryEvent: function (component, event, helper) {
        const appliedFilters = component.get("v.appliedFilters");

        let queryList = appliedFilters.reduce((queryList, filter) => {
            queryList.push(filter.query);
            return queryList;
        }, []);

        let query = '';
        if (queryList && Array.isArray(queryList) && queryList.length > 0) {
            let mergedQuery = '';
            queryList.forEach(queryItem => {
                mergedQuery += `AND ${queryItem} `;
            });
            query = mergedQuery;
        } else {
            query = '';
        }
        const surveySearchUserFilterQueryEvent = component.getEvent("surveySearchUserFilterQueryEvent");
        surveySearchUserFilterQueryEvent.setParams({
            "filterQuery": query
        });
        surveySearchUserFilterQueryEvent.fire();
    },

    addUserFieldQuery: function (component, event, helper, newFilter) {
        helper.setUserFieldQuery(component, event, helper, newFilter);
        const appliedFilters = component.get("v.appliedFilters");
        appliedFilters.push(newFilter);
        component.set("v.appliedFilters", appliedFilters);
        this.sendQueryEvent(component, event, helper);
    },

    addUserRelationalFieldQuery: function (component, event, helper, newFilter) {

        const utility = component.find("utility");
        const appliedFilters = component.get("v.appliedFilters");
        component.set("v.isLoading", true);

        const promises = [];
        if (newFilter.field === 'EUR_TR_CityName__c' || newFilter.field === "EUR_TR_Channel__c") {

            const userQueryFilterRequestByOwner = {
                fieldName: newFilter.field,
                selectedOptions: [...newFilter.value],
                queryReference: "byOwner"
            };
            const p0 = utility.callAction(component, 'c.getUsersByQueryFilter', {"userQueryFilterRequest": userQueryFilterRequestByOwner});
            promises.push(p0);

            const userQueryFilterRequestBySalesChief = {
                fieldName: newFilter.field,
                selectedOptions: [...newFilter.value],
                queryReference: "bySalesChief"
            };
            const p1 = utility.callAction(component, 'c.getUsersByQueryFilter', {"userQueryFilterRequest": userQueryFilterRequestBySalesChief});
            promises.push(p1);

        } else {

            const userQueryFilterRequest = {
                fieldName: newFilter.field,
                selectedOptions: [...newFilter.value],
                queryReference: ""
            };
            const p0 = utility.callAction(component, 'c.getUsersByQueryFilter', {"userQueryFilterRequest": userQueryFilterRequest});
            promises.push(p0);

        }

        Promise.all(promises).then(data => {
            let userIds = [];
            if (data.length === 2) {
                const userIdsByOwnerId = data[0];
                const userIdsBySalesChief = data[1];
                userIds = [...userIdsByOwnerId, ...userIdsBySalesChief];
            } else {
                userIds = [...data[0]];
            }
            return utility.callAction(component, 'c.generateQueryByUserIds', {"userIds": userIds});
        }).then(generatedQuery => {
            newFilter.query = generatedQuery;
            appliedFilters.push(newFilter);
            component.set("v.appliedFilters", appliedFilters);
            this.sendQueryEvent(component, event, helper);
            component.set("v.isLoading", false);
        }).catch(error => {
            const errorMessage = (error && error.message) ? error.message : 'Bilinmeyen Hata';
            utility.showErrorToast('Hata!', errorMessage);
            component.set("v.isLoading", false);
        });


    },

    removeSameCriteriaFilter: function (component, newFilter) {
        const appliedFilters = component.get("v.appliedFilters");
        const foundIndex = appliedFilters.findIndex(item => {
            return item.field === newFilter.field;
        });
        if (foundIndex !== -1) {
            appliedFilters.splice(foundIndex, 1);
            component.set("v.appliedFilters", appliedFilters);
        }
    }

});