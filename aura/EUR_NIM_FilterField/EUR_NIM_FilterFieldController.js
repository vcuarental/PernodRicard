/**
 * Created by thomas.schnocklake on 22.03.18.
 */
({
    doneRendering : function(component, event, helper) {
    },
    init : function(component, event, helper) {
        var field = component.get("v.field");
    },

    filterChanged : function(component, event, helper) {
        console.log('filter: ', component.get('v.field.filterValue'));
        var field = component.get('v.field');
        var filterSoqlExp = null;
        if (field.type === 'STRING')
        {
            if (field.filterValue)
            {
                filterSoqlExp = field.fieldName + ' Like \'%' +field.filterValue+'%\' ';
            }
        }
        else if (field.type === 'DATETIME' || field.type === 'DATE' || field.type === 'CURRENCY' || field.type === 'DOUBLE' || field.type === 'INT')
        {
           if (field.filterValueFrom)
           {
               filterSoqlExp = field.fieldName + ' >= ' +field.filterValueFrom+' ';
           }
           if (field.filterValueTo)
           {
               filterSoqlExp =( filterSoqlExp ? filterSoqlExp + ' AND ' : '' ) + field.fieldName + ' <= ' +field.filterValueTo+' ';
           }
        }
        component.set('v.field.filterSoqlExp',  filterSoqlExp);

        var filterChangeEvent = component.getEvent("filterChangeEvent");
        filterChangeEvent.fire();
    },
    frontendFilterChanged : function(component, event, helper) {
        console.log('filter: ', component.get('v.field.filterValue'));

        var filterChangeEvent = component.getEvent("filterChangeEvent");
        filterChangeEvent.setParams({"isFrontend" : true });

        filterChangeEvent.fire();
    },

    reset : function(component, event, helper) {
        component.set("v.field.filterValue", "");
        component.set("v.field.filterValueFrom", "");
        component.set("v.field.filterValueTo", "");
        component.set("v.field.filterSoqlExp", "");
    }
})