({
    loadColumns : function(component){
        component.set('v.columns', [
            {
                label: 'Nro Pago',
                fieldName: 'Name',
                type: 'text'
            },
            {
                label: 'Estado',
                fieldName: 'LAT_Status__c',
                type: 'text'
            },
            {
                label: 'Importe',
                fieldName: 'LAT_Amount__c',
                type: 'currency'
            },
            {
                label: 'Fecha',
                fieldName: 'LAT_Date__c',
                type: 'text'
            },
            {
                label: '',
                type: 'button',
                initialWidth: 135,
                typeAttributes: {
                    label: 'Ver Pago',
                    name: 'viewPayment',
                    title: ''
                }
            },

        ]);
    },
	getPayment : function(component) {
        console.log('en getPayment');
		var action = component.get("c.getB2BPayment");
        action.setParams({ "paymentId": component.get("v.paymentId") });
        console.log('en getPayment, paymentId: ' + component.get("v.paymentId"));
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var payment = a.getReturnValue();
                console.log('payment:');
                console.log(JSON.stringify(payment));
                component.set('v.pago', payment);
                let uploadedFileIds = [];
                if(payment.ContentDocumentLinks) {
                    for(var i =0; i<payment.ContentDocumentLinks.length; i++){
                        uploadedFileIds.push(payment.ContentDocumentLinks[i].ContentDocumentId);
                    }
                }
                var facturasList = [];
                var notasDeCreditoList = [];
                if(payment.Fiscal_Notes__r){
                    for(var i =0; i<payment.Fiscal_Notes__r.length; i++){
                        if(payment.Fiscal_Notes__r[i].LAT_PaymentTerm__c == 'NC'){
                            notasDeCreditoList.push(payment.Fiscal_Notes__r[i]);
                        }else {
                            facturasList.push(payment.Fiscal_Notes__r[i]);
                        }
                    }
                }
                component.set('v.uploadedFileIds', uploadedFileIds);
                component.set('v.pago', payment);
                component.set('v.facturas', facturasList);
                component.set('v.notasDeCredito', notasDeCreditoList);
                component.set('v.accountName', payment.LAT_Account__r.Corporate_Name__c);
            }
        });
        $A.enqueueAction(action);
	},
   	getPaymentsList : function(component, event, helper) {
        console.log('en getPaymentsList');
		var action = component.get("c.getPaymentsList");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var payments = a.getReturnValue();
                console.log('payments:');
                console.log(JSON.stringify(payments));
                
                component.set('v.payments', payments);
                var payid = component.get("v.paymentId");
                if(payid.length==0){
                    console.log('entramos:'+payments[0].Id);
                    component.set('v.paymentId', payments[0].Id);
                    helper.getPayment(component);
                }
            }
        });
        $A.enqueueAction(action);
	},
    loadPaymentId: function (component) {
        var url = decodeURIComponent(window.location.search.substring(1));
        var urlParams = url.split('&');
        var reorderParam;
        for (var i = 0; i < urlParams.length; i++) {
            reorderParam = urlParams[i].split('=');
            if (reorderParam[0] === 'payment') {
                reorderParam[1] === undefined ? 0 : reorderParam[1];
                if (reorderParam[1] != 0) {
                    component.set("v.paymentId", reorderParam[1]);
                }
            }
        }
    },
})