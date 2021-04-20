({
    doFetchFacturas: function(component) {
        console.log('en doFetchFacturas 1 ');
        
        var action = component.get('c.getPendingFiscalNotes');
        console.log('en doFetchFacturas 2');
        action.setCallback(this, function(response){
            
        	console.log('en doFetchFacturas 3 ');
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                
                console.log('en doFetchFacturas 4:'+JSON.stringify(response.getReturnValue()));
          		var rows = response.getReturnValue();
                var data = component.get("v.fiscalNotes");
                console.log('data antes:' + JSON.stringify(data));
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    // Process related field manually
                    row.fiscalNoteNumber = row.LAT_LegalInvoice__c;
                    row.fiscalNoteStatus = row.LAT_AR_B2B_Status__c;
                    row.fiscalNoteAmount = row.LAT_AR_NetAmmount__c;
                    row.issueDate = row.LAT_BillingDate__c;
                    row.sfdcId = row.Id;
                    row.verPago = row.LAT_B2B_Payment__c;
                    row.linkPago = '/s/mi-cuenta/?tab=pagos&payment='+row.LAT_B2B_Payment__c;
                     
                    if(row.verPago==null) {
                        row.linkPago ='';
                    }
                    if(row.LAT_B2B_Payment__r){
                        row.linkPagoLabel = row.LAT_B2B_Payment__r.Name;
                    }
                    if (row.LAT_Opportunity__r)  {
                        row.oppName = row.LAT_Opportunity__r.LAT_NROrderJDE__c;
                        row.oppId = '/s/detalle-pedido?order='+row.LAT_Opportunity__c;
                        row.descargarFactura = row.LAT_Opportunity__r.LAT_NextStep__c;
                        console.log('%% row.descargarFactura : '+ row.descargarFactura);
                        if(row.descargarFactura==null) {
                            row.facturaDisabled = 'false';
                        }
                        row.descargarRecibo = row.LAT_Opportunity__r.LAT_Description__c;
                        if(row.descargarRecibo==null) {
                            row.reciboDisabled = 'false';
                        }
                        row.linkLabel = 'Descargar Factura';
                    }
                
                    
                    console.log('en doFetchFacturas 2 row:' + JSON.stringify(row));
                    
                    data.push(row);
                 }
                console.log('data despues:' + JSON.stringify(data));
                component.set('v.fiscalNotes', data);
            }else{
                alert('ERROR');
        		console.log('en doFetchFacturas 5');
            }
        });
        
        console.log('en doFetchFacturas 6');
        $A.enqueueAction(action);
        
    },
    doFetchPaidFacturas: function(component) {
        console.log('en doFetchFacturas 1 ');
        
        var action = component.get('c.getPaidFiscalNotes');
        action.setCallback(this, function(response){
            
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                
          		var rows = response.getReturnValue();
                var data = component.get("v.paidFiscalNotes");
                console.log('data antes:' + JSON.stringify(data));
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    // Process related field manually
                    row.fiscalNoteNumber = row.LAT_LegalInvoice__c;
                    row.fiscalNoteStatus = row.LAT_AR_B2B_Status__c;
                    row.fiscalNoteAmount = row.LAT_AR_NetAmmount__c;
                    row.issueDate = row.LAT_BillingDate__c;
                    row.sfdcId = row.Id;
                    row.verPago = row.LAT_B2B_Payment__c;
                    if(row.verPago==null) {
                        row.pagoDisabled = 'false';
                    }
                    
                    if(row.LAT_B2B_Payment__r){
                        row.linkPago = '/s/mi-cuenta/?tab=pagos&payment='+row.LAT_B2B_Payment__c;
                        row.linkPagoLabel = row.LAT_B2B_Payment__r.Name;
                    }
                    if (row.LAT_Opportunity__r)  {
                        row.oppId = '/s/detalle-pedido?order='+row.LAT_Opportunity__c;
                        row.oppName = row.LAT_Opportunity__r.LAT_NROrderJDE__c;
                        row.descargarFactura = row.LAT_Opportunity__r.LAT_NextStep__c;
                        console.log('%% row.descargarFactura : '+ row.descargarFactura);
                        if(row.descargarFactura==null) {
                            row.facturaDisabled = 'false';
                        }
                        row.descargarRecibo = row.LAT_Opportunity__r.LAT_Description__c;
                        if(row.descargarRecibo==null) {
                            row.reciboDisabled = 'false';
                        }
                        row.linkLabel = 'Descargar Factura';
                    }
                
                    
                    console.log('en doFetchFacturas 2 row:' + JSON.stringify(row));
                    
                    data.push(row);
                 }
                console.log('data despues:' + JSON.stringify(data));
                component.set('v.paidFiscalNotes', data);
            }else{
                alert('ERROR');
        		console.log('en doFetchFacturas 5');
            }
        });
        
        console.log('en doFetchFacturas 6');
        $A.enqueueAction(action);
        
    },
    doFetchNotasDeCredito: function(component) {
        console.log('en doFetchNotasDeCredito 1 ');
        
        var action = component.get('c.getNotasDeCredito');
        action.setCallback(this, function(response){
            
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                
          		var rows = response.getReturnValue();
                console.log('data antes doFetchNotasDeCredito:' + JSON.stringify(rows));
                component.set('v.notasDeCredito', rows);
            }else{
                alert('ERROR');
        		console.log('en doFetchNotasDeCredito 5');
            }
        });
        
        console.log('en doFetchNotasDeCredito 6');
        $A.enqueueAction(action);
        
    },

    pay: function(component, event) {
        var error = '';
        console.info("pay");
        var paymentAmount = component.find('paymentAmount');
        
        console.info("paymentAmount: " + paymentAmount.get("v.value"));
        
        
        //console.info("paymentAmount value: " + paymentAmount.get("v.value"));
        if (!paymentAmount.get("v.validity").valid) {
            paymentAmount.showHelpMessageIfInvalid();
            var target = component.find('cuadroDePago');
            console.log('target tabla : ' + target);
            var element = target.getElement();
            var rect = element.getBoundingClientRect();
            scrollTo({top: rect.top, behavior: "smooth"});
            error = 'Por favor ingrese el monto del comprobante.'
        } else {
            var uploadedFiles = component.get("v.uploadedFileIds");
            console.info("uploadedFiles: " + uploadedFiles);
            
            var listaComprobantes = component.get("v.selectedNotes");
            console.info("listaComprobantes: ");
            console.info(listaComprobantes);
    
            if (listaComprobantes.length == 0 && !component.get("v.esAdelanto")) {
                scrollTo({top: 350, behavior: "smooth"});
                error += '\nNo se han seleccionado facturas.\nPor favor seleccione una factura, o marque el pago como Adelanto';
            }
        }
        
        if (error != '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Han Ocurrido Errores al Informar el Pago",
                "message": error,
                "type": "error",
                "duration":9000
            });
            toastEvent.fire();
                       
        } else {
            component.set("v.isLoading", true);
            var paymentIds = new Array();
            for (var i= 0; i < listaComprobantes.length ; i++){
                paymentIds.push(listaComprobantes[i].Id);
            }
            console.info("paymentIds: ");
            console.log(paymentIds);
            
            var listaNCs = component.get("v.selectedNCs");
            var ncIds = new Array();
            for (var i= 0; i < listaNCs.length ; i++){
                ncIds.push(listaNCs[i].Id);
            }
            console.info("ncIds: ");
            console.log(ncIds);
            var action = component.get('c.updatePayment');
            let esAdelanto = component.get("v.esAdelanto");
            console.log('es adelanto : '+ esAdelanto);
            action.setParams({ 
                "paymentId": component.get("v.b2bPaymentId"),
                "isDownpayment": esAdelanto,
                "paymentAmount": paymentAmount.get("v.value"),
                "fiscalNotesId": JSON.stringify(paymentIds),
                "titulosId": JSON.stringify(ncIds)
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('pay retorno : ' + state);
                console.log('pay error : ');
                console.log(response.getError());
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "El pago fue cargado correctamente",
                        "type": "success"
                    });
                    toastEvent.fire();     
                    component.set("v.isLoading", false);
                    component.set("v.mostrarCuadroPago", false);
                    window.open('/s/mi-cuenta?tab=facturas','_top')               
                }
            });
            $A.enqueueAction(action);
        }
    },

    cretatePaymentJunction: function(component) {
        console.log('cretatePaymentJunction');
        var action = component.get("c.createB2BPayment");
        action.setCallback(this, function(a) {
            var state = a.getState();
            console.log('cretatePaymentJunction retorno : ' + state);
            console.log('cretatePaymentJunction error : ');
            console.log(a.getError());
            if (state === "SUCCESS") {
                var payment = a.getReturnValue();
                console.log('payment:');
                console.log(payment);
                component.set('v.b2bPayment', payment);
                component.set('v.b2bPaymentId', payment.Id);
            }
        });
        $A.enqueueAction(action);
    }
})