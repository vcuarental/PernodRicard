({
    initFilter: function(component, helper)
    {
        var fieldList = JSON.parse(component.get("v.fieldList"));
        helper.getTranslations(component, event, helper, function(translations)
        {
            component.set('v.translations', translations);
        });
        var sObjectFieldList = helper.stringifyBooleanValues(component, fieldList);

        var isFilterActive = false;
        sObjectFieldList.forEach(field => {
            if ( field.preselectedValue )
            {
                isFilterActive = true;
            }
        });

        component.set("v.isFilterActive", isFilterActive);
        component.set("v.filterFields", sObjectFieldList);

        helper.handleFieldSelectionUpdate(component, helper);
        helper.querySObject(component, helper, function(err, result)
        {
            if (err)
            {
                alert('Filtered List: ' + component.get('v.title') + ' returned an error retrieving data: ' + err[0].message);
                helper.hideSpinner(component);
                return;
            }
            component.set('v.sObjectArrayRaw', helper.stringifyBooleanValues(component, result));

            helper.createFrontentFilterOptions(component, helper);
            helper.applyFrontendFilter(component, helper);

            var dataTable = component.find('data-table');
            dataTable.applyDefaultSorting();
            helper.hideSpinner(component, helper);
        });
    },
    applyFrontendFilter: function(component, helper)
    {
        var sObjectArrayRaw = component.get('v.sObjectArrayRaw');
        var fields = component.get("v.filterFields");


        var frontendFilteredFields = fields.filter(field => field.filterValue && field.frontendFilter);
        // combine all filter values with the same restriction field (Relation.Type)
        var combinedFrontendFilteredFields = [];
        var restrictions = {};
        frontendFilteredFields.forEach(function(field){
            if ( field.frontendFilterRestriction )
            {
                if ( restrictions[field.fieldName] ) {
                    restrictions[field.fieldName].push(field.filterValue);
                } else {
                    restrictions[field.fieldName] = [field.filterValue];
                }
            } else {
                combinedFrontendFilteredFields.push(field);
            }
        })
        for (var key in restrictions) {
            combinedFrontendFilteredFields.push({fieldName: key, filterValue: restrictions[key].join(";")});
        }
        var sObjectArray;
        if (combinedFrontendFilteredFields.length == 0)
        {
            sObjectArray = sObjectArrayRaw.filter(function(sObject){return true});
        }
        else
        {
            sObjectArray = sObjectArrayRaw.filter(function(sObject)
            {
                var failedCheck = combinedFrontendFilteredFields.some(function(field)
                {
                    if (field.filterValue === null)
                        return false;
                    var match;
                    if (typeof field.type == "BOOLEAN") {
                        match = field.filterValue == helper.extract(sObject,field.fieldName).toString();
                    } else {
                        match = field.filterValue.split(";").indexOf(helper.extract(sObject,field.fieldName)) >= 0;
                    }
                    return !match;
                });
                return !failedCheck;
            })
        }

        component.set('v.sObjectArray', sObjectArray);
        component.set('v.listSize', sObjectArray.length);

        helper.hideSpinner(component);
    },
    applyBackendFilter : function(component, helper, resetFronendFilters)
    {
        helper.showSpinner(component);
        helper.querySObject(component, helper, function(err, result){
                component.set('v.sObjectArrayRaw', result);
                helper.applyFrontendFilter(component, helper);
            });
    },
    querySObject: function(component, helper, callback){
        var action = component.get("c.querySObject");
        var fields = component.get("v.filterFields");
        var fullListFields = component.get("v.fullListFields");
        var restrictionStatement = component.get("v.restrictionStatement");
        var recordId = component.get("v.recordId") || JSON.parse(component.get("v.parent")).recordId;

        restrictionStatement = restrictionStatement.replace('%%', recordId);
        var user = $A.get("$SObjectType.CurrentUser");
        restrictionStatement = restrictionStatement.replace('##', user.Id);

        var whereClause = '';
        fields.forEach(function(field)
        {
            if (field.filterSoqlExp)
                whereClause += ' AND ' + field.filterSoqlExp;
        });

        if (restrictionStatement)
        {
            whereClause = ' AND ' + restrictionStatement + ' ' + whereClause;
        }

        whereClause = whereClause.substr(4);

        var fieldsOutput = fields.map(function(field) {return JSON.stringify(field)});
        if (fullListFields) {
            var fullListFields = JSON.parse(fullListFields).map(function(field) {return JSON.stringify(field)});
        }
        var mergedFields = this.mergeFields(fieldsOutput, fullListFields);

        console.log('where ' , whereClause);
		
        //Add Map related fields to SOQL query
        if (component.get("v.GeoLocationField"))
        {
            var geoField = component.get("v.GeoLocationField");
            console.log('mergedFields' + mergedFields);
            var latitude = new Object();
            latitude.fieldName = geoField.substring(0, geoField.length -1) + 'Latitude__s';
            var longitue = new Object();
            longitue.fieldName = geoField.substring(0, geoField.length -1) + 'Longitude__s';
            mergedFields.push(JSON.stringify(latitude));
            mergedFields.push(JSON.stringify(longitue));
        }
        action.setParam('fields', mergedFields);
        action.setParam('whereClause', whereClause);
        action.setParam('sObjectName', component.get("v.listsObjectName"));

        action.setCallback(this, helper.callbackHandlerGenerator(callback));
        $A.enqueueAction(action);
    },
    extract: function(object, fieldName)
    {
        if (typeof object[fieldName] !== "undefined")
        {
            return object[fieldName]
        }
        var val = object;
        fieldName.split('.').forEach(function(part)
        {
            if (typeof val === "undefined" || val === null)
            {
                val = {};
            }
            val = val[part];
        });
        return val;
    },
    callbackHandlerGenerator: function(callback)
    {
        return function(response)
        {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                callback(null, response.getReturnValue());
            }
            else
            {
                callback(response.getError());
            }
        }
    },

    mergeFields: function(baseArray, arrayToMerge)
    {
        if(arrayToMerge) {
            arrayToMerge.forEach(mergeField => {
                var mergeFieldName = JSON.parse(mergeField).fieldName;
                var merge = true;
                baseArray.forEach(baseField => {
                    var baseFieldJSON = JSON.parse(baseField);
                    if (baseFieldJSON.fieldName == mergeFieldName) {
                        merge = false;
                    }
                });

                if (merge) {
                    baseArray.push(mergeField);
                }
            })
        }

        return baseArray;
    },

    getTranslations: function(component, event, helper, callback) {
        // https://fullcalendar.io/docs/event_data/Event_Object/
        console.log('getTranslations');

        var action = component.get("c.getTranslations");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('got translations: ' , response.getReturnValue());
                callback(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    handleFieldSelectionUpdate: function(component, helper){
        var selectedAccountFieldList = component.get("v.selectedAccountFieldList")
        selectedAccountFieldList = ['Id', 'Name'];
        var sObjectFieldList = component.get("v.filterFields");
        var sObjectColumns = [];

        var accountFieldMap = {};
        sObjectFieldList.forEach(
            function(accountField)
            {
                if ( accountField.isTableColumn )
                {
                    accountFieldMap[accountField.fieldName] = accountField;
                }
            }
        );
        sObjectColumns = Object.values(accountFieldMap)


        component.set("v.sObjectColumns", sObjectColumns);
    },
    createFrontentFilterOptions: function(component, helper)
    {
        var sObjectArrayRaw = component.get('v.sObjectArrayRaw');
        var fields = component.get("v.filterFields");

        fields.filter(field => field.frontendFilter).forEach(function(field)
        {
            var m = {};
            sObjectArrayRaw.forEach(function(sObject)
            {
                // check if there is restriction statements for filter
                var filterRestriction = field.frontendFilterRestriction;
                var filterRestrictionField = filterRestriction ? filterRestriction.substring(0, filterRestriction.indexOf("=")) : "";
                var filterRestrictionValue = filterRestriction ? filterRestriction.substring(filterRestriction.indexOf("=")+1, filterRestriction.length) : "";

                if (filterRestriction)
                {
                    var recordRestrictionValue = helper.extract(sObject,filterRestrictionField);
                    var val = helper.extract(sObject,field.fieldName);
                    if (!m[val] && typeof val != "undefined" && filterRestrictionValue == recordRestrictionValue)
                    {
                        m[val] = {label:val, text:val};
                    }
                }
                else
                {
                    var val = helper.extract(sObject,field.fieldName);
                    if (!m[val] && typeof val != "undefined")
                    {
                        m[val] = {label:val, text:val};
                    }
                }
            })
            field.filterValueOptions = Object.values(m).sort(function(a,b)
             {
                 var a1 = a.label;
                 var b1 = b.label;

                 return 1 * (a1 < b1 ? -1 : a1 > b1 ? 1 : 0);
             });

            if ( field.preselectedValue )
            {
                field.filterValue = field.preselectedValue;
            }
        });

        component.set('v.filterFields', fields);
    },
    stringifyBooleanValues: function(component, values) {
        var records = values;

        records.forEach( record => {
            for (var field in record) {
                if ( typeof record[field] == "boolean") {
                    record[field] = record[field].toString();
                }
            }
        })

        return records;
    },

    showSpinner: function(component){
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function(component, helper){
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        var isSpinnerRendered = spinner.getElements().length > 0;
        if ( !isSpinnerRendered && helper) {
            setTimeout(function(){
                helper.hideSpinner(component);
            }, 500)
        }
    }
})