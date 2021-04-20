({
    loadColumns : function(component){
        component.set('v.columns', [
            {
                label: 'Nro Pago',
                fieldName: 'Name',
                type: 'text'
            },
            {
                label: 'Status',
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

                 
                component.set('v.uploadedFileIds', uploadedFileIds);
                component.set('v.pago', payment);
                component.set('v.accountName', payment.LAT_Account__r.Corporate_Name__c);
            }
        });
        $A.enqueueAction(action);
	},
   	getInformedPayments : function(component, event, helper) {
        console.log('en getPaymentsList');
		var action = component.get("c.getInformedPayments");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var pageSize = component.get("v.pageSize");
                var payments = a.getReturnValue();
                component.set("v.totalRecords", payments.length);
                component.set("v.startPage", 0);                
                component.set("v.endPage", pageSize - 1);
                var PagList = [];
                for ( var i=0; i< pageSize; i++ ) {
                    if ( payments.length> i )
                        PagList.push(payments[i]);    
                }
                component.set('v.PaginationList', PagList);
                
                console.log('informedPayments:');
                console.log(JSON.stringify(payments));
                
                component.set('v.informedPayments', payments);
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
    getProcessedPayments : function(component, event, helper) {
        console.log('en getPaymentsList');
		var action = component.get("c.getProcessedPayments");
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var payments = a.getReturnValue();
                console.log('processed payments:');
                console.log(JSON.stringify(payments));
                for(var i=0; i<payments.length; i++){
                    var row = payments[i];
                    row.LAT_Account__rName = row.LAT_Account__r.Name;
                    console.log('processed row:'+row);
                }
                component.set('v.processedPayments', payments);
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
   	procesarPago : function(component) {
        console.log('en helper procesarPago');
        console.log('en procesarPago, paymentId: ' + component.get("v.paymentId"));
		var action = component.get("c.procesarPago");
        action.setParams({ "paymentId": component.get("v.paymentId") });
        let _this = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response:'+response);
            console.log('response.getState():'+response.getState());
            if (state === "SUCCESS") {
                
                var payment = response.getReturnValue();
                console.log('payment:');
                console.log(JSON.stringify(payment));
                component.set('v.pago', payment);
                let uploadedFileIds = [];
                if(payment.ContentDocumentLinks) {
                    for(var i =0; i<payment.ContentDocumentLinks.length; i++){
                        uploadedFileIds.push(payment.ContentDocumentLinks[i].ContentDocumentId);
                    }
                }

                 
                component.set('v.uploadedFileIds', uploadedFileIds);
                component.set('v.pago', payment);
                component.set('v.accountName', payment.LAT_Account__r.Corporate_Name__c);
                _this.getInformedPayments(component);
                _this.getProcessedPayments(component);
            }
        });
        $A.enqueueAction(action);
	},
   	cancelarPago: function(component) {
        console.log('en helper  cancelar');
        console.log('en procesarPago, paymentId: ' + component.get("v.paymentId"));
		var action = component.get("c.cancelarPago");
        action.setParams({
            "paymentId": component.get("v.paymentId"),
        	"comments": component.get("v.comments")	
        });
        let _this = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response:'+response);
            console.log('response.getState():'+response.getState());
            if (state === "SUCCESS") {
                
                var payment = response.getReturnValue();
                console.log('payment:');
                console.log(JSON.stringify(payment));
                component.set('v.pago', payment);
                component.set('v.comments', "");
                component.set('v.showComments', false);
                let uploadedFileIds = [];
                if(payment.ContentDocumentLinks) {
                    for(var i =0; i<payment.ContentDocumentLinks.length; i++){
                        uploadedFileIds.push(payment.ContentDocumentLinks[i].ContentDocumentId);
                    }
                }

                 
                component.set('v.uploadedFileIds', uploadedFileIds);
                component.set('v.pago', payment);
                component.set('v.accountName', payment.LAT_Account__r.Corporate_Name__c);
                _this.getInformedPayments(component);
                _this.getProcessedPayments(component);
            }
        });
        $A.enqueueAction(action);
	},
})