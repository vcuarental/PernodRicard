({
    getChildRelationships: function (component) {
        var sObjectName = component.get('v.sObjectName');
        var getChildRelationships = component.get('c.getChildRelationships');
        getChildRelationships.setParam('sObjectName', sObjectName);
        getChildRelationships.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var childRelationships = JSON.parse(response.getReturnValue());
                console.log('childRelationships:', childRelationships);
                var childRels = component.get('v.childRelationships');
                childRelationships.forEach(function (valueFromBackend) {
                    if (!$A.util.isEmpty(childRels)) {
                        childRels.forEach(function (existingValue) {
                            if (valueFromBackend.relationshipName === existingValue.relationshipName) {
                                valueFromBackend.prepopulatedFilter = existingValue.prepopulatedFilter;
                            }
                        });
                    }
                });
                component.set('v.childRelationships', childRelationships);
                component.set('v.childRelationsLoaded', true);
            }
        });
        $A.enqueueAction(getChildRelationships);
    },
    buildFilterHandler: function (component, helper) {
        component.set('v.childFilters', null);
        component.set('v.hasError', false);
        var relationships = component.find('childRel');
        if(relationships) {
            [].concat(relationships).forEach(function (relationship) {
                relationship.buildFilter();
            });
        } else {
            var result = {
                success: true,
                message: 'OK',
                childFilters: []
            };
            helper.sendBuildFilterEventHandler(component, result);
        }
    },
    childRelationshipFilterBuild: function (component, event) {
        var childRelationshipFilterBuildEvent = event.getParam('result');
        console.log('ChildRelationship Component result:', JSON.parse(JSON.stringify(childRelationshipFilterBuildEvent)));
        if (!childRelationshipFilterBuildEvent.success) {
            component.set('v.hasError', true);
        }
        var childFilters = component.get('v.childFilters');
        if ( ! childFilters) { childFilters = []; }

        var relationName = childRelationshipFilterBuildEvent.filter.childRelationshipName;

        const obj = Object.create({});
        obj[relationName] = childRelationshipFilterBuildEvent.filter;
        childFilters.push(obj);
        component.set('v.childFilters', childFilters);
    },
    fireBuildFilterEventHandler: function (component, event, helper) {
        var childFilters = component.get('v.childFilters');
        if (childFilters && childFilters.length == component.get('v.childRelationships').length) {
            console.log('Fire BuildFilterEvent');
            var hasError = component.get('v.hasError');
            var result = {
                success: !hasError,
                message: !hasError ? 'OK' : 'The error occurred during building one of the child relationship filters. Please, revise errors before saving.',
                childFilters: childFilters
            };
            helper.sendBuildFilterEventHandler(component, result);
        }
    },

    sendBuildFilterEventHandler: function (component, result) {
        var filterBuilderEvent = component.getEvent('buildFilterEvent');
        filterBuilderEvent.setParams({
            result: result
        });
        filterBuilderEvent.fire();
    },

    filterPopulationHandler: function (component, event) {
        var params = event.getParam('arguments');
        if (params && params.hasOwnProperty('existingFilter')) {
            var childRelationships = component.get('v.childRelationships');
            for (let relationshipName in params.existingFilter) {
                if ($A.util.isEmpty(childRelationships) || !childRelationships.hasOwnProperty(relationshipName)) {
                    childRelationships.push({
                        relationshipName: relationshipName,
                        prepopulatedFilter: params.existingFilter[relationshipName]
                    });
                }
                else {
                    childRelationships.forEach(function (value) {
                        if (value.relationshipName === relationshipName) {
                            value.prepopulatedFilter = params.existingFilter[relationshipName];
                        }
                    })
                }
            }
            component.set('v.childRelationships', childRelationships);
        }
    }
})