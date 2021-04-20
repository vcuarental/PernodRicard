({
    doInit: function (component, event, helper) {
        component.set('v.mostrarCuadroPago', false);
        component.set('v.columns', [
            {
                label: 'Nro Pedido',
             	fieldName: 'oppId', 
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'oppName' }
                  }
            },
            {
                label: 'Nro Factura',
                fieldName: 'fiscalNoteNumber',
                type: 'text'
            },
            {
                label: 'Estado',
                fieldName: 'fiscalNoteStatus',
                type: 'text'
            },
            {
                label: 'Importe',
                fieldName: 'fiscalNoteAmount',
                type: 'currency'
            },
            {
                label: 'Saldo',
                fieldName: 'LAT_Balance__c',
                type: 'currency'
            },
            {
                label: 'Fecha',
                fieldName: 'issueDate',
                type: 'text'
            },
            {
                label: 'Venc. Factura',
                fieldName: 'LAT_DueDate__c',
                type: 'text'
            },
            {
                label: 'Factura',
                type: 'button-icon',
                initialWidth: 135,
                typeAttributes: {
                    iconName: 'utility:download',
                    name: 'facturaIcono',
                    title: 'Click to Download Invoice',
                    disabled: {fieldName: 'facturaDisabled'}
                }
            },
            {
                label: 'Recibo',
                type: 'button-icon',
                initialWidth: 135,
                typeAttributes: {
                    iconName: 'utility:note',
                    name: 'reciboIcono',
                    title: 'Click to Download Receipt',
                    disabled: {fieldName: 'reciboDisabled'}
                }
            },
            {
                label: 'Ver Pago', 
             	fieldName: 'linkPago', 
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'linkPagoLabel' }
                  }
            }

        ]);
        component.set('v.paidColumns', [
            {
                label: 'Nro Pedido',
             	fieldName: 'oppId', 
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'oppName' }
                  }
            },
            {
                label: 'Nro Factura',
                fieldName: 'fiscalNoteNumber',
                type: 'text'
            },
            {
                label: 'Estado',
                fieldName: 'fiscalNoteStatus',
                type: 'text'
            },
            {
                label: 'Importe',
                fieldName: 'fiscalNoteAmount',
                type: 'currency'
            },
            {
                label: 'Fecha',
                fieldName: 'issueDate',
                type: 'text'
            },
            {
                label: 'Factura',
                type: 'button-icon',
                initialWidth: 105,
                typeAttributes: {
                    iconName: 'utility:download',
                    name: 'facturaIcono',
                    title: 'Click to Download Invoice',
                    disabled: {fieldName: 'facturaDisabled'}
                }
            },
            {
                label: 'Recibo',
                type: 'button-icon',
                initialWidth: 105,
                typeAttributes: {
                    iconName: 'utility:note',
                    name: 'reciboIcono',
                    title: 'Click to Download Receipt',
                    disabled: {fieldName: 'reciboDisabled'}
                }
            },
            {
                label: 'Ver Pago', 
             	fieldName: 'linkPago', 
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'linkPagoLabel' }
                  }
            }


        ]);
        component.set('v.ncColumns', [
            
            {
                label: 'Nro Factura',
                fieldName: 'LegalInvoice_AR__c',
                type: 'text'
            },
            {
                label: 'Tipo',
                fieldName: 'LAT_AR_TypeDescription__c',
                type: 'text'
            },
            {
                label: 'Importe',
                fieldName: 'valorOriginalTitulo__c',
                type: 'currency'
            },
            {
                label: 'Saldo',
                fieldName: 'valorSaldo__c',
                type: 'currency'
            },
            {
                label: 'Fecha',
                fieldName: 'dataEmissao__c',
                type: 'text'
            }


        ]);
        helper.doFetchFacturas(component);
        helper.doFetchPaidFacturas(component);
        helper.doFetchNotasDeCredito(component);
    },
    pay: function (component, event, helper) {
        helper.pay(component, event);
    },
    hideFileUpload: function (component, event, helper) {   
        component.set('v.mostrarCuadroPago', false);
    },
    showFileUpload: function (component, event, helper) {
        var target = component.find('cuadroDePago');
        console.log('target tabla : ' + target);
        var element = target.getElement();
        var rect = element.getBoundingClientRect();
        scrollTo({top: rect.top, behavior: "smooth"});
        
        
        helper.cretatePaymentJunction(component);
        component.set('v.mostrarCuadroPago', true);
    },
    cerrarCuadroPago:function (component, event, helper) {
        scrollTo({top: 0, behavior: "smooth"});
        var action = component.get('c.deleteB2BPayment');
            action.setParams({ 
                "paymentId": component.get("v.b2bPaymentId")
            });
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('eliminó');          
                }
            });
        $A.enqueueAction(action);
        let listaVacia = [];
        component.set('v.mostrarCuadroPago', false);
        component.set('v.uploadedFileIds', listaVacia);
        component.set('v.fileUploaded', false);
    },
    handleUploadFinished: function (component, event, helper) {
        component.set('v.uploadDisabled', true);
        var uploadedFiles = event.getParam("files");
        let uploadedFileIds = component.get('v.uploadedFileIds');
        for(var i=0; i<uploadedFiles.length; i++){
            console.log('file:'+uploadedFiles[i]);
            console.log('file.documentId:'+uploadedFiles[i].documentId);
            uploadedFileIds.push(uploadedFiles[i].documentId);
        }
        component.set('v.uploadedFileIds', uploadedFileIds);
        component.set('v.fileUploaded', true);
    },
    handleSelectNC: function (component, event, helper) {
        console.log('entramos al handle select');
        var selectedRows = event.getParam('selectedRows');
        var setRows = [];
        var totalSeleccionado = 0;
        for (var i = 0; i < selectedRows.length; i++) {
            setRows.push(selectedRows[i]);
            if(selectedRows[i].valorSaldo__c ){
                totalSeleccionado += Math.abs(selectedRows[i].valorSaldo__c);
            }
             
        }
        console.log('totalSeleccionado NC : '+ totalSeleccionado);
        totalSeleccionado = totalSeleccionado.toFixed(2);
        console.log('totalSeleccionado NC : '+ totalSeleccionado);
        console.log('setRows : '+ JSON.stringify(setRows));
        component.set("v.selectedNCs", setRows);
        component.set("v.paymentAmmountNC", totalSeleccionado);
        let valorFacts =  component.get("v.paymentAmmountFacturas");
        console.log('valorFacts en NC :'+ valorFacts);
        let suma = parseFloat(valorFacts)-totalSeleccionado;
        console.log('suma en NC :'+ suma);
        component.set("v.paymentAmmount", suma);
        
    }, 
    handleSelect: function (component, event, helper) {
        console.log('entramos al handle select');
        var selectedRows = event.getParam('selectedRows');
        var setRows = [];
        var totalSeleccionado = 0;
        for (var i = 0; i < selectedRows.length; i++) {
            setRows.push(selectedRows[i]);
            if(selectedRows[i].LAT_Balance__c){
                totalSeleccionado += selectedRows[i].LAT_Balance__c;
            }
             
        }
        console.log('totalSeleccionado : '+ totalSeleccionado);
        totalSeleccionado = totalSeleccionado.toFixed(2);
        console.log('totalSeleccionado : '+ totalSeleccionado);
        component.set("v.selectedNotes", setRows);
        component.set("v.paymentAmmountFacturas", totalSeleccionado);
        let valorNCs =  component.get("v.paymentAmmountNC");
        console.log('valorNCs en Fact :'+ valorNCs);
        let suma = totalSeleccionado - parseFloat(valorNCs);
        console.log('suma en Fact :'+ suma);
        component.set("v.paymentAmmount", suma);
        
    }, 
    handleRowAction: function (component, event, helper){
        var action = event.getParam('action');
        console.log('action.name en rowhandle : ' + action.name);
        var row = event.getParam('row');
        switch (action.name) {
            case 'facturaIcono':
                console.log('adentro del action : ' + row.descargarFactura);
                var address = row.descargarFactura;
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": address,
                  "isredirect" :true
                });
                urlEvent.fire();
                break;
            case 'reciboIcono':
                console.log('adentro del action : ' + row.descargarRecibo);
                var address = row.descargarRecibo;
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": address,
                  "isredirect" :true
                });
                urlEvent.fire();
                break;
            case 'pagoIcono':
                console.log('adentro del action : ' + row.verPago);
                var address = '/s/mi-cuenta/?tab=pagos&payment='+row.verPago;
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": address,
                  "isredirect" :true
                });
                urlEvent.fire();
                break;
        }
    },
	eliminarArchivo: function (component, event, helper) {
    	var selectedItem = event.currentTarget;
		var aId = selectedItem.dataset.item;
        var action = component.get('c.deleteAttachment');
            action.setParams({ 
                "attId": aId
            });
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('eliminó');          
                }
            });
        $A.enqueueAction(action);
        let uploadedFileIds = component.get('v.uploadedFileIds');
        uploadedFileIds = uploadedFileIds.filter(item =>  (item != aId) );
        component.set('v.uploadedFileIds',uploadedFileIds);
    	console.log('archivoid : '+aId );
	},
    irAFacturasPendientes: function (component, event, helper) {
   		scrollTo({top: 350, behavior: "smooth"});
    },
    handleAdelantoButtonClick : function (component) {
        component.set('v.esAdelanto', !component.get('v.esAdelanto'));
    }
})