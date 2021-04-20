({
    describeChildRelationship: function (component, helper) {
        var describeRelationship = component.get('c.describeRelationship');
        describeRelationship.setParams({
            'parentSObjectName': component.get('v.parentSObjectName'),
            'childRelationshipName': component.get('v.childRelationshipName')
        });
        describeRelationship.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var childRelationship = JSON.parse(response.getReturnValue());
                console.log('childRelationship:', childRelationship);
                if (childRelationship != null && component.get('v.childRelationship') == null) {
                    component.set('v.childRelationship', childRelationship);
                    component.set('v.childSObjectName', childRelationship.objectName);
                }
                component.set('v.childRelationLoaded', true);
                helper.populateFilter(component, helper);
            }
        });
        $A.enqueueAction(describeRelationship);
    },
    populateFilter: function (component, helper) {
        var childRelationship = component.get('v.childRelationship');
        if (childRelationship && childRelationship.hasOwnProperty('objectName') &&
            childRelationship.hasOwnProperty('items') && !$A.util.isEmpty(childRelationship.items)) {
            component.find('filterBuilder').setInitialItems(childRelationship.items, childRelationship.filterLogic);
            helper.markSection(component, true);
            helper.expandSectionHandler(component);
        }
    },
    changeRelationType: function (component, event, helper) {
        helper.changeCheckboxGroupState(event.target);
        helper.markSection(component, event.target.checked);
        helper.setRelationType(component, event.target);
    },
    changeCheckboxGroupState: function (target) {
        var checkBoxState = target.checked;
        var checkboxGroup = document.getElementsByName(target.name);
        for (let i = 0; i < checkboxGroup.length; i++) {
            checkboxGroup[i].checked = false;
        }
        target.checked = checkBoxState;
    },
    setRelationType: function (component, target) {
        var childRelation = component.get('v.childRelationship');
        childRelation.parentRelationType = (target.checked == true) ? target.value : null;
        component.set('v.childRelationship', childRelation);
    },
    markSection: function (component, targetChecked) {
        var section = component.find('section-name');
        if (targetChecked) {
            $A.util.addClass(section, 'selectedFilter');
        }
        else {
            $A.util.removeClass(section, 'selectedFilter');
        }
    },
    expandSectionHandler: function (component) {
        var section = component.find('section');
        $A.util.toggleClass(section, 'slds-is-open');
        $A.util.toggleClass(section, 'slds-is-closed');
    },
    onBuildFilterHandler: function (component, event, helper) {
        var buildFilterResult = event.getParam("result");
        console.log('FilterBuilder Component result:', JSON.parse(JSON.stringify(buildFilterResult)));
        helper.fullfillChildRelationship(component, buildFilterResult, helper);
        helper.markFilterCondition(component, buildFilterResult);
    },
    markFilterCondition: function (component, buildFilterResult) {
        var errorMark = component.find('section-error-mark');
        if (!buildFilterResult.success) {
            $A.util.removeClass(errorMark, 'slds-hide');
        }
        else {
            $A.util.addClass(errorMark, 'slds-hide');
        }
    },
    fullfillChildRelationship: function (component, buildFilterResult, helper) {
        var childRelationship = component.get('v.childRelationship');
        for (let attr in  buildFilterResult.filter) {
            childRelationship[attr] = buildFilterResult.filter[attr];
        }
        if (buildFilterResult.success
            && !$A.util.isEmpty(buildFilterResult.filter.items)
            && ($A.util.isEmpty(childRelationship.parentRelationType) && childRelationship.objectName !== 'EUR_CRM_PRS_Segmentation__c')) {
            // buildFilterResult.message = $A.get('$Label.c.No_Parent_Relation');
            buildFilterResult.message = 'No Parent Relation was chosen!';
            buildFilterResult.success = false;
        }
        component.set('v.errorMessage', buildFilterResult.message);
        buildFilterResult.filter = childRelationship;
        helper.sendResult(component, buildFilterResult);
    },
    buildFilterHandler: function (component) {
        component.find('filterBuilder').validate();
    },
    sendResult: function (component, result) {
        var buildFilterEvent = component.getEvent("buildChildRelationshipFilterEvent");
        buildFilterEvent.setParams({
            result: result
        });
        buildFilterEvent.fire();
    }
})