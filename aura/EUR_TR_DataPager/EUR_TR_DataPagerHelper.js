/**
 * Created by bsavcı on 8/27/2020.
 */

({
    reloadData: function (component, forceToReload) {
        if (!forceToReload)
            forceToReload = false;
        let loadingEnabled = component.get("v.loadingEnabled");
        if (loadingEnabled === false) {
            return;
        }
        const helper = this;
        const objectName = component.get("v.objectName");
        if ($A.util.isEmpty(objectName))
            return;
        const filter = this.getQueryFilter(component);
        const filterObject = component.get("v.filterObject");
        const columns = component.get("v.columns");
        if ($A.util.isEmpty(columns))
            return;
        component.set("v.loading", true);
        const fields = columns.filter(x => x.type !== "action").map(x => helper.getColumnFieldName(x));
        const pagerCount = 10;
        let pagerStartIndex = 1;
        let pagerStartId = null;
        let selectedPageFirstId = null;
        let pages = component.get("v.pages");
        const prePages = component.get("v.prePages");
        let gotoPageItem = undefined;
        if (pages) {
            if (prePages && Array.isArray(pages) && Array.isArray(prePages)) {
                pages = pages.concat(prePages);
            }
            let currentPage = component.get("v.currentPage");
            gotoPageItem = pages.find(x => x.Index === currentPage);
            if (gotoPageItem && forceToReload === false) {
                selectedPageFirstId = gotoPageItem.Id;
                const totalDataCount = component.get("v.totalDataCount");
                if (totalDataCount) { //not first load
                    const pagination = helper.paginate(totalDataCount, gotoPageItem.Index, filterObject.pageSize, pagerCount);
                    const item = pages.find(x => x.Index === pagination.startPage);
                    if (item) {
                        pagerStartIndex = item.Index;
                        pagerStartId = item.Id;
                    }
                }
            }
        }
        const utility = component.find("utility");
        utility.callAction(component, "c.query", {
            request: {
                objectName: objectName,
                filter: filter,
                fields: fields,
                pageSize: filterObject.pageSize,
                pagerCount: pagerCount,
                pagerStartIndex: pagerStartIndex,
                pagerStartId: pagerStartId,
                selectedPageFirstId: selectedPageFirstId
            }
        }).then(function (response) {
            const data = helper.prepareDataForDataTable(component, response.data);
            component.set("v.data", data);
            component.set("v.pages", response.pageMap);
            component.set("v.prePages", component.get("v.pages"));
            component.set("v.totalDataCount", response.total);
            component.set("v.displayingDataCount", data.length);
            component.set("v.dataQuery", response.queryString);
            let currentPage = 1;
            if (gotoPageItem !== undefined) {
                currentPage = gotoPageItem.Index;
            }
            component.set("v.currentPage", currentPage);
            component.set("v.loading", false);
        }, function (error) {
            component.set("v.loading", false);
            utility.showErrorToast("Data Pager Veri Yükleme Hatası", `Lütfen sayfayı yenileyiniz. Eğer hata devam ederse sistem yöneticinizle görüşünüz. ${error}`, 15000);
        });
    },
    prepareDataForDataTable: function (component, data) {
        const columns = component.get("v.columns");
        for (const item of data) {
            for (const column of columns) {
                if (column.type === "action") {
                    continue;
                }
                const fieldName = this.getColumnFieldName(column);
                if (fieldName.indexOf(".") > -1) {
                    const parts = fieldName.split(".");
                    let current = this.getNestedPropValue(item, parts);
                    item[parts.join("_")] = current;
                    if (column.type === "url") {
                        parts.splice(parts.length - 1, 1);
                        parts.push("Id");
                        current = this.getNestedPropValue(item, parts);
                        const urlLinkField = parts.join("_");
                        item[urlLinkField] = '/' + current;
                    }
                } else if (column.type === "url") {
                    item.__RecordLink = '/' + item.Id;
                }
            }
        }
        return data;
    },
    getNestedPropValue: function (item, parts) {
        let current = item;
        for (const part of parts) {
            if (typeof current == 'undefined' || !current.hasOwnProperty(part)) {
                current = undefined;
                break;
            } else {
                current = current[part];
            }
        }
        return current;
    },
    getColumnFieldName: function (column) {
        if (column.type === "url") {
            return column.typeAttributes.label.fieldName;
        } else {
            return column.fieldName;
        }
    },
    setColumnFieldName: function (column, fieldName) {
        if (column.type === "url") {
            column.typeAttributes.label.fieldName = fieldName;
        } else {
            column.fieldName = fieldName;
        }
    },

    paginate: function (totalItems, currentPage, pageSize, maxPages) {
        // calculate total pages
        let totalPages = Math.ceil(totalItems / pageSize);

        // ensure current page isn't out of range
        if (currentPage < 1) {
            currentPage = 1;
        } else if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        let startPage, endPage;
        if (totalPages <= maxPages) {
            // total pages less than max so show all pages
            startPage = 1;
            endPage = totalPages;
        } else {
            // total pages more than max so calculate start and end pages
            let maxPagesBeforeCurrentPage = Math.floor(maxPages / 2);
            let maxPagesAfterCurrentPage = Math.ceil(maxPages / 2) - 1;
            if (currentPage <= maxPagesBeforeCurrentPage) {
                // current page near the start
                startPage = 1;
                endPage = maxPages;
            } else if (currentPage + maxPagesAfterCurrentPage >= totalPages) {
                // current page near the end
                startPage = totalPages - maxPages + 1;
                endPage = totalPages;
            } else {
                // current page somewhere in the middle
                startPage = currentPage - maxPagesBeforeCurrentPage;
                endPage = currentPage + maxPagesAfterCurrentPage;
            }
        }

        // calculate start and end item indexes
        let startIndex = (currentPage - 1) * pageSize;
        let endIndex = Math.min(startIndex + pageSize - 1, totalItems - 1);

        // create an array of pages to ng-repeat in the pager control
        let pages = Array.from(Array((endPage + 1) - startPage).keys()).map(i => startPage + i);

        // return object with all pager properties required by the view
        return {
            totalItems: totalItems,
            currentPage: currentPage,
            pageSize: pageSize,
            totalPages: totalPages,
            startPage: startPage,
            endPage: endPage,
            startIndex: startIndex,
            endIndex: endIndex,
            pages: pages
        };
    },

    getQueryFilter: function (component) {
        let filter = $A.util.isUndefined(component.get("v.filter")) ? "" : component.get("v.filter");
        const filterObject = component.get("v.filterObject");
        if (!$A.util.isEmpty(filterObject.searchTerm)) {
            const columns = component.get("v.columns");
            if (!$A.util.isEmpty(columns)) {
                const searchTermFilters = [];
                for (const column of columns) {
                    if (this.isStringTypeColumn(column.type)) {
                        if (!$A.util.isEmpty(column.filterable) && column.filterable === false) {
                            continue;
                        }
                        let field = this.getColumnFieldName(column);
                        let searchTermFilter = this.getStringQueryParameter('like', filterObject.searchTerm, field);
                        searchTermFilters.push(searchTermFilter);
                    }
                }
                if (searchTermFilters.length > 0) {
                    let condition = " ( " + searchTermFilters.join(" or ") + " ) ";
                    filter = this.appendFilter(filter, condition);
                }
            }
        }
        if (filterObject.appliedFilters) {
            let condition;
            const groupedPicklist = this.groupBy(filterObject.appliedFilters.filter(x => x.type === "PICKLIST"), 'field');
            if (!$A.util.isEmpty(groupedPicklist)) {
                Object.keys(groupedPicklist).forEach(key => {
                    condition = this.getPicklistQueryParameter(groupedPicklist[key][0].operator, groupedPicklist[key].map(x => x.value), key);
                    filter = this.appendFilter(filter, condition);
                });
            }
            for (const appliedFilter of filterObject.appliedFilters.filter(x => x.type !== 'PICKLIST')) {
                if (this.isStringTypeColumn(appliedFilter.type)) {
                    condition = this.getStringQueryParameter(appliedFilter.operator, appliedFilter.value, appliedFilter.field);
                } else if (appliedFilter.type === "number") {
                    condition = this.getNumberQueryParameter(appliedFilter.operator, appliedFilter.value, appliedFilter.field);
                } else if (appliedFilter.type === "action") {
                    condition = '';
                } else {
                    condition = this.getNonStringQueryParameter(appliedFilter.operator, appliedFilter.value, appliedFilter.field);
                }
                filter = this.appendFilter(filter, condition);
            }
        }
        return filter;
    },
    isStringTypeColumn: function (type) {
        return ["text", "url", "STRING"].indexOf(type) > -1;
    },
    appendFilter: function (filter, condition) {
        if (!$A.util.isEmpty(filter) && filter.trim().length > 0 && !$A.util.isEmpty(condition)) {
            filter += " and ";
        }
        filter += condition;
        return filter;
    },
    getStringQueryParameter: function (operator, value, field) {
        if ($A.util.isEmpty(value)) return "";
        let compareValue = "";
        if (operator === "like") {
            compareValue = " '%" + value + "%' "
        } else if (operator === "IN") {
            compareValue = " (" + value + ") "
        } else {
            compareValue = " '" + value + "' "
        }
        return " ( " + field + " " + operator + " " + compareValue + " ) ";
    },

    getPicklistQueryParameter: function (operator, value, field) {
        if ($A.util.isEmpty(value)) return "";
        let compareValue = "";
        if (operator === "IN") {
            let result = "(";
            for (const v of value) {
                if (result.length > 1) {
                    result += ",";
                }
                result += "'" + v + "'";
            }
            result += ") ";
            compareValue = result;
        } else {
            compareValue = " '" + value + "' "
        }
        return " ( " + field + " " + operator + " " + compareValue + " ) ";
    },

    getNonStringQueryParameter: function (operator, value, field) {
        if ($A.util.isEmpty(value)) return "";
        return " ( " + field + " " + operator + " " + value + " ) ";
    },
    getNumberQueryParameter: function (operator, value, field) {
        const numValue = parseFloat(value);
        if (isNaN(numValue)) return "";
        return this.getNonStringQueryParameter(operator, numValue, field);
    },
    reloadDataWithoutState: function (component) {
        component.set("v.currentPage", 1);
        component.set("v.pages", []);
        component.set("v.prePages", []);
        this.reloadData(component);
    },
    setSelectedFields: function (component) {
        let selectedFields = component.get("v.selectedFields");
        let fieldObject = component.get("v.fieldsObject");
        let columns = component.get("v.columns");

        let items = [];
        let actionCol = [];
        for (const column of columns) {
            if (column.type === "action") {
                actionCol.push = column;
            }
        }
        for (const selfield of selectedFields) {
            for (const allfield of fieldObject) {
                if (selfield === allfield.value) {
                    items.push({
                        label: allfield.label,
                        fieldName: allfield.value,
                        type: allfield.type,
                        typeAttributes: {label: {fieldName: allfield.value}, target: '_blank'}
                    });
                    allfield.showInTable = true;
                }
                allfield.showInTable = false;
            }
        }
        if (actionCol.length > 0) {
            items.push(actionCol);
        }
        component.set("v.columns", items);
        $A.enqueueAction(component.get("c.columnsChanged"));
    },
    groupBy: function (data, keyField) {
        return data.reduce(function (storage, item) {
            (storage[item[keyField]] = storage[item[keyField]] || []).push(item);
            return storage;
        }, {});
    },
    relateFilterFields: function (childFilterObjects) {
        //First clone filterObjects with JSON.parse(JSON.stringify(childFilterObjects)) to avoid effect v.filterObject.childFilterObjects attribute
        return JSON.parse(JSON.stringify(childFilterObjects)).reduce((filter, filterObj) => {
            if (filterObj.type === "REFERENCE") {
                if (filterObj.field.endsWith('__c')) {
                    filterObj.field = filterObj.field.replace('__c', '__r');
                } else if (filterObj.field.toLowerCase().endsWith("id")) {
                    filterObj.field = filterObj.field.replace(/id/ig, '');
                }
            }
            filter += $A.util.isEmpty(filter) ? filterObj.field : `.${filterObj.field}`;
            return filter;
        }, "");
    },
    relateFilterLabels: function (childFilterObjects) {
        return childFilterObjects.reduce((filter, filterObj) => {
            filter += `${filterObj.label} `;
            return filter;
        }, "");
    },
    setFieldDualListBoxValues: function (component) {
        const options = component.find('fieldDualListBox').get('v.options');
        const values = component.find('fieldDualListBox').get('v.value');
        const notLookupFieldValues = options.filter(option => values.includes(option.value)).reduce((notLookupFieldValues, option) => {
            if (option.type !== 'REFERENCE')
                notLookupFieldValues.push(option.value);
            return notLookupFieldValues
        }, []);
        component.find('fieldDualListBox').set('v.value', notLookupFieldValues);
    }
});