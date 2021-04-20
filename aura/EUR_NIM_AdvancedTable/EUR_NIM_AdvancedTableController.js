/**
 * Created by thomas.schnocklake on 23.01.18.
 */
({
    init: function (component, event, helper) {
    },
    applyDefaultSorting: function (component, event, helper) {
        component.set('v.fromIndex', 0);
        helper.applySorting(component, event, helper);
        helper.applyPagination(component, event, helper);
    },
    jsLoaded : function(cmp, evt, hlp) {
    },

    handleHide : function (component, event, helper) {
        var idx = event.getSource().get('v.value');
        var visibleRows = component.get('v.visibleRows');
        if (visibleRows[idx].showDetails)
        {
            visibleRows[idx].showDetails = false;
        }
        else
        {
            visibleRows[idx].showDetails = true;
        }

        helper.applyPagination(component, event, helper);

    },
    handleAllHide : function (component, event, helper) {
        var dataArrayInternal = component.get('v.dataArrayInternal');
        dataArrayInternal.forEach(function(row)
        {
            if (row.isGrouping)
            {
                row.showDetails = true;
            }

        })

        helper.applyPagination(component, event, helper);

    },
    prev : function (component, event, helper) {
        component.set('v.fromIndex',component.get('v.fromIndex') - component.get('v.pageSize'));
        helper.applyPagination(component, event, helper);
        helper.attachDND(component, event, helper);
    },
    next : function (component, event, helper) {
        component.set('v.fromIndex',component.get('v.fromIndex') + component.get('v.pageSize'));
        helper.applyPagination(component, event, helper);
        helper.attachDND(component, event, helper);
    },
    onSortClick : function (component, event, helper) {
        //var whichOne = event.getSource().get('v.value');
        var whichOne = event.currentTarget.dataset.fieldname
        console.log(whichOne);

        var sortField = component.get('v.sortField');
        var sortDir = component.get('v.sortDir');

        if (sortField === whichOne)
        {
            if (sortDir === 'DESC')
            {
                sortDir = 'ASC';
            }
            else
            {
                sortDir = 'DESC'
            }
        }
        else
        {
            sortField = whichOne;
            sortDir = 'ASC';
        }
        component.set('v.sortField', sortField);
        component.set('v.sortDir', sortDir);
        component.set('v.fromIndex', 0);
        helper.applySorting(component, event, helper);
        helper.applyPagination(component, event, helper);

        var event = component.getEvent("changeSortSettings");
        event.fire();
    },
    changeValue : function (component, event, helper) {
        component.set('v.columns', [
                {label: 'Account name', fieldName: 'Name', type: 'text'},
                {label: 'Account id', fieldName: 'Id', type: 'text'}
            ]);
    },
    colsChange : function (component, event, helper) {
        helper.handleListOrColsChange(component, event, helper);
        helper.applySorting(component, event, helper);
        helper.applyPagination(component, event, helper);


    },
    objectListChange : function (component, event, helper) {
        component.set('v.fromIndex',0);
        helper.handleListOrColsChange(component, event, helper);
        helper.applySorting(component, event, helper);
        helper.applyPagination(component, event, helper);

    },
    addDND : function (component, event, helper) {
        helper.attachDND(component, event, helper);
    },

})