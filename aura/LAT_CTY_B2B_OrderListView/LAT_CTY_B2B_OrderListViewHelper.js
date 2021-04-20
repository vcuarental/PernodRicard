({
    /*
     * getColumnDefinitions
     * Get the columns to use on data table
     */
    getColumnDefinitions: function () {
        var columns = [
            // {label: 'Número de Pedido', fieldName: 'Name', type: 'text', sortable: true},
            {
                label: 'Nº de Pedido',
                fieldName: 'LAT_NROrderJDE__c',
                sortable: true,
                type: 'button',
                initialWidth: 160,
                typeAttributes: {
                    variant: "base",
                    label: {
                        fieldName: 'LAT_NROrderJDE__c'
                    },
                    name: 'view_details',
                    title: 'Click to View Details'
                }
            },
            {
                label: 'Nº de Referencia',
                fieldName: 'LAT_NRCustomerOrder__c',
                type: 'button',
                initialWidth: 160,
                typeAttributes: {
                    variant: "base",
                    label: {
                        fieldName: 'LAT_NRCustomerOrder__c'
                    },
                    name: 'view_details',
                    title: 'Click to View Details'
                }
            },
            {
                label: 'Nº Factura',
                fieldName: 'legalInvoice',
                type: 'text',
                initialWidth: 135,
                sortable: true
            },
            {
                label: 'Fecha',
                fieldName: 'CreatedDate',
                type: 'date',
                sortable: true,
                initialWidth: 200
            },
            {
                label: 'Monto',
                fieldName: 'LAT_AR_TotalImpuestosInculidos__c',
                type: 'currency',
                sortable: true,
                initialWidth: 160
            },
            {
                label: 'Estado',
                fieldName: 'LAT_StageName__c',
                type: 'text',
                sortable: true
            },
            {
                label: 'Factura',
                type: 'button-icon',
                initialWidth: 135,
                typeAttributes: {
                    iconName: 'utility:download',
                    name: 'facturaIcono',
                    title: 'Click para descargar factura',
                    disabled: {fieldName: 'facturaDisabled'}
                }
            },
            {
                label: 'Calico',
                fieldName: 'LAT_CTY_B2B_URL_Calico__c',
                type: 'url',
                sortable: false,
                typeAttributes: {
                    label: 'LINK',
                }
            },
            {
                label: 'Reorder',
                type: 'button',
                initialWidth: 205,
                typeAttributes: {
                    label: 'REPETIR PEDIDO',
                    name: 'reorder',
                    title: 'Click to Reorder'
                }
            }
        ];

        return columns;
    },

    /*
     * sortData
     * Order data
     */
    getOrders: function (component, filter) {
        component.set('v.isLoading', true);
        component.set('v.mycolumns', this.getColumnDefinitions());

        var action = component.get("c.getCommunityOrders");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    row.linkLabel = 'Descargar Factura'
                    // Process related field manually
                   	row.facturaDisabled = true;
                    if(row.LAT_NextStep__c != '' && row.LAT_NextStep__c != null){
                        row.facturaDisabled = false;
                    }
                    row.legalInvoice = row.LAT_MobileId__c;
                    if (row.LAT_Account__r) {
                        row.AccountName = row.LAT_Account__r.Name;
                        row.accountLink = '/' + row.LAT_Account__c;
                    }
                }
                this.setOrdersAndTotals(component, rows, filter);
            }
        });
        $A.enqueueAction(action);
    },

    /*
     * setOrdersAndTotals.
     * We have all the orders, so, we set the totals of orders integrated and new orders.
     * Into the order list we always have all the orders, and we manage the display based on the filter.
     */
    setOrdersAndTotals: function (component, orders, filter) {
        component.set("v.orders", orders);
        var resultsIntegrated = orders.filter(order => order.LAT_Community_Status__c != 'Nuevo').length;

        component.set("v.integratedOrdersCount", resultsIntegrated);
        component.set("v.notIntegratedOrdersCount", orders.length - resultsIntegrated);
        component.set('v.isLoading', false);
        this.filterByStatus(component, event, filter, null);
    },

    /*
     * sortData
     * Order data
     */
    sortData: function (component, fieldName, sortDirection) {

        console.log('fieldName', fieldName);
        var data = component.get("v.filteredOrders");
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        component.set("v.filteredOrders", data);
    },

    /*
     * sortBy
     * Order data
     */
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function (x) {
                return primer(x[field])
            } :
            function (x) {
                return x[field]
            };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },

    /*
     * showRowDetails
     * TO DO: call the lightning page
     */
    showRowDetails: function (row) {
        window.location.href = '/s/detalle-pedido?order=' + row.Id;
    },

    filterByStatus: function (component, event, filterStatus, term) {

        var data = component.get("v.orders");
       	var results = data;
        let filteredOpps = data;
        console.info('data antes:'+JSON.stringify(data));
        console.debug('data size:' + data.length);
        console.log('term : '+term);

        // If term means that the user use the search box, we filter by Name
        if (term) {
            filteredOpps = filteredOpps.filter(item => ( (item.LAT_NROrderJDE__c &&item.LAT_NROrderJDE__c.toLowerCase().includes(term)) 
                                                        || (item.LAT_StageName__c.toLowerCase().includes(term))
                                                       	|| (item.LAT_NRCustomerOrder__c && item.LAT_NRCustomerOrder__c.toLowerCase().includes(term))));
            console.info('filteredOpps despues: ' + filteredOpps.length);
            data = filteredOpps;
            //data = data.filter(order => (item.LAT_NROrderJDE__c && order.LAT_NROrderJDE__c.toLowerCase().includes(term)) | (item.LAT_NRCustomerOrder__c && order.LAT_NRCustomerOrder__c.toLowerCase().includes(term))|| (item.LAT_StageName__c && order.LAT_StageName__c.toLowerCase().includes(term)));
        }
        console.info('data despues: ' + data);
        console.debug('data size despues:' + data.length);
        switch (filterStatus) {
            case 'all':
                component.set('v.filter', 'Todos los Pedidos');
                results = data;
                break;
            case 'new':
                component.set('v.filter', 'Pedidos Nuevos');
                //results = data.filter(order=>  !order.LAT_NROrderJDE__c );
                results = data.filter(order => order.LAT_Community_Status__c == 'Nuevo');

                // component.set("v.notIntegratedOrdersCount",  results.length);
                break;
            case 'integrated':
                component.set('v.filter', 'Pedidos Integrados');
                results = data.filter(order => order.LAT_Community_Status__c != 'Nuevo');
                // component.set("v.integratedOrdersCount",  results.length);

                break;
            default:
                component.set('v.filter', 'Todos los Pedidos');
                results = data;
                break;
        }

        var resultsIntegrated = data.filter(order => !order.LAT_NROrderJDE__c).length;
        component.set("v.integratedOrdersCount", resultsIntegrated);
        component.set("v.notIntegratedOrdersCount", data.length - resultsIntegrated);
        component.set("v.filteredOrders", results);
    },

    reorder: function (component, row) {
        component.set('v.isLoading', true);
        console.info('reorder');
        //console.info(row);
        console.info(row.Id);

        var action = component.get("c.reOrderOppty");
        console.info('1 1');
        action.setParams({ "opptyId" : row.Id });

        console.info('before callback');
        action.setCallback(this, function (response) {
            console.info('callback');
            var state = response.getState();
            if (state === "SUCCESS") {
                console.info(response.getReturnValue());
                window.location.href = '/s/nuevo-pedido?opencart=1';
            }
        });
        $A.enqueueAction(action);
    }
})