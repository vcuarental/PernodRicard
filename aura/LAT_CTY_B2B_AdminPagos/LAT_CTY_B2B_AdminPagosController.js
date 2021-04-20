({
	doInit : function(component, event, helper) {
        helper.loadPaymentId(component);
        helper.loadColumns(component);
        helper.getInformedPayments(component, event, helper);
        helper.getProcessedPayments(component, event, helper);
        helper.getPayment(component);
	},
    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'viewPayment':
                console.log('row: '+JSON.stringify(row));
                component.set("v.paymentId", row.Id);
                helper.getPayment(component);
                break;
            
        }
	},
    procesarPagoCont: function(component, event, helper) {
        console.log('en controller procesar pago');
    	helper.procesarPago(component);
    },
    cancelarPagoCont: function(component, event, helper) {
    	helper.cancelarPago(component);
    },
    mostrarComentarios: function(component, event, helper) {
    	component.set("v.showComments", true);
    },
    ocultarComentarios: function(component, event, helper) {
    	component.set("v.showComments", false);
    },
 	next: function (component, event, helper) {
 	 	var sObjectList = component.get("v.informedPayments");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i = end + 1; i < end + pageSize + 1; i++ ) {
            if ( sObjectList.length > i ) {
                PagList.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
 	},
 	previous: function (component, event, helper) {
        var sObjectList = component.get("v.informedPayments");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i= start-pageSize; i < start ; i++ ) {
            if ( i > -1 ) {
                PagList.push(sObjectList[i]);
                counter ++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
 }
})