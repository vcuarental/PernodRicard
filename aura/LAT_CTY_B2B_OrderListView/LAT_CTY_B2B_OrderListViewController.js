({
    doInit : function(component, event, helper){
        var currentFilter = component.get('v.filterName');
        helper.getOrders(component, currentFilter);
    },

    /*
    * newOrder
    * Open Step 1 from Overlay
    */
    newOrder : function(component, event, helper){
        window.location.href = '/s/nuevo-pedido';
    },

    /*
    * updateColumnSorting
    * Order trigger called when the user click on header table to reorder
    */
    updateColumnSorting: function(component, event, helper){

        component.set('v.isLoading', true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        setTimeout(function() {
            var fieldName = event.getParam('fieldName');
            console.log(fieldName);
            var sortDirection = event.getParam('sortDirection');
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
            component.set('v.isLoading', false);
        }, 200);
    },

    /*
    * handleRowAction
    *
    */
    handleRowAction: function (component, event, helper){
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view_details':
                helper.showRowDetails(row);
                break;
            case 'reorder':
                helper.reorder(component, row);
                break;
            case 'facturaIcono':
                console.log('adentro del action : ' + row.LAT_NextStep__c);
                var address = row.LAT_NextStep__c;
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": address,
                  "isredirect" :true
                });
                urlEvent.fire();
                break;
        }
    },

    changeFilter: function (component, event, helper){
        console.log(event.getParams());
        var selectedFilter = event.getParam("value");
        component.set('v.filterName', selectedFilter);
        // TO DO: Custom labels
        var queryTerm = component.find('enter-search').get('v.value');
        helper.filterByStatus(component, event, selectedFilter, queryTerm);

    },

    searchHandler: function (component, event, helper){
        var isEnterKey = event.keyCode === 13;
        var queryTerm = component.find('enter-search').get('v.value');


        if (isEnterKey) {
            component.set('v.isLoading', true);
            component.set('v.term', queryTerm);
            setTimeout(function() {
                // alert('Searched for "' + queryTerm + '"!');
                component.set('v.isLoading', false);
                var currentFilter = component.get('v.filterName');
                helper.filterByStatus(component, event, currentFilter, queryTerm);
            }, 0);
        }

    },

    checkIfIsEmpty: function (component, event, helper){

        var queryTerm = component.find('enter-search').get('v.value');
        if (queryTerm == '') {
            // Reset to show all the results
            var currentFilter = component.get('v.filterName');
            component.set('v.term', '');
            helper.getOrders(component, event, helper, currentFilter);
        }

    },








})